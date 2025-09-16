import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChoosePictureHeader extends StatelessWidget {
  const ChoosePictureHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Add a Profile Picture', style: AppTextStyles.bold18),
        SizedBox(height: 10.h),
        Text(
          'Choose a picture that represents you best',
          textAlign: TextAlign.center,
          style: AppTextStyles.regular14,
        ),
      ],
    );
  }
}