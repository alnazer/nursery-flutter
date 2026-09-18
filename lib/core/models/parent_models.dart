/// حالة الطفل اليوم كما يعيدها الخادم.
class TodayStatus {
  const TodayStatus({
    required this.status,
    this.checkedInAt,
    this.checkedOutAt,
    this.absenceLabel,
    this.absenceId,
    this.absenceType = '',
  });

  /// present | checked_out | absent | closed | not_arrived
  final String status;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final String? absenceLabel;

  /// رقم الغياب المسجّل اليوم — يلزم للتراجع عنه.
  final int? absenceId;

  /// excused أو unexcused.
  final String absenceType;

  static const TodayStatus unknown = TodayStatus(status: 'not_arrived');

  factory TodayStatus.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? absence =
        json['absence'] is Map ? Map<String, dynamic>.from(json['absence'] as Map) : null;

    return TodayStatus(
      status: (json['status'] as String?) ?? 'not_arrived',
      checkedInAt: DateTime.tryParse((json['checked_in_at'] as String?) ?? ''),
      checkedOutAt: DateTime.tryParse((json['checked_out_at'] as String?) ?? ''),
      absenceLabel: absence == null ? null : absence['type_label'] as String?,
      absenceId: absence == null ? null : absence['id'] as int?,
      absenceType: absence == null ? '' : '${absence['type'] ?? ''}',
    );
  }
}

class Child {
  const Child({
    required this.id,
    required this.name,
    required this.firstName,
    required this.avatarUrl,
    required this.classroom,
    required this.branch,
    required this.today,
  });

  final int id;
  final String name;
  final String firstName;
  final String? avatarUrl;
  final String classroom;
  final String branch;
  final TodayStatus today;

  factory Child.fromJson(Map<String, dynamic> json) => Child(
        id: (json['id'] as int?) ?? 0,
        name: (json['name'] as String?) ?? '',
        firstName: (json['first_name'] as String?) ?? (json['name'] as String?) ?? '',
        avatarUrl: json['avatar_url'] as String?,
        classroom: _title(json['classroom']),
        branch: _title(json['branch']),
        today: json['today'] is Map
            ? TodayStatus.fromJson(Map<String, dynamic>.from(json['today'] as Map))
            : TodayStatus.unknown,
      );
}

/// مرفق نشاط (صورة أو PDF) برابط موقّع مؤقّت.
class ActivityFile {
  const ActivityFile({
    required this.id,
    required this.name,
    required this.mime,
    required this.size,
    required this.sizeLabel,
    required this.isImage,
    required this.url,
  });

  final int id;
  final String name;
  final String mime;
  final int size;
  final String sizeLabel;
  final bool isImage;

  /// رابط مؤقّت يُفتح بلا ترويسات (صالح ساعة).
  final String url;

  bool get isPdf => mime == 'application/pdf';

  factory ActivityFile.fromJson(Map<String, dynamic> json) => ActivityFile(
        id: (json['id'] as int?) ?? 0,
        name: (json['name'] as String?) ?? '',
        mime: (json['mime'] as String?) ?? '',
        size: (json['size'] as num?)?.toInt() ?? 0,
        sizeLabel: (json['size_label'] as String?) ?? '',
        isImage: json['is_image'] == true,
        url: '${json['url'] ?? ''}',
      );

  /// يقرأ مصفوفة `files` من أي رد.
  static List<ActivityFile> listFrom(dynamic value) => value is List
      ? value
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => ActivityFile.fromJson(Map<String, dynamic>.from(item)))
          .toList()
      : <ActivityFile>[];
}

class Activity {
  const Activity({
    required this.id,
    required this.date,
    required this.studentName,
    required this.studentId,
    this.studentAvatar,
    required this.note,
    required this.viewed,
    required this.publishedAt,
    this.pdfUrl,
    this.options = const <ActivityOption>[],
    this.files = const <ActivityFile>[],
  });

  final int id;
  final String date;
  final String studentName;
  final int studentId;
  final String? studentAvatar;
  final String note;
  final bool viewed;
  final DateTime? publishedAt;
  final String? pdfUrl;
  final List<ActivityOption> options;

  /// المرفقات (صور أو PDF) — فارغة إن لم يُرفق شيء.
  final List<ActivityFile> files;

  factory Activity.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> student =
        json['student'] is Map ? Map<String, dynamic>.from(json['student'] as Map) : <String, dynamic>{};
    final List<dynamic> options = json['options'] is List ? json['options'] as List<dynamic> : <dynamic>[];

    return Activity(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      studentName: (student['name'] as String?) ?? '',
      studentId: (student['id'] as int?) ?? 0,
      studentAvatar: student['avatar_url'] as String?,
      note: (json['note'] as String?) ?? '',
      viewed: json['viewed'] == true,
      publishedAt: DateTime.tryParse((json['published_at'] as String?) ?? ''),
      pdfUrl: json['pdf_url'] as String?,
      options: options
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => ActivityOption.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      files: ActivityFile.listFrom(json['files']),
    );
  }
}

/// بند في النشاط: أيقونات، أو نجوم، أو نص.
class ActivityOption {
  const ActivityOption({required this.title, required this.type, this.images = const <String>[], this.stars, this.maxStars, this.text});

  final String title;
  final String type;
  final List<String> images;
  final int? stars;
  final int? maxStars;
  final String? text;

  factory ActivityOption.fromJson(Map<String, dynamic> json) => ActivityOption(
        title: (json['title'] as String?) ?? '',
        type: (json['type'] as String?) ?? 'text',
        images: json['images'] is List
            ? (json['images'] as List<dynamic>).map((dynamic item) => '$item').toList()
            : const <String>[],
        stars: json['stars'] as int?,
        maxStars: json['max_stars'] as int?,
        text: json['text'] as String?,
      );
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime? createdAt;
  final bool read;

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: '${json['id'] ?? ''}',
        type: (json['type'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        body: (json['body'] as String?) ?? '',
        createdAt: DateTime.tryParse((json['created_at'] as String?) ?? ''),
        read: json['read_at'] != null,
      );
}

class Invoice {
  const Invoice({
    required this.id,
    required this.number,
    required this.status,
    required this.statusLabel,
    required this.dueDate,
    required this.isOverdue,
    required this.studentName,
    required this.total,
    required this.currency,
    required this.canPay,
    this.items = const <InvoiceItem>[],
  });

  final int id;
  final String number;
  final String status;
  final String statusLabel;
  final String dueDate;
  final bool isOverdue;
  final String studentName;
  final String total;
  final String currency;
  final bool canPay;
  final List<InvoiceItem> items;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> student =
        json['student'] is Map ? Map<String, dynamic>.from(json['student'] as Map) : <String, dynamic>{};
    final List<dynamic> items = json['items'] is List ? json['items'] as List<dynamic> : <dynamic>[];

    return Invoice(
      id: (json['id'] as int?) ?? 0,
      number: '${json['number'] ?? ''}',
      status: (json['status'] as String?) ?? '',
      statusLabel: (json['status_label'] as String?) ?? '',
      dueDate: (json['due_date'] as String?) ?? '',
      isOverdue: json['is_overdue'] == true,
      studentName: (student['name'] as String?) ?? '',
      total: '${json['total'] ?? ''}',
      currency: (json['currency'] as String?) ?? '',
      canPay: json['can_pay'] == true,
      items: items
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => InvoiceItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class InvoiceItem {
  const InvoiceItem({required this.title, required this.total});

  final String title;
  final String total;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        title: (json['title'] as String?) ?? '',
        total: '${json['total'] ?? ''}',
      );
}

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.requireAck,
    required this.acknowledged,
    required this.read,
    required this.sentAt,
    this.bodyHtml = '',
    this.attachments = const <Attachment>[],
  });

  final int id;
  final String title;
  final bool requireAck;
  final bool acknowledged;
  final bool read;
  final DateTime? sentAt;
  final String bodyHtml;
  final List<Attachment> attachments;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    final List<dynamic> files =
        json['attachments'] is List ? json['attachments'] as List<dynamic> : <dynamic>[];

    return Announcement(
      id: (json['id'] as int?) ?? 0,
      title: (json['title'] as String?) ?? '',
      requireAck: json['require_ack'] == true,
      acknowledged: json['acknowledged_at'] != null,
      read: json['read_at'] != null,
      sentAt: DateTime.tryParse((json['sent_at'] as String?) ?? ''),
      bodyHtml: (json['body_html'] as String?) ?? '',
      attachments: files
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => Attachment.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

/// مرفق تعميم: اسمه ورابطه الموقّع وحجمه.
class Attachment {
  const Attachment({
    required this.id,
    required this.name,
    required this.url,
    required this.mime,
    required this.size,
    required this.isImage,
  });

  final int id;
  final String name;
  final String url;
  final String mime;

  /// الحجم بالبايت كما يرسله الخادم (0 إن لم يُرسل).
  final int size;
  final bool isImage;

  /// «182 KB» — فارغ إن لم يصل الحجم.
  String get sizeLabel {
    if (size <= 0) {
      return '';
    }
    if (size < 1024) {
      return '$size B';
    }
    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(0)} KB';
    }

    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        id: (json['id'] as int?) ?? 0,
        name: (json['name'] as String?) ?? '',
        url: '${json['url'] ?? ''}',
        mime: (json['mime'] as String?) ?? '',
        size: (json['size'] as num?)?.toInt() ?? 0,
        isImage: json['is_image'] == true,
      );
}

String _title(dynamic value) {
  if (value is Map) {
    return '${value['title'] ?? ''}';
  }

  return '';
}


/// ملاحظة معلّمة عن الطفل.
class ChildNote {
  const ChildNote({required this.id, required this.type, required this.note, required this.by, required this.createdAt});

  final int id;
  final String type;
  final String note;
  final String by;
  final DateTime? createdAt;

  factory ChildNote.fromJson(Map<String, dynamic> json) => ChildNote(
        id: (json['id'] as int?) ?? 0,
        type: (json['type'] as String?) ?? '',
        note: (json['note'] as String?) ?? '',
        by: (json['by'] as String?) ?? '',
        createdAt: DateTime.tryParse((json['created_at'] as String?) ?? ''),
      );
}

/// بلاغ غياب.
class AbsenceItem {
  const AbsenceItem({
    required this.id,
    required this.studentId,
    required this.date,
    required this.typeLabel,
    required this.note,
    required this.cancellable,
  });

  final int id;
  final int studentId;
  final String date;
  final String typeLabel;
  final String note;
  final bool cancellable;

  factory AbsenceItem.fromJson(Map<String, dynamic> json) => AbsenceItem(
        id: (json['id'] as int?) ?? 0,
        studentId: (json['student_id'] as int?) ?? 0,
        date: (json['date'] as String?) ?? '',
        typeLabel: (json['type_label'] as String?) ?? '',
        note: (json['note'] as String?) ?? '',
        cancellable: json['cancellable'] == true,
      );
}

/// جهاز متصل بالحساب.
class DeviceItem {
  const DeviceItem({
    required this.id,
    required this.name,
    required this.platform,
    required this.appVersion,
    required this.lastUsedAt,
    required this.current,
    required this.biometricEnabled,
  });

  final int id;
  final String name;
  final String platform;
  final String appVersion;
  final DateTime? lastUsedAt;
  final bool current;
  final bool biometricEnabled;

  factory DeviceItem.fromJson(Map<String, dynamic> json) => DeviceItem(
        id: (json['id'] as int?) ?? 0,
        name: (json['device_name'] as String?) ?? '',
        platform: (json['platform'] as String?) ?? '',
        appVersion: (json['app_version'] as String?) ?? '',
        lastUsedAt: DateTime.tryParse((json['last_used_at'] as String?) ?? ''),
        current: json['current'] == true,
        biometricEnabled: json['biometric_enabled'] == true,
      );
}

/// حضور شهر كامل مع الملخّص.
class AttendanceMonth {
  const AttendanceMonth({
    required this.month,
    required this.days,
    required this.schoolDays,
    required this.absent,
    required this.excused,
    required this.unexcused,
    required this.rate,
  });

  final String month;
  final List<AttendanceDay> days;
  final int schoolDays;
  final int absent;
  final int excused;
  final int unexcused;
  final double rate;

  static const AttendanceMonth empty = AttendanceMonth(
    month: '',
    days: <AttendanceDay>[],
    schoolDays: 0,
    absent: 0,
    excused: 0,
    unexcused: 0,
    rate: 0,
  );

  factory AttendanceMonth.fromJson(Map<String, dynamic> json) {
    final List<dynamic> days = json['days'] is List ? json['days'] as List<dynamic> : <dynamic>[];
    final Map<String, dynamic> summary =
        json['summary'] is Map ? Map<String, dynamic>.from(json['summary'] as Map) : <String, dynamic>{};
    final dynamic rate = summary['rate'];

    return AttendanceMonth(
      month: (json['month'] as String?) ?? '',
      days: days
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> day) => AttendanceDay.fromJson(Map<String, dynamic>.from(day)))
          .toList(),
      schoolDays: (summary['school_days'] as int?) ?? 0,
      absent: (summary['absent'] as int?) ?? 0,
      excused: (summary['excused'] as int?) ?? 0,
      unexcused: (summary['unexcused'] as int?) ?? 0,
      rate: rate is num ? rate.toDouble() : 0,
    );
  }
}

class AttendanceDay {
  const AttendanceDay({required this.date, required this.status, this.checkedInAt, this.checkedOutAt});

  final String date;
  final String status;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;

  factory AttendanceDay.fromJson(Map<String, dynamic> json) => AttendanceDay(
        date: (json['date'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        checkedInAt: DateTime.tryParse((json['checked_in_at'] as String?) ?? ''),
        checkedOutAt: DateTime.tryParse((json['checked_out_at'] as String?) ?? ''),
      );
}


/// فعالية معروضة لولي الأمر.
class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.startsAt,
    required this.location,
    required this.phaseLabel,
    required this.canRegister,
    required this.priceFrom,
    required this.currency,
    required this.remainingSeats,
  });

  final int id;
  final String title;
  final String summary;
  final String? imageUrl;
  final DateTime? startsAt;
  final String location;
  final String phaseLabel;
  final bool canRegister;
  final String priceFrom;
  final String currency;
  final int? remainingSeats;

  factory EventItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> phase =
        json['phase'] is Map ? Map<String, dynamic>.from(json['phase'] as Map) : <String, dynamic>{};

    return EventItem(
      id: (json['id'] as int?) ?? 0,
      title: (json['title'] as String?) ?? '',
      summary: (json['summary'] as String?) ?? '',
      imageUrl: json['image_url'] as String?,
      startsAt: DateTime.tryParse((json['starts_at'] as String?) ?? ''),
      location: (json['location'] as String?) ?? '',
      phaseLabel: (phase['label'] as String?) ?? '',
      canRegister: json['can_register'] == true,
      priceFrom: '${json['price_from'] ?? ''}',
      currency: (json['currency'] as String?) ?? '',
      remainingSeats: json['remaining_seats'] as int?,
    );
  }
}

/// حجز فعالية.
class EventBooking {
  const EventBooking({
    required this.reference,
    required this.code,
    required this.statusLabel,
    required this.status,
    required this.eventTitle,
    required this.startsAt,
    required this.participants,
    required this.total,
    required this.currency,
    required this.canPay,
    required this.canCancel,
    this.canAccept = false,
    this.canRenew = false,
    this.eventId = 0,
  });

  final String reference;
  final String code;
  final String statusLabel;
  final String status;
  final String eventTitle;
  final DateTime? startsAt;
  final int participants;
  final String total;
  final String currency;
  final bool canPay;
  final bool canCancel;

  /// حجز بانتظار قبول ولي الأمر (بعد فتح مقعد من قائمة الانتظار).
  final bool canAccept;

  /// تمديد مهلة الحجز المؤقّت.
  final bool canRenew;

  /// رقم الفعالية — يلزم لفتح استبيانها.
  final int eventId;

  factory EventBooking.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> event =
        json['event'] is Map ? Map<String, dynamic>.from(json['event'] as Map) : <String, dynamic>{};

    return EventBooking(
      reference: '${json['reference'] ?? ''}',
      code: '${json['code'] ?? ''}',
      statusLabel: (json['status_label'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      eventTitle: (event['title'] as String?) ?? '',
      startsAt: DateTime.tryParse((event['starts_at'] as String?) ?? ''),
      participants: (json['participants_count'] as int?) ?? 0,
      total: '${json['total'] ?? ''}',
      currency: (json['currency'] as String?) ?? '',
      canPay: json['can_pay'] == true,
      canCancel: json['can_cancel'] == true,
      canAccept: json['can_accept'] == true,
      canRenew: json['can_renew'] == true,
      eventId: (event['id'] as int?) ?? 0,
    );
  }
}


/// عملية دفع.
class PaymentItem {
  const PaymentItem({
    required this.reference,
    required this.status,
    required this.statusLabel,
    required this.amount,
    required this.currency,
    required this.invoicesCount,
    required this.createdAt,
    required this.isFinal,
    required this.canCancel,
    this.receiptUrl,
    this.message,
  });

  final String reference;
  final String status;
  final String statusLabel;
  final String amount;
  final String currency;
  final int invoicesCount;
  final DateTime? createdAt;
  final bool isFinal;
  final bool canCancel;
  final String? receiptUrl;
  final String? message;

  bool get isPaid => status == 'paid';

  factory PaymentItem.fromJson(Map<String, dynamic> json) => PaymentItem(
        reference: '${json['reference'] ?? ''}',
        status: (json['status'] as String?) ?? '',
        statusLabel: (json['status_label'] as String?) ?? '',
        amount: '${json['amount'] ?? ''}',
        currency: (json['currency'] as String?) ?? '',
        invoicesCount: (json['invoices_count'] as int?) ?? 0,
        createdAt: DateTime.tryParse((json['created_at'] as String?) ?? ''),
        isFinal: json['is_final'] == true,
        canCancel: json['can_cancel'] == true,
        receiptUrl: json['receipt_url'] as String?,
        message: json['message'] as String?,
      );
}

/// بدء عملية دفع: الرابط والمرجع.
class PaymentStart {
  const PaymentStart({required this.reference, required this.paymentUrl, required this.amount});

  final String reference;
  final String paymentUrl;
  final String amount;

  factory PaymentStart.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payment =
        json['payment'] is Map ? Map<String, dynamic>.from(json['payment'] as Map) : <String, dynamic>{};

    return PaymentStart(
      reference: '${payment['reference'] ?? ''}',
      paymentUrl: '${json['payment_url'] ?? ''}',
      amount: '${payment['amount'] ?? ''}',
    );
  }
}


/// قسيمة خصم متاحة لولي الأمر.
class Coupon {
  const Coupon({
    required this.code,
    required this.name,
    required this.value,
    required this.type,
    required this.endsAt,
    required this.children,
    required this.conditions,
    this.description = '',
    this.invoiceNumbers = const <String>[],
  });

  final String code;
  final String name;
  final String value;
  final String type;
  final DateTime? endsAt;
  final List<String> children;
  final List<String> conditions;
  final String description;

  /// أرقام الفواتير المستحقة التي تقبل هذه القسيمة — الدفع المباشر منها.
  final List<String> invoiceNumbers;

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        code: '${json['code'] ?? ''}',
        name: (json['name'] as String?) ?? '',
        value: '${json['value'] ?? ''}',
        type: (json['type'] as String?) ?? '',
        endsAt: DateTime.tryParse((json['ends_at'] as String?) ?? ''),
        description: (json['description'] as String?) ?? '',
        children: json['children'] is List
            ? (json['children'] as List<dynamic>).map((dynamic item) => '$item').toList()
            : const <String>[],
        conditions: json['conditions'] is List
            ? (json['conditions'] as List<dynamic>).map((dynamic item) => '$item').toList()
            : const <String>[],
        invoiceNumbers: json['payable_invoice_numbers'] is List
            ? (json['payable_invoice_numbers'] as List<dynamic>).map((dynamic item) => '$item').toList()
            : const <String>[],
      );
}

/// اشتراك شهري لطفل.
class Subscription {
  const Subscription({
    required this.id,
    required this.title,
    required this.statusLabel,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.isCurrent,
    required this.daysLeft,
    required this.studentName,
    required this.studentId,
    required this.amount,
    required this.currency,
    this.discount = '',
    this.products = const <String>[],
    this.invoiceId = 0,
    this.invoiceNumber = '',
    this.invoiceStatus = '',
    this.invoiceCanPay = false,
    this.invoiceTotal = '',
  });

  final int id;
  final String title;
  final String statusLabel;
  final String status;
  final String startsAt;
  final String endsAt;
  final bool isCurrent;
  final int daysLeft;
  final String studentName;
  final int studentId;
  final String amount;
  final String currency;
  final String discount;

  /// عناوين المنتجات الإضافية (الباص، الوجبة…).
  final List<String> products;

  /// فاتورة الاشتراك إن صدرت.
  final int invoiceId;
  final String invoiceNumber;
  final String invoiceStatus;
  final bool invoiceCanPay;
  final String invoiceTotal;

  bool get hasInvoice => invoiceId > 0;

  bool get isPaid => status == 'paid';

  factory Subscription.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> student =
        json['student'] is Map ? Map<String, dynamic>.from(json['student'] as Map) : <String, dynamic>{};
    final Map<String, dynamic> invoice =
        json['invoice'] is Map ? Map<String, dynamic>.from(json['invoice'] as Map) : <String, dynamic>{};
    final List<dynamic> products = json['products'] is List ? json['products'] as List<dynamic> : <dynamic>[];

    return Subscription(
      id: (json['id'] as int?) ?? 0,
      title: (json['title'] as String?) ?? '',
      statusLabel: (json['status_label'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      startsAt: (json['starts_at'] as String?) ?? '',
      endsAt: (json['ends_at'] as String?) ?? '',
      isCurrent: json['is_current'] == true,
      daysLeft: (json['days_left'] as int?) ?? 0,
      studentName: (student['name'] as String?) ?? '',
      studentId: (student['id'] as int?) ?? 0,
      amount: '${json['amount'] ?? ''}',
      currency: (json['currency'] as String?) ?? '',
      discount: '${json['discount'] ?? ''}',
      products: products
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => '${item['title'] ?? ''}')
          .where((String title) => title.isNotEmpty)
          .toList(),
      invoiceId: (invoice['id'] as int?) ?? 0,
      invoiceNumber: '${invoice['number'] ?? ''}',
      invoiceStatus: '${invoice['status'] ?? ''}',
      invoiceCanPay: invoice['can_pay'] == true,
      invoiceTotal: '${invoice['total'] ?? ''}',
    );
  }
}

/// طريقة دفع إلكترونية.
class PaymentMethodItem {
  const PaymentMethodItem({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
  });

  final int id;
  final String title;
  final String description;
  final String? iconUrl;

  factory PaymentMethodItem.fromJson(Map<String, dynamic> json) => PaymentMethodItem(
        id: (json['id'] as int?) ?? 0,
        title: (json['title'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        iconUrl: json['icon_url'] as String?,
      );
}

/// سطر فاتورة في معاينة الدفع: المبلغ قبل الخصم وبعده، وكوبونها إن وُجد.
class QuoteLine {
  const QuoteLine({
    required this.invoiceNumber,
    required this.subtotal,
    required this.discount,
    required this.amount,
    required this.couponCode,
    required this.couponError,
  });

  final String invoiceNumber;
  final String subtotal;
  final String discount;
  final String amount;
  final String couponCode;

  /// سبب رفض الكوبون لهذه الفاتورة — يُعرض تحت الحقل.
  final String couponError;

  bool get hasDiscount => (double.tryParse(discount) ?? 0) > 0;

  factory QuoteLine.fromJson(Map<String, dynamic> json) => QuoteLine(
        invoiceNumber: '${json['invoice_number'] ?? ''}',
        subtotal: '${json['subtotal'] ?? ''}',
        discount: '${json['discount'] ?? ''}',
        amount: '${json['amount'] ?? ''}',
        couponCode: '${json['coupon_code'] ?? ''}',
        couponError: '${json['coupon_error'] ?? ''}',
      );
}

/// فاتورة يدفعها ولي أمر آخر الآن فلا تدخل العملية.
class BusyInvoice {
  const BusyInvoice({required this.invoiceNumber, required this.until});

  final String invoiceNumber;

  /// متى ينتهي حجزها.
  final DateTime? until;

  factory BusyInvoice.fromJson(Map<String, dynamic> json) => BusyInvoice(
        invoiceNumber: '${json['invoice_number'] ?? ''}',
        until: DateTime.tryParse((json['until'] as String?) ?? ''),
      );
}

/// قسيمة يقترحها الخادم لفاتورة بعينها.
class CouponSuggestion {
  const CouponSuggestion({required this.code, required this.name, required this.discount});

  final String code;
  final String name;
  final String discount;

  factory CouponSuggestion.fromJson(Map<String, dynamic> json) => CouponSuggestion(
        code: '${json['code'] ?? ''}',
        name: (json['name'] as String?) ?? '',
        discount: '${json['discount'] ?? ''}',
      );
}

/// معاينة الدفع: الفواتير وأسطرها والمشغولة والاقتراحات وطرق الدفع.
class PaymentQuote {
  const PaymentQuote({
    required this.invoices,
    required this.lines,
    required this.busy,
    required this.suggestions,
    required this.methods,
    required this.total,
    required this.currency,
    required this.canPay,
    required this.maxInvoices,
  });

  final List<Invoice> invoices;
  final List<QuoteLine> lines;
  final List<BusyInvoice> busy;

  /// مفتاحها رقم الفاتورة.
  final Map<String, CouponSuggestion> suggestions;
  final List<PaymentMethodItem> methods;
  final String total;
  final String currency;
  final bool canPay;
  final int maxInvoices;

  static const PaymentQuote empty = PaymentQuote(
    invoices: <Invoice>[],
    lines: <QuoteLine>[],
    busy: <BusyInvoice>[],
    suggestions: <String, CouponSuggestion>{},
    methods: <PaymentMethodItem>[],
    total: '',
    currency: '',
    canPay: false,
    maxInvoices: 0,
  );

  /// سطر فاتورة بالرقم، أو null إن لم يكن ضمن المعاينة.
  QuoteLine? line(String invoiceNumber) {
    for (final QuoteLine row in lines) {
      if (row.invoiceNumber == invoiceNumber) {
        return row;
      }
    }

    return null;
  }

  factory PaymentQuote.fromJson(Map<String, dynamic> json) {
    List<dynamic> list(String key) => json[key] is List ? json[key] as List<dynamic> : <dynamic>[];
    final Map<String, dynamic> suggestions = json['suggestions'] is Map
        ? Map<String, dynamic>.from(json['suggestions'] as Map)
        : <String, dynamic>{};

    return PaymentQuote(
      invoices: list('invoices')
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => Invoice.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      lines: list('lines')
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => QuoteLine.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      busy: list('busy')
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => BusyInvoice.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      suggestions: <String, CouponSuggestion>{
        for (final MapEntry<String, dynamic> entry in suggestions.entries)
          if (entry.value is Map)
            entry.key: CouponSuggestion.fromJson(Map<String, dynamic>.from(entry.value as Map)),
      },
      methods: list('methods')
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => PaymentMethodItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      total: '${json['total'] ?? ''}',
      currency: (json['currency'] as String?) ?? '',
      canPay: json['can_pay'] == true,
      maxInvoices: (json['max_invoices'] as int?) ?? 0,
    );
  }
}

/// نتيجة التحقق من كوبون على فاتورة: الرفض نتيجة لا خطأ.
class CouponCheck {
  const CouponCheck({
    required this.valid,
    required this.reason,
    required this.message,
    required this.code,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  final bool valid;

  /// ok، expired، not_applicable…
  final String reason;
  final String message;
  final String code;
  final String subtotal;
  final String discount;
  final String total;

  factory CouponCheck.fromJson(Map<String, dynamic> json) => CouponCheck(
        valid: json['valid'] == true,
        reason: '${json['reason'] ?? ''}',
        message: '${json['message'] ?? ''}',
        code: '${json['code'] ?? ''}',
        subtotal: '${json['subtotal'] ?? ''}',
        discount: '${json['discount'] ?? ''}',
        total: '${json['total'] ?? ''}',
      );
}
