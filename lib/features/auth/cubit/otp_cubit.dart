import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/models/auth_session.dart';
import '../../session/session_cubit.dart';

enum OtpPhase { idle, verifying, resending, done, expired }

class OtpState {
  const OtpState({
    required this.challenge,
    this.phase = OtpPhase.idle,
    this.failure,
    this.secondsToResend = 0,
    this.resent = false,
  });

  final OtpChallenge challenge;
  final OtpPhase phase;
  final ApiFailure? failure;
  final int secondsToResend;
  final bool resent;

  bool get busy => phase == OtpPhase.verifying || phase == OtpPhase.resending;

  bool get canResend => secondsToResend <= 0 && !busy && phase != OtpPhase.done;

  OtpState copyWith({
    OtpChallenge? challenge,
    OtpPhase? phase,
    ApiFailure? failure,
    bool clearFailure = false,
    int? secondsToResend,
    bool? resent,
  }) =>
      OtpState(
        challenge: challenge ?? this.challenge,
        phase: phase ?? this.phase,
        failure: clearFailure ? null : failure ?? this.failure,
        secondsToResend: secondsToResend ?? this.secondsToResend,
        resent: resent ?? this.resent,
      );
}

/// رمز التحقق: تأكيد، وإعادة إرسال بعدّاد، وانتهاء الصلاحية.
class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required this.api,
    required this.session,
    required OtpChallenge challenge,
  }) : super(OtpState(challenge: challenge, secondsToResend: challenge.resendIn)) {
    _startTicker();
  }

  final AuthApi api;
  final SessionCubit session;

  Timer? _timer;

  void _startTicker() {
    _timer?.cancel();
    if (state.secondsToResend <= 0) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final int next = state.secondsToResend - 1;
      if (next <= 0) {
        timer.cancel();
      }
      if (!isClosed) {
        emit(state.copyWith(secondsToResend: next < 0 ? 0 : next));
      }
    });
  }

  Future<void> verify(String code) async {
    if (state.busy) {
      return;
    }
    emit(state.copyWith(phase: OtpPhase.verifying, clearFailure: true, resent: false));
    try {
      final LoginResult result = await api.verifyOtp(challenge: state.challenge.challenge, code: code.trim());
      final AuthSession? issued = result.session;
      if (issued == null) {
        emit(state.copyWith(phase: OtpPhase.idle, failure: const ApiFailure(code: ApiCode.serverError, message: '')));

        return;
      }
      await session.signedIn(issued);
      emit(state.copyWith(phase: OtpPhase.done));
    } on ApiFailure catch (failure) {
      emit(state.copyWith(
        phase: failure.code == ApiCode.otpExpired ? OtpPhase.expired : OtpPhase.idle,
        failure: failure,
      ));
    }
  }

  Future<void> resend() async {
    if (!state.canResend) {
      return;
    }
    emit(state.copyWith(phase: OtpPhase.resending, clearFailure: true));
    try {
      final OtpChallenge fresh = await api.resendOtp(state.challenge.challenge);
      emit(state.copyWith(
        challenge: fresh,
        phase: OtpPhase.idle,
        secondsToResend: fresh.resendIn,
        resent: true,
      ));
      _startTicker();
    } on ApiFailure catch (failure) {
      emit(state.copyWith(
        phase: failure.code == ApiCode.otpExpired ? OtpPhase.expired : OtpPhase.idle,
        failure: failure,
        secondsToResend: failure.retryAfter ?? state.secondsToResend,
      ));
      _startTicker();
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();

    return super.close();
  }
}
