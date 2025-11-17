import 'package:chatbox/Features/navigation%20bar/data/entites/navigation_bar_entity.dart';
import 'package:chatbox/Features/navigation%20bar/presentation/views/widgets/navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButtonNavigationBar extends StatelessWidget {
  const CustomButtonNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    List<NavigationBarEntity> bottomNavBarItems = [
      NavigationBarEntity(
        activeIcon: Icon(
          Icons.message,
          size: 30.r,
          color: Theme.of(context).iconTheme.color,
        ),
        inActiveIcon: Icon(Icons.message, color: Colors.grey, size: 30.r),
        title: 'Message',
      ),
      NavigationBarEntity(
        activeIcon: Icon(
          Icons.call,
          size: 30.r,
          color: Theme.of(context).iconTheme.color,
        ),
        inActiveIcon: Icon(Icons.call, size: 30.r, color: Colors.grey),
        title: 'Calls',
      ),
      NavigationBarEntity(
        activeIcon: Icon(
          Icons.settings,
          size: 30.r,
          color: Theme.of(context).iconTheme.color,
        ),
        inActiveIcon: Icon(Icons.settings, color: Colors.grey, size: 30.r),
        title: 'Settings',
      ),
    ];
    return Container(
      width: double.infinity,
      height: 80.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children:
            bottomNavBarItems.asMap().entries.map((e) {
              final index = e.key;
              final value = e.value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  child: NavigationBarItem(
                    isSelected: selectedIndex == index,
                    entity: value,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
