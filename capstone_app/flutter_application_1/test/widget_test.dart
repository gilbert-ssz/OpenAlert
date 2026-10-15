import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/app.dart';
import 'package:flutter_application_1/config/species_data.dart';
import 'package:flutter_application_1/controllers/monitoring_controller.dart';
import 'package:flutter_application_1/logic/recommendation_engine.dart';
import 'package:flutter_application_1/logic/water_quality.dart';
import 'package:flutter_application_1/models/app_settings.dart';
import 'package:flutter_application_1/models/fish_species.dart';
import 'package:flutter_application_1/models/sensor_reading.dart';
import 'package:flutter_application_1/models/water_parameter.dart';
import 'package:flutter_application_1/services/esp32_http_source.dart';
import 'package:flutter_application_1/utils/lang.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

SensorReading reading({double? temp, double? ph, double? sal}) => SensorReading(
      timestamp: DateTime(2026, 1, 1, 12),
      origin: ReadingOrigin.sensor,
      temperatureC: temp,
      ph: ph,
      salinityPpt: sal,
    );

void main() {
  group('WaterQuality', () {
    test('classifies temperature and pH', () {
      expect(WaterQuality.statusFor(WaterParameter.temperature, 28),
          ParameterStatus.good);
      expect(WaterQuality.statusFor(WaterParameter.temperature, 33.5),
          ParameterStatus.caution);
      expect(WaterQuality.statusFor(WaterParameter.ph, 5.0),
          ParameterStatus.critical);
      expect(WaterQuality.overall(reading(temp: 28, ph: 9.2)),
          ParameterStatus.caution);
      expect(WaterQuality.overall(reading()), ParameterStatus.unknown);
    });
  });

  group('RecommendationEngine', () {
    final tilapia = kFishSpecies.firstWhere((s) => s.id == 'tilapia');
    final milkfish = kFishSpecies.firstWhere((s) => s.id == 'milkfish');

    test('fresh water favors tilapia over milkfish', () {
      final r = reading(temp: 28, ph: 7.8, sal: 2);
      expect(RecommendationEngine.evaluateSpecies(tilapia, r).suitability,
          Suitability.suitable);
      expect(RecommendationEngine.evaluateSpecies(milkfish, r).suitability,
          Suitability.caution);
    });

    test('high salinity makes tilapia unsuitable', () {
      final r = reading(temp: 28, ph: 8, sal: 25);
      expect(RecommendationEngine.evaluateSpecies(tilapia, r).suitability,
          Suitability.unsuitable);
      expect(RecommendationEngine.evaluateSpecies(milkfish, r).suitability,
          Suitability.suitable);
    });

    test('missing values are not evaluated', () {
      final rec = RecommendationEngine.evaluateSpecies(tilapia, reading(temp: 28));
      expect(rec.suitability, Suitability.suitable);
      expect(rec.measured.length, 1);
      expect(RecommendationEngine.evaluateSpecies(tilapia, reading()).suitability,
          Suitability.unknown);
    });

    test('results are sorted best first', () {
      final recs = RecommendationEngine.evaluate(reading(temp: 28, ph: 8, sal: 20));
      for (var i = 1; i < recs.length; i++) {
        expect(recs[i - 1].suitability.index <= recs[i].suitability.index, isTrue);
      }
    });
  });

  group('Esp32HttpSource', () {
    test('parses JSON and drops implausible values', () {
      final r = Esp32HttpSource.parse(
        {'temperature': -127, 'ph': '7.4', 'conductivity': 15625},
        DateTime(2026),
      );
      expect(r.temperatureC, isNull); // disconnected DS18B20
      expect(r.ph, 7.4);
      expect(r.isSalinityEstimated, isTrue);
      expect(r.salinityForEvaluation, closeTo(10, 0.01));
      expect(r.isDemo, isFalse);
    });

    test('builds endpoint from address', () {
      expect(Esp32HttpSource.buildEndpoint('192.168.1.50:8080').toString(),
          'http://192.168.1.50:8080/readings');
      expect(Esp32HttpSource.isValidAddress('bad address'), isFalse);
    });
  });

  testWidgets('shows login, continues as guest, and opens every tab',
      (tester) async {
    // Typical Android phone: 393 x 851 logical pixels.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AquaSenseApp());
    await tester.pumpAndSettle();

    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);

    // Validation errors on empty submit.
    await tester.tap(find.text('Log In'));
    await tester.pump();
    expect(find.text('Please enter your email.'), findsOneWidget);

    await tester.ensureVisible(find.text('Continue as Guest'));
    await tester.tap(find.text('Continue as Guest'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Demo Mode'), findsWidgets);
    expect(find.text('Overall Water Condition'), findsOneWidget);
    expect(find.text('Demo Mode - sample data'), findsOneWidget);

    // Visit every tab; any layout overflow would fail the test.
    for (final tab in ['Water', 'Raise', 'History', 'Settings', 'Home']) {
      await tester.tap(find.text(tab).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.tap(find.text('Raise').last);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Suitable'), findsWidgets);

    // Open a species detail page.
    final list = find.byType(Scrollable).hitTestable().first;
    for (var i = 0; i < 10 && find.text('View details').evaluate().isEmpty; i++) {
      await tester.drag(list, const Offset(0, -300));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('View details').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View details').first);
    await tester.pumpAndSettle();
    expect(find.text('About this species'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('History').last);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('readings stored on this device'), findsOneWidget);

    // Dispose the app so timers are cancelled.
    await tester.pumpWidget(const SizedBox());
  });

  group('ESP32 mode', () {
    final esp32Prefs = <String, Object>{
      'settings_v1_mode': 'esp32',
      'auth_session_v1': '{"name":"Ana","email":null}',
    };

    testWidgets('shows live readings when the sensor responds', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues(esp32Prefs);
      final client = MockClient((req) async {
        expect(req.url.path, '/readings');
        return http.Response(
            '{"temperature": 29.1, "ph": 7.9, "salinity": 12.0}', 200);
      });
      await tester.pumpWidget(AquaSenseApp(
          monitoring: MonitoringController(httpClient: client)));
      await tester.pumpAndSettle();

      expect(find.text('Connected'), findsOneWidget);
      expect(find.textContaining('29.1', findRichText: true), findsWidgets);
      expect(find.text('Demo Mode - sample data'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('shows Disconnected and never fake values on failure',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues(esp32Prefs);
      final client = MockClient(
          (_) async => throw const SocketException('Network unreachable'));
      await tester.pumpWidget(AquaSenseApp(
          monitoring: MonitoringController(httpClient: client)));
      await tester.pumpAndSettle();

      expect(find.text('Disconnected'), findsOneWidget);
      expect(find.text('Sensor node disconnected'), findsOneWidget);
      expect(find.text('No Data'), findsOneWidget);
      expect(find.text('Demo Mode - sample data'), findsNothing);
      expect(find.text('Sensor unavailable'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('Shrimp and crab', () {
    SpeciesRecommendation rec(String id, SensorReading r) =>
        RecommendationEngine.evaluateSpecies(
            kFishSpecies.firstWhere((s) => s.id == id), r);

    test('species list includes shrimp and crab', () {
      final groups = kFishSpecies.map((s) => s.group).toSet();
      expect(groups, containsAll(SpeciesGroup.values));
      expect(kFishSpecies.map((s) => s.id),
          containsAll(['tiger_prawn', 'vannamei', 'mud_crab']));
    });

    test('brackish water suits prawn and crab, fresh water does not', () {
      final brackish = reading(temp: 29, ph: 8, sal: 20);
      expect(rec('tiger_prawn', brackish).suitability, Suitability.suitable);
      expect(rec('mud_crab', brackish).suitability, Suitability.suitable);
      expect(rec('vannamei', brackish).suitability, Suitability.suitable);

      final fresh = reading(temp: 29, ph: 7.5, sal: 0.2);
      expect(rec('tiger_prawn', fresh).suitability, Suitability.unsuitable);
      expect(rec('mud_crab', fresh).suitability, Suitability.unsuitable);
    });
  });

  group('Advice', () {
    test('gives practical steps only when needed', () {
      expect(WaterQuality.advice(reading(temp: 28, ph: 7.5, sal: 10)), isEmpty);
      final hotAcidic = WaterQuality.advice(reading(temp: 34, ph: 6.0, sal: 10));
      expect(hotAcidic.length, 3); // heat, low pH, check again
      expect(hotAcidic.first, contains('hot'));
    });

    test('speaks Bisaya when selected', () {
      Lang.current = AppLanguage.bisaya;
      addTearDown(() => Lang.current = AppLanguage.english);
      expect(WaterQuality.advice(reading(temp: 34, ph: 7.5, sal: 10)).first,
          contains('Init ang tubig'));
      expect(WaterQuality.overallTitle(ParameterStatus.good), 'Maayo');
    });
  });

  testWidgets('Bisaya with the largest text fits on a phone', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    addTearDown(() => Lang.current = AppLanguage.english);
    SharedPreferences.setMockInitialValues({
      'settings_v1_language': 'bisaya',
      'settings_v1_textSize': 'extraLarge',
      'auth_session_v1': '{"name":"Lola Nena","email":null}',
    });
    await tester.pumpWidget(const AquaSenseApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Kahimtang sa Tubig'), findsOneWidget);
    expect(find.textContaining('Maayong'), findsWidgets); // greeting

    // Visit every tab; any layout overflow would fail the test.
    for (final tab in ['Tubig', 'Ibuhi', 'Kasaysayan', 'Settings', 'Home']) {
      await tester.tap(find.text(tab).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    // Filter to crabs only.
    await tester.tap(find.text('Ibuhi').last);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.textContaining('Alimango').first);
    await tester.pump(const Duration(milliseconds: 500));
    final list = find.byType(Scrollable).hitTestable().first;
    for (var i = 0; i < 10 && find.textContaining('Mud Crab').evaluate().isEmpty; i++) {
      await tester.drag(list, const Offset(0, -300));
      await tester.pump();
    }
    expect(find.textContaining('Mud Crab'), findsWidgets);
    expect(find.textContaining('Bangus'), findsNothing);
    await tester.drag(list, const Offset(0, 3000));
    await tester.pump();

    // Switching language keeps the user on the Settings tab.
    await tester.tap(find.text('Settings').last);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('English').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Language & Text Size'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
