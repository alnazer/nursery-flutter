import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/staff_api.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/detail_cubit.dart';
import '../../common/failure_view.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import '../../common/salary_privacy.dart';

/// راتبي: قسائم الرواتب المعتمدة وتفاصيل كل قسيمة.
class PayslipsPage extends StatelessWidget {
  const PayslipsPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const PayslipsPage(),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final StaffApi api = context.read<StaffApi>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.payslipsTitle),
        actions: const <Widget>[SalaryEyeButton()],
      ),
      body: BlocProvider<PagedCubit<Payslip>>(
        create: (BuildContext context) => PagedCubit<Payslip>((int page) => api.payslips(page: page))..load(),
        child: PagedListView<PagedCubit<Payslip>, Payslip>(
          emptyText: l10n.payslipsEmpty,
          itemBuilder: (BuildContext context, Payslip item) => _PayslipTile(payslip: item),
        ),
      ),
    );
  }
}

class _PayslipTile extends StatelessWidget {
  const _PayslipTile({required this.payslip});

  final Payslip payslip;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return AppCard(
      onTap: () => Navigator.of(context).push(PayslipDetailPage.route(payslip.id)),
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
                Text(payslip.period, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 3),
                Text(
                  payslip.payDate.isEmpty ? l10n.payslipNet : l10n.payslipPaidOn(formatDate(payslip.payDate)),
                  style: TextStyle(color: colors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          SalaryText(
            payslip.netLabel,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: colors.green),
          ),
        ],
      ),
    );
  }
}

/// تفاصيل قسيمة واحدة: الاستحقاقات والاستقطاعات والصافي.
class PayslipDetailPage extends StatelessWidget {
  const PayslipDetailPage({super.key, required this.id});

  final int id;

  static Route<void> route(int id) => MaterialPageRoute<void>(
        builder: (BuildContext context) => PayslipDetailPage(id: id),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final StaffApi api = context.read<StaffApi>();

    return BlocProvider<DetailCubit<PayslipDetail>>(
      create: (BuildContext context) => DetailCubit<PayslipDetail>(() => api.payslip(id))..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.payslipTitle),
          actions: const <Widget>[SalaryEyeButton()],
        ),
        body: BlocBuilder<DetailCubit<PayslipDetail>, DetailState<PayslipDetail>>(
          builder: (BuildContext context, DetailState<PayslipDetail> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(
                  failure: state.failure!,
                  onRetry: () => context.read<DetailCubit<PayslipDetail>>().load(),
                ),
              );
            }
            final PayslipDetail? detail = state.data;
            if (detail == null) {
              return const SizedBox.shrink();
            }
            final AppColors colors = context.colors;
            final String currency = detail.summary.currency;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: <Widget>[
                      Text(detail.summary.period,
                          style: TextStyle(color: colors.muted, fontSize: 13)),
                      const SizedBox(height: 6),
                      SalaryText(
                        '${detail.summary.net} $currency',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: colors.green),
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.payslipNet, style: TextStyle(color: colors.muted, fontSize: 12)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          _Figure(label: l10n.payslipGross, value: '${detail.summary.gross} $currency'),
                          _Figure(label: l10n.payslipDeductions, value: '${detail.summary.deductions} $currency'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    children: <Widget>[
                      _Row(
                        label: l10n.payslipBasic,
                        value: '${detail.basicSalary} $currency',
                        icon: Icons.payments_outlined,
                        money: true,
                      ),
                      _Row(
                        label: l10n.hrPresentDays,
                        value: _number(detail.paidDays),
                        icon: Icons.event_available_outlined,
                      ),
                      if (detail.absentDays > 0)
                        _Row(
                          label: l10n.hrAbsentDays,
                          value: _number(detail.absentDays),
                          icon: Icons.event_busy_outlined,
                        ),
                      if (detail.unpaidLeaveDays > 0)
                        _Row(
                          label: l10n.payslipUnpaidDays,
                          value: _number(detail.unpaidLeaveDays),
                          icon: Icons.money_off_outlined,
                        ),
                      if (detail.overtimeMinutes > 0)
                        _Row(
                          label: l10n.payslipOvertime,
                          value: l10n.minutesCount('${detail.overtimeMinutes}'),
                          icon: Icons.more_time_outlined,
                        ),
                      if (detail.bankName.isNotEmpty)
                        _Row(
                          label: l10n.payslipBank,
                          value: detail.ibanLast4.isEmpty
                              ? detail.bankName
                              : '${detail.bankName} ••••${detail.ibanLast4}',
                          icon: Icons.account_balance_outlined,
                        ),
                    ],
                  ),
                ),
                if (detail.earnings.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 18),
                  _Lines(
                    title: l10n.payslipEarnings,
                    lines: detail.earnings,
                    currency: currency,
                    color: colors.green,
                    icon: Icons.add_circle_outline,
                  ),
                ],
                if (detail.deductions.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  _Lines(
                    title: l10n.payslipDeductions,
                    lines: detail.deductions,
                    currency: currency,
                    color: colors.coral,
                    icon: Icons.remove_circle_outline,
                  ),
                ],
                if (detail.note.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  Text(detail.note, style: TextStyle(color: colors.muted, fontSize: 13, height: 1.6)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  static String _number(double value) =>
      value == value.roundToDouble() ? '${value.round()}' : value.toStringAsFixed(1);
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Column(
      children: <Widget>[
        SalaryText(value, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 11, color: colors.muted)),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.icon, this.money = false});

  final String label;
  final String value;
  final IconData? icon;

  /// المبالغ تُخفى مع بقيّة الراتب؛ الأيام وأرقام البنك تبقى ظاهرة.
  final bool money;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 16, color: colors.muted),
            const SizedBox(width: 6),
          ],
          Expanded(child: Text(label, style: TextStyle(color: colors.muted, fontSize: 13))),
          if (money)
            SalaryText(value, style: TextStyle(color: colors.ink, fontSize: 13, fontWeight: FontWeight.w600))
          else
            Text(value, style: TextStyle(color: colors.ink, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Lines extends StatelessWidget {
  const _Lines({
    required this.title,
    required this.lines,
    required this.currency,
    required this.color,
    required this.icon,
  });

  final String title;
  final IconData icon;
  final List<PayslipLine> lines;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
          ],
        ),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            children: lines
                .map((PayslipLine line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(line.title, style: TextStyle(color: colors.ink, fontSize: 13)),
                                if (line.note.isNotEmpty)
                                  Text(line.note, style: TextStyle(color: colors.muted, fontSize: 11)),
                              ],
                            ),
                          ),
                          SalaryText(
                            '${line.amount} $currency',
                            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
