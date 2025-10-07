import 'package:chatbox/Core/utils/app_colors.dart';
import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.darkBackground,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    secondary: AppColors.darkSecondary,
    onSecondary: AppColors.darkOnSecondary,
    error: AppColors.darkError,
    onError: AppColors.darkOnError,
    primaryContainer: AppColors.darkPrimaryVariant,
    secondaryContainer: AppColors.darkSecondaryVariant,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.darkOnBackground,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.darkOnBackground),
    titleTextStyle: TextStyle(
      color: AppColors.darkOnBackground,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.darkPrimary,
    foregroundColor: AppColors.darkOnPrimary,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkSecondary,
      foregroundColor: AppColors.darkOnSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.darkPrimaryVariant,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkBackground,
    hintStyle: TextStyle(color: AppColors.darkOnBackground.withValues(alpha: 0.8)),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  ),

  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    shadowColor: AppColors.darkBackground.withValues(alpha: 0.06),
  ),

  dividerColor: AppColors.darkSurface,
  disabledColor: AppColors.darkOnSurface.withValues(alpha: 0.5),
);
