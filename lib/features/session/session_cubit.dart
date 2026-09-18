import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_config.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_failure.dart';
import '../../core/api/auth_api.dart';
import '../../core/api/auth_holder.dart';
import '../../core/models/app_meta.dart';
import '../../core/models/auth_session.dart';
import '../../core/native/native_bridge.dart';
import '../../core/storage/session_store.dart';
import '../../core/util/children_cache.dart';
import '../common/salary_privacy.dart';
import '../../core/util/staff_abilities.dart';

enum SessionStatus { loading, signedOut, signedIn, blocked }

/// رسائل تُعرض مرة واحدة بعد تغيّر الحالة.
enum SessionNotice { sessionExpired, signedOut, staffReplaced, biometricRevoked }

class SessionState {
  const SessionState({
    this.status = SessionStatus.loading,
    this.meta = AppMeta.fallback,
    this.session,
    this.biometric,
    this.biometricStatus = BiometricStatus.unavailable,
    this.device = DeviceInfo.unknown,
    this.deviceId = '',
    this.blocker,
    this.notice,
    this.locale = 'ar',
    this.promptBiometric = false,
  });

  final SessionStatus status;
  final AppMeta meta;
  final AuthSession? session;
  final StoredBiometric? biometric;
  final BiometricStatus biometricStatus;
  final DeviceInfo device;
  final String deviceId;

  /// خطأ يمنع الاستخدام: صيانة، تحديث إلزامي، إعداد خاطئ، أو انقطاع الشبكة عند الإقلاع.
  final ApiFailure? blocker;
  final SessionNotice? notice;
  final String locale;

  /// دخل للتو ولم يفعّل البصمة بعد: نعرض عليه شاشة التفعيل مرة واحدة.
  final bool promptBiometric;

  /// هل نعرض زر البصمة داخل شاشة الدخول؟
  bool get canUseBiometric =>
      meta.biometricLogin && biometric != null && biometricStatus == BiometricStatus.available;

  String get biometricUserName => biometric?.userName ?? '';

  SessionState copyWith({
    SessionStatus? status,
    AppMeta? meta,
    AuthSession? session,
    bool clearSession = false,
    StoredBiometric? biometric,
    bool clearBiometric = false,
    BiometricStatus? biometricStatus,
    DeviceInfo? device,
    String? deviceId,
    ApiFailure? blocker,
    bool clearBlocker = false,
    SessionNotice? notice,
    bool clearNotice = false,
    String? locale,
    bool? promptBiometric,
  }) =>
      SessionState(
        status: status ?? this.status,
        meta: meta ?? this.meta,
        session: clearSession ? null : session ?? this.session,
        biometric: clearBiometric ? null : biometric ?? this.biometric,
        biometricStatus: biometricStatus ?? this.biometricStatus,
        device: device ?? this.device,
        deviceId: deviceId ?? this.deviceId,
        blocker: clearBlocker ? null : blocker ?? this.blocker,
        notice: clearNotice ? null : notice ?? this.notice,
        locale: locale ?? this.locale,
        promptBiometric: promptBiometric ?? this.promptBiometric,
      );
}

/// الحالة العامة للتطبيق: الإقلاع، ومن هو المستخدم، وهل البصمة جاهزة.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required this.config,
    required this.api,
    required this.client,
    required this.store,
    required this.native,
    required this.holder,
  }) : super(const SessionState());

  final AppConfig config;
  final AuthApi api;
  final ApiClient client;
  final SessionStore store;
  final NativeBridge native;
  final AuthHolder holder;

  Future<void> bootstrap() async {
    emit(state.copyWith(status: SessionStatus.loading, clearBlocker: true));

    final DeviceInfo device = await native.deviceInfo();
    client.deviceInfo = device;

    final String deviceId = await store.deviceId();
    final AuthSession? session = await store.readSession();
    holder.token = session?.token;

    final String locale = await store.readLocale() ?? state.locale;
    holder.locale = locale;

    StoredBiometric? biometric = await store.readBiometric();
    final BiometricStatus biometricStatus = await native.biometricStatus();
    if (biometric != null && !await native.hasBiometricKey()) {
      // المفتاح اختفى من الجهاز (إعادة تثبيت أو تغيّر البصمات المسجّلة)
      await store.clearBiometric();
      biometric = null;
    }

    emit(state.copyWith(
      device: device,
      deviceId: deviceId,
      session: session,
      clearSession: session == null,
      biometric: biometric,
      clearBiometric: biometric == null,
      biometricStatus: biometricStatus,
      locale: locale,
    ));

    await refreshMeta(signedIn: session != null);
  }

  Future<void> refreshMeta({bool signedIn = false}) async {
    if (!config.isConfigured) {
      emit(state.copyWith(
        status: SessionStatus.blocked,
        blocker: const ApiFailure(code: ApiCode.invalidClient, message: ''),
      ));

      return;
    }
    try {
      final AppMeta meta = await api.meta();
      emit(state.copyWith(
        meta: meta,
        clearBlocker: true,
        status: signedIn || state.session != null ? SessionStatus.signedIn : SessionStatus.signedOut,
      ));
    } on ApiFailure catch (failure) {
      if (failure.isNetwork && state.session != null) {
        // بلا إنترنت مع جلسة محفوظة: نكمل ونحاول لاحقاً
        emit(state.copyWith(status: SessionStatus.signedIn));

        return;
      }
      emit(state.copyWith(status: SessionStatus.blocked, blocker: failure));
    }
  }

  Future<void> signedIn(AuthSession session) async {
    holder.token = session.token;
    await store.writeSession(session);
    final bool offerBiometric = state.meta.biometricLogin &&
        state.biometric == null &&
        state.biometricStatus == BiometricStatus.available;
    emit(state.copyWith(
      promptBiometric: offerBiometric,
      status: SessionStatus.signedIn,
      session: session,
      clearBlocker: true,
      notice: session.replacedDevices > 0 ? SessionNotice.staffReplaced : null,
      clearNotice: session.replacedDevices == 0,
    ));
  }

  Future<void> signOut({bool forgetBiometric = false}) async {
    try {
      await api.logout(forgetBiometric: forgetBiometric);
    } on ApiFailure {
      // الخروج محلي في كل الأحوال
    }
    if (forgetBiometric) {
      await native.deleteBiometricKey();
      await store.clearBiometric();
    }
    await store.writeSession(null);
    holder.token = null;
    ChildrenCache.clear();
    StaffAbilities.clear();
    SalaryVisibility.reset();
    emit(state.copyWith(
      status: SessionStatus.signedOut,
      clearSession: true,
      clearBiometric: forgetBiometric,
      notice: SessionNotice.signedOut,
      promptBiometric: false,
    ));
  }

  /// الرمز لم يعد صالحاً (انتهى، أو دخول من جهاز آخر).
  Future<void> expired() async {
    await store.writeSession(null);
    holder.token = null;
    ChildrenCache.clear();
    StaffAbilities.clear();
    SalaryVisibility.reset();
    emit(state.copyWith(
      status: SessionStatus.signedOut,
      clearSession: true,
      notice: SessionNotice.sessionExpired,
      promptBiometric: false,
    ));
  }

  Future<void> biometricEnabled(String keyId, String userName) async {
    await store.writeBiometric(keyId, userName);
    emit(state.copyWith(
      biometric: StoredBiometric(keyId: keyId, userName: userName),
      promptBiometric: false,
    ));
  }

  /// البصمة أُلغيت على الخادم أو على الجهاز.
  Future<void> biometricCleared({bool notify = false}) async {
    await native.deleteBiometricKey();
    await store.clearBiometric();
    emit(state.copyWith(
      clearBiometric: true,
      notice: notify ? SessionNotice.biometricRevoked : null,
      clearNotice: !notify,
    ));
  }

  Future<void> setLocale(String locale) async {
    holder.locale = locale;
    await store.writeLocale(locale);
    emit(state.copyWith(locale: locale));
  }

  void consumeNotice() => emit(state.copyWith(clearNotice: true));

  void consumeBiometricPrompt() => emit(state.copyWith(promptBiometric: false));
}
