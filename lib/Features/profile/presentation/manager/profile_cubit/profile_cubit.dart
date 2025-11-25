import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/profile/data/models/profile_settings_model.dart';
import 'package:chatbox/Features/profile/data/repos/profile_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo _profileRepo;

  ProfileCubit({required ProfileRepo profileRepo})
      : _profileRepo = profileRepo,
        super(ProfileInitial());

  Future<void> loadProfileData(String uid) async {
    emit(ProfileLoading());

    final result = await _profileRepo.getProfileData(uid);
    
    result.fold(
      (failure) => emit(ProfileError(message: failure.errorMessage)),
      (profileData) => emit(ProfileLoaded(
        user: profileData['user'],
        settings: profileData['settings'],
      )),
    );
  }

  Future<void> updateUserName(String name) async {
    if (state is! ProfileLoaded && state is! ProfileUpdated) return;

    emit(const ProfileUpdateLoading(ProfileUpdateType.name));

    final result = await _profileRepo.updateUserName(name);
    
    result.fold(
      (failure) => emit(ProfileError(
        message: failure.errorMessage,
        updateType: ProfileUpdateType.name,
      )),
      (updatedUser) {
        // Get current settings from any loaded state
        ProfileSettingsModel currentSettings;
        if (state is ProfileLoaded) {
          currentSettings = (state as ProfileLoaded).settings;
        } else if (state is ProfileUpdated) {
          currentSettings = (state as ProfileUpdated).updatedSettings;
        } else {
          currentSettings = const ProfileSettingsModel(); // fallback
        }
        
        emit(ProfileUpdated(
          updatedUser: updatedUser,
          updatedSettings: currentSettings,
          updateType: ProfileUpdateType.name,
        ));
      },
    );
  }

  Future<void> updateUserEmail(String email) async {
    if (state is! ProfileLoaded && state is! ProfileUpdated) return;

    emit(const ProfileUpdateLoading(ProfileUpdateType.email));

    final result = await _profileRepo.updateUserEmail(email);
    
    result.fold(
      (failure) => emit(ProfileError(
        message: failure.errorMessage,
        updateType: ProfileUpdateType.email,
      )),
      (updatedUser) {
        // Get current settings from any loaded state
        ProfileSettingsModel currentSettings;
        if (state is ProfileLoaded) {
          currentSettings = (state as ProfileLoaded).settings;
        } else if (state is ProfileUpdated) {
          currentSettings = (state as ProfileUpdated).updatedSettings;
        } else {
          currentSettings = const ProfileSettingsModel(); // fallback
        }
        
        emit(ProfileUpdated(
          updatedUser: updatedUser,
          updatedSettings: currentSettings,
          updateType: ProfileUpdateType.email,
        ));
      },
    );
  }

  Future<void> updateUserPhoneNumber(String phoneNumber) async {
    if (state is! ProfileLoaded && state is! ProfileUpdated) return;

    emit(const ProfileUpdateLoading(ProfileUpdateType.phone));

    final result = await _profileRepo.updateUserPhoneNumber(phoneNumber);
    
    result.fold(
      (failure) => emit(ProfileError(
        message: failure.errorMessage,
        updateType: ProfileUpdateType.phone,
      )),
      (updatedUser) {
        // Get current settings from any loaded state
        ProfileSettingsModel currentSettings;
        if (state is ProfileLoaded) {
          currentSettings = (state as ProfileLoaded).settings;
        } else if (state is ProfileUpdated) {
          currentSettings = (state as ProfileUpdated).updatedSettings;
        } else {
          currentSettings = const ProfileSettingsModel(); // fallback
        }
        
        emit(ProfileUpdated(
          updatedUser: updatedUser,
          updatedSettings: currentSettings,
          updateType: ProfileUpdateType.phone,
        ));
      },
    );
  }

  Future<void> updateUserAbout(String about) async {
    if (state is! ProfileLoaded && state is! ProfileUpdated) return;

    emit(const ProfileUpdateLoading(ProfileUpdateType.about));

    final result = await _profileRepo.updateUserAbout(about);
    
    result.fold(
      (failure) => emit(ProfileError(
        message: failure.errorMessage,
        updateType: ProfileUpdateType.about,
      )),
      (updatedUser) {
        // Get current settings from any loaded state
        ProfileSettingsModel currentSettings;
        if (state is ProfileLoaded) {
          currentSettings = (state as ProfileLoaded).settings;
        } else if (state is ProfileUpdated) {
          currentSettings = (state as ProfileUpdated).updatedSettings;
        } else {
          currentSettings = const ProfileSettingsModel(); // fallback
        }
        
        emit(ProfileUpdated(
          updatedUser: updatedUser,
          updatedSettings: currentSettings,
          updateType: ProfileUpdateType.about,
        ));

        // TODO: Update UserCubit here when we have access to it
        // This will ensure HomeAppBar reflects the changes immediately
      },
    );
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    if (state is! ProfileLoaded && state is! ProfileUpdated) return;

    emit(const ProfileUpdateLoading(ProfileUpdateType.picture));

    final result = await _profileRepo.updateProfilePicture(imageUrl);
    
    result.fold(
      (failure) => emit(ProfileError(
        message: failure.errorMessage,
        updateType: ProfileUpdateType.picture,
      )),
      (updatedUser) {
        // Get current settings from any loaded state
        ProfileSettingsModel currentSettings;
        if (state is ProfileLoaded) {
          currentSettings = (state as ProfileLoaded).settings;
        } else if (state is ProfileUpdated) {
          currentSettings = (state as ProfileUpdated).updatedSettings;
        } else {
          currentSettings = const ProfileSettingsModel(); // fallback
        }
        
        emit(ProfileUpdated(
          updatedUser: updatedUser,
          updatedSettings: currentSettings,
          updateType: ProfileUpdateType.picture,
        ));
      },
    );
  }

  Future<void> updatePrivacySettings({
    bool? lastSeenVisible,
    bool? profilePictureVisible,
    bool? onlineStatusVisible,
  }) async {
    if (state is! ProfileLoaded && state is! ProfileUpdated) return;

    // Save current user before changing state
    final currentUser = this.currentUser;
    if (currentUser == null) return;

    emit(const ProfileUpdateLoading(ProfileUpdateType.privacy));

    final result = await _profileRepo.updatePrivacySettings(
      lastSeenVisible: lastSeenVisible,
      profilePictureVisible: profilePictureVisible,
      onlineStatusVisible: onlineStatusVisible,
    );

    result.fold(
      (failure) => emit(ProfileError(
        message: failure.errorMessage,
        updateType: ProfileUpdateType.privacy,
      )),
      (updatedSettings) {
        emit(ProfileUpdated(
          updatedUser: currentUser,
          updatedSettings: updatedSettings,
          updateType: ProfileUpdateType.privacy,
        ));
      },
    );
  }

  Future<void> updateNotificationSettings(bool notificationsEnabled) async {
    if (state is! ProfileLoaded && state is! ProfileUpdated) return;

    // Save current user before changing state
    final currentUser = this.currentUser;
    if (currentUser == null) return;

    emit(const ProfileUpdateLoading(ProfileUpdateType.notifications));

    final result = await _profileRepo.updateNotificationSettings(notificationsEnabled);

    result.fold(
      (failure) => emit(ProfileError(
        message: failure.errorMessage,
        updateType: ProfileUpdateType.notifications,
      )),
      (updatedSettings) {
        emit(ProfileUpdated(
          updatedUser: currentUser,
          updatedSettings: updatedSettings,
          updateType: ProfileUpdateType.notifications,
        ));
      },
    );
  }

  Future<void> toggleTheme(bool darkTheme) async {
    if (state is! ProfileLoaded && state is! ProfileUpdated) return;

    // Save current user before changing state
    final currentUser = this.currentUser;
    if (currentUser == null) return;

    emit(const ProfileUpdateLoading(ProfileUpdateType.theme));

    final result = await _profileRepo.updateThemePreference(darkTheme);

    result.fold(
      (failure) => emit(ProfileError(
        message: failure.errorMessage,
        updateType: ProfileUpdateType.theme,
      )),
      (updatedSettings) {
        emit(ProfileUpdated(
          updatedUser: currentUser,
          updatedSettings: updatedSettings,
          updateType: ProfileUpdateType.theme,
        ));
      },
    );
  }

  Future<void> logout() async {
    emit(ProfileLoading());
    
    final result = await _profileRepo.logout();
    
    result.fold(
      (failure) => emit(ProfileError(message: 'Logout failed: ${failure.errorMessage}')),
      (_) => emit(ProfileInitial()),
    );
  }

  Future<void> deleteAccount() async {
    emit(ProfileLoading());
    
    final result = await _profileRepo.deleteAccount();
    
    result.fold(
      (failure) => emit(ProfileError(message: 'Account deletion failed: ${failure.errorMessage}')),
      (_) => emit(ProfileInitial()),
    );
  }

  // Getters
  UserModel? get currentUser {
    if (state is ProfileLoaded) {
      return (state as ProfileLoaded).user;
    }
    if (state is ProfileUpdated) {
      return (state as ProfileUpdated).updatedUser;
    }
    return null;
  }

  ProfileSettingsModel? get currentSettings {
    if (state is ProfileLoaded) {
      return (state as ProfileLoaded).settings;
    }
    if (state is ProfileUpdated) {
      return (state as ProfileUpdated).updatedSettings;
    }
    return null;
  }

  bool get isProfileLoaded => state is ProfileLoaded || state is ProfileUpdated;
  
  bool get isLoading => state is ProfileLoading || state is ProfileUpdateLoading;
}