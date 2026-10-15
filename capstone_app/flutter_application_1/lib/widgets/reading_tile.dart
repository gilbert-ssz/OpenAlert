import 'package:flutter/material.dart';

import '../config/water_thresholds.dart';
import '../logic/water_quality.dart';
import '../models/app_settings.dart';
import '../models/sensor_reading.dart';
import '../models/water_parameter.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/lang.dart';
import 'common.dart';
import 'status_widgets.dart';

/// Status chip for a parameter. Salinity shows its water class instead of
/// good/bad, since suitable salinity depends on the species.
Widget parameterStatusPill(WaterParameter p, SensorReading? r, {bool dense = false}) {
  final value = r?.valueOf(p);
  if (p == WaterParameter.salinity && value != null) {
    return StatusPill(
      StatusStyle(SalinityClass.of(value).name, AppColors.teal, Icons.waves_rounded),
      dense: dense,
    );
  }
  if (value == null && r != null) {
    return StatusPill(
      StatusStyle(tr('Unavailable', 'Walay basa'), AppColors.unknown,
          Icons.sensors_off_rounded),
      dense: dense,
    );
  }
  return StatusPill(StatusStyle.parameter(WaterQuality.statusFor(p, value)),
      dense: dense);
}

/// Compact summary card for one parameter (Home dashboard).
class ReadingTile extends StatelessWidget {
  const ReadingTile({
    super.key,
    required this.parameter,
    required this.reading,
    required this.settings,
    this.onTap,
  });

  final WaterParameter parameter;
  final SensorReading? reading;
  final AppSettings settings;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dv = Fmt.value(parameter, reading, settings);
    final unavailable = reading != null && dv.isMissing;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(parameter.icon, color: AppColors.teal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parameter.label,
                    style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                if (unavailable)
                  Text(tr('Sensor unavailable', 'Walay basa ang sensor'),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.unknown))
                else
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: '${dv.estimated ? '≈' : ''}${dv.value}',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                      if (dv.unit.isNotEmpty && !dv.isMissing)
                        TextSpan(
                          text: ' ${dv.unit}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.muted),
                        ),
                    ]),
                    style: const TextStyle(color: AppColors.ink),
                  ),
              ],
            ),
          ),
          parameterStatusPill(parameter, reading),
        ],
      ),
    );
  }
}
