import 'package:bloc/bloc.dart';
import 'package:chatbox/Core/service/shared_prefrences_sengelton.dart';
import 'package:chatbox/Core/theme/dark_theme.dart';
import 'package:chatbox/Core/theme/light_theme.dart';
import 'package:chatbox/Core/utils/app_theme_enum.dart';
import 'package:chatbox/constants.dart';
import 'package:flutter/material.dart';

class ToggleThemeCubit extends Cubit<AppTheme> {
  ToggleThemeCubit() : super(AppTheme.dark);

  /// Set theme and persist to local storage
  void setTheme(AppTheme theme) {
    emit(theme);
    _persistTheme(theme);
  }

  /// Toggle between light and dark themes
  void toggleTheme() {
    final newTheme = state == AppTheme.light ? AppTheme.dark : AppTheme.light;
    emit(newTheme);
    _persistTheme(newTheme);
  }

  /// Persist theme to local storage
  void _persistTheme(AppTheme theme) async {
    await Prefs.setBool(isDarkModeKey, theme == AppTheme.dark);
  }

  /// Load theme from local storage
  Future<void> loadTheme() async {
    final isDark = Prefs.getBool(isDarkModeKey);
    final theme = isDark ? AppTheme.dark : AppTheme.light;
    emit(theme);
  }

  /// Check if current theme is dark
  bool get isDarkTheme => state == AppTheme.dark;

  /// Get current ThemeData
  ThemeData get currentTheme {
    switch (state) {
      case AppTheme.light:
        return lightTheme;
      case AppTheme.dark:
        return darkTheme;
    }
  }
}
