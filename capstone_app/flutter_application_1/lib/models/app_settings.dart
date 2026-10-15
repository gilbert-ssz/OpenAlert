enum DataMode { demo, esp32 }

enum TemperatureUnit { celsius, fahrenheit }

enum SalinityDisplay { ppt, conductivity }

/// Display language. Bisaya (Cebuano) is offered because most fishpond
/// owners in the target area read it more easily than English.
enum AppLanguage { english, bisaya }

/// App-wide text size, applied on top of the phone's own font setting.
enum TextSize {
  normal(1.0),
  large(1.15),
  extraLarge(1.3);

  const TextSize(this.scale);

  final double scale;
}

class AppSettings {
  const AppSettings({
    this.dataMode = DataMode.demo,
    this.esp32Address = '192.168.4.1',
    this.autoRefreshSeconds = 30,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.salinityDisplay = SalinityDisplay.ppt,
    this.pondName = 'My Fishpond',
    this.language = AppLanguage.english,
    this.textSize = TextSize.large,
  });

  final DataMode dataMode;

  /// IP address or host (optionally with port) of the ESP32 sensor node.
  final String esp32Address;

  /// 0 disables automatic refresh.
  final int autoRefreshSeconds;
  final TemperatureUnit temperatureUnit;
  final SalinityDisplay salinityDisplay;
  final String pondName;
  final AppLanguage language;

  /// Defaults to large because many pond owners are older adults.
  final TextSize textSize;

  AppSettings copyWith({
    DataMode? dataMode,
    String? esp32Address,
    int? autoRefreshSeconds,
    TemperatureUnit? temperatureUnit,
    SalinityDisplay? salinityDisplay,
    String? pondName,
    AppLanguage? language,
    TextSize? textSize,
  }) =>
      AppSettings(
        dataMode: dataMode ?? this.dataMode,
        esp32Address: esp32Address ?? this.esp32Address,
        autoRefreshSeconds: autoRefreshSeconds ?? this.autoRefreshSeconds,
        temperatureUnit: temperatureUnit ?? this.temperatureUnit,
        salinityDisplay: salinityDisplay ?? this.salinityDisplay,
        pondName: pondName ?? this.pondName,
        language: language ?? this.language,
        textSize: textSize ?? this.textSize,
      );
}
