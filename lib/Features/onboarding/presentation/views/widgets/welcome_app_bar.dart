import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:svg_flutter/svg.dart';

class WelcomeAppBar extends StatelessWidget {
  const WelcomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/logo.svg', height: 18.h, width: 18.w),
        SizedBox(width: 6.w),
        Text('ChatBox', style: AppTextStyles.semiBold14),
      ],
    );
  }
}
