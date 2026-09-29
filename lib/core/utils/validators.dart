abstract final class Validators {
  static final _phone = RegExp(r'^[6-9]\d{9}$');
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isPhone(String value) => _phone.hasMatch(value);

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your name';
    if (v.length < 2) return 'Name is too short';
    return null;
  }

  static String? optionalEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty || _email.hasMatch(v)) return null;
    return 'Enter a valid email address';
  }
}
