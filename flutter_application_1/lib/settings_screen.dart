import 'package:flutter/material.dart';
import 'config.dart';
import 'door_sensor.dart';

class SettingsScreen extends StatefulWidget {
  final DoorSensor sensor;
  const SettingsScreen({super.key, required this.sensor});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _ipController;
  late bool _demoMode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.sensor.esp32Ip);
    _demoMode = widget.sensor.demoMode;
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _save() {
    final ip = _ipController.text.trim();
    final validIp = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$').hasMatch(ip) &&
        ip.split('.').every((part) => int.parse(part) <= 255);
    if (!validIp) {
      setState(() => _error = 'Enter a valid ESP32 IPv4 address.');
      return;
    }

    setState(() => _error = null);
    widget.sensor.configure(ip: ip, useDemoMode: _demoMode);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved; checking connection.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        TextField(
          controller: _ipController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'ESP32 IP address',
            hintText: defaultEsp32Ip,
            errorText: _error,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Demo mode'),
          subtitle: const Text('Turn off to connect to the real ESP32'),
          value: _demoMode,
          onChanged: (value) => setState(() => _demoMode = value),
          activeTrackColor: AppColors.blue,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save settings'),
        ),
      ],
    );
  }
}
