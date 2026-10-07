import 'package:flutter/material.dart';
import '../config.dart';
import '../door_sensor.dart';

class HomeScreen extends StatelessWidget {
  final DoorSensor sensor;
  final void Function(int) goTo;
  const HomeScreen({super.key, required this.sensor, required this.goTo});

  @override
  Widget build(BuildContext context) {
    final open = sensor.doorOpen;
    final color = open ? AppColors.red : AppColors.green;
    final last = sensor.log.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('OpenAlert',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              _badge(open ? 'TRIGGERED' : 'ACTIVE', color),
            ],
          ),
          const SizedBox(height: 20),

          // Door status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: open ? AppColors.red : AppColors.border),
            ),
            child: Column(
              children: [
                const Text('Front door',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 16),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, border: Border.all(color: color, width: 5)),
                ),
                const SizedBox(height: 16),
                Text(open ? 'OPEN' : 'CLOSED',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(open ? 'Your door was just opened.' : 'Your door is currently secure.',
                    style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ESP32 / Sensor status
          Row(children: [
            Expanded(child: _chip(sensor.connected ? '● ESP32 connected' : '○ ESP32 offline')),
            const SizedBox(width: 10),
            Expanded(child: _chip(sensor.connected ? '● Sensor online' : '○ Sensor offline')),
          ]),
          const SizedBox(height: 14),

          // Last activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Last activity', style: TextStyle(color: AppColors.muted)),
              Text('${last.text} — ${last.time}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),

          // Quick actions
          const Text('Quick actions', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _action(Icons.show_chart, 'Activity', () => goTo(1), active: true)),
            const SizedBox(width: 10),
            Expanded(child: _action(Icons.notifications_none, 'Test alert', sensor.testAlert)),
            const SizedBox(width: 10),
            Expanded(child: _action(Icons.tune, 'Settings', () => goTo(3))),
          ]),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), border: Border.all(color: color)),
        child: Text(text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      );

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      );

  Widget _action(IconData icon, String text, VoidCallback onTap, {bool active = false}) {
    final c = active ? AppColors.blue : AppColors.muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? AppColors.blue : AppColors.border),
        ),
        child: Column(children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(height: 6),
          Text(text, style: TextStyle(color: c, fontSize: 12)),
        ]),
      ),
    );
  }
}