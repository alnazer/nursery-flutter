import 'package:flutter/material.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/staff_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/staff_abilities.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/child_avatar.dart';
import '../../common/busy_overlay.dart';
import '../../common/confirm_dialog.dart';
import '../../common/failure_view.dart';
import '../../common/list_views.dart';
import '../../common/prompt_dialog.dart';

/// هل لهذه المستخدمة أي إجراء على صفّ الطالب أصلاً؟
bool canActOnAttendance() =>
    StaffAbilities.can(StaffAbilities.scanAttendance) ||
    StaffAbilities.can(StaffAbilities.markAbsent) ||
    StaffAbilities.can(StaffAbilities.deleteAbsence);

/// ورقة إجراءات الحضور لطالب واحد: تحضير، انصراف، غياب، غياب بعذر، وإلغاء الغياب.
/// تُعرض الخيارات المتاحة فقط بحسب صلاحيات المستخدمة وحالة الطالب اليوم.
Future<void> showAttendanceActions(
  BuildContext context,
  StaffApi api,
  Child student, {
  required Future<void> Function() onDone,
}) async {
  final AppL10n l10n = AppL10n.of(context);
  final bool canScan = StaffAbilities.can(StaffAbilities.scanAttendance);
  final bool canAbsent = StaffAbilities.can(StaffAbilities.markAbsent);
  final bool canUndo = StaffAbilities.can(StaffAbilities.deleteAbsence);
  final String status = student.today.status;
  final bool present = status == 'present';
  final bool out = status == 'checked_out';
  final bool absent = status == 'absent';

  final _AttendanceAction? action = await showModalBottomSheet<_AttendanceAction>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      final AppColors colors = sheetContext.colors;

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: <Widget>[
                  ChildAvatar(name: student.firstName, url: student.avatarUrl, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          student.name,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: colors.ink),
                        ),
                        if (student.classroom.isNotEmpty)
                          Text(student.classroom, style: TextStyle(color: colors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (canScan && !present)
              _ActionTile(
                icon: Icons.login,
                color: colors.green,
                background: colors.greenSoft,
                label: l10n.markPresent,
                note: l10n.markPresentNote,
                onTap: () => Navigator.of(sheetContext).pop(_AttendanceAction.checkIn),
              ),
            if (canScan && present)
              _ActionTile(
                icon: Icons.logout,
                color: colors.skyInk,
                background: colors.sky,
                label: l10n.markCheckedOut,
                note: l10n.markCheckedOutNote,
                onTap: () => Navigator.of(sheetContext).pop(_AttendanceAction.checkOut),
              ),
            if (canAbsent && !absent && !present && !out) ...<Widget>[
              _ActionTile(
                icon: Icons.event_busy_outlined,
                color: colors.coral,
                background: colors.coralSoft,
                label: l10n.markUnexcused,
                note: l10n.markUnexcusedNote,
                onTap: () => Navigator.of(sheetContext).pop(_AttendanceAction.unexcused),
              ),
              _ActionTile(
                icon: Icons.assignment_late_outlined,
                color: colors.sun,
                background: colors.sunSoft,
                label: l10n.markExcused,
                note: l10n.markExcusedNote,
                onTap: () => Navigator.of(sheetContext).pop(_AttendanceAction.excused),
              ),
            ],
            if (canUndo && absent)
              _ActionTile(
                icon: Icons.undo,
                color: colors.purple,
                background: colors.purpleSoft,
                label: l10n.undoAbsence,
                note: l10n.undoAbsenceConfirm,
                onTap: () => Navigator.of(sheetContext).pop(_AttendanceAction.undoAbsence),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  if (action == null || !context.mounted) {
    return;
  }

  try {
    switch (action) {
      case _AttendanceAction.checkIn:
      case _AttendanceAction.checkOut:
        final String mode = action == _AttendanceAction.checkIn ? 'in' : 'out';
        final Map<String, dynamic> result = await runBusy<Map<String, dynamic>>(
          context,
          label: l10n.working,
          action: () => api.markAttendance(studentId: student.id, mode: mode),
        );
        if (!context.mounted) {
          return;
        }
        showSuccessSnack(context, '${result['message'] ?? l10n.saved}');
        break;

      case _AttendanceAction.unexcused:
        final bool yes = await showConfirmDialog(
          context,
          title: l10n.markUnexcused,
          message: l10n.markAbsentOneConfirm(student.name),
          icon: Icons.event_busy_outlined,
          destructive: true,
        );
        if (!yes || !context.mounted) {
          return;
        }
        await runBusy<Map<String, dynamic>>(
          context,
          label: l10n.markAbsentBusy,
          action: () => api.storeAbsence(studentId: student.id, type: 'unexcused'),
        );
        if (!context.mounted) {
          return;
        }
        showSuccessSnack(context, l10n.saved);
        break;

      case _AttendanceAction.excused:
        final PromptResult? reason = await showPromptDialog(
          context,
          title: l10n.markExcused,
          note: student.name,
          label: l10n.absenceReason,
          maxLines: 3,
          minLength: 3,
          confirmLabel: l10n.confirm,
        );
        if (reason == null || !context.mounted) {
          return;
        }
        await runBusy<Map<String, dynamic>>(
          context,
          label: l10n.markAbsentBusy,
          action: () => api.storeAbsence(studentId: student.id, type: 'excused', note: reason.text),
        );
        if (!context.mounted) {
          return;
        }
        showSuccessSnack(context, l10n.saved);
        break;

      case _AttendanceAction.undoAbsence:
        final int? id = student.today.absenceId;
        if (id == null) {
          showInfoSnack(context, l10n.emptyList);

          return;
        }
        final bool yes = await showConfirmDialog(
          context,
          title: l10n.undoAbsence,
          message: l10n.undoAbsenceConfirm,
          icon: Icons.undo,
          destructive: true,
        );
        if (!yes || !context.mounted) {
          return;
        }
        await runBusy<void>(
          context,
          label: l10n.working,
          action: () => api.deleteAbsence(id),
        );
        if (!context.mounted) {
          return;
        }
        showSuccessSnack(context, l10n.absenceRemoved);
        break;
    }
    await onDone();
  } on ApiFailure catch (failure) {
    if (context.mounted) {
      showFailureSnack(context, failure);
    }
  }
}

enum _AttendanceAction { checkIn, checkOut, unexcused, excused, undoAbsence }

/// خيار في ورقة الإجراءات: أيقونة ملوّنة، وعنوان، وسطر شرح.
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.note,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final String note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return ListTile(
      onTap: onTap,
      leading: IconBadge(icon: icon, color: color, background: background, size: 42),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
      subtitle: Text(note, style: TextStyle(color: colors.muted, fontSize: 12)),
      trailing: Icon(Icons.chevron_left, color: colors.muted),
    );
  }
}
