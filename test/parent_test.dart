import 'package:flutter_test/flutter_test.dart';
import 'package:nursery/app/app_config.dart';
import 'package:nursery/core/api/api_client.dart';
import 'package:nursery/core/api/parent_api.dart';
import 'package:nursery/core/models/paged.dart';
import 'package:nursery/core/models/parent_models.dart';
import 'package:nursery/core/models/staff_models.dart';
import 'package:nursery/features/common/paged_cubit.dart';

const AppConfig _config = AppConfig(
  flavor: AppFlavor.parent,
  baseUrl: 'https://nursery.test',
  apiKey: 'key',
  apiSecret: 'secret',
);

/// يعيد أغلفة جاهزة { data, meta } بلا شبكة.
class FakeEnvelopeClient extends ApiClient {
  FakeEnvelopeClient(this.envelopes)
      : super(config: _config, tokenProvider: _noToken, localeProvider: _arabic);

  final Map<String, Map<String, dynamic>> envelopes;

  static String? _noToken() => null;

  static String _arabic() => 'ar';

  @override
  Future<Map<String, dynamic>> sendEnvelope(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    String? idempotencyKey,
    bool common = false,
  }) async =>
      envelopes[path] ?? <String, dynamic>{'data': null, 'meta': <String, dynamic>{}};
}

void main() {
  test('قائمة الأبناء تُقرأ مع حالة اليوم', () async {
    final ParentApi api = ParentApi(FakeEnvelopeClient(<String, Map<String, dynamic>>{
      '/children': <String, dynamic>{
        'data': <dynamic>[
          <String, dynamic>{
            'id': 33,
            'name': 'سارة أحمد محمد',
            'first_name': 'سارة',
            'classroom': <String, dynamic>{'id': 10, 'title': 'KG1'},
            'branch': <String, dynamic>{'id': 1, 'title': 'فرع الشويخ'},
            'today': <String, dynamic>{
              'status': 'present',
              'checked_in_at': '2026-09-22T07:41:00+03:00',
            },
          },
        ],
        'meta': <String, dynamic>{},
      },
    }));

    final List<Child> children = await api.children();

    expect(children, hasLength(1));
    expect(children.first.firstName, 'سارة');
    expect(children.first.classroom, 'KG1');
    expect(children.first.today.status, 'present');
    expect(children.first.today.checkedInAt, isNotNull);
  });

  test('الترقيم يُقرأ من meta وتُضاف الصفحة التالية للقائمة', () async {
    Map<String, dynamic> page(int number, bool hasMore) => <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{'id': number, 'date': '2026-09-22', 'note': 'نشاط $number'},
          ],
          'meta': <String, dynamic>{
            'pagination': <String, dynamic>{'current_page': number, 'has_more': hasMore},
          },
        };

    final PagedCubit<Activity> cubit = PagedCubit<Activity>((int number) async => Paged.fromEnvelope<Activity>(
          page(number, number < 2),
          Activity.fromJson,
        ));

    await cubit.load();
    expect(cubit.state.items, hasLength(1));
    expect(cubit.state.hasMore, isTrue);

    await cubit.loadMore();
    expect(cubit.state.items, hasLength(2));
    expect(cubit.state.hasMore, isFalse);
    expect(cubit.state.page, 2);
  });

  test('لوحة اليوم للمشرفة تُقرأ من الأقسام الثلاثة', () {
    final StaffToday today = StaffToday.fromJson(<String, dynamic>{
      'date': '2026-09-22',
      'window': <String, dynamic>{'open': true, 'hours': 'من 6:00 ص إلى 2:00 م'},
      'attendance': <String, dynamic>{'expected': 24, 'in': 20, 'out': 3, 'absent': 2, 'remaining': 2},
      'activities': <String, dynamic>{'added': 15, 'published': 10, 'missing': 5},
    });

    expect(today.expected, 24);
    expect(today.checkedIn, 20);
    expect(today.activitiesMissing, 5);
    expect(today.window.open, isTrue);
    expect(today.window.hours, 'من 6:00 ص إلى 2:00 م');
  });

  test('الفاتورة تُقرأ ببنودها', () {
    final Invoice invoice = Invoice.fromJson(<String, dynamic>{
      'id': 512,
      'number': '512',
      'status': 'pending',
      'status_label': 'بانتظار الدفع',
      'due_date': '2026-09-06',
      'is_overdue': false,
      'student': <String, dynamic>{'id': 33, 'name': 'سارة أحمد'},
      'currency': 'KWD',
      'total': '120.000',
      'can_pay': true,
      'items': <dynamic>[
        <String, dynamic>{'title': 'اشتراك سبتمبر', 'total': '120.000'},
      ],
    });

    expect(invoice.studentName, 'سارة أحمد');
    expect(invoice.canPay, isTrue);
    expect(invoice.items.single.total, '120.000');
  });
}
