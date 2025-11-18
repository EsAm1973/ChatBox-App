import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/profile/data/models/profile_settings_model.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepo {
  Future<Either<Failure, Map<String, dynamic>>> getProfileData(String uid);
  Future<Either<Failure, UserModel>> updateUserName(String name);
  Future<Either<Failure, UserModel>> updateUserEmail(String email);
  Future<Either<Failure, UserModel>> updateUserPhoneNumber(String phoneNumber);
  Future<Either<Failure, UserModel>> updateUserAbout(String about);
  Future<Either<Failure, UserModel>> updateProfilePicture(String imageUrl);
  Future<Either<Failure, ProfileSettingsModel>> updatePrivacySettings({
    bool? lastSeenVisible,
    bool? profilePictureVisible,
    bool? onlineStatusVisible,
  });
  Future<Either<Failure, ProfileSettingsModel>> updateNotificationSettings(bool enabled);
  Future<Either<Failure, ProfileSettingsModel>> updateThemePreference(bool darkTheme);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> deleteAccount();
}