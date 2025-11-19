import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

            if (state is ProfileLoading) {
              return const ProfileLoadingState();
            }

            if (state is ProfileError) {
              return ProfileErrorState(
                message: state.message,
                onRetry: _loadProfileData,
              );
            }

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

            final userCubitUser = context.read<UserCubit>().getCurrentUser();
            if (userCubitUser != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadProfileData();
              });
              return const ProfileLoadingState();
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
                      (value) =>
                          context.read<ProfileCubit>().updateUserName(value),
                    ),
                onEditEmail:
                    () => _showEditDialog(
                      context,
                      'Edit Email',
                      user.email,
                      (value) =>
                          context.read<ProfileCubit>().updateUserEmail(value),
                    ),
                onEditPhone:
                    () => _showEditDialog(
                      context,
                      'Edit Phone',
                      user.phoneNumber ?? '',
                      (value) => context
                          .read<ProfileCubit>()
                          .updateUserPhoneNumber(value),
                    ),
                onEditAbout:
                    () => _showEditDialog(
                      context,
                      'Edit About',
                      user.about ?? '',
                      (value) =>
                          context.read<ProfileCubit>().updateUserAbout(value),
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
      onTakePhoto: () {},
      onChooseFromGallery: () {},
      onRemovePhoto: () {},
      hasExistingPhoto: hasExistingPhoto,
    );
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
