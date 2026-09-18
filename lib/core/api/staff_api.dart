import '../models/card_design.dart';
import '../models/paged.dart';
import '../models/parent_models.dart';
import '../models/staff_models.dart';
import 'api_client.dart';

/// مسارات تطبيق المشرفات بعد الدخول.
class StaffApi {
  StaffApi(this._client);

  final ApiClient _client;

  /// حسابي: البيانات والصلاحيات (can) التي تُبنى عليها أزرار الشاشات.
  Future<Map<String, dynamic>> me() async {
    final dynamic data = await _client.get('/me');

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<StaffToday> today() async {
    final dynamic data = await _client.get('/today');

    return StaffToday.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  Future<Paged<Child>> students({int page = 1, String? search, int? classroom}) async {
    final Map<String, String> query = <String, String>{'page': '$page'};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    if (classroom != null) {
      query['classroom'] = '$classroom';
    }

    return Paged.fromEnvelope<Child>(
      await _client.getEnvelope('/students', query: query),
      Child.fromJson,
    );
  }

  /// حضور اليوم مع الإحصائيات في meta.
  Future<Paged<Child>> attendanceToday({int page = 1, String? status, int? classroom}) async {
    final Map<String, String> query = <String, String>{'page': '$page'};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    if (classroom != null) {
      query['classroom'] = '$classroom';
    }

    return Paged.fromEnvelope<Child>(
      await _client.getEnvelope('/attendance/today', query: query),
      Child.fromJson,
    );
  }

  /// مسح بطاقة: mode = in للحضور و out للانصراف.
  Future<Map<String, dynamic>> scan({required String code, required String mode}) async {
    final dynamic data = await _client.post(
      '/attendance/scan',
      body: <String, dynamic>{'code': code, 'mode': mode},
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// تسجيل غياب من لم يصل (اختيارياً لفصل واحد).
  Future<Map<String, dynamic>> markAbsent({int? classroom}) async {
    final dynamic data = await _client.post(
      '/attendance/mark-absent',
      body: classroom == null ? null : <String, dynamic>{'classroom': classroom},
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> student(int id) async {
    final dynamic data = await _client.get('/students/$id');

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// بطاقة الطالب: التصميم والقيم ورمز QR.
  Future<StudentCard> studentCard(int id) async {
    final dynamic data = await _client.get('/students/$id/card');

    return StudentCard.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  /// ملاحظة معلّمة على طالب (تُشارك مع ولي الأمر اختيارياً).
  Future<Map<String, dynamic>> storeNote({
    required int studentId,
    required String type,
    required String note,
    bool shareWithParent = true,
  }) async {
    final dynamic data = await _client.post(
      '/students/$studentId/notes',
      body: <String, dynamic>{
        'type': type,
        'note': note,
        'share_with_parent': shareWithParent,
      },
      idempotencyKey: 'note-$studentId-${DateTime.now().millisecondsSinceEpoch}',
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// تحضير طالب أو تسجيل انصرافه يدوياً (بلا مسح بطاقة).
  Future<Map<String, dynamic>> markAttendance({required int studentId, required String mode}) async {
    final dynamic data = await _client.post(
      '/attendance/mark',
      body: <String, dynamic>{'student_id': studentId, 'mode': mode},
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// تسجيل غياب طالب يدوياً.
  Future<Map<String, dynamic>> storeAbsence({
    required int studentId,
    String? date,
    String type = 'unexcused',
    String? note,
    bool notify = true,
  }) async {
    final dynamic data = await _client.post(
      '/absences',
      body: <String, dynamic>{
        'student_id': studentId,
        if (date != null) 'date': date,
        'type': type,
        'note': note,
        'notify': notify,
      },
      idempotencyKey: 'absence-$studentId-${DateTime.now().millisecondsSinceEpoch}',
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// نموذج إضافة النشاط لطالب في يوم النشاط الحالي.
  Future<ActivityForm> activityForm(int studentId) async {
    final dynamic data = await _client.get('/students/$studentId/activity-form');

    return ActivityForm.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  /// إضافة نشاط: options مفاتيحها أرقام التعريفات.
  Future<Map<String, dynamic>> storeActivity({
    required int studentId,
    required Map<String, dynamic> options,
    required String date,
    String? note,
    bool publish = false,
  }) async {
    final dynamic data = await _client.post(
      '/student-activities',
      body: <String, dynamic>{
        'student_id': studentId,
        'options': options,
        'date': date,
        'note': note,
        'publish': publish,
      },
      idempotencyKey: 'activity-$studentId-$date-${DateTime.now().millisecondsSinceEpoch}',
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<Paged<StaffActivity>> activities({
    int page = 1,
    String? status,
    String? search,
    int? classroom,
    bool mine = false,
  }) async {
    final Map<String, String> query = <String, String>{'page': '$page'};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    if (classroom != null) {
      query['classroom'] = '$classroom';
    }
    if (mine) {
      query['mine'] = '1';
    }

    return Paged.fromEnvelope<StaffActivity>(
      await _client.getEnvelope('/student-activities', query: query),
      StaffActivity.fromJson,
    );
  }

  Future<void> publishActivity(int id) => _client.post('/student-activities/$id/publish');

  Future<void> unpublishActivity(int id) => _client.post('/student-activities/$id/unpublish');

  Future<void> deleteActivity(int id) => _client.delete('/student-activities/$id');

  /// تفاصيل النشاط مع قيمه الحالية (values) للتعديل.
  Future<Map<String, dynamic>> activity(int id) async {
    final dynamic data = await _client.get('/student-activities/$id');

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// تعديل نشاط قبل نشره — تُستبدل البنود كلها.
  Future<Map<String, dynamic>> updateActivity({
    required int id,
    required Map<String, dynamic> options,
    String? note,
  }) async {
    final dynamic data = await _client.put(
      '/student-activities/$id',
      body: <String, dynamic>{'options': options, 'note': note},
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// فصول المستخدم (للفلترة).
  Future<List<Classroom>> classrooms() async {
    final dynamic data = await _client.get('/classrooms');

    return data is List
        ? data
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> item) => Classroom.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <Classroom>[];
  }

  /// كل تعريفات الأنشطة (لإسنادها لطالب).
  Future<List<ActivityDefinition>> activityDefinitions() async {
    final dynamic data = await _client.get('/activities');

    return data is List
        ? data
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> item) => ActivityDefinition.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <ActivityDefinition>[];
  }

  /// إسناد أنشطة لطالب (يضيف دون إزالة المسند سابقاً).
  Future<Map<String, dynamic>> assignActivities({required int studentId, required List<int> activities}) async {
    final dynamic data = await _client.post(
      '/students/$studentId/activities/assign',
      body: <String, dynamic>{'activities': activities},
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// مرفق طلب الإجازة (تنزيل بترويسات الاعتماد).
  Future<DownloadedFile> leaveAttachment(int id) =>
      _client.download('/hr/leaves/$id/attachment', fallbackName: 'leave-$id');

  /// التراجع عن غياب سُجّل بالخطأ.
  Future<void> deleteAbsence(int id) => _client.delete('/absences/$id');

  // ————— خدمات الموظف —————

  Future<HrSummary> hrSummary() async {
    final dynamic data = await _client.get('/hr/summary');

    return HrSummary.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  Future<List<LeaveType>> leaveTypes() async {
    final dynamic data = await _client.get('/hr/leave-types');

    return data is List
        ? data
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> item) => LeaveType.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <LeaveType>[];
  }

  Future<Paged<LeaveRequest>> leaves({int page = 1, String? status}) async {
    final Map<String, String> query = <String, String>{'page': '$page'};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    return Paged.fromEnvelope<LeaveRequest>(
      await _client.getEnvelope('/hr/leaves', query: query),
      LeaveRequest.fromJson,
    );
  }

  /// معاينة الطلب قبل الإرسال: عدد الأيام والتحذيرات.
  Future<Map<String, dynamic>> previewLeave({
    required int leaveTypeId,
    required String startDate,
    String? endDate,
  }) async {
    final dynamic data = await _client.post('/hr/leaves/preview', body: <String, dynamic>{
      'leave_type_id': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate ?? startDate,
    });

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> storeLeave({
    required int leaveTypeId,
    required String startDate,
    String? endDate,
    String? reason,
  }) async {
    final dynamic data = await _client.post(
      '/hr/leaves',
      body: <String, dynamic>{
        'leave_type_id': leaveTypeId,
        'start_date': startDate,
        'end_date': endDate ?? startDate,
        'reason': reason,
      },
      idempotencyKey: 'leave-$leaveTypeId-$startDate-${DateTime.now().millisecondsSinceEpoch}',
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// طلب إجازة مع مرفق (بعض الأنواع تشترطه).
  Future<Map<String, dynamic>> storeLeaveWithAttachment({
    required int leaveTypeId,
    required String startDate,
    String? endDate,
    String? reason,
    required UploadFile attachment,
  }) async {
    final dynamic data = await _client.upload(
      '/hr/leaves',
      fields: <String, String>{
        'leave_type_id': '$leaveTypeId',
        'start_date': startDate,
        'end_date': endDate ?? startDate,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
      files: <UploadFile>[attachment],
      idempotencyKey: 'leave-$leaveTypeId-$startDate-${DateTime.now().millisecondsSinceEpoch}',
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<void> withdrawLeave(int id) => _client.delete('/hr/leaves/$id');

  Future<HrAttendance> hrAttendance({String? month}) async {
    final dynamic data = await _client.get(
      '/hr/attendance',
      query: month == null ? null : <String, String>{'month': month},
    );

    return HrAttendance.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  Future<Paged<Correction>> corrections({int page = 1, String? status}) async {
    final Map<String, String> query = <String, String>{'page': '$page'};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    return Paged.fromEnvelope<Correction>(
      await _client.getEnvelope('/hr/corrections', query: query),
      Correction.fromJson,
    );
  }

  /// طلب تصحيح بصمة دخول أو خروج ليوم مضى.
  Future<Map<String, dynamic>> storeCorrection({
    required String date,
    required String kind,
    required String requestedTime,
    required String reason,
  }) async {
    final dynamic data = await _client.post(
      '/hr/corrections',
      body: <String, dynamic>{
        'date': date,
        'kind': kind,
        'requested_time': requestedTime,
        'reason': reason,
      },
      idempotencyKey: 'correction-$date-$kind-${DateTime.now().millisecondsSinceEpoch}',
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<void> withdrawCorrection(int id) => _client.delete('/hr/corrections/$id');

  Future<Paged<Payslip>> payslips({int page = 1}) async {
    return Paged.fromEnvelope<Payslip>(
      await _client.getEnvelope('/hr/payslips', query: <String, String>{'page': '$page'}),
      Payslip.fromJson,
    );
  }

  Future<PayslipDetail> payslip(int id) async {
    final dynamic data = await _client.get('/hr/payslips/$id');

    return PayslipDetail.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  Future<Paged<Violation>> violations({int page = 1, bool openOnly = false}) async {
    final Map<String, String> query = <String, String>{'page': '$page'};
    if (openOnly) {
      query['open'] = '1';
    }

    return Paged.fromEnvelope<Violation>(
      await _client.getEnvelope('/hr/violations', query: query),
      Violation.fromJson,
    );
  }

  Future<void> justifyViolation(int id, String justification, {UploadFile? attachment}) async {
    if (attachment == null) {
      await _client.post('/hr/violations/$id/justify', body: <String, dynamic>{'justification': justification});

      return;
    }
    await _client.upload(
      '/hr/violations/$id/justify',
      fields: <String, String>{'justification': justification},
      files: <UploadFile>[attachment],
    );
  }

  /// تغيير صورتي الشخصية — يعيد رابط الصورة الجديد.
  Future<String> updateAvatar(UploadFile file) async {
    final dynamic data = await _client.upload('/me/avatar', files: <UploadFile>[file]);

    return data is Map && data['avatar_url'] != null ? '${data['avatar_url']}' : '';
  }

  /// تغيير صورة الطالب — يتطلب صلاحية تعديل الطلاب.
  Future<String> updateStudentPhoto(int studentId, UploadFile file) async {
    final dynamic data = await _client.upload('/students/$studentId/photo', files: <UploadFile>[file]);

    return data is Map && data['avatar_url'] != null ? '${data['avatar_url']}' : '';
  }

  /// رفع مستند للطالب (شهادة، تطعيمات، بطاقة…).
  Future<Map<String, dynamic>> uploadDocument({
    required int studentId,
    required String title,
    required UploadFile file,
    String? expiresAt,
  }) async {
    final dynamic data = await _client.upload(
      '/students/$studentId/documents',
      fields: <String, String>{
        'title': title,
        if (expiresAt != null && expiresAt.isNotEmpty) 'expires_at': expiresAt,
      },
      files: <UploadFile>[file],
      idempotencyKey: 'doc-$studentId-${DateTime.now().millisecondsSinceEpoch}',
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> publishMany(List<int> ids) async {
    final dynamic data = await _client.post(
      '/student-activities/publish',
      body: <String, dynamic>{'ids': ids},
    );

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }
}
