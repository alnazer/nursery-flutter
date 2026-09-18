import 'package:flutter_test/flutter_test.dart';
import 'package:nursery/app/app_config.dart';
import 'package:nursery/core/api/api_client.dart';
import 'package:nursery/core/api/api_failure.dart';
import 'package:nursery/core/api/auth_api.dart';
import 'package:nursery/core/api/auth_holder.dart';
import 'package:nursery/core/models/auth_session.dart';
import 'package:nursery/core/native/native_bridge.dart';
import 'package:nursery/core/storage/session_store.dart';
import 'package:nursery/features/auth/cubit/biometric_cubit.dart';
import 'package:nursery/features/auth/cubit/login_cubit.dart';
import 'package:nursery/features/auth/cubit/otp_cubit.dart';
import 'package:nursery/features/session/session_cubit.dart';

const AppConfig _config = AppConfig(
  flavor: AppFlavor.parent,
  baseUrl: 'https://nursery.test',
  apiKey: 'key',
  apiSecret: 'secret',
);

/// عميل وهمي: يعيد ردوداً جاهزة لكل مسار بلا شبكة.
class FakeApiClient extends ApiClient {
  FakeApiClient(this.responses)
      : super(
          config: _config,
          tokenProvider: _noToken,
          localeProvider: _arabic,
        );

  final Map<String, Object?> responses;
  final List<String> calls = <String>[];

  static String? _noToken() => null;

  static String _arabic() => 'ar';

  @override
  Future<dynamic> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    String? idempotencyKey,
    bool common = false,
  }) async {
    calls.add(path);
    final Object? response = responses[path];
    if (response is ApiFailure) {
      throw response;
    }

    return response;
  }
}

/// جسر وهمي: لا قناة أصلية في الاختبارات.
class FakeNative extends NativeBridge {
  const FakeNative({this.signature = 'sig', this.status = BiometricStatus.available});

  final String signature;
  final BiometricStatus status;

  @override
  Future<BiometricStatus> biometricStatus() async => status;

  @override
  Future<bool> hasBiometricKey() async => true;

  @override
  Future<String> createBiometricKey() async => 'public-key';

  @override
  Future<void> deleteBiometricKey() async {}

  @override
  Future<String> sign({
    required String message,
    required String title,
    required String subtitle,
    required String cancel,
  }) async =>
      signature;

  @override
  Future<String?> secureRead(String key) async => null;

  @override
  Future<void> secureWrite(String key, String? value) async {}

  @override
  Future<DeviceInfo> deviceInfo() async => const DeviceInfo(
        platform: 'android',
        deviceName: 'Test Device',
        osVersion: '14',
        appVersion: '1.0.0',
        appBuild: 1,
      );
}

SessionCubit buildSession(FakeApiClient client, {NativeBridge native = const FakeNative()}) {
  final AuthApi api = AuthApi(client);

  return SessionCubit(
    config: _config,
    api: api,
    client: client,
    store: SessionStore(native),
    native: native,
    holder: AuthHolder(),
  );
}

Map<String, Object?> tokenResponse({int replacedDevices = 0}) => <String, Object?>{
      'otp_required': false,
      'token': '12|token',
      'token_type': 'Bearer',
      'expires_at': '2026-12-21T08:00:00+03:00',
      'user': <String, Object?>{'id': 7, 'name': 'منى'},
      'replaced_devices': replacedDevices,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginCubit', () {
    test('رد otp_required ينقل الشاشة إلى رمز التحقق', () async {
      final FakeApiClient client = FakeApiClient(<String, Object?>{
        '/auth/login': <String, Object?>{
          'otp_required': true,
          'challenge': 'abc',
          'length': 6,
          'expires_in': 600,
          'resend_in': 60,
          'mobile': '+965 5551 ••45',
        },
      });
      final SessionCubit session = buildSession(client);
      final LoginCubit cubit = LoginCubit(api: AuthApi(client), session: session);

      await cubit.parentMobile('55512345');

      expect(cubit.state.phase, LoginPhase.otp);
      expect(cubit.state.challenge?.challenge, 'abc');
      expect(cubit.state.challenge?.target, '+965 5551 ••45');
      expect(session.state.status, isNot(SessionStatus.signedIn));
    });

    test('الدخول المباشر يفتح الجلسة', () async {
      final FakeApiClient client = FakeApiClient(<String, Object?>{'/auth/login': tokenResponse()});
      final SessionCubit session = buildSession(client);
      final LoginCubit cubit = LoginCubit(api: AuthApi(client), session: session);

      await cubit.parentMobile('55512345');

      expect(cubit.state.phase, LoginPhase.done);
      expect(session.state.status, SessionStatus.signedIn);
      expect(session.state.session?.userName, 'منى');
    });

    test('خطأ التحقق يبقي الشاشة ويعرض رسالة الحقل', () async {
      final FakeApiClient client = FakeApiClient(<String, Object?>{
        '/auth/login': const ApiFailure(
          code: ApiCode.validationFailed,
          message: 'هذا الرقم غير مسجّل لأي ولي أمر.',
          status: 422,
          errors: <String, List<String>>{
            'mobile': <String>['هذا الرقم غير مسجّل لأي ولي أمر.'],
          },
          meta: <String, dynamic>{'reason': 'not_registered'},
        ),
      });
      final LoginCubit cubit = LoginCubit(api: AuthApi(client), session: buildSession(client));

      await cubit.parentMobile('99999999');

      expect(cubit.state.phase, LoginPhase.idle);
      expect(cubit.state.failure?.reason, 'not_registered');
      expect(cubit.state.failure?.fieldError('mobile'), isNotNull);
    });
  });

  group('OtpCubit', () {
    const OtpChallenge challenge = OtpChallenge(
      challenge: 'abc',
      length: 6,
      expiresIn: 600,
      resendIn: 60,
      target: '+965 5551 ••45',
    );

    test('الرمز الصحيح يفتح الجلسة', () async {
      final FakeApiClient client = FakeApiClient(<String, Object?>{'/auth/otp/verify': tokenResponse()});
      final SessionCubit session = buildSession(client);
      final OtpCubit cubit = OtpCubit(api: AuthApi(client), session: session, challenge: challenge);

      await cubit.verify('482913');

      expect(cubit.state.phase, OtpPhase.done);
      expect(session.state.status, SessionStatus.signedIn);
      await cubit.close();
    });

    test('انتهاء التحدي يوقف المحاولة', () async {
      final FakeApiClient client = FakeApiClient(<String, Object?>{
        '/auth/otp/verify': const ApiFailure(
          code: ApiCode.otpExpired,
          message: 'انتهت صلاحية الرمز، اطلب رمزاً جديداً.',
          status: 410,
        ),
      });
      final OtpCubit cubit = OtpCubit(api: AuthApi(client), session: buildSession(client), challenge: challenge);

      await cubit.verify('000000');

      expect(cubit.state.phase, OtpPhase.expired);
      await cubit.close();
    });
  });

  group('BiometricCubit', () {
    test('التفعيل يحفظ المفتاح ويجعل زر البصمة متاحاً', () async {
      final FakeApiClient client = FakeApiClient(<String, Object?>{
        '/auth/login': tokenResponse(),
        '/auth/biometric': <String, Object?>{'key_id': 'bk_1', 'algorithm': 'ES256'},
      });
      const FakeNative native = FakeNative();
      final SessionCubit session = buildSession(client, native: native);
      final AuthApi api = AuthApi(client);
      await LoginCubit(api: api, session: session).parentMobile('55512345');
      final BiometricCubit cubit = BiometricCubit(api: api, session: session, native: native);

      await cubit.enable();

      expect(cubit.state.phase, BiometricPhase.enabled);
      expect(session.state.biometric?.keyId, 'bk_1');
    });

    test('مفتاح ملغى: يُحذف من الجهاز وتُعرض رسالة', () async {
      final FakeApiClient client = FakeApiClient(<String, Object?>{
        '/auth/biometric/challenge': <String, Object?>{'challenge': 'q8V0', 'expires_in': 120},
        '/auth/biometric/verify': const ApiFailure(
          code: ApiCode.biometricInvalid,
          message: 'أُلغي الدخول بالبصمة على هذا الجهاز.',
          status: 401,
          meta: <String, dynamic>{'reason': 'key_revoked'},
        ),
      });
      const FakeNative native = FakeNative();
      final SessionCubit session = buildSession(client, native: native);
      await session.biometricEnabled('bk_1', 'منى');
      final BiometricCubit cubit = BiometricCubit(api: AuthApi(client), session: session, native: native);

      await cubit.signIn(promptTitle: 't', promptSubtitle: 's', cancelLabel: 'c');

      expect(cubit.state.phase, BiometricPhase.revoked);
      expect(session.state.biometric, isNull);
    });

    test('توقيع صحيح يفتح الجلسة', () async {
      final FakeApiClient client = FakeApiClient(<String, Object?>{
        '/auth/biometric/challenge': <String, Object?>{'challenge': 'q8V0', 'expires_in': 120},
        '/auth/biometric/verify': tokenResponse(replacedDevices: 1),
      });
      const FakeNative native = FakeNative();
      final SessionCubit session = buildSession(client, native: native);
      await session.biometricEnabled('bk_1', 'منى');
      final BiometricCubit cubit = BiometricCubit(api: AuthApi(client), session: session, native: native);

      await cubit.signIn(promptTitle: 't', promptSubtitle: 's', cancelLabel: 'c');

      expect(cubit.state.phase, BiometricPhase.signedIn);
      expect(session.state.status, SessionStatus.signedIn);
      expect(session.state.notice, SessionNotice.staffReplaced);
      expect(client.calls, contains('/auth/biometric/verify'));
    });
  });

  test('نص التوقيع يطابق ما يتوقعه الخادم', () {
    final AuthApi api = AuthApi(FakeApiClient(<String, Object?>{}));

    expect(
      api.signedMessage(keyId: 'bk_1', challenge: 'q8V0'),
      'nsm-biometric-v1\nkey\nbk_1\nq8V0',
    );
  });
}
