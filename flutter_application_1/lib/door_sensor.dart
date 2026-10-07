// Mao ni ang "utok" sa app: mo-check sa ESP32, mo-save sa log, mo-alert.
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class LogItem {
  final String text, time, type; // type: 'alert' | 'ok' | 'info'
  LogItem(this.text, this.time, this.type);
}

String nowTime() {
  final n = DateTime.now();
  final h = n.hour % 12 == 0 ? 12 : n.hour % 12;
  final m = n.minute.toString().padLeft(2, '0');
  return '$h:$m ${n.hour >= 12 ? 'PM' : 'AM'}';
}

class DoorSensor extends ChangeNotifier {
  DoorSensor({String ip = defaultEsp32Ip, bool useDemoMode = defaultDemoMode})
      : esp32Ip = ip,
        demoMode = useDemoMode {
    _timer = Timer.periodic(const Duration(seconds: pollSeconds), (_) => checkNow());
  }

  String esp32Ip;
  bool demoMode;
  bool doorOpen = false; // true = open
  bool connected = false; // ESP32 online?
  bool triggered = false; // naay active alert?
  final List<LogItem> log = [LogItem('System armed', nowTime(), 'info')];
  Timer? _timer;

  // GET http://<ip>/status -> {"door":"open"} or {"door":"closed"}
  Future<void> checkNow() async {
    if (demoMode) {
      connected = true;
      notifyListeners();
      return;
    }
    try {
      final res = await http
          .get(Uri.parse('http://$esp32Ip/status'))
          .timeout(const Duration(seconds: 2));
      if (res.statusCode != 200) {
        throw const FormatException('Unexpected ESP32 response');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final state = data['door'];
      if (state != 'open' && state != 'closed') {
        throw const FormatException('Missing door state');
      }
      connected = true;
      _handleNewState(state == 'open');
    } catch (_) {
      connected = false;
    }
    notifyListeners();
  }

  void configure({required String ip, required bool useDemoMode}) {
    esp32Ip = ip;
    demoMode = useDemoMode;
    connected = false;
    notifyListeners();
    checkNow();
  }

  // Tawagon kada naay bag-ong state gikan sa sensor
  void _handleNewState(bool isOpen) {
    if (isOpen == doorOpen) return; // walay nausab
    doorOpen = isOpen;
    if (isOpen) {
      log.insert(0, LogItem('Door opened — alert sent', nowTime(), 'alert'));
      triggered = true;
      HapticFeedback.heavyImpact(); // vibrate
      SystemSound.play(SystemSoundType.alert); // tunog
    } else {
      log.insert(0, LogItem('Door closed', nowTime(), 'ok'));
    }
    notifyListeners();
  }

  // Test Alert button: i-simulate nga naabri/nagsira ang pultahan
  void testAlert() => _handleNewState(!doorOpen);

  void acknowledge() {
    triggered = false;
    log.insert(0, LogItem('Alert acknowledged', nowTime(), 'info'));
    notifyListeners();
  }

  // GET http://<ip>/silence -> patyon ang buzzer
  Future<void> silenceBuzzer() async {
    if (!demoMode) {
      try {
        await http.get(Uri.parse('http://$esp32Ip/silence'));
      } catch (_) {
        connected = false;
      }
    }
    log.insert(0, LogItem('Buzzer silenced', nowTime(), 'info'));
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}