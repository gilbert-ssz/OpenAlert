import 'package:intl/intl.dart';

import '../models/app_settings.dart';
import '../models/sensor_reading.dart';
import '../models/water_parameter.dart';
import 'lang.dart';

/// A value split into number and unit for large displays.
class DisplayValue {
  const DisplayValue(this.value, this.unit, {this.estimated = false});

  final String value;
  final String unit;

  /// True when salinity was estimated from conductivity.
  final bool estimated;

  bool get isMissing => value == '--';

  @override
  String toString() =>
      isMissing ? '--' : '${estimated ? '≈' : ''}$value $unit'.trim();
}

class Fmt {
  Fmt._();

  static double toDisplayTemp(double celsius, TemperatureUnit unit) =>
      unit == TemperatureUnit.celsius ? celsius : celsius * 9 / 5 + 32;

  static String tempUnit(TemperatureUnit unit) =>
      unit == TemperatureUnit.celsius ? '°C' : '°F';

  /// Display value of a parameter in a reading, honoring unit settings.
  static DisplayValue value(
      WaterParameter p, SensorReading? r, AppSettings s) {
    switch (p) {
      case WaterParameter.temperature:
        final c = r?.temperatureC;
        return DisplayValue(
          c == null ? '--' : toDisplayTemp(c, s.temperatureUnit).toStringAsFixed(1),
          tempUnit(s.temperatureUnit),
        );
      case WaterParameter.ph:
        return DisplayValue(r?.ph?.toStringAsFixed(2) ?? '--', '');
      case WaterParameter.salinity:
        if (r == null) return const DisplayValue('--', 'ppt');
        if (s.salinityDisplay == SalinityDisplay.conductivity &&
            r.conductivityUsCm != null) {
          return conductivity(r.conductivityUsCm!);
        }
        final ppt = r.salinityForEvaluation;
        return DisplayValue(
          ppt?.toStringAsFixed(1) ?? '--',
          'ppt',
          estimated: r.isSalinityEstimated,
        );
    }
  }

  static DisplayValue conductivity(double microSiemens) => microSiemens >= 10000
      ? DisplayValue((microSiemens / 1000).toStringAsFixed(1), 'mS/cm')
      : DisplayValue(microSiemens.toStringAsFixed(0), 'µS/cm');

  /// A bare value (no reading) in display units, e.g. for explanations.
  static String number(WaterParameter p, double v, AppSettings s) =>
      switch (p) {
        WaterParameter.temperature =>
          '${toDisplayTemp(v, s.temperatureUnit).toStringAsFixed(1)} ${tempUnit(s.temperatureUnit)}',
        WaterParameter.ph => v.toStringAsFixed(2),
        WaterParameter.salinity => '${v.toStringAsFixed(1)} ppt',
      };

  static String range(WaterParameter p, ParameterRange r, AppSettings s) {
    String n(double v) {
      final d = p == WaterParameter.temperature
          ? toDisplayTemp(v, s.temperatureUnit)
          : v;
      return d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(1);
    }

    final unit = switch (p) {
      WaterParameter.temperature => ' ${tempUnit(s.temperatureUnit)}',
      WaterParameter.ph => '',
      WaterParameter.salinity => ' ppt',
    };
    return '${n(r.min)}–${n(r.max)}$unit';
  }

  static String dateTime(DateTime t) =>
      DateFormat('MMM d, yyyy • h:mm a').format(t);

  static String date(DateTime t) => DateFormat('EEE, MMM d, yyyy').format(t);

  static String time(DateTime t) => DateFormat('h:mm a').format(t);

  static String relative(DateTime t, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(t);
    if (diff.inSeconds < 45) return tr('just now', 'karon lang');
    if (diff.inMinutes < 60) {
      return tr('${diff.inMinutes} min ago',
          '${diff.inMinutes} ka minuto na');
    }
    if (diff.inHours < 24) {
      return tr('${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago',
          '${diff.inHours} ka oras na');
    }
    return tr('${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago',
        '${diff.inDays} ka adlaw na');
  }

  static String greeting([DateTime? now]) {
    final h = (now ?? DateTime.now()).hour;
    if (h < 12) return tr('Good morning', 'Maayong buntag');
    if (h < 18) return tr('Good afternoon', 'Maayong hapon');
    return tr('Good evening', 'Maayong gabii');
  }
}
