import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/auth_api.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../../widgets/auth_scaffold.dart';
import '../../common/failure_view.dart';

/// نسيت كلمة المرور (ولي الأمر، وضع كلمة المرور).
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();

  bool _busy = false;
  bool _sent = false;
  ApiFailure? _failure;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final FormState? form = _form.currentState;
    if (form == null || !form.validate() || _busy) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await context.read<AuthApi>().forgotPassword(_email.text.trim());
      if (mounted) {
        setState(() {
          _busy = false;
          _sent = true;
        });
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failure = failure;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return AuthScaffold(
      canPop: true,
      showLogo: false,
      title: l10n.forgotTitle,
      subtitle: l10n.forgotSubtitle,
      children: <Widget>[
        Form(
          key: _form,
          child: TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const <String>[AutofillHints.email],
            decoration: InputDecoration(
              labelText: l10n.emailLabel,
              errorText: _failure?.fieldError('email'),
            ),
            validator: (String? value) => (value == null || value.trim().isEmpty) ? l10n.fieldRequired : null,
          ),
        ),
        if (_sent) ...<Widget>[
          const SizedBox(height: 14),
          SoftNote(text: l10n.forgotSent, icon: Icons.mark_email_read_outlined),
        ],
        if (_failure != null && _failure!.errors.isEmpty) ...<Widget>[
          const SizedBox(height: 14),
          FailureView(failure: _failure!, compact: true),
        ],
        const SizedBox(height: 18),
        PrimaryButton(label: l10n.send, busy: _busy, onPressed: _submit),
      ],
    );
  }
}
