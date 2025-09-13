import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/onboarding/presentation/views/widgets/onboard_socialmedia_login.dart';
import 'package:chatbox/Features/onboarding/presentation/views/widgets/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardViewBody extends StatelessWidget {
  const OnboardViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 17.h),
      child: Column(
        children: [
          WelcomeAppBar(),
          SizedBox(height: 43.h),
          Text('Connect friends easily & quickly', style: AppTextStyles.bold68),
          SizedBox(height: 16.h),
          Text(
            'Our chat app is the perfect way to stay connected with friends and family.',
            style: AppTextStyles.regular16.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 38.h),
          OnboardSocialMediaLogin(),
        ],
      ),
    );
  }
}
