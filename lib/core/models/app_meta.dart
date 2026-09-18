/// رد GET /api/v1/meta — ما يحتاجه التطبيق قبل الدخول.
class AppMeta {
  const AppMeta({
    required this.name,
    required this.logoUrl,
    required this.locales,
    required this.currency,
    required this.parentLoginMode,
    required this.biometricLogin,
    required this.pushEnabled,
    required this.singleDevice,
    required this.minVersion,
    required this.latestVersion,
    required this.storeUrl,
    required this.demo,
  });

  final String name;
  final String? logoUrl;
  final List<String> locales;
  final String currency;

  /// mobile_only | mobile_otp | password
  final String parentLoginMode;
  final bool biometricLogin;
  final bool pushEnabled;
  final bool singleDevice;
  final String? minVersion;
  final String? latestVersion;
  final String? storeUrl;
  final bool demo;

  static const AppMeta fallback = AppMeta(
    name: '',
    logoUrl: null,
    locales: <String>['ar', 'en'],
    currency: 'KWD',
    parentLoginMode: 'mobile_otp',
    biometricLogin: true,
    pushEnabled: false,
    singleDevice: false,
    minVersion: null,
    latestVersion: null,
    storeUrl: null,
    demo: false,
  );

  bool get usesPassword => parentLoginMode == 'password';

  bool get needsOtp => parentLoginMode == 'mobile_otp';

  factory AppMeta.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> app = json['app'] is Map ? Map<String, dynamic>.from(json['app'] as Map) : <String, dynamic>{};

    return AppMeta(
      name: (json['name'] as String?) ?? '',
      logoUrl: json['logo_url'] as String?,
      locales: json['locales'] is List
          ? (json['locales'] as List).map((dynamic item) => '$item').toList()
          : const <String>['ar', 'en'],
      currency: (json['currency'] as String?) ?? 'KWD',
      parentLoginMode: (json['parent_login_mode'] as String?) ?? 'mobile_otp',
      biometricLogin: json['biometric_login'] == true,
      pushEnabled: json['push_enabled'] == true,
      singleDevice: app['single_device'] == true,
      minVersion: app['min_version'] as String?,
      latestVersion: app['latest_version'] as String?,
      storeUrl: app['store_url'] as String?,
      demo: json['demo'] == true,
    );
  }
}
