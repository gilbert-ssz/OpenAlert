import 'package:flutter/widgets.dart';

import 'controllers/auth_controller.dart';
import 'controllers/monitoring_controller.dart';
import 'controllers/settings_controller.dart';

/// Makes the app-wide controllers available to every screen.
/// Widgets rebuild by listening to the controllers themselves.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.settings,
    required this.auth,
    required this.monitoring,
    required super.child,
  });

  final SettingsController settings;
  final AuthController auth;
  final MonitoringController monitoring;

  static AppScope of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      settings != oldWidget.settings ||
      auth != oldWidget.auth ||
      monitoring != oldWidget.monitoring;
}
