import 'package:flutter/material.dart';

import '../config/water_thresholds.dart';
import '../models/water_parameter.dart';
import '../theme/app_theme.dart';

class GaugeZone {
  const GaugeZone(this.from, this.to, this.color);

  final double from;
  final double to;
  final Color color;
}

/// Horizontal bar with colored zones and a marker for the current value.
/// Values are in the parameter's base unit (°C, pH, ppt).
class RangeGauge extends StatelessWidget {
  const RangeGauge({
    super.key,
    required this.parameter,
    required this.value,
    required this.labelFor,
  });

  final WaterParameter parameter;
  final double? value;

  /// Formats a bound for the min/max labels (handles °F).
  final String Function(double) labelFor;

  static ParameterRange boundsFor(WaterParameter p) => switch (p) {
        WaterParameter.temperature => WaterThresholds.temperatureGauge,
        WaterParameter.ph => WaterThresholds.phGauge,
        WaterParameter.salinity => WaterThresholds.salinityGauge,
      };

  static List<GaugeZone> zonesFor(WaterParameter p) {
    switch (p) {
      case WaterParameter.temperature:
        return _statusZones(WaterThresholds.temperatureGauge,
            WaterThresholds.temperatureGood, WaterThresholds.temperatureCaution);
      case WaterParameter.ph:
        return _statusZones(WaterThresholds.phGauge, WaterThresholds.phGood,
            WaterThresholds.phCaution);
      case WaterParameter.salinity:
        // Fresh → seawater, light aqua to deep teal (not good/bad).
        const shades = [
          Color(0xFFB9EAF0),
          Color(0xFF8ED8E2),
          Color(0xFF4FBFCB),
          Color(0xFF1E9AA6),
          Color(0xFF0F766E),
        ];
        final b = WaterThresholds.salinityGauge;
        return [
          for (var i = 0; i < shades.length; i++)
            GaugeZone(
              SalinityClass.all[i].range.min,
              SalinityClass.all[i].range.max.clamp(b.min, b.max),
              shades[i],
            ),
        ];
    }
  }

  static List<GaugeZone> _statusZones(
      ParameterRange bounds, ParameterRange good, ParameterRange caution) {
    return [
      GaugeZone(bounds.min, caution.min, AppColors.critical),
      GaugeZone(caution.min, good.min, AppColors.caution),
      GaugeZone(good.min, good.max, AppColors.good),
      GaugeZone(good.max, caution.max, AppColors.caution),
      GaugeZone(caution.max, bounds.max, AppColors.critical),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bounds = boundsFor(parameter);
    final zones = zonesFor(parameter);
    final span = bounds.max - bounds.min;
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final v = value;
      final markerX = v == null
          ? null
          : ((v.clamp(bounds.min, bounds.max) - bounds.min) / span) * w;
      return Column(
        children: [
          SizedBox(
            height: 26,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      children: [
                        for (final z in zones)
                          Expanded(
                            flex: ((z.to - z.from) / span * 1000).round().clamp(1, 1000),
                            child: Container(
                              height: 10,
                              color: z.color.withValues(alpha: 0.75),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (markerX != null)
                  Positioned(
                    left: (markerX - 11).clamp(0.0, w - 22),
                    top: 2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.deepGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: AppTheme.softShadow,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(labelFor(bounds.min),
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              Text(labelFor(bounds.max),
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ],
      );
    });
  }
}
