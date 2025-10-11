import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:svg_flutter/svg.dart';

PreferredSizeWidget buildHomeAppBar(BuildContext context) {
  return PreferredSize(
    preferredSize: Size.fromHeight(100.h),
    child: Padding(
      padding: EdgeInsets.only(top: 17.h, left: 20.w, right: 20.w),
      child: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('Home', style: AppTextStyles.semiBold20),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF363F3B), width: 1.0.w),
          ),
          child: IconButton(
            iconSize: 22.r,
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(_getSearchIconPath(context)),
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

String _getSearchIconPath(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? 'assets/search_icon.svg'
      : 'assets/search_icon_dark.svg';
}
