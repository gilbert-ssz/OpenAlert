import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../config/water_thresholds.dart';
import '../controllers/monitoring_controller.dart';
import '../models/app_settings.dart';
import '../models/sensor_reading.dart';
import '../models/water_parameter.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/lang.dart';
import '../widgets/common.dart';
import '../widgets/photo_header.dart';
import '../widgets/range_gauge.dart';
import '../widgets/reading_tile.dart';
import '../widgets/status_widgets.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([scope.monitoring, scope.settings]),
      builder: (context, _) {
        final m = scope.monitoring;
        final settings = scope.settings.value;
        final reading = m.latest;

        return RefreshIndicator(
          onRefresh: () => m.refresh(userInitiated: true),
          edgeOffset: 100,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              PhotoHeader(
                image: AppImages.monitor,
                title: tr('Water Readings', 'Basa sa Tubig'),
                eyebrow: Align(
                  alignment: Alignment.centerLeft,
                  child: ConnectionBadge(m.status),
                ),
                actions: [
                  IconButton(
                    tooltip: tr('Refresh readings', 'I-refresh ang basa'),
                    onPressed:
                        m.isLoading ? null : () => m.refresh(userInitiated: true),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                sliver: SliverList.list(
                  children: _content(context, m, settings, reading),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _content(BuildContext context, MonitoringController m,
      AppSettings settings, SensorReading? reading) {
    // 1. First load, nothing to show yet.
    if (reading == null && m.isLoading) {
      return [
        LoadingState(
            message: tr('Getting the latest readings…',
                'Gikuha ang pinakabag-o nga basa…')),
      ];
    }

    // 2. ESP32 mode and the node cannot be reached.
    if (reading == null && m.status == ConnectionStatus.disconnected) {
      final last = m.lastSensorReading;
      return [
        StateMessage(
          icon: Icons.sensors_off_rounded,
          color: AppColors.critical,
          title: tr('Sensor node disconnected', 'Naputol ang sensor'),
          message: '${m.error ?? tr('Could not reach the ESP32.', 'Dili makonektar sa ESP32.')}'
              '\n\n'
              '${tr('Check that the ESP32 is powered on and that this phone '
                  'is connected to the same Wi-Fi network.', 'Susiha kung '
                  'naka-on ang ESP32 ug kung kini nga cellphone konektado sa '
                  'parehas nga Wi-Fi.')}',
          action: FilledButton.icon(
            onPressed: () => m.refresh(userInitiated: true),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(tr('Try again', 'Sulayi pag-usab')),
          ),
        ),
        if (last != null) ...[
          SectionTitle(tr('Last recorded reading (not live)',
              'Katapusang basa (dili karon)')),
          InfoBanner(
            icon: Icons.history_rounded,
            color: AppColors.unknown,
            title:
                '${tr('Recorded', 'Natala')} ${Fmt.dateTime(last.timestamp)}',
            message: tr(
                'This is the most recent reading received from the sensor. '
                    'Current pond conditions may be different.',
                'Kini ang katapusang basa gikan sa sensor. Basin lahi na ang '
                    'kahimtang sa fishpond karon.'),
          ),
          const SizedBox(height: 12),
          for (final p in WaterParameter.values) ...[
            Opacity(
              opacity: 0.75,
              child: _ParameterDetailCard(
                  parameter: p, reading: last, settings: settings),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ];
    }

    // 3. No data at all (e.g. demo data cleared mid-refresh).
    if (reading == null) {
      return [
        StateMessage(
          icon: Icons.water_drop_outlined,
          title: tr('No readings available', 'Walay basa'),
          message: tr('Tap the button to get a new reading.',
              'Pindota ang button aron makakuha og bag-ong basa.'),
          action: FilledButton.icon(
            onPressed: () => m.refresh(userInitiated: true),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(tr('Check water now', 'Susiha ang tubig karon')),
          ),
        ),
      ];
    }

    // 4. Normal display.
    return [
      if (reading.isDemo) ...[const DemoNotice(), const SizedBox(height: 12)],
      LastUpdatedRow(reading: reading, loading: m.isLoading),
      const SizedBox(height: 12),
      for (final p in WaterParameter.values) ...[
        _ParameterDetailCard(parameter: p, reading: reading, settings: settings),
        const SizedBox(height: 14),
      ],
    ];
  }
}

class _ParameterDetailCard extends StatelessWidget {
  const _ParameterDetailCard({
    required this.parameter,
    required this.reading,
    required this.settings,
  });

  final WaterParameter parameter;
  final SensorReading reading;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final dv = Fmt.value(parameter, reading, settings);
    final value = reading.valueOf(parameter);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(parameter.icon, color: AppColors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(parameter.label,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink)),
              ),
              parameterStatusPill(parameter, reading),
            ],
          ),
          const SizedBox(height: 14),
          if (value == null)
            const _SensorUnavailable()
          else ...[
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '${dv.estimated ? '≈' : ''}${dv.value}',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
                ),
                if (dv.unit.isNotEmpty)
                  TextSpan(
                    text: ' ${dv.unit}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted),
                  ),
              ]),
              style: const TextStyle(color: AppColors.ink, height: 1.1),
            ),
            if (parameter == WaterParameter.salinity) ..._salinityDetails(value),
            const SizedBox(height: 14),
            RangeGauge(
              parameter: parameter,
              value: value,
              labelFor: (v) => parameter == WaterParameter.temperature
                  ? Fmt.number(parameter, v, settings).replaceAll('.0', '')
                  : parameter == WaterParameter.ph
                      ? v.toStringAsFixed(0)
                      : '${v.toStringAsFixed(0)} ppt',
            ),
            if (parameter != WaterParameter.salinity) ...[
              const SizedBox(height: 6),
              Text(
                '${tr('Normal range', 'Normal nga range')}: '
                '${Fmt.range(parameter, parameter == WaterParameter.temperature ? WaterThresholds.temperatureGood : WaterThresholds.phGood, settings)}',
                style: const TextStyle(fontSize: 14, color: AppColors.muted),
              ),
            ],
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(parameter.explanation,
                      style: const TextStyle(
                          fontSize: 15, height: 1.45, color: AppColors.ink)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _salinityDetails(double ppt) {
    final cls = SalinityClass.of(ppt);
    final secondary = settings.salinityDisplay == SalinityDisplay.conductivity
        ? '${ppt.toStringAsFixed(1)} ppt'
        : reading.conductivityUsCm != null
            ? Fmt.conductivity(reading.conductivityUsCm!).toString()
            : null;
    return [
      const SizedBox(height: 4),
      Text('${cls.name} - ${cls.detail}',
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: AppColors.teal)),
      if (secondary != null)
        Text('${tr('Also', 'Usab')}: $secondary',
            style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
      if (reading.isSalinityEstimated)
        Text(
          tr('≈ Estimated from conductivity (approximate conversion).',
              '≈ Gibanabana gikan sa conductivity.'),
          style: const TextStyle(fontSize: 13.5, color: AppColors.muted),
        ),
    ];
  }
}

class _SensorUnavailable extends StatelessWidget {
  const _SensorUnavailable();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.unknown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.sensors_off_rounded, color: AppColors.unknown),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr(
                  'No reading from this sensor. Check that the probe is '
                      'connected and under the water.',
                  'Walay basa gikan niini nga sensor. Susiha kung nakakabit '
                      'ug nalubog sa tubig ang probe.'),
              style: const TextStyle(color: AppColors.ink, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
