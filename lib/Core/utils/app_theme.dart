import 'package:chatbox/Core/theme/dark_theme.dart';
import 'package:chatbox/Core/theme/light_theme.dart';
import 'package:flutter/material.dart';

/// App theme enum to represent light and dark themes
enum AppTheme { light, dark }

abstract class AppThemes {
  static ThemeData getLightTheme() => lightTheme;
  static ThemeData getDarkTheme() => darkTheme;
  
  /// Convert AppTheme enum to corresponding ThemeData
  static ThemeData getTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return getLightTheme();
      case AppTheme.dark:
        return getDarkTheme();
    }
  }
  
  /// Get AppTheme from ThemeData
  static AppTheme getAppTheme(ThemeData theme) {
    return theme == getDarkTheme() ? AppTheme.dark : AppTheme.light;
  }
}
