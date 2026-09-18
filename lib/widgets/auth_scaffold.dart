import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app_config.dart';
import '../core/theme/app_theme.dart';
import '../features/session/session_cubit.dart';
import '../l10n/app_localizations.dart';
import 'app_widgets.dart';

/// الإطار المشترك لشاشات الدخول: مبدّل اللغة، والشعار، وعنوان وشرح.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showLogo = true,
    this.showLanguage = true,
    this.canPop = false,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool showLogo;
  final bool showLanguage;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppL10n l10n = AppL10n.of(context);
    final SessionState session = context.watch<SessionCubit>().state;
    final AppConfig config = context.read<AppConfig>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (canPop)
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      color: colors.ink,
                    ),
                  const Spacer(),
                  if (showLanguage)
                    TextButton.icon(
                      onPressed: () => context
                          .read<SessionCubit>()
                          .setLocale(session.locale == 'ar' ? 'en' : 'ar'),
                      icon: const Icon(Icons.language, size: 18),
                      label: Text(l10n.languageSwitch),
                    ),
                ],
              ),
              if (showLogo) ...<Widget>[
                const SizedBox(height: 8),
                Center(child: NurseryLogo(url: session.meta.logoUrl)),
                const SizedBox(height: 12),
                Text(
                  session.meta.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  config.isStaff ? l10n.taglineStaff : l10n.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: colors.muted),
                ),
              ],
              const SizedBox(height: 24),
              Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.ink)),
              const SizedBox(height: 6),
              Text(subtitle, style: TextStyle(fontSize: 15, color: colors.body, height: 1.5)),
              const SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
