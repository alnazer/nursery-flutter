import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../../widgets/auth_scaffold.dart';
import '../cubit/otp_cubit.dart';
import '../../common/failure_view.dart';

/// رمز التحقق: رسالة نصية لولي الأمر، أو بريد للمشرفة.
class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return BlocConsumer<OtpCubit, OtpState>(
      listener: (BuildContext context, OtpState state) {
        if (state.phase == OtpPhase.done) {
          Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);

          return;
        }
        if (state.resent) {
          showSuccessSnack(context, l10n.otpSent);
        }
      },
      builder: (BuildContext context, OtpState state) {
        final ApiFailure? failure = state.failure;
        final bool expired = state.phase == OtpPhase.expired;

        return AuthScaffold(
          canPop: true,
          showLogo: false,
          title: l10n.otpTitle,
          subtitle: l10n.otpSubtitle(state.challenge.target),
          children: <Widget>[
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: true,
              maxLength: state.challenge.length,
              style: TextStyle(fontSize: 26, letterSpacing: 8, fontWeight: FontWeight.w700, color: colors.ink),
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                labelText: l10n.otpCodeLabel,
                errorText: failure?.fieldError('code'),
              ),
              onSubmitted: (String value) => context.read<OtpCubit>().verify(value),
            ),
            if (failure != null && failure.errors.isEmpty) ...<Widget>[
              const SizedBox(height: 14),
              FailureView(failure: failure, compact: true),
            ],
            const SizedBox(height: 18),
            PrimaryButton(
              label: l10n.verify,
              busy: state.phase == OtpPhase.verifying,
              onPressed: expired ? null : () => context.read<OtpCubit>().verify(_code.text),
            ),
            const SizedBox(height: 10),
            Center(
              child: state.canResend || expired
                  ? TextButton(
                      onPressed: expired
                          ? () => Navigator.of(context).maybePop()
                          : () => context.read<OtpCubit>().resend(),
                      child: Text(expired ? l10n.retry : l10n.resend),
                    )
                  : Text(
                      l10n.resendIn(state.secondsToResend),
                      style: TextStyle(color: colors.muted, fontSize: 14),
                    ),
            ),
          ],
        );
      },
    );
  }
}
