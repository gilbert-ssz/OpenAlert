import 'dart:math';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/app_settings.dart';
import '../models/sensor_reading.dart';
import '../models/water_parameter.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/lang.dart';
import '../widgets/common.dart';
import '../widgets/history_chart.dart';
import '../widgets/photo_header.dart';

enum HistoryRange { day, week, month, all, customDay }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryRange _range = HistoryRange.week;
  DateTime? _day;
  WaterParameter _parameter = WaterParameter.temperature;

  static const _listLimit = 200;

  List<SensorReading> _filter(List<SensorReading> all) {
    final now = DateTime.now();
    bool Function(SensorReading) test;
    switch (_range) {
      case HistoryRange.day:
        final c = now.subtract(const Duration(hours: 24));
        test = (r) => r.timestamp.isAfter(c);
      case HistoryRange.week:
        final c = now.subtract(const Duration(days: 7));
        test = (r) => r.timestamp.isAfter(c);
      case HistoryRange.month:
        final c = now.subtract(const Duration(days: 30));
        test = (r) => r.timestamp.isAfter(c);
      case HistoryRange.all:
        test = (_) => true;
      case HistoryRange.customDay:
        final d = _day!;
        test = (r) =>
            r.timestamp.year == d.year &&
            r.timestamp.month == d.month &&
            r.timestamp.day == d.day;
    }
    return all.where(test).toList();
  }

  Future<void> _pickDate(List<SensorReading> all) async {
    final now = DateTime.now();
    final first = all.isEmpty ? now.subtract(const Duration(days: 30)) : all.first.timestamp;
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? now,
      firstDate: DateTime(first.year, first.month, first.day),
      lastDate: now,
      helpText: tr('Show readings from', 'Ipakita ang basa sa'),
    );
    if (picked != null) {
      setState(() {
        _day = picked;
        _range = HistoryRange.customDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([scope.monitoring, scope.settings]),
      builder: (context, _) {
        final settings = scope.settings.value;
        final all = scope.monitoring.history;
        final filtered = _filter(all);
        final newestFirst = filtered.reversed.take(_listLimit).toList();
        final series = ChartSeries(_parameter, settings);

        return CustomScrollView(
          slivers: [
            PhotoHeader(
              image: AppImages.history,
              title: tr('History', 'Kasaysayan'),
              eyebrow: Text(
                tr('${all.length} reading${all.length == 1 ? '' : 's'} stored on this device',
                    '${all.length} ka basa ang natala niini nga cellphone'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                ),
              ),
              actions: [
                IconButton(
                  tooltip: tr('Pick a date', 'Pili og petsa'),
                  onPressed: () => _pickDate(all),
                  icon: const Icon(Icons.calendar_month_rounded),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              sliver: SliverList.list(children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _chip(tr('24 hours', '24 oras'), HistoryRange.day),
                    _chip(tr('7 days', '7 ka adlaw'), HistoryRange.week),
                    _chip(tr('30 days', '30 ka adlaw'), HistoryRange.month),
                    _chip(tr('All', 'Tanan'), HistoryRange.all),
                    ChoiceChip(
                      avatar: const Icon(Icons.event_rounded, size: 18),
                      label: Text(_range == HistoryRange.customDay && _day != null
                          ? Fmt.date(_day!)
                          : tr('Pick date', 'Pili og petsa')),
                      selected: _range == HistoryRange.customDay,
                      onSelected: (_) => _pickDate(all),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<WaterParameter>(
                    showSelectedIcon: false,
                    segments: [
                      for (final p in WaterParameter.values)
                        ButtonSegment(
                            value: p, label: Text(p.shortLabel), icon: Icon(p.icon)),
                    ],
                    selected: {_parameter},
                    onSelectionChanged: (s) => setState(() => _parameter = s.first),
                  ),
                ),
                const SizedBox(height: 14),
                if (filtered.isEmpty)
                  StateMessage(
                    icon: Icons.insights_rounded,
                    title: all.isEmpty
                        ? tr('No readings yet', 'Wala pay basa')
                        : tr('No readings in this period',
                            'Walay basa niini nga panahon'),
                    message: all.isEmpty
                        ? tr(
                            'Readings are saved here automatically each time '
                                'the app gets new data. Tap "Check water now" '
                                'on Home to record one.',
                            'Awtomatik nga matala dinhi ang basa matag '
                                'makadawat og bag-ong datos. Pindota ang '
                                '"Susiha ang tubig karon" sa Home.')
                        : tr('Try a longer time range or pick another date.',
                            'Sulayi ang mas taas nga panahon o pili og laing '
                                'petsa.'),
                    action: all.isEmpty
                        ? null
                        : OutlinedButton(
                            onPressed: () =>
                                setState(() => _range = HistoryRange.all),
                            child: Text(tr('Show all readings',
                                'Ipakita tanang basa')),
                          ),
                  )
                else ...[
                  if (filtered.any((r) => r.isDemo))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InfoBanner(
                        icon: Icons.science_rounded,
                        color: AppColors.demo,
                        title: tr('Includes demo data', 'Naay sample nga datos'),
                        message: tr(
                            'Readings marked DEMO are examples only, not '
                                'sensor measurements.',
                            'Ang basa nga naay DEMO pananglitan lang, dili '
                                'gikan sa sensor.'),
                      ),
                    ),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 12),
                          child: Text(
                            '${_parameter.label} (${series.unit})',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        HistoryChart(readings: filtered, series: series),
                        if (_parameter != WaterParameter.salinity)
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 6),
                            child: Text(
                              tr('Dashed lines: normal range',
                                  'Mga putol-putol nga linya: normal nga range'),
                              style: const TextStyle(fontSize: 13, color: AppColors.muted),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatsRow(readings: filtered, series: series),
                  SectionTitle(
                    '${tr('Readings', 'Mga basa')} (${filtered.length})',
                  ),
                  if (filtered.length > _listLimit)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                          tr('Showing the latest $_listLimit readings.',
                              'Gipakita ang katapusang $_listLimit ka basa.'),
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 13.5)),
                    ),
                ],
              ]),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              sliver: SliverList.separated(
                itemCount: newestFirst.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) =>
                    _ReadingRow(reading: newestFirst[i], settings: settings),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chip(String label, HistoryRange range) => ChoiceChip(
        label: Text(label),
        selected: _range == range,
        onSelected: (_) => setState(() => _range = range),
      );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.readings, required this.series});

  final List<SensorReading> readings;
  final ChartSeries series;

  @override
  Widget build(BuildContext context) {
    final values = readings.map(series.valueOf).whereType<double>().toList();
    if (values.isEmpty) return const SizedBox.shrink();
    final decimals = series.parameter == WaterParameter.ph ? 2 : 1;
    String f(double v) => v.toStringAsFixed(decimals);
    final avg = values.reduce((a, b) => a + b) / values.length;

    Widget stat(String label, String value) => Expanded(
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Text(label,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.ink)),
              ],
            ),
          ),
        );

    return Row(
      children: [
        stat(tr('Lowest', 'Pinakaubos'), f(values.reduce(min))),
        const SizedBox(width: 8),
        stat(tr('Average', 'Average'), f(avg)),
        const SizedBox(width: 8),
        stat(tr('Highest', 'Pinakataas'), f(values.reduce(max))),
      ],
    );
  }
}

class _ReadingRow extends StatelessWidget {
  const _ReadingRow({required this.reading, required this.settings});

  final SensorReading reading;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    String v(WaterParameter p) => Fmt.value(p, reading, settings).toString();
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Fmt.time(reading.timestamp),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(Fmt.date(reading.timestamp),
                  style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 4,
              children: [
                _value(Icons.thermostat_rounded, v(WaterParameter.temperature)),
                _value(Icons.science_outlined, 'pH ${v(WaterParameter.ph)}'),
                _value(Icons.water_drop_outlined, v(WaterParameter.salinity)),
                if (reading.isDemo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.demo.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('DEMO',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.demo)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _value(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.teal),
          const SizedBox(width: 3),
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      );
}
