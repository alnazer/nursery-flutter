import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// حوار تأكيد موحّد لكل التطبيق:
/// أيقونة كبيرة، ثم عنوان بخط كبير، ثم شرح،
/// وزرّان جنباً إلى جنب: «تأكيد» أعرض وأعلى، و«إلغاء» أحمر.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String message = '',
  String? confirmLabel,
  String? cancelLabel,
  IconData icon = Icons.help_outline,
  IconData confirmIcon = Icons.check_circle_outline,

  /// إجراء لا رجعة فيه: الأيقونة وزر التأكيد باللون الأحمر.
  bool destructive = false,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      final AppL10n l10n = AppL10n.of(dialogContext);
      final AppColors colors = dialogContext.colors;
      final Color tint = destructive ? colors.coral : colors.primaryInk;
      final Color tintSoft = destructive ? colors.coralSoft : colors.soft;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(color: tintSoft, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Icon(icon, size: 32, color: tint),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: colors.ink,
                          height: 1.4,
                        ),
                      ),
                      if (message.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: colors.body, height: 1.6),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DialogActions(
                confirmLabel: confirmLabel ?? l10n.confirm,
                cancelLabel: cancelLabel ?? l10n.cancel,
                confirmIcon: confirmIcon,
                destructive: destructive,
                onConfirm: () => Navigator.of(dialogContext).pop(true),
                onCancel: () => Navigator.of(dialogContext).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );

  return confirmed == true;
}

/// صفّ أزرار الحوارات: «تأكيد» أكبر على اليمين، و«إلغاء» أحمر بجواره.
class DialogActions extends StatelessWidget {
  const DialogActions({
    super.key,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.cancelLabel,
    this.confirmIcon = Icons.check_circle_outline,
    this.cancelIcon = Icons.close,
    this.destructive = false,
  });

  final String confirmLabel;
  final String? cancelLabel;

  /// null يعطّل زر التأكيد (نموذج غير مكتمل).
  final VoidCallback? onConfirm;
  final VoidCallback onCancel;
  final IconData confirmIcon;
  final IconData cancelIcon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: FilledButton.icon(
            onPressed: onConfirm,
            style: FilledButton.styleFrom(
              backgroundColor: destructive ? colors.coral : colors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 56),
              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: Icon(confirmIcon, size: 20),
            label: Text(confirmLabel, overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.coral,
              minimumSize: const Size(0, 46),
              side: BorderSide(color: colors.coral, width: 1.5),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: Icon(cancelIcon, size: 18),
            label: Text(cancelLabel ?? l10n.cancel, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}
