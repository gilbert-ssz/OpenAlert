import 'package:flutter/material.dart';

import '../utils/lang.dart';

/// An inclusive numeric range, e.g. an optimal pH of 6.5–8.5.
class ParameterRange {
  const ParameterRange(this.min, this.max);

  final double min;
  final double max;

  bool contains(double value) => value >= min && value <= max;
}

/// The water parameters AquaSense measures.
enum WaterParameter { temperature, ph, salinity }

/// General (species-independent) status of a single reading.
enum ParameterStatus { good, caution, critical, unknown }

extension WaterParameterInfo on WaterParameter {
  String get label => switch (this) {
        WaterParameter.temperature => tr('Temperature', 'Kainit sa Tubig'),
        WaterParameter.ph => tr('pH Level', 'pH sa Tubig'),
        WaterParameter.salinity => tr('Salinity', 'Kaparat sa Tubig'),
      };

  String get shortLabel => switch (this) {
        WaterParameter.temperature => tr('Temp', 'Kainit'),
        WaterParameter.ph => 'pH',
        WaterParameter.salinity => tr('Salinity', 'Kaparat'),
      };

  IconData get icon => switch (this) {
        WaterParameter.temperature => Icons.thermostat_rounded,
        WaterParameter.ph => Icons.science_outlined,
        WaterParameter.salinity => Icons.water_drop_outlined,
      };

  /// Plain-language explanation shown on the Monitoring screen.
  String get explanation => switch (this) {
        WaterParameter.temperature => tr(
            'How warm the water is. Fish and shrimp eat and grow best in warm '
                'water, but very hot water holds less oxygen and can stress '
                'them. Cold water makes them eat less and grow slowly.',
            'Kung unsa ka init ang tubig. Ang isda ug pasayan mokaon ug '
                'modako og maayo sa init-init nga tubig, apan kung init '
                'kaayo, gamay ra ang hangin (oxygen) sa tubig ug ma-stress '
                'sila. Kung bugnaw, gamay ra sila mokaon ug hinay modako.'),
        WaterParameter.ph => tr(
            'pH shows if the water is sour/acidic (below 7) or alkaline '
                '(above 7). It usually goes up in the afternoon and down at '
                'night. Very low or very high pH can hurt the gills and slow '
                'growth.',
            'Ang pH nagpakita kung aslom (ubos sa 7) o alkaline (labaw sa 7) '
                'ang tubig. Kasagaran mosaka kini sa hapon ug moubos sa '
                'gabii. Kung ubos kaayo o taas kaayo ang pH, madaot ang '
                'hasang ug mahinay ang pagdako.'),
        WaterParameter.salinity => tr(
            'How salty the water is, in parts per thousand (ppt). Fresh water '
                'is below 0.5 ppt and seawater is about 35 ppt. There is no '
                'single "good" salinity - it depends on what you raise, so '
                'AquaSense uses it to recommend fish, shrimp and crab.',
            'Kung unsa ka parat ang tubig, sa ppt (parts per thousand). Ang '
                'tab-ang nga tubig ubos sa 0.5 ppt ug ang tubig dagat mga '
                '35 ppt. Walay usa ka "sakto" nga kaparat - depende kini sa '
                'imong ibuhi. Mao kini ang gamiton sa AquaSense sa pagpili '
                'og isda, pasayan o alimango.'),
      };
}
