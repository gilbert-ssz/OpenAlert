import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../controllers/monitoring_controller.dart';
import '../models/app_settings.dart';
import '../services/esp32_http_source.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/lang.dart';
import '../widgets/common.dart';
import '../widgets/photo_header.dart';
import '../widgets/status_widgets.dart';
import 'image_credits_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _address;
  late final TextEditingController _pondName;
  bool _testing = false;
  String? _testResult;

  static Map<int, String> get _refreshOptions => {
        0: tr('Off', 'Patay'),
        15: tr('Every 15 seconds', 'Matag 15 segundos'),
        30: tr('Every 30 seconds', 'Matag 30 segundos'),
        60: tr('Every minute', 'Matag minuto'),
        300: tr('Every 5 minutes', 'Matag 5 minutos'),
      };

  @override
  void initState() {
    super.initState();
    final s = AppScope.of(context).settings.value;
    _address = TextEditingController(text: s.esp32Address);
    _pondName = TextEditingController(text: s.pondName);
  }

  @override
  void dispose() {
    _address.dispose();
    _pondName.dispose();
    super.dispose();
  }

  void _update(AppSettings next) => AppScope.of(context).settings.update(next);

  void _snack(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _testConnection() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final result =
        await AppScope.of(context).monitoring.testConnection(_address.text);
    if (!mounted) return;
    setState(() {
      _testing = false;
      _testResult = result;
    });
  }

  Future<bool> _confirm(String title, String message, String action,
      {bool destructive = false}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr('Cancel', 'Ayaw'))),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: AppColors.critical,
                    minimumSize: const Size(0, 44))
                : FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([scope.settings, scope.monitoring, scope.auth]),
      builder: (context, _) {
        final s = scope.settings.value;
        final m = scope.monitoring;
        final user = scope.auth.session;

        return CustomScrollView(
          slivers: [
            const PhotoHeader(image: AppImages.settings, title: 'Settings'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              sliver: SliverList.list(children: [
                // ---------------- Easy reading ----------------
                SectionTitle(tr('Language & Text Size',
                    'Pinulongan ug Gidak-on sa Sulat')),
                _ReadingOptions(settings: s, onChanged: _update),

                // ---------------- Profile ----------------
                SectionTitle(tr('Profile', 'Profile')),
                AppCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.lightGreen,
                            child: Text(
                              (user?.name.isNotEmpty ?? false)
                                  ? user!.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.teal),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.name ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800, fontSize: 16)),
                                Text(
                                  user?.isGuest ?? true
                                      ? tr('Guest - no account', 'Bisita - walay account')
                                      : user!.email!,
                                  style: const TextStyle(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              if (await _confirm(tr('Log out?', 'Mo-log out?'),
                                  tr('You will return to the login screen. Your readings stay on this device.',
                                      'Mobalik ka sa login. Magpabilin ang imong mga basa niini nga cellphone.'),
                                  tr('Log out', 'Log out'))) {
                                await scope.auth.logout();
                              }
                            },
                            icon: const Icon(Icons.logout_rounded),
                            label: Text(tr('Log out', 'Log out')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _pondName,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: tr('Pond name', 'Ngalan sa fishpond'),
                          prefixIcon: const Icon(Icons.water_rounded),
                          suffixIcon: IconButton(
                            tooltip: tr('Save pond name', 'I-save ang ngalan'),
                            icon: const Icon(Icons.check_rounded),
                            onPressed: () {
                              final name = _pondName.text.trim();
                              if (name.isEmpty) return;
                              FocusScope.of(context).unfocus();
                              _update(s.copyWith(pondName: name));
                              _snack(tr('Pond name saved', 'Na-save ang ngalan'));
                            },
                          ),
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) {
                            _update(s.copyWith(pondName: v.trim()));
                            _snack(tr('Pond name saved', 'Na-save ang ngalan'));
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // ---------------- Data connection ----------------
                SectionTitle(tr('Sensor Connection', 'Koneksyon sa Sensor')),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusPill(StatusStyle.connection(m.status)),
                          const SizedBox(width: 8),
                          if (m.lastAttempt != null)
                            Expanded(
                              child: Text('${tr('Checked', 'Gisusi')} ${Fmt.time(m.lastAttempt!)}',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 12.5)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_statusDescription(m),
                          style: const TextStyle(height: 1.35)),
                      const SizedBox(height: 14),
                      Text(tr('Where readings come from', 'Diin gikan ang basa'),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<DataMode>(
                          segments: [
                            ButtonSegment(
                                value: DataMode.demo,
                                label: Text(tr('Demo Mode', 'Sample lang')),
                                icon: const Icon(Icons.science_outlined)),
                            const ButtonSegment(
                                value: DataMode.esp32,
                                label: Text('ESP32 Sensor'),
                                icon: Icon(Icons.sensors_rounded)),
                          ],
                          selected: {s.dataMode},
                          onSelectionChanged: (v) =>
                              _update(s.copyWith(dataMode: v.first)),
                        ),
                      ),
                      if (s.dataMode == DataMode.esp32) ...[
                        const SizedBox(height: 14),
                        TextField(
                          controller: _address,
                          keyboardType: TextInputType.url,
                          onChanged: (_) => setState(() => _testResult = null),
                          decoration: InputDecoration(
                            labelText: tr('ESP32 IP address', 'IP address sa ESP32'),
                            hintText: '192.168.4.1',
                            prefixIcon: const Icon(Icons.router_outlined),
                            errorText: Esp32HttpSource.isValidAddress(_address.text)
                                ? null
                                : tr('Enter an IP address such as 192.168.4.1', 'Isulat ang IP address sama sa 192.168.4.1'),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'App requests: ${Esp32HttpSource.buildEndpoint(_address.text)}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _testing ||
                                        !Esp32HttpSource.isValidAddress(_address.text)
                                    ? null
                                    : _testConnection,
                                icon: _testing
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Icon(Icons.network_check_rounded),
                                label: Text(tr('Test', 'Sulayi')),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48)),
                                onPressed: !Esp32HttpSource.isValidAddress(
                                        _address.text)
                                    ? null
                                    : () {
                                  FocusScope.of(context).unfocus();
                                  _update(s.copyWith(
                                      esp32Address: _address.text.trim()));
                                  m.refresh(userInitiated: true);
                                  _snack(tr('Address saved - connecting…', 'Na-save - nagkonektar…'));
                                },
                                icon: const Icon(Icons.save_rounded),
                                label: Text(tr('Save & Connect', 'I-save ug Ikonektar')),
                              ),
                            ),
                          ],
                        ),
                        if (_testResult != null) ...[
                          const SizedBox(height: 10),
                          Text(_testResult!,
                              style: TextStyle(
                                  color: _testResult!.startsWith('Connected')
                                      ? AppColors.good
                                      : AppColors.critical,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ],
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: _refreshOptions.containsKey(s.autoRefreshSeconds)
                            ? s.autoRefreshSeconds
                            : 30,
                        decoration: InputDecoration(
                          labelText: tr('Automatic refresh', 'Awtomatik nga pag-refresh'),
                          prefixIcon: const Icon(Icons.autorenew_rounded),
                        ),
                        items: [
                          for (final e in _refreshOptions.entries)
                            DropdownMenuItem(value: e.key, child: Text(e.value)),
                        ],
                        onChanged: (v) {
                          if (v != null) _update(s.copyWith(autoRefreshSeconds: v));
                        },
                      ),
                    ],
                  ),
                ),

                // ---------------- Display ----------------
                SectionTitle(tr('Units', 'Mga Unit')),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('Temperature unit', 'Unit sa kainit'),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<TemperatureUnit>(
                          segments: const [
                            ButtonSegment(
                                value: TemperatureUnit.celsius,
                                label: Text('Celsius (°C)')),
                            ButtonSegment(
                                value: TemperatureUnit.fahrenheit,
                                label: Text('Fahrenheit (°F)')),
                          ],
                          selected: {s.temperatureUnit},
                          onSelectionChanged: (v) =>
                              _update(s.copyWith(temperatureUnit: v.first)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(tr('Salinity reading', 'Basa sa kaparat'),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<SalinityDisplay>(
                          segments: const [
                            ButtonSegment(
                                value: SalinityDisplay.ppt,
                                label: Text('Salinity (ppt)')),
                            ButtonSegment(
                                value: SalinityDisplay.conductivity,
                                label: Text('Conductivity')),
                          ],
                          selected: {s.salinityDisplay},
                          onSelectionChanged: (v) =>
                              _update(s.copyWith(salinityDisplay: v.first)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Use "Conductivity" if your salinity probe is an EC '
                        'sensor. Recommendations always use salinity in ppt; '
                        'when only conductivity is available it is estimated.',
                        style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),

                // ---------------- Data management ----------------
                SectionTitle(tr('Saved Readings', 'Mga Natala nga Basa')),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.storage_rounded, color: AppColors.teal),
                        title: Text(tr('${m.history.length} readings stored', '${m.history.length} ka basa ang natala')),
                        subtitle: Text('${m.demoReadingCount} demo • '
                            '${m.history.length - m.demoReadingCount} from sensor'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.auto_graph_rounded, color: AppColors.demo),
                        title: const Text('Load sample demo history'),
                        subtitle: const Text('Adds 3 days of labelled sample readings'),
                        onTap: () async {
                          if (await _confirm(
                              'Load sample history?',
                              'This replaces existing demo readings with 3 days '
                                  'of simulated samples. Sensor readings are not affected.',
                              'Load')) {
                            await m.loadSampleHistory();
                            _snack('Sample demo history loaded');
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.cleaning_services_rounded,
                            color: AppColors.caution),
                        title: const Text('Clear demo data'),
                        subtitle: const Text('Removes simulated readings only'),
                        onTap: () async {
                          if (await _confirm(
                              'Clear demo data?',
                              'All ${m.demoReadingCount} demo readings will be '
                                  'deleted. Sensor readings are kept.',
                              'Clear')) {
                            await m.clearDemoData();
                            _snack('Demo data cleared');
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.delete_forever_rounded,
                            color: AppColors.critical),
                        title: const Text('Clear all history'),
                        subtitle: const Text('Deletes every stored reading'),
                        onTap: () async {
                          if (await _confirm(
                              'Delete all history?',
                              'All ${m.history.length} readings, including '
                                  'sensor readings, will be permanently deleted '
                                  'from this device.',
                              'Delete all',
                              destructive: true)) {
                            await m.clearAllHistory();
                            _snack('All history deleted');
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // ---------------- Help ----------------
                SectionTitle(tr('Help', 'Tabang')),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: Column(
                      children: [
                        _Help(
                          tr('What do the colors mean?',
                              'Unsay buot ipasabot sa mga kolor?'),
                          tr(
                              'Green = good / suitable.\n'
                                  'Yellow = needs attention - it can still '
                                  'live, but watch closely.\n'
                                  'Red = not safe - act now or choose '
                                  'something else to raise.',
                              'Berde = maayo / angay.\n'
                                  'Dalag = bantayi - mabuhi pa, apan '
                                  'bantayi pag-ayo.\n'
                                  'Pula = dili luwas - aksyoni dayon o '
                                  'pili og lain nga ibuhi.'),
                        ),
                        _Help(
                          tr('What is Demo Mode?', 'Unsa ang Demo Mode?'),
                          tr(
                              'Demo Mode shows example readings so the app '
                                  'can be tried without the sensor. Demo '
                                  'values are always labelled and never '
                                  'shown as real sensor data.',
                              'Ang Demo Mode nagpakita og pananglitan nga '
                                  'basa aron masulayan ang app bisan walay '
                                  'sensor. Kanunay kini nga gimarkahan og '
                                  '"sample" ug dili tinuod nga basa.'),
                        ),
                        _Help(
                          tr('Connecting the ESP32 sensor node',
                              'Pagkonektar sa ESP32 sensor'),
                          tr(
                              '1. Power on the ESP32.\n'
                                  '2. Connect this phone to the same Wi-Fi '
                                  'network (or to the ESP32\'s own hotspot).\n'
                                  '3. Choose "ESP32 Sensor", enter its IP '
                                  'address (shown on the ESP32 serial '
                                  'monitor), then tap Test.\n'
                                  '4. Tap Save & Connect.\n\n'
                                  'Live readings work only on the local '
                                  'network; remote monitoring over the '
                                  'internet is not part of this version.',
                              '1. I-on ang ESP32.\n'
                                  '2. Ikonektar kini nga cellphone sa '
                                  'parehas nga Wi-Fi (o sa hotspot sa '
                                  'ESP32).\n'
                                  '3. Pilia ang "ESP32 Sensor", isulat ang '
                                  'IP address (makita sa serial monitor sa '
                                  'ESP32), unya pindota ang Sulayi.\n'
                                  '4. Pindota ang I-save ug Ikonektar.\n\n'
                                  'Molihok lang ang tinuod nga basa sa '
                                  'parehas nga Wi-Fi; dili pa kini magamit '
                                  'pinaagi sa internet.'),
                        ),
                        _Help(
                          tr('Status shows "Disconnected"',
                              'Nag-ingon og "Naputol"'),
                          tr(
                              '• Check the ESP32 is powered and running.\n'
                                  '• Make sure the phone is not on mobile '
                                  'data only.\n'
                                  '• Confirm the IP address has not '
                                  'changed.\n'
                                  '• Open http://<ip>/readings in the phone '
                                  'browser - it should show JSON values.',
                              '• Susiha kung naka-on ug nagdagan ang '
                                  'ESP32.\n'
                                  '• Siguroha nga naka-Wi-Fi ang cellphone, '
                                  'dili mobile data lang.\n'
                                  '• Susiha kung wala nausab ang IP '
                                  'address.\n'
                                  '• Ablihi ang http://<ip>/readings sa '
                                  'browser - kinahanglan naay JSON nga '
                                  'makita.'),
                        ),
                        _Help(
                          tr('A sensor shows "Unavailable"',
                              'Ang sensor nag-ingon og "Walay basa"'),
                          tr(
                              'The ESP32 responded but that value was '
                                  'missing or out of range (for example '
                                  '-127 °C from a disconnected temperature '
                                  'probe). Check the probe wiring and make '
                                  'sure it is under the water.',
                              'Mitubag ang ESP32 apan walay sakto nga basa '
                                  'niana nga sensor (pananglitan -127 °C '
                                  'kung natangtang ang temperature probe). '
                                  'Susiha ang wire sa probe ug siguroha nga '
                                  'nalubog kini sa tubig.'),
                        ),
                        _Help(
                          tr('Readings look wrong', 'Murag sayop ang basa'),
                          tr(
                              'pH and salinity probes need regular '
                                  'calibration with buffer / standard '
                                  'solutions. Rinse probes with clean water '
                                  'and recalibrate if readings drift.',
                              'Ang pH ug salinity probe kinahanglan '
                                  'i-calibrate kanunay gamit ang buffer / '
                                  'standard solution. Hugasi og limpyo nga '
                                  'tubig ang probe ug i-calibrate pag-usab '
                                  'kung mausab-usab ang basa.'),
                        ),
                        _Help(
                          tr('How does AquaSense choose what to raise?',
                              'Unsaon pagpili sa AquaSense sa ibuhi?'),
                          tr(
                              'Each fish, shrimp and crab has a best range '
                                  'and a "can still live" range for '
                                  'temperature, pH and salinity. It is '
                                  'Suitable when all readings are in the '
                                  'best range, Caution when some are only in '
                                  'the "can still live" range, and Not '
                                  'Suitable when any is outside it.',
                              'Ang matag isda, pasayan ug alimango naay '
                                  'sakto nga range ug "mabuhi pa" nga range '
                                  'sa kainit, pH ug kaparat. Angay kung '
                                  'sakto tanan, Bantayi kung naa sa "mabuhi '
                                  'pa" nga range, ug Dili Angay kung naa '
                                  'sa gawas niini.'),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---------------- About ----------------
                SectionTitle(tr('About', 'Mahitungod')),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.water_drop_rounded, color: AppColors.teal),
                          SizedBox(width: 8),
                          Text('AquaSense  v1.0.0',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'AquaSense: An IoT-Based Fishpond Water Quality and '
                        'Salinity Monitoring System with Mobile Application for '
                        'Fish Species Recommendation.',
                        style: TextStyle(height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Capstone project prototype. Recommendations are '
                        'decision support only and do not replace advice from '
                        'aquaculture technicians.',
                        style: TextStyle(color: AppColors.muted, fontSize: 12.5),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (_) => const ImageCreditsScreen()),
                        ),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(tr('Photo credits & licenses', 'Tag-iya sa mga litrato')),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        );
      },
    );
  }

  String _statusDescription(MonitoringController m) => switch (m.status) {
        ConnectionStatus.demo => tr(
            'Showing example readings. No sensor is in use.',
            'Nagpakita og pananglitan nga basa. Walay sensor nga gigamit.'),
        ConnectionStatus.connecting =>
          tr('Contacting the ESP32 sensor node…', 'Nagkonektar sa ESP32…'),
        ConnectionStatus.connected => tr(
            'Receiving live readings from the ESP32 sensor node.',
            'Nakadawat og tinuod nga basa gikan sa ESP32.'),
        ConnectionStatus.disconnected => m.error ??
            tr('Cannot reach the ESP32 sensor node.',
                'Dili makonektar sa ESP32.'),
      };
}

class _Help extends StatelessWidget {
  const _Help(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.help_outline_rounded, color: AppColors.teal),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(body, style: const TextStyle(fontSize: 15.5, height: 1.5))],
    );
  }
}

/// Language and text-size choices with large buttons and a live preview.
class _ReadingOptions extends StatelessWidget {
  const _ReadingOptions({required this.settings, required this.onChanged});

  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget choice<T>({
      required T value,
      required T current,
      required String label,
      required ValueChanged<T> onTap,
      double fontSize = 16,
    }) {
      final selected = value == current;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton(
            onPressed: () => onTap(value),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              backgroundColor: selected ? AppColors.teal : Colors.white,
              foregroundColor: selected ? Colors.white : AppColors.ink,
              side: BorderSide(
                  color: selected ? AppColors.teal : const Color(0xFFD5E4DC),
                  width: 2),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fontSize, fontWeight: FontWeight.w800)),
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('Language', 'Pinulongan'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Row(children: [
            choice(
              value: AppLanguage.english,
              current: settings.language,
              label: 'English',
              onTap: (v) => onChanged(settings.copyWith(language: v)),
            ),
            choice(
              value: AppLanguage.bisaya,
              current: settings.language,
              label: 'Bisaya',
              onTap: (v) => onChanged(settings.copyWith(language: v)),
            ),
          ]),
          const SizedBox(height: 18),
          Text(tr('Text size', 'Gidak-on sa sulat'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Row(children: [
            for (final (size, label, font) in [
              (TextSize.normal, tr('Normal', 'Normal'), 14.0),
              (TextSize.large, tr('Large', 'Dako'), 17.0),
              (TextSize.extraLarge, tr('Largest', 'Pinakadako'), 20.0),
            ])
              choice(
                value: size,
                current: settings.textSize,
                label: label,
                fontSize: font,
                onTap: (v) => onChanged(settings.copyWith(textSize: v)),
              ),
          ]),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              tr('Sample: The water is OK. Temperature and pH are normal.',
                  'Pananglitan: Okay ang tubig. Normal ang kainit ug pH.'),
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
