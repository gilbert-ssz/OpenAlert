# AquaSense

**AquaSense: An IoT-Based Fishpond Water Quality and Salinity Monitoring System
with Mobile Application for Fish Species Recommendation** - Android app (Flutter).

## Run on an Android phone

1. On the phone: Settings → About phone → tap **Build number** 7 times, then
   Settings → Developer options → enable **USB debugging**.
2. Connect the phone by USB and accept the "Allow USB debugging?" prompt.
3. In a terminal opened in this folder:

```
flutter pub get
flutter devices          # the phone should be listed
flutter run              # debug build with hot reload
```

To install a standalone APK: `flutter build apk --release`, then copy
`build/app/outputs/flutter-apk/app-release.apk` to the phone.

Run the tests with `flutter test`.

## Project structure

```
lib/
  main.dart, app.dart, app_scope.dart   entry point, theme, login gate
  config/species_data.dart              fish species + water ranges (edit here)
  config/water_thresholds.dart          general pond thresholds, salinity classes
  controllers/                          settings, local auth, monitoring state
  logic/                                water quality + rule-based recommendations
  models/                               SensorReading, FishSpecies, AppSettings
  services/esp32_http_source.dart       ESP32 integration (HTTP JSON contract)
  services/demo_reading_source.dart     clearly-labelled demo data
  services/history_store.dart           offline history (shared_preferences)
  screens/                              Welcome, Register, Home, Monitor, Fish,
                                        Species detail, History, Settings, Credits
  widgets/                              reusable cards, headers, gauge, chart
assets/images/                          fishpond and fish photographs
assets/data/image_credits.json          photo authors and licenses
```

## Data sources

- **Demo Mode** (default): simulated readings, always labelled "Demo".
- **ESP32 Sensor**: the app polls `GET http://<esp32-ip>/readings` over local
  Wi-Fi and expects JSON like
  `{"temperature": 28.4, "ph": 7.6, "salinity": 6.1, "conductivity": 9500}`.
  Any field may be omitted or null. See `lib/services/esp32_http_source.dart`.
  Remote (internet) monitoring is not included in this version.

## Fish recommendation ranges

The ranges in `lib/config/species_data.dart` are starting reference values.
Verify them with BFAR, SEAFDEC/AQD or FAO sources before relying on them.

## Photo credits

All photographs come from Wikimedia Commons under public-domain or Creative
Commons licenses. Authors and licenses are listed in
`assets/data/image_credits.json` and in the app under Settings → About →
Photo credits & licenses.
