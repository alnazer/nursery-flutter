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
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import '../../common/child_filter.dart';
import 'checkout_page.dart';
import 'payments_page.dart';
import '../../common/failure_view.dart';

/// الفواتير: قائمة مصفّاة مع المبلغ وحالة السداد.
class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key, this.asTab = false});

  final bool asTab;

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const InvoicesPage(),
      );

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  /// '' الكل · 'payable' المستحقة · وإلا حالة الفاتورة
  String _filter = '';
  int? _child;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    final Widget body = Column(
      children: <Widget>[
        FilterBar<String>(
          selected: _filter,
          onSelected: (String value) => setState(() => _filter = value),
          options: <FilterOption<String>>[
            FilterOption<String>(value: '', label: l10n.filterAll),
            FilterOption<String>(value: 'payable', label: l10n.filterDue, icon: Icons.schedule),
            FilterOption<String>(value: 'paid', label: l10n.filterPaid),
            FilterOption<String>(value: 'unpaid', label: l10n.filterUnpaid),
            FilterOption<String>(value: 'expired', label: l10n.filterExpired),
          ],
        ),
        ChildFilterBar(selected: _child, onSelected: (int? value) => setState(() => _child = value)),
        Expanded(
          child: BlocProvider<PagedCubit<Invoice>>(
            key: ValueKey<String>('$_filter|$_child'),
            create: (BuildContext context) => PagedCubit<Invoice>(
              (int page) => api.invoices(
                page: page,
                payable: _filter == 'payable',
                status: _filter.isEmpty || _filter == 'payable' ? null : _filter,
                studentId: _child,
              ),
            )..load(),
            child: PagedListView<PagedCubit<Invoice>, Invoice>(
              itemBuilder: (BuildContext context, Invoice item) => _InvoiceTile(invoice: item),
            ),
          ),
        ),
      ],
    );

    if (widget.asTab) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: <Widget>[
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(CheckoutPage.route()),
                  icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                  label: Text(l10n.checkoutTitle),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(PaymentsPage.route()),
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: Text(l10n.paymentsTitle),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoicesTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.checkoutTitle,
            onPressed: () => Navigator.of(context).push(CheckoutPage.route()),
            icon: const Icon(Icons.shopping_cart_checkout),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(PaymentsPage.route()),
            child: Text(l10n.paymentsTitle),
          ),
        ],
      ),
      body: body,
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final bool paid = invoice.status == 'paid';
    final bool overdue = !paid && invoice.isOverdue;
    final Color accent = paid ? colors.green : (overdue ? colors.coral : colors.sun);
    final Color accentSoft = paid ? colors.greenSoft : (overdue ? colors.coralSoft : colors.sunSoft);

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.of(context).push(InvoiceDetailPage.route(invoice.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: accentSoft, borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: Icon(
              paid
                  ? Icons.receipt_long
                  : (overdue ? Icons.running_with_errors_outlined : Icons.receipt_long_outlined),
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(l10n.invoiceNumber(invoice.number),
                          style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                    ),
                    StatusChip(
                      text: invoice.statusLabel,
                      color: accent,
                      background: accentSoft,
                      icon: paid ? Icons.check_circle_outline : (overdue ? Icons.error_outline : Icons.schedule),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Icon(Icons.payments_outlined, size: 18, color: accent),
                    const SizedBox(width: 6),
                    Text('${invoice.total} ${invoice.currency}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.ink)),
                  ],
                ),
                const SizedBox(height: 6),
                if (invoice.studentName.isNotEmpty)
                  IconLine(icon: Icons.child_care_outlined, text: invoice.studentName),
                IconLine(
                  icon: overdue ? Icons.event_busy_outlined : Icons.event_outlined,
                  text: overdue ? l10n.overdue : l10n.dueOn(formatDate(invoice.dueDate)),
                  color: overdue ? colors.coral : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceDetailPage extends StatelessWidget {
  const InvoiceDetailPage({super.key, required this.id});

  final int id;

  static Route<void> route(int id) => MaterialPageRoute<void>(
        builder: (BuildContext context) => InvoiceDetailPage(id: id),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<DetailCubit<Invoice>>(
      create: (BuildContext context) => DetailCubit<Invoice>(() => api.invoice(id))..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.invoicesTitle)),
        body: BlocBuilder<DetailCubit<Invoice>, DetailState<Invoice>>(
          builder: (BuildContext context, DetailState<Invoice> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(failure: state.failure!, onRetry: () => context.read<DetailCubit<Invoice>>().load()),
              );
            }
            final Invoice invoice = state.data!;
            final AppColors colors = context.colors;

            final bool paid = invoice.status == 'paid';
            final bool overdue = !paid && invoice.isOverdue;
            final Color accent = paid ? colors.green : (overdue ? colors.coral : colors.sun);
            final Color accentSoft = paid ? colors.greenSoft : (overdue ? colors.coralSoft : colors.sunSoft);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(color: accentSoft, borderRadius: BorderRadius.circular(18)),
                        alignment: Alignment.center,
                        child: Icon(paid ? Icons.verified_outlined : Icons.receipt_long_outlined,
                            size: 30, color: accent),
                      ),
                      const SizedBox(height: 10),
                      Text(l10n.invoiceNumber(invoice.number),
                          style: TextStyle(color: colors.muted, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text('${invoice.total} ${invoice.currency}',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: colors.ink)),
                      const SizedBox(height: 10),
                      StatusChip(
                        text: invoice.statusLabel,
                        color: accent,
                        background: accentSoft,
                        icon: paid ? Icons.check_circle_outline : (overdue ? Icons.error_outline : Icons.schedule),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(
                    children: <Widget>[
                      if (invoice.studentName.isNotEmpty)
                        IconLine(icon: Icons.child_care_outlined, text: invoice.studentName),
                      IconLine(
                        icon: overdue ? Icons.event_busy_outlined : Icons.event_outlined,
                        text: overdue ? l10n.overdue : l10n.dueOn(formatDate(invoice.dueDate)),
                        color: overdue ? colors.coral : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Icon(Icons.list_alt_outlined, size: 18, color: colors.primaryInk),
                    const SizedBox(width: 8),
                    Text(l10n.invoiceItems, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                  ],
                ),
                const SizedBox(height: 10),
                ...invoice.items.map((InvoiceItem item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.chevron_left, size: 18, color: colors.muted),
                            const SizedBox(width: 6),
                            Expanded(child: Text(item.title, style: TextStyle(color: colors.body, fontSize: 13))),
                            Text('${item.total} ${invoice.currency}',
                                style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 18),
                if (invoice.canPay) _PayButton(invoice: invoice),
                if (paid) _PdfButton(invoice: invoice),
              ],
            );
          },
        ),
      ),
    );
  }
}


/// كوبون اختياري ثم بدء الدفع وفتح صفحة البوابة.
class _PayButton extends StatefulWidget {
  const _PayButton({required this.invoice});

  final Invoice invoice;

  @override
  State<_PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends State<_PayButton> {
  final TextEditingController _coupon = TextEditingController();

  bool _busy = false;
  bool _checking = false;
  CouponCheck? _check;
  ApiFailure? _failure;

  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    final String code = _coupon.text.trim();
    if (code.isEmpty || _checking) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _checking = true;
      _failure = null;
    });
    try {
      final CouponCheck result = await context.read<ParentApi>().validateCoupon(
            code: code,
            invoiceId: widget.invoice.id,
          );
      if (mounted) {
        setState(() {
          _checking = false;
          _check = result;
        });
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() {
          _checking = false;
          _failure = failure;
        });
      }
    }
  }

  Future<void> _pay() async {
    if (_busy) {
      return;
    }
    final String code = _coupon.text.trim();
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final PaymentStart start = await context.read<ParentApi>().payInvoice(
            widget.invoice.id,
            coupon: code.isEmpty ? null : code,
          );
      if (mounted) {
        setState(() => _busy = false);
        Navigator.of(context).push(
          PaymentStatusPage.route(start.reference, paymentUrl: start.paymentUrl),
        );
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
    final CouponCheck? check = _check;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _coupon,
          textInputAction: TextInputAction.done,
          onSubmitted: (String _) => _validate(),
          decoration: InputDecoration(
            labelText: l10n.couponLabel,
            prefixIcon: const Icon(Icons.local_offer_outlined, size: 18),
            errorText: check != null && !check.valid ? check.message : null,
            suffixIcon: TextButton(
              onPressed: _checking ? null : _validate,
              child: _checking
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.couponApply),
            ),
          ),
        ),
        if (check != null && check.valid) ...<Widget>[
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Icon(Icons.verified_outlined, size: 18, color: colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.couponAccepted('${check.discount} ${widget.invoice.currency}',
                      '${check.total} ${widget.invoice.currency}'),
                  style: TextStyle(color: colors.green, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
        if (_failure != null) ...<Widget>[
          const SizedBox(height: 10),
          FailureView(failure: _failure!, compact: true),
        ],
        const SizedBox(height: 14),
        PrimaryButton(label: l10n.payNow, busy: _busy, onPressed: _pay),
      ],
    );
  }
}

/// تحميل نسخة الفاتورة المدفوعة (رابط مؤقّت من الخادم يُفتح خارج التطبيق).
class _PdfButton extends StatefulWidget {
  const _PdfButton({required this.invoice});

  final Invoice invoice;

  @override
  State<_PdfButton> createState() => _PdfButtonState();
}

class _PdfButtonState extends State<_PdfButton> {
  bool _busy = false;

  Future<void> _open() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    final AppL10n l10n = AppL10n.of(context);
    try {
      final String url = await context.read<ParentApi>().invoicePdf(widget.invoice.id);
      if (!mounted) {
        return;
      }
      if (url.isEmpty) {
        showInfoSnack(context, l10n.invoicePdfFailed);
      } else {
        await const NativeBridge().openUrl(url);
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        showFailureSnack(context, failure);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return OutlinedButton.icon(
      onPressed: _busy ? null : _open,
      icon: _busy
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.picture_as_pdf_outlined, size: 18),
      label: Text(l10n.invoicePdf),
    );
  }
}
