import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/staff_api.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import 'corrections_page.dart';
import '../../common/failure_view.dart';

/// سجل حضور الموظف بالشهر، ومنه يطلب تصحيح بصمة أي يوم.
class HrAttendancePage extends StatelessWidget {
  const HrAttendancePage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const HrAttendancePage(),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final StaffApi api = context.read<StaffApi>();

    return BlocProvider<DetailCubit<HrAttendance>>(
      create: (BuildContext context) => DetailCubit<HrAttendance>(api.hrAttendance)..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.hrAttendanceTitle),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).push(CorrectionsPage.route()),
              child: Text(l10n.correctionsTitle),
            ),
          ],
        ),
        body: BlocBuilder<DetailCubit<HrAttendance>, DetailState<HrAttendance>>(
          builder: (BuildContext context, DetailState<HrAttendance> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(failure: state.failure!, onRetry: () => context.read<DetailCubit<HrAttendance>>().load()),
              );
            }
            final HrAttendance attendance = state.data ?? HrAttendance.empty;
            final AppColors colors = context.colors;

            return RefreshIndicator(
              onRefresh: () => context.read<DetailCubit<HrAttendance>>().load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.calendar_month_outlined, size: 20, color: colors.primaryInk),
                      const SizedBox(width: 8),
                      Text(attendance.month,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.ink)),
                      const Spacer(),
                      StatusChip(
                        text: l10n.hrPresentDays,
                        color: colors.green,
                        background: colors.greenSoft,
                        icon: Icons.check_circle_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...attendance.days.map((HrDay day) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _DayCard(day: day),
                      )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});

  final HrDay day;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    final bool present = day.status == 'present';
    final bool absent = day.status == 'absent';
    final bool leave = day.status == 'leave';
    final Color accent = present ? colors.green : (absent ? colors.coral : (leave ? colors.skyInk : colors.muted));
    final Color accentSoft = present ? colors.greenSoft : (absent ? colors.coralSoft : (leave ? colors.sky : colors.bg2));

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () async {
        final bool? saved = await Navigator.of(context).push<bool>(CorrectionFormPage.route(date: day.date));
        if (saved == true && context.mounted) {
          context.read<DetailCubit<HrAttendance>>().load();
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconBadge(
            icon: present
                ? Icons.check_circle_outline
                : (absent
                    ? Icons.event_busy_outlined
                    : (leave ? Icons.beach_access_outlined : Icons.remove_circle_outline)),
            color: accent,
            background: accentSoft,
            size: 38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(formatDate(day.date),
                          style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                    ),
                    if (day.statusLabel.isNotEmpty)
                      StatusChip(text: day.statusLabel, color: accent, background: accentSoft),
                  ],
                ),
                const SizedBox(height: 8),
                if (day.expectedStart.isNotEmpty)
                  IconLine(
                    icon: Icons.schedule_outlined,
                    text: l10n.expectedHours(day.expectedStart, day.expectedEnd),
                  ),
                if (day.firstIn != null)
                  IconLine(icon: Icons.login, text: formatTime(day.firstIn), color: colors.green),
                if (day.lastOut != null)
                  IconLine(icon: Icons.logout, text: formatTime(day.lastOut), color: colors.skyInk),
                if (day.lateMinutes > 0 || day.earlyMinutes > 0) ...<Widget>[
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    children: <Widget>[
                      if (day.lateMinutes > 0)
                        StatusChip(
                          text: l10n.lateBy('${day.lateMinutes}'),
                          color: colors.coral,
                          background: colors.coralSoft,
                          icon: Icons.running_with_errors_outlined,
                        ),
                      if (day.earlyMinutes > 0)
                        StatusChip(
                          text: l10n.earlyBy('${day.earlyMinutes}'),
                          color: colors.sun,
                          background: colors.sunSoft,
                          icon: Icons.fast_forward_outlined,
                        ),
                    ],
                  ),
                ],
                if (day.hasCorrection)
                  IconLine(
                    icon: Icons.build_circle_outlined,
                    text: l10n.correctionsTitle,
                    color: colors.primaryInk,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
