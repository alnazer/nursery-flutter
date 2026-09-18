import 'dart:math';

import '../models/auth_session.dart';
import '../native/native_bridge.dart';

/// بصمة مفعّلة على هذا الجهاز.
class StoredBiometric {
  const StoredBiometric({required this.keyId, required this.userName});

  final String keyId;
  final String userName;
}

/// كل ما يُحفظ على الجهاز: الرمز، ومفتاح البصمة، ومعرّف التثبيت، واللغة.
/// القيم الحساسة تمرّ عبر Keystore/Keychain في الكود الأصلي.
class SessionStore {
  SessionStore(this._native);

  final NativeBridge _native;

  static const String _sessionKey = 'session';
  static const String _biometricKeyId = 'biometric_key_id';
  static const String _biometricUser = 'biometric_user';
  static const String _deviceIdKey = 'device_id';
  static const String _localeKey = 'locale';

  Future<AuthSession?> readSession() async => AuthSession.decode(await _native.secureRead(_sessionKey));

  Future<void> writeSession(AuthSession? session) => _native.secureWrite(_sessionKey, session?.encode());

  Future<StoredBiometric?> readBiometric() async {
    final String? keyId = await _native.secureRead(_biometricKeyId);
    if (keyId == null || keyId.isEmpty) {
      return null;
    }

    return StoredBiometric(keyId: keyId, userName: await _native.secureRead(_biometricUser) ?? '');
  }

  Future<void> writeBiometric(String keyId, String userName) async {
    await _native.secureWrite(_biometricKeyId, keyId);
    await _native.secureWrite(_biometricUser, userName);
  }

  Future<void> clearBiometric() async {
    await _native.secureDelete(_biometricKeyId);
    await _native.secureDelete(_biometricUser);
  }

  /// معرّف ثابت لتثبيت التطبيق: يمنع تنبيه «جهاز جديد» المتكرر ويربط البصمة بالجهاز.
  Future<String> deviceId() async {
    final String? stored = await _native.secureRead(_deviceIdKey);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
    final Random random = Random.secure();
    final String generated = List<String>.generate(
      16,
      (int _) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await _native.secureWrite(_deviceIdKey, generated);

    return generated;
  }

  Future<String?> readLocale() => _native.secureRead(_localeKey);

  Future<void> writeLocale(String locale) => _native.secureWrite(_localeKey, locale);
}
