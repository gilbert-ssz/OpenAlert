import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../config/water_thresholds.dart';
import '../controllers/monitoring_controller.dart';
import '../logic/recommendation_engine.dart';
import '../logic/water_quality.dart';
import '../models/app_settings.dart';
import '../models/sensor_reading.dart';
import '../models/water_parameter.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/lang.dart';
import '../widgets/common.dart';
import '../widgets/photo_header.dart';
import '../widgets/reading_tile.dart';
import '../widgets/species_card.dart';
import '../widgets/status_widgets.dart';
import 'main_shell.dart';
import 'species_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([scope.monitoring, scope.settings, scope.auth]),
      builder: (context, _) {
        final m = scope.monitoring;
        final settings = scope.settings.value;
        final reading = m.latest;
        final name = scope.auth.session?.firstName ?? tr('there', 'higala');
        final tips = WaterQuality.advice(reading);

        return RefreshIndicator(
          onRefresh: () => m.refresh(userInitiated: true),
          edgeOffset: 100,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              PhotoHeader(
                image: AppImages.home,
                title: '${Fmt.greeting()}, $name',
                expandedHeight: 250,
                eyebrow: Row(
                  children: [
                    ConnectionBadge(m.status),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        settings.pondName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                sliver: SliverList.list(
                  children: [
                    if (m.status == ConnectionStatus.demo) ...[
                      const DemoNotice(),
                      const SizedBox(height: 14),
                    ],
                    if (m.status == ConnectionStatus.disconnected) ...[
                      InfoBanner(
                        icon: Icons.sensors_off_rounded,
                        color: AppColors.critical,
                        title: tr('Sensor node disconnected',
                            'Naputol ang sensor'),
                        message: m.error ??
                            tr('Could not reach the ESP32.',
                                'Dili makonektar sa ESP32.'),
                        action: Wrap(spacing: 8, children: [
                          FilledButton.tonal(
                            onPressed: () => m.refresh(userInitiated: true),
                            child: Text(tr('Retry', 'Sulayi pag-usab')),
                          ),
                          TextButton(
                            onPressed: () => onNavigate(MainShell.settings),
                            child: Text(tr('Connection settings',
                                'Settings sa koneksyon')),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 14),
                    ],
                    _OverallConditionCard(reading: reading, loading: m.isLoading),
                    if (tips.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _AdviceCard(tips: tips),
                    ],
                    SectionTitle(tr('Water Readings', 'Basa sa Tubig')),
                    _ReadingGrid(
                      reading: reading,
                      settings: settings,
                      onTap: () => onNavigate(MainShell.monitor),
                    ),
                    const SizedBox(height: 4),
                    FilledButton.icon(
                      onPressed: m.isLoading
                          ? null
                          : () => m.refresh(userInitiated: true),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(60),
                        backgroundColor: AppColors.teal,
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      icon: m.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Icon(Icons.refresh_rounded, size: 26),
                      label: Text(m.isLoading
                          ? tr('Checking…', 'Gisusi…')
                          : tr('Check water now', 'Susiha ang tubig karon')),
                    ),
                    const SizedBox(height: 8),
                    LastUpdatedRow(reading: reading),
                    SectionTitle(
                      tr('Best to raise in this water',
                          'Angay ibuhi niining tubiga'),
                      actionLabel: tr('See all', 'Tan-awa tanan'),
                      onAction: () => onNavigate(MainShell.fish),
                    ),
                    _TopPicks(reading: reading),
                    SectionTitle(tr('Go to', 'Adto sa')),
                    _QuickActions(onNavigate: onNavigate),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OverallConditionCard extends StatelessWidget {
  const _OverallConditionCard({required this.reading, required this.loading});

  final SensorReading? reading;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final status = WaterQuality.overall(reading);
    final style = StatusStyle.parameter(status);
    final salinity = reading?.salinityForEvaluation;
    final waiting = reading == null && loading;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [style.color, Color.lerp(style.color, AppColors.deepGreen, 0.55)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: waiting
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3),
                  )
                : Icon(style.icon, color: Colors.white, size: 42),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('Overall Water Condition', 'Kahimtang sa Tubig'),
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text(
                  waiting
                      ? tr('Checking…', 'Gisusi…')
                      : WaterQuality.overallTitle(status),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  waiting
                      ? tr('Getting the latest readings.',
                          'Gikuha ang pinakabag-o nga basa.')
                      : WaterQuality.overallMessage(status),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, height: 1.35),
                ),
                if (salinity != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${tr('Water type', 'Klase sa tubig')}: '
                    '${SalinityClass.of(salinity).name} '
                    '(${SalinityClass.of(salinity).detail})',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple numbered steps telling the owner what to do.
class _AdviceCard extends StatelessWidget {
  const _AdviceCard({required this.tips});

  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: const Color(0xFFFFF8E6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  color: AppColors.caution, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(tr('What to do', 'Unsay buhaton'),
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < tips.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: AppColors.caution,
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(tips[i],
                        style: const TextStyle(
                            fontSize: 15.5,
                            height: 1.4,
                            color: AppColors.ink)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReadingGrid extends StatelessWidget {
  const _ReadingGrid({
    required this.reading,
    required this.settings,
    required this.onTap,
  });

  final SensorReading? reading;
  final AppSettings settings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      for (final p in WaterParameter.values)
        ReadingTile(parameter: p, reading: reading, settings: settings, onTap: onTap),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      // One column on phones, three on tablets / landscape.
      if (constraints.maxWidth < 600) {
        return Column(
          children: [
            for (final t in tiles)
              Padding(padding: const EdgeInsets.only(bottom: 10), child: t),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: tiles[i]),
          ],
        ],
      );
    });
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    Widget action(String image, IconData icon, String label, int tab) => Expanded(
          child: _PhotoAction(
            image: image,
            icon: icon,
            label: label,
            onTap: () => onNavigate(tab),
          ),
        );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          action(AppImages.monitor, Icons.water_drop_rounded,
              tr('Water', 'Tubig'), MainShell.monitor),
          const SizedBox(width: 10),
          action(AppImages.fish, Icons.set_meal_rounded,
              tr('What to raise', 'Unsay ibuhi'), MainShell.fish),
          const SizedBox(width: 10),
          action(AppImages.history, Icons.show_chart_rounded,
              tr('History', 'Kasaysayan'), MainShell.history),
        ],
      ),
    );
  }
}

class _PhotoAction extends StatelessWidget {
  const _PhotoAction({
    required this.image,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String image;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Grows with the text so large font sizes never overflow.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 112),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),
                Positioned.fill(
                  child: ColoredBox(
                      color: AppColors.deepGreen.withValues(alpha: 0.6)),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: Colors.white, size: 32),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopPicks extends StatelessWidget {
  const _TopPicks({required this.reading});

  final SensorReading? reading;

  @override
  Widget build(BuildContext context) {
    if (reading == null) {
      return AppCard(
        child: Text(
          tr('Suggestions will appear once a reading is available.',
              'Makita ang mga sugyot kung naa nay basa sa tubig.'),
          style: const TextStyle(color: AppColors.muted),
        ),
      );
    }
    final recs = RecommendationEngine.evaluate(reading);
    return SizedBox(
      height: 190 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => SpeciesMiniCard(
          recommendation: recs[i],
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => SpeciesDetailScreen(
              recommendation: recs[i],
              basis: reading!,
            ),
          )),
        ),
      ),
    );
  }
}
