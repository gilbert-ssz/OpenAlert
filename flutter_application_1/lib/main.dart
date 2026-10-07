import 'package:flutter/material.dart';
import 'config.dart';
import 'door_sensor.dart';
import 'home_screen.dart';
import 'activity_screen.dart';
import 'devices_screen.dart';
import 'settings_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenAlert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: AppColors.bg),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final sensor = DoorSensor(); // ang data gikan sa sensor naa dinhi
  int tab = 0; // 0=Home 1=Activity 2=Devices 3=Settings

  @override
  void initState() {
    super.initState();
    // Kung naay alert, ablihi dayon ang Activity screen
    sensor.addListener(() {
      if (sensor.triggered && tab != 1) setState(() => tab = 1);
    });
  }

  @override
  void dispose() {
    sensor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: sensor, // mo-update ang screen kung naay usab
          builder: (context, _) {
            if (tab == 0) {
              return HomeScreen(sensor: sensor, goTo: (i) => setState(() => tab = i));
            }
            if (tab == 1) return ActivityScreen(sensor: sensor);
            if (tab == 2) return DevicesScreen(sensor: sensor);
            return SettingsScreen(sensor: sensor);
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.bg,
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.memory), label: 'Devices'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}