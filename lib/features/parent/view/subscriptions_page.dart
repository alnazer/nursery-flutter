import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import '../../common/child_filter.dart';
import '../../common/prompt_dialog.dart';
import 'checkout_page.dart';
import 'invoices_page.dart';
import '../../common/failure_view.dart';

/// اشتراكات الأبناء مع طلب إيقاف الاشتراك.
class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const SubscriptionsPage(),
      );

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  /// '' الكل · 'current' السارية · وإلا حالة الاشتراك
  String _filter = '';
  int? _child;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.subscriptionsTitle)),
      body: Column(
        children: <Widget>[
          FilterBar<String>(
            selected: _filter,
            onSelected: (String value) => setState(() => _filter = value),
            options: <FilterOption<String>>[
              FilterOption<String>(value: '', label: l10n.filterAll),
              FilterOption<String>(value: 'current', label: l10n.filterCurrent, icon: Icons.play_circle_outline),
              FilterOption<String>(value: 'paid', label: l10n.filterPaid),
              FilterOption<String>(value: 'unpaid', label: l10n.filterUnpaid),
              FilterOption<String>(value: 'expired', label: l10n.filterExpired),
            ],
          ),
          ChildFilterBar(selected: _child, onSelected: (int? value) => setState(() => _child = value)),
          Expanded(
            child: BlocProvider<PagedCubit<Subscription>>(
              key: ValueKey<String>('$_filter|$_child'),
              create: (BuildContext context) => PagedCubit<Subscription>(
                (int page) => api.subscriptions(
                  page: page,
                  current: _filter == 'current',
                  status: _filter.isEmpty || _filter == 'current' ? null : _filter,
                  studentId: _child,
                ),
              )..load(),
              child: PagedListView<PagedCubit<Subscription>, Subscription>(
                itemBuilder: (BuildContext context, Subscription item) =>
                    _SubscriptionTile(subscription: item, api: api),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({required this.subscription, required this.api});

  final Subscription subscription;
  final ParentApi api;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final bool paid = subscription.isPaid;
    final Color accent = paid ? colors.green : colors.sun;
    final Color accentSoft = paid ? colors.greenSoft : colors.sunSoft;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: accentSoft, borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Icon(paid ? Icons.verified_outlined : Icons.pending_actions_outlined, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(subscription.title,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: colors.ink)),
                    const SizedBox(height: 3),
                    Text(subscription.studentName, style: TextStyle(color: colors.muted, fontSize: 12)),
                  ],
                ),
              ),
              StatusChip(
                text: subscription.statusLabel,
                color: accent,
                background: accentSoft,
                icon: paid ? Icons.check_circle_outline : Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: 12),
          IconLine(
            icon: Icons.date_range_outlined,
            text: l10n.subscriptionPeriod(formatDate(subscription.startsAt), formatDate(subscription.endsAt)),
          ),
          if (subscription.isCurrent && subscription.daysLeft > 0)
            IconLine(
              icon: Icons.hourglass_bottom_outlined,
              text: l10n.daysLeft('${subscription.daysLeft}'),
              color: colors.primaryInk,
            ),
          if (subscription.products.isNotEmpty)
            IconLine(icon: Icons.add_shopping_cart_outlined, text: subscription.products.join('، ')),
          if (subscription.amount.isNotEmpty)
            IconLine(
              icon: Icons.payments_outlined,
              text: '${subscription.amount} ${subscription.currency}',
              bold: true,
            ),
          if (subscription.hasInvoice)
            IconLine(
              icon: Icons.receipt_long_outlined,
              text: l10n.invoiceNumber(subscription.invoiceNumber),
            ),
          const SizedBox(height: 12),
          if (subscription.hasInvoice)
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).push(InvoiceDetailPage.route(subscription.invoiceId)),
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: Text(l10n.showInvoice),
                  ),
                ),
                if (subscription.invoiceCanPay) ...<Widget>[
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(CheckoutPage.route(
                        invoiceNumbers: <String>[subscription.invoiceNumber],
                      )),
                      icon: const Icon(Icons.credit_card, size: 18),
                      label: Text(l10n.payNow),
                    ),
                  ),
                ],
              ],
            ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () => _requestStop(context),
              icon: Icon(Icons.pause_circle_outline, size: 18, color: colors.coral),
              label: Text(l10n.requestStop, style: TextStyle(color: colors.coral)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestStop(BuildContext context) async {
    final AppL10n l10n = AppL10n.of(context);

    // طلب قائم قيد المراجعة؟ اعرض حالته بدل فتح النموذج (الخادم يرفضه بـ 409).
    try {
      final Map<String, dynamic>? existing = await api.cancellationRequest(subscription.studentId);
      if (existing != null && '${existing['status']}' == 'new' && context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: Text(l10n.requestStop),
            content: Text(
              <String>[
                '${existing['status_label'] ?? ''}',
                if (existing['created_at'] != null) formatDateTime(DateTime.tryParse('${existing['created_at']}')),
                if ('${existing['reason'] ?? ''}'.isNotEmpty) '${existing['reason']}',
              ].where((String part) => part.trim().isNotEmpty).join('\n'),
            ),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.close)),
            ],
          ),
        );

        return;
      }
    } on ApiFailure {
      // تعذّر جلب الحالة لا يمنع فتح النموذج
    }
    if (!context.mounted) {
      return;
    }
    final PromptResult? result = await showPromptDialog(
      context,
      title: l10n.requestStop,
      label: l10n.requestStopReason,
      maxLines: 3,
      minLength: 5,
    );
    if (result == null || result.text.isEmpty || !context.mounted) {
      return;
    }
    try {
      await api.requestCancellation(subscription.studentId, result.text);
      if (context.mounted) {
        showSuccessSnack(context, l10n.requestStopSent);
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }
}

/// اختصار للانتقال إلى الفواتير من الاشتراكات.
Route<void> invoicesRoute() => InvoicesPage.route();
