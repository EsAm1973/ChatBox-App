import 'package:chatbox/Features/onboarding/presentation/views/widgets/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardViewBody extends StatelessWidget {
  const OnboardViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 17.h),
      child: Column(children: [WelcomeAppBar()]),
    );
  }
}
