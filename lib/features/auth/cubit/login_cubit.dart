import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/models/auth_session.dart';
import '../../session/session_cubit.dart';

enum LoginPhase { idle, submitting, otp, done }

class LoginState {
  const LoginState({
    this.phase = LoginPhase.idle,
    this.failure,
    this.challenge,
    this.obscure = true,
  });

  final LoginPhase phase;
  final ApiFailure? failure;
  final OtpChallenge? challenge;
  final bool obscure;

  bool get busy => phase == LoginPhase.submitting;

  LoginState copyWith({
    LoginPhase? phase,
    ApiFailure? failure,
    bool clearFailure = false,
    OtpChallenge? challenge,
    bool clearChallenge = false,
    bool? obscure,
  }) =>
      LoginState(
        phase: phase ?? this.phase,
        failure: clearFailure ? null : failure ?? this.failure,
        challenge: clearChallenge ? null : challenge ?? this.challenge,
        obscure: obscure ?? this.obscure,
      );
}

/// شاشة الدخول للتطبيقين: جوال، أو جوال + رمز، أو اسم/بريد + كلمة مرور.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this.api, required this.session}) : super(const LoginState());

  final AuthApi api;
  final SessionCubit session;

  Future<void> parentMobile(String mobile) => _run(() => api.parentLogin(
        mobile: mobile.trim(),
        deviceId: session.state.deviceId,
        deviceName: session.state.device.deviceName,
      ));

  Future<void> parentPassword(String login, String password) => _run(() => api.parentLogin(
        login: login.trim(),
        password: password,
        deviceId: session.state.deviceId,
        deviceName: session.state.device.deviceName,
      ));

  Future<void> staffLogin(String username, String password) => _run(() => api.staffLogin(
        username: username.trim(),
        password: password,
        deviceId: session.state.deviceId,
        deviceName: session.state.device.deviceName,
      ));

  void toggleObscure() => emit(state.copyWith(obscure: !state.obscure));

  void clearFailure() => emit(state.copyWith(clearFailure: true));

  /// بعد العودة من شاشة الرمز بلا نجاح.
  void reset() => emit(const LoginState());

  Future<void> _run(Future<LoginResult> Function() call) async {
    if (state.busy) {
      return;
    }
    emit(state.copyWith(phase: LoginPhase.submitting, clearFailure: true, clearChallenge: true));
    try {
      final LoginResult result = await call();
      final OtpChallenge? challenge = result.challenge;
      if (challenge != null) {
        emit(state.copyWith(phase: LoginPhase.otp, challenge: challenge));

        return;
      }
      final AuthSession? issued = result.session;
      if (issued == null) {
        emit(state.copyWith(
          phase: LoginPhase.idle,
          failure: const ApiFailure(code: ApiCode.serverError, message: ''),
        ));

        return;
      }
      await session.signedIn(issued);
      emit(state.copyWith(phase: LoginPhase.done));
    } on ApiFailure catch (failure) {
      emit(state.copyWith(phase: LoginPhase.idle, failure: failure));
    }
  }
}
