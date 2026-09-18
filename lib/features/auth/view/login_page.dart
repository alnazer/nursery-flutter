import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_config.dart';
import '../../../core/api/api_failure.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/models/app_meta.dart';
import '../../../core/models/auth_session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../../widgets/auth_scaffold.dart';
import '../../session/session_cubit.dart';
import '../cubit/biometric_cubit.dart';
import '../cubit/login_cubit.dart';
import '../cubit/otp_cubit.dart';
import 'error_messages.dart';
import 'forgot_password_page.dart';
import 'otp_page.dart';
import '../../common/failure_view.dart';

/// شاشة الدخول للتطبيقين. زر البصمة داخل الشاشة نفسها إن كانت مفعّلة على الجهاز.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _identifier = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(AppConfig config, AppMeta meta) {
    final FormState? form = _form.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    final LoginCubit cubit = context.read<LoginCubit>();
    if (config.isStaff) {
      cubit.staffLogin(_identifier.text, _password.text);
    } else if (meta.usesPassword) {
      cubit.parentPassword(_identifier.text, _password.text);
    } else {
      cubit.parentMobile(_identifier.text);
    }
  }

  void _openOtp(OtpChallenge challenge) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext routeContext) => BlocProvider<OtpCubit>(
        create: (BuildContext providerContext) => OtpCubit(
          api: context.read<AuthApi>(),
          session: context.read<SessionCubit>(),
          challenge: challenge,
        ),
        child: const OtpPage(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final AppConfig config = context.read<AppConfig>();
    final SessionState session = context.watch<SessionCubit>().state;
    final AppMeta meta = session.meta;
    final bool usesPassword = config.isStaff || meta.usesPassword;

    return MultiBlocListener(
      listeners: [
        BlocListener<LoginCubit, LoginState>(
          listenWhen: (LoginState previous, LoginState current) => current.phase == LoginPhase.otp,
          listener: (BuildContext context, LoginState state) {
            final OtpChallenge? challenge = state.challenge;
            if (challenge != null) {
              _openOtp(challenge);
            }
          },
        ),
        BlocListener<BiometricCubit, BiometricState>(
          listener: (BuildContext context, BiometricState state) {
            final AppL10n messages = AppL10n.of(context);
            String text = '';
            if (state.phase == BiometricPhase.revoked) {
              text = messages.biometricRevoked;
            } else if (state.phase == BiometricPhase.failed || state.phase == BiometricPhase.unavailable) {
              final ApiFailure? failure = state.failure;
              final BiometricError? error = state.error;
              text = failure != null
                  ? failureMessage(messages, failure)
                  : error != null
                      ? biometricErrorMessage(messages, error)
                      : messages.biometricRetry;
            }
            if (text.isNotEmpty) {
              showInfoSnack(context, text);
            }
          },
        ),
      ],
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (BuildContext context, LoginState state) {
          final ApiFailure? failure = state.failure;

          return AuthScaffold(
            title: l10n.loginTitle,
            subtitle: config.isStaff
                ? l10n.loginSubtitleStaff
                : usesPassword
                    ? l10n.loginSubtitlePassword
                    : l10n.loginSubtitleMobile,
            children: <Widget>[
              Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _identifier,
                      keyboardType: usesPassword ? TextInputType.text : TextInputType.phone,
                      textInputAction: usesPassword ? TextInputAction.next : TextInputAction.done,
                      autofillHints: usesPassword
                          ? const <String>[AutofillHints.username]
                          : const <String>[AutofillHints.telephoneNumber],
                      decoration: InputDecoration(
                        labelText: config.isStaff
                            ? l10n.usernameLabel
                            : usesPassword
                                ? l10n.identifierLabel
                                : l10n.mobileLabel,
                        errorText: failure?.fieldError(config.isStaff
                            ? 'username'
                            : usesPassword
                                ? 'login'
                                : 'mobile'),
                      ),
                      validator: (String? value) =>
                          (value == null || value.trim().isEmpty) ? l10n.fieldRequired : null,
                    ),
                    if (usesPassword) ...<Widget>[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password,
                        obscureText: state.obscure,
                        textInputAction: TextInputAction.done,
                        autofillHints: const <String>[AutofillHints.password],
                        onFieldSubmitted: (String _) => _submit(config, meta),
                        decoration: InputDecoration(
                          labelText: l10n.passwordLabel,
                          errorText: failure?.fieldError('password'),
                          suffixIcon: IconButton(
                            onPressed: () => context.read<LoginCubit>().toggleObscure(),
                            icon: Icon(state.obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                        ),
                        validator: (String? value) =>
                            (value == null || value.isEmpty) ? l10n.fieldRequired : null,
                      ),
                    ],
                  ],
                ),
              ),
              if (failure != null && failure.errors.isEmpty) ...<Widget>[
                const SizedBox(height: 14),
                FailureView(failure: failure, compact: true),
              ],
              const SizedBox(height: 18),
              BlocBuilder<BiometricCubit, BiometricState>(
                builder: (BuildContext context, BiometricState biometric) {
                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: PrimaryButton(
                          label: usesPassword ? l10n.signIn : l10n.continueLabel,
                          busy: state.busy,
                          onPressed: () => _submit(config, meta),
                        ),
                      ),
                      if (session.canUseBiometric) ...<Widget>[
                        const SizedBox(width: 12),
                        FingerprintButton(
                          tooltip: l10n.biometricLabel,
                          busy: biometric.busy,
                          onPressed: () => context.read<BiometricCubit>().signIn(
                                promptTitle: l10n.biometricPromptTitle,
                                promptSubtitle: l10n.biometricPromptSubtitle,
                                cancelLabel: l10n.cancel,
                              ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              if (session.canUseBiometric) ...<Widget>[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.check, size: 14, color: colors.muted),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.biometricHint(session.biometricUserName),
                        style: TextStyle(fontSize: 13, color: colors.muted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
              if (usesPassword) ...<Widget>[
                const SizedBox(height: 6),
                if (!config.isStaff)
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (BuildContext _) => const ForgotPasswordPage(),
                    )),
                    child: Text(l10n.forgotPassword),
                  ),
              ] else ...<Widget>[
                const SizedBox(height: 18),
                SoftNote(text: l10n.smsNote),
                const SizedBox(height: 14),
                Text(
                  l10n.notRegistered,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: colors.muted),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
