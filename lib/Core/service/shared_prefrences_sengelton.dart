import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _instance;
  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _instance.setBool(key, value);
  }

  static bool getBool(String key) {
    return _instance.getBool(key) ?? false;
  }

  static Future<bool> setString(String key, String value) async {
    return await _instance.setString(key, value);
  }

  static String getString(String key) {
    return _instance.getString(key) ?? '';
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    return await _instance.setStringList(key, value);
  }

  static List<String> getStringList(String key) {
    return _instance.getStringList(key) ?? [];
  }

  static Future<bool> remove(String key) async {
    return await _instance.remove(key);
  }

  static bool containsKey(String key) {
    return _instance.containsKey(key);
  }
}
