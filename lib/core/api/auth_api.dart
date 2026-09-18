import '../../app/app_config.dart';
import '../models/app_meta.dart';
import '../models/auth_session.dart';
import 'api_client.dart';

/// تسجيل مفتاح البصمة على الخادم.
class BiometricRegistration {
  const BiometricRegistration({required this.keyId, required this.algorithm});

  final String keyId;
  final String algorithm;
}

/// كل مسارات الدخول للتطبيقين — الفرق في الحقول فقط.
class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  AppConfig get _config => _client.config;

  Future<AppMeta> meta() async {
    final dynamic data = await _client.get('/meta', common: true);

    return data is Map<String, dynamic> ? AppMeta.fromJson(data) : AppMeta.fallback;
  }

  /// ولي الأمر: الجوال وحده، أو الجوال ثم رمز، أو اسم/بريد + كلمة مرور.
  Future<LoginResult> parentLogin({
    String? mobile,
    String? login,
    String? password,
    required String deviceId,
    required String deviceName,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'device_id': deviceId,
      'device_name': deviceName,
    };
    if (mobile != null) {
      body['mobile'] = mobile;
    }
    if (login != null) {
      body['login'] = login;
      body['password'] = password;
    }

    return _login(body);
  }

  /// المشرفات: اسم المستخدم وكلمة المرور.
  Future<LoginResult> staffLogin({
    required String username,
    required String password,
    required String deviceId,
    required String deviceName,
  }) =>
      _login(<String, dynamic>{
        'username': username,
        'password': password,
        'device_id': deviceId,
        'device_name': deviceName,
      });

  Future<LoginResult> _login(Map<String, dynamic> body) async {
    final dynamic data = await _client.post('/auth/login', body: body);

    return LoginResult.fromJson(_map(data));
  }

  Future<LoginResult> verifyOtp({required String challenge, required String code}) async {
    final dynamic data = await _client.post('/auth/otp/verify', body: <String, dynamic>{
      'challenge': challenge,
      'code': code,
    });

    return LoginResult.fromJson(_map(data));
  }

  Future<OtpChallenge> resendOtp(String challenge) async {
    final dynamic data = await _client.post('/auth/otp/resend', body: <String, dynamic>{'challenge': challenge});

    return OtpChallenge.fromJson(_map(data));
  }

  /// ولي الأمر فقط (وضع كلمة المرور).
  Future<void> forgotPassword(String email) =>
      _client.post('/auth/password/forgot', body: <String, dynamic>{'email': email});

  Future<void> logout({bool forgetBiometric = false}) =>
      _client.post('/auth/logout', body: <String, dynamic>{'forget_biometric': forgetBiometric});

  /// تفعيل البصمة — خلال 15 دقيقة من الدخول وإلا reauth_required.
  Future<BiometricRegistration> registerBiometric({
    required String publicKey,
    required String deviceId,
    required String deviceName,
  }) async {
    final Map<String, dynamic> data = _map(await _client.post('/auth/biometric', body: <String, dynamic>{
      'public_key': publicKey,
      'device_id': deviceId,
      'device_name': deviceName,
    }));

    return BiometricRegistration(
      keyId: (data['key_id'] as String?) ?? '',
      algorithm: (data['algorithm'] as String?) ?? 'ES256',
    );
  }

  Future<void> removeBiometric({String? deviceId}) => _client.delete(
        '/auth/biometric',
        body: deviceId == null ? null : <String, dynamic>{'device_id': deviceId},
      );

  /// تحدٍّ صالح دقيقتين ولمحاولة واحدة.
  Future<String> biometricChallenge(String keyId) async {
    final Map<String, dynamic> data =
        _map(await _client.post('/auth/biometric/challenge', body: <String, dynamic>{'key_id': keyId}));

    return (data['challenge'] as String?) ?? '';
  }

  Future<AuthSession> biometricVerify({
    required String keyId,
    required String challenge,
    required String signature,
    required String deviceName,
  }) async {
    final Map<String, dynamic> data = _map(await _client.post('/auth/biometric/verify', body: <String, dynamic>{
      'key_id': keyId,
      'challenge': challenge,
      'signature': signature,
      'device_name': deviceName,
    }));

    return AuthSession.fromJson(data);
  }

  /// النص الذي يوقّعه الجهاز: nsm-biometric-v1\n{X-Api-Key}\n{key_id}\n{challenge}
  String signedMessage({required String keyId, required String challenge}) =>
      'nsm-biometric-v1\n${_config.apiKey}\n$keyId\n$challenge';

  Map<String, dynamic> _map(dynamic data) =>
      data is Map<String, dynamic> ? data : <String, dynamic>{};
}
