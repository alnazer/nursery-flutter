import 'dart:convert';

/// جلسة مستخدم: رمز Sanctum ومعلومات العرض.
class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.userName,
    this.expiresAt,
    this.replacedDevices = 0,
  });

  final String token;
  final int userId;
  final String userName;
  final DateTime? expiresAt;

  /// المشرفات: عدد الأجهزة التي أُخرجت بهذا الدخول (جهاز واحد لكل موظفة).
  final int replacedDevices;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user =
        json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : <String, dynamic>{};

    return AuthSession(
      token: (json['token'] as String?) ?? '',
      userId: (user['id'] as int?) ?? 0,
      userName: (user['name'] as String?) ?? '',
      expiresAt: DateTime.tryParse((json['expires_at'] as String?) ?? ''),
      replacedDevices: (json['replaced_devices'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'token': token,
        'user': <String, dynamic>{'id': userId, 'name': userName},
        'expires_at': expiresAt?.toIso8601String(),
        'replaced_devices': replacedDevices,
      };

  String encode() => jsonEncode(toJson());

  static AuthSession? decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final dynamic json = jsonDecode(raw);

      return json is Map<String, dynamic> ? AuthSession.fromJson(json) : null;
    } catch (_) {
      return null;
    }
  }
}

/// رد الدخول: إمّا رمز دخول، وإمّا تحدٍّ يحتاج رمز تحقق.
class LoginResult {
  const LoginResult({this.session, this.challenge});

  final AuthSession? session;
  final OtpChallenge? challenge;

  bool get needsOtp => challenge != null;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    if (json['otp_required'] == true) {
      return LoginResult(challenge: OtpChallenge.fromJson(json));
    }

    return LoginResult(session: AuthSession.fromJson(json));
  }
}

/// تحدي رمز التحقق (رسالة نصية لولي الأمر، أو بريد للمشرفة).
class OtpChallenge {
  const OtpChallenge({
    required this.challenge,
    required this.length,
    required this.expiresIn,
    required this.resendIn,
    required this.target,
  });

  final String challenge;
  final int length;
  final int expiresIn;
  final int resendIn;

  /// الجوال أو البريد مُقنّعاً كما يعيده الخادم.
  final String target;

  factory OtpChallenge.fromJson(Map<String, dynamic> json) => OtpChallenge(
        challenge: (json['challenge'] as String?) ?? '',
        length: (json['length'] as int?) ?? 6,
        expiresIn: (json['expires_in'] as int?) ?? 600,
        resendIn: (json['resend_in'] as int?) ?? 60,
        target: (json['mobile'] as String?) ?? (json['email'] as String?) ?? '',
      );
}
