import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../session/session_cubit.dart';

/// شاشة تمنع الاستخدام: صيانة، أو تحديث إلزامي، أو إعداد ناقص، أو انقطاع الشبكة.
class BlockerPage extends StatelessWidget {
  const BlockerPage({super.key, required this.failure});

  final ApiFailure failure;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    late final String title;
    late final String body;
    late final IconData icon;
    switch (failure.code) {
      case ApiCode.appUpdateRequired:
        title = l10n.updateTitle;
        body = l10n.updateBody;
        icon = Icons.system_update_alt;
        break;
      case ApiCode.maintenance:
        title = l10n.maintenanceTitle;
        body = failure.displayMessage.isNotEmpty ? failure.displayMessage : l10n.maintenanceBody;
        icon = Icons.build_outlined;
        break;
      case ApiCode.invalidClient:
      case ApiCode.clientNotAllowed:
        title = l10n.serverError;
        body = l10n.configMissing;
        icon = Icons.vpn_key_outlined;
        break;
      default:
        title = failure.isNetwork ? l10n.networkError : l10n.serverError;
        body = failure.isNetwork ? '' : failure.displayMessage;
        icon = failure.isNetwork ? Icons.wifi_off_outlined : Icons.error_outline;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(icon, size: 64, color: colors.primaryInk),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.ink),
              ),
              if (body.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: colors.body, height: 1.6),
                ),
              ],
              if (failure.storeUrl != null) ...<Widget>[
                const SizedBox(height: 10),
                SelectableText(
                  failure.storeUrl!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: colors.primaryInk),
                ),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: l10n.retry,
                onPressed: () => context.read<SessionCubit>().bootstrap(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
