import 'lang.dart';

class Validators {
  Validators._();

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return tr('Please enter your name.', 'Palihug isulat ang imong ngalan.');
    if (v.trim().length < 2) return tr('Name is too short.', 'Mubo ra kaayo ang ngalan.');
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return tr('Please enter your email.', 'Palihug isulat ang imong email.');
    if (!_email.hasMatch(v.trim())) return tr('Enter a valid email address.', 'Isulat ang sakto nga email address.');
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return tr('Please enter your password.', 'Palihug isulat ang imong password.');
    if (v.length < 6) return tr('Password must be at least 6 characters.', 'Ang password kinahanglan 6 ka letra o labaw pa.');
    return null;
  }
}
