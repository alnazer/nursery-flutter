import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/staff_api.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/detail_cubit.dart';
import '../../common/failure_view.dart';
import '../../common/list_views.dart';

/// أرصدة الإجازات: رصيد كل نوع كما يحسبه الخادم في `GET /staff/hr/summary`.
class LeaveBalancesPage extends StatelessWidget {
  const LeaveBalancesPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const LeaveBalancesPage(),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final StaffApi api = context.read<StaffApi>();

    return BlocProvider<DetailCubit<HrSummary>>(
      create: (BuildContext context) => DetailCubit<HrSummary>(api.hrSummary)..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.hrBalances)),
        body: BlocBuilder<DetailCubit<HrSummary>, DetailState<HrSummary>>(
          builder: (BuildContext context, DetailState<HrSummary> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(
                  failure: state.failure!,
                  onRetry: () => context.read<DetailCubit<HrSummary>>().load(),
                ),
              );
            }
            final List<LeaveBalance> balances = (state.data ?? HrSummary.empty).balances;
            if (balances.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context.read<DetailCubit<HrSummary>>().load(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: <Widget>[
                    const SizedBox(height: 40),
                    Icon(Icons.account_balance_wallet_outlined, size: 56, color: context.colors.muted),
                    const SizedBox(height: 12),
                    Text(
                      l10n.balancesEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.muted, height: 1.6),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<DetailCubit<HrSummary>>().load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: balances.length,
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) => _BalanceTile(balance: balances[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({required this.balance});

  final LeaveBalance balance;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final bool empty = balance.balance <= 0;
    final Color tint = empty ? colors.coral : colors.green;

    return AppCard(
      child: Row(
        children: <Widget>[
          IconBadge(
            icon: empty ? Icons.remove_circle_outline : Icons.account_balance_wallet_outlined,
            color: tint,
            background: empty ? colors.coralSoft : colors.greenSoft,
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              balance.title,
              style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink),
            ),
          ),
          Text(
            l10n.balanceDays(formatBalance(balance.balance)),
            style: TextStyle(fontWeight: FontWeight.w800, color: tint),
          ),
        ],
      ),
    );
  }
}

/// 3.0 → «3» و2.5 تبقى «2.5».
String formatBalance(double value) =>
    value == value.roundToDouble() ? '${value.round()}' : value.toStringAsFixed(1);
