import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecoverPassTitle extends StatelessWidget {
  const RecoverPassTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Password Recovery', style: AppTextStyles.semiBold20),
        SizedBox(height: 12.h),
        Text(
          textAlign: TextAlign.center,
          'Enter your email to recover your \npassword',
          style: AppTextStyles.regular16,
        ),
      ],
    );
  }
}
