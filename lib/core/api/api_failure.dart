/// رموز الأخطاء الثابتة من الخادم (القسم «رموز الأخطاء» في توثيق الـ API).
class ApiCode {
  static const String network = 'network_error';
  static const String invalidClient = 'invalid_client';
  static const String signatureExpired = 'signature_expired';
  static const String unauthenticated = 'unauthenticated';
  static const String biometricInvalid = 'biometric_invalid';
  static const String reauthRequired = 'reauth_required';
  static const String accountAppDisabled = 'account_app_disabled';
  static const String accountInactive = 'account_inactive';
  static const String clientNotAllowed = 'client_not_allowed';
  static const String forbidden = 'forbidden';
  static const String notFound = 'not_found';
  static const String otpExpired = 'otp_expired';
  static const String validationFailed = 'validation_failed';
  static const String appUpdateRequired = 'app_update_required';
  static const String tooManyRequests = 'too_many_requests';
  static const String otpUnavailable = 'otp_unavailable';
  static const String smsUnavailable = 'sms_unavailable';
  static const String maintenance = 'maintenance';
  static const String serverError = 'server_error';
}

/// خطأ من الـ API بالغلاف الموحّد: { message, code, errors, meta }
class ApiFailure implements Exception {
  const ApiFailure({
    required this.code,
    required this.message,
    this.status = 0,
    this.errors = const <String, List<String>>{},
    this.meta = const <String, dynamic>{},
    this.path = '',
  });

  final String code;
  final String message;
  final int status;
  final Map<String, List<String>> errors;
  final Map<String, dynamic> meta;

  /// مسار الطلب الذي فشل — يظهر في السطر الفني ويسهّل التشخيص.
  final String path;

  factory ApiFailure.network(String message, {String path = ''}) =>
      ApiFailure(code: ApiCode.network, message: message, path: path);

  factory ApiFailure.fromResponse(int status, dynamic body, {int? retryAfter, String path = ''}) {
    final Map<String, dynamic> map = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final Map<String, dynamic> meta = map['meta'] is Map ? Map<String, dynamic>.from(map['meta'] as Map) : <String, dynamic>{};
    if (retryAfter != null && !meta.containsKey('retry_after')) {
      meta['retry_after'] = retryAfter;
    }
    final Map<String, List<String>> errors = <String, List<String>>{};
    if (map['errors'] is Map) {
      (map['errors'] as Map).forEach((dynamic key, dynamic value) {
        errors['$key'] = value is List ? value.map((dynamic item) => '$item').toList() : <String>['$value'];
      });
    }

    return ApiFailure(
      code: (map['code'] as String?) ?? _codeForStatus(status),
      message: (map['message'] as String?) ?? '',
      status: status,
      errors: errors,
      meta: meta,
      path: path,
    );
  }

  /// سبب إضافي يرسله الخادم مع بعض الأخطاء (otp_wrong، signature_invalid، …)
  String? get reason => meta['reason'] as String?;

  int? get retryAfter => _int(meta['retry_after']);

  int? get attemptsLeft => _int(meta['attempts_left']);

  String? get minVersion => meta['min_version'] as String?;

  String? get storeUrl => meta['store_url'] as String?;

  bool get isNetwork => code == ApiCode.network;

  /// أول رسالة حقل — لإبرازها تحت الحقل في النموذج.
  String? fieldError(String field) {
    final List<String>? messages = errors[field];

    return messages == null || messages.isEmpty ? null : messages.first;
  }

  String get displayMessage {
    if (message.isNotEmpty) {
      return message;
    }
    for (final List<String> messages in errors.values) {
      if (messages.isNotEmpty) {
        return messages.first;
      }
    }

    return '';
  }

  @override
  String toString() => 'ApiFailure($code, $status, $path, $message)';

  static int? _int(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  static String _codeForStatus(int status) {
    switch (status) {
      case 401:
        return ApiCode.unauthenticated;
      case 403:
        return ApiCode.forbidden;
      case 404:
        return ApiCode.notFound;
      case 422:
        return ApiCode.validationFailed;
      case 429:
        return ApiCode.tooManyRequests;
      case 503:
        return ApiCode.maintenance;
      default:
        return status >= 500 ? ApiCode.serverError : 'bad_request';
    }
  }
}
