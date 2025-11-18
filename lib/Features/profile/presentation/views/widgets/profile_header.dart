import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';

class ProfileHeader extends StatefulWidget {
  final UserModel user;
  final VoidCallback onEditPicture;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEditPicture,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Profile Picture with Animated Border
          Stack(
            alignment: Alignment.center,
            children: [
              // Animated Outer Ring
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 140.w,
                      height: 140.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Profile Picture Container
              Hero(
                tag: 'profile_pic_${widget.user.uid}',
                child: Container(
                  width: 130.w,
                  height: 130.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(4.w),
                  child: CircleAvatar(
                    radius: 60.r,
                    backgroundColor: theme.cardColor,
                    backgroundImage:
                        widget.user.profilePic.isNotEmpty
                            ? NetworkImage(widget.user.profilePic)
                            : null,
                    child:
                        widget.user.profilePic.isEmpty
                            ? ShaderMask(
                              shaderCallback:
                                  (bounds) => LinearGradient(
                                    colors: [
                                      theme.primaryColor,
                                      theme.primaryColor.withOpacity(0.7),
                                    ],
                                  ).createShader(bounds),
                              child: Text(
                                widget.user.name.isNotEmpty
                                    ? widget.user.name[0].toUpperCase()
                                    : 'U',
                                style: AppTextStyles.bold18.copyWith(
                                  color: Colors.white,
                                  fontSize: 48.sp,
                                ),
                              ),
                            )
                            : null,
                  ),
                ),
              ),

              // Edit Button with Gradient
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: widget.onEditPicture,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // User Name with Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.user.name,
                  style: AppTextStyles.bold18.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 26.sp,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified, color: Colors.white, size: 20.sp),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Email Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isDark
                        ? [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ]
                        : [
                          theme.primaryColor.withOpacity(0.1),
                          theme.primaryColor.withOpacity(0.05),
                        ],
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_rounded,
                  color: theme.primaryColor,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    widget.user.email,
                    style: AppTextStyles.regular14.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // About Section with Glass Effect
          if (widget.user.about != null && widget.user.about!.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isDark
                          ? [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.02),
                          ]
                          : [
                            Colors.black.withOpacity(0.03),
                            Colors.black.withOpacity(0.01),
                          ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: theme.primaryColor.withOpacity(0.5),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'About Me',
                        style: AppTextStyles.semiBold14.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.7,
                          ),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    widget.user.about!,
                    style: AppTextStyles.regular16.copyWith(
                      color: theme.textTheme.bodyLarge?.color,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
