import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/water_thresholds.dart';
import '../models/app_settings.dart';
import '../models/sensor_reading.dart';
import '../services/demo_reading_source.dart';
import '../services/esp32_http_source.dart';
import '../services/history_store.dart';
import '../services/reading_source.dart';

enum ConnectionStatus { demo, connecting, connected, disconnected }

/// Owns the active [ReadingSource], the latest reading, connection status,
/// and the locally stored history.
class MonitoringController extends ChangeNotifier {
  MonitoringController({HistoryStore? historyStore, http.Client? httpClient})
      : _store = historyStore ?? HistoryStore(),
        _http = httpClient ?? http.Client();

  final HistoryStore _store;
  final http.Client _http;

  AppSettings? _settings;
  ReadingSource? _source;
  ReadingSource? _inFlight;
  Timer? _timer;
  bool _disposed = false;

  List<SensorReading> _history = [];
  SensorReading? _latest;
  ConnectionStatus _status = ConnectionStatus.demo;
  String? _error;
  DateTime? _lastAttempt;

  List<SensorReading> get history => List.unmodifiable(_history);
  SensorReading? get latest => _latest;
  ConnectionStatus get status => _status;
  String? get error => _error;
  DateTime? get lastAttempt => _lastAttempt;
  bool get isLoading => _inFlight != null && _inFlight == _source;
  bool get isDemoMode => _settings?.dataMode != DataMode.esp32;

  /// Most recent reading actually received from the hardware, if any.
  SensorReading? get lastSensorReading {
    for (var i = _history.length - 1; i >= 0; i--) {
      if (!_history[i].isDemo) return _history[i];
    }
    return null;
  }

  int get demoReadingCount => _history.where((r) => r.isDemo).length;

  Future<void> init(AppSettings settings) async {
    _history = await _store.load();
    applySettings(settings, force: true);
  }

  /// Rebuilds the reading source when the data mode or address changes.
  void applySettings(AppSettings settings, {bool force = false}) {
    final prev = _settings;
    _settings = settings;
    final sourceChanged = force ||
        prev == null ||
        prev.dataMode != settings.dataMode ||
        prev.esp32Address != settings.esp32Address;
    final timerChanged = sourceChanged ||
        prev.autoRefreshSeconds != settings.autoRefreshSeconds;

    if (sourceChanged) {
      final demo = settings.dataMode == DataMode.demo;
      _source = demo
          ? DemoReadingSource()
          : Esp32HttpSource(address: settings.esp32Address, client: _http);
      _latest = null;
      _error = null;
      _status = demo ? ConnectionStatus.demo : ConnectionStatus.connecting;
      notifyListeners();
      if (demo) unawaited(_seedDemoHistoryIfNeeded());
      unawaited(refresh(userInitiated: true));
    }
    if (timerChanged) _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    final seconds = _settings?.autoRefreshSeconds ?? 0;
    if (seconds > 0) {
      _timer = Timer.periodic(Duration(seconds: seconds), (_) => refresh());
    }
  }

  /// Fetches a new reading. Manual refreshes are always saved to history;
  /// automatic ones at most every [WaterThresholds.historyIntervalMinutes].
  Future<void> refresh({bool userInitiated = false}) async {
    final source = _source;
    if (source == null || _inFlight == source) return;
    _inFlight = source;
    _lastAttempt = DateTime.now();
    if (_status == ConnectionStatus.disconnected) {
      _status = ConnectionStatus.connecting;
    }
    notifyListeners();
    try {
      final reading = await source.fetchLatest();
      if (_disposed || source != _source) return;
      _latest = reading;
      _error = null;
      _status = reading.isDemo
          ? ConnectionStatus.demo
          : ConnectionStatus.connected;
      await _record(reading, force: userInitiated);
    } on ReadingSourceException catch (e) {
      if (_disposed || source != _source) return;
      _onFailure(e.message);
    } catch (e) {
      if (_disposed || source != _source) return;
      _onFailure('Unexpected error: $e');
    } finally {
      if (_inFlight == source) _inFlight = null;
      if (!_disposed) notifyListeners();
    }
  }

  void _onFailure(String message) {
    _error = message;
    if (_settings?.dataMode == DataMode.esp32) {
      // Never keep showing an old value as if it were live.
      _latest = null;
      _status = ConnectionStatus.disconnected;
    }
  }

  Future<void> _record(SensorReading reading, {required bool force}) async {
    final lastSame = _history.lastWhereOrNull((r) => r.origin == reading.origin);
    final due = lastSame == null ||
        reading.timestamp.difference(lastSame.timestamp).inMinutes >=
            WaterThresholds.historyIntervalMinutes;
    if (!force && !due) return;
    _history = [..._history, reading];
    await _store.save(_history);
  }

  Future<void> _seedDemoHistoryIfNeeded() async {
    if (await _store.isDemoSeeded()) return;
    await loadSampleHistory();
  }

  /// Replaces demo readings with a 3-day sample history (Demo Mode only).
  Future<void> loadSampleHistory() async {
    final samples = DemoReadingSource.sampleHistory(end: DateTime.now());
    _history = [..._history.where((r) => !r.isDemo), ...samples]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    await _store.save(_history);
    await _store.setDemoSeeded(true);
    if (!_disposed) notifyListeners();
  }

  /// Removes all demo/sample readings. Sensor readings are kept.
  Future<void> clearDemoData() async {
    _history = _history.where((r) => !r.isDemo).toList();
    if (_latest?.isDemo ?? false) _latest = null;
    await _store.save(_history);
    await _store.setDemoSeeded(true); // don't silently re-seed
    if (!_disposed) notifyListeners();
  }

  Future<void> clearAllHistory() async {
    _history = [];
    await _store.save(_history);
    await _store.setDemoSeeded(true);
    if (!_disposed) notifyListeners();
  }

  /// Tries the given address once without changing settings.
  Future<String> testConnection(String address) async {
    final source = Esp32HttpSource(address: address, client: _http);
    try {
      final r = await source.fetchLatest();
      final parts = <String>[
        if (r.temperatureC != null) 'temperature',
        if (r.ph != null) 'pH',
        if (r.salinityPpt != null || r.conductivityUsCm != null) 'salinity',
      ];
      return 'Connected to ${source.endpoint.authority}. '
          'Sensors reporting: ${parts.join(', ')}.';
    } on ReadingSourceException catch (e) {
      return 'Connection failed: ${e.message}';
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _http.close();
    super.dispose();
  }
}

extension _LastWhereOrNull<T> on List<T> {
  T? lastWhereOrNull(bool Function(T) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) return this[i];
    }
    return null;
  }
}
