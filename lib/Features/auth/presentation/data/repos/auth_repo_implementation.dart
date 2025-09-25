import 'dart:io';

import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/service/firebase_auth_service.dart';
import 'package:chatbox/Core/service/firestore_service.dart';
import 'package:chatbox/Core/service/storage_service.dart';
import 'package:chatbox/Features/auth/presentation/data/models/user_model.dart';
import 'package:chatbox/Features/auth/presentation/data/repos/auth_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepoImplementation implements AuthRepo {
  final FirebaseAuthService firebaseAuthServices;
  final StorageService storageService;
  final FirestoreService firestoreService;

  AuthRepoImplementation(
    this.firebaseAuthServices,
    this.storageService,
    this.firestoreService,
  );

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
      // 2. Create user in Firebase Auth
      user = await firebaseAuthServices.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );

      // 1. First upload the image to Supabase
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
      await user.sendEmailVerification();
      return Right(userModel);
    } on Failure catch (e) {
      // If we uploaded an image but then failed, delete the image
      if (uploadedImageUrl != null) {
        try {
          await storageService.deleteFile(uploadedImageUrl);
          await firebaseAuthServices.deleteUser(user!.uid);
        } catch (deleteError) {
          // Log the error but don't throw it as we want to preserve the original error
          print('Failed to delete image during rollback: $deleteError');
        }
      }
      return Left(e);
    } catch (e) {
      // If we uploaded an image but then failed, delete the image
      if (uploadedImageUrl != null) {
        try {
          await storageService.deleteFile(uploadedImageUrl);
          await firebaseAuthServices.deleteUser(user!.uid);
        } catch (deleteError) {
          // Log the error but don't throw it as we want to preserve the original error
          print('Failed to delete image during rollback: $deleteError');
        }
      }
      return Left(
        FirebaseFailure(errorMessage: 'An unexpected error occurred: $e'),
      );
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
      return Left(
        FirebaseFailure(errorMessage: 'An unexpected error occurred: $e'),
      );
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
      return Left(FirebaseFailure(errorMessage: 'Failed to sign out: $e'));
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
      return Left(
        FirebaseFailure(errorMessage: 'Failed to get current user data: $e'),
      );
    }
  }
}
