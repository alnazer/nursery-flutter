import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../app/app_config.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../auth/cubit/biometric_cubit.dart';
import '../../auth/view/error_messages.dart';
import '../../common/list_views.dart';
import '../../common/user_avatar.dart';
import '../../session/session_cubit.dart';
import '../../staff/view/hr_page.dart';
import 'circulars_page.dart';
import 'devices_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import '../../common/failure_view.dart';

/// حسابي: الاسم، واللغة، والبصمة، وتسجيل الخروج. مشتركة بين التطبيقين.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  static String _biometricMessage(BuildContext context, BiometricState state) {
    final AppL10n l10n = AppL10n.of(context);
    switch (state.phase) {
      case BiometricPhase.enabled:
        return l10n.biometricEnabled;
      case BiometricPhase.disabled:
        return l10n.biometricDisabled;
      case BiometricPhase.reauthRequired:
        return l10n.biometricReauth;
      case BiometricPhase.unavailable:
        final BiometricError? error = state.error;
        return error == null ? l10n.biometricUnavailable : biometricErrorMessage(l10n, error);
      case BiometricPhase.failed:
        final ApiFailure? failure = state.failure;
        return failure == null ? l10n.serverError : failureMessage(l10n, failure);
      case BiometricPhase.idle:
      case BiometricPhase.working:
      case BiometricPhase.signedIn:
      case BiometricPhase.revoked:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final SessionState session = context.watch<SessionCubit>().state;
    final bool biometricOn = session.biometric != null;
    final bool isStaff = context.read<AppConfig>().isStaff;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (isStaff)
          StaffIdentity(
            name: session.session?.userName ?? '',
            subtitle: session.meta.name,
          )
        else
          Row(
            children: <Widget>[
              NurseryLogo(url: session.meta.logoUrl, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(session.session?.userName ?? '',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.ink)),
                    const SizedBox(height: 4),
                    Text(session.meta.name, style: TextStyle(fontSize: 13, color: colors.muted)),
                  ],
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(Icons.person_outline, color: colors.primaryInk),
            title: Text(l10n.profileTitle, style: TextStyle(color: colors.ink)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(ProfilePage.route()),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(Icons.language, color: colors.primaryInk),
            title: Text(l10n.languageSwitch, style: TextStyle(color: colors.ink)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.read<SessionCubit>().setLocale(session.locale == 'ar' ? 'en' : 'ar'),
          ),
        ),
        if (isStaff) ...<Widget>[
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.notifications_none, color: colors.primaryInk),
              title: Text(l10n.notificationsTitle, style: TextStyle(color: colors.ink)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(NotificationsPage.route()),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.campaign_outlined, color: colors.primaryInk),
              title: Text(l10n.circularsTitle, style: TextStyle(color: colors.ink)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(CircularsPage.route()),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.badge_outlined, color: colors.primaryInk),
              title: Text(l10n.hrTitle, style: TextStyle(color: colors.ink)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(HrPage.route()),
            ),
          ),
        ],
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(Icons.devices_outlined, color: colors.primaryInk),
            title: Text(l10n.devicesTitle, style: TextStyle(color: colors.ink)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(DevicesPage.route()),
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.securitySettings, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.ink)),
        const SizedBox(height: 8),
        BlocConsumer<BiometricCubit, BiometricState>(
          listener: (BuildContext context, BiometricState state) {
            final String text = _biometricMessage(context, state);
            if (text.isNotEmpty) {
              showInfoSnack(context, text);
            }
          },
          builder: (BuildContext context, BiometricState state) {
            return AppCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile.adaptive(
                value: biometricOn,
                title: Text(l10n.biometricLabel, style: TextStyle(color: colors.ink)),
                subtitle: Text(
                  biometricOn ? l10n.biometricEnabled : l10n.biometricEnableBody,
                  style: TextStyle(color: colors.muted, fontSize: 13),
                ),
                secondary: Icon(Icons.fingerprint, color: colors.primaryInk),
                onChanged: state.busy
                    ? null
                    : (bool value) {
                        final BiometricCubit cubit = context.read<BiometricCubit>();
                        if (value) {
                          cubit.enable();
                        } else {
                          cubit.disable();
                        }
                      },
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => context.read<SessionCubit>().signOut(),
          icon: const Icon(Icons.logout),
          label: Text(l10n.signOut),
        ),
        if (biometricOn) ...<Widget>[
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.read<SessionCubit>().signOut(forgetBiometric: true),
            child: Text(l10n.signOutForget),
          ),
        ],
      ],
    );
  }
}
