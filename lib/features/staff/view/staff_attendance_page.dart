import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/staff_api.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/child_avatar.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import 'attendance_actions.dart';
import 'scan_flow.dart';

/// حضور اليوم: قائمة الطلاب بحالاتهم مع فلاتر، وتسجيل غياب من لم يصل.
class StaffAttendancePage extends StatefulWidget {
  const StaffAttendancePage({super.key});

  @override
  State<StaffAttendancePage> createState() => _StaffAttendancePageState();
}

class _StaffAttendancePageState extends State<StaffAttendancePage> {
  String _status = '';
  int? _classroom;
  List<Classroom> _classrooms = <Classroom>[];

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  /// الفصول تُحمّل مرة واحدة، وفشلها يخفي شريط الفصول فقط.
  Future<void> _loadClassrooms() async {
    try {
      final List<Classroom> rooms = await context.read<StaffApi>().classrooms();
      if (mounted) {
        setState(() => _classrooms = rooms);
      }
    } catch (_) {
      // تُترك فارغة
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final StaffApi api = context.read<StaffApi>();

    return BlocProvider<PagedCubit<Child>>(
      key: ValueKey<String>('$_status|$_classroom'),
      create: (BuildContext context) => PagedCubit<Child>(
        (int page) => api.attendanceToday(page: page, status: _status, classroom: _classroom),
      )..load(),
      child: Builder(
        builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              FilterBar<String>(
                selected: _status,
                onSelected: (String value) => setState(() => _status = value),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                options: <FilterOption<String>>[
                  FilterOption<String>(value: '', label: l10n.filterAll),
                  FilterOption<String>(value: 'not_arrived', label: l10n.filterNotArrived),
                  FilterOption<String>(value: 'present', label: l10n.filterPresent),
                  FilterOption<String>(value: 'absent', label: l10n.filterAbsent),
                ],
              ),
              if (_classrooms.isNotEmpty)
                FilterBar<int?>(
                  selected: _classroom,
                  onSelected: (int? value) => setState(() => _classroom = value),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  options: <FilterOption<int?>>[
                    FilterOption<int?>(value: null, label: l10n.allClassrooms),
                    ..._classrooms.map((Classroom room) => FilterOption<int?>(value: room.id, label: room.title)),
                  ],
                ),
              Expanded(
                child: PagedListView<PagedCubit<Child>, Child>(
                  header: const _StatsHeader(),
                  itemBuilder: (BuildContext context, Child student) => _AttendanceTile(student: student, api: api),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => scanAttendance(context, api, 'in', onScanned: () => context.read<PagedCubit<Child>>().load(refresh: true)),
                              icon: const Icon(Icons.qr_code_scanner, size: 18),
                              label: Text(l10n.scanIn),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => scanAttendance(context, api, 'out', onScanned: () => context.read<PagedCubit<Child>>().load(refresh: true)),
                              icon: const Icon(Icons.logout, size: 18),
                              label: Text(l10n.scanOut),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => markAbsentFlow(context, api, onDone: () => context.read<PagedCubit<Child>>().load(refresh: true)),
                        icon: const Icon(Icons.event_busy_outlined),
                        label: Text(l10n.markAbsentAction),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return BlocBuilder<PagedCubit<Child>, ListState<Child>>(
      builder: (BuildContext context, ListState<Child> state) {
        final Map<String, dynamic> stats = state.meta['stats'] is Map
            ? Map<String, dynamic>.from(state.meta['stats'] as Map)
            : <String, dynamic>{};
        if (stats.isEmpty) {
          return const SizedBox.shrink();
        }

        return AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              StatText(label: l10n.statExpected, value: stats['expected'], color: colors.ink),
              StatText(label: l10n.statIn, value: stats['in'], color: colors.green),
              StatText(label: l10n.statOut, value: stats['out'], color: colors.skyInk),
              StatText(label: l10n.statAbsent, value: stats['absent'], color: colors.coral),
              StatText(label: l10n.statRemaining, value: stats['remaining'], color: colors.sun),
            ],
          ),
        );
      },
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.student, required this.api});

  final Child student;
  final StaffApi api;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    late final String label;
    late final Color color;
    late final Color background;
    switch (student.today.status) {
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
      default:
        label = l10n.statusNotArrived;
        color = colors.muted;
        background = colors.bg2;
    }

    final bool actionable = canActOnAttendance();
    // الصفّ كلّه يفتح ورقة الإجراءات، وزر النقاط الثلاث يوضّح أن هناك إجراءات.
    Future<void> open() => showAttendanceActions(
          context,
          api,
          student,
          onDone: () => context.read<PagedCubit<Child>>().load(refresh: true),
        );

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: actionable ? open : null,
      child: Row(
        children: <Widget>[
          ChildAvatar(name: student.firstName, url: student.avatarUrl, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(student.name, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                if (student.today.checkedInAt != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(l10n.arrivedAt(formatTime(student.today.checkedInAt)),
                      style: TextStyle(color: colors.muted, fontSize: 12)),
                ] else if (student.today.status == 'absent' && student.today.absenceType.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    student.today.absenceType == 'excused' ? l10n.markExcused : l10n.markUnexcused,
                    style: TextStyle(color: colors.muted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          StatusChip(text: label, color: color, background: background),
          if (actionable) ...<Widget>[
            const SizedBox(width: 2),
            IconButton(
              tooltip: l10n.studentActions,
              onPressed: open,
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.more_vert, color: colors.muted),
            ),
          ],
        ],
      ),
    );
  }
}


/// نتيجة المسح: اسم الطالب وصورته ورسالة الخادم وأرقام اليوم.
