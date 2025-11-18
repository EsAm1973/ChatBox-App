import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallHistoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CallHistoryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 17.h, left: 20.w, right: 20.w),
      child: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('Calls', style: AppTextStyles.semiBold20),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80.h);
}
