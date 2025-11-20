import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:chatbox/Core/cubit/user cubit/user_cubit.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/profile/presentation/manager/profile_cubit/profile_cubit.dart';
import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Features/profile/presentation/services/profile_image_service.dart';
import 'package:chatbox/Features/profile/presentation/services/profile_dialog_manager.dart';

class ProfileViewController {
  final BuildContext context;
  late final ProfileImageService _imageService;
  late final ProfileDialogManager _dialogManager;

  ProfileViewController(this.context) {
    _imageService = ProfileImageService(context);
    _dialogManager = ProfileDialogManager(context);
  }

  /// Initialize controller - load profile data
  Future<void> initialize() async {
    _loadProfileData();
  }

  /// Load profile data from both UserCubit and ProfileCubit
  void _loadProfileData() {
    final currentUser = context.read<UserCubit>().getCurrentUser();
    if (currentUser != null) {
      context.read<ProfileCubit>().loadProfileData(currentUser.uid);
    }
  }

  // Image Management
  Future<void> showEditPictureOptions() async {
    final currentUser = context.read<ProfileCubit>().currentUser;
    final hasExistingPhoto =
        currentUser?.profilePic != null && currentUser!.profilePic.isNotEmpty;

    await _dialogManager.showEditPictureBottomSheet(
      hasExistingPhoto: hasExistingPhoto,
      onTakePhoto: () => _pickImage(ImageSource.camera),
      onChooseFromGallery: () => _pickImage(ImageSource.gallery),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    await _imageService.pickAndUploadImage(
      source: source,
      onSuccess: _handleImageUploadSuccess,
      onError: _handleImageUploadError,
    );
  }

  void _handleImageUploadSuccess(String imageUrl) {
    // Update ProfileCubit
    context.read<ProfileCubit>().updateProfilePicture(imageUrl);

    // Update UserCubit for HomeAppBar
    context.read<UserCubit>().updateProfilePicture(imageUrl);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleImageUploadError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to upload image: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // User Information Editing
  Future<void> showEditNameDialog(String initialValue) async {
    await _dialogManager.showEditDialog(
      title: 'Edit Name',
      initialValue: initialValue,
      onSave:
          (value) => _updateUserField(
            () => context.read<ProfileCubit>().updateUserName(value),
            value,
            'name',
          ),
    );
  }

  Future<void> showEditEmailDialog(String initialValue) async {
    await _dialogManager.showEditDialog(
      title: 'Edit Email',
      initialValue: initialValue,
      onSave:
          (value) => _updateUserField(
            () => context.read<ProfileCubit>().updateUserEmail(value),
            value,
            'email',
          ),
    );
  }

  Future<void> showEditPhoneDialog(String initialValue) async {
    await _dialogManager.showEditDialog(
      title: 'Edit Phone',
      initialValue: initialValue,
      onSave:
          (value) => _updateUserField(
            () => context.read<ProfileCubit>().updateUserPhoneNumber(value),
            value,
            'phone',
          ),
    );
  }

  Future<void> showEditAboutDialog(String initialValue) async {
    await _dialogManager.showEditDialog(
      title: 'Edit About',
      initialValue: initialValue,
      onSave:
          (value) => _updateUserField(
            () => context.read<ProfileCubit>().updateUserAbout(value),
            value,
            'about',
          ),
    );
  }

  /// Generic method to update user fields and sync with UserCubit
  void _updateUserField(
    Future<void> Function() updateFunction,
    String value,
    String fieldName,
  ) {
    // Update through ProfileCubit
    updateFunction();

    // Sync with UserCubit for HomeAppBar
    final currentUser = context.read<UserCubit>().getCurrentUser();
    if (currentUser != null) {
      UserModel updatedUser;
      switch (fieldName) {
        case 'name':
          updatedUser = currentUser.copyWith(name: value);
          break;
        case 'email':
          updatedUser = currentUser.copyWith(email: value);
          break;
        case 'phone':
          updatedUser = currentUser.copyWith(phoneNumber: value);
          break;
        case 'about':
          updatedUser = currentUser.copyWith(about: value);
          break;
        default:
          return;
      }
      context.read<UserCubit>().updateUserProfile(updatedUser);
    }
  }

  // Settings Management
  Future<void> toggleTheme(bool isDark) async {
    await context.read<ProfileCubit>().toggleTheme(isDark);
  }

  Future<void> updateNotificationSettings(bool enabled) async {
    await context.read<ProfileCubit>().updateNotificationSettings(enabled);
  }

  // Navigation
  void navigateToPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy settings coming soon...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  // Account Actions
  Future<void> showLogoutDialog() async {
    await _dialogManager.showLogoutDialog(onLogout: performLogout);
  }

  Future<void> performLogout() async {
    try {
      // Show loading state
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Perform logout through ProfileCubit
      await context.read<ProfileCubit>().logout();

      // Also logout UserCubit to clear user state
      context.read<UserCubit>().logout();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to onboarding view
      if (context.mounted) {
        GoRouter.of(context).pushReplacement(AppRouter.kOnboardRoute);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> showDeleteAccountDialog() async {
    await _dialogManager.showDeleteAccountDialog(
      onDelete: performDeleteAccount,
    );
  }

  Future<void> performDeleteAccount() async {
    try {
      // Show loading state
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Perform delete account through ProfileCubit
      await context.read<ProfileCubit>().deleteAccount();

      // Also logout UserCubit to clear user state
      context.read<UserCubit>().logout();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to onboarding view
      if (context.mounted) {
        GoRouter.of(context).pushReplacement(AppRouter.kOnboardRoute);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account deletion failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
