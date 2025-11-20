import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatbox/Features/profile/data/models/profile_settings_model.dart';
import 'package:chatbox/Features/profile/presentation/manager/profile_cubit/profile_cubit.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';

class ProfileActionsSection extends StatefulWidget {
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
  State<ProfileActionsSection> createState() => _ProfileActionsSectionState();
}

class _ProfileActionsSectionState extends State<ProfileActionsSection> {
  late bool _darkTheme;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _darkTheme = widget.settings.darkTheme;
    _notificationsEnabled = widget.settings.notificationsEnabled;
  }

  @override
  void didUpdateWidget(ProfileActionsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state when settings change from outside
    if (oldWidget.settings != widget.settings) {
      _darkTheme = widget.settings.darkTheme;
      _notificationsEnabled = widget.settings.notificationsEnabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        // Update local state when settings are updated
        if (state is ProfileUpdated) {
          setState(() {
            _darkTheme = state.updatedSettings.darkTheme;
            _notificationsEnabled = state.updatedSettings.notificationsEnabled;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preferences Section
          _buildSectionHeader(
            context,
            'Preferences',
            Icons.tune_rounded,
            gradient: LinearGradient(
              colors: [
                Colors.purple,
                Colors.purple.withOpacity(0.8),
              ],
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
                  value: _darkTheme,
                  onChanged: (value) {
                    setState(() {
                      _darkTheme = value;
                    });
                    widget.onThemeTap(value);
                  },
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.8),
                      Colors.purple.withOpacity(0.6),
                    ],
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
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    widget.onNotificationsTap(value);
                  },
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.8),
                      Colors.orange.withOpacity(0.6),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Privacy Section
          _buildSectionHeader(
            context,
            'Privacy',
            Icons.security_rounded,
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.blue.withOpacity(0.8),
              ],
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
            child: _buildActionTile(
              context,
              icon: Icons.lock_rounded,
              title: 'Privacy Settings',
              subtitle: 'Manage your privacy preferences',
              onTap: widget.onPrivacyTap,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.8),
                  Colors.blue.withOpacity(0.6),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Danger Zone
          _buildSectionHeader(
            context,
            'Danger Zone',
            Icons.warning_rounded,
            gradient: LinearGradient(
              colors: [
                Colors.red,
                Colors.red.withOpacity(0.8),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isDark
                        ? [
                          theme.colorScheme.error.withOpacity(0.05),
                          theme.colorScheme.error.withOpacity(0.02),
                        ]
                        : [
                          theme.colorScheme.error.withOpacity(0.05),
                          theme.scaffoldBackgroundColor,
                        ],
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.2),
                width: 1.5
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.error.withOpacity(0.1),
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
                  onTap: widget.onLogoutTap,
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.8),
                      Colors.red.withOpacity(0.6),
                    ],
                  ),
                  isDestructive: true,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Divider(height: 1.h, color: theme.colorScheme.error.withOpacity(0.1)),
                ),

                _buildActionTile(
                  context,
                  icon: Icons.delete_forever_rounded,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  onTap: widget.onDeleteAccountTap,
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.8),
                      Colors.red.withOpacity(0.6),
                    ],
                  ),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
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
            style: AppTextStyles.semiBold16.copyWith(
              color: theme.textTheme.bodyLarge?.color,
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

              // Static Switch
              Transform.scale(
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
