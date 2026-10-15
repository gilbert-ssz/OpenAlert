import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/water_thresholds.dart';
import '../models/app_settings.dart';
import '../models/sensor_reading.dart';
import '../models/water_parameter.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/lang.dart';

/// Chart-ready value of a reading in the user's display units.
class ChartSeries {
  ChartSeries(this.parameter, this.settings);

  final WaterParameter parameter;
  final AppSettings settings;

  bool get usesConductivity =>
      parameter == WaterParameter.salinity &&
      settings.salinityDisplay == SalinityDisplay.conductivity;

  String get unit => switch (parameter) {
        WaterParameter.temperature => Fmt.tempUnit(settings.temperatureUnit),
        WaterParameter.ph => 'pH',
        WaterParameter.salinity => usesConductivity ? 'mS/cm' : 'ppt',
      };

  double? valueOf(SensorReading r) => switch (parameter) {
        WaterParameter.temperature => r.temperatureC == null
            ? null
            : Fmt.toDisplayTemp(r.temperatureC!, settings.temperatureUnit),
        WaterParameter.ph => r.ph,
        WaterParameter.salinity => usesConductivity
            ? (r.conductivityUsCm == null ? null : r.conductivityUsCm! / 1000)
            : r.salinityForEvaluation,
      };

  /// Dashed reference lines for the general "good" range.
  List<double> get referenceLines => switch (parameter) {
        WaterParameter.temperature => [
            Fmt.toDisplayTemp(WaterThresholds.temperatureGood.min, settings.temperatureUnit),
            Fmt.toDisplayTemp(WaterThresholds.temperatureGood.max, settings.temperatureUnit),
          ],
        WaterParameter.ph => [WaterThresholds.phGood.min, WaterThresholds.phGood.max],
        WaterParameter.salinity => const [],
      };

  Color get color => switch (parameter) {
        WaterParameter.temperature => const Color(0xFFE07A2E),
        WaterParameter.ph => AppColors.teal,
        WaterParameter.salinity => const Color(0xFF1E88C8),
      };
}

class HistoryChart extends StatelessWidget {
  const HistoryChart({super.key, required this.readings, required this.series});

  /// Sorted oldest → newest.
  final List<SensorReading> readings;
  final ChartSeries series;

  static const _maxPoints = 300;

  @override
  Widget build(BuildContext context) {
    // Downsample long histories so the chart stays fast.
    final step = max(1, (readings.length / _maxPoints).ceil());
    final sampled = [
      for (var i = 0; i < readings.length; i += step) readings[i],
      if ((readings.length - 1) % step != 0) readings.last,
    ];

    final spots = <FlSpot>[];
    final values = <double>[];
    for (final r in sampled) {
      final v = series.valueOf(r);
      final x = r.timestamp.millisecondsSinceEpoch.toDouble();
      if (v == null) {
        spots.add(FlSpot.nullSpot);
      } else {
        spots.add(FlSpot(x, v));
        values.add(v);
      }
    }
    if (values.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
              tr('No values recorded for this parameter in this period.',
                  'Walay basa niini nga panahon.'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted)),
        ),
      );
    }

    final minX = sampled.first.timestamp.millisecondsSinceEpoch.toDouble();
    var maxX = sampled.last.timestamp.millisecondsSinceEpoch.toDouble();
    if (maxX == minX) maxX = minX + const Duration(hours: 1).inMilliseconds;
    final refs = series.referenceLines;
    var minY = [...values, ...refs].reduce(min);
    var maxY = [...values, ...refs].reduce(max);
    final pad = max((maxY - minY) * 0.12, 0.2);
    minY = minY - pad;
    maxY = maxY + pad;

    final spanHours = (maxX - minX) / 3600000;
    final xFormat = spanHours <= 30 ? DateFormat('h a') : DateFormat('MMM d');
    final yDecimals = (maxY - minY) < 3 ? 1 : 0;

    return SizedBox(
      height: 230,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.lightGreen, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(yDecimals),
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (maxX - minX) / 4,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      xFormat.format(
                          DateTime.fromMillisecondsSinceEpoch(value.round())),
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  );
                },
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              for (final y in refs)
                HorizontalLine(
                  y: y,
                  color: AppColors.good.withValues(alpha: 0.7),
                  strokeWidth: 1.2,
                  dashArray: [6, 4],
                ),
            ],
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.deepGreen,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (touched) => touched
                  .map((s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(series.parameter == WaterParameter.ph ? 2 : 1)} ${series.unit}\n',
                        const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                        children: [
                          TextSpan(
                            text: Fmt.dateTime(
                                DateTime.fromMillisecondsSinceEpoch(s.x.round())),
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              color: series.color,
              barWidth: 3,
              dotData: FlDotData(show: values.length < 30),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    series.color.withValues(alpha: 0.25),
                    series.color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
