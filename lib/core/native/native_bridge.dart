import 'package:flutter/services.dart';

/// معلومات الجهاز والتطبيق من الكود الأصلي (تُرسل في ترويسات الطلبات وتُعرض في «أجهزتي»).
class DeviceInfo {
  const DeviceInfo({
    required this.platform,
    required this.deviceName,
    required this.osVersion,
    required this.appVersion,
    required this.appBuild,
  });

  final String platform;
  final String deviceName;
  final String osVersion;
  final String appVersion;
  final int appBuild;

  static const DeviceInfo unknown = DeviceInfo(
    platform: 'android',
    deviceName: '',
    osVersion: '',
    appVersion: '',
    appBuild: 0,
  );

  factory DeviceInfo.fromMap(Map<dynamic, dynamic> map) => DeviceInfo(
        platform: '${map['platform'] ?? 'android'}',
        deviceName: '${map['deviceName'] ?? ''}',
        osVersion: '${map['osVersion'] ?? ''}',
        appVersion: '${map['appVersion'] ?? ''}',
        appBuild: map['appBuild'] is int ? map['appBuild'] as int : 0,
      );
}

enum BiometricStatus { available, notEnrolled, noHardware, unavailable }

/// خطأ من طبقة البصمة الأصلية: cancelled، locked، not_enrolled، key_invalidated، no_key، sign_failed.
class BiometricError implements Exception {
  const BiometricError(this.code, [this.message]);

  final String code;
  final String? message;

  bool get isCancelled => code == 'cancelled';

  bool get keyGone => code == 'key_invalidated' || code == 'no_key';

  @override
  String toString() => 'BiometricError($code, $message)';
}

/// القناة الوحيدة مع الكود الأصلي — بلا أي مكتبة خارجية.
class NativeBridge {
  const NativeBridge([this.channel = _defaultChannel]);

  static const MethodChannel _defaultChannel = MethodChannel('nursery/native');

  final MethodChannel channel;

  Future<DeviceInfo> deviceInfo() async {
    try {
      final Map<dynamic, dynamic>? map = await channel.invokeMethod<Map<dynamic, dynamic>>('deviceInfo');

      return map == null ? DeviceInfo.unknown : DeviceInfo.fromMap(map);
    } on PlatformException {
      return DeviceInfo.unknown;
    } on MissingPluginException {
      return DeviceInfo.unknown;
    }
  }

  /// يفتح رابطاً خارج التطبيق (صفحة الدفع، الإيصال).
  Future<bool> openUrl(String url) async {
    try {
      return await channel.invokeMethod<bool>('openUrl', <String, dynamic>{'url': url}) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// يفتح ماسح الأكواد ويعيد النص الممسوح (أو null إن أُلغي).
  Future<String?> scanCode() async {
    try {
      return await channel.invokeMethod<String>('scanCode');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<String?> secureRead(String key) async {
    try {
      return await channel.invokeMethod<String>('secureRead', <String, dynamic>{'key': key});
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<void> secureWrite(String key, String? value) async {
    try {
      if (value == null) {
        await channel.invokeMethod<void>('secureDelete', <String, dynamic>{'key': key});

        return;
      }
      await channel.invokeMethod<void>('secureWrite', <String, dynamic>{'key': key, 'value': value});
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  Future<void> secureDelete(String key) => secureWrite(key, null);

  Future<BiometricStatus> biometricStatus() async {
    try {
      final String? value = await channel.invokeMethod<String>('biometricStatus');
      switch (value) {
        case 'available':
          return BiometricStatus.available;
        case 'not_enrolled':
          return BiometricStatus.notEnrolled;
        case 'no_hardware':
          return BiometricStatus.noHardware;
        default:
          return BiometricStatus.unavailable;
      }
    } on PlatformException {
      return BiometricStatus.unavailable;
    } on MissingPluginException {
      return BiometricStatus.unavailable;
    }
  }

  Future<bool> hasBiometricKey() async {
    try {
      return await channel.invokeMethod<bool>('biometricHasKey') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// ينشئ مفتاحاً جديداً ويعيد المفتاح العام base64 (SubjectPublicKeyInfo).
  Future<String> createBiometricKey() async {
    try {
      final String? key = await channel.invokeMethod<String>('biometricCreateKey');
      if (key == null || key.isEmpty) {
        throw const BiometricError('key_failed');
      }

      return key;
    } on PlatformException catch (error) {
      throw BiometricError(error.code, error.message);
    } on MissingPluginException {
      throw const BiometricError('unavailable');
    }
  }

  Future<void> deleteBiometricKey() async {
    try {
      await channel.invokeMethod<void>('biometricDeleteKey');
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  /// يعرض شاشة البصمة ويعيد التوقيع base64.
  Future<String> sign({
    required String message,
    required String title,
    required String subtitle,
    required String cancel,
  }) async {
    try {
      final String? signature = await channel.invokeMethod<String>('biometricSign', <String, dynamic>{
        'message': message,
        'title': title,
        'subtitle': subtitle,
        'cancel': cancel,
      });
      if (signature == null || signature.isEmpty) {
        throw const BiometricError('sign_failed');
      }

      return signature;
    } on PlatformException catch (error) {
      throw BiometricError(error.code, error.message);
    } on MissingPluginException {
      throw const BiometricError('unavailable');
    }
  }
}
