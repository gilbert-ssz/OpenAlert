import '../config/water_thresholds.dart';
import 'water_parameter.dart';

/// Where a reading came from. Demo readings must never be shown as live.
enum ReadingOrigin { sensor, demo }

/// One set of water-quality values captured at a point in time.
/// Any value may be null when that sensor is missing or reported an error.
class SensorReading {
  const SensorReading({
    required this.timestamp,
    required this.origin,
    this.temperatureC,
    this.ph,
    this.salinityPpt,
    this.conductivityUsCm,
  });

  final DateTime timestamp;
  final ReadingOrigin origin;
  final double? temperatureC;
  final double? ph;
  final double? salinityPpt;

  /// Electrical conductivity in µS/cm, if the sensor reports it.
  final double? conductivityUsCm;

  bool get isDemo => origin == ReadingOrigin.demo;

  /// Salinity used for evaluation: measured salinity, or an estimate derived
  /// from conductivity when only conductivity is available.
  double? get salinityForEvaluation =>
      salinityPpt ??
      (conductivityUsCm == null
          ? null
          : WaterThresholds.conductivityToSalinityPpt(conductivityUsCm!));

  bool get isSalinityEstimated =>
      salinityPpt == null && conductivityUsCm != null;

  bool get hasAnyValue =>
      temperatureC != null ||
      ph != null ||
      salinityPpt != null ||
      conductivityUsCm != null;

  double? valueOf(WaterParameter parameter) => switch (parameter) {
        WaterParameter.temperature => temperatureC,
        WaterParameter.ph => ph,
        WaterParameter.salinity => salinityForEvaluation,
      };

  Map<String, dynamic> toJson() => {
        't': timestamp.millisecondsSinceEpoch,
        'o': origin.name,
        if (temperatureC != null) 'temp': temperatureC,
        if (ph != null) 'ph': ph,
        if (salinityPpt != null) 'sal': salinityPpt,
        if (conductivityUsCm != null) 'ec': conductivityUsCm,
      };

  factory SensorReading.fromJson(Map<String, dynamic> json) => SensorReading(
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['t'] as int),
        origin: json['o'] == ReadingOrigin.sensor.name
            ? ReadingOrigin.sensor
            : ReadingOrigin.demo,
        temperatureC: (json['temp'] as num?)?.toDouble(),
        ph: (json['ph'] as num?)?.toDouble(),
        salinityPpt: (json['sal'] as num?)?.toDouble(),
        conductivityUsCm: (json['ec'] as num?)?.toDouble(),
      );

  /// Averages each value across [readings], ignoring missing values.
  /// The result is marked demo if any input reading was demo data.
  static SensorReading? average(List<SensorReading> readings) {
    if (readings.isEmpty) return null;
    double? avg(double? Function(SensorReading) pick) {
      final values = readings.map(pick).whereType<double>().toList();
      if (values.isEmpty) return null;
      return values.reduce((a, b) => a + b) / values.length;
    }

    final latest = readings
        .map((r) => r.timestamp)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return SensorReading(
      timestamp: latest,
      origin: readings.any((r) => r.isDemo)
          ? ReadingOrigin.demo
          : ReadingOrigin.sensor,
      temperatureC: avg((r) => r.temperatureC),
      ph: avg((r) => r.ph),
      salinityPpt: avg((r) => r.salinityPpt),
      conductivityUsCm: avg((r) => r.conductivityUsCm),
    );
  }
}
