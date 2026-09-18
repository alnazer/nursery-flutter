import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/models/auth_session.dart';
import '../../../core/native/native_bridge.dart';
import '../../session/session_cubit.dart';

enum BiometricPhase {
  idle,
  working,
  enabled,
  signedIn,
  disabled,
  failed,
  reauthRequired,
  revoked,
  unavailable,
}

class BiometricState {
  const BiometricState({this.phase = BiometricPhase.idle, this.failure, this.error});

  final BiometricPhase phase;
  final ApiFailure? failure;
  final BiometricError? error;

  bool get busy => phase == BiometricPhase.working;

  int? get attemptsLeft => failure?.attemptsLeft;
}

/// الدخول بالبصمة وتفعيلها وإيقافها — يتكلم مع الخادم ومع Keystore/Secure Enclave.
class BiometricCubit extends Cubit<BiometricState> {
  BiometricCubit({required this.api, required this.session, required this.native})
      : super(const BiometricState());

  final AuthApi api;
  final SessionCubit session;
  final NativeBridge native;

  /// تفعيل البصمة بعد الدخول مباشرة (يُقبل خلال 15 دقيقة).
  Future<void> enable() async {
    if (state.busy) {
      return;
    }
    emit(const BiometricState(phase: BiometricPhase.working));
    try {
      final BiometricStatus status = await native.biometricStatus();
      if (status != BiometricStatus.available) {
        emit(BiometricState(
          phase: BiometricPhase.unavailable,
          error: BiometricError(status == BiometricStatus.notEnrolled ? 'not_enrolled' : 'unavailable'),
        ));

        return;
      }
      final String publicKey = await native.createBiometricKey();
      final BiometricRegistration registration = await api.registerBiometric(
        publicKey: publicKey,
        deviceId: session.state.deviceId,
        deviceName: session.state.device.deviceName,
      );
      await session.biometricEnabled(registration.keyId, session.state.session?.userName ?? '');
      emit(const BiometricState(phase: BiometricPhase.enabled));
    } on ApiFailure catch (failure) {
      await native.deleteBiometricKey();
      emit(BiometricState(
        phase: failure.code == ApiCode.reauthRequired ? BiometricPhase.reauthRequired : BiometricPhase.failed,
        failure: failure,
      ));
    } on BiometricError catch (error) {
      await native.deleteBiometricKey();
      emit(BiometricState(
        phase: error.isCancelled ? BiometricPhase.idle : BiometricPhase.unavailable,
        error: error,
      ));
    }
  }

  /// الدخول بالبصمة: تحدٍّ ← توقيع بعد البصمة ← تحقق.
  Future<void> signIn({
    required String promptTitle,
    required String promptSubtitle,
    required String cancelLabel,
  }) async {
    final StoredBiometricRef? stored = _stored();
    if (stored == null || state.busy) {
      return;
    }
    emit(const BiometricState(phase: BiometricPhase.working));
    try {
      final String challenge = await api.biometricChallenge(stored.keyId);
      final String signature = await native.sign(
        message: api.signedMessage(keyId: stored.keyId, challenge: challenge),
        title: promptTitle,
        subtitle: promptSubtitle,
        cancel: cancelLabel,
      );
      final AuthSession issued = await api.biometricVerify(
        keyId: stored.keyId,
        challenge: challenge,
        signature: signature,
        deviceName: session.state.device.deviceName,
      );
      await session.signedIn(issued);
      emit(const BiometricState(phase: BiometricPhase.signedIn));
    } on ApiFailure catch (failure) {
      if (failure.code == ApiCode.biometricInvalid && failure.reason == 'key_revoked') {
        await session.biometricCleared();
        emit(BiometricState(phase: BiometricPhase.revoked, failure: failure));

        return;
      }
      emit(BiometricState(phase: BiometricPhase.failed, failure: failure));
    } on BiometricError catch (error) {
      if (error.keyGone) {
        await session.biometricCleared();
        emit(BiometricState(phase: BiometricPhase.revoked, error: error));

        return;
      }
      emit(BiometricState(
        phase: error.isCancelled ? BiometricPhase.idle : BiometricPhase.failed,
        error: error,
      ));
    }
  }

  /// إيقاف البصمة على هذا الجهاز (يحذف المفتاح هنا وعلى الخادم).
  Future<void> disable() async {
    emit(const BiometricState(phase: BiometricPhase.working));
    try {
      await api.removeBiometric(deviceId: session.state.deviceId);
    } on ApiFailure {
      // الحذف المحلي يتم في كل الأحوال
    }
    await session.biometricCleared();
    emit(const BiometricState(phase: BiometricPhase.disabled));
  }

  void reset() => emit(const BiometricState());

  StoredBiometricRef? _stored() {
    final String? keyId = session.state.biometric?.keyId;

    return keyId == null || keyId.isEmpty ? null : StoredBiometricRef(keyId);
  }
}

class StoredBiometricRef {
  const StoredBiometricRef(this.keyId);

  final String keyId;
}
