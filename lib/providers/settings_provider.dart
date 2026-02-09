import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant_settings.dart';

class SettingsNotifier extends StateNotifier<RestaurantSettings> {
  SettingsNotifier() : super(RestaurantSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('app_settings');
    if (data != null) {
      state = RestaurantSettings.fromJson(jsonDecode(data));
    }
  }

  Future<void> updateSettings(RestaurantSettings newSettings) async {
    state = newSettings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', jsonEncode(state.toJson()));
  }

  Future<void> updateLogo(String path) async {
    final newSettings = state.copyWith(logoPath: path);
    await updateSettings(newSettings);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, RestaurantSettings>((ref) {
  return SettingsNotifier();
});
