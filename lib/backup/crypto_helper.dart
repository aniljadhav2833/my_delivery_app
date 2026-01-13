import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart' as debug;

class CryptoHelper {
  // ✅ EXACTLY 32 characters (count them)

  static const String _rawKey = 'MY_DELIVERY_APP_KEY_32_BYTES!121';

  static final Key _key = Key.fromUtf8(_rawKey);

  static final IV _iv = IV.fromLength(16);

  static final Encrypter _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  static Uint8List encrypt(Uint8List data) {
    debug.debugPrint('Encrypt KEY LENGTH = ${CryptoHelper._rawKey.length}');
    return _encrypter.encryptBytes(data, iv: _iv).bytes;
  }

  static Uint8List decrypt(Uint8List data) {
    debug.debugPrint('Decrypt KEY LENGTH = ${CryptoHelper._rawKey.length}');
    return Uint8List.fromList(
      _encrypter.decryptBytes(Encrypted(data), iv: _iv),
    );
  }
}
