import 'package:flutter/material.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/staff_api.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/child_avatar.dart';
import '../../common/busy_overlay.dart';
import '../../common/confirm_dialog.dart';
import '../../common/failure_view.dart';
import '../../common/list_views.dart';

/// يفتح الكاميرا، ويرسل الرمز للخادم، ويعرض النتيجة مع إمكانية مسح بطاقة أخرى.
/// [mode] هو `in` للحضور و`out` للانصراف، و[onScanned] لتحديث القائمة بعد كل مسح.
Future<void> scanAttendance(
  BuildContext context,
  StaffApi api,
  String mode, {
  Future<void> Function()? onScanned,
}) async {
  final AppL10n l10n = AppL10n.of(context);
  final String? code = await const NativeBridge().scanCode();
  if (!context.mounted) {
    return;
  }
  if (code == null || code.isEmpty) {
    showInfoSnack(context, l10n.scanCancelled);

    return;
  }
  try {
    final Map<String, dynamic> result = await runBusy<Map<String, dynamic>>(
      context,
      label: l10n.scanSending,
      action: () => api.scan(code: code, mode: mode),
    );
    if (!context.mounted) {
      return;
    }
    await onScanned?.call();
    if (!context.mounted) {
      return;
    }
    final bool again = await showModalBottomSheet<bool>(
          context: context,
          builder: (BuildContext sheetContext) => ScanResultSheet(result: result),
        ) ??
        false;
    if (again && context.mounted) {
      await scanAttendance(context, api, mode, onScanned: onScanned);
    }
  } on ApiFailure catch (failure) {
    if (context.mounted) {
      showFailureSnack(context, failure);
    }
  }
}

/// تسجيل غياب كل من لم يحضر اليوم، بعد تأكيد.
Future<void> markAbsentFlow(
  BuildContext context,
  StaffApi api, {
  Future<void> Function()? onDone,
}) async {
  final AppL10n l10n = AppL10n.of(context);
  final bool confirmed = await showConfirmDialog(
    context,
    title: l10n.markAbsentAction,
    message: l10n.markAbsentConfirm,
    icon: Icons.event_busy_outlined,
  );
  if (!confirmed || !context.mounted) {
    return;
  }
  try {
    final Map<String, dynamic> result = await runBusy<Map<String, dynamic>>(
      context,
      label: l10n.markAbsentBusy,
      action: api.markAbsent,
    );
    if (!context.mounted) {
      return;
    }
    final String message = '${result['message'] ?? ''}';
    if (message.isNotEmpty) {
      showInfoSnack(context, message);
    }
    await onDone?.call();
  } on ApiFailure catch (failure) {
    if (context.mounted) {
      showFailureSnack(context, failure);
    }
  }
}

/// نتيجة المسح: الطفل وحالته وأرقام اليوم، وزر لمسح بطاقة أخرى.
class ScanResultSheet extends StatelessWidget {
  const ScanResultSheet({super.key, required this.result});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final Map<String, dynamic> student = result['student'] is Map
        ? Map<String, dynamic>.from(result['student'] as Map)
        : <String, dynamic>{};
    final Map<String, dynamic> stats =
        result['stats'] is Map ? Map<String, dynamic>.from(result['stats'] as Map) : <String, dynamic>{};
    final Map<String, dynamic> classroom = student['classroom'] is Map
        ? Map<String, dynamic>.from(student['classroom'] as Map)
        : <String, dynamic>{};
    final String status = '${result['status'] ?? ''}';
    final bool out = status == 'checked_out' || status == 'already_out';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ChildAvatar(
              name: '${student['name'] ?? ''}',
              url: student['avatar_url'] as String?,
              size: 72,
            ),
            const SizedBox(height: 12),
            Text('${student['name'] ?? ''}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.ink)),
            if (classroom.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text('${classroom['title'] ?? ''}', style: TextStyle(color: colors.muted, fontSize: 13)),
            ],
            const SizedBox(height: 12),
            StatusChip(
              text: '${result['message'] ?? ''}',
              color: out ? colors.skyInk : colors.green,
              background: out ? colors.sky : colors.greenSoft,
              icon: out ? Icons.logout : Icons.check_circle_outline,
            ),
            if (stats.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  StatText(label: l10n.statIn, value: stats['in'], color: colors.green),
                  StatText(label: l10n.statOut, value: stats['out'], color: colors.skyInk),
                  StatText(label: l10n.statAbsent, value: stats['absent'], color: colors.coral),
                  StatText(label: l10n.statRemaining, value: stats['remaining'], color: colors.sun),
                ],
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: Text(l10n.scanAgain),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }
}

/// رقم فوق تسميته — يُستعمل في شريط الإحصاءات وفي ورقة نتيجة المسح.
class StatText extends StatelessWidget {
  const StatText({super.key, required this.label, required this.value, required this.color});

  final String label;
  final dynamic value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('${value ?? 0}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: context.colors.muted)),
      ],
    );
  }
}
