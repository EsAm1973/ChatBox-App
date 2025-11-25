import 'package:chatbox/Core/service/shared_prefrences_sengelton.dart';
import 'package:chatbox/Core/utils/app_theme_enum.dart';
import 'package:chatbox/constants.dart';

class ThemeService {
  static Future<AppTheme> getInitialTheme() async {
    // Check if theme preference exists
    final hasTheme = Prefs.containsKey(isDarkModeKey);
    
    if (!hasTheme) {
      // First launch: default to dark theme
      return AppTheme.dark;
    }
    
    final isDark = Prefs.getBool(isDarkModeKey);
    return isDark ? AppTheme.dark : AppTheme.light;
  }
  
  static Future<void> setTheme(AppTheme theme) async {
    await Prefs.setBool(isDarkModeKey, theme == AppTheme.dark);
  }
}