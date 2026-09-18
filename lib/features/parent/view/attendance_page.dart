import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/parent_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import 'absence_form_page.dart';
import '../../common/failure_view.dart';

/// حضور الطفل خلال الشهر مع ملخّص ونسبة، وزر التبليغ عن غياب.
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key, required this.childId, required this.childName});

  final int childId;
  final String childName;

  static Route<void> route(int childId, String childName) => MaterialPageRoute<void>(
        builder: (BuildContext context) => AttendancePage(childId: childId, childName: childName),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<DetailCubit<AttendanceMonth>>(
      create: (BuildContext context) => DetailCubit<AttendanceMonth>(() => api.attendance(childId))..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.attendanceMonthTitle)),
        floatingActionButton: Builder(
          builder: (BuildContext context) => FloatingActionButton.extended(
            onPressed: () async {
              final bool? saved = await Navigator.of(context).push<bool>(
                AbsenceFormPage.route(childId: childId, childName: childName),
              );
              if (saved == true && context.mounted) {
                context.read<DetailCubit<AttendanceMonth>>().load();
              }
            },
            icon: const Icon(Icons.event_busy_outlined),
            label: Text(l10n.reportAbsence),
          ),
        ),
        body: BlocBuilder<DetailCubit<AttendanceMonth>, DetailState<AttendanceMonth>>(
          builder: (BuildContext context, DetailState<AttendanceMonth> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(failure: state.failure!, onRetry: () => context.read<DetailCubit<AttendanceMonth>>().load()),
              );
            }
            final AttendanceMonth month = state.data ?? AttendanceMonth.empty;
            final AppColors colors = context.colors;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: <Widget>[
                Text(childName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 5),
                IconLine(icon: Icons.calendar_month_outlined, text: month.month, fontSize: 13),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.insights_outlined, size: 20, color: colors.primaryInk),
                          const SizedBox(width: 8),
                          Text(
                            l10n.attendanceRate(month.rate.toStringAsFixed(1)),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.primaryInk),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _Summary(
                            label: l10n.schoolDays,
                            value: month.schoolDays,
                            color: colors.ink,
                            icon: Icons.calendar_today_outlined,
                          ),
                          _Summary(
                            label: l10n.absentDays,
                            value: month.absent,
                            color: colors.coral,
                            icon: Icons.event_busy_outlined,
                          ),
                          _Summary(
                            label: l10n.excusedDays,
                            value: month.excused,
                            color: colors.green,
                            icon: Icons.assignment_turned_in_outlined,
                          ),
                          _Summary(
                            label: l10n.unexcusedDays,
                            value: month.unexcused,
                            color: colors.sun,
                            icon: Icons.report_gmailerrorred_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...month.days.map((AttendanceDay day) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _DayRow(day: day),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.value, required this.color, required this.icon});

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 19, color: color),
        const SizedBox(height: 4),
        Text('$value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: context.colors.muted)),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});

  final AttendanceDay day;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    late final String label;
    late final Color color;
    late final Color background;
    switch (day.status) {
      case 'present':
        label = l10n.statusPresent;
        color = colors.green;
        background = colors.greenSoft;
        break;
      case 'checked_out':
        label = l10n.statusCheckedOut;
        color = colors.skyInk;
        background = colors.sky;
        break;
      case 'absent':
        label = l10n.statusAbsent;
        color = colors.coral;
        background = colors.coralSoft;
        break;
      case 'closed':
        label = l10n.statusClosed;
        color = colors.sun;
        background = colors.sunSoft;
        break;
      default:
        label = l10n.statusNotArrived;
        color = colors.muted;
        background = colors.bg2;
    }

    late final IconData icon;
    switch (day.status) {
      case 'present':
        icon = Icons.check_circle_outline;
        break;
      case 'checked_out':
        icon = Icons.logout;
        break;
      case 'absent':
        icon = Icons.event_busy_outlined;
        break;
      case 'closed':
        icon = Icons.lock_clock;
        break;
      default:
        icon = Icons.remove_circle_outline;
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(formatDate(day.date), style: TextStyle(color: colors.ink))),
          if (day.checkedInAt != null) ...<Widget>[
            Icon(Icons.login, size: 14, color: colors.muted),
            const SizedBox(width: 4),
            Text(formatTime(day.checkedInAt), style: TextStyle(color: colors.muted, fontSize: 12)),
            const SizedBox(width: 10),
          ],
          StatusChip(text: label, color: color, background: background, icon: icon),
        ],
      ),
    );
  }
}
