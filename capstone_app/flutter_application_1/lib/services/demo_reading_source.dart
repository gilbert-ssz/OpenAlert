import 'dart:math';

import '../config/water_thresholds.dart';
import '../models/sensor_reading.dart';
import 'reading_source.dart';

/// Generates clearly labelled SAMPLE readings for demonstrations when no
/// sensor hardware is connected. Every reading has [ReadingOrigin.demo].
class DemoReadingSource implements ReadingSource {
  DemoReadingSource({Random? random}) : _rng = random ?? Random();

  final Random _rng;
  double _salinityDrift = 0;

  @override
  Future<SensorReading> fetchLatest() async {
    // Simulate network latency so loading states are visible.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _salinityDrift =
        (_salinityDrift + (_rng.nextDouble() - 0.5) * 0.3).clamp(-1.0, 1.0);
    return _sample(DateTime.now(), _rng, _salinityDrift);
  }

  /// Hourly sample history ending at [end], for charts in Demo Mode.
  static List<SensorReading> sampleHistory({
    required DateTime end,
    int hours = 72,
    Random? random,
  }) {
    final rng = random ?? Random(42);
    var drift = 0.0;
    return List.generate(hours, (i) {
      drift = (drift + (rng.nextDouble() - 0.5) * 0.4).clamp(-1.0, 1.0);
      return _sample(end.subtract(Duration(hours: hours - i)), rng, drift);
    });
  }

  /// Plausible tropical brackish-pond pattern: temperature and pH peak in
  /// the afternoon (sunlight, algae photosynthesis) and dip before dawn.
  static SensorReading _sample(DateTime t, Random rng, double salinityDrift) {
    final hour = t.hour + t.minute / 60;
    final daily = sin(2 * pi * (hour - 9) / 24); // peaks around 15:00
    double noise(double scale) => (rng.nextDouble() - 0.5) * scale;

    final temperature = 28.5 + 1.8 * daily + noise(0.4);
    final ph = 7.6 + 0.45 * daily + noise(0.1);
    final salinity = 6.0 + salinityDrift + noise(0.3);
    return SensorReading(
      timestamp: t,
      origin: ReadingOrigin.demo,
      temperatureC: _round(temperature, 1),
      ph: _round(ph, 2),
      salinityPpt: _round(salinity, 1),
      conductivityUsCm: _round(
          WaterThresholds.salinityPptToConductivity(salinity), 0),
    );
  }

  static double _round(double v, int places) {
    final f = pow(10, places);
    return (v * f).round() / f;
  }
}
