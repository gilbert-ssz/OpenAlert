import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/sensor_reading.dart';
import 'reading_source.dart';

/// Reads live values from the ESP32 sensor node over local Wi-Fi (HTTP).
///
/// ## Integration contract for the firmware team
///
/// The phone and the ESP32 must be on the same Wi-Fi network (or the phone
/// joined to the ESP32's own access point, default IP 192.168.4.1).
/// The ESP32 should serve:
///
///     GET http://<esp32-ip>/readings
///
/// returning JSON such as:
///
///     {
///       "temperature": 28.4,     // °C, e.g. DS18B20 (-127 = disconnected)
///       "ph": 7.62,              // 0-14
///       "salinity": 6.1,         // ppt (optional)
///       "conductivity": 9500     // µS/cm (optional)
///     }
///
/// Any field may be omitted or null when that sensor is not installed or
/// failed; the app will show "Sensor unavailable" for it. Provide at least
/// one of `salinity` or `conductivity` for the salinity reading.
///
/// This works only on the local network. Remote monitoring from anywhere
/// would need a cloud relay (e.g. MQTT broker or a database), which is
/// intentionally NOT part of this version.
class Esp32HttpSource implements ReadingSource {
  Esp32HttpSource({
    required String address,
    required this.client,
    this.timeout = const Duration(seconds: 5),
  }) : endpoint = buildEndpoint(address);

  static const readingsPath = '/readings';

  final Uri endpoint;
  final Duration timeout;
  final http.Client client;

  /// Accepts "192.168.4.1", "192.168.1.50:8080" or "http://host/".
  static Uri buildEndpoint(String address) {
    var a = address.trim();
    if (a.isEmpty) a = '192.168.4.1';
    if (!a.startsWith('http://') && !a.startsWith('https://')) {
      a = 'http://$a';
    }
    final base = Uri.tryParse(a);
    if (base == null || base.host.isEmpty) {
      // Unusable input: requests fail with a clear "cannot reach" error.
      return Uri(scheme: 'http', host: 'invalid-address', path: readingsPath);
    }
    return base.replace(path: readingsPath);
  }

  static bool isValidAddress(String address) =>
      address.trim().isNotEmpty &&
      buildEndpoint(address).host != 'invalid-address' &&
      !address.trim().contains(' ');

  @override
  Future<SensorReading> fetchLatest() async {
    final http.Response response;
    try {
      response = await client.get(endpoint).timeout(timeout);
    } on TimeoutException {
      throw ReadingSourceException(
          'No response from the sensor node at ${endpoint.authority} '
          'within ${timeout.inSeconds} s.');
    } on SocketException catch (e) {
      throw ReadingSourceException(
          'Cannot reach ${endpoint.authority}. Make sure the phone is on the '
          'same Wi-Fi as the ESP32. (${e.osError?.message ?? e.message})');
    } on http.ClientException catch (e) {
      throw ReadingSourceException('Connection error: ${e.message}');
    }

    if (response.statusCode != 200) {
      throw ReadingSourceException(
          'Sensor node responded with HTTP ${response.statusCode}.');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const ReadingSourceException(
          'Sensor node sent data that is not valid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ReadingSourceException(
          'Sensor node sent an unexpected data format.');
    }
    final reading = parse(decoded, DateTime.now());
    if (!reading.hasAnyValue) {
      throw const ReadingSourceException(
          'Sensor node responded, but no valid sensor values were found. '
          'Check the probe connections.');
    }
    return reading;
  }

  /// Converts the ESP32 JSON into a [SensorReading], discarding values that
  /// are physically implausible (typically a disconnected probe).
  static SensorReading parse(Map<String, dynamic> json, DateTime receivedAt) {
    double? number(Object? v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    double? within(double? v, double min, double max) =>
        v != null && v >= min && v <= max ? v : null;

    return SensorReading(
      timestamp: receivedAt,
      origin: ReadingOrigin.sensor,
      temperatureC: within(number(json['temperature'] ?? json['temp']), -5, 60),
      ph: within(number(json['ph']), 0, 14),
      salinityPpt: within(number(json['salinity']), 0, 80),
      conductivityUsCm: within(
          number(json['conductivity'] ?? json['ec']), 0, 200000),
    );
  }
}
