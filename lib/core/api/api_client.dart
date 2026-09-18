import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../app/app_config.dart';
import '../native/native_bridge.dart';
import 'api_failure.dart';

/// ملف يُرفع في طلب multipart.
class UploadFile {
  const UploadFile({
    required this.field,
    required this.filename,
    required this.bytes,
    this.contentType = 'application/octet-stream',
  });

  final String field;
  final String filename;
  final List<int> bytes;
  final String contentType;
}

/// ملف نُزّل من مسار محمي (يحتاج ترويسات الاعتماد فلا يصلح فتحه في المتصفّح).
class DownloadedFile {
  const DownloadedFile({required this.bytes, required this.filename});

  final Uint8List bytes;
  final String filename;
}

typedef TokenProvider = String? Function();
typedef LocaleProvider = String Function();

/// عميل الـ API على HttpClient من dart:io — بلا مكتبات خارجية.
/// يضيف ترويسات التطبيق، ويفكّ الغلاف { data, meta }، ويحوّل الأخطاء إلى ApiFailure.
class ApiClient {
  ApiClient({
    required this.config,
    required this.tokenProvider,
    required this.localeProvider,
    this.onUnauthenticated,
    HttpClient? httpClient,
  }) : _http = httpClient ?? (HttpClient()..connectionTimeout = const Duration(seconds: 15));

  final AppConfig config;
  final TokenProvider tokenProvider;
  final LocaleProvider localeProvider;
  final void Function(ApiFailure failure)? onUnauthenticated;

  final HttpClient _http;

  static const Duration _timeout = Duration(seconds: 25);

  DeviceInfo? deviceInfo;

  Future<dynamic> get(String path, {Map<String, String>? query, bool common = false}) =>
      send('GET', path, query: query, common: common);

  /// مثل get لكنه يعيد الغلاف كاملاً { data, meta } — للقوائم ذات الترقيم والعدادات.
  Future<Map<String, dynamic>> getEnvelope(String path, {Map<String, String>? query}) =>
      sendEnvelope('GET', path, query: query);

  Future<dynamic> post(String path, {Map<String, dynamic>? body, String? idempotencyKey, bool common = false}) =>
      send('POST', path, body: body, idempotencyKey: idempotencyKey, common: common);

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) => send('PATCH', path, body: body);

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) => send('PUT', path, body: body);

  Future<dynamic> delete(String path, {Map<String, dynamic>? body}) => send('DELETE', path, body: body);

  Future<dynamic> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    String? idempotencyKey,
    bool common = false,
  }) async {
    final Map<String, dynamic> envelope = await sendEnvelope(
      method,
      path,
      body: body,
      query: query,
      idempotencyKey: idempotencyKey,
      common: common,
    );

    return envelope['data'];
  }

  /// ينفّذ الطلب ويعيد الغلاف كاملاً { data, meta }.
  Future<Map<String, dynamic>> sendEnvelope(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    String? idempotencyKey,
    bool common = false,
  }) async {
    final String prefix = common ? config.commonPrefix : config.portalPrefix;
    Uri uri = Uri.parse('${config.baseUrl}$prefix$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }
    final String payload = body == null ? '' : jsonEncode(body);

    try {
      final List<int> bytes = payload.isEmpty ? const <int>[] : utf8.encode(payload);
      final HttpClientRequest request = await _http.openUrl(method, uri).timeout(_timeout);
      _writeHeaders(
        request,
        method: method,
        uri: uri,
        body: bytes,
        contentType: 'application/json; charset=utf-8',
        idempotencyKey: idempotencyKey,
      );
      if (bytes.isNotEmpty) {
        request.add(bytes);
      }
      final HttpClientResponse response = await request.close().timeout(_timeout);
      final String text = await response.transform(utf8.decoder).join();

      return _handle(response, text, '$prefix$path');
    } on ApiFailure {
      rethrow;
    } on TimeoutException {
      throw ApiFailure.network('timeout', path: '$prefix$path');
    } on SocketException catch (error) {
      throw ApiFailure.network(error.message, path: '$prefix$path');
    } on HandshakeException catch (error) {
      throw ApiFailure.network(error.message, path: '$prefix$path');
    } on HttpException catch (error) {
      throw ApiFailure.network(error.message, path: '$prefix$path');
    }
  }

  /// تنزيل ملف ثنائي من مسار محمي (مرفق إجازة، مستند). اسم الملف من Content-Disposition.
  /// تنزيل رابط مطلق موقّع (مرفقات الأنشطة) — بلا ترويسات التطبيق لأن التوقيع في الرابط.
  Future<DownloadedFile> downloadUrl(String url, {String fallbackName = 'file'}) async {
    final Uri uri = Uri.parse(url);
    try {
      final HttpClientRequest request = await _http.openUrl('GET', uri).timeout(_timeout);
      final HttpClientResponse response = await request.close().timeout(const Duration(seconds: 90));
      final BytesBuilder builder = BytesBuilder();
      await for (final List<int> chunk in response) {
        builder.add(chunk);
      }
      final Uint8List bytes = builder.takeBytes();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiFailure(
          code: ApiCode.serverError,
          message: '',
          status: response.statusCode,
          path: uri.path,
        );
      }

      return DownloadedFile(bytes: bytes, filename: _filename(response, fallbackName));
    } on ApiFailure {
      rethrow;
    } on TimeoutException {
      throw ApiFailure.network('timeout', path: uri.path);
    } on SocketException catch (error) {
      throw ApiFailure.network(error.message, path: uri.path);
    }
  }

  Future<DownloadedFile> download(String path, {String fallbackName = 'file'}) async {
    final Uri uri = Uri.parse('${config.baseUrl}${config.portalPrefix}$path');
    try {
      final HttpClientRequest request = await _http.openUrl('GET', uri).timeout(_timeout);
      _writeHeaders(
        request,
        method: 'GET',
        uri: uri,
        body: const <int>[],
        contentType: 'application/json; charset=utf-8',
      );
      final HttpClientResponse response = await request.close().timeout(const Duration(seconds: 90));
      final BytesBuilder builder = BytesBuilder();
      await for (final List<int> chunk in response) {
        builder.add(chunk);
      }
      final Uint8List bytes = builder.takeBytes();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        // يرمي ApiFailure بالرسالة القادمة من الخادم
        _handle(response, utf8.decode(bytes, allowMalformed: true), '${config.portalPrefix}$path');
      }

      return DownloadedFile(bytes: bytes, filename: _filename(response, fallbackName));
    } on ApiFailure {
      rethrow;
    } on TimeoutException {
      throw ApiFailure.network('timeout', path: '${config.portalPrefix}$path');
    } on SocketException catch (error) {
      throw ApiFailure.network(error.message, path: '${config.portalPrefix}$path');
    } on HttpException catch (error) {
      throw ApiFailure.network(error.message, path: '${config.portalPrefix}$path');
    }
  }

  static String _filename(HttpClientResponse response, String fallback) {
    final String disposition = response.headers.value('content-disposition') ?? '';
    final RegExpMatch? match = RegExp(r'filename[^=]*=\s*"?([^";]+)').firstMatch(disposition);
    if (match == null) {
      return fallback;
    }
    final String name = match.group(1)!.trim();

    return name.isEmpty ? fallback : Uri.decodeComponent(name);
  }

  /// رفع ملفات بصيغة multipart/form-data — مبني يدوياً بلا مكتبة HTTP.
  Future<dynamic> upload(
    String path, {
    Map<String, String> fields = const <String, String>{},
    List<UploadFile> files = const <UploadFile>[],
    String? idempotencyKey,
  }) async {
    final Uri uri = Uri.parse('${config.baseUrl}${config.portalPrefix}$path');
    final String boundary = '----nsm${DateTime.now().microsecondsSinceEpoch}';
    final BytesBuilder builder = BytesBuilder();

    fields.forEach((String name, String value) {
      builder.add(utf8.encode('--$boundary\r\nContent-Disposition: form-data; name="$name"\r\n\r\n$value\r\n'));
    });
    for (final UploadFile file in files) {
      builder.add(utf8.encode('--$boundary\r\nContent-Disposition: form-data; name="${file.field}"; '
          'filename="${file.filename}"\r\nContent-Type: ${file.contentType}\r\n\r\n'));
      builder.add(file.bytes);
      builder.add(utf8.encode('\r\n'));
    }
    builder.add(utf8.encode('--$boundary--\r\n'));
    final List<int> body = builder.takeBytes();

    try {
      final HttpClientRequest request = await _http.openUrl('POST', uri).timeout(_timeout);
      _writeHeaders(
        request,
        method: 'POST',
        uri: uri,
        body: body,
        contentType: 'multipart/form-data; boundary=$boundary',
        idempotencyKey: idempotencyKey,
      );
      request.add(body);
      final HttpClientResponse response = await request.close().timeout(const Duration(seconds: 90));
      final String text = await response.transform(utf8.decoder).join();

      return _handle(response, text, '${config.portalPrefix}$path')['data'];
    } on ApiFailure {
      rethrow;
    } on TimeoutException {
      throw ApiFailure.network('timeout', path: '${config.portalPrefix}$path');
    } on SocketException catch (error) {
      throw ApiFailure.network(error.message, path: '${config.portalPrefix}$path');
    } on HttpException catch (error) {
      throw ApiFailure.network(error.message, path: '${config.portalPrefix}$path');
    }
  }

  void _writeHeaders(
    HttpClientRequest request, {
    required String method,
    required Uri uri,
    required List<int> body,
    required String contentType,
    String? idempotencyKey,
  }) {
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.contentTypeHeader, contentType);
    request.headers.set(HttpHeaders.acceptLanguageHeader, localeProvider());
    request.headers.set('X-Api-Key', config.apiKey);

    final DeviceInfo? device = deviceInfo;
    if (device != null) {
      request.headers.set('X-App-Platform', device.platform);
      if (device.appVersion.isNotEmpty) {
        request.headers.set('X-App-Version', device.appVersion);
      }
    }

    if (config.signRequests && config.apiSecret.isNotEmpty) {
      final String timestamp = '${DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000}';
      final String requestUri = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
      request.headers.set('X-Api-Timestamp', timestamp);
      request.headers.set('X-Api-Signature', _signature(method, requestUri, timestamp, body));
    } else if (config.apiSecret.isNotEmpty) {
      request.headers.set('X-Api-Secret', config.apiSecret);
    }

    final String? token = tokenProvider();
    if (token != null && token.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (idempotencyKey != null) {
      request.headers.set('Idempotency-Key', idempotencyKey);
    }
  }

  /// نفس صيغة الخادم: HMAC-SHA256 على "METHOD\npath\ntimestamp\nsha256(body)"
  String _signature(String method, String path, String timestamp, List<int> body) {
    final String bodyHash = sha256.convert(body).toString();
    final String message = '${method.toUpperCase()}\n$path\n$timestamp\n$bodyHash';

    return Hmac(sha256, utf8.encode(config.apiSecret)).convert(utf8.encode(message)).toString();
  }

  Map<String, dynamic> _handle(HttpClientResponse response, String text, String path) {
    dynamic decoded;
    if (text.isNotEmpty) {
      try {
        decoded = jsonDecode(text);
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    }

    final ApiFailure failure = ApiFailure.fromResponse(
      response.statusCode,
      decoded,
      retryAfter: int.tryParse(response.headers.value('retry-after') ?? ''),
      path: path,
    );
    if (failure.code == ApiCode.unauthenticated) {
      onUnauthenticated?.call(failure);
    }

    throw failure;
  }

  void close() => _http.close(force: true);
}
