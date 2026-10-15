import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../logic/recommendation_engine.dart';
import '../models/app_settings.dart';
import '../models/fish_species.dart';
import '../models/sensor_reading.dart';
import '../models/water_parameter.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/lang.dart';
import '../widgets/common.dart';
import '../widgets/photo_header.dart';
import '../widgets/species_card.dart';
import '../widgets/status_widgets.dart';
import 'species_detail_screen.dart';

enum RecommendationBasis { latest, average24h }

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  RecommendationBasis _basis = RecommendationBasis.latest;

  /// null = show every group.
  SpeciesGroup? _group;

  SensorReading? _basisReading(List<SensorReading> history, SensorReading? latest) {
    if (_basis == RecommendationBasis.latest) return latest;
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    // Only average readings of the same kind as the current mode, so demo
    // data never mixes with sensor data.
    final demo = latest?.isDemo ?? history.lastOrNull?.isDemo ?? true;
    final recent = history
        .where((r) => r.timestamp.isAfter(cutoff) && r.isDemo == demo)
        .toList();
    return SensorReading.average(recent);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([scope.monitoring, scope.settings]),
      builder: (context, _) {
        final m = scope.monitoring;
        final settings = scope.settings.value;
        final reading = _basisReading(m.history, m.latest);
        final all = reading == null
            ? <SpeciesRecommendation>[]
            : RecommendationEngine.evaluate(reading);
        final recs = _group == null
            ? all
            : all.where((r) => r.species.group == _group).toList();

        return CustomScrollView(
          slivers: [
            PhotoHeader(
              image: AppImages.fish,
              title: tr('What to Raise', 'Unsay Angay Ibuhi'),
              eyebrow: Align(
                alignment: Alignment.centerLeft,
                child: ConnectionBadge(m.status),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverList.list(children: [
                Text(
                  tr('Show:', 'Ipakita:'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _GroupFilter(
                  selected: _group,
                  onSelected: (g) => setState(() => _group = g),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<RecommendationBasis>(
                    segments: [
                      ButtonSegment(
                        value: RecommendationBasis.latest,
                        label: Text(tr('Latest reading', 'Bag-ong basa')),
                        icon: const Icon(Icons.bolt_rounded),
                      ),
                      ButtonSegment(
                        value: RecommendationBasis.average24h,
                        label: Text(tr('24-hour average', 'Average sa 24 oras')),
                        icon: const Icon(Icons.av_timer_rounded),
                      ),
                    ],
                    selected: {_basis},
                    onSelectionChanged: (s) => setState(() => _basis = s.first),
                  ),
                ),
                const SizedBox(height: 12),
                if (reading == null)
                  StateMessage(
                    icon: Icons.set_meal_outlined,
                    title: tr('No readings to check', 'Walay basa nga masusi'),
                    message: _basis == RecommendationBasis.latest
                        ? tr(
                            'Suggestions need a current reading. Tap the '
                                'button below, or switch to the 24-hour '
                                'average.',
                            'Kinahanglan og bag-ong basa. Pindota ang button '
                                'sa ubos, o pilia ang average sa 24 oras.')
                        : tr('No readings were recorded in the last 24 hours.',
                            'Walay basa nga natala sulod sa 24 ka oras.'),
                    action: FilledButton.icon(
                      onPressed: () => m.refresh(userInitiated: true),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(tr('Check water now', 'Susiha ang tubig karon')),
                    ),
                  )
                else ...[
                  _BasisCard(reading: reading, basis: _basis, settings: settings),
                  const SizedBox(height: 12),
                  _SummaryRow(recs: recs),
                ],
              ]),
            ),
            if (reading != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: recs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => SpeciesCard(
                    recommendation: recs[i],
                    settings: settings,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SpeciesDetailScreen(
                            recommendation: recs[i], basis: reading),
                      ),
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              sliver: SliverToBoxAdapter(
                child: InfoBanner(
                  icon: Icons.menu_book_rounded,
                  color: AppColors.teal,
                  title: tr('How suggestions work', 'Unsaon pagpili'),
                  message: tr(
                      'AquaSense compares your water with what each fish, '
                          'shrimp and crab needs. Green = good, yellow = can '
                          'live but watch closely, red = not safe. Other '
                          'things like oxygen, ammonia and pond care also '
                          'matter - ask BFAR or SEAFDEC before stocking.',
                      'Gikumpara sa AquaSense ang imong tubig sa kinahanglan '
                          'sa matag isda, pasayan ug alimango. Berde = maayo, '
                          'dalag = mabuhi apan bantayi, pula = dili luwas. '
                          'Importante usab ang oxygen, ammonia ug pag-atiman '
                          'sa fishpond - pangutana sa BFAR o SEAFDEC una '
                          'mag-stock.'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Big, easy-to-tap buttons: All / Fish / Shrimp / Crab.
class _GroupFilter extends StatelessWidget {
  const _GroupFilter({required this.selected, required this.onSelected});

  final SpeciesGroup? selected;
  final ValueChanged<SpeciesGroup?> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget chip(SpeciesGroup? group, String emoji, String label) {
      final isSelected = selected == group;
      return ChoiceChip(
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) => onSelected(group),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        selectedColor: AppColors.teal,
        backgroundColor: Colors.white,
        side: BorderSide(
            color: isSelected ? AppColors.teal : const Color(0xFFD5E4DC)),
        label: Text(
          '$emoji  $label',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.ink,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(null, '✅', tr('All', 'Tanan')),
        for (final g in SpeciesGroup.values) chip(g, g.emoji, g.label),
      ],
    );
  }
}

class _BasisCard extends StatelessWidget {
  const _BasisCard({required this.reading, required this.basis, required this.settings});

  final SensorReading reading;
  final RecommendationBasis basis;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final values = WaterParameter.values
        .map((p) => Fmt.value(p, reading, settings))
        .map((d) => d.toString())
        .toList();
    final source = reading.isDemo
        ? tr('Demo reading', 'Sample nga basa')
        : tr('Sensor reading', 'Basa sa sensor');
    final label = basis == RecommendationBasis.latest
        ? '$source ${tr('at', 'sa')} ${Fmt.time(reading.timestamp)}'
        : tr('24-hour average${reading.isDemo ? ' of demo data' : ''}',
            'Average sa 24 oras${reading.isDemo ? ' (sample)' : ''}');
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            reading.isDemo ? Icons.science_rounded : Icons.sensors_rounded,
            color: reading.isDemo ? AppColors.demo : AppColors.good,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${tr('Based on', 'Base sa')}: $label',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '${values[0]}  •  pH ${values[1]}  •  ${values[2]}',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.recs});

  final List<SpeciesRecommendation> recs;

  @override
  Widget build(BuildContext context) {
    Widget box(Suitability s) {
      final style = StatusStyle.suitability(s);
      final count = recs.where((r) => r.suitability == s).length;
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: style.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text('$count',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900, color: style.color)),
              Text(style.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, color: style.color)),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box(Suitability.suitable),
        const SizedBox(width: 8),
        box(Suitability.caution),
        const SizedBox(width: 8),
        box(Suitability.unsuitable),
      ],
    );
  }
}
