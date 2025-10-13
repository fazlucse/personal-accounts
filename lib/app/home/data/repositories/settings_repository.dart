import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  Future<Settings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('settings');
    if (jsonString != null) {
      final json = jsonDecode(jsonString);
      return Settings.fromJson(json);
    }
    return Settings(language: 'en', theme: 'light');
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = await getSettings();
    final updatedSettings = Settings(language: language, theme: settings.theme);
    await prefs.setString('settings', jsonEncode(updatedSettings.toJson()));
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = await getSettings();
    final updatedSettings = Settings(language: settings.language, theme: theme);
    await prefs.setString('settings', jsonEncode(updatedSettings.toJson()));
  }
}