import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final VoidCallback onBackPressed;
  final ValueChanged<String> onSearchChanged;

  const SearchAppBar({
    super.key,
    required this.controller,
    required this.onBackPressed,
    required this.onSearchChanged,
  });

  @override
  Size get preferredSize => Size.fromHeight(100.h);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 17.h, left: 20.w, right: 20.w),
      child: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.r),
          onPressed: onBackPressed,
        ),
        title: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by email...',
            hintStyle: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 16.sp,
            ),
            border: InputBorder.none,
          ),
          style: TextStyle(fontSize: 16.sp),
          onChanged: onSearchChanged,
        ),
        actions: [
          if (controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, size: 22.r),
              onPressed: () {
                controller.clear();
                onSearchChanged('');
              },
            ),
        ],
      ),
    );
  }
}
