import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../../widgets/auth_scaffold.dart';
import '../../session/session_cubit.dart';
import '../cubit/biometric_cubit.dart';
import 'error_messages.dart';
import '../../common/failure_view.dart';

/// تُعرض مرة واحدة بعد الدخول: تفعيل البصمة خلال 15 دقيقة من الدخول.
class BiometricEnablePage extends StatelessWidget {
  const BiometricEnablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return BlocConsumer<BiometricCubit, BiometricState>(
      listener: (BuildContext context, BiometricState state) {
        final SessionCubit session = context.read<SessionCubit>();
        if (state.phase == BiometricPhase.enabled) {
          showSuccessSnack(context, l10n.biometricEnabled);
          session.consumeBiometricPrompt();
        } else if (state.phase == BiometricPhase.unavailable) {
          final BiometricError? error = state.error;
          final String text = error == null ? l10n.biometricUnavailable : biometricErrorMessage(l10n, error);
          if (text.isNotEmpty) {
            showInfoSnack(context, text);
          }
          session.consumeBiometricPrompt();
        }
      },
      builder: (BuildContext context, BiometricState state) {
        final ApiFailure? failure = state.failure;

        return AuthScaffold(
          showLogo: false,
          showLanguage: false,
          title: l10n.biometricEnableTitle,
          subtitle: l10n.biometricEnableBody,
          children: <Widget>[
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colors.soft,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primaryInk, width: 1.5),
                ),
                child: Icon(Icons.fingerprint, size: 64, color: colors.primaryInk),
              ),
            ),
            const SizedBox(height: 24),
            if (failure != null) ...<Widget>[
              FailureView(failure: failure, compact: true),
              const SizedBox(height: 14),
            ],
            PrimaryButton(
              label: l10n.biometricEnableAction,
              busy: state.busy,
              onPressed: state.phase == BiometricPhase.reauthRequired
                  ? null
                  : () => context.read<BiometricCubit>().enable(),
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () => context.read<SessionCubit>().consumeBiometricPrompt(),
                child: Text(l10n.later),
              ),
            ),
          ],
        );
      },
    );
  }
}
