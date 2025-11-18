part of 'profile_cubit.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final ProfileSettingsModel settings;

  const ProfileLoaded({
    required this.user,
    required this.settings,
  });
}

class ProfileUpdateLoading extends ProfileState {
  final ProfileUpdateType updateType;

  const ProfileUpdateLoading(this.updateType);
}

class ProfileUpdated extends ProfileState {
  final UserModel updatedUser;
  final ProfileSettingsModel updatedSettings;
  final ProfileUpdateType updateType;

  const ProfileUpdated({
    required this.updatedUser,
    required this.updatedSettings,
    required this.updateType,
  });
}

class ProfileError extends ProfileState {
  final String message;
  final ProfileUpdateType? updateType;

  const ProfileError({
    required this.message,
    this.updateType,
  });
}

class ProfileSettingsUpdated extends ProfileState {
  final ProfileSettingsModel settings;

  const ProfileSettingsUpdated(this.settings);
}

class ProfilePictureLoading extends ProfileState {}

class ProfilePictureUpdated extends ProfileState {
  final String imageUrl;

  const ProfilePictureUpdated(this.imageUrl);
}

class ProfilePictureError extends ProfileState {
  final String message;

  const ProfilePictureError({required this.message});
}

enum ProfileUpdateType {
  name,
  email,
  phone,
  about,
  picture,
  privacy,
  theme,
  notifications,
}