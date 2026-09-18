import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/staff_api.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import '../../common/salary_privacy.dart';
import '../../common/user_avatar.dart';
import 'corrections_page.dart';
import 'hr_attendance_page.dart';
import 'leave_balances_page.dart';
import 'leaves_page.dart';
import 'payslips_page.dart';
import 'violations_page.dart';
import '../../common/failure_view.dart';

/// خدماتي: ملخّص الحضور الشهري وأرصدة الإجازات ومداخل الإجازات والمخالفات.
class HrPage extends StatelessWidget {
  const HrPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const HrPage(),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final StaffApi api = context.read<StaffApi>();

    return BlocProvider<DetailCubit<HrSummary>>(
      create: (BuildContext context) => DetailCubit<HrSummary>(api.hrSummary)..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.hrTitle),
          actions: const <Widget>[SalaryEyeButton()],
        ),
        body: BlocBuilder<DetailCubit<HrSummary>, DetailState<HrSummary>>(
          builder: (BuildContext context, DetailState<HrSummary> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(failure: state.failure!, onRetry: () => context.read<DetailCubit<HrSummary>>().load()),
              );
            }
            final HrSummary summary = state.data ?? HrSummary.empty;
            final AppColors colors = context.colors;

            return RefreshIndicator(
              onRefresh: () => context.read<DetailCubit<HrSummary>>().load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  StaffIdentity(
                    name: summary.name,
                    subtitle: <String>[summary.jobTitle, summary.branch]
                        .where((String part) => part.isNotEmpty)
                        .join(' · '),
                    size: 56,
                  ),
                  if (summary.month.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    IconLine(icon: Icons.calendar_month_outlined, text: summary.month, fontSize: 13),
                  ],
                  const SizedBox(height: 16),
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _Stat(label: l10n.hrPresentDays, value: '${summary.present}', color: colors.green),
                        _Stat(label: l10n.hrAbsentDays, value: '${summary.absent}', color: colors.coral),
                        _Stat(label: l10n.hrLeaveDays, value: '${summary.leaveDays}', color: colors.skyInk),
                        _Stat(label: l10n.hrLateMinutes, value: '${summary.lateMinutes}', color: colors.sun),
                      ],
                    ),
                  ),
                  if (summary.lastPayslip != null) ...<Widget>[
                    const SizedBox(height: 12),
                    AppCard(
                      onTap: () => Navigator.of(context).push(PayslipsPage.route()),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: colors.soft, borderRadius: BorderRadius.circular(14)),
                            alignment: Alignment.center,
                            child: Icon(Icons.payments_outlined, color: colors.primaryInk),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(l10n.payslipLast,
                                    style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                                const SizedBox(height: 3),
                                Text(summary.lastPayslip!.period,
                                    style: TextStyle(color: colors.muted, fontSize: 12)),
                              ],
                            ),
                          ),
                          SalaryText(
                            summary.lastPayslip!.netLabel,
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (summary.balances.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Icon(Icons.account_balance_wallet_outlined, size: 18, color: colors.primaryInk),
                        const SizedBox(width: 8),
                        Text(l10n.hrBalances, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: summary.balances
                          .map((LeaveBalance balance) => StatusChip(
                                text: '${balance.title}: ${l10n.balanceDays(_number(balance.balance))}',
                                color: balance.balance <= 0 ? colors.coral : colors.green,
                                background: balance.balance <= 0 ? colors.coralSoft : colors.greenSoft,
                                icon: Icons.event_available_outlined,
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 22),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(Icons.fact_check_outlined, color: colors.primaryInk),
                      title: Text(l10n.hrAttendanceTitle, style: TextStyle(color: colors.ink)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(HrAttendancePage.route()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(Icons.schedule_outlined, color: colors.primaryInk),
                      title: Text(l10n.correctionsTitle, style: TextStyle(color: colors.ink)),
                      subtitle: summary.pendingCorrections > 0
                          ? Text('${summary.pendingCorrections}', style: TextStyle(color: colors.muted))
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(CorrectionsPage.route()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(Icons.account_balance_wallet_outlined, color: colors.primaryInk),
                      title: Text(l10n.hrBalances, style: TextStyle(color: colors.ink)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(LeaveBalancesPage.route()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(Icons.event_available_outlined, color: colors.primaryInk),
                      title: Text(l10n.leavesTitle, style: TextStyle(color: colors.ink)),
                      subtitle: summary.pendingLeaves > 0
                          ? Text('${summary.pendingLeaves}', style: TextStyle(color: colors.muted))
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(LeavesPage.route()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(Icons.payments_outlined, color: colors.primaryInk),
                      title: Text(l10n.payslipsTitle, style: TextStyle(color: colors.ink)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(PayslipsPage.route()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(Icons.gavel_outlined, color: colors.primaryInk),
                      title: Text(l10n.violationsTitle, style: TextStyle(color: colors.ink)),
                      subtitle: summary.openViolations > 0
                          ? Text('${summary.openViolations}', style: TextStyle(color: colors.coral))
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(ViolationsPage.route()),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static String _number(double value) =>
      value == value.roundToDouble() ? '${value.round()}' : value.toStringAsFixed(1);
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: context.colors.muted)),
      ],
    );
  }
}
