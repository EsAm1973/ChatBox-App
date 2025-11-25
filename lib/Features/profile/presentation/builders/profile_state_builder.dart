import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/profile/data/models/profile_settings_model.dart';
import 'package:chatbox/Features/profile/presentation/manager/profile_cubit/profile_cubit.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_loading_state.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_error_state.dart';
import 'package:chatbox/Features/profile/presentation/builders/profile_content_builder.dart';
import 'package:chatbox/Features/profile/presentation/controllers/profile_view_controller.dart';
import 'package:chatbox/Core/cubit/user cubit/user_cubit.dart';

/// Builder responsible for handling different profile states and rendering appropriate UI
/// This centralizes state management logic and keeps the main view clean
class ProfileStateBuilder extends StatelessWidget {
  final ProfileViewController controller;
  final ProfileContentBuilder contentBuilder;

  const ProfileStateBuilder({
    super.key,
    required this.controller,
    required this.contentBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) {
        // Don't rebuild when only settings are being updated
        if (current is ProfileUpdateLoading) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        return _buildStateContent(context, state);
      },
    );
  }

  /// Build content based on current state
  Widget _buildStateContent(BuildContext context, ProfileState state) {
    if (state is ProfileInitial) {
      // Trigger data loading for initial state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initialize();
      });
      return const ProfileLoadingState();
    }

    if (state is ProfileLoading) {
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
      if (state.updateType != null &&
          state.updateType != ProfileUpdateType.none) {
        return _buildProfileContentFromCurrentData(context);
      }

      // Only show error state if we don't have any loaded data
      final userCubitUser = context.read<UserCubit>().getCurrentUser();
      if (userCubitUser != null) {
        return _buildProfileContent(
          context,
          userCubitUser,
          context.read<ProfileCubit>().currentSettings ??
              const ProfileSettingsModel(),
        );
      }

      return ProfileErrorState(
        message: state.message,
        onRetry: () => controller.initialize(),
      );
    }

    // Fallback: try to load from UserCubit if available
    return _buildProfileContentFromCurrentData(context);
  }

  /// Build profile content using current data from both cubits
  Widget _buildProfileContentFromCurrentData(BuildContext context) {
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
      onRetry: () => controller.initialize(),
    );
  }

  /// Build the actual profile content with all interactive elements
  Widget _buildProfileContent(
    BuildContext context,
    UserModel user,
    ProfileSettingsModel settings,
  ) {
    return contentBuilder.buildProfileContent(
      context,
      user,
      settings,
      onEditPicture: controller.showEditPictureOptions,
      onEditName: controller.showEditNameDialog,
      onEditEmail: controller.showEditEmailDialog,
      onEditPhone: controller.showEditPhoneDialog,
      onEditAbout: controller.showEditAboutDialog,
      onPrivacyTap: controller.navigateToPrivacySettings,
      onNotificationsTap: controller.updateNotificationSettings,
      onLogoutTap: controller.showLogoutDialog,
      onDeleteAccountTap: controller.showDeleteAccountDialog,
    );
  }
}