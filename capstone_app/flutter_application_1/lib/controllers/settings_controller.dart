import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Loads, holds, and persists [AppSettings].
class SettingsController extends ChangeNotifier {
  static const _prefix = 'settings_v1_';

  AppSettings _value = const AppSettings();
  AppSettings get value => _value;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    const d = AppSettings();
    _value = AppSettings(
      dataMode: _byName(DataMode.values, prefs.getString('${_prefix}mode'),
          d.dataMode),
      esp32Address: prefs.getString('${_prefix}esp32') ?? d.esp32Address,
      autoRefreshSeconds:
          prefs.getInt('${_prefix}refresh') ?? d.autoRefreshSeconds,
      temperatureUnit: _byName(TemperatureUnit.values,
          prefs.getString('${_prefix}tempUnit'), d.temperatureUnit),
      salinityDisplay: _byName(SalinityDisplay.values,
          prefs.getString('${_prefix}salinity'), d.salinityDisplay),
      pondName: prefs.getString('${_prefix}pond') ?? d.pondName,
      language: _byName(AppLanguage.values,
          prefs.getString('${_prefix}language'), d.language),
      textSize: _byName(
          TextSize.values, prefs.getString('${_prefix}textSize'), d.textSize),
    );
    notifyListeners();
  }

  Future<void> update(AppSettings next) async {
    _value = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefix}mode', next.dataMode.name);
    await prefs.setString('${_prefix}esp32', next.esp32Address);
    await prefs.setInt('${_prefix}refresh', next.autoRefreshSeconds);
    await prefs.setString('${_prefix}tempUnit', next.temperatureUnit.name);
    await prefs.setString('${_prefix}salinity', next.salinityDisplay.name);
    await prefs.setString('${_prefix}pond', next.pondName);
    await prefs.setString('${_prefix}language', next.language.name);
    await prefs.setString('${_prefix}textSize', next.textSize.name);
  }

  static T _byName<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }
}
