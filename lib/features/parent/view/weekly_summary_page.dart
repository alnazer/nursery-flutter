import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/parent_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import '../../common/failure_view.dart';

/// الملخص الأسبوعي للطفل.
class WeeklySummaryPage extends StatelessWidget {
  const WeeklySummaryPage({super.key, required this.childId, required this.childName});

  final int childId;
  final String childName;

  static Route<void> route(int childId, String childName) => MaterialPageRoute<void>(
        builder: (BuildContext context) => WeeklySummaryPage(childId: childId, childName: childName),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<DetailCubit<Map<String, dynamic>>>(
      create: (BuildContext context) =>
          DetailCubit<Map<String, dynamic>>(() => api.weeklySummary(childId))..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.weeklyTitle)),
        body: BlocBuilder<DetailCubit<Map<String, dynamic>>, DetailState<Map<String, dynamic>>>(
          builder: (BuildContext context, DetailState<Map<String, dynamic>> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(failure: state.failure!, onRetry: () => context.read<DetailCubit<Map<String, dynamic>>>().load()),
              );
            }
            final Map<String, dynamic> summary = state.data ?? <String, dynamic>{};
            final AppColors colors = context.colors;
            final List<dynamic> activities =
                summary['activities'] is List ? summary['activities'] as List<dynamic> : <dynamic>[];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Text(childName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 5),
                IconLine(
                  icon: Icons.date_range_outlined,
                  text: '${formatDate('${summary['from'] ?? ''}')} - ${formatDate('${summary['to'] ?? ''}')}',
                  fontSize: 13,
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _Stat(
                        label: l10n.weeklyPresent,
                        value: '${summary['present'] ?? 0}',
                        color: colors.green,
                        icon: Icons.check_circle_outline,
                      ),
                      _Stat(
                        label: l10n.weeklyAbsent,
                        value: '${summary['absent'] ?? 0}',
                        color: colors.coral,
                        icon: Icons.event_busy_outlined,
                      ),
                      _Stat(
                        label: l10n.excusedDays,
                        value: '${summary['excused'] ?? 0}',
                        color: colors.sun,
                        icon: Icons.assignment_turned_in_outlined,
                      ),
                      _Stat(
                        label: l10n.weeklyActivities,
                        value: '${activities.length}',
                        color: colors.primaryInk,
                        icon: Icons.auto_awesome_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color, required this.icon});

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: context.colors.muted)),
      ],
    );
  }
}
