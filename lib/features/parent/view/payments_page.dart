import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import '../../common/failure_view.dart';

/// مدفوعاتي: عمليات الدفع السابقة وإيصالاتها.
class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const PaymentsPage(),
      );

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  String _status = '';

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentsTitle)),
      body: Column(
        children: <Widget>[
          FilterBar<String>(
            selected: _status,
            onSelected: (String value) => setState(() => _status = value),
            options: <FilterOption<String>>[
              FilterOption<String>(value: '', label: l10n.filterAll),
              FilterOption<String>(value: 'paid', label: l10n.filterPaid),
              FilterOption<String>(value: 'pending', label: l10n.filterPending),
              FilterOption<String>(value: 'failed', label: l10n.filterFailed),
              FilterOption<String>(value: 'expired', label: l10n.filterExpired),
            ],
          ),
          Expanded(
            child: BlocProvider<PagedCubit<PaymentItem>>(
              key: ValueKey<String>(_status),
              create: (BuildContext context) => PagedCubit<PaymentItem>(
                (int page) => api.payments(page: page, status: _status.isEmpty ? null : _status),
              )..load(),
              child: PagedListView<PagedCubit<PaymentItem>, PaymentItem>(
                itemBuilder: (BuildContext context, PaymentItem item) => _PaymentTile(payment: item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});

  final PaymentItem payment;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final bool paid = payment.isPaid;
    final bool failed = !paid && payment.isFinal;
    final Color accent = paid ? colors.green : (failed ? colors.coral : colors.sun);
    final Color accentSoft = paid ? colors.greenSoft : (failed ? colors.coralSoft : colors.sunSoft);

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.of(context).push(PaymentStatusPage.route(payment.reference)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconBadge(
            icon: paid
                ? Icons.task_alt
                : (failed ? Icons.credit_card_off_outlined : Icons.hourglass_bottom_outlined),
            color: accent,
            background: accentSoft,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text('${payment.amount} ${payment.currency}',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: colors.ink)),
                    ),
                    StatusChip(
                      text: payment.statusLabel,
                      color: accent,
                      background: accentSoft,
                      icon: paid ? Icons.check_circle_outline : (failed ? Icons.error_outline : Icons.schedule),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (payment.invoicesCount > 0)
                  IconLine(
                    icon: Icons.receipt_long_outlined,
                    text: l10n.invoicesCount('${payment.invoicesCount}'),
                  ),
                if (payment.createdAt != null)
                  IconLine(icon: Icons.schedule_outlined, text: formatDateTime(payment.createdAt)),
                IconLine(icon: Icons.tag, text: payment.reference),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentStatusPage extends StatefulWidget {
  const PaymentStatusPage({super.key, required this.reference, this.paymentUrl});

  final String reference;
  final String? paymentUrl;

  static Route<void> route(String reference, {String? paymentUrl}) => MaterialPageRoute<void>(
        builder: (BuildContext context) => PaymentStatusPage(reference: reference, paymentUrl: paymentUrl),
      );

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  PaymentItem? _payment;
  bool _busy = false;
  bool _opened = false;
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    if (widget.paymentUrl != null && widget.paymentUrl!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) => _open());
    } else {
      _check();
    }
  }

  Future<void> _open() async {
    final AppL10n l10n = AppL10n.of(context);
    final bool opened = await const NativeBridge().openUrl(widget.paymentUrl ?? '');
    if (!mounted) {
      return;
    }
    setState(() => _opened = opened);
    if (!opened) {
      showInfoSnack(context, l10n.cannotOpenLink);
    }
  }

  Future<void> _check() async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final PaymentItem payment = await context.read<ParentApi>().payment(widget.reference);
      if (mounted) {
        setState(() {
          _payment = payment;
          _busy = false;
        });
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failure = failure;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final PaymentItem? payment = _payment;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (payment != null) ...<Widget>[
            Icon(
              payment.isPaid
                  ? Icons.check_circle_outline
                  : payment.isFinal
                      ? Icons.cancel_outlined
                      : Icons.hourglass_bottom,
              size: 64,
              color: payment.isPaid ? colors.green : (payment.isFinal ? colors.coral : colors.sun),
            ),
            const SizedBox(height: 14),
            Text(
              payment.message != null && payment.message!.isNotEmpty
                  ? payment.message!
                  : payment.isPaid
                      ? l10n.paymentPaid
                      : payment.isFinal
                          ? l10n.paymentFailed
                          : l10n.paymentPending,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colors.ink, height: 1.6),
            ),
            const SizedBox(height: 8),
            Text('${payment.amount} ${payment.currency}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.primaryInk)),
            const SizedBox(height: 20),
          ] else if (_opened) ...<Widget>[
            SoftNote(text: l10n.paymentOpened, icon: Icons.open_in_new),
            const SizedBox(height: 16),
          ],
          if (_failure != null) ...<Widget>[
            FailureView(failure: _failure!, compact: true),
            const SizedBox(height: 12),
          ],
          PrimaryButton(label: l10n.paymentCheck, busy: _busy, onPressed: _check),
          if (widget.paymentUrl != null && widget.paymentUrl!.isNotEmpty && (payment == null || !payment.isFinal)) ...<Widget>[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _open,
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.paymentOpen),
            ),
          ],
          if (payment?.receiptUrl != null) ...<Widget>[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => const NativeBridge().openUrl(payment!.receiptUrl!),
              icon: const Icon(Icons.receipt_outlined),
              label: Text(l10n.receipt),
            ),
          ],
        ],
      ),
    );
  }
}
