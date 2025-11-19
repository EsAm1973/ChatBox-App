import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';

class ProfileLogoutDialog extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileLogoutDialog({
    super.key,
    required this.onLogout,
  });

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onLogout,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ProfileLogoutDialog(
        onLogout: onLogout,
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
        'Logout',
        style: AppTextStyles.semiBold20.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      content: Text(
        'Are you sure you want to logout?',
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
            onLogout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Logout',
            style: AppTextStyles.semiBold14.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}