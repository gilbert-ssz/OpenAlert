import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/sensor_reading.dart';

/// Persists reading history on the device so it stays available offline.
class HistoryStore {
  static const _key = 'reading_history_v1';
  static const _seededKey = 'demo_history_seeded_v1';

  /// Oldest readings are dropped beyond this many entries
  /// (about 10 days at one reading every 5 minutes).
  static const maxEntries = 3000;

  Future<List<SensorReading>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SensorReading.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } on FormatException {
      return [];
    }
  }

  Future<void> save(List<SensorReading> readings) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = readings.length > maxEntries
        ? readings.sublist(readings.length - maxEntries)
        : readings;
    await prefs.setString(
        _key, jsonEncode(trimmed.map((r) => r.toJson()).toList()));
  }

  Future<bool> isDemoSeeded() async =>
      (await SharedPreferences.getInstance()).getBool(_seededKey) ?? false;

  Future<void> setDemoSeeded(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_seededKey, value);
}
