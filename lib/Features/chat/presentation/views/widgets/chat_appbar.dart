import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:svg_flutter/svg_flutter.dart';

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          BackButton(color: Theme.of(context).iconTheme.color),
          SizedBox(width: 12.w),
          Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 24.r,
              backgroundImage: const AssetImage('assets/user_pic_test.png'),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jhon Abraham', style: AppTextStyles.semiBold16),
                SizedBox(height: 6.h),
                Text(
                  'Active now',
                  style: AppTextStyles.regular12.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            icon: SvgPicture.asset(
              _getCallIconPath(context),
              height: 28.h,
              width: 28.w,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            icon: SvgPicture.asset(
              _getVideoIconPath(context),
              height: 28.h,
              width: 28.w,
            ),
          ),
        ],
      ),
    );
  }

  String _getCallIconPath(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? 'assets/call_light.svg'
        : 'assets/call_dark.svg';
  }

  String _getVideoIconPath(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? 'assets/video_light.svg'
        : 'assets/video_dark.svg';
  }
}
