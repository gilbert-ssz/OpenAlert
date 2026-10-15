import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme/app_theme.dart';
import '../utils/lang.dart';
import '../utils/validators.dart';
import '../widgets/common.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await AppScope.of(context).auth.register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
    if (!mounted) return;
    if (error == null) {
      // Signed in: return to the root, which now shows the dashboard.
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: PhotoBackground(
        image: AppImages.welcome,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    const AquaSenseLogo(size: 56),
                    const SizedBox(height: 20),
                    FrostedPanel(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              tr('Create Account', 'Paghimo og Account'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr('Your account is saved on this phone only.',
                                  'Ang imong account natago lang niini nga cellphone.'),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _name,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: tr('Full name', 'Tibuok ngalan'),
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                              ),
                              validator: Validators.name,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'Email address',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: tr('Password (min. 6 characters)',
                                    'Password (6 ka letra o labaw pa)'),
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  tooltip: _obscure
                                      ? tr('Show password', 'Ipakita ang password')
                                      : tr('Hide password', 'Tagoa ang password'),
                                  icon: Icon(_obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: Validators.password,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _confirm,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                hintText: tr('Confirm password', 'Isulat pag-usab ang password'),
                                prefixIcon: const Icon(Icons.lock_reset_rounded),
                              ),
                              validator: (v) => v != _password.text
                                  ? tr('Passwords do not match.',
                                      'Dili parehas ang password.')
                                  : null,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.critical.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(_error!,
                                    style: const TextStyle(color: Colors.white)),
                              ),
                            ],
                            const SizedBox(height: 18),
                            FilledButton(
                              onPressed: _busy ? null : _submit,
                              style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.teal),
                              child: _busy
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : Text(tr('Create Account', 'Paghimo og Account')),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _busy ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      child: Text(tr('Already have an account? Log in',
                          'Naa nay account? Mag-log in')),
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
}
