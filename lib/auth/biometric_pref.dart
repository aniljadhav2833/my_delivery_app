import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricPref {
  static const _key = 'biometric_enabled';
  static const _storage = FlutterSecureStorage();

  static Future<bool> isEnabled() async {
    return (await _storage.read(key: _key)) == 'true';
  }

  static Future<void> enable() async {
    await _storage.write(key: _key, value: 'true');
  }

  static Future<void> disable() async {
    await _storage.write(key: _key, value: 'false');
  }
}
