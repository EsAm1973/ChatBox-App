import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';

class ProfileEditPictureBottomSheet extends StatelessWidget {
  final VoidCallback onTakePhoto;
  final VoidCallback onChooseFromGallery;
  final bool hasExistingPhoto;

  const ProfileEditPictureBottomSheet({
    super.key,
    required this.onTakePhoto,
    required this.onChooseFromGallery,
    required this.hasExistingPhoto,
  });

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onTakePhoto,
    required VoidCallback onChooseFromGallery,
    required bool hasExistingPhoto,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileEditPictureBottomSheet(
        onTakePhoto: onTakePhoto,
        onChooseFromGallery: onChooseFromGallery,
        hasExistingPhoto: hasExistingPhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.5),
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
              onTakePhoto();
            },
          ),
          _buildBottomSheetOption(
            context,
            icon: Icons.photo_library_rounded,
            title: 'Choose from Gallery',
            onTap: () {
              Navigator.pop(context);
              onChooseFromGallery();
            },
          ),
        ],
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
                  color: (isDestructive ? theme.colorScheme.error : theme.primaryColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? theme.colorScheme.error : theme.primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                title,
                style: AppTextStyles.semiBold14.copyWith(
                  color: isDestructive
                      ? theme.colorScheme.error
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
