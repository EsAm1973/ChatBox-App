import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageDivider extends StatelessWidget {
  const MessageDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Divider(
        height: 1,
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}