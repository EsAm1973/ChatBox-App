import 'package:chatbox/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppTextStyles {
  static TextStyle bold68 = TextStyle(
    fontSize: 68.sp,
    fontFamily: carosFontFamily,
    fontWeight: FontWeight.w600,
    height: 1.15.h,
  );

  static TextStyle semiBold40 = TextStyle(
    fontSize: 40.sp,
    fontStyle: FontStyle.italic,
    fontFamily: circularStdFontFamily,
    fontWeight: FontWeight.w500,
    height: 1.h,
  );

  static TextStyle semiBold20 = TextStyle(
    fontSize: 20.sp,
    fontFamily: carosFontFamily,
    fontWeight: FontWeight.w500,
    height: 1.h,
  );

  static TextStyle bold18 = TextStyle(
    fontSize: 18.sp,
    fontFamily: carosFontFamily,
    fontWeight: FontWeight.w600,
    height: 1.h,
  );

  static TextStyle regular18 = TextStyle(
    fontSize: 18.sp,
    fontFamily: circularStdFontFamily,
    fontWeight: FontWeight.w400,
    height: 1.h,
  );

  static TextStyle regular16 = TextStyle(
    fontSize: 16.sp,
    fontFamily: circularStdFontFamily,
    fontWeight: FontWeight.w400,
    height: 1.62.h,
  );

  static TextStyle semiBold16 = TextStyle(
    fontSize: 16.sp,
    fontFamily: carosFontFamily,
    fontWeight: FontWeight.w500,
    height: 1.h,
  );

  static TextStyle regular14 = TextStyle(
    fontSize: 14.sp,
    fontFamily: circularStdFontFamily,
    fontWeight: FontWeight.w400,
    height: 1.h,
    letterSpacing: 0.10,
  );

  static TextStyle semiBold14 = TextStyle(
    fontSize: 14.sp,
    fontFamily: circularStdFontFamily,
    fontWeight: FontWeight.w500,
    height: 1.h,
    letterSpacing: 0.10,
  );

  static TextStyle bold14 = TextStyle(
    fontSize: 14.sp,
    fontFamily: carosFontFamily,
    fontWeight: FontWeight.w600,
    height: 1.h,
  );

  static TextStyle regular12 = TextStyle(
    fontSize: 12.sp,
    fontFamily: circularStdFontFamily,
    fontWeight: FontWeight.w400,
    height: 1.h,
  );
}
