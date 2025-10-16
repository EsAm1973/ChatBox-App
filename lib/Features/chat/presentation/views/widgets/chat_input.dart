import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 8.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.attachment,
              color: Theme.of(context).iconTheme.color,
              size: 28.r,
            ),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(30.0.r),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Write your message',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.0.h,
                    horizontal: 20.0.w,
                  ),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),

          IconButton(
            icon: Icon(
              Icons.mic_none_outlined,
              color: Theme.of(context).iconTheme.color,
              size: 28.r,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: Theme.of(context).iconTheme.color,
              size: 28.r,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
