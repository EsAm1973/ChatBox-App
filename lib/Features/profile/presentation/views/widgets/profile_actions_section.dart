import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatbox/Features/profile/data/models/profile_settings_model.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';

class ProfileActionsSection extends StatelessWidget {
  final ProfileSettingsModel settings;
  final VoidCallback onPrivacyTap;
  final Function(bool) onThemeTap;
  final Function(bool) onNotificationsTap;
  final VoidCallback onLogoutTap;
  final VoidCallback onDeleteAccountTap;

  const ProfileActionsSection({
    super.key,
    required this.settings,
    required this.onPrivacyTap,
    required this.onThemeTap,
    required this.onNotificationsTap,
    required this.onLogoutTap,
    required this.onDeleteAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preferences Section
        _buildSectionHeader(
          context,
          'Preferences',
          Icons.tune_rounded,
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade300],
          ),
        ),

        SizedBox(height: 16.h),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDark
                      ? [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ]
                      : [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.dark_mode_rounded,
                title: 'Dark Theme',
                subtitle: 'Switch between light and dark themes',
                value: settings.darkTheme,
                onChanged: onThemeTap,
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade400, Colors.indigo.shade300],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Divider(
                  height: 1.h,
                  color: theme.dividerColor.withOpacity(0.1),
                ),
              ),

              _buildSwitchTile(
                context,
                icon: Icons.notifications_rounded,
                title: 'Push Notifications',
                subtitle: 'Enable notifications for new messages',
                value: settings.notificationsEnabled,
                onChanged: onNotificationsTap,
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade300],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // Account & Security Section
        _buildSectionHeader(
          context,
          'Account & Security',
          Icons.shield_rounded,
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade300],
          ),
        ),

        SizedBox(height: 16.h),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDark
                      ? [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ]
                      : [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActionTile(
                context,
                icon: Icons.lock_rounded,
                title: 'Privacy Settings',
                subtitle: 'Manage your privacy preferences',
                onTap: onPrivacyTap,
                gradient: LinearGradient(
                  colors: [Colors.teal.shade400, Colors.teal.shade300],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Divider(
                  height: 1.h,
                  color: theme.dividerColor.withOpacity(0.1),
                ),
              ),

              _buildActionTile(
                context,
                icon: Icons.help_rounded,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Help center coming soon...'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                },
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade300],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // Danger Zone
        _buildSectionHeader(
          context,
          'Danger Zone',
          Icons.warning_rounded,
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade300],
          ),
        ),

        SizedBox(height: 16.h),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDark
                      ? [
                        Colors.red.withOpacity(0.05),
                        Colors.red.withOpacity(0.02),
                      ]
                      : [Colors.red.shade50, Colors.white],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.red.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActionTile(
                context,
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                onTap: onLogoutTap,
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade300],
                ),
                isDestructive: true,
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Divider(height: 1.h, color: Colors.red.withOpacity(0.1)),
              ),

              _buildActionTile(
                context,
                icon: Icons.delete_forever_rounded,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                onTap: onDeleteAccountTap,
                gradient: LinearGradient(
                  colors: [Colors.red.shade500, Colors.red.shade400],
                ),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    required Gradient gradient,
  }) {
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
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: AppTextStyles.semiBold16.copyWith(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 18.sp,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Gradient gradient,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              // Icon Container with Gradient
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22.sp),
              ),

              SizedBox(width: 16.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.semiBold14.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.regular12.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Animated Switch
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    activeThumbColor: gradient.colors.first,
                    activeTrackColor: gradient.colors.first.withOpacity(0.3),
                    inactiveThumbColor: theme.disabledColor,
                    inactiveTrackColor: theme.disabledColor.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Gradient gradient,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22.sp),
              ),

              SizedBox(width: 16.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.semiBold14.copyWith(
                        color:
                            isDestructive
                                ? gradient.colors.first
                                : theme.textTheme.bodyLarge?.color,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.regular12.copyWith(
                        color:
                            isDestructive
                                ? gradient.colors.first.withOpacity(0.7)
                                : theme.textTheme.bodySmall?.color?.withOpacity(
                                  0.6,
                                ),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: gradient.colors.first.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: gradient.colors.first,
                  size: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
