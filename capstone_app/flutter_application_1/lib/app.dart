import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'controllers/auth_controller.dart';
import 'controllers/monitoring_controller.dart';
import 'controllers/settings_controller.dart';
import 'screens/main_shell.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'utils/lang.dart';
import 'widgets/common.dart';

class AquaSenseApp extends StatefulWidget {
  const AquaSenseApp({super.key, this.monitoring});

  /// Injectable for tests.
  final MonitoringController? monitoring;

  @override
  State<AquaSenseApp> createState() => _AquaSenseAppState();
}

class _AquaSenseAppState extends State<AquaSenseApp> {
  final _settings = SettingsController();
  final _auth = AuthController();
  late final MonitoringController _monitoring =
      widget.monitoring ?? MonitoringController();
  late final Future<void> _ready = _initialize();

  Future<void> _initialize() async {
    await _settings.load();
    await _auth.load();
    await _monitoring.init(_settings.value);
    _settings.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() => _monitoring.applySettings(_settings.value);

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    _settings.dispose();
    _auth.dispose();
    _monitoring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      settings: _settings,
      auth: _auth,
      monitoring: _monitoring,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) {
          final settings = _settings.value;
          Lang.current = settings.language;
          return MaterialApp(
            title: 'AquaSense',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            // Bigger text for older users, on top of the phone's own setting.
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              final scale = mq.textScaler.scale(1) * settings.textSize.scale;
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: TextScaler.linear(scale)
                      .clamp(maxScaleFactor: 2.0),
                ),
                child: child!,
              );
            },
            home: FutureBuilder<void>(
              future: _ready,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const _SplashScreen();
                }
                if (snapshot.hasError) {
                  return _StartupError(error: snapshot.error.toString());
                }
                // Rebuild every screen from scratch when the language
                // changes so no text is left in the old language.
                return KeyedSubtree(
                  key: ValueKey(settings.language),
                  child: const _AuthGate(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Shows the login flow or the main app depending on the session.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) =>
          auth.session == null ? const WelcomeScreen() : const MainShell(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PhotoBackground(
        image: AppImages.welcome,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AquaSenseLogo(size: 88),
              SizedBox(height: 28),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StateMessage(
            icon: Icons.error_outline_rounded,
            color: AppColors.critical,
            title: tr('AquaSense could not start',
                'Wala ma-abli ang AquaSense'),
            message: error,
          ),
        ),
      ),
    );
  }
}
