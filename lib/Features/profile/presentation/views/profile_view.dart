import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatbox/Core/cubit/user%20cubit/user_cubit.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/profile/data/models/profile_settings_model.dart';
import 'package:chatbox/Features/profile/presentation/manager/profile_cubit/profile_cubit.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_app_bar.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_header.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_info_section.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_actions_section.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_loading_state.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_error_state.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_edit_picture_bottom_sheet.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_edit_dialog.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_logout_dialog.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_delete_account_dialog.dart';
import 'package:chatbox/Core/service/supabase_storage.dart';
import 'package:chatbox/Core/helper%20functions/animated_loading_dialog.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();

    // Load profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  void _loadProfileData() {
    final currentUser = context.read<UserCubit>().getCurrentUser();
    if (currentUser != null) {
      context.read<ProfileCubit>().loadProfileData(currentUser.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProfileAppBar(),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadProfileData();
              });
              return const ProfileLoadingState();
            }

            if (state is ProfileLoading || state is ProfileUpdateLoading) {
              return const ProfileLoadingState();
            }

            // If we have loaded data, always show it regardless of other states
            if (state is ProfileLoaded) {
              return _buildProfileContent(context, state.user, state.settings);
            }

            if (state is ProfileUpdated) {
              return _buildProfileContent(
                context,
                state.updatedUser,
                state.updatedSettings,
              );
            }

            // Handle errors intelligently
            if (state is ProfileError) {
              // For update-related errors, don't disrupt the UI - just continue showing current data
              if (state.updateType != null && state.updateType != ProfileUpdateType.none) {
                // Return current data instead of showing error
                final currentUser = context.read<UserCubit>().getCurrentUser();
                final currentSettings = context.read<ProfileCubit>().currentSettings;
                
                if (currentUser != null && currentSettings != null) {
                  return _buildProfileContent(
                    context,
                    currentUser,
                    currentSettings,
                  );
                }
              }
              
              // Only show error state if we don't have any loaded data
              final userCubitUser = context.read<UserCubit>().getCurrentUser();
              if (userCubitUser != null) {
                return _buildProfileContent(
                  context,
                  userCubitUser,
                  context.read<ProfileCubit>().currentSettings ?? const ProfileSettingsModel(),
                );
              }
              
              return ProfileErrorState(
                message: state.message,
                onRetry: _loadProfileData,
              );
            }

            // Fallback: try to load from UserCubit if available
            final userCubitUser = context.read<UserCubit>().getCurrentUser();
            if (userCubitUser != null) {
              final currentSettings = context.read<ProfileCubit>().currentSettings;
              if (currentSettings != null) {
                return _buildProfileContent(
                  context,
                  userCubitUser,
                  currentSettings,
                );
              }
            }

            return ProfileErrorState(
              message: 'Profile not loaded',
              onRetry: _loadProfileData,
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserModel user,
    ProfileSettingsModel settings,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.scaffoldBackgroundColor,
            theme.scaffoldBackgroundColor.withOpacity(0.8),
          ],
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.top + 30.h),
          ),

          // Profile Header
          SliverToBoxAdapter(
            child: ProfileHeader(
              user: user,
              onEditPicture: () => _showEditPictureOptions(context),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 24.h)),

          // Profile Info
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ProfileInfoSection(
                user: user,
                settings: settings,
                onEditName:
                    () => _showEditDialog(
                      context,
                      'Edit Name',
                      user.name,
                      (value) {
                        context.read<ProfileCubit>().updateUserName(value);
                        // Update UserCubit for HomeAppBar
                        final currentUser = context.read<UserCubit>().getCurrentUser();
                        if (currentUser != null) {
                          context.read<UserCubit>().updateUserProfile(
                            currentUser.copyWith(name: value),
                          );
                        }
                      },
                    ),
                onEditEmail:
                    () => _showEditDialog(
                      context,
                      'Edit Email',
                      user.email,
                      (value) {
                        context.read<ProfileCubit>().updateUserEmail(value);
                        // Update UserCubit for HomeAppBar
                        final currentUser = context.read<UserCubit>().getCurrentUser();
                        if (currentUser != null) {
                          context.read<UserCubit>().updateUserProfile(
                            currentUser.copyWith(email: value),
                          );
                        }
                      },
                    ),
                onEditPhone:
                    () => _showEditDialog(
                      context,
                      'Edit Phone',
                      user.phoneNumber ?? '',
                      (value) {
                        context.read<ProfileCubit>().updateUserPhoneNumber(value);
                        // Update UserCubit for HomeAppBar
                        final currentUser = context.read<UserCubit>().getCurrentUser();
                        if (currentUser != null) {
                          context.read<UserCubit>().updateUserProfile(
                            currentUser.copyWith(phoneNumber: value),
                          );
                        }
                      },
                    ),
                onEditAbout:
                    () => _showEditDialog(
                      context,
                      'Edit About',
                      user.about ?? '',
                      (value) {
                        context.read<ProfileCubit>().updateUserAbout(value);
                        // Update UserCubit for HomeAppBar
                        final currentUser = context.read<UserCubit>().getCurrentUser();
                        if (currentUser != null) {
                          context.read<UserCubit>().updateUserProfile(
                            currentUser.copyWith(about: value),
                          );
                        }
                      },
                    ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 24.h)),

          // Actions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ProfileActionsSection(
                settings: settings,
                onPrivacyTap: () => _navigateToPrivacySettings(context),
                onThemeTap:
                    (isDark) =>
                        context.read<ProfileCubit>().toggleTheme(isDark),
                onNotificationsTap:
                    (enabled) => context
                        .read<ProfileCubit>()
                        .updateNotificationSettings(enabled),
                onLogoutTap: () => _showLogoutDialog(context),
                onDeleteAccountTap: () => _showDeleteAccountDialog(context),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 32.h)),
        ],
      ),
    );
  }

  void _showEditPictureOptions(BuildContext context) {
    final currentUser = context.read<ProfileCubit>().currentUser;
    final hasExistingPhoto =
        currentUser?.profilePic != null && currentUser!.profilePic.isNotEmpty;

    ProfileEditPictureBottomSheet.show(
      context: context,
      onTakePhoto: () => _takePhoto(context),
      onChooseFromGallery: () => _chooseFromGallery(context),
      hasExistingPhoto: hasExistingPhoto,
    );
  }

  Future<void> _takePhoto(BuildContext context) async {
    await _pickImage(context, ImageSource.camera);
  }

  Future<void> _chooseFromGallery(BuildContext context) async {
    await _pickImage(context, ImageSource.gallery);
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        await _uploadImage(context, File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImage(BuildContext context, File imageFile) async {
    // Show loading dialog first
    if (mounted) {
      openLoadingAnimatedDialog(
        context,
        'uploading_image',
        'Uploading Image',
        'Please wait while we upload your profile picture...',
      );
    }

    try {
      // Get current user from both user cubit and profile cubit for reliability
      UserModel? currentUser = context.read<UserCubit>().getCurrentUser();
      currentUser ??= context.read<ProfileCubit>().currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Initialize Supabase storage service if not already done
      await SupabaseStorageService.initSupabaseStorage();

      // Upload image to Supabase storage
      final storageService = SupabaseStorageService();
      final imageUrl = await storageService.uploadFile(
        imageFile,
        'profile_pictures',
        currentUser.uid,
      );

      // Update profile picture in both ProfileCubit and UserCubit
      await context.read<ProfileCubit>().updateProfilePicture(imageUrl);

      // Update UserCubit with the new profile picture URL
      context.read<UserCubit>().updateProfilePicture(imageUrl);

      if (mounted) {
        // Close the loading dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Close the loading dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String initialValue,
    Function(String) onSave,
  ) {
    ProfileEditDialog.show(
      context: context,
      title: title,
      initialValue: initialValue,
      onSave: onSave,
    );
  }

  void _navigateToPrivacySettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Privacy settings coming soon...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    ProfileLogoutDialog.show(
      context: context,
      onLogout: () => context.read<ProfileCubit>().logout(),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    ProfileDeleteAccountDialog.show(
      context: context,
      onDelete: () => context.read<ProfileCubit>().deleteAccount(),
    );
  }
}
