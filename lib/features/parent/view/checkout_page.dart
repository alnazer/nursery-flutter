import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../common/failure_view.dart';
import '../../common/list_views.dart';
import 'payments_page.dart';

/// دفع الفواتير المستحقة دفعة واحدة: اختيار الفواتير، كوبون لكل فاتورة،
/// المجموع بعد الخصم، ثم طريقة الدفع وبدء العملية.
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, this.invoiceNumbers, this.coupon});

  /// فواتير محددة مسبقاً (من «قسائمي»). فارغة = كل المستحق.
  final List<String>? invoiceNumbers;

  /// كوبون يُطبَّق على الفواتير المحددة عند الفتح.
  final String? coupon;

  static Route<void> route({List<String>? invoiceNumbers, String? coupon}) => MaterialPageRoute<void>(
        builder: (BuildContext context) => CheckoutPage(invoiceNumbers: invoiceNumbers, coupon: coupon),
      );

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final Map<String, TextEditingController> _coupons = <String, TextEditingController>{};

  PaymentQuote _quote = PaymentQuote.empty;
  Set<String> _selected = <String>{};
  int? _methodId;
  bool _loading = true;
  bool _paying = false;
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    final List<String> preset = widget.invoiceNumbers ?? const <String>[];
    if (preset.isEmpty) {
      _load(all: true);

      return;
    }
    _selected = preset.toSet();
    for (final String number in preset) {
      _coupons[number] = TextEditingController(text: widget.coupon ?? '');
    }
    _load();
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _coupons.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, String> _couponValues() {
    final Map<String, String> out = <String, String>{};
    _coupons.forEach((String number, TextEditingController controller) {
      final String code = controller.text.trim();
      if (code.isNotEmpty && _selected.contains(number)) {
        out[number] = code;
      }
    });

    return out;
  }

  Future<void> _load({bool all = false}) async {
    setState(() {
      _loading = true;
      _failure = null;
    });
    try {
      final PaymentQuote quote = await context.read<ParentApi>().paymentQuote(
            all: all,
            numbers: all ? null : _selected.toList(),
            coupons: _couponValues(),
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _quote = quote;
        _loading = false;
        if (all) {
          _selected = quote.invoices.map((Invoice invoice) => invoice.number).toSet();
        }
        for (final Invoice invoice in quote.invoices) {
          _coupons.putIfAbsent(invoice.number, () => TextEditingController());
        }
        if (_methodId == null && quote.methods.isNotEmpty) {
          _methodId = quote.methods.first.id;
        }
      });
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failure = failure;
        });
      }
    }
  }

  Future<void> _pay() async {
    if (_paying || _selected.isEmpty) {
      return;
    }
    setState(() {
      _paying = true;
      _failure = null;
    });
    try {
      final PaymentStart start = await context.read<ParentApi>().payInvoices(
            numbers: _selected.toList(),
            coupons: _couponValues(),
            methodId: _methodId,
          );
      if (!mounted) {
        return;
      }
      setState(() => _paying = false);
      Navigator.of(context).push(PaymentStatusPage.route(start.reference, paymentUrl: start.paymentUrl));
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() {
          _paying = false;
          _failure = failure;
        });
      }
    }
  }

  void _toggle(String number, bool value) {
    setState(() {
      if (value) {
        _selected.add(number);
      } else {
        _selected.remove(number);
      }
    });
    _load();
  }

  /// مجموع الأسطر المحدّدة (الخادم يعيد المجموع لما أُرسل، فيُستعمل كما هو).
  String get _total => _quote.total;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: _loading && _quote.invoices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _failure != null && _quote.invoices.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: FailureView(failure: _failure!, onRetry: () => _load(all: true)),
                )
              : _quote.invoices.isEmpty
                  ? EmptyNote(text: l10n.checkoutEmpty)
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: <Widget>[
                        ..._quote.invoices.map(_invoiceCard),
                        ..._quote.busy.map((BusyInvoice item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SoftNote(
                                icon: Icons.lock_clock,
                                text: l10n.checkoutBusy(
                                  item.invoiceNumber,
                                  item.until == null ? '' : formatTime(item.until!),
                                ),
                              ),
                            )),
                        if (_quote.methods.length > 1) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(l10n.paymentMethod,
                              style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                          const SizedBox(height: 8),
                          ..._quote.methods.map((PaymentMethodItem method) => AppCard(
                                padding: EdgeInsets.zero,
                                child: RadioListTile<int>(
                                  value: method.id,
                                  groupValue: _methodId,
                                  onChanged: (int? value) => setState(() => _methodId = value),
                                  title: Text(method.title, style: TextStyle(color: colors.ink)),
                                  subtitle: method.description.isEmpty
                                      ? null
                                      : Text(method.description, style: TextStyle(color: colors.muted)),
                                  secondary: method.iconUrl == null
                                      ? null
                                      : Image.network(method.iconUrl!, width: 36, height: 36),
                                ),
                              )),
                        ],
                        const SizedBox(height: 14),
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(l10n.checkoutTotal,
                                    style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                              ),
                              if (_loading)
                                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              else
                                Text(
                                  '$_total ${_quote.currency}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: colors.primaryInk,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_failure != null) ...<Widget>[
                          const SizedBox(height: 12),
                          FailureView(failure: _failure!, compact: true),
                        ],
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: l10n.payNow,
                          busy: _paying,
                          onPressed: _selected.isEmpty || _loading || !_quote.canPay ? null : _pay,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.checkoutSelected('${_selected.length}'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.muted, fontSize: 12),
                        ),
                      ],
                    ),
    );
  }

  Widget _invoiceCard(Invoice invoice) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final QuoteLine? line = _quote.line(invoice.number);
    final CouponSuggestion? suggestion = _quote.suggestions[invoice.number];
    final TextEditingController controller =
        _coupons.putIfAbsent(invoice.number, () => TextEditingController());
    final bool checked = _selected.contains(invoice.number);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(
                  value: checked,
                  onChanged: _loading ? null : (bool? value) => _toggle(invoice.number, value == true),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(l10n.invoiceNumber(invoice.number),
                          style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                      const SizedBox(height: 2),
                      Text(invoice.studentName, style: TextStyle(color: colors.muted, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '${line?.amount ?? invoice.total} ${invoice.currency}',
                      style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink),
                    ),
                    if (line != null && line.hasDiscount)
                      Text(
                        '${line.subtotal} ${invoice.currency}',
                        style: TextStyle(
                          color: colors.muted,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (checked) ...<Widget>[
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (String _) => _load(),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: l10n.couponLabel,
                  errorText: line != null && line.couponError.isNotEmpty ? line.couponError : null,
                  prefixIcon: const Icon(Icons.local_offer_outlined, size: 18),
                  suffixIcon: TextButton(
                    onPressed: _loading ? null : () => _load(),
                    child: Text(l10n.couponApply),
                  ),
                ),
              ),
              if (suggestion != null && controller.text.trim().isEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.couponSuggested(suggestion.code, '${suggestion.discount} ${invoice.currency}'),
                        style: TextStyle(color: colors.green, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              controller.text = suggestion.code;
                              _load();
                            },
                      child: Text(l10n.couponUse),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
