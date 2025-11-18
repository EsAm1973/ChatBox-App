import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatbox/Core/cubit/user%20cubit/user_cubit.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/profile/data/models/profile_settings_model.dart';
import 'package:chatbox/Features/profile/presentation/manager/profile_cubit/profile_cubit.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_header.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_info_section.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_actions_section.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Load profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    final currentUser = context.read<UserCubit>().getCurrentUser();
    if (currentUser != null) {
      context.read<ProfileCubit>().loadProfileData(currentUser.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: AppTextStyles.semiBold16.copyWith(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 18.sp,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.sp,
              color: theme.textTheme.bodyLarge?.color,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.qr_code_rounded,
                color: theme.textTheme.bodyLarge?.color,
              ),
              onPressed: () {
                // TODO: Show QR Code
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadProfileData();
            });
            return _buildLoadingState(context);
          }

          if (state is ProfileLoading) {
            return _buildLoadingState(context);
          }

          if (state is ProfileError) {
            return _buildErrorState(context, state.message);
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
            return _buildLoadingState(context);
          }

          return _buildErrorState(context, 'Profile not loaded');
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    const Color(0xFF0f3460),
                  ]
                  : [
                    const Color(0xFFf8f9fa),
                    const Color(0xFFe9ecef),
                    const Color(0xFFdee2e6),
                  ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 32.h),
            ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.7),
                    ],
                  ).createShader(bounds),
              child: Text(
                'Loading your profile...',
                style: AppTextStyles.semiBold16.copyWith(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                  : [const Color(0xFFf8f9fa), const Color(0xFFe9ecef)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.1),
                      Colors.red.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64.sp,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Oops! Something went wrong',
                style: AppTextStyles.semiBold16.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 20.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                style: AppTextStyles.regular14.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _loadProfileData,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Try Again',
                          style: AppTextStyles.semiBold14.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    const Color(0xFF0f3460),
                  ]
                  : [
                    const Color(0xFFffffff),
                    const Color(0xFFf8f9fa),
                    const Color(0xFFe9ecef),
                  ],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.top + 70.h,
                ),
              ),

              // Profile Header
              SliverToBoxAdapter(
                child: ProfileHeader(
                  user: user,
                  onEditPicture: () => _showEditPictureOptions(context),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 24.h)),

              // Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildStatsRow(context, user),
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
                          (value) => context
                              .read<ProfileCubit>()
                              .updateUserName(value),
                        ),
                    onEditEmail:
                        () => _showEditDialog(
                          context,
                          'Edit Email',
                          user.email,
                          (value) => context
                              .read<ProfileCubit>()
                              .updateUserEmail(value),
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
                          (value) => context
                              .read<ProfileCubit>()
                              .updateUserAbout(value),
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
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.chat_bubble_rounded,
            label: 'Messages',
            value: '248',
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.favorite_rounded,
            label: 'Favorites',
            value: '42',
            gradient: LinearGradient(
              colors: [Colors.pink.shade400, Colors.pink.shade300],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.star_rounded,
            label: 'Points',
            value: '1.2k',
            gradient: LinearGradient(
              colors: [Colors.amber.shade400, Colors.amber.shade300],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.bold18.copyWith(
              color: Colors.white,
              fontSize: 20.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTextStyles.regular12.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  // Keep existing dialog methods...
  void _showEditPictureOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildBottomSheetOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  title: 'Take Photo',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement camera
                  },
                ),
                _buildBottomSheetOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement gallery
                  },
                ),
                if (context.read<ProfileCubit>().currentUser?.profilePic !=
                    null)
                  _buildBottomSheetOption(
                    context,
                    icon: Icons.delete_rounded,
                    title: 'Remove Photo',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Remove photo
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildBottomSheetOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: (isDestructive ? Colors.red : theme.primaryColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? Colors.red : theme.primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                title,
                style: AppTextStyles.semiBold14.copyWith(
                  color:
                      isDestructive
                          ? Colors.red
                          : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String initialValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Text(title),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field cannot be empty';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    onSave(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<ProfileCubit>().logout();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<ProfileCubit>().deleteAccount();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
