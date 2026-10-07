import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('screens share sensor state and navigation', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Front door'), findsOneWidget);
    expect(find.text('CLOSED'), findsOneWidget);

    await tester.ensureVisible(find.text('Test alert'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test alert'));
    await tester.pumpAndSettle();
    expect(find.text('Activity log'), findsOneWidget);
    expect(find.text('DOOR OPEN'), findsOneWidget);

    await tester.tap(find.text('Acknowledge alert'));
    await tester.pumpAndSettle();
    expect(find.text('DOOR OPEN'), findsNothing);

    await tester.tap(find.byIcon(Icons.memory));
    await tester.pumpAndSettle();
    expect(find.text('ESP32 door sensor'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('ESP32 IP address'), findsOneWidget);
    expect(find.text('Demo mode'), findsOneWidget);
  });
}
