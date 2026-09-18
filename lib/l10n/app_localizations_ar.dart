import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppL10nAr extends AppL10n {
  AppL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get appNameParent => 'حضانتي';

  @override
  String get appNameStaff => 'حضانتي - المشرفات';

  @override
  String get tagline => 'تابِع يوم طفلك لحظة بلحظة';

  @override
  String get taglineStaff => 'يومك مع الأطفال في مكان واحد';

  @override
  String get languageSwitch => 'English';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get cancel => 'إلغاء';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get close => 'إغلاق';

  @override
  String get later => 'لاحقاً';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitleMobile => 'أدخل رقم الجوال المسجّل لدى الحضانة.';

  @override
  String get loginSubtitlePassword => 'أدخل بيانات الدخول الخاصة بك.';

  @override
  String get loginSubtitleStaff => 'ادخلي باسم المستخدم وكلمة المرور كما في لوحة التحكم.';

  @override
  String get mobileLabel => 'رقم الجوال';

  @override
  String get identifierLabel => 'اسم المستخدم أو البريد';

  @override
  String get usernameLabel => 'اسم المستخدم';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get smsNote => 'سنرسل رمز تحقق برسالة نصية إلى هذا الرقم. لا نشارك رقمك مع أحد.';

  @override
  String get notRegistered => 'رقمك غير مسجّل؟ تواصل مع الحضانة';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get forgotTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotSubtitle => 'أدخل بريدك المسجّل وسنرسل لك رابط التعيين.';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get send => 'إرسال';

  @override
  String get forgotSent => 'إن كان البريد مسجّلاً فستصلك رسالة خلال دقائق.';

  @override
  String get otpTitle => 'رمز التحقق';

  @override
  String otpSubtitle(String target) {
    return 'أدخل الرمز المرسل إلى $target';
  }

  @override
  String get otpCodeLabel => 'الرمز';

  @override
  String get verify => 'تأكيد';

  @override
  String get resend => 'إعادة إرسال الرمز';

  @override
  String resendIn(int seconds) {
    return 'إعادة الإرسال بعد $seconds ثانية';
  }

  @override
  String get otpSent => 'أرسلنا رمزاً جديداً.';

  @override
  String get biometricLabel => 'الدخول بالبصمة';

  @override
  String biometricHint(String name) {
    return 'البصمة مفعّلة لـ $name — المس زر البصمة للدخول مباشرة';
  }

  @override
  String get biometricPromptTitle => 'تسجيل الدخول';

  @override
  String get biometricPromptSubtitle => 'استخدم بصمتك للدخول إلى حسابك';

  @override
  String get biometricEnableTitle => 'تفعيل الدخول بالبصمة';

  @override
  String get biometricEnableBody => 'ادخل في المرة القادمة ببصمتك بدل كتابة بياناتك. بصمتك لا تغادر جهازك.';

  @override
  String get biometricEnableAction => 'تفعيل البصمة';

  @override
  String get biometricEnabled => 'تم تفعيل الدخول بالبصمة على هذا الجهاز.';

  @override
  String get biometricDisabled => 'أوقفنا الدخول بالبصمة على هذا الجهاز.';

  @override
  String get biometricFailedTitle => 'تعذّر التحقق من البصمة';

  @override
  String get biometricRetry => 'حاول مرة أخرى أو ادخل بالطريقة المعتادة.';

  @override
  String get biometricRevoked => 'أُلغي الدخول بالبصمة على هذا الجهاز. سجّل الدخول بالطريقة المعتادة.';

  @override
  String get biometricLocked => 'أُقفلت البصمة مؤقتاً بعد محاولات كثيرة. ادخل بالطريقة المعتادة.';

  @override
  String get biometricNotEnrolled => 'لا توجد بصمة مسجّلة على هذا الجهاز. سجّلها من إعدادات الجهاز أولاً.';

  @override
  String get biometricUnavailable => 'هذا الجهاز لا يدعم الدخول بالبصمة.';

  @override
  String get biometricReauth => 'لتفعيل البصمة أعد تسجيل الدخول أولاً.';

  @override
  String get networkError => 'تعذّر الاتصال بالخادم. تحقّق من الإنترنت ثم أعد المحاولة.';

  @override
  String get serverError => 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get configMissing => 'لم يُضبط مفتاح التطبيق. شغّل التطبيق مع ‎--dart-define‎ للمفاتيح.';

  @override
  String get maintenanceTitle => 'التطبيق تحت الصيانة';

  @override
  String get maintenanceBody => 'نعمل على تحسينات سريعة. حاول بعد قليل.';

  @override
  String get updateTitle => 'حدّث التطبيق';

  @override
  String get updateBody => 'هذه النسخة لم تعد مدعومة. حدّث التطبيق للمتابعة.';

  @override
  String get updateAction => 'تحديث الآن';

  @override
  String get accountBlockedTitle => 'الحساب موقوف عن التطبيق';

  @override
  String get accountBlockedBody => 'تواصل مع إدارة الحضانة لمعرفة التفاصيل.';

  @override
  String get accountInactiveTitle => 'الحساب غير نشِط';

  @override
  String get accountInactiveBody => 'تواصل مع إدارة الحضانة لتفعيل حسابك.';

  @override
  String get tooManyTitle => 'محاولات كثيرة';

  @override
  String tooManyBody(int minutes) {
    return 'حاول بعد $minutes دقيقة.';
  }

  @override
  String get smsUnavailable => 'خدمة الرسائل غير متاحة حالياً. تواصل مع الحضانة.';

  @override
  String get otpUnavailable => 'لا يوجد بريد مسجّل لحسابك لإرسال الرمز. تواصل مع الإدارة.';

  @override
  String get sessionExpiredTitle => 'انتهت الجلسة';

  @override
  String get sessionExpiredBody => 'سجّل الدخول من جديد للمتابعة.';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutForget => 'تسجيل الخروج وإيقاف البصمة';

  @override
  String get staffReplacedDevices => 'تم إخراج جهازك السابق — تطبيق المشرفات يعمل على جهاز واحد.';

  @override
  String welcome(String name) {
    return 'أهلاً $name';
  }

  @override
  String get homeParentTitle => 'الرئيسية';

  @override
  String get homeStaffTitle => 'اليوم';

  @override
  String get comingSoon => 'بقية الشاشات قيد البناء.';

  @override
  String get securitySettings => 'الأمان والبصمة';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navActivities => 'الأنشطة';

  @override
  String get navPayments => 'المدفوعات';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String get navAccount => 'حسابي';

  @override
  String get navToday => 'اليوم';

  @override
  String get navStudents => 'الطلاب';

  @override
  String get statusPresent => 'حاضر الآن';

  @override
  String get statusCheckedOut => 'انصرف';

  @override
  String get statusAbsent => 'غائب اليوم';

  @override
  String get statusClosed => 'اليوم عطلة';

  @override
  String get statusNotArrived => 'لم يصل بعد';

  @override
  String arrivedAt(String time) {
    return 'وصل $time';
  }

  @override
  String leftAt(String time) {
    return 'انصرف $time';
  }

  @override
  String get childCard => 'ملف الطفل';

  @override
  String get pendingTitle => 'بانتظارك';

  @override
  String get payNow => 'ادفع الآن';

  @override
  String get acknowledge => 'اطّلعت';

  @override
  String get acknowledged => 'تم الاطلاع';

  @override
  String get needsAck => 'تعميم يحتاج موافقتك';

  @override
  String dueOn(String date) {
    return 'مستحقة $date';
  }

  @override
  String get overdue => 'متأخرة';

  @override
  String get servicesTitle => 'الخدمات';

  @override
  String get serviceAttendance => 'الحضور';

  @override
  String get serviceInvoices => 'الفواتير';

  @override
  String get serviceCirculars => 'التعاميم';

  @override
  String get serviceEvents => 'الفعاليات';

  @override
  String get serviceCoupons => 'قسائمي';

  @override
  String get todayActivity => 'نشاط اليوم';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get noActivityYet => 'لا يوجد نشاط منشور بعد.';

  @override
  String get activitiesTitle => 'الأنشطة';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get invoicesTitle => 'الفواتير';

  @override
  String get circularsTitle => 'التعاميم';

  @override
  String get markAllRead => 'تعليم الكل كمقروء';

  @override
  String get emptyList => 'لا يوجد شيء هنا بعد.';

  @override
  String get loadMore => 'عرض المزيد';

  @override
  String invoiceNumber(String number) {
    return 'فاتورة رقم $number';
  }

  @override
  String get invoiceItems => 'بنود الفاتورة';

  @override
  String get attendanceTitle => 'الحضور اليوم';

  @override
  String get statExpected => 'متوقّع';

  @override
  String get statIn => 'حضر';

  @override
  String get statOut => 'انصرف';

  @override
  String get statAbsent => 'غائب';

  @override
  String get statRemaining => 'متبقٍ';

  @override
  String get activitiesBoard => 'الأنشطة';

  @override
  String get statAdded => 'أُضيف';

  @override
  String get statPublished => 'منشور';

  @override
  String get statMissing => 'ناقص';

  @override
  String get windowOpenNow => 'نافذة إضافة الأنشطة مفتوحة الآن.';

  @override
  String get windowOpensIn => 'يُفتح بعد';

  @override
  String get windowClosesIn => 'يُغلق بعد';

  @override
  String get windowUpdating => 'يجري تحديث حالة النافذة…';

  @override
  String windowHoursNote(String hours) {
    return 'ساعات الإضافة $hours';
  }

  @override
  String windowReopensAt(String time) {
    return 'يُعاد الفتح الساعة $time';
  }

  @override
  String windowClosesAt(String time) {
    return 'يُغلق الساعة $time';
  }

  @override
  String get pickStudent => 'اختر طالباً';

  @override
  String get windowClosed => 'نافذة إضافة الأنشطة مغلقة الآن.';

  @override
  String get studentsTitle => 'الطلاب';

  @override
  String get searchHint => 'ابحث بالاسم';

  @override
  String get scanTitle => 'مسح البطاقة';

  @override
  String get attendanceMonthTitle => 'الحضور والغياب';

  @override
  String attendanceRate(String rate) {
    return 'نسبة الحضور $rate%';
  }

  @override
  String get schoolDays => 'أيام الدراسة';

  @override
  String get absentDays => 'أيام الغياب';

  @override
  String get excusedDays => 'بعذر';

  @override
  String get unexcusedDays => 'بلا عذر';

  @override
  String get reportAbsence => 'بلّغ عن غياب';

  @override
  String get absenceFrom => 'من تاريخ';

  @override
  String get absenceTo => 'إلى تاريخ';

  @override
  String get absenceNote => 'السبب';

  @override
  String get absenceSaved => 'سجّلنا البلاغ.';

  @override
  String get absenceCancel => 'إلغاء البلاغ';

  @override
  String get absenceCancelled => 'أُلغي البلاغ.';

  @override
  String get upcomingAbsences => 'بلاغات قادمة';

  @override
  String get notesTitle => 'ملاحظات المعلّمة';

  @override
  String get devicesTitle => 'أجهزتي';

  @override
  String get deviceCurrent => 'هذا الجهاز';

  @override
  String get deviceSignOut => 'إخراج الجهاز';

  @override
  String get deviceSignedOut => 'أُخرج الجهاز.';

  @override
  String lastUsed(String time) {
    return 'آخر استخدام $time';
  }

  @override
  String get staffAttendanceTitle => 'حضور اليوم';

  @override
  String get markAbsentAction => 'تسجيل غياب من لم يصل';

  @override
  String get markAbsentConfirm => 'سيُسجّل غياب كل من لم يصل اليوم. متابعة؟';

  @override
  String get confirm => 'تأكيد';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterNotArrived => 'لم يصل';

  @override
  String get filterPresent => 'حاضر';

  @override
  String get filterAbsent => 'غائب';

  @override
  String get selectChild => 'اختر الطفل';

  @override
  String get pickDate => 'اختر التاريخ';

  @override
  String get eventsTitle => 'الفعاليات';

  @override
  String get bookingsTitle => 'حجوزاتي';

  @override
  String seatsLeft(String count) {
    return '$count مقعد متبقٍ';
  }

  @override
  String priceFrom(String price) {
    return 'تبدأ من $price';
  }

  @override
  String get eventProgram => 'البرنامج';

  @override
  String get eventChildren => 'الأبناء';

  @override
  String get eligible => 'مؤهّل للحجز';

  @override
  String get notEligible => 'غير مؤهّل';

  @override
  String get booked => 'محجوز';

  @override
  String get bookingSoon => 'الحجز من التطبيق قيد الإضافة.';

  @override
  String participantsCount(String count) {
    return '$count مشارك';
  }

  @override
  String get cancelBooking => 'إلغاء الحجز';

  @override
  String get bookingCancelled => 'أُلغي الحجز.';

  @override
  String get cancelBookingConfirm => 'سيُلغى هذا الحجز. متابعة؟';

  @override
  String get staffActivitiesTitle => 'أنشطة الطلاب';

  @override
  String get addActivity => 'إضافة نشاط';

  @override
  String activityFor(String name) {
    return 'نشاط $name';
  }

  @override
  String activityDay(String date) {
    return 'يوم النشاط $date';
  }

  @override
  String get activityNote => 'ملاحظة المعلّمة';

  @override
  String get activityTemplates => 'رسائل جاهزة';

  @override
  String get publishNow => 'نشر مباشرة';

  @override
  String get saveActivity => 'حفظ النشاط';

  @override
  String get activitySaved => 'حُفظ النشاط.';

  @override
  String get activityExists => 'لهذا الطالب نشاط في هذا اليوم.';

  @override
  String get activityBlocked => 'لا يمكن إضافة نشاط الآن.';

  @override
  String get filterUnpublished => 'بانتظار النشر';

  @override
  String get filterPublished => 'منشور';

  @override
  String get publish => 'نشر';

  @override
  String get published => 'نُشر';

  @override
  String get publishAll => 'نشر الكل';

  @override
  String publishedCount(String count) {
    return 'نُشر $count نشاطاً.';
  }

  @override
  String addedBy(String name) {
    return 'أضافه $name';
  }

  @override
  String get missingActivity => 'بلا نشاط';

  @override
  String get hrTitle => 'خدماتي';

  @override
  String get hrPresentDays => 'أيام الحضور';

  @override
  String get hrAbsentDays => 'أيام الغياب';

  @override
  String get hrLeaveDays => 'أيام الإجازة';

  @override
  String get hrLateMinutes => 'دقائق التأخير';

  @override
  String get hrBalances => 'أرصدة الإجازات';

  @override
  String get leavesTitle => 'إجازاتي';

  @override
  String get newLeave => 'طلب إجازة';

  @override
  String get leaveType => 'نوع الإجازة';

  @override
  String get leaveReason => 'السبب';

  @override
  String leaveDaysCount(String count) {
    return '$count يوم';
  }

  @override
  String get leaveSubmitted => 'أُرسل الطلب.';

  @override
  String get withdraw => 'سحب الطلب';

  @override
  String get withdrawn => 'سُحب الطلب.';

  @override
  String get violationsTitle => 'مخالفاتي';

  @override
  String get justify => 'تبرير';

  @override
  String get justification => 'التبرير';

  @override
  String get justifySent => 'أُرسل التبرير.';

  @override
  String decisionDeadline(String date) {
    return 'آخر موعد $date';
  }

  @override
  String minutesCount(String count) {
    return '$count دقيقة';
  }

  @override
  String balanceDays(String count) {
    return '$count يوم متبقٍ';
  }

  @override
  String get paymentsTitle => 'مدفوعاتي';

  @override
  String get paymentOpen => 'افتح صفحة الدفع';

  @override
  String get paymentOpened => 'فُتحت صفحة الدفع في المتصفح. بعد إتمامها ارجع هنا واضغط «تحقّق من الحالة».';

  @override
  String get paymentCheck => 'تحقّق من الحالة';

  @override
  String get paymentPaid => 'تم الدفع بنجاح.';

  @override
  String get paymentFailed => 'لم تكتمل عملية الدفع.';

  @override
  String get paymentPending => 'العملية قيد التنفيذ.';

  @override
  String get receipt => 'الإيصال';

  @override
  String invoicesCount(String count) {
    return '$count فاتورة';
  }

  @override
  String get cannotOpenLink => 'تعذّر فتح الرابط.';

  @override
  String get hrAttendanceTitle => 'سجل حضوري';

  @override
  String get correctionsTitle => 'طلبات التصحيح';

  @override
  String get newCorrection => 'طلب تصحيح';

  @override
  String get correctionKind => 'نوع البصمة';

  @override
  String get correctionIn => 'دخول';

  @override
  String get correctionOut => 'خروج';

  @override
  String get correctionTime => 'الوقت الصحيح';

  @override
  String get correctionReason => 'السبب';

  @override
  String get correctionSent => 'أُرسل طلب التصحيح.';

  @override
  String expectedHours(String from, String to) {
    return 'الدوام $from - $to';
  }

  @override
  String lateBy(String count) {
    return 'تأخير $count د';
  }

  @override
  String earlyBy(String count) {
    return 'خروج مبكر $count د';
  }

  @override
  String get requestCorrectionForDay => 'اطلب تصحيحاً لهذا اليوم';

  @override
  String get absencesTitle => 'الغياب';

  @override
  String get couponsTitle => 'قسائمي';

  @override
  String get subscriptionsTitle => 'الاشتراكات';

  @override
  String get profileTitle => 'بياناتي';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get profileSaved => 'حُفظت بياناتك.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get currentPasswordHint => 'مطلوبة لتغيير البريد.';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordHint => 'سنرسل رابط التعيين إلى بريدك المسجّل.';

  @override
  String couponValue(String value) {
    return 'خصم $value';
  }

  @override
  String couponEnds(String date) {
    return 'ينتهي $date';
  }

  @override
  String couponFor(String names) {
    return 'لـ $names';
  }

  @override
  String subscriptionPeriod(String from, String to) {
    return '$from إلى $to';
  }

  @override
  String daysLeft(String count) {
    return 'باقٍ $count يوم';
  }

  @override
  String get currentSubscription => 'الاشتراك الحالي';

  @override
  String get requestStop => 'طلب إيقاف الاشتراك';

  @override
  String get requestStopReason => 'سبب الإيقاف';

  @override
  String get requestStopSent => 'أُرسل الطلب إلى الإدارة.';

  @override
  String get noChildSelected => 'اختر الطفل أولاً';

  @override
  String get documentsTitle => 'مستندات الطفل';

  @override
  String get documentsMissing => 'ناقصة';

  @override
  String get documentsExpired => 'منتهية';

  @override
  String get documentsExpiring => 'قاربت الانتهاء';

  @override
  String get documentOpen => 'فتح المستند';

  @override
  String get cardTitle => 'بطاقة الطفل';

  @override
  String get cardHint => 'اعرض هذا الرمز عند البوابة لتسجيل الحضور والانصراف.';

  @override
  String get weeklyTitle => 'الملخص الأسبوعي';

  @override
  String get weeklyPresent => 'أيام حضور';

  @override
  String get weeklyAbsent => 'أيام غياب';

  @override
  String get weeklyActivities => 'أنشطة';

  @override
  String get mediaConsent => 'الموافقة على نشر الصور';

  @override
  String get mediaConsentOn => 'مفعّلة';

  @override
  String get mediaConsentOff => 'موقوفة';

  @override
  String get studentTitle => 'ملف الطالب';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get notePositive => 'إيجابية';

  @override
  String get noteNegative => 'تحتاج متابعة';

  @override
  String get noteShare => 'مشاركتها مع ولي الأمر';

  @override
  String get noteSaved => 'حُفظت الملاحظة.';

  @override
  String get markAbsent => 'تسجيل غياب';

  @override
  String get absenceExcused => 'بعذر';

  @override
  String get absenceUnexcused => 'بلا عذر';

  @override
  String get absenceSavedStaff => 'سُجّل الغياب.';

  @override
  String get parentsLabel => 'أولياء الأمر';

  @override
  String get teachersLabel => 'المعلّمات';

  @override
  String get bookNow => 'احجز الآن';

  @override
  String get bookingTitle => 'حجز الفعالية';

  @override
  String get participants => 'المشاركون';

  @override
  String get bookingContact => 'بيانات التواصل';

  @override
  String get bookingAnswers => 'بيانات الحجز';

  @override
  String get bookingAddons => 'الإضافات';

  @override
  String get previewBooking => 'معاينة المبلغ';

  @override
  String bookingTotal(String total) {
    return 'الإجمالي $total';
  }

  @override
  String bookingDiscount(String amount) {
    return 'الخصم $amount';
  }

  @override
  String get willWait => 'لا توجد مقاعد كافية — سيدخل الحجز قائمة الانتظار.';

  @override
  String get consentText => 'أوافق على شروط المشاركة في الفعالية.';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get bookingCreated => 'تم الحجز.';

  @override
  String get payBooking => 'ادفع الحجز';

  @override
  String get fileFieldWeb => 'هذا النموذج يطلب مرفقاً — أكمل الحجز من موقع الحضانة.';

  @override
  String get selectAtLeastOne => 'اختر مشاركاً واحداً على الأقل.';

  @override
  String get quantity => 'العدد';

  @override
  String get scanIn => 'مسح الحضور';

  @override
  String get scanOut => 'مسح الانصراف';

  @override
  String get scanAgain => 'مسح بطاقة أخرى';

  @override
  String get scanMode => 'نوع المسح';

  @override
  String get scanCancelled => 'أُلغي المسح.';

  @override
  String get scanUnavailable => 'الكاميرا غير متاحة على هذا الجهاز.';

  @override
  String get scanCardUnknown => 'بطاقة غير معروفة.';

  @override
  String get attachFile => 'إرفاق ملف';

  @override
  String get attachmentRequired => 'هذا النوع يتطلب مرفقاً.';

  @override
  String get removeAttachment => 'إزالة المرفق';

  @override
  String get addDocument => 'رفع مستند';

  @override
  String get documentTitle => 'اسم المستند';

  @override
  String get documentExpires => 'تاريخ الانتهاء (اختياري)';

  @override
  String get documentUploaded => 'رُفع المستند.';

  @override
  String get uploading => 'جارٍ الرفع…';

  @override
  String get errorNotFoundTitle => 'غير موجود';

  @override
  String get errorNotFoundBody => 'لم نجد ما تبحث عنه. ربما حُذف أو تغيّر.';

  @override
  String get errorForbiddenTitle => 'لا تملك صلاحية';

  @override
  String get errorForbiddenBody => 'هذه الصفحة غير متاحة لحسابك. تواصل مع إدارة الحضانة.';

  @override
  String get errorNetworkTitle => 'لا يوجد اتصال';

  @override
  String get errorServerTitle => 'خطأ في الخادم';

  @override
  String get errorServerBody => 'حدث خلل مؤقت عندنا. حاول بعد قليل.';

  @override
  String get errorValidationTitle => 'تحقّق من البيانات';

  @override
  String get errorSessionTitle => 'انتهت الجلسة';

  @override
  String get errorDetails => 'تفاصيل فنية';

  @override
  String retryIn(String seconds) {
    return 'حاول بعد $seconds ثانية';
  }

  @override
  String get goBack => 'رجوع';

  @override
  String get errorConflictTitle => 'تعذّر إتمام العملية';

  @override
  String get errorConfigTitle => 'خطأ في إعداد التطبيق';

  @override
  String get errorConfigBody => 'مفاتيح الاتصال بالخادم غير صحيحة. أبلغ المطوّر.';

  @override
  String get errorReauthTitle => 'أعد تسجيل الدخول';

  @override
  String get errorTooLargeTitle => 'الملف كبير';

  @override
  String get errorDemoTitle => 'نسخة تجربة';

  @override
  String get errorGatewayTitle => 'تعذّر الاتصال ببوابة الدفع';

  @override
  String get errorCardTitle => 'بطاقة غير معروفة';

  @override
  String get errorAccountBlockedTitle => 'الحساب موقوف';

  @override
  String get errorAccountInactiveTitle => 'الحساب غير نشِط';

  @override
  String get cardFront => 'الوجه الأمامي';

  @override
  String get cardBack => 'الوجه الخلفي';

  @override
  String get cardDownload => 'تحميل البطاقة';

  @override
  String get cardSaved => 'حُفظت البطاقة';

  @override
  String get cardSaveCancelled => 'أُلغي الحفظ';

  @override
  String get cardSaveFailed => 'تعذّر إنشاء صورة البطاقة';

  @override
  String minLengthHint(String count) {
    return '$count أحرف على الأقل';
  }

  @override
  String get payslipsTitle => 'راتبي';

  @override
  String get payslipsEmpty => 'لا توجد قسائم رواتب معتمدة بعد.';

  @override
  String get payslipTitle => 'قسيمة الراتب';

  @override
  String get payslipLast => 'آخر راتب';

  @override
  String get payslipNet => 'الصافي';

  @override
  String get payslipGross => 'الإجمالي';

  @override
  String get payslipDeductions => 'الاستقطاعات';

  @override
  String get payslipEarnings => 'الاستحقاقات';

  @override
  String get payslipBasic => 'الراتب الأساسي';

  @override
  String get payslipUnpaidDays => 'أيام بلا أجر';

  @override
  String get payslipOvertime => 'العمل الإضافي';

  @override
  String get payslipBank => 'البنك';

  @override
  String payslipPaidOn(String date) {
    return 'صُرف في $date';
  }

  @override
  String get checkoutTitle => 'دفع المستحق';

  @override
  String get checkoutEmpty => 'لا توجد فواتير مستحقة الآن.';

  @override
  String get checkoutTotal => 'الإجمالي';

  @override
  String checkoutSelected(String count) {
    return '$count فاتورة محدّدة';
  }

  @override
  String checkoutBusy(String number, String time) {
    return 'الفاتورة $number يدفعها ولي أمر آخر الآن حتى $time';
  }

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get couponLabel => 'كود الخصم';

  @override
  String get couponApply => 'تطبيق';

  @override
  String couponSuggested(String code, String amount) {
    return 'قسيمة متاحة $code — خصم $amount';
  }

  @override
  String get couponUse => 'استخدمها';

  @override
  String get invoicePdf => 'تحميل الفاتورة';

  @override
  String get invoicePdfFailed => 'تعذّر إنشاء نسخة الفاتورة.';

  @override
  String get editActivity => 'تعديل النشاط';

  @override
  String get deleteActivity => 'حذف النشاط';

  @override
  String get deleteActivityConfirm => 'سيُحذف النشاط وبنوده. هل تريد المتابعة؟';

  @override
  String get activityDeleted => 'حُذف النشاط';

  @override
  String get activityPublished => 'نُشر النشاط';

  @override
  String get activityUnpublished => 'أُلغي نشر النشاط';

  @override
  String get unpublish => 'إلغاء النشر';

  @override
  String get delete => 'حذف';

  @override
  String get allClassrooms => 'كل الفصول';

  @override
  String get undoAbsence => 'تراجع عن الغياب';

  @override
  String get undoAbsenceConfirm => 'سيُحذف تسجيل غياب اليوم لهذا الطالب.';

  @override
  String get absenceRemoved => 'حُذف تسجيل الغياب';

  @override
  String get filterUnread => 'غير المقروءة';

  @override
  String get filterUnacked => 'بانتظار التأكيد';

  @override
  String get filterDue => 'المستحقة';

  @override
  String get filterPaid => 'المدفوعة';

  @override
  String get filterUnpaid => 'غير المدفوعة';

  @override
  String get filterExpired => 'المنتهية';

  @override
  String get filterPending => 'قيد التنفيذ';

  @override
  String get filterFailed => 'المتعثّرة';

  @override
  String get filterCurrent => 'السارية';

  @override
  String get filterUpcoming => 'القادمة';

  @override
  String get filterUnviewed => 'غير المشاهدة';

  @override
  String get filterForMyChildren => 'لأبنائي';

  @override
  String get filterActive => 'النشطة';

  @override
  String get filterConfirmed => 'المؤكَّدة';

  @override
  String get filterCancelled => 'الملغاة';

  @override
  String get eventTrip => 'رحلات';

  @override
  String get eventActivity => 'أنشطة';

  @override
  String get eventWorkshop => 'ورش';

  @override
  String get eventCamp => 'مخيّمات';

  @override
  String get eventCelebration => 'حفلات';

  @override
  String get acceptBooking => 'قبول الحجز';

  @override
  String get bookingAccepted => 'قُبل الحجز';

  @override
  String get renewBooking => 'تجديد المهلة';

  @override
  String get bookingRenewed => 'جُدِّدت مهلة الدفع';

  @override
  String get bookingInvoice => 'الفاتورة';

  @override
  String get surveyTitle => 'تقييم الفعالية';

  @override
  String get surveySent => 'شكراً لتقييمك';

  @override
  String get surveyAlreadySent => 'أرسلتَ تقييماً سابقاً، والإرسال الآن يستبدله.';

  @override
  String get surveyNotes => 'ملاحظات';

  @override
  String get attachments => 'المرفقات';

  @override
  String get openAttachment => 'فتح المرفق';

  @override
  String get downloading => 'جارٍ التنزيل…';

  @override
  String get fileSaved => 'حُفظ الملف';

  @override
  String get assignActivities => 'إسناد أنشطة';

  @override
  String get activitiesAssigned => 'أُسندت الأنشطة';

  @override
  String couponAccepted(String discount, String total) {
    return 'خصم $discount — الإجمالي بعد الخصم $total';
  }

  @override
  String get activityPdf => 'تحميل تقرير اليوم';

  @override
  String get disablePush => 'إيقاف إشعارات هذا الجهاز';

  @override
  String get pushDisabled => 'أُوقفت إشعارات هذا الجهاز';

  @override
  String get filterEveryone => 'الجميع';

  @override
  String get filterMine => 'ما أضفتُه';

  @override
  String get copy => 'نسخ';

  @override
  String get couponCopied => 'نُسخ الكود';

  @override
  String get couponNoInvoices => 'لا توجد فواتير مستحقة يصلح لها هذا الكوبون.';

  @override
  String get showInvoice => 'عرض الفاتورة';

  @override
  String get allChildren => 'كل الأبناء';

  @override
  String get scanHint => 'امسحي بطاقة الطفل من تبويب «الحضور» لتسجيل الدخول أو الانصراف.';

  @override
  String get showAmounts => 'إظهار المبالغ';

  @override
  String get hideAmounts => 'إخفاء المبالغ';

  @override
  String get leaveTypesEmpty => 'لا توجد أنواع إجازات مفعّلة حالياً. راجعي إدارة النظام.';

  @override
  String get balancesEmpty => 'لا توجد أرصدة إجازات مسجّلة على ملفك.';

  @override
  String get withdrawLeaveConfirm => 'سيُسحب طلب الإجازة ولن يُعرض على الإدارة. متابعة؟';

  @override
  String get working => 'جارٍ التنفيذ…';

  @override
  String get scanSending => 'جارٍ إرسال البطاقة…';

  @override
  String get markAbsentBusy => 'جارٍ تسجيل الغياب…';

  @override
  String get formHiddenUntilOpen => 'يظهر نموذج الإضافة تلقائياً فور فتح النافذة.';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get photoUploading => 'جارٍ رفع الصورة…';

  @override
  String get photoUpdated => 'تم تحديث الصورة';

  @override
  String get markPresent => 'تحضير';

  @override
  String get markPresentNote => 'تسجيل وصول الطالب الآن وإلغاء غياب اليوم إن وُجد.';

  @override
  String get markCheckedOut => 'تسجيل انصراف';

  @override
  String get markCheckedOutNote => 'تسجيل مغادرة الطالب الآن.';

  @override
  String get markUnexcused => 'غياب بدون عذر';

  @override
  String get markUnexcusedNote => 'يُسجَّل غياباً ويُبلَّغ ولي الأمر.';

  @override
  String get markExcused => 'غياب بعذر';

  @override
  String get markExcusedNote => 'يُطلب سبب الغياب ثم يُسجَّل ويُبلَّغ ولي الأمر.';

  @override
  String markAbsentOneConfirm(String name) {
    return 'سيُسجَّل غياب $name اليوم ويُبلَّغ ولي الأمر. متابعة؟';
  }

  @override
  String get absenceReason => 'سبب الغياب';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get studentActions => 'إجراءات الطالب';

  @override
  String get attachAdd => 'إضافة مرفق';

  @override
  String get attachCamera => 'التقاط صورة';

  @override
  String get attachGallery => 'من معرض الصور';

  @override
  String attachHint(String max) {
    return 'صور أو PDF، حتى $max مرفقات.';
  }

  @override
  String attachmentsCount(String count) {
    return 'المرفقات ($count)';
  }

  @override
  String attachmentsLimit(String max) {
    return 'الحد الأقصى $max مرفقات.';
  }

  @override
  String get download => 'تحميل';
}
