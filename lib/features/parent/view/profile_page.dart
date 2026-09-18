import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/util/staff_abilities.dart';
import '../../../widgets/app_widgets.dart';
import '../../common/editable_avatar.dart';
import '../../common/failure_view.dart';

/// بياناتي: تعديل الاسم والبريد، وإرسال رابط إعادة تعيين كلمة المرور.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const ProfilePage(),
      );

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String _avatarUrl = '';
  String _displayName = '';
  bool _loading = true;
  bool _busy = false;
  bool _sendingReset = false;
  String _initialEmail = '';
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final Map<String, dynamic> me = await context.read<ParentApi>().me();
      if (mounted) {
        setState(() {
          _name.text = '${me['name'] ?? ''}';
          _email.text = '${me['email'] ?? ''}';
          _displayName = _name.text;
          _avatarUrl = '${me['avatar_url'] ?? ''}';
          _initialEmail = _email.text;
          _loading = false;
        });
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failure = failure;
        });
      }
    }
  }

  Future<void> _save() async {
    final FormState? form = _form.currentState;
    if (form == null || !form.validate() || _busy) {
      return;
    }
    final AppL10n l10n = AppL10n.of(context);
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await context.read<ParentApi>().updateMe(
            name: _name.text.trim(),
            email: _email.text.trim(),
            currentPassword: _password.text,
          );
      if (mounted) {
        setState(() {
          _busy = false;
          _initialEmail = _email.text.trim();
          _password.clear();
        });
        showSuccessSnack(context, l10n.profileSaved);
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

  Future<void> _resetPassword() async {
    final AppL10n l10n = AppL10n.of(context);
    final String email = _email.text.trim();
    if (email.isEmpty || _sendingReset) {
      return;
    }
    setState(() => _sendingReset = true);
    try {
      await context.read<AuthApi>().forgotPassword(email);
      if (mounted) {
        showSuccessSnack(context, l10n.forgotSent);
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        showFailureSnack(context, failure);
      }
    } finally {
      if (mounted) {
        setState(() => _sendingReset = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final bool emailChanged = _email.text.trim() != _initialEmail;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Center(
                  child: EditableAvatar(
                    name: _displayName,
                    url: _avatarUrl.isEmpty ? null : _avatarUrl,
                    size: 88,
                    onPick: (UploadFile file) => context.read<ParentApi>().updateAvatar(file),
                    onChanged: (String url) {
                      setState(() => _avatarUrl = url);
                      // صورة الحساب تظهر في شاشات المشرفة أيضاً فتتحدّث معها
                      StaffAbilities.setAvatar(url);
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Form(
                  key: _form,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: l10n.nameLabel,
                          errorText: _failure?.fieldError('name'),
                        ),
                        validator: (String? value) =>
                            (value == null || value.trim().isEmpty) ? l10n.fieldRequired : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (String _) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: l10n.emailLabel,
                          errorText: _failure?.fieldError('email'),
                        ),
                      ),
                      if (emailChanged) ...<Widget>[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.currentPassword,
                            helperText: l10n.currentPasswordHint,
                            errorText: _failure?.fieldError('current_password'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_failure != null && _failure!.errors.isEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  FailureView(failure: _failure!, compact: true),
                ],
                const SizedBox(height: 18),
                PrimaryButton(label: l10n.saveChanges, busy: _busy, onPressed: _save),
                const SizedBox(height: 24),
                Text(l10n.resetPasswordHint, style: TextStyle(color: colors.muted, fontSize: 13)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _email.text.trim().isEmpty || _sendingReset ? null : _resetPassword,
                  icon: const Icon(Icons.lock_reset),
                  label: Text(l10n.resetPassword),
                ),
              ],
            ),
    );
  }
}
