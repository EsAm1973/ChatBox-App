import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:svg_flutter/svg.dart';

PreferredSizeWidget buildHomeAppBar() {
  return PreferredSize(
    preferredSize: Size.fromHeight(100.h),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 17.h),
      child: AppBar(
        backgroundColor: const Color(0xFF000D07),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Home',
          style: AppTextStyles.semiBold20.copyWith(color: Colors.white),
        ),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF363F3B), width: 1.0.w),
          ),
          child: IconButton(
            iconSize: 22.r,
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
              'assets/search_icon.svg',
              width: 26.r,
              height: 26.r,
            ),
            onPressed: () {},
          ),
        ),
        actions: [
          Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 26.r,
              backgroundImage: const AssetImage('assets/user_pic_test.png'),
            ),
          ),
        ],
      ),
    ),
  );
}
