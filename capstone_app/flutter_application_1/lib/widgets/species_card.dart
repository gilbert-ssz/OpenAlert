import 'package:flutter/material.dart';

import '../logic/recommendation_engine.dart';
import '../logic/recommendation_text.dart';
import '../models/app_settings.dart';
import '../models/water_parameter.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/lang.dart';
import 'status_widgets.dart';

/// Photo card for one recommended species.
class SpeciesCard extends StatelessWidget {
  const SpeciesCard({
    super.key,
    required this.recommendation,
    required this.settings,
    required this.onTap,
  });

  final SpeciesRecommendation recommendation;
  final AppSettings settings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = recommendation.species;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 170,
                child: Stack(
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
                            Colors.transparent,
                            AppColors.deepGreen.withValues(alpha: 0.85),
                          ],
                          stops: const [0.35, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: StatusPill(
                        StatusStyle.suitability(recommendation.suitability),
                        solid: true,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.group.emoji} ${s.localName} (${s.commonName})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            s.scientificName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.displayDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final a in recommendation.assessments)
                          _RequirementChip(assessment: a, settings: settings),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded,
                            size: 18, color: AppColors.teal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            RecommendationText.summary(recommendation),
                            style: const TextStyle(
                                color: AppColors.ink, height: 1.4, fontSize: 15.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(tr('View details', 'Tan-awa ang detalye')),
                        iconAlignment: IconAlignment.end,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementChip extends StatelessWidget {
  const _RequirementChip({required this.assessment, required this.settings});

  final ParameterAssessment assessment;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.suitability(assessment.suitability);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(assessment.parameter.icon, size: 15, color: style.color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              '${assessment.parameter.shortLabel} '
              '${Fmt.range(assessment.parameter, assessment.requirement.optimal, settings)}',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small photo tile for horizontal lists (Home "Top fish picks").
class SpeciesMiniCard extends StatelessWidget {
  const SpeciesMiniCard({super.key, required this.recommendation, required this.onTap});

  final SpeciesRecommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = recommendation.species;
    return SizedBox(
      width: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(s.imageAsset, fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.deepGreen.withValues(alpha: 0.9),
                      ],
                      stops: const [0.3, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${s.group.emoji} ${s.localName}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      StatusPill(StatusStyle.suitability(recommendation.suitability),
                          solid: true, dense: true),
                    ],
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
