import 'package:flutter/widgets.dart';

class NavigationBarEntity {
  final Widget activeIcon;
  final Widget inActiveIcon;
  final String title;

  NavigationBarEntity({
    required this.activeIcon,
    required this.inActiveIcon,
    required this.title,
  });
}
