import 'package:flutter/material.dart';

import '../controllers/monitoring_controller.dart';
import '../logic/recommendation_engine.dart';
import '../models/water_parameter.dart';
import '../theme/app_theme.dart';
import '../utils/lang.dart';

class StatusStyle {
  const StatusStyle(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;

  static StatusStyle parameter(ParameterStatus s) => switch (s) {
        ParameterStatus.good => StatusStyle(
            tr('Good', 'Maayo'), AppColors.good, Icons.check_circle_rounded),
        ParameterStatus.caution => StatusStyle(tr('Caution', 'Bantayi'),
            AppColors.caution, Icons.warning_amber_rounded),
        ParameterStatus.critical => StatusStyle(
            tr('Critical', 'Delikado'), AppColors.critical, Icons.error_rounded),
        ParameterStatus.unknown => StatusStyle(tr('No data', 'Walay datos'),
            AppColors.unknown, Icons.help_outline_rounded),
      };

  static StatusStyle suitability(Suitability s) => switch (s) {
        Suitability.suitable => StatusStyle(tr('Suitable', 'Angay'),
            AppColors.good, Icons.check_circle_rounded),
        Suitability.caution => StatusStyle(tr('Caution', 'Bantayi'),
            AppColors.caution, Icons.warning_amber_rounded),
        Suitability.unsuitable => StatusStyle(tr('Not Suitable', 'Dili Angay'),
            AppColors.critical, Icons.cancel_rounded),
        Suitability.unknown => StatusStyle(tr('Not checked', 'Wala masusi'),
            AppColors.unknown, Icons.help_outline_rounded),
      };

  static StatusStyle connection(ConnectionStatus s) => switch (s) {
        ConnectionStatus.demo => StatusStyle(tr('Demo Mode', 'Demo Mode'),
            AppColors.demo, Icons.science_rounded),
        ConnectionStatus.connecting => StatusStyle(
            tr('Connecting…', 'Nagkonektar…'), AppColors.caution, Icons.sync_rounded),
        ConnectionStatus.connected => StatusStyle(tr('Connected', 'Konektado'),
            AppColors.good, Icons.sensors_rounded),
        ConnectionStatus.disconnected => StatusStyle(
            tr('Disconnected', 'Naputol'), AppColors.critical,
            Icons.sensors_off_rounded),
      };
}

/// Small rounded label with icon, e.g. "Good" or "Suitable".
class StatusPill extends StatelessWidget {
  const StatusPill(this.style, {super.key, this.solid = false, this.dense = false});

  final StatusStyle style;

  /// Solid pills are used on top of photos.
  final bool solid;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final fg = solid ? Colors.white : style.color;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(
        color: solid ? style.color : style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: dense ? 14 : 17, color: fg),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              color: fg,
              fontSize: dense ? 12 : 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Connection status chip shown on photo headers.
class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge(this.status, {super.key});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) =>
      StatusPill(StatusStyle.connection(status), solid: true);
}
