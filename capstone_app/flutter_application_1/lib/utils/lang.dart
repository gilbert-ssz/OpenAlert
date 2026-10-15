import '../models/app_settings.dart';

/// The language currently shown. Set by the app root from the settings;
/// the whole screen tree is rebuilt when it changes (see app.dart), so
/// widgets can simply call [tr] while building.
class Lang {
  Lang._();

  static AppLanguage current = AppLanguage.english;

  static bool get isBisaya => current == AppLanguage.bisaya;
}

/// Returns the English or the Bisaya (Cebuano) version of a text.
String tr(String en, String ceb) => Lang.isBisaya ? ceb : en;
