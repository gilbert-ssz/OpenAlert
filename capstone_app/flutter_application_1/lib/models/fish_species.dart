import '../utils/lang.dart';
import 'water_parameter.dart';

/// Optimal and tolerable ranges of one parameter for one species.
/// Inside [optimal] = suitable; inside [tolerable] only = caution;
/// outside [tolerable] = unsuitable.
class SpeciesRequirement {
  const SpeciesRequirement({required this.optimal, required this.tolerable});

  final ParameterRange optimal;
  final ParameterRange tolerable;
}

/// Kind of animal, used to filter the recommendation list.
enum SpeciesGroup {
  fish('🐟'),
  shrimp('🦐'),
  crab('🦀');

  const SpeciesGroup(this.emoji);

  final String emoji;

  String get label => switch (this) {
        SpeciesGroup.fish => tr('Fish', 'Isda'),
        SpeciesGroup.shrimp => tr('Shrimp', 'Pasayan'),
        SpeciesGroup.crab => tr('Crab', 'Alimango'),
      };
}

/// A species AquaSense can recommend (fish, shrimp or crab).
class FishSpecies {
  const FishSpecies({
    required this.id,
    required this.group,
    required this.commonName,
    required this.localName,
    required this.scientificName,
    required this.imageAsset,
    required this.description,
    required this.descriptionCeb,
    required this.cultureNotes,
    required this.cultureNotesCeb,
    required this.requirements,
    required this.reference,
  });

  final String id;
  final SpeciesGroup group;
  final String commonName;

  /// Name commonly used in the Philippines, e.g. "Bangus".
  final String localName;
  final String scientificName;
  final String imageAsset;
  final String description;

  /// Bisaya (Cebuano) version of [description].
  final String descriptionCeb;
  final String cultureNotes;

  /// Bisaya (Cebuano) version of [cultureNotes].
  final String cultureNotesCeb;
  final Map<WaterParameter, SpeciesRequirement> requirements;

  /// Where the ranges should be verified.
  final String reference;

  String get displayDescription => tr(description, descriptionCeb);

  String get displayCultureNotes => tr(cultureNotes, cultureNotesCeb);
}
