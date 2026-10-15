import '../models/app_settings.dart';
import '../models/water_parameter.dart';
import '../utils/formatters.dart';
import '../utils/lang.dart';
import 'recommendation_engine.dart';

/// Turns rule results into plain-language explanations.
class RecommendationText {
  RecommendationText._();

  static String explain(ParameterAssessment a, AppSettings s) {
    final name = a.parameter.label;
    final opt = Fmt.range(a.parameter, a.requirement.optimal, s);
    final tol = Fmt.range(a.parameter, a.requirement.tolerable, s);
    final v = a.value == null ? '' : Fmt.number(a.parameter, a.value!, s);
    return switch (a.relation) {
      RangeRelation.withinOptimal => tr(
          '$name $v is within the best range ($opt).',
          '$name $v - sakto ($opt).'),
      RangeRelation.belowOptimal => tr(
          '$name $v is a bit low. Best is $opt, but it can still live in '
              '$tol.',
          '$name $v - medyo ubos. Ang sakto $opt, apan mabuhi pa gihapon '
              'sa $tol.'),
      RangeRelation.aboveOptimal => tr(
          '$name $v is a bit high. Best is $opt, but it can still live in '
              '$tol.',
          '$name $v - medyo taas. Ang sakto $opt, apan mabuhi pa gihapon '
              'sa $tol.'),
      RangeRelation.belowTolerable => tr(
          '$name $v is too low. It can only live in $tol.',
          '$name $v - ubos kaayo. Mabuhi ra kini sa $tol.'),
      RangeRelation.aboveTolerable => tr(
          '$name $v is too high. It can only live in $tol.',
          '$name $v - taas kaayo. Mabuhi ra kini sa $tol.'),
      RangeRelation.notMeasured => tr(
          '$name was not measured, so it was not checked.',
          'Walay basa sa $name, busa wala kini masusi.'),
    };
  }

  static String summary(SpeciesRecommendation r) {
    final name = r.species.localName;
    String names(Iterable<ParameterAssessment> list) =>
        _join(list.map((a) => a.parameter.label.toLowerCase()).toList());

    final missing = r.assessments
        .where((a) => a.relation == RangeRelation.notMeasured)
        .length;
    final note = missing == 0
        ? ''
        : tr(
            ' ($missing reading${missing == 1 ? ' was' : 's were'} missing.)',
            ' ($missing ka basa ang wala.)');

    switch (r.suitability) {
      case Suitability.suitable:
        return tr('Good choice. Your water is right for $name.$note',
            'Maayo nga ibuhi. Sakto ang imong tubig para sa $name.$note');
      case Suitability.caution:
        final off =
            r.assessments.where((a) => a.suitability == Suitability.caution);
        return tr(
            '$name can live here, but the ${names(off)} '
                '${off.length == 1 ? 'is' : 'are'} not the best. '
                'It may grow slower - watch it closely.$note',
            'Mabuhi ang $name dinhi, apan dili sakto ang ${names(off)}. '
                'Basin mahinay ang pagdako - bantayi pag-ayo.$note');
      case Suitability.unsuitable:
        final off = r.assessments
            .where((a) => a.suitability == Suitability.unsuitable);
        return tr(
            'Not recommended. The ${names(off)} '
                '${off.length == 1 ? 'is' : 'are'} not safe for $name.$note',
            'Dili angay. Ang ${names(off)} dili luwas para sa $name.$note');
      case Suitability.unknown:
        return tr('Not enough readings to check $name.',
            'Kulang ang basa aron masusi ang $name.');
    }
  }

  static String _join(List<String> items) {
    if (items.length <= 1) return items.join();
    final and = tr('and', 'ug');
    return '${items.sublist(0, items.length - 1).join(', ')} $and ${items.last}';
  }
}
