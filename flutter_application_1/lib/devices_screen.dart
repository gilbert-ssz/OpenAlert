import 'package:flutter/material.dart';
import 'config.dart';
import 'door_sensor.dart';

class DevicesScreen extends StatelessWidget {
  final DoorSensor sensor;
  const DevicesScreen({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    final statusColor = sensor.connected ? AppColors.green : AppColors.red;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Devices',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.memory, color: AppColors.blue),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('ESP32 door sensor',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                Icon(Icons.circle, size: 10, color: statusColor),
                const SizedBox(width: 6),
                Text(sensor.connected ? 'Online' : 'Offline',
                    style: TextStyle(color: statusColor, fontSize: 12)),
              ]),
              const SizedBox(height: 14),
              Text('Address: ${sensor.esp32Ip}',
                  style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 4),
              Text(sensor.demoMode ? 'Demo mode' : 'Live connection',
                  style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Check connection',
                  onPressed: sensor.checkNow,
                  icon: const Icon(Icons.refresh),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
