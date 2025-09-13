import 'package:chatbox/Core/theme/dark_theme.dart';
import 'package:chatbox/Core/theme/light_theme.dart';
import 'package:flutter/material.dart';

abstract class AppThemes {
  static ThemeData get getLightTheme => lightTheme;
  static ThemeData get getDarkTheme => darkTheme;
}
