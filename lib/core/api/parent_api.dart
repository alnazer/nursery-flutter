import '../models/card_design.dart';
import '../models/paged.dart';
import '../models/parent_models.dart';
import 'api_client.dart';

/// مسارات تطبيق ولي الأمر بعد الدخول.
class ParentApi {
  ParentApi(this._client);

  final ApiClient _client;

  Future<List<Child>> children() async {
    final dynamic data = await _client.get('/children');

    return data is List
        ? data
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> item) => Child.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <Child>[];
  }

  Future<Map<String, dynamic>> child(int id) async {
    final dynamic data = await _client.get('/children/$id');

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<Paged<Activity>> activities({int page = 1, int? studentId, bool unviewed = false}) async {
    final Map<String, String> query = <String, String>{'page': '$page'};
    if (studentId != null) {
      query['student'] = '$studentId';
    }
    if (unviewed) {
      query['unviewed'] = '1';
    }

    return Paged.fromEnvelope<Activity>(
      await _client.getEnvelope('/activities', query: query),
      Activity.fromJson,
    );
  }

  Future<Activity> activity(int id) async {
    final dynamic data = await _client.get('/activities/$id');

    return Activity.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  Future<Paged<NotificationItem>> notifications({int page = 1, bool unread = false}) async =>
      Paged.fromEnvelope<NotificationItem>(
        await _client.getEnvelope('/notifications', query: <String, String>{
          'page': '$page',
          if (unread) 'unread': '1',
        }),
        NotificationItem.fromJson,
      );

  Future<void> markNotificationRead(String id) => _client.post('/notifications/$id/read');

  Future<void> markAllNotificationsRead() => _client.post('/notifications/read-all');

  Future<Paged<Invoice>> invoices({
    int page = 1,
    String? status,
    bool payable = false,
    int? studentId,
  }) async =>
      Paged.fromEnvelope<Invoice>(
        await _client.getEnvelope('/invoices', query: <String, String>{
          'page': '$page',
          if (status != null && status.isNotEmpty) 'status': status,
          if (payable) 'payable': '1',
          if (studentId != null) 'student': '$studentId',
        }),
        Invoice.fromJson,
      );

  Future<Invoice> invoice(int id) async {
    final dynamic data = await _client.get('/invoices/$id');

    return Invoice.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  Future<Paged<Announcement>> announcements({int page = 1, String? filter}) async =>
      Paged.fromEnvelope<Announcement>(
        await _client.getEnvelope('/announcements', query: <String, String>{
          'page': '$page',
          if (filter != null && filter.isNotEmpty) 'filter': filter,
        }),
        Announcement.fromJson,
      );

  Future<Announcement> announcement(int id) async {
    final dynamic data = await _client.get('/announcements/$id');

    return Announcement.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  Future<void> acknowledge(int id) => _client.post('/announcements/$id/acknowledge');

  Future<AttendanceMonth> attendance(int studentId, {String? month}) async {
    final dynamic data = await _client.get(
      '/children/$studentId/attendance',
      query: month == null ? null : <String, String>{'month': month},
    );

    return AttendanceMonth.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  Future<Paged<ChildNote>> notes(int studentId, {int page = 1}) async => Paged.fromEnvelope<ChildNote>(
        await _client.getEnvelope('/children/$studentId/notes', query: <String, String>{'page': '$page'}),
        ChildNote.fromJson,
      );

  Future<Paged<AbsenceItem>> absences({int page = 1, bool upcoming = false, int? studentId}) async {
    final Map<String, String> query = <String, String>{'page': '$page'};
    if (upcoming) {
      query['upcoming'] = '1';
    }
    if (studentId != null) {
      query['student'] = '$studentId';
    }

    return Paged.fromEnvelope<AbsenceItem>(
      await _client.getEnvelope('/absences', query: query),
      AbsenceItem.fromJson,
    );
  }

  /// بلاغ غياب لمدى من الأيام — مع مفتاح تكرار حتى لا يتكرر البلاغ مع إعادة الإرسال.
  Future<Map<String, dynamic>> reportAbsence({
    required int studentId,
    required String from,
    required String to,
    required String note,
  }) async {
    final dynamic data = await _client.post(
      '/absences',
      body: <String, dynamic>{'student_id': studentId, 'from': from, 'to': to, 'note': note},
      idempotencyKey: 'absence-$studentId-$from-$to-${DateTime.now().millisecondsSinceEpoch}',
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<void> cancelAbsence(int id) => _client.delete('/absences/$id');

  Future<List<DeviceItem>> devices() async {
    final dynamic data = await _client.get('/devices');

    return data is List
        ? data
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> item) => DeviceItem.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <DeviceItem>[];
  }

  Future<void> signOutDevice(int id) => _client.delete('/devices/$id');

  Future<Paged<EventItem>> events({int page = 1, bool forMe = false, String? category}) async =>
      Paged.fromEnvelope<EventItem>(
        await _client.getEnvelope('/events', query: <String, String>{
          'page': '$page',
          if (forMe) 'for_me': '1',
          if (category != null && category.isNotEmpty) 'category': category,
        }),
        EventItem.fromJson,
      );

  Future<Map<String, dynamic>> event(int id) async {
    final dynamic data = await _client.get('/events/$id');

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<Paged<EventBooking>> bookings({int page = 1, String? status}) async =>
      Paged.fromEnvelope<EventBooking>(
        await _client.getEnvelope('/event-bookings', query: <String, String>{
          'page': '$page',
          if (status != null && status.isNotEmpty) 'status': status,
        }),
        EventBooking.fromJson,
      );

  /// قبول حجز من قائمة الانتظار.
  Future<Map<String, dynamic>> acceptBooking(String reference) async {
    final dynamic data = await _client.post('/event-bookings/$reference/accept');

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// تجديد مهلة الدفع لحجز انتهت مهلته.
  Future<Map<String, dynamic>> renewBooking(String reference) async {
    final dynamic data = await _client.post('/event-bookings/$reference/renew');

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// فاتورة الحجز.
  Future<Map<String, dynamic>> bookingInvoice(String reference) async {
    final dynamic data = await _client.get('/event-bookings/$reference/invoice');

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// استبيان تقييم الفعالية (الأسئلة وإجابتي إن وُجدت).
  Future<Map<String, dynamic>> eventSurvey(int eventId) async {
    final dynamic data = await _client.get('/events/$eventId/survey');

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// إرسال تقييم الفعالية.
  Future<Map<String, dynamic>> submitEventSurvey(int eventId, Map<String, dynamic> answers) async {
    final dynamic data = await _client.post('/events/$eventId/survey', body: answers);

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<void> cancelBooking(String reference) => _client.post('/event-bookings/$reference/cancel');

  /// معاينة الحجز: يتحقق من النموذج ويحسب المبلغ بلا حجز مقعد.
  Future<Map<String, dynamic>> previewBooking(int eventId, Map<String, dynamic> payload) async {
    final dynamic data = await _client.post('/events/$eventId/bookings/preview', body: payload);

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// تأكيد الحجز — يحجز المقاعد مؤقتاً حتى الدفع.
  Future<Map<String, dynamic>> createBooking(int eventId, Map<String, dynamic> payload) async {
    final dynamic data = await _client.post(
      '/events/$eventId/bookings',
      body: payload,
      idempotencyKey: 'booking-$eventId-${DateTime.now().millisecondsSinceEpoch}',
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// بدء دفع حجز فعالية.
  Future<PaymentStart> payBooking(String reference) async {
    final dynamic data = await _client.post(
      '/event-bookings/$reference/pay',
      idempotencyKey: 'booking-pay-$reference-${DateTime.now().millisecondsSinceEpoch}',
    );

    return PaymentStart.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  /// بدء دفع فاتورة واحدة — يعيد رابط بوابة الدفع ومرجع العملية.
  Future<PaymentStart> payInvoice(int invoiceId, {String? coupon}) async {
    final dynamic data = await _client.post(
      '/invoices/$invoiceId/pay',
      body: coupon == null ? null : <String, dynamic>{'coupon': coupon},
      idempotencyKey: 'pay-$invoiceId-${DateTime.now().millisecondsSinceEpoch}',
    );

    return PaymentStart.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  /// طرق الدفع الإلكترونية المتاحة.
  Future<List<PaymentMethodItem>> paymentMethods() async {
    final dynamic data = await _client.get('/payments/methods');

    return data is List
        ? data
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> item) => PaymentMethodItem.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <PaymentMethodItem>[];
  }

  /// معاينة الدفع: المبالغ بعد الكوبونات واقتراحات القسائم، بلا حجز.
  /// [all] يجلب كل المستحق، وإلا تُرسل الأرقام المحددة.
  Future<PaymentQuote> paymentQuote({
    List<String>? numbers,
    bool all = false,
    Map<String, String> coupons = const <String, String>{},
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      if (all) 'all': true,
      if (!all && numbers != null) 'invoice_numbers': numbers,
      if (coupons.isNotEmpty) 'coupons': coupons,
    };
    final dynamic data = await _client.post('/payments/quote', body: body);

    return PaymentQuote.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  /// بدء دفع عدة فواتير في عملية واحدة.
  Future<PaymentStart> payInvoices({
    required List<String> numbers,
    Map<String, String> coupons = const <String, String>{},
    int? methodId,
  }) async {
    final dynamic data = await _client.post(
      '/payments',
      body: <String, dynamic>{
        'invoice_numbers': numbers,
        if (coupons.isNotEmpty) 'coupons': coupons,
        if (methodId != null) 'payment_method_id': methodId,
      },
      idempotencyKey: 'pay-${numbers.join('-')}-${DateTime.now().millisecondsSinceEpoch}',
    );

    return PaymentStart.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  /// حالة آخر طلب إيقاف اشتراك لهذا الطفل (null إن لم يوجد).
  Future<Map<String, dynamic>?> cancellationRequest(int studentId) async {
    final dynamic data = await _client.get('/children/$studentId/cancellation-request');

    return data is Map<String, dynamic> ? data : null;
  }

  /// التحقق من كوبون على فاتورة قبل الدفع. الرفض يعود بـ valid=false لا بخطأ.
  Future<CouponCheck> validateCoupon({required String code, required int invoiceId}) async {
    final dynamic data = await _client.post(
      '/coupons/validate',
      body: <String, dynamic>{'code': code, 'invoice_id': invoiceId},
    );

    return CouponCheck.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  /// رابط مؤقّت لتقرير النشاط اليومي (PDF).
  Future<String> activityPdf(int activityId) async {
    final dynamic data = await _client.get('/activities/$activityId/pdf');

    return data is Map<String, dynamic> ? '${data['url'] ?? ''}' : '';
  }

  /// إيقاف إشعارات هذا الجهاز (يمسح رمز الدفع من الخادم).
  Future<void> disablePush() => _client.delete('/devices/current/push');

  /// رابط مؤقّت لنسخة الفاتورة (للمدفوعة فقط).
  Future<String> invoicePdf(int invoiceId) async {
    final dynamic data = await _client.get('/invoices/$invoiceId/pdf');

    return data is Map<String, dynamic> ? '${data['url'] ?? ''}' : '';
  }

  Future<Paged<PaymentItem>> payments({int page = 1, String? status}) async => Paged.fromEnvelope<PaymentItem>(
        await _client.getEnvelope('/payments', query: <String, String>{
          'page': '$page',
          if (status != null && status.isNotEmpty) 'status': status,
        }),
        PaymentItem.fromJson,
      );

  /// حالة عملية الدفع بعد العودة من البوابة.
  Future<PaymentItem> payment(String reference) async {
    final dynamic data = await _client.get('/payments/$reference');

    return PaymentItem.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  Future<void> cancelPayment(String reference) => _client.post('/payments/$reference/cancel');

  Future<Map<String, dynamic>> documents(int studentId) async {
    final dynamic data = await _client.get('/children/$studentId/documents');

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// بطاقة الطفل: التصميم والقيم ورمز QR.
  Future<StudentCard> card(int studentId) async {
    final dynamic data = await _client.get('/children/$studentId/card');

    return StudentCard.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  Future<Map<String, dynamic>> weeklySummary(int studentId) async {
    final dynamic data = await _client.get('/children/$studentId/weekly-summary');

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// موافقة نشر صور الطفل.
  Future<bool> setMediaConsent(int studentId, bool value) async {
    final dynamic data = await _client.post(
      '/children/$studentId/media-consent',
      body: <String, dynamic>{'media_consent': value},
    );

    return data is Map<String, dynamic> ? data['media_consent'] == true : value;
  }

  Future<List<Coupon>> coupons() async {
    final dynamic data = await _client.get('/coupons');

    return data is List
        ? data
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> item) => Coupon.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <Coupon>[];
  }

  Future<Paged<Subscription>> subscriptions({
    int page = 1,
    String? status,
    bool current = false,
    int? studentId,
  }) async =>
      Paged.fromEnvelope<Subscription>(
        await _client.getEnvelope('/subscriptions', query: <String, String>{
          'page': '$page',
          if (status != null && status.isNotEmpty) 'status': status,
          if (current) 'current': '1',
          if (studentId != null) 'student': '$studentId',
        }),
        Subscription.fromJson,
      );

  Future<Map<String, dynamic>> me() async {
    final dynamic data = await _client.get('/me');

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// تعديل الاسم أو البريد (تغيير البريد في وضع كلمة المرور يطلب كلمة المرور الحالية).
  Future<Map<String, dynamic>> updateMe({
    String? name,
    String? email,
    String? currentPassword,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (name != null) {
      body['name'] = name;
    }
    if (email != null) {
      body['email'] = email;
    }
    if (currentPassword != null && currentPassword.isNotEmpty) {
      body['current_password'] = currentPassword;
    }
    final dynamic data = await _client.patch('/me', body: body);

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// تغيير صورتي الشخصية — يعيد رابط الصورة الجديد.
  Future<String> updateAvatar(UploadFile file) async {
    final dynamic data = await _client.upload('/me/avatar', files: <UploadFile>[file]);

    return data is Map && data['avatar_url'] != null ? '${data['avatar_url']}' : '';
  }

  /// تغيير صورة الطفل — يعيد رابط الصورة الجديد.
  Future<String> updateChildPhoto(int studentId, UploadFile file) async {
    final dynamic data = await _client.upload('/children/$studentId/photo', files: <UploadFile>[file]);

    return data is Map && data['avatar_url'] != null ? '${data['avatar_url']}' : '';
  }

  /// طلب إيقاف اشتراك طفل.
  Future<Map<String, dynamic>> requestCancellation(int studentId, String reason) async {
    final dynamic data = await _client.post(
      '/children/$studentId/cancellation-request',
      body: <String, dynamic>{'reason': reason},
      idempotencyKey: 'stop-$studentId-${DateTime.now().millisecondsSinceEpoch}',
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }
}
