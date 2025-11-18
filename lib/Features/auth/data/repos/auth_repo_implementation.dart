import 'dart:io';
import 'dart:developer';
import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/service/firebase_auth_service.dart';
import 'package:chatbox/Core/service/firestore_user_service.dart';
import 'package:chatbox/Core/service/storage_service.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/auth/data/repos/auth_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepoImplementation implements AuthRepo {
  final FirebaseAuthService firebaseAuthServices;
  final StorageService storageService;
  final FirestoreUserService firestoreService;

  AuthRepoImplementation(
    this.firebaseAuthServices,
    this.storageService,
    this.firestoreService,
  );

  /// Helper method to handle errors consistently across all repository methods
  Either<Failure, T> _handleError<T>(dynamic error, String operation) {
    log('Error during $operation: $error');
    if (error is Failure) {
      return Left(error);
    } else {
      return Left(
        FirebaseFailure(
          errorMessage:
              'An unexpected error occurred during $operation: $error',
        ),
      );
    }
  }

  /// Helper method to clean up resources when user creation fails
  Future<void> _cleanupUserResources(
    User user,
    String? uploadedImageUrl,
  ) async {
    final uid = user.uid;
    // 1. Delete the uploaded image if it exists
    if (uploadedImageUrl != null) {
      try {
        await storageService.deleteFile(uploadedImageUrl);
      } catch (deleteError) {
        // Log the error but don't throw it as we want to preserve the original error
        log('Failed to delete image during rollback: $deleteError');
      }
    }
    // 2. Delete any Firestore data that might have been created
    try {
      await firestoreService.deleteUser(uid);
    } catch (deleteError) {
      // Log the error but don't throw it as we want to preserve the original error
      log('Failed to delete Firestore data during rollback: $deleteError');
    }
    // 3. Delete the user from Firebase Auth
    try {
      await firebaseAuthServices.deleteUser(uid);
    } catch (deleteError) {
      // Log the error but don't throw it as we want to preserve the original error
      log('Failed to delete user during rollback: $deleteError');
    }
  }

  @override
  Future<Either<Failure, UserModel>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required File profilePic,
  }) async {
    String? uploadedImageUrl;
    User? user;
    try {
      // 1. Create user in Firebase Auth (email verification is sent automatically in the service)
      user = await firebaseAuthServices.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );

      // 2. Upload the image to storage
      uploadedImageUrl = await storageService.uploadFile(
        profilePic,
        'user-image',
        user.uid,
      );

      // 3. Create UserModel with the image URL
      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        profilePic: uploadedImageUrl,
        phoneNumber: '',
        about: '',
        isOnline: true,
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
      );

      // 4. Save user to Firestore
      await firestoreService.saveUser(userModel);
      return Right(userModel);
    } on Failure catch (e) {
      // Clean up resources if we failed after creating some of them
      if (user != null) {
        await _cleanupUserResources(user, uploadedImageUrl);
      }
      return Left(e);
    } catch (e) {
      // Clean up resources if we failed after creating some of them
      if (user != null) {
        await _cleanupUserResources(user, uploadedImageUrl);
      }
      return _handleError(e, 'user registration');
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await firebaseAuthServices.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userModel = await firestoreService.getUser(user.uid);
      if (userModel == null) {
        return Left(
          FirebaseFailure(
            errorMessage: 'User data not found. Please contact support.',
          ),
        );
      }

      final updatedUserModel = userModel.copyWith(
        isOnline: true,
        lastSeen: DateTime.now(),
      );

      await firestoreService.saveUser(updatedUserModel);
      return Right(updatedUserModel);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return _handleError(e, 'sign in');
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      // Update user's online status before signing out
      if (currentUser != null) {
        final userModel = await firestoreService.getUser(currentUser.uid);
        if (userModel != null) {
          final updatedUserModel = userModel.copyWith(
            isOnline: false,
            lastSeen: DateTime.now(),
          );
          await firestoreService.saveUser(updatedUserModel);
        }
      }

      await firebaseAuthServices.signOut();
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return _handleError(e, 'sign out');
    }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return Left(
          FirebaseFailure(errorMessage: 'No user currently signed in'),
        );
      }

      final userModel = await firestoreService.getUser(currentUser.uid);

      if (userModel == null) {
        return Left(FirebaseFailure(errorMessage: 'User data not found'));
      }

      return Right(userModel);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return _handleError(e, 'get current user data');
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification({
    required String email,
  }) async {
    try {
      await firebaseAuthServices.sendEmailVerification(email: email);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return _handleError(e, 'send verification email');
    }
  }

  @override
  Future<Either<Failure, bool>> isEmailVerified({required String email}) async {
    try {
      final isVerified = await firebaseAuthServices.isEmailVerified(
        email: email,
      );
      return Right(isVerified);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return _handleError(e, 'check email verification status');
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserAccount() async {
    try {
      // 1. Get current user data
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Left(
          FirebaseFailure(errorMessage: 'No user currently signed in'),
        );
      }

      final uid = currentUser.uid;

      // 2. Get user model to access profile picture URL
      final userModel = await firestoreService.getUser(uid);
      if (userModel == null) {
        return Left(FirebaseFailure(errorMessage: 'User data not found'));
      }

      // 3. Delete user's profile picture from Supabase storage
      if (userModel.profilePic.isNotEmpty &&
          userModel.profilePic != 'default_profile_pic_url') {
        try {
          await storageService.deleteFile(userModel.profilePic);
        } catch (e) {
          // Log error but continue with deletion process
          log('Failed to delete profile picture: $e');
        }
      }

      // 4. Delete user data from Firestore
      await firestoreService.deleteUser(uid);

      // 5. Delete user from Firebase Authentication
      await firebaseAuthServices.deleteUser(uid);

      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return _handleError(e, 'delete user account');
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      // 1. Authenticate with Google
      final user = await firebaseAuthServices.signInWithGoogle();

      // 2. Check if user already exists in Firestore by email
      UserModel? existingUser = await firestoreService.getUserByEmail(
        user.email!,
      );

      if (existingUser != null) {
        // User already exists, update online status and last seen
        final updatedUserModel = existingUser.copyWith(
          isOnline: true,
          lastSeen: DateTime.now(),
        );

        await firestoreService.saveUser(updatedUserModel);
        return Right(updatedUserModel);
      } else {
        // User doesn't exist, create a new user
        // Get profile image URL from Google or use a default
        String profilePicUrl = user.photoURL ?? '';

        // Create new user model
        final userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Google User',
          email: user.email!,
          profilePic: profilePicUrl,
          phoneNumber: user.phoneNumber ?? '',
          about: '',
          isOnline: true,
          createdAt: DateTime.now(),
          lastSeen: DateTime.now(),
        );

        // Save user to Firestore
        await firestoreService.saveUser(userModel);
        return Right(userModel);
      }
    } on Failure catch (e) {
      // Handle specific cancellation error
      if (e.errorMessage.contains('canceled by user')) {
        log('Google sign-in was canceled by the user');
        return Left(FirebaseFailure(errorMessage: 'Sign in was canceled'));
      }
      return Left(e);
    } catch (e) {
      return _handleError(e, 'Google sign in');
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithFacebook() async {
    try {
      // 1. Authenticate with Facebook
      final user = await firebaseAuthServices.signInWithFacebook();

      // 2. Check if user already exists in Firestore by email
      UserModel? existingUser = await firestoreService.getUserByEmail(
        user.email!,
      );

      if (existingUser != null) {
        // User already exists, update online status and last seen
        final updatedUserModel = existingUser.copyWith(
          isOnline: true,
          lastSeen: DateTime.now(),
        );

        await firestoreService.saveUser(updatedUserModel);
        return Right(updatedUserModel);
      } else {
        // User doesn't exist, create a new user
        // Get profile image URL from Facebook or use a default
        String profilePicUrl = user.photoURL ?? '';

        // Create new user model
        final userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Facebook User',
          email: user.email!,
          profilePic: profilePicUrl,
          phoneNumber: user.phoneNumber ?? '',
          about: '',
          isOnline: true,
          createdAt: DateTime.now(),
          lastSeen: DateTime.now(),
        );

        // Save user to Firestore
        await firestoreService.saveUser(userModel);
        return Right(userModel);
      }
    } on Failure catch (e) {
      // Handle specific cancellation error
      if (e.errorMessage.contains('canceled') || e.errorMessage.contains('failed')) {
        log('Facebook sign-in was canceled by the user');
        return Left(FirebaseFailure(errorMessage: 'Sign in was canceled'));
      }
      return Left(e);
    } catch (e) {
      return _handleError(e, 'Facebook sign in');
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await firebaseAuthServices.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return _handleError(e, 'send password reset email');
    }
  }
}
