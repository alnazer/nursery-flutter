import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursery/core/api/api_failure.dart';
import 'package:nursery/core/models/card_design.dart';
import 'package:nursery/core/models/paged.dart';
import 'package:nursery/core/models/parent_models.dart';
import 'package:nursery/core/models/staff_models.dart';
import 'package:nursery/core/util/formatters.dart';
import 'package:nursery/features/common/paged_cubit.dart';
import 'package:nursery/widgets/student_card_view.dart';

void main() {
  group('بطاقة الطالب', () {
    test('يقرأ التصميم والقيم ورمز QR', () {
      final StudentCard card = StudentCard.fromJson(<String, dynamic>{
        'qr': 'Xy7Kp2Qa',
        'qr_image': 'data:image/png;base64,${base64Encode(<int>[1, 2, 3])}',
        'photo_url': 'https://example.com/a.png',
        'branch_logo_url': null,
        'vars': <String, dynamic>{'student_name': 'سارة', 'classroom': 'KG1', 'civil_id': null},
        'assets': <String, dynamic>{'uploads_base': 'https://example.com/uploads/', 'app_logo': 'https://x/l.png'},
        'design': <String, dynamic>{
          'size': <String, dynamic>{'w': 85.6, 'h': 54},
          'radius': 3,
          'faces': <String, dynamic>{
            'front': <String, dynamic>{
              'bg': <String, dynamic>{'color': '#ffffff'},
              'elements': <dynamic>[
                <String, dynamic>{'id': 'a', 'type': 'text', 'text': '{student_name}', 'size': 9},
              ],
            },
            'back': <String, dynamic>{'bg': <String, dynamic>{}, 'elements': <dynamic>[]},
          },
        },
      });

      expect(card.qr, 'Xy7Kp2Qa');
      expect(card.qrImage, isNotNull);
      expect(card.qrImage!.length, 3);
      expect(card.vars['civil_id'], '');
      expect(card.design.width, 85.6);
      expect(card.design.face('front')!.elements.single.type, 'text');
      // الوجه الخلفي بلا عناصر لا يُعدّ وجهاً قابلاً للعرض
      expect(card.design.hasBack, isFalse);
    });

    test('روابط الصور: الشعار والملفات المرفوعة', () {
      const StudentCard card = StudentCard(
        qr: '',
        qrImage: null,
        photoUrl: null,
        branchLogoUrl: 'https://x/branch.png',
        appLogoUrl: 'https://x/app.png',
        uploadsBase: 'https://x/uploads/',
        vars: <String, String>{},
        design: CardDesign.empty,
      );

      expect(card.imageUrl('@app_logo'), 'https://x/app.png');
      expect(card.imageUrl('@branch_logo'), 'https://x/branch.png');
      expect(card.imageUrl('bg.png'), 'https://x/uploads/bg.png');
      expect(card.imageUrl(null), isNull);
    });

    test('ألوان CSS بكل صيغها', () {
      expect(cardColor('#fff'), const Color(0xFFFFFFFF));
      expect(cardColor('#4338CA'), const Color(0xFF4338CA));
      // الشفافية في آخر النص بصيغة CSS وفي أول القيمة في Flutter
      expect(cardColor('#00000080'), const Color(0x80000000));
      expect(cardColor('transparent'), const Color(0x00000000));
      expect(cardColor('nope'), isNull);
      expect(cardColor(null), isNull);
    });

    test('استبدال المتغيّرات وإخفاء الفارغ', () {
      const Map<String, String> vars = <String, String>{'student_name': 'سارة', 'civil_id': ''};

      expect(resolveCardText('الاسم: {student_name}', vars), 'الاسم: سارة');
      expect(resolveCardText('{unknown}', vars), '');
      expect(hasEmptyCardVar('{student_name}', vars), isFalse);
      expect(hasEmptyCardVar('{civil_id}', vars), isTrue);
    });
  });

  group('الدفع', () {
    test('معاينة الدفع تقرأ الأسطر والاقتراحات وطرق الدفع', () {
      final PaymentQuote quote = PaymentQuote.fromJson(<String, dynamic>{
        'invoices': <dynamic>[
          <String, dynamic>{'id': 512, 'number': '512', 'total': '120.000', 'currency': 'KWD'},
        ],
        'lines': <dynamic>[
          <String, dynamic>{
            'invoice_number': '512',
            'subtotal': '120.000',
            'discount': '12.000',
            'amount': '108.000',
            'coupon_code': 'WELCOME10',
            'coupon_error': null,
          },
        ],
        'busy': <dynamic>[
          <String, dynamic>{'invoice_number': '513', 'until': '2026-09-22T08:20:00+03:00'},
        ],
        'suggestions': <String, dynamic>{
          '513': <String, dynamic>{'code': 'SIBLING5', 'name': 'خصم الإخوة', 'discount': '5.000'},
        },
        'methods': <dynamic>[
          <String, dynamic>{'id': 3, 'title': 'كي نت'},
        ],
        'total': '108.000',
        'currency': 'KWD',
        'can_pay': true,
        'max_invoices': 20,
      });

      expect(quote.canPay, isTrue);
      expect(quote.line('512')!.hasDiscount, isTrue);
      expect(quote.line('999'), isNull);
      expect(quote.busy.single.until, isNotNull);
      expect(quote.suggestions['513']!.code, 'SIBLING5');
      expect(quote.methods.single.id, 3);
    });

    test('التحقق من الكوبون يقرأ الرفض كنتيجة لا كخطأ', () {
      final CouponCheck check = CouponCheck.fromJson(<String, dynamic>{
        'valid': false,
        'reason': 'expired',
        'message': 'انتهت صلاحية الكوبون',
        'code': 'OLD5',
        'subtotal': '120.000',
        'discount': '0.000',
        'total': '120.000',
      });

      expect(check.valid, isFalse);
      expect(check.message, 'انتهت صلاحية الكوبون');
    });

    test('القسيمة تحمل فواتيرها المستحقة', () {
      final Coupon coupon = Coupon.fromJson(<String, dynamic>{
        'code': 'WELCOME10',
        'name': 'خصم الترحيب',
        'type': 'percent',
        'value': '10.000',
        'description': 'للطلاب الجدد',
        'children': <dynamic>['سارة'],
        'conditions': <dynamic>[],
        'payable_invoice_numbers': <dynamic>['512', '513'],
      });

      expect(coupon.invoiceNumbers, <String>['512', '513']);
      expect(coupon.description, 'للطلاب الجدد');
    });
  });

  group('الاشتراك', () {
    test('يقرأ فاتورته وحالتها', () {
      final Subscription subscription = Subscription.fromJson(<String, dynamic>{
        'id': 90,
        'title': 'September 2026',
        'status': 'unpaid',
        'status_label': 'غير مدفوع',
        'starts_at': '2026-09-01',
        'ends_at': '2026-09-30',
        'is_current': true,
        'days_left': 8,
        'student': <String, dynamic>{'id': 33, 'name': 'سارة'},
        'amount': '120.000',
        'currency': 'KWD',
        'products': <dynamic>[
          <String, dynamic>{'id': 4, 'title': 'اشتراك الباص'},
        ],
        'invoice': <String, dynamic>{'id': 512, 'number': '512', 'status': 'pending', 'can_pay': true},
      });

      expect(subscription.hasInvoice, isTrue);
      expect(subscription.invoiceCanPay, isTrue);
      expect(subscription.isPaid, isFalse);
      expect(subscription.products, <String>['اشتراك الباص']);
    });
  });

  group('قسيمة الراتب', () {
    test('تقرأ الصافي والاستحقاقات والاستقطاعات', () {
      final PayslipDetail detail = PayslipDetail.fromJson(<String, dynamic>{
        'id': 40,
        'period': '2026-08',
        'net': '650.000',
        'gross': '700.000',
        'deductions': '50.000',
        'currency': 'KWD',
        'basic_salary': '600.000',
        'paid_days': 30,
        'iban_last4': '1234',
        'earnings': <dynamic>[
          <String, dynamic>{'code': 'basic', 'title': 'الراتب الأساسي', 'amount': '600.000'},
        ],
        'deductions_lines': <dynamic>[
          <String, dynamic>{'code': 'penalty', 'title': 'جزاء تأخير', 'amount': '50.000'},
        ],
      });

      expect(detail.summary.netLabel, '650.000 KWD');
      expect(detail.earnings.single.title, 'الراتب الأساسي');
      expect(detail.deductions.single.amount, '50.000');
      expect(detail.paidDays, 30);
    });
  });

  group('الترقيم', () {
    test('loadMore يُلحق الصفحة التالية ويوقف عند النهاية', () async {
      final PagedCubit<int> cubit = PagedCubit<int>((int page) async => Paged<int>(
            items: <int>[page * 10, page * 10 + 1],
            page: page,
            hasMore: page < 3,
          ));

      await cubit.load();
      expect(cubit.state.items, <int>[10, 11]);
      expect(cubit.state.hasMore, isTrue);

      await cubit.loadMore();
      expect(cubit.state.items, <int>[10, 11, 20, 21]);
      expect(cubit.state.page, 2);

      await cubit.loadMore();
      expect(cubit.state.items.length, 6);
      expect(cubit.state.hasMore, isFalse);

      // لا مزيد: الاستدعاء بعدها لا يغيّر شيئاً
      await cubit.loadMore();
      expect(cubit.state.items.length, 6);
    });

    test('نجاح الصفحة التالية يمسح خطأ المحاولة السابقة', () async {
      int calls = 0;
      final PagedCubit<int> cubit = PagedCubit<int>((int page) async {
        calls += 1;
        if (page == 1) {
          return const Paged<int>(items: <int>[1], page: 1, hasMore: true);
        }
        if (calls == 2) {
          throw const ApiFailure(code: ApiCode.serverError, message: 'خطأ', status: 500);
        }

        return const Paged<int>(items: <int>[2], page: 2, hasMore: false);
      });

      await cubit.load();
      await cubit.loadMore();
      expect(cubit.state.failure, isNotNull);
      expect(cubit.state.items, <int>[1]);

      await cubit.loadMore();
      expect(cubit.state.failure, isNull);
      expect(cubit.state.items, <int>[1, 2]);
    });
  });

  group('نافذة إضافة الأنشطة', () {
    test('مغلقة: العدّاد حتى إعادة الفتح', () {
      final DateTime now = DateTime.parse('2026-09-18T16:16:00Z');
      final ActivityWindow window = ActivityWindow.fromJson(<String, dynamic>{
        'enabled': true,
        'open': false,
        'day': '2026-09-18',
        'opens_at': '2026-09-19T06:00:00Z',
        'closes_at': null,
        'seconds_left': 49440,
        'hours': 'من 6:00 ص إلى 2:00 م',
      });

      expect(window.changesAt, DateTime.parse('2026-09-19T06:00:00Z'));
      expect(formatCountdown(window.remaining(now)), '13:44:00');
    });

    test('مفتوحة: العدّاد حتى الإغلاق', () {
      final DateTime now = DateTime.parse('2026-09-18T07:30:15Z');
      final ActivityWindow window = ActivityWindow.fromJson(<String, dynamic>{
        'enabled': true,
        'open': true,
        'opens_at': '2026-09-18T06:00:00Z',
        'closes_at': '2026-09-18T14:00:00Z',
        'seconds_left': 23385,
        'hours': '',
      });

      expect(window.open, isTrue);
      expect(formatCountdown(window.remaining(now)), '06:29:45');
    });

    test('بلا تواريخ: يعتمد على ثواني الخادم، والوقت المنقضي يصير صفراً', () {
      final ActivityWindow window = ActivityWindow.fromJson(<String, dynamic>{
        'enabled': true,
        'open': false,
        'seconds_left': 3661,
      });

      expect(window.changesAt, isNull);
      expect(formatCountdown(window.remaining()), '01:01:01');

      final ActivityWindow past = ActivityWindow.fromJson(<String, dynamic>{
        'enabled': true,
        'open': true,
        'closes_at': '2020-01-01T00:00:00Z',
      });

      expect(past.remaining(), Duration.zero);
      expect(formatCountdown(past.remaining()), '00:00:00');
    });

    test('غياب الحقل يعني بلا نافذة', () {
      expect(ActivityWindow.read(null).enabled, isFalse);
      expect(StaffToday.fromJson(<String, dynamic>{'date': '2026-09-18'}).window.enabled, isFalse);
      expect(
        StaffToday.fromJson(<String, dynamic>{
          'date': '2026-09-18',
          'window': <String, dynamic>{'enabled': true, 'open': true, 'hours': 'س'},
        }).window.open,
        isTrue,
      );
    });
  });
}
