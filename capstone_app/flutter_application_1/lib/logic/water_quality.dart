import '../config/water_thresholds.dart';
import '../models/sensor_reading.dart';
import '../models/water_parameter.dart';
import '../utils/lang.dart';

/// General, species-independent evaluation of a reading.
class WaterQuality {
  WaterQuality._();

  /// Status of a single parameter. Salinity returns [ParameterStatus.unknown]
  /// because a "good" salinity depends on the species being raised.
  static ParameterStatus statusFor(WaterParameter parameter, double? value) {
    if (value == null) return ParameterStatus.unknown;
    switch (parameter) {
      case WaterParameter.temperature:
        return _classify(value, WaterThresholds.temperatureGood,
            WaterThresholds.temperatureCaution);
      case WaterParameter.ph:
        return _classify(
            value, WaterThresholds.phGood, WaterThresholds.phCaution);
      case WaterParameter.salinity:
        return ParameterStatus.unknown;
    }
  }

  static ParameterStatus _classify(
      double value, ParameterRange good, ParameterRange caution) {
    if (good.contains(value)) return ParameterStatus.good;
    if (caution.contains(value)) return ParameterStatus.caution;
    return ParameterStatus.critical;
  }

  /// Overall condition = worst of temperature and pH.
  static ParameterStatus overall(SensorReading? reading) {
    if (reading == null) return ParameterStatus.unknown;
    final statuses = [
      statusFor(WaterParameter.temperature, reading.temperatureC),
      statusFor(WaterParameter.ph, reading.ph),
    ].where((s) => s != ParameterStatus.unknown).toList();
    if (statuses.isEmpty) return ParameterStatus.unknown;
    if (statuses.contains(ParameterStatus.critical)) {
      return ParameterStatus.critical;
    }
    if (statuses.contains(ParameterStatus.caution)) {
      return ParameterStatus.caution;
    }
    return ParameterStatus.good;
  }

  static String overallTitle(ParameterStatus status) => switch (status) {
        ParameterStatus.good => tr('Good', 'Maayo'),
        ParameterStatus.caution => tr('Needs Attention', 'Bantayi'),
        ParameterStatus.critical => tr('Critical', 'Delikado'),
        ParameterStatus.unknown => tr('No Data', 'Walay Datos'),
      };

  static String overallMessage(ParameterStatus status) => switch (status) {
        ParameterStatus.good => tr(
            'The water is OK. Temperature and pH are in the normal range.',
            'Okay ang tubig. Normal ang kainit ug pH.'),
        ParameterStatus.caution => tr(
            'Something is a little off. See "What to do" below.',
            'Naay gamay nga problema. Tan-awa ang "Unsay buhaton" sa ubos.'),
        ParameterStatus.critical => tr(
            'The water needs action now. See "What to do" below.',
            'Kinahanglan aksyonan dayon ang tubig. Tan-awa ang "Unsay '
                'buhaton" sa ubos.'),
        ParameterStatus.unknown => tr(
            'No temperature or pH reading yet.',
            'Wala pay basa sa kainit o pH.'),
      };

  /// Simple, practical steps for the pond owner based on a reading.
  /// Empty when nothing needs to be done.
  static List<String> advice(SensorReading? reading) {
    if (reading == null) return const [];
    final tips = <String>[];
    final t = reading.temperatureC;
    final ph = reading.ph;

    if (t != null && t > WaterThresholds.temperatureGood.max) {
      tips.add(tr(
          'The water is hot. Add fresh water or make the water deeper, run '
              'the aerator, and feed less at midday.',
          'Init ang tubig. Dugangi og bag-ong tubig o palalma ang tubig, '
              'paandara ang aerator, ug kunhori ang pakaon sa udto.'));
    } else if (t != null && t < WaterThresholds.temperatureGood.min) {
      tips.add(tr(
          'The water is cold. Feed less - fish and shrimp eat less in cold '
              'water.',
          'Bugnaw ang tubig. Kunhori ang pakaon - gamay ra mokaon ang isda '
              'ug pasayan kung bugnaw.'));
    }

    if (ph != null && ph < WaterThresholds.phGood.min) {
      tips.add(tr(
          'The water is too sour (low pH). Change part of the water and ask '
              'a BFAR technician about adding agricultural lime.',
          'Aslom kaayo ang tubig (ubos ang pH). Ilisi ang pipila ka bahin sa '
              'tubig ug pangutana sa BFAR technician bahin sa pagbutang og '
              'apog (agricultural lime).'));
    } else if (ph != null && ph > WaterThresholds.phGood.max) {
      tips.add(tr(
          'The pH is too high. Change part of the water and stop adding '
              'fertilizer or lime for now.',
          'Taas kaayo ang pH. Ilisi ang pipila ka bahin sa tubig ug ayaw sa '
              'una butangi og abono o apog.'));
    }

    if (tips.isNotEmpty) {
      tips.add(tr('Check the water again after 1 to 2 hours.',
          'Susiha pag-usab ang tubig human sa 1 hangtod 2 ka oras.'));
    }

    if (!reading.isDemo &&
        (t == null || ph == null || reading.salinityForEvaluation == null)) {
      tips.add(tr(
          'One sensor is not giving a reading. Check that the probe is '
              'connected and under the water.',
          'Naay usa ka sensor nga walay basa. Susiha kung nakakabit ug '
              'nalubog sa tubig ang probe.'));
    }
    return tips;
  }
}
