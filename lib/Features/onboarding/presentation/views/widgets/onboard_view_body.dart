import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Core/widgets/custom_bottom.dart';
import 'package:chatbox/Features/onboarding/presentation/views/widgets/login_row.dart';
import 'package:chatbox/Features/onboarding/presentation/views/widgets/onboard_socialmedia_login.dart';
import 'package:chatbox/Features/onboarding/presentation/views/widgets/or_divider.dart';
import 'package:chatbox/Features/onboarding/presentation/views/widgets/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OnboardViewBody extends StatelessWidget {
  const OnboardViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 17.h),
      child: SingleChildScrollView(
        child: Column(
          children: [
            WelcomeAppBar(),
            SizedBox(height: 30.h),
            Text(
              'Connect friends easily & quickly',
              style: AppTextStyles.bold68,
            ),
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
            SizedBox(height: 30.h),
            OrDivider(),
            SizedBox(height: 30.h),
            CustomBottom(
              text: 'Sign up with email',
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              onTap: () {
                GoRouter.of(context).pushReplacement(AppRouter.kSignupRoute);
              },
            ),
            SizedBox(height: 30.h),
            LoginRow(
              onTap: () {
                GoRouter.of(context).pushReplacement(AppRouter.kLoginRoute);
              },
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
