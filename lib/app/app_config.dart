/// نسختا التطبيق من نفس الكود.
enum AppFlavor { parent, staff }

/// إعدادات التشغيل — كلها قابلة للتغيير عند التشغيل بـ --dart-define بلا تعديل الكود:
///
/// flutter run --flavor parent -t lib/main_parent.dart \
///   --dart-define=API_BASE_URL=http://10.0.2.2 \
///   --dart-define=PARENT_API_KEY=... --dart-define=PARENT_API_SECRET=...
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.baseUrl,
    required this.apiKey,
    required this.apiSecret,
    this.signRequests = false,
  });

  final AppFlavor flavor;
  final String baseUrl;
  final String apiKey;
  final String apiSecret;

  /// وضع التوقيع HMAC بدل إرسال كلمة السر في كل طلب.
  final bool signRequests;

  static const String _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://nursery.local');
  static const String _apiKey = String.fromEnvironment('API_KEY');
  static const String _apiSecret = String.fromEnvironment('API_SECRET');
  static const String _parentKey = String.fromEnvironment('PARENT_API_KEY');
  static const String _parentSecret = String.fromEnvironment('PARENT_API_SECRET');
  static const String _staffKey = String.fromEnvironment('STAFF_API_KEY');
  static const String _staffSecret = String.fromEnvironment('STAFF_API_SECRET');
  static const bool _sign = bool.fromEnvironment('API_SIGN');

  factory AppConfig.fromEnvironment(AppFlavor flavor) {
    final bool isParent = flavor == AppFlavor.parent;
    final String key = isParent ? _parentKey : _staffKey;
    final String secret = isParent ? _parentSecret : _staffSecret;

    return AppConfig(
      flavor: flavor,
      baseUrl: _trimSlash(_baseUrl),
      apiKey: key.isNotEmpty ? key : _apiKey,
      apiSecret: secret.isNotEmpty ? secret : _apiSecret,
      signRequests: _sign,
    );
  }

  /// بادئة مسارات هذا التطبيق: /api/v1/parent أو /api/v1/staff
  String get portalPrefix => flavor == AppFlavor.parent ? '/api/v1/parent' : '/api/v1/staff';

  /// المسارات العامة (meta، health) خارج بوابة التطبيق.
  String get commonPrefix => '/api/v1';

  bool get isParent => flavor == AppFlavor.parent;

  bool get isStaff => flavor == AppFlavor.staff;

  bool get isConfigured => apiKey.isNotEmpty;

  static String _trimSlash(String value) => value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}
