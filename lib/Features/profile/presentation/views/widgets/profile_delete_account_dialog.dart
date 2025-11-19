import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';

class ProfileDeleteAccountDialog extends StatelessWidget {
  final VoidCallback onDelete;

  const ProfileDeleteAccountDialog({
    super.key,
    required this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ProfileDeleteAccountDialog(
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      title: Text(
        'Delete Account',
        style: AppTextStyles.semiBold20.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      content: Text(
        'Are you sure you want to delete your account? This action cannot be undone.',
        style: AppTextStyles.regular14.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTextStyles.regular14.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onDelete();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Delete',
            style: AppTextStyles.semiBold14.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}