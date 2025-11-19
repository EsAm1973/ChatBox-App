import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/profile/data/models/profile_settings_model.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';

class ProfileInfoSection extends StatelessWidget {
  final UserModel user;
  final ProfileSettingsModel settings;
  final VoidCallback onEditName;
  final VoidCallback onEditEmail;
  final VoidCallback onEditPhone;
  final VoidCallback onEditAbout;

  const ProfileInfoSection({
    super.key,
    required this.user,
    required this.settings,
    required this.onEditName,
    required this.onEditEmail,
    required this.onEditPhone,
    required this.onEditAbout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Icon
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 16.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.blue.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Personal Information',
                style: AppTextStyles.semiBold20.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Info Container
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
              _buildInfoTile(
                context,
                icon: Icons.person_rounded,
                title: 'Full Name',
                subtitle: user.name,
                onTap: onEditName,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.blue.withOpacity(0.6),
                  ],
                ),
              ),

              _buildDivider(theme),

              _buildInfoTile(
                context,
                icon: Icons.email_rounded,
                title: 'Email Address',
                subtitle: user.email,
                onTap: onEditEmail,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.blue.withOpacity(0.6),
                  ],
                ),
              ),

              _buildDivider(theme),

              _buildInfoTile(
                context,
                icon: Icons.phone_android_rounded,
                title: 'Phone Number',
                subtitle: user.phoneNumber ?? 'Not provided',
                onTap: onEditPhone,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.blue.withOpacity(0.6),
                  ],
                ),
              ),

              _buildDivider(theme),

              _buildInfoTile(
                context,
                icon: Icons.article_rounded,
                title: 'About Me',
                subtitle:
                    user.about ?? 'Add a bio to tell others about yourself',
                onTap: onEditAbout,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.blue.withOpacity(0.6),
                  ],
                ),
                maxLines: 2,
              ),

              _buildDivider(theme),

              _buildInfoTile(
                context,
                icon: Icons.access_time_rounded,
                title: 'Last Seen',
                subtitle: _formatLastSeen(user.lastSeen),
                onTap: null,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.blue.withOpacity(0.6),
                  ],
                ),
                showArrow: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Divider(height: 1.h, color: theme.dividerColor.withOpacity(0.1)),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required Gradient gradient,
    bool showArrow = true,
    int maxLines = 1,
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
              // Gradient Icon Container
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
                child: Icon(icon, color: Colors.white, size: 24.sp),
              ),

              SizedBox(width: 16.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.regular12.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.6,
                        ),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.semiBold16.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                        height: 1.3,
                      ),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              if (showArrow) ...[
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: theme.primaryColor,
                    size: 14.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inDays > 7) {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Active now';
    }
  }
}
