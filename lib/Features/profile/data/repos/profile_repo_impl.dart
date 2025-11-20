import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/service/firestore_profile_service.dart';
import 'package:chatbox/Core/service/local_profile_service.dart';
import 'package:chatbox/Core/service/supabase_storage.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/profile/data/models/profile_settings_model.dart';
import 'package:chatbox/Features/profile/data/repos/profile_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepoImpl implements ProfileRepo {
  final FirestoreProfileService _profileService;
  final LocalProfileService _localProfileService;

  ProfileRepoImpl({
    required FirestoreProfileService profileService,
    required LocalProfileService localProfileService,
  })  : _profileService = profileService,
        _localProfileService = localProfileService;

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProfileData(String uid) async {
    try {
      // Get user data from Firestore
      final userData = await _profileService.getUserData(uid);
      if (userData == null) {
        return Left(FirebaseFailure(errorMessage: 'User not found'));
      }

      // Get user settings from local storage
      final settings = _localProfileService.getUserSettings();

      return Right({
        'user': userData,
        'settings': settings,
      });
    } on FirebaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to get profile data: $e'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUserName(String name) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Left(FirebaseFailure(errorMessage: 'User not authenticated'));
      }

      // Update in Firestore through service
      final updatedUser = await _profileService.updateUserName(currentUser.uid, name);
      
      return Right(updatedUser);
    } on FirebaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to update name: $e'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUserEmail(String email) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Left(FirebaseFailure(errorMessage: 'User not authenticated'));
      }

      // Update in Firestore through service
      final updatedUser = await _profileService.updateUserEmail(currentUser.uid, email);
      
      return Right(updatedUser);
    } on FirebaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to update email: $e'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUserPhoneNumber(String phoneNumber) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Left(FirebaseFailure(errorMessage: 'User not authenticated'));
      }

      // Update in Firestore through service
      final updatedUser = await _profileService.updateUserPhoneNumber(
        currentUser.uid, 
        phoneNumber,
      );
      
      return Right(updatedUser);
    } on FirebaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to update phone number: $e'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUserAbout(String about) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Left(FirebaseFailure(errorMessage: 'User not authenticated'));
      }

      // Update in Firestore through service
      final updatedUser = await _profileService.updateUserAbout(currentUser.uid, about);
      
      return Right(updatedUser);
    } on FirebaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to update about: $e'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfilePicture(String imageUrl) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Left(FirebaseFailure(errorMessage: 'User not authenticated'));
      }

      // Update in Firestore through service
      final updatedUser = await _profileService.updateProfilePicture(
        currentUser.uid, 
        imageUrl,
      );
      
      return Right(updatedUser);
    } on FirebaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to update profile picture: $e'));
    }
  }

  @override
  Future<Either<Failure, ProfileSettingsModel>> updatePrivacySettings({
    bool? lastSeenVisible,
    bool? profilePictureVisible,
    bool? onlineStatusVisible,
  }) async {
    try {
      // Update in local storage through service
      final updatedSettings = await _localProfileService.updatePrivacySettings(
        lastSeenVisible: lastSeenVisible,
        profilePictureVisible: profilePictureVisible,
        onlineStatusVisible: onlineStatusVisible,
      );

      return Right(updatedSettings);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to update privacy settings: $e'));
    }
  }

  @override
  Future<Either<Failure, ProfileSettingsModel>> updateNotificationSettings(bool enabled) async {
    try {
      // Update in local storage through service
      final updatedSettings = await _localProfileService.updateNotificationSettings(
        enabled: enabled,
      );

      return Right(updatedSettings);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to update notification settings: $e'));
    }
  }

  @override
  Future<Either<Failure, ProfileSettingsModel>> updateThemePreference(bool darkTheme) async {
    try {
      // Update in local storage through service
      final updatedSettings = await _localProfileService.updateThemePreference(
        darkTheme: darkTheme,
      );

      return Right(updatedSettings);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to update theme preference: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear local settings
      await _localProfileService.clearSettings();
      
      // Clear downloaded files data
      await SupabaseStorageService.clearDownloadedFiles();
      
      // Logout through service
      await _profileService.logout();
      
      return const Right(null);
    } on FirebaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to logout: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Left(FirebaseFailure(errorMessage: 'User not authenticated'));
      }

      // Clear local settings
      await _localProfileService.clearSettings();
      
      // Clear downloaded files data
      await SupabaseStorageService.clearDownloadedFiles();
      
      // Delete account through service
      await _profileService.deleteAccount(currentUser.uid);
      
      return const Right(null);
    } on FirebaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to delete account: $e'));
    }
  }
}
