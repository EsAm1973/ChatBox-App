import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/navigation%20bar/data/entites/navigation_bar_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavigationBarItem extends StatelessWidget {
  const NavigationBarItem({
    super.key,
    required this.isSelected,
    required this.entity,
  });
  final NavigationBarEntity entity;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isSelected ? entity.activeIcon : entity.inActiveIcon,

        SizedBox(height: 4.h),

        // النص
        Text(
          entity.title,
          style: AppTextStyles.semiBold14.copyWith(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.grey,
          ),
        ),
      ],
    );
  }
}
