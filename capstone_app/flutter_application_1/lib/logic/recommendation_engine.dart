import '../config/species_data.dart';
import '../models/fish_species.dart';
import '../models/sensor_reading.dart';
import '../models/water_parameter.dart';

enum Suitability { suitable, caution, unsuitable, unknown }

/// How a measured value relates to a species' ranges.
enum RangeRelation {
  withinOptimal,
  belowOptimal,
  aboveOptimal,
  belowTolerable,
  aboveTolerable,
  notMeasured,
}

class ParameterAssessment {
  const ParameterAssessment({
    required this.parameter,
    required this.requirement,
    required this.value,
    required this.relation,
  });

  final WaterParameter parameter;
  final SpeciesRequirement requirement;
  final double? value;
  final RangeRelation relation;

  Suitability get suitability => switch (relation) {
        RangeRelation.withinOptimal => Suitability.suitable,
        RangeRelation.belowOptimal ||
        RangeRelation.aboveOptimal =>
          Suitability.caution,
        RangeRelation.belowTolerable ||
        RangeRelation.aboveTolerable =>
          Suitability.unsuitable,
        RangeRelation.notMeasured => Suitability.unknown,
      };
}

class SpeciesRecommendation {
  const SpeciesRecommendation({
    required this.species,
    required this.suitability,
    required this.assessments,
  });

  final FishSpecies species;
  final Suitability suitability;
  final List<ParameterAssessment> assessments;

  int get optimalCount => assessments
      .where((a) => a.relation == RangeRelation.withinOptimal)
      .length;

  List<ParameterAssessment> get measured => assessments
      .where((a) => a.relation != RangeRelation.notMeasured)
      .toList();
}

/// Rule-based recommender: compares a reading with each species' optimal
/// and tolerable ranges from species_data.dart.
class RecommendationEngine {
  RecommendationEngine._();

  static RangeRelation relate(double? value, SpeciesRequirement req) {
    if (value == null) return RangeRelation.notMeasured;
    if (req.optimal.contains(value)) return RangeRelation.withinOptimal;
    if (req.tolerable.contains(value)) {
      return value < req.optimal.min
          ? RangeRelation.belowOptimal
          : RangeRelation.aboveOptimal;
    }
    return value < req.tolerable.min
        ? RangeRelation.belowTolerable
        : RangeRelation.aboveTolerable;
  }

  static SpeciesRecommendation evaluateSpecies(
      FishSpecies species, SensorReading? reading) {
    final assessments = <ParameterAssessment>[];
    species.requirements.forEach((parameter, req) {
      final value = reading?.valueOf(parameter);
      assessments.add(ParameterAssessment(
        parameter: parameter,
        requirement: req,
        value: value,
        relation: relate(value, req),
      ));
    });

    final levels = assessments
        .map((a) => a.suitability)
        .where((s) => s != Suitability.unknown)
        .toSet();
    final Suitability overall;
    if (levels.isEmpty) {
      overall = Suitability.unknown;
    } else if (levels.contains(Suitability.unsuitable)) {
      overall = Suitability.unsuitable;
    } else if (levels.contains(Suitability.caution)) {
      overall = Suitability.caution;
    } else {
      overall = Suitability.suitable;
    }
    return SpeciesRecommendation(
      species: species,
      suitability: overall,
      assessments: assessments,
    );
  }

  /// Evaluates every species and sorts best matches first.
  static List<SpeciesRecommendation> evaluate(
    SensorReading? reading, {
    List<FishSpecies> species = kFishSpecies,
  }) {
    final results =
        species.map((s) => evaluateSpecies(s, reading)).toList();
    results.sort((a, b) {
      final byLevel = a.suitability.index.compareTo(b.suitability.index);
      if (byLevel != 0) return byLevel;
      return b.optimalCount.compareTo(a.optimalCount);
    });
    return results;
  }
}
