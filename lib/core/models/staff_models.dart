/// حساب الموظفة كما يعيده `GET /staff/me`: الاسم والصورة والمسمّى والفرع.
class StaffMe {
  const StaffMe({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.roleTitle,
    required this.branch,
  });

  final int id;
  final String name;
  final String? avatarUrl;

  /// أول دور في القائمة — يُعرض تحت الاسم.
  final String roleTitle;
  final String branch;

  static const StaffMe empty = StaffMe(id: 0, name: '', avatarUrl: null, roleTitle: '', branch: '');

  bool get isEmpty => id == 0 && name.isEmpty;

  /// «معلّمة · الشويخ» بحسب المتوفّر.
  String get subtitle => <String>[roleTitle, branch].where((String part) => part.isNotEmpty).join(' · ');

  factory StaffMe.fromJson(Map<String, dynamic> json) {
    String first(String key, String field) {
      final dynamic rows = json[key];
      if (rows is List) {
        for (final dynamic row in rows) {
          if (row is Map && '${row[field] ?? ''}'.isNotEmpty) {
            return '${row[field]}';
          }
        }
      }

      return '';
    }

    final String avatar = '${json['avatar_url'] ?? ''}';

    return StaffMe(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      avatarUrl: avatar.isEmpty ? null : avatar,
      roleTitle: first('roles', 'title'),
      branch: first('branches', 'title'),
    );
  }
}

/// نافذة إضافة الأنشطة كما يعيدها الخادم: مفتوحة أو مغلقة، ومتى تتغيّر حالتها.
class ActivityWindow {
  const ActivityWindow({
    required this.enabled,
    required this.open,
    required this.day,
    required this.opensAt,
    required this.closesAt,
    required this.secondsLeft,
    required this.hours,
  });

  /// هل خاصية تقييد ساعات الإضافة مفعّلة أصلاً.
  final bool enabled;
  final bool open;

  /// يوم النشاط (قد يكون الأمس بعد منتصف الليل إن كانت نافذته مفتوحة).
  final String day;

  /// موعد إعادة الفتح حين تكون مغلقة.
  final DateTime? opensAt;

  /// موعد الإغلاق حين تكون مفتوحة.
  final DateTime? closesAt;

  /// ما تبقّى بالثواني كما حسبه الخادم — بديل حين لا يصل التاريخ.
  final int secondsLeft;

  /// ساعات الإضافة نصّاً: «من 6:00 ص إلى 2:00 م».
  final String hours;

  static const ActivityWindow empty = ActivityWindow(
    enabled: false,
    open: false,
    day: '',
    opensAt: null,
    closesAt: null,
    secondsLeft: 0,
    hours: '',
  );

  /// اللحظة التي تتغيّر عندها الحالة: الإغلاق إن كانت مفتوحة، وإلّا إعادة الفتح.
  DateTime? get changesAt => open ? closesAt : opensAt;

  /// ما تبقّى حتى تغيّر الحالة: من التاريخ إن وصل، وإلّا من عدّاد الخادم.
  Duration remaining([DateTime? now]) {
    final DateTime? target = changesAt;
    if (target != null) {
      final Duration left = target.difference(now ?? DateTime.now());

      return left.isNegative ? Duration.zero : left;
    }

    return Duration(seconds: secondsLeft < 0 ? 0 : secondsLeft);
  }

  factory ActivityWindow.fromJson(Map<String, dynamic> json) => ActivityWindow(
        enabled: json['enabled'] != false,
        open: json['open'] == true,
        day: (json['day'] as String?) ?? '',
        opensAt: DateTime.tryParse((json['opens_at'] as String?) ?? ''),
        closesAt: DateTime.tryParse((json['closes_at'] as String?) ?? ''),
        secondsLeft: (json['seconds_left'] as num?)?.toInt() ?? 0,
        hours: (json['hours'] as String?) ?? '',
      );

  /// يقرأ الحقل من الرد: غيابه يعني «بلا نافذة» لا نافذة مغلقة.
  static ActivityWindow read(dynamic value) =>
      value is Map ? ActivityWindow.fromJson(Map<String, dynamic>.from(value)) : ActivityWindow.empty;
}

/// لوحة اليوم للمشرفة.
class StaffToday {
  const StaffToday({
    required this.date,
    required this.expected,
    required this.checkedIn,
    required this.checkedOut,
    required this.absent,
    required this.remaining,
    required this.activitiesAdded,
    required this.activitiesPublished,
    required this.activitiesMissing,
    required this.window,
  });

  final String date;
  final int expected;
  final int checkedIn;
  final int checkedOut;
  final int absent;
  final int remaining;
  final int activitiesAdded;
  final int activitiesPublished;
  final int activitiesMissing;
  final ActivityWindow window;

  static const StaffToday empty = StaffToday(
    date: '',
    expected: 0,
    checkedIn: 0,
    checkedOut: 0,
    absent: 0,
    remaining: 0,
    activitiesAdded: 0,
    activitiesPublished: 0,
    activitiesMissing: 0,
    window: ActivityWindow.empty,
  );

  factory StaffToday.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> attendance =
        json['attendance'] is Map ? Map<String, dynamic>.from(json['attendance'] as Map) : <String, dynamic>{};
    final Map<String, dynamic> activities =
        json['activities'] is Map ? Map<String, dynamic>.from(json['activities'] as Map) : <String, dynamic>{};
    return StaffToday(
      date: (json['date'] as String?) ?? '',
      expected: (attendance['expected'] as int?) ?? 0,
      checkedIn: (attendance['in'] as int?) ?? 0,
      checkedOut: (attendance['out'] as int?) ?? 0,
      absent: (attendance['absent'] as int?) ?? 0,
      remaining: (attendance['remaining'] as int?) ?? 0,
      activitiesAdded: (activities['added'] as int?) ?? 0,
      activitiesPublished: (activities['published'] as int?) ?? 0,
      activitiesMissing: (activities['missing'] as int?) ?? 0,
      window: ActivityWindow.read(json['window']),
    );
  }
}


/// تعريف بند في نموذج النشاط (أيقونات / نجوم / نص).
class ActivityDefinition {
  const ActivityDefinition({
    required this.id,
    required this.title,
    required this.type,
    required this.multiple,
    required this.choices,
    this.max,
  });

  final int id;
  final String title;

  /// icons | stars | text
  final String type;
  final bool multiple;
  final List<ActivityChoice> choices;
  final int? max;

  factory ActivityDefinition.fromJson(Map<String, dynamic> json) {
    final List<dynamic> choices = json['choices'] is List ? json['choices'] as List<dynamic> : <dynamic>[];

    return ActivityDefinition(
      id: (json['id'] as int?) ?? 0,
      title: (json['title'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'text',
      multiple: json['multiple'] == true,
      max: json['max'] as int?,
      choices: choices
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => ActivityChoice.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class ActivityChoice {
  const ActivityChoice({required this.value, required this.imageUrl});

  final String value;
  final String? imageUrl;

  factory ActivityChoice.fromJson(Map<String, dynamic> json) => ActivityChoice(
        value: '${json['value'] ?? ''}',
        imageUrl: json['image_url'] as String?,
      );
}

/// نموذج نشاط طالب كما يعيده الخادم قبل الإضافة.
class ActivityForm {
  const ActivityForm({
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.canAdd,
    required this.blocked,
    required this.hasExisting,
    required this.definitions,
    required this.templates,
    required this.window,
  });

  final int studentId;
  final String studentName;
  final String date;
  final bool canAdd;

  /// سبب المنع إن وُجد (نافذة مغلقة، الطالب غائب…)
  final String blocked;
  final bool hasExisting;
  final List<ActivityDefinition> definitions;
  final List<String> templates;

  /// نافذة الإضافة: لعرض العدّاد التنازلي حتى الفتح أو الإغلاق.
  final ActivityWindow window;

  static const ActivityForm empty = ActivityForm(
    studentId: 0,
    studentName: '',
    date: '',
    canAdd: false,
    blocked: '',
    hasExisting: false,
    definitions: <ActivityDefinition>[],
    templates: <String>[],
    window: ActivityWindow.empty,
  );

  factory ActivityForm.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> student =
        json['student'] is Map ? Map<String, dynamic>.from(json['student'] as Map) : <String, dynamic>{};
    final List<dynamic> definitions =
        json['definitions'] is List ? json['definitions'] as List<dynamic> : <dynamic>[];
    final List<dynamic> templates =
        json['message_templates'] is List ? json['message_templates'] as List<dynamic> : <dynamic>[];
    final dynamic blocked = json['blocked'];

    return ActivityForm(
      studentId: (student['id'] as int?) ?? 0,
      studentName: (student['name'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
      canAdd: json['can_add'] == true,
      blocked: blocked is Map
          ? '${blocked['message'] ?? blocked['reason'] ?? ''}'
          : blocked == null
              ? ''
              : '$blocked',
      hasExisting: json['existing'] != null,
      window: ActivityWindow.read(json['window']),
      definitions: definitions
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => ActivityDefinition.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      templates: templates
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => '${item['message'] ?? ''}')
          .where((String message) => message.isNotEmpty)
          .toList(),
    );
  }
}

/// نشاط في قائمة المشرفة (منشور أو بانتظار النشر).
class StaffActivity {
  const StaffActivity({
    required this.id,
    required this.date,
    required this.studentName,
    required this.studentAvatar,
    required this.note,
    required this.published,
    required this.canPublish,
    required this.canUpdate,
    required this.canDelete,
    required this.addedBy,
    required this.studentId,
  });

  final int id;
  final String date;
  final String studentName;
  final String? studentAvatar;
  final String note;
  final bool published;
  final bool canPublish;
  final bool canUpdate;
  final bool canDelete;
  final String addedBy;
  final int studentId;

  factory StaffActivity.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> student =
        json['student'] is Map ? Map<String, dynamic>.from(json['student'] as Map) : <String, dynamic>{};
    final Map<String, dynamic> can =
        json['can'] is Map ? Map<String, dynamic>.from(json['can'] as Map) : <String, dynamic>{};
    final Map<String, dynamic> addedBy =
        json['added_by'] is Map ? Map<String, dynamic>.from(json['added_by'] as Map) : <String, dynamic>{};

    return StaffActivity(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      studentName: (student['name'] as String?) ?? '',
      studentAvatar: student['avatar_url'] as String?,
      note: (json['note'] as String?) ?? '',
      published: json['published'] == true || json['published_at'] != null,
      canPublish: can['publish'] == true,
      canUpdate: can['update'] == true,
      canDelete: can['delete'] == true,
      addedBy: (addedBy['name'] as String?) ?? '',
      studentId: (student['id'] as int?) ?? 0,
    );
  }
}


/// ملخّص خدمات الموظف.
class HrSummary {
  const HrSummary({
    required this.name,
    required this.jobTitle,
    required this.branch,
    required this.month,
    required this.todayStatus,
    required this.present,
    required this.absent,
    required this.leaveDays,
    required this.lateMinutes,
    required this.openViolations,
    required this.pendingLeaves,
    required this.pendingCorrections,
    required this.balances,
    required this.lastPayslip,
  });

  final String name;
  final String jobTitle;
  final String branch;
  final String month;
  final String todayStatus;
  final int present;
  final int absent;
  final int leaveDays;
  final int lateMinutes;
  final int openViolations;
  final int pendingLeaves;
  final int pendingCorrections;
  final List<LeaveBalance> balances;
  final Payslip? lastPayslip;

  static const HrSummary empty = HrSummary(
    name: '',
    jobTitle: '',
    branch: '',
    month: '',
    todayStatus: '',
    present: 0,
    absent: 0,
    leaveDays: 0,
    lateMinutes: 0,
    openViolations: 0,
    pendingLeaves: 0,
    pendingCorrections: 0,
    balances: <LeaveBalance>[],
    lastPayslip: null,
  );

  factory HrSummary.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> section(String key) =>
        json[key] is Map ? Map<String, dynamic>.from(json[key] as Map) : <String, dynamic>{};
    final Map<String, dynamic> employee = section('employee');
    final Map<String, dynamic> today = section('today');
    final Map<String, dynamic> totals = section('month_totals');
    final List<dynamic> balances = json['balances'] is List ? json['balances'] as List<dynamic> : <dynamic>[];

    return HrSummary(
      name: (employee['name'] as String?) ?? '',
      jobTitle: (employee['job_title'] as String?) ?? '',
      branch: (employee['branch'] as String?) ?? '',
      month: (json['month'] as String?) ?? '',
      todayStatus: (today['status'] as String?) ?? '',
      present: (totals['present'] as int?) ?? 0,
      absent: (totals['absent'] as int?) ?? 0,
      leaveDays: (totals['leave'] as int?) ?? 0,
      lateMinutes: (totals['late_minutes'] as int?) ?? 0,
      openViolations: (json['open_violations'] as int?) ?? 0,
      pendingLeaves: (json['pending_leaves'] as int?) ?? 0,
      pendingCorrections: (json['pending_corrections'] as int?) ?? 0,
      balances: balances
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => LeaveBalance.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      lastPayslip: json['last_payslip'] is Map
          ? Payslip.fromJson(Map<String, dynamic>.from(json['last_payslip'] as Map))
          : null,
    );
  }
}

class LeaveBalance {
  const LeaveBalance({required this.title, required this.balance, required this.unit});

  final String title;
  final double balance;
  final String unit;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> type =
        json['leave_type'] is Map ? Map<String, dynamic>.from(json['leave_type'] as Map) : <String, dynamic>{};
    final dynamic balance = json['balance'];

    return LeaveBalance(
      title: (type['title'] as String?) ?? '',
      unit: (type['unit'] as String?) ?? 'day',
      balance: balance is num ? balance.toDouble() : 0,
    );
  }
}

class LeaveType {
  const LeaveType({
    required this.id,
    required this.title,
    required this.unit,
    required this.balance,
    required this.requiresAttachment,
  });

  final int id;
  final String title;
  final String unit;
  final double balance;
  final bool requiresAttachment;

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    final dynamic balance = json['balance'];

    return LeaveType(
      id: (json['id'] as int?) ?? 0,
      title: (json['title'] as String?) ?? '',
      unit: (json['unit'] as String?) ?? 'day',
      balance: balance is num ? balance.toDouble() : 0,
      requiresAttachment: json['requires_attachment'] == true,
    );
  }
}

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.typeTitle,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.status,
    required this.statusLabel,
    required this.canWithdraw,
    required this.hasAttachment,
  });

  final int id;
  final String typeTitle;
  final String startDate;
  final String endDate;
  final num days;
  final String reason;
  final String status;
  final String statusLabel;
  final bool canWithdraw;
  final bool hasAttachment;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> type =
        json['leave_type'] is Map ? Map<String, dynamic>.from(json['leave_type'] as Map) : <String, dynamic>{};
    final dynamic days = json['days'];

    return LeaveRequest(
      id: (json['id'] as int?) ?? 0,
      typeTitle: (type['title'] as String?) ?? '',
      startDate: (json['start_date'] as String?) ?? '',
      endDate: (json['end_date'] as String?) ?? '',
      days: days is num ? days : 0,
      reason: (json['reason'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      statusLabel: (json['status_label'] as String?) ?? '',
      canWithdraw: json['can_withdraw'] == true,
      hasAttachment: json['has_attachment'] == true,
    );
  }
}

class Violation {
  const Violation({
    required this.id,
    required this.date,
    required this.typeLabel,
    required this.minutes,
    required this.statusLabel,
    required this.justification,
    required this.deadline,
    required this.canJustify,
  });

  final int id;
  final String date;
  final String typeLabel;
  final int minutes;
  final String statusLabel;
  final String justification;
  final String deadline;
  final bool canJustify;

  factory Violation.fromJson(Map<String, dynamic> json) => Violation(
        id: (json['id'] as int?) ?? 0,
        date: (json['date'] as String?) ?? '',
        typeLabel: (json['type_label'] as String?) ?? '',
        minutes: (json['minutes'] as int?) ?? 0,
        statusLabel: (json['status_label'] as String?) ?? '',
        justification: (json['justification'] as String?) ?? '',
        deadline: (json['decision_deadline'] as String?) ?? '',
        canJustify: json['can_justify'] == true,
      );
}


/// يوم في سجل حضور الموظف.
class HrDay {
  const HrDay({
    required this.date,
    required this.status,
    required this.statusLabel,
    required this.expectedStart,
    required this.expectedEnd,
    required this.firstIn,
    required this.lastOut,
    required this.lateMinutes,
    required this.earlyMinutes,
    required this.hasCorrection,
  });

  final String date;

  /// present · absent · leave · holiday · weekly_rest · missing_punch · no_data
  final String status;
  final String statusLabel;
  final String expectedStart;
  final String expectedEnd;
  final DateTime? firstIn;
  final DateTime? lastOut;
  final int lateMinutes;
  final int earlyMinutes;
  final bool hasCorrection;

  factory HrDay.fromJson(Map<String, dynamic> json) => HrDay(
        date: (json['date'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        statusLabel: (json['status_label'] as String?) ?? (json['status'] as String?) ?? '',
        expectedStart: (json['expected_start'] as String?) ?? '',
        expectedEnd: (json['expected_end'] as String?) ?? '',
        firstIn: DateTime.tryParse((json['first_in'] as String?) ?? ''),
        lastOut: DateTime.tryParse((json['last_out'] as String?) ?? ''),
        lateMinutes: (json['late_minutes'] as int?) ?? 0,
        earlyMinutes: (json['early_minutes'] as int?) ?? 0,
        hasCorrection: json['correction'] != null,
      );
}

/// سجل حضور شهر للموظف.
class HrAttendance {
  const HrAttendance({required this.month, required this.days, required this.present, required this.absent});

  final String month;
  final List<HrDay> days;
  final int present;
  final int absent;

  static const HrAttendance empty = HrAttendance(month: '', days: <HrDay>[], present: 0, absent: 0);

  factory HrAttendance.fromJson(Map<String, dynamic> json) {
    final List<dynamic> days = json['days'] is List ? json['days'] as List<dynamic> : <dynamic>[];
    final Map<String, dynamic> totals =
        json['totals'] is Map ? Map<String, dynamic>.from(json['totals'] as Map) : <String, dynamic>{};

    return HrAttendance(
      month: (json['month'] as String?) ?? '',
      present: (totals['present'] as int?) ?? 0,
      absent: (totals['absent'] as int?) ?? 0,
      days: days
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> day) => HrDay.fromJson(Map<String, dynamic>.from(day)))
          .toList(),
    );
  }
}

/// طلب تصحيح بصمة.
class Correction {
  const Correction({
    required this.id,
    required this.date,
    required this.kind,
    required this.requestedTime,
    required this.reason,
    required this.status,
    required this.statusLabel,
  });

  final int id;
  final String date;

  /// in أو out
  final String kind;
  final String requestedTime;
  final String reason;
  final String status;
  final String statusLabel;

  bool get canWithdraw => status == 'pending';

  factory Correction.fromJson(Map<String, dynamic> json) => Correction(
        id: (json['id'] as int?) ?? 0,
        date: (json['date'] as String?) ?? '',
        kind: (json['kind'] as String?) ?? 'in',
        requestedTime: (json['requested_time'] as String?) ?? '',
        reason: (json['reason'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        statusLabel: (json['status_label'] as String?) ?? '',
      );
}

/// قسيمة راتب في القائمة.
class Payslip {
  const Payslip({
    required this.id,
    required this.period,
    required this.payDate,
    required this.gross,
    required this.deductions,
    required this.net,
    required this.currency,
  });

  final int id;

  /// YYYY-MM
  final String period;
  final String payDate;
  final String gross;
  final String deductions;
  final String net;
  final String currency;

  String get netLabel => '$net $currency';

  factory Payslip.fromJson(Map<String, dynamic> json) => Payslip(
        id: (json['id'] as int?) ?? 0,
        period: (json['period'] as String?) ?? '',
        payDate: (json['pay_date'] as String?) ?? '',
        gross: '${json['gross'] ?? ''}',
        deductions: '${json['deductions'] ?? ''}',
        net: '${json['net'] ?? ''}',
        currency: (json['currency'] as String?) ?? '',
      );
}

/// سطر في قسيمة الراتب (استحقاق أو استقطاع).
class PayslipLine {
  const PayslipLine({
    required this.title,
    required this.amount,
    required this.quantity,
    required this.note,
  });

  final String title;
  final String amount;
  final double? quantity;
  final String note;

  factory PayslipLine.fromJson(Map<String, dynamic> json) {
    final dynamic quantity = json['quantity'];

    return PayslipLine(
      title: (json['title'] as String?) ?? '',
      amount: '${json['amount'] ?? ''}',
      quantity: quantity is num ? quantity.toDouble() : null,
      note: (json['note'] as String?) ?? '',
    );
  }
}

/// تفاصيل قسيمة الراتب.
class PayslipDetail {
  const PayslipDetail({
    required this.summary,
    required this.employeeName,
    required this.jobTitle,
    required this.basicSalary,
    required this.paidDays,
    required this.absentDays,
    required this.unpaidLeaveDays,
    required this.overtimeMinutes,
    required this.bankName,
    required this.ibanLast4,
    required this.earnings,
    required this.deductions,
    required this.note,
  });

  final Payslip summary;
  final String employeeName;
  final String jobTitle;
  final String basicSalary;
  final double paidDays;
  final double absentDays;
  final double unpaidLeaveDays;
  final int overtimeMinutes;
  final String bankName;
  final String ibanLast4;
  final List<PayslipLine> earnings;
  final List<PayslipLine> deductions;
  final String note;

  static List<PayslipLine> _lines(dynamic value) => value is List
      ? value
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => PayslipLine.fromJson(Map<String, dynamic>.from(item)))
          .toList()
      : <PayslipLine>[];

  static double _double(dynamic value) => value is num ? value.toDouble() : 0;

  factory PayslipDetail.fromJson(Map<String, dynamic> json) => PayslipDetail(
        summary: Payslip.fromJson(json),
        employeeName: (json['employee_name'] as String?) ?? '',
        jobTitle: (json['job_title'] as String?) ?? '',
        basicSalary: '${json['basic_salary'] ?? ''}',
        paidDays: _double(json['paid_days']),
        absentDays: _double(json['absent_days']),
        unpaidLeaveDays: _double(json['unpaid_leave_days']),
        overtimeMinutes: (json['overtime_minutes'] as int?) ?? 0,
        bankName: (json['bank_name'] as String?) ?? '',
        ibanLast4: (json['iban_last4'] as String?) ?? '',
        earnings: _lines(json['earnings']),
        deductions: _lines(json['deductions_lines']),
        note: (json['note'] as String?) ?? '',
      );
}

/// فصل دراسي (للفلترة).
class Classroom {
  const Classroom({required this.id, required this.title});

  final int id;
  final String title;

  factory Classroom.fromJson(Map<String, dynamic> json) => Classroom(
        id: (json['id'] as int?) ?? 0,
        title: (json['title'] as String?) ?? '',
      );
}
