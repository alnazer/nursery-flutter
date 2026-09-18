import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/staff_api.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/activity_window_note.dart';
import '../../common/user_avatar.dart';
import '../../common/list_views.dart';
import '../../session/session_cubit.dart';
import '../../../core/util/staff_abilities.dart';
import '../cubit/staff_today_cubit.dart';
import 'scan_flow.dart';
import 'staff_students_page.dart';
import '../../common/failure_view.dart';

/// لوحة اليوم: الحضور والأنشطة ونافذة الإضافة.
class StaffTodayPage extends StatelessWidget {
  const StaffTodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StaffTodayCubit>(
      create: (BuildContext context) => StaffTodayCubit(context.read<StaffApi>())..load(),
      child: const _StaffTodayView(),
    );
  }
}

class _StaffTodayView extends StatelessWidget {
  const _StaffTodayView();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final SessionState session = context.watch<SessionCubit>().state;

    return BlocBuilder<StaffTodayCubit, StaffTodayState>(
      builder: (BuildContext context, StaffTodayState state) {
        if (state.loading && state.today.date.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.failure != null && state.today.date.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: FailureView(failure: state.failure!, onRetry: () => context.read<StaffTodayCubit>().load()),
            ),
          );
        }
        final StaffToday today = state.today;

        return RefreshIndicator(
          onRefresh: () => context.read<StaffTodayCubit>().load(refresh: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              Row(
                children: <Widget>[
                  StaffAvatar(size: 46, fallbackName: session.session?.userName ?? ''),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(l10n.welcome(session.session?.userName ?? ''),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.ink)),
                        const SizedBox(height: 4),
                        IconLine(icon: Icons.event_outlined, text: formatDate(today.date), fontSize: 13),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionTitle(icon: Icons.how_to_reg_outlined, text: l10n.attendanceTitle),
              const SizedBox(height: 10),
              _StatsGrid(
                stats: <_Stat>[
                  _Stat(l10n.statExpected, today.expected, colors.ink, colors.bg2, Icons.groups_outlined),
                  _Stat(l10n.statIn, today.checkedIn, colors.green, colors.greenSoft, Icons.login),
                  _Stat(l10n.statOut, today.checkedOut, colors.skyInk, colors.sky, Icons.logout),
                  _Stat(l10n.statAbsent, today.absent, colors.coral, colors.coralSoft, Icons.event_busy_outlined),
                  _Stat(l10n.statRemaining, today.remaining, colors.sun, colors.sunSoft, Icons.hourglass_bottom_outlined),
                ],
              ),
              const SizedBox(height: 22),
              _SectionTitle(icon: Icons.auto_awesome_outlined, text: l10n.activitiesBoard),
              const SizedBox(height: 10),
              _StatsGrid(
                stats: <_Stat>[
                  _Stat(l10n.statAdded, today.activitiesAdded, colors.ink, colors.bg2, Icons.note_add_outlined),
                  _Stat(l10n.statPublished, today.activitiesPublished, colors.green, colors.greenSoft, Icons.publish_outlined),
                  _Stat(l10n.statMissing, today.activitiesMissing, colors.coral, colors.coralSoft, Icons.error_outline),
                ],
              ),
              const SizedBox(height: 18),
              ActivityWindowNote(
                window: today.window,
                onExpired: () => context.read<StaffTodayCubit>().load(refresh: true),
                onAdd: () => Navigator.of(context).push(StaffStudentsPage.route()),
              ),
              const SizedBox(height: 14),
              const _ScanCard(),
            ],
          ),
        );
      },
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value, this.color, this.background, this.icon);

  final String label;
  final int value;
  final Color color;
  final Color background;
  final IconData icon;
}

/// عنوان قسم بأيقونة.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: colors.primaryInk),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.ink)),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: stats
          .map((_Stat stat) => SizedBox(
                width: 104,
                child: AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: stat.background,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(stat.icon, size: 15, color: stat.color),
                            const SizedBox(width: 5),
                            Text(
                              '${stat.value}',
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: stat.color),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stat.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: context.colors.muted),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

/// بطاقة المسح في لوحة اليوم: زر الباركود وتحته مسح الحضور والانصراف.
/// تظهر بحسب صلاحيات المستخدم القادمة من `GET /staff/me`.
class _ScanCard extends StatefulWidget {
  const _ScanCard();

  @override
  State<_ScanCard> createState() => _ScanCardState();
}

class _ScanCardState extends State<_ScanCard> {
  @override
  void initState() {
    super.initState();
    if (!StaffAbilities.loaded) {
      _load();
    }
  }

  Future<void> _load() async {
    await StaffAbilities.load(context.read<StaffApi>());
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refresh() async => context.read<StaffTodayCubit>().load(refresh: true);

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final StaffApi api = context.read<StaffApi>();
    final bool canScan = StaffAbilities.can(StaffAbilities.scanAttendance);
    final bool canAbsent = StaffAbilities.can(StaffAbilities.markAbsent);
    if (!canScan && !canAbsent) {
      return const SizedBox.shrink();
    }

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: <Widget>[
          if (canScan) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => scanAttendance(context, api, 'in', onScanned: _refresh),
                    icon: const Icon(Icons.login, size: 18),
                    label: Text(l10n.scanIn),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => scanAttendance(context, api, 'out', onScanned: _refresh),
                    icon: const Icon(Icons.logout, size: 18),
                    label: Text(l10n.scanOut),
                  ),
                ),
              ],
            ),
          ],
          if (canAbsent) ...<Widget>[
            SizedBox(height: canScan ? 10 : 0),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => markAbsentFlow(context, api, onDone: _refresh),
                icon: const Icon(Icons.event_busy_outlined, size: 18),
                label: Text(l10n.markAbsentAction),
              ),
            ),
          ],
          if (canScan) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              l10n.scanHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.muted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
