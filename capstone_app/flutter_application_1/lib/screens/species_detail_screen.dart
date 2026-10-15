import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../logic/recommendation_engine.dart';
import '../logic/recommendation_text.dart';
import '../models/app_settings.dart';
import '../models/sensor_reading.dart';
import '../models/water_parameter.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/lang.dart';
import '../widgets/common.dart';
import '../widgets/status_widgets.dart';

class SpeciesDetailScreen extends StatelessWidget {
  const SpeciesDetailScreen({
    super.key,
    required this.recommendation,
    required this.basis,
  });

  final SpeciesRecommendation recommendation;

  /// The reading the recommendation was computed from.
  final SensorReading basis;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings.value;
    final s = recommendation.species;
    final style = StatusStyle.suitability(recommendation.suitability);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: AppColors.deepGreen,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsetsDirectional.only(start: 56, bottom: 14, end: 16),
              title: Text(s.localName,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'species-${s.id}',
                    child: Image.asset(s.imageAsset, fit: BoxFit.cover),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.deepGreen.withValues(alpha: 0.5),
                          Colors.transparent,
                          AppColors.deepGreen.withValues(alpha: 0.9),
                        ],
                        stops: const [0, 0.35, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 56,
                    bottom: 60,
                    child: StatusPill(style, solid: true),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
            sliver: SliverList.list(children: [
              Text('${s.group.emoji} ${s.localName} (${s.commonName})',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink)),
              Text(s.scientificName,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, color: AppColors.muted)),
              const SizedBox(height: 14),
              InfoBanner(
                icon: style.icon,
                color: style.color,
                title: style.label,
                message: RecommendationText.summary(recommendation),
              ),
              SectionTitle(tr('About this species', 'Mahitungod niini')),
              Text(s.displayDescription,
                  style: const TextStyle(
                      fontSize: 16, height: 1.5, color: AppColors.ink)),
              const SizedBox(height: 8),
              Text(s.displayCultureNotes,
                  style: const TextStyle(
                      fontSize: 16, height: 1.5, color: AppColors.muted)),
              SectionTitle(tr('Your pond water vs. what it needs',
                  'Imong tubig kumpara sa kinahanglan niini')),
              Text(
                tr(
                    'Compared with the ${basis.isDemo ? 'demo' : 'sensor'} '
                        'reading from ${Fmt.dateTime(basis.timestamp)}.',
                    'Gikumpara sa ${basis.isDemo ? 'sample' : 'sensor'} nga '
                        'basa niadtong ${Fmt.dateTime(basis.timestamp)}.'),
                style: const TextStyle(color: AppColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 10),
              for (final a in recommendation.assessments) ...[
                _AssessmentCard(assessment: a, settings: settings),
                const SizedBox(height: 10),
              ],
              SectionTitle(tr('Reference', 'Gigikanan')),
              Text(s.reference,
                  style: const TextStyle(color: AppColors.ink, height: 1.4)),
              const SizedBox(height: 6),
              Text(
                tr(
                    'Ranges are reference values for this prototype and should '
                        'be verified with an aquaculture specialist (BFAR).',
                    'Kini nga mga range pananglitan para niining prototype. '
                        'Pangutana gihapon sa eksperto sa BFAR.'),
                style: const TextStyle(color: AppColors.muted, fontSize: 13.5),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({required this.assessment, required this.settings});

  final ParameterAssessment assessment;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final p = assessment.parameter;
    final style = StatusStyle.suitability(assessment.suitability);
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(p.icon, color: AppColors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(p.label,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              StatusPill(style, dense: true),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _cell(tr('Best', 'Sakto'),
                  Fmt.range(p, assessment.requirement.optimal, settings)),
              _cell(tr('Can live in', 'Mabuhi pa'),
                  Fmt.range(p, assessment.requirement.tolerable, settings)),
              _cell(
                tr('Your pond', 'Imong tubig'),
                assessment.value == null
                    ? tr('Not measured', 'Walay basa')
                    : Fmt.number(p, assessment.value!, settings),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(RecommendationText.explain(assessment, settings),
              style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.ink)),
        ],
      ),
    );
  }

  Widget _cell(String label, String value) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
      );
}
