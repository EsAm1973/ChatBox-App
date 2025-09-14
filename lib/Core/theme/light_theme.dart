import 'package:chatbox/Core/utils/app_colors.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    error: AppColors.error,
    onError: AppColors.onError,
    primaryContainer: AppColors.primaryVariant,
    secondaryContainer: AppColors.secondaryVariant,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.onBackground,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.onBackground),
    titleTextStyle: TextStyle(
      color: AppColors.onBackground,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.onSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryVariant,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.background,
    hintStyle: TextStyle(color: AppColors.onBackground.withOpacity(0.7)),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  ),

  cardTheme: CardTheme(
    color: AppColors.surface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    shadowColor: AppColors.primary.withValues(alpha: 0.06),
  ),

  dividerColor: AppColors.surface,
  disabledColor: AppColors.onSurface.withValues(alpha: 0.5),
);
