import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/profile/data/models/profile_settings_model.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_header.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_info_section.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_actions_section.dart';

/// Builder class responsible for constructing the profile content UI
/// This separates the complex UI building logic from the main view
class ProfileContentBuilder {
  /// Build the complete profile content with proper state handling
  Widget buildProfileContent(
    BuildContext context,
    UserModel user,
    ProfileSettingsModel settings, {
    required VoidCallback onEditPicture,
    required Function(String) onEditName,
    required Function(String) onEditEmail,
    required Function(String) onEditPhone,
    required Function(String) onEditAbout,
    required VoidCallback onPrivacyTap,
    required Function(bool) onNotificationsTap,
    required VoidCallback onLogoutTap,
    required VoidCallback onDeleteAccountTap,
  }) {
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
          _buildTopSpacing(context),
          _buildProfileHeader(user, onEditPicture),
          _buildSpacing(24),
          _buildProfileInfoSection(
            user,
            settings,
            onEditName,
            onEditEmail,
            onEditPhone,
            onEditAbout,
          ),
          _buildSpacing(24),
          _buildProfileActionsSection(
            settings,
            onPrivacyTap,
            onNotificationsTap,
            onLogoutTap,
            onDeleteAccountTap,
          ),
          _buildBottomSpacing(),
        ],
      ),
    );
  }

  /// Build spacing widget
  Widget _buildSpacing(double height) {
    return SliverToBoxAdapter(
      child: SizedBox(height: height.h),
    );
  }

  /// Build top spacing with safe area consideration
  Widget _buildTopSpacing(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(height: 30.h + MediaQuery.of(context).padding.top),
    );
  }

  /// Build profile header section
  Widget _buildProfileHeader(UserModel user, VoidCallback onEditPicture) {
    return SliverToBoxAdapter(
      child: ProfileHeader(
        user: user,
        onEditPicture: onEditPicture,
      ),
    );
  }

  /// Build profile info section with all user information
  Widget _buildProfileInfoSection(
    UserModel user,
    ProfileSettingsModel settings,
    Function(String) onEditName,
    Function(String) onEditEmail,
    Function(String) onEditPhone,
    Function(String) onEditAbout,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ProfileInfoSection(
          user: user,
          settings: settings,
          onEditName: () => onEditName(user.name),
          onEditEmail: () => onEditEmail(user.email),
          onEditPhone: () => onEditPhone(user.phoneNumber ?? ''),
          onEditAbout: () => onEditAbout(user.about ?? ''),
        ),
      ),
    );
  }

  /// Build profile actions section with settings and account actions
  Widget _buildProfileActionsSection(
    ProfileSettingsModel settings,
    VoidCallback onPrivacyTap,
    Function(bool) onNotificationsTap,
    VoidCallback onLogoutTap,
    VoidCallback onDeleteAccountTap,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ProfileActionsSection(
          settings: settings,
          onPrivacyTap: onPrivacyTap,
          onNotificationsTap: onNotificationsTap,
          onLogoutTap: onLogoutTap,
          onDeleteAccountTap: onDeleteAccountTap,
        ),
      ),
    );
  }

  /// Build bottom spacing
  Widget _buildBottomSpacing() {
    return const SliverToBoxAdapter(
      child: SizedBox(height: 32),
    );
  }

  /// Build a custom section with header and content
  Widget buildCustomSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget content,
    required Gradient headerGradient,
    EdgeInsets? padding,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, title, icon, headerGradient),
            SizedBox(height: 16.h),
            content,
          ],
        ),
      ),
    );
  }

  /// Build section header with icon and title
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Gradient gradient,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}