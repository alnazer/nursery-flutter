import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/parent_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import '../../common/failure_view.dart';
import 'checkout_page.dart';

/// قسائمي: الخصومات المتاحة لأبنائي.
class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const CouponsPage(),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<DetailCubit<List<Coupon>>>(
      create: (BuildContext context) => DetailCubit<List<Coupon>>(api.coupons)..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.couponsTitle)),
        body: BlocBuilder<DetailCubit<List<Coupon>>, DetailState<List<Coupon>>>(
          builder: (BuildContext context, DetailState<List<Coupon>> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(failure: state.failure!, onRetry: () => context.read<DetailCubit<List<Coupon>>>().load()),
              );
            }
            final List<Coupon> coupons = state.data ?? <Coupon>[];
            if (coupons.isEmpty) {
              return EmptyNote(text: l10n.emptyList);
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: coupons.length,
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) => _CouponCard(coupon: coupons[index]),
            );
          },
        ),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon});

  final Coupon coupon;

  /// نسخ الكود إلى الحافظة — من خدمات Flutter نفسها بلا مكتبة خارجية.
  Future<void> _copy(BuildContext context) async {
    final AppL10n l10n = AppL10n.of(context);
    await Clipboard.setData(ClipboardData(text: coupon.code));
    if (context.mounted) {
      showSuccessSnack(context, l10n.couponCopied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final String value = coupon.type == 'percent' ? '${coupon.value}%' : coupon.value;
    final bool usable = coupon.invoiceNumbers.isNotEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(coupon.name.isEmpty ? coupon.code : coupon.name,
                    style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
              ),
              StatusChip(text: l10n.couponValue(value), color: colors.green, background: colors.greenSoft),
            ],
          ),
          if (coupon.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(coupon.description, style: TextStyle(color: colors.muted, fontSize: 12)),
          ],
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.primaryInk, style: BorderStyle.solid),
                  color: colors.soft,
                ),
                child: Text(
                  coupon.code,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.primaryInk,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _copy(context),
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text(l10n.copy),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            <String>[
              if (coupon.endsAt != null) l10n.couponEnds(formatDate(coupon.endsAt!.toIso8601String())),
              if (coupon.children.isNotEmpty) l10n.couponFor(coupon.children.join('، ')),
            ].join(' · '),
            style: TextStyle(color: colors.muted, fontSize: 12),
          ),
          if (coupon.conditions.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            ...coupon.conditions.map((String condition) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.check, size: 14, color: colors.muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(condition, style: TextStyle(color: colors.body, fontSize: 13)),
                    ),
                  ],
                )),
          ],
          const SizedBox(height: 12),
          if (usable)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(CheckoutPage.route(
                  invoiceNumbers: coupon.invoiceNumbers,
                  coupon: coupon.code,
                )),
                icon: const Icon(Icons.local_offer_outlined, size: 18),
                label: Text(l10n.couponUse),
              ),
            )
          else
            Text(l10n.couponNoInvoices, style: TextStyle(color: colors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}
