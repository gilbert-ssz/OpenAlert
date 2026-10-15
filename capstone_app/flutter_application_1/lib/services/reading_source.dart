import '../models/sensor_reading.dart';

/// Anything that can supply the latest water-quality reading.
/// Implemented by [DemoReadingSource] and [Esp32HttpSource]; add another
/// implementation (e.g. Bluetooth or MQTT) without changing the UI.
abstract class ReadingSource {
  Future<SensorReading> fetchLatest();
}

class ReadingSourceException implements Exception {
  const ReadingSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}
