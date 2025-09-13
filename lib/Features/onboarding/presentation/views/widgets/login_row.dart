import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class LoginRow extends StatelessWidget {
  const LoginRow({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Existing account? ',
          style: AppTextStyles.regular14.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text('Login', style: AppTextStyles.semiBold14.copyWith(
            color: Theme.of(context).colorScheme.primary,
          )),
        ),
      ],
    );
  }
}
