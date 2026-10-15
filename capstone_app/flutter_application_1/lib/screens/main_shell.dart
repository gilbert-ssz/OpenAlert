import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../utils/lang.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'monitoring_screen.dart';
import 'recommendations_screen.dart';
import 'settings_screen.dart';

/// Bottom-navigation container for the five main sections.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static const home = 0;
  static const monitor = 1;
  static const fish = 2;
  static const history = 3;
  static const settings = 4;

  // The screen tree is rebuilt when the language changes (see app.dart).
  // These remember the open tab so the user stays on Settings instead of
  // being sent back to Home.
  static int _lastIndex = home;
  static AppLanguage? _lastLanguage;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    final languageChanged = MainShell._lastLanguage != null &&
        MainShell._lastLanguage != Lang.current;
    _index = languageChanged ? MainShell._lastIndex : MainShell.home;
    MainShell._lastLanguage = Lang.current;
    MainShell._lastIndex = _index;
  }

  void _go(int index) {
    MainShell._lastIndex = index;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Android back button returns to Home before leaving the app.
      canPop: _index == MainShell.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(MainShell.home);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onNavigate: _go),
            const MonitoringScreen(),
            const RecommendationsScreen(),
            const HistoryScreen(),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _go,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: tr('Home', 'Home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.water_drop_outlined),
              selectedIcon: const Icon(Icons.water_drop_rounded),
              label: tr('Water', 'Tubig'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.set_meal_outlined),
              selectedIcon: const Icon(Icons.set_meal_rounded),
              label: tr('Raise', 'Ibuhi'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.show_chart_rounded),
              selectedIcon: const Icon(Icons.insights_rounded),
              label: tr('History', 'Kasaysayan'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: tr('Settings', 'Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
