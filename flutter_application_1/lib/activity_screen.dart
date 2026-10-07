import 'package:flutter/material.dart';
import '../config.dart';
import '../door_sensor.dart';

class ActivityScreen extends StatelessWidget {
  final DoorSensor sensor;
  const ActivityScreen({super.key, required this.sensor});

  // Kolor sa dot sa timeline
  Color _dotColor(String type) {
    if (type == 'alert') return AppColors.red;
    if (type == 'ok') return AppColors.green;
    return AppColors.muted;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Activity log',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            if (sensor.triggered)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.red)),
                child: const Text('TRIGGERED',
                    style: TextStyle(
                        color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Red alert card (makita ra kung naay alert)
        if (sensor.triggered)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.red, width: 1.5),
            ),
            child: Column(children: [
              const Text('Security alert',
                  style: TextStyle(
                      color: AppColors.red, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              const Text('DOOR OPEN',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text('Your front door was opened — ${sensor.log.first.time}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13)),
            ]),
          ),

        // Timeline
        const Text('Timeline', style: TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 12),
        for (final item in sensor.log)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(top: 5, right: 12),
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: _dotColor(item.type), shape: BoxShape.circle),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.text,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Today, ${item.time}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ]),
            ]),
          ),

        // Buttons (makita ra kung naay alert)
        if (sensor.triggered) ...[
          const SizedBox(height: 12),
          FilledButton(
            onPressed: sensor.acknowledge,
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Acknowledge alert'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: sensor.silenceBuzzer,
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.muted,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Silence buzzer'),
          ),
        ],
      ],
    );
  }
}