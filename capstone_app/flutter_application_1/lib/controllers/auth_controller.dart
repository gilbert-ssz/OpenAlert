import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/lang.dart';

class UserSession {
  const UserSession({required this.name, this.email});

  final String name;

  /// Null for guests.
  final String? email;

  bool get isGuest => email == null;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;
}

/// Local, on-device accounts only.
///
/// No cloud authentication is configured: accounts exist only on this phone
/// and are removed if the app data is cleared. Passwords are stored as
/// salted SHA-256 hashes, never as plain text. Replace this class with a
/// real backend (e.g. Firebase Auth) if multi-device login is needed.
class AuthController extends ChangeNotifier {
  static const _accountsKey = 'auth_accounts_v1';
  static const _sessionKey = 'auth_session_v1';

  UserSession? _session;
  UserSession? get session => _session;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw != null) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _session = UserSession(
          name: json['name'] as String, email: json['email'] as String?);
    }
    notifyListeners();
  }

  /// Returns an error message, or null on success.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = _readAccounts(prefs);
    final key = email.trim().toLowerCase();
    if (accounts.containsKey(key)) {
      return tr('An account with this email already exists on this device.',
          'Naa nay account niini nga email sa kini nga cellphone.');
    }
    final salt = _newSalt();
    accounts[key] = {
      'name': name.trim(),
      'salt': salt,
      'hash': _hash(salt, password),
    };
    await prefs.setString(_accountsKey, jsonEncode(accounts));
    await _startSession(prefs, UserSession(name: name.trim(), email: key));
    return null;
  }

  /// Returns an error message, or null on success.
  Future<String?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final account = _readAccounts(prefs)[email.trim().toLowerCase()];
    if (account == null) {
      return tr(
          'No account found for this email on this device. '
              'Create an account or continue as guest.',
          'Walay account niini nga email sa kini nga cellphone. '
              'Paghimo og account o padayon bisan walay account.');
    }
    if (_hash(account['salt'] as String, password) != account['hash']) {
      return tr('Incorrect password. Please try again.',
          'Sayop ang password. Sulayi pag-usab.');
    }
    await _startSession(
      prefs,
      UserSession(
          name: account['name'] as String, email: email.trim().toLowerCase()),
    );
    return null;
  }

  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await _startSession(prefs, const UserSession(name: 'Guest'));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _session = null;
    notifyListeners();
  }

  Future<void> _startSession(SharedPreferences prefs, UserSession s) async {
    await prefs.setString(
        _sessionKey, jsonEncode({'name': s.name, 'email': s.email}));
    _session = s;
    notifyListeners();
  }

  Map<String, dynamic> _readAccounts(SharedPreferences prefs) {
    final raw = prefs.getString(_accountsKey);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  static String _newSalt() {
    final rng = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => rng.nextInt(256)));
  }

  static String _hash(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}
