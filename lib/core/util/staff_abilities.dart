import 'package:flutter/foundation.dart';

import '../api/staff_api.dart';
import '../models/staff_models.dart';

/// حساب الموظفة وصلاحياتها كما يرسلها الخادم في `GET /staff/me`.
/// تُحمَّل مرة واحدة بعد الدخول: الصلاحيات لإظهار الأزرار أو إخفائها
/// (والخادم يبقى هو الحَكم)، والحساب لعرض الصورة والاسم والمسمّى.
class StaffAbilities {
  StaffAbilities._();

  static const String scanAttendance = 'scan_attendance';
  static const String markAbsent = 'mark_absent';
  static const String deleteAbsence = 'delete_absence';
  static const String addActivity = 'add_activity';
  static const String updateActivity = 'update_activity';
  static const String deleteActivity = 'delete_activity';
  static const String publishActivity = 'publish_activity';
  static const String uploadDocument = 'upload_document';

  static Map<String, bool> _can = <String, bool>{};
  static bool _loaded = false;

  /// بيانات الحساب — تتغيّر مرة واحدة بعد التحميل فتتحدّث الصور المعروضة.
  static final ValueNotifier<StaffMe> me = ValueNotifier<StaffMe>(StaffMe.empty);

  static bool get loaded => _loaded;

  /// غير المحمَّل يعود بـ false فلا يظهر زر لا نعرف صلاحيته بعد.
  static bool can(String key) => _can[key] ?? false;

  static Future<void> load(StaffApi api) async {
    if (_loaded) {
      return;
    }
    try {
      final Map<String, dynamic> data = await api.me();
      final dynamic can = data['can'];
      if (can is Map) {
        _can = <String, bool>{
          for (final MapEntry<dynamic, dynamic> entry in can.entries) '${entry.key}': entry.value == true,
        };
      }
      me.value = StaffMe.fromJson(data);
      _loaded = true;
    } catch (_) {
      // تُترك فارغة ويُعاد المحاولة في الدخول التالي للشاشة
    }
  }

  /// تحديث الصورة بعد رفعها من «بياناتي» بلا إعادة نداء الخادم.
  static void setAvatar(String url) {
    final StaffMe current = me.value;
    if (url.isEmpty || current.isEmpty) {
      return;
    }
    me.value = StaffMe(
      id: current.id,
      name: current.name,
      avatarUrl: url,
      roleTitle: current.roleTitle,
      branch: current.branch,
    );
  }

  static void clear() {
    _can = <String, bool>{};
    _loaded = false;
    me.value = StaffMe.empty;
  }
}
