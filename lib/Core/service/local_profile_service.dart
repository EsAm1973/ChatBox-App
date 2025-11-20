import 'dart:convert';
import 'package:chatbox/Core/service/shared_prefrences_sengelton.dart';
import 'package:chatbox/Features/profile/data/models/profile_settings_model.dart';

class LocalProfileService {
  // Keys for SharedPreferences
  static const String _settingsKey = 'user_settings';

  /// Get user settings from local storage
  ProfileSettingsModel getUserSettings() {
    try {
      final settingsJson = Prefs.getString(_settingsKey);
      if (settingsJson.isEmpty) {
        // Return default settings if not found
        return const ProfileSettingsModel();
      }
      
      final Map<String, dynamic> settingsMap = json.decode(settingsJson);
      return ProfileSettingsModel.fromMap(settingsMap);
    } catch (e) {
      // Return default settings on error
      return const ProfileSettingsModel();
    }
  }

  /// Save user settings to local storage
  Future<bool> saveUserSettings(ProfileSettingsModel settings) async {
    try {
      final settingsJson = json.encode(settings.toMap());
      return await Prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      return false;
    }
  }

  /// Update privacy settings
  Future<ProfileSettingsModel> updatePrivacySettings({
    bool? lastSeenVisible,
    bool? profilePictureVisible,
    bool? onlineStatusVisible,
  }) async {
    try {
      // Get current settings
      final currentSettings = getUserSettings();
      
      // Create updated settings
      final updatedSettings = currentSettings.copyWith(
        lastSeenVisible: lastSeenVisible,
        profilePictureVisible: profilePictureVisible,
        onlineStatusVisible: onlineStatusVisible,
        updatedAt: DateTime.now(),
      );
      
      // Save updated settings
      await saveUserSettings(updatedSettings);
      
      return updatedSettings;
    } catch (e) {
      throw Exception('Failed to update privacy settings: $e');
    }
  }

  /// Update notification settings
  Future<ProfileSettingsModel> updateNotificationSettings({
    required bool enabled,
  }) async {
    try {
      // Get current settings
      final currentSettings = getUserSettings();
      
      // Create updated settings
      final updatedSettings = currentSettings.copyWith(
        notificationsEnabled: enabled,
        updatedAt: DateTime.now(),
      );
      
      // Save updated settings
      await saveUserSettings(updatedSettings);
      
      return updatedSettings;
    } catch (e) {
      throw Exception('Failed to update notification settings: $e');
    }
  }

  /// Update theme preference
  Future<ProfileSettingsModel> updateThemePreference({
    required bool darkTheme,
  }) async {
    try {
      // Get current settings
      final currentSettings = getUserSettings();
      
      // Create updated settings
      final updatedSettings = currentSettings.copyWith(
        darkTheme: darkTheme,
        updatedAt: DateTime.now(),
      );
      
      // Save updated settings
      await saveUserSettings(updatedSettings);
      
      return updatedSettings;
    } catch (e) {
      throw Exception('Failed to update theme preference: $e');
    }
  }

  /// Update language preference
  Future<ProfileSettingsModel> updateLanguagePreference({
    required String language,
  }) async {
    try {
      // Get current settings
      final currentSettings = getUserSettings();
      
      // Create updated settings
      final updatedSettings = currentSettings.copyWith(
        language: language,
        updatedAt: DateTime.now(),
      );
      
      // Save updated settings
      await saveUserSettings(updatedSettings);
      
      return updatedSettings;
    } catch (e) {
      throw Exception('Failed to update language preference: $e');
    }
  }

  /// Clear all settings (useful for logout)
  Future<bool> clearSettings() async {
    try {
      return await Prefs.remove(_settingsKey);
    } catch (e) {
      return false;
    }
  }

  /// Initialize settings with default values if not exists
  Future<void> initializeSettings() async {
    try {
      final settingsJson = Prefs.getString(_settingsKey);
      if (settingsJson.isEmpty) {
        // Create default settings with current timestamp
        final defaultSettings = ProfileSettingsModel(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await saveUserSettings(defaultSettings);
      }
    } catch (e) {
      // Ignore initialization errors
    }
  }
}
