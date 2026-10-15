import '../models/water_parameter.dart';
import '../utils/lang.dart';

/// General pond water-quality thresholds used for the overall condition
/// indicator. These are NOT species-specific (see species_data.dart for
/// that). Edit the values here to match the references your group adopts.
///
/// Starting points commonly cited in warm-water pond aquaculture guidance
/// (e.g. Boyd, "Water Quality in Ponds for Aquaculture"; FAO pond
/// management manuals). Verify before using them for real decisions.
class WaterThresholds {
  WaterThresholds._();

  // Temperature (°C)
  static const temperatureGood = ParameterRange(25, 32);
  static const temperatureCaution = ParameterRange(20, 35);

  // pH
  static const phGood = ParameterRange(6.5, 9.0);
  static const phCaution = ParameterRange(6.0, 9.5);

  /// Display bounds for gauges (not thresholds).
  static const temperatureGauge = ParameterRange(15, 40);
  static const phGauge = ParameterRange(4, 11);
  static const salinityGauge = ParameterRange(0, 40);

  /// Approximate salinity (ppt) per µS/cm of conductivity at 25 °C.
  /// Used only when the sensor reports conductivity but not salinity.
  /// 0.64 ppt per mS/cm is a common rough conversion; the real relationship
  /// is non-linear (PSS-78), so values derived this way are marked "≈".
  static const pptPerMicroSiemens = 0.00064;

  static double conductivityToSalinityPpt(double microSiemensPerCm) =>
      microSiemensPerCm * pptPerMicroSiemens;

  static double salinityPptToConductivity(double ppt) =>
      ppt / pptPerMicroSiemens;

  /// Readings are stored in history at most this often during automatic
  /// refresh. Manual refreshes are always stored.
  static const historyIntervalMinutes = 5;
}

/// Salinity classes based on the Venice System (1958).
class SalinityClass {
  const SalinityClass(this._name, this._nameCeb, this._detail, this._detailCeb,
      this.range);

  final String _name;
  final String _nameCeb;
  final String _detail;
  final String _detailCeb;
  final ParameterRange range;

  String get name => tr(_name, _nameCeb);
  String get detail => tr(_detail, _detailCeb);

  static const all = [
    SalinityClass('Fresh water', 'Tab-ang nga tubig', 'below 0.5 ppt',
        'ubos sa 0.5 ppt', ParameterRange(0, 0.5)),
    SalinityClass('Low brackish', 'Gamay\'g parat', 'oligohaline, 0.5–5 ppt',
        '0.5–5 ppt', ParameterRange(0.5, 5)),
    SalinityClass('Brackish', 'Sagol parat ug tab-ang', 'mesohaline, 5–18 ppt',
        '5–18 ppt', ParameterRange(5, 18)),
    SalinityClass('High brackish', 'Parat kaayo', 'polyhaline, 18–30 ppt',
        '18–30 ppt', ParameterRange(18, 30)),
    SalinityClass('Seawater', 'Sama sa tubig dagat', 'euhaline, 30–40 ppt',
        '30–40 ppt', ParameterRange(30, 40)),
    SalinityClass('Hypersaline', 'Sobra ka parat', 'above 40 ppt',
        'labaw sa 40 ppt', ParameterRange(40, 1000)),
  ];

  static SalinityClass of(double ppt) =>
      all.firstWhere((c) => ppt < c.range.max, orElse: () => all.last);
}
