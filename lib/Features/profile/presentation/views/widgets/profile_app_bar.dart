import 'package:flutter/material.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15.h),
      child: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('Profile', style: AppTextStyles.semiBold20),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
