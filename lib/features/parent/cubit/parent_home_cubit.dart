import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/models/paged.dart';
import '../../../core/models/parent_models.dart';

class ParentHomeState {
  const ParentHomeState({
    this.loading = true,
    this.failure,
    this.children = const <Child>[],
    this.selectedChildId,
    this.latestActivity,
    this.pendingInvoice,
    this.pendingAnnouncement,
    this.unreadNotifications = 0,
    this.badges = const <String, int>{},
  });

  final bool loading;
  final ApiFailure? failure;
  final List<Child> children;
  final int? selectedChildId;
  final Activity? latestActivity;
  final Invoice? pendingInvoice;
  final Announcement? pendingAnnouncement;
  final int unreadNotifications;

  /// عدّادات بطاقات الخدمات: المفتاح اسم الخدمة والقيمة عدد ما ينتظر تصرّفاً.
  final Map<String, int> badges;

  Child? get selectedChild {
    if (children.isEmpty) {
      return null;
    }
    for (final Child child in children) {
      if (child.id == selectedChildId) {
        return child;
      }
    }

    return children.first;
  }

  ParentHomeState copyWith({
    bool? loading,
    ApiFailure? failure,
    bool clearFailure = false,
    List<Child>? children,
    int? selectedChildId,
    Activity? latestActivity,
    bool clearActivity = false,
    Invoice? pendingInvoice,
    bool clearInvoice = false,
    Announcement? pendingAnnouncement,
    bool clearAnnouncement = false,
    int? unreadNotifications,
    Map<String, int>? badges,
  }) =>
      ParentHomeState(
        loading: loading ?? this.loading,
        failure: clearFailure ? null : failure ?? this.failure,
        children: children ?? this.children,
        selectedChildId: selectedChildId ?? this.selectedChildId,
        latestActivity: clearActivity ? null : latestActivity ?? this.latestActivity,
        pendingInvoice: clearInvoice ? null : pendingInvoice ?? this.pendingInvoice,
        pendingAnnouncement: clearAnnouncement ? null : pendingAnnouncement ?? this.pendingAnnouncement,
        unreadNotifications: unreadNotifications ?? this.unreadNotifications,
        badges: badges ?? this.badges,
      );
}

/// الشاشة الرئيسية لولي الأمر: الأبناء وحالة اليوم، وما ينتظر تصرّفه، وآخر نشاط.
class ParentHomeCubit extends Cubit<ParentHomeState> {
  ParentHomeCubit(this.api) : super(const ParentHomeState());

  final ParentApi api;

  Future<void> load({bool refresh = false}) async {
    emit(state.copyWith(loading: !refresh, clearFailure: true));
    try {
      final List<Child> children = await api.children();
      emit(state.copyWith(children: children, loading: false));
      await _loadExtras();
    } on ApiFailure catch (failure) {
      emit(state.copyWith(loading: false, failure: failure));
    }
  }

  void selectChild(int id) => emit(state.copyWith(selectedChildId: id, clearActivity: true));

  Future<void> _loadExtras() async {
    final int? childId = state.selectedChild?.id;
    try {
      final Paged<Activity> activities = await api.activities(studentId: childId);
      emit(state.copyWith(
        latestActivity: activities.items.isEmpty ? null : activities.items.first,
        clearActivity: activities.items.isEmpty,
      ));
    } on ApiFailure {
      // بطاقة النشاط اختيارية
    }
    try {
      final Paged<Invoice> invoices = await api.invoices();
      Invoice? pending;
      for (final Invoice invoice in invoices.items) {
        if (invoice.canPay) {
          pending = invoice;
          break;
        }
      }
      emit(state.copyWith(pendingInvoice: pending, clearInvoice: pending == null));
    } on ApiFailure {
      // بطاقة الفاتورة اختيارية
    }
    try {
      final Paged<Announcement> announcements = await api.announcements();
      Announcement? pending;
      for (final Announcement item in announcements.items) {
        if (item.requireAck && !item.acknowledged) {
          pending = item;
          break;
        }
      }
      emit(state.copyWith(pendingAnnouncement: pending, clearAnnouncement: pending == null));
    } on ApiFailure {
      // بطاقة التعميم اختيارية
    }
    try {
      final Paged<NotificationItem> notifications = await api.notifications();
      emit(state.copyWith(unreadNotifications: (notifications.meta['unread'] as int?) ?? 0));
    } on ApiFailure {
      // عدّاد الجرس اختياري
    }
    try {
      emit(state.copyWith(badges: await api.badges()));
    } on ApiFailure {
      // الشارات زينة: غيابها لا يغيّر الشاشة
    }
  }

  /// بعد اختيار طفل آخر نعيد تحميل بطاقة النشاط فقط.
  Future<void> reloadActivity() async {
    try {
      final Paged<Activity> activities = await api.activities(studentId: state.selectedChild?.id);
      emit(state.copyWith(
        latestActivity: activities.items.isEmpty ? null : activities.items.first,
        clearActivity: activities.items.isEmpty,
      ));
    } on ApiFailure {
      return;
    }
  }
}
