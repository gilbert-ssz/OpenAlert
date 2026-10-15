import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme/app_theme.dart';
import '../models/app_settings.dart';
import '../utils/lang.dart';
import '../utils/validators.dart';
import '../widgets/common.dart';
import 'register_screen.dart';

/// Welcome / Login screen with a full-screen fishpond photograph.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final error =
        await AppScope.of(context).auth.login(_email.text, _password.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  Future<void> _guest() async {
    setState(() => _busy = true);
    await AppScope.of(context).auth.continueAsGuest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoBackground(
        image: AppImages.welcome,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    const _LanguagePicker(),
                    const SizedBox(height: 20),
                    const AquaSenseLogo(),
                    const SizedBox(height: 10),
                    Text(
                      tr('Check your fishpond water and find out the best '
                          'fish, shrimp or crab to raise.',
                          'Susiha ang tubig sa imong fishpond ug hibal-i ang '
                          'labing angay nga isda, pasayan o alimango nga '
                          'ibuhi.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                      ),
                    ),
                    const SizedBox(height: 28),
                    FrostedPanel(child: _buildForm()),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(tr("Don't have an account?", 'Wala pay account?'),
                            style: const TextStyle(color: Colors.white)),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                        builder: (_) => const RegisterScreen()),
                                  ),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.aqua),
                          child: Text(tr('Create Account', 'Paghimo og Account'),
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _guest,
                      icon: const Icon(Icons.person_outline_rounded),
                      label: Text(tr('Continue as Guest', 'Padayon bisan walay account')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      tr('Accounts are stored on this device only.',
                          'Ang account natago lang niini nga cellphone.'),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr('Welcome back', 'Maayong pag-abot'),
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(tr('Log in to check on your pond.',
                  'Mag-log in aron masusi ang imong fishpond.'),
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              hintText: tr('Email address', 'Email address'),
              prefixIcon: const Icon(Icons.mail_outline_rounded),
            ),
            validator: Validators.email,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
            decoration: InputDecoration(
              hintText: tr('Password', 'Password'),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure
                    ? tr('Show password', 'Ipakita ang password')
                    : tr('Hide password', 'Tagoa ang password'),
                icon: Icon(_obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: Validators.password,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.critical.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error!, style: const TextStyle(color: Colors.white)),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _busy ? null : _login,
            style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(tr('Log In', 'Mag-log in')),
          ),
        ],
      ),
    );
  }
}

/// Large English / Bisaya switch shown before logging in, so the owner can
/// pick a language right away.
class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final current = settings.value.language;

    Widget option(AppLanguage language, String label) {
      final selected = language == current;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton(
            onPressed: () =>
                settings.update(settings.value.copyWith(language: language)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.08),
              foregroundColor: selected ? AppColors.deepGreen : Colors.white,
              side: const BorderSide(color: Colors.white70, width: 1.5),
            ),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800)),
          ),
        ),
      );
    }

    return Row(
      children: [
        option(AppLanguage.english, 'English'),
        option(AppLanguage.bisaya, 'Bisaya'),
      ],
    );
  }
}
