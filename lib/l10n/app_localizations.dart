import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appNameParent.
  ///
  /// In ar, this message translates to:
  /// **'حضانتي'**
  String get appNameParent;

  /// No description provided for @appNameStaff.
  ///
  /// In ar, this message translates to:
  /// **'حضانتي - المشرفات'**
  String get appNameStaff;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'تابِع يوم طفلك لحظة بلحظة'**
  String get tagline;

  /// No description provided for @taglineStaff.
  ///
  /// In ar, this message translates to:
  /// **'يومك مع الأطفال في مكان واحد'**
  String get taglineStaff;

  /// No description provided for @languageSwitch.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageSwitch;

  /// No description provided for @continueLabel.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueLabel;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signIn;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @later.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get later;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginTitle;

  /// No description provided for @loginSubtitleMobile.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الجوال المسجّل لدى الحضانة.'**
  String get loginSubtitleMobile;

  /// No description provided for @loginSubtitlePassword.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بيانات الدخول الخاصة بك.'**
  String get loginSubtitlePassword;

  /// No description provided for @loginSubtitleStaff.
  ///
  /// In ar, this message translates to:
  /// **'ادخلي باسم المستخدم وكلمة المرور كما في لوحة التحكم.'**
  String get loginSubtitleStaff;

  /// No description provided for @mobileLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get mobileLabel;

  /// No description provided for @identifierLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم أو البريد'**
  String get identifierLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get passwordLabel;

  /// No description provided for @smsNote.
  ///
  /// In ar, this message translates to:
  /// **'سنرسل رمز تحقق برسالة نصية إلى هذا الرقم. لا نشارك رقمك مع أحد.'**
  String get smsNote;

  /// No description provided for @notRegistered.
  ///
  /// In ar, this message translates to:
  /// **'رقمك غير مسجّل؟ تواصل مع الحضانة'**
  String get notRegistered;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @forgotTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك المسجّل وسنرسل لك رابط التعيين.'**
  String get forgotSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailLabel;

  /// No description provided for @send.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get send;

  /// No description provided for @forgotSent.
  ///
  /// In ar, this message translates to:
  /// **'إن كان البريد مسجّلاً فستصلك رسالة خلال دقائق.'**
  String get forgotSent;

  /// No description provided for @otpTitle.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المرسل إلى {target}'**
  String otpSubtitle(String target);

  /// No description provided for @otpCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرمز'**
  String get otpCodeLabel;

  /// No description provided for @verify.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get verify;

  /// No description provided for @resend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get resend;

  /// No description provided for @resendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد {seconds} ثانية'**
  String resendIn(int seconds);

  /// No description provided for @otpSent.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رمزاً جديداً.'**
  String get otpSent;

  /// No description provided for @biometricLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدخول بالبصمة'**
  String get biometricLabel;

  /// No description provided for @biometricHint.
  ///
  /// In ar, this message translates to:
  /// **'البصمة مفعّلة لـ {name} — المس زر البصمة للدخول مباشرة'**
  String biometricHint(String name);

  /// No description provided for @biometricPromptTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get biometricPromptTitle;

  /// No description provided for @biometricPromptSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استخدم بصمتك للدخول إلى حسابك'**
  String get biometricPromptSubtitle;

  /// No description provided for @biometricEnableTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الدخول بالبصمة'**
  String get biometricEnableTitle;

  /// No description provided for @biometricEnableBody.
  ///
  /// In ar, this message translates to:
  /// **'ادخل في المرة القادمة ببصمتك بدل كتابة بياناتك. بصمتك لا تغادر جهازك.'**
  String get biometricEnableBody;

  /// No description provided for @biometricEnableAction.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل البصمة'**
  String get biometricEnableAction;

  /// No description provided for @biometricEnabled.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل الدخول بالبصمة على هذا الجهاز.'**
  String get biometricEnabled;

  /// No description provided for @biometricDisabled.
  ///
  /// In ar, this message translates to:
  /// **'أوقفنا الدخول بالبصمة على هذا الجهاز.'**
  String get biometricDisabled;

  /// No description provided for @biometricFailedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التحقق من البصمة'**
  String get biometricFailedTitle;

  /// No description provided for @biometricRetry.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى أو ادخل بالطريقة المعتادة.'**
  String get biometricRetry;

  /// No description provided for @biometricRevoked.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي الدخول بالبصمة على هذا الجهاز. سجّل الدخول بالطريقة المعتادة.'**
  String get biometricRevoked;

  /// No description provided for @biometricLocked.
  ///
  /// In ar, this message translates to:
  /// **'أُقفلت البصمة مؤقتاً بعد محاولات كثيرة. ادخل بالطريقة المعتادة.'**
  String get biometricLocked;

  /// No description provided for @biometricNotEnrolled.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بصمة مسجّلة على هذا الجهاز. سجّلها من إعدادات الجهاز أولاً.'**
  String get biometricNotEnrolled;

  /// No description provided for @biometricUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'هذا الجهاز لا يدعم الدخول بالبصمة.'**
  String get biometricUnavailable;

  /// No description provided for @biometricReauth.
  ///
  /// In ar, this message translates to:
  /// **'لتفعيل البصمة أعد تسجيل الدخول أولاً.'**
  String get biometricReauth;

  /// No description provided for @networkError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال بالخادم. تحقّق من الإنترنت ثم أعد المحاولة.'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. حاول مرة أخرى.'**
  String get serverError;

  /// No description provided for @configMissing.
  ///
  /// In ar, this message translates to:
  /// **'لم يُضبط مفتاح التطبيق. شغّل التطبيق مع ‎--dart-define‎ للمفاتيح.'**
  String get configMissing;

  /// No description provided for @maintenanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق تحت الصيانة'**
  String get maintenanceTitle;

  /// No description provided for @maintenanceBody.
  ///
  /// In ar, this message translates to:
  /// **'نعمل على تحسينات سريعة. حاول بعد قليل.'**
  String get maintenanceBody;

  /// No description provided for @updateTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدّث التطبيق'**
  String get updateTitle;

  /// No description provided for @updateBody.
  ///
  /// In ar, this message translates to:
  /// **'هذه النسخة لم تعد مدعومة. حدّث التطبيق للمتابعة.'**
  String get updateBody;

  /// No description provided for @updateAction.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الآن'**
  String get updateAction;

  /// No description provided for @accountBlockedTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحساب موقوف عن التطبيق'**
  String get accountBlockedTitle;

  /// No description provided for @accountBlockedBody.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع إدارة الحضانة لمعرفة التفاصيل.'**
  String get accountBlockedBody;

  /// No description provided for @accountInactiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحساب غير نشِط'**
  String get accountInactiveTitle;

  /// No description provided for @accountInactiveBody.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع إدارة الحضانة لتفعيل حسابك.'**
  String get accountInactiveBody;

  /// No description provided for @tooManyTitle.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة'**
  String get tooManyTitle;

  /// No description provided for @tooManyBody.
  ///
  /// In ar, this message translates to:
  /// **'حاول بعد {minutes} دقيقة.'**
  String tooManyBody(int minutes);

  /// No description provided for @smsUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'خدمة الرسائل غير متاحة حالياً. تواصل مع الحضانة.'**
  String get smsUnavailable;

  /// No description provided for @otpUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد بريد مسجّل لحسابك لإرسال الرمز. تواصل مع الإدارة.'**
  String get otpUnavailable;

  /// No description provided for @sessionExpiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة'**
  String get sessionExpiredTitle;

  /// No description provided for @sessionExpiredBody.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول من جديد للمتابعة.'**
  String get sessionExpiredBody;

  /// No description provided for @signOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get signOut;

  /// No description provided for @signOutForget.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج وإيقاف البصمة'**
  String get signOutForget;

  /// No description provided for @staffReplacedDevices.
  ///
  /// In ar, this message translates to:
  /// **'تم إخراج جهازك السابق — تطبيق المشرفات يعمل على جهاز واحد.'**
  String get staffReplacedDevices;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً {name}'**
  String welcome(String name);

  /// No description provided for @homeParentTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get homeParentTitle;

  /// No description provided for @homeStaffTitle.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get homeStaffTitle;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'بقية الشاشات قيد البناء.'**
  String get comingSoon;

  /// No description provided for @securitySettings.
  ///
  /// In ar, this message translates to:
  /// **'الأمان والبصمة'**
  String get securitySettings;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navActivities.
  ///
  /// In ar, this message translates to:
  /// **'الأنشطة'**
  String get navActivities;

  /// No description provided for @navPayments.
  ///
  /// In ar, this message translates to:
  /// **'المدفوعات'**
  String get navPayments;

  /// No description provided for @navNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get navNotifications;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// No description provided for @navToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get navToday;

  /// No description provided for @navStudents.
  ///
  /// In ar, this message translates to:
  /// **'الطلاب'**
  String get navStudents;

  /// No description provided for @statusPresent.
  ///
  /// In ar, this message translates to:
  /// **'حاضر الآن'**
  String get statusPresent;

  /// No description provided for @statusCheckedOut.
  ///
  /// In ar, this message translates to:
  /// **'انصرف'**
  String get statusCheckedOut;

  /// No description provided for @statusAbsent.
  ///
  /// In ar, this message translates to:
  /// **'غائب اليوم'**
  String get statusAbsent;

  /// No description provided for @statusClosed.
  ///
  /// In ar, this message translates to:
  /// **'اليوم عطلة'**
  String get statusClosed;

  /// No description provided for @statusNotArrived.
  ///
  /// In ar, this message translates to:
  /// **'لم يصل بعد'**
  String get statusNotArrived;

  /// No description provided for @arrivedAt.
  ///
  /// In ar, this message translates to:
  /// **'وصل {time}'**
  String arrivedAt(String time);

  /// No description provided for @leftAt.
  ///
  /// In ar, this message translates to:
  /// **'انصرف {time}'**
  String leftAt(String time);

  /// No description provided for @childCard.
  ///
  /// In ar, this message translates to:
  /// **'ملف الطفل'**
  String get childCard;

  /// No description provided for @pendingTitle.
  ///
  /// In ar, this message translates to:
  /// **'بانتظارك'**
  String get pendingTitle;

  /// No description provided for @payNow.
  ///
  /// In ar, this message translates to:
  /// **'ادفع الآن'**
  String get payNow;

  /// No description provided for @acknowledge.
  ///
  /// In ar, this message translates to:
  /// **'اطّلعت'**
  String get acknowledge;

  /// No description provided for @acknowledged.
  ///
  /// In ar, this message translates to:
  /// **'تم الاطلاع'**
  String get acknowledged;

  /// No description provided for @needsAck.
  ///
  /// In ar, this message translates to:
  /// **'تعميم يحتاج موافقتك'**
  String get needsAck;

  /// No description provided for @dueOn.
  ///
  /// In ar, this message translates to:
  /// **'مستحقة {date}'**
  String dueOn(String date);

  /// No description provided for @overdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخرة'**
  String get overdue;

  /// No description provided for @servicesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات'**
  String get servicesTitle;

  /// No description provided for @serviceAttendance.
  ///
  /// In ar, this message translates to:
  /// **'الحضور'**
  String get serviceAttendance;

  /// No description provided for @serviceInvoices.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير'**
  String get serviceInvoices;

  /// No description provided for @serviceCirculars.
  ///
  /// In ar, this message translates to:
  /// **'التعاميم'**
  String get serviceCirculars;

  /// No description provided for @serviceEvents.
  ///
  /// In ar, this message translates to:
  /// **'الفعاليات'**
  String get serviceEvents;

  /// No description provided for @serviceCoupons.
  ///
  /// In ar, this message translates to:
  /// **'قسائمي'**
  String get serviceCoupons;

  /// No description provided for @todayActivity.
  ///
  /// In ar, this message translates to:
  /// **'نشاط اليوم'**
  String get todayActivity;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @noActivityYet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد نشاط منشور بعد.'**
  String get noActivityYet;

  /// No description provided for @activitiesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأنشطة'**
  String get activitiesTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @invoicesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير'**
  String get invoicesTitle;

  /// No description provided for @circularsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التعاميم'**
  String get circularsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تعليم الكل كمقروء'**
  String get markAllRead;

  /// No description provided for @emptyList.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد شيء هنا بعد.'**
  String get emptyList;

  /// No description provided for @loadMore.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get loadMore;

  /// No description provided for @invoiceNumber.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة رقم {number}'**
  String invoiceNumber(String number);

  /// No description provided for @invoiceItems.
  ///
  /// In ar, this message translates to:
  /// **'بنود الفاتورة'**
  String get invoiceItems;

  /// No description provided for @attendanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحضور اليوم'**
  String get attendanceTitle;

  /// No description provided for @statExpected.
  ///
  /// In ar, this message translates to:
  /// **'متوقّع'**
  String get statExpected;

  /// No description provided for @statIn.
  ///
  /// In ar, this message translates to:
  /// **'حضر'**
  String get statIn;

  /// No description provided for @statOut.
  ///
  /// In ar, this message translates to:
  /// **'انصرف'**
  String get statOut;

  /// No description provided for @statAbsent.
  ///
  /// In ar, this message translates to:
  /// **'غائب'**
  String get statAbsent;

  /// No description provided for @statRemaining.
  ///
  /// In ar, this message translates to:
  /// **'متبقٍ'**
  String get statRemaining;

  /// No description provided for @activitiesBoard.
  ///
  /// In ar, this message translates to:
  /// **'الأنشطة'**
  String get activitiesBoard;

  /// No description provided for @statAdded.
  ///
  /// In ar, this message translates to:
  /// **'أُضيف'**
  String get statAdded;

  /// No description provided for @statPublished.
  ///
  /// In ar, this message translates to:
  /// **'منشور'**
  String get statPublished;

  /// No description provided for @statMissing.
  ///
  /// In ar, this message translates to:
  /// **'ناقص'**
  String get statMissing;

  /// No description provided for @windowOpenNow.
  ///
  /// In ar, this message translates to:
  /// **'نافذة إضافة الأنشطة مفتوحة الآن.'**
  String get windowOpenNow;

  /// No description provided for @windowOpensIn.
  ///
  /// In ar, this message translates to:
  /// **'يُفتح بعد'**
  String get windowOpensIn;

  /// No description provided for @windowClosesIn.
  ///
  /// In ar, this message translates to:
  /// **'يُغلق بعد'**
  String get windowClosesIn;

  /// No description provided for @windowUpdating.
  ///
  /// In ar, this message translates to:
  /// **'يجري تحديث حالة النافذة…'**
  String get windowUpdating;

  /// No description provided for @windowHoursNote.
  ///
  /// In ar, this message translates to:
  /// **'ساعات الإضافة {hours}'**
  String windowHoursNote(String hours);

  /// No description provided for @windowReopensAt.
  ///
  /// In ar, this message translates to:
  /// **'يُعاد الفتح الساعة {time}'**
  String windowReopensAt(String time);

  /// No description provided for @windowClosesAt.
  ///
  /// In ar, this message translates to:
  /// **'يُغلق الساعة {time}'**
  String windowClosesAt(String time);

  /// No description provided for @pickStudent.
  ///
  /// In ar, this message translates to:
  /// **'اختر طالباً'**
  String get pickStudent;

  /// No description provided for @windowClosed.
  ///
  /// In ar, this message translates to:
  /// **'نافذة إضافة الأنشطة مغلقة الآن.'**
  String get windowClosed;

  /// No description provided for @studentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الطلاب'**
  String get studentsTitle;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم'**
  String get searchHint;

  /// No description provided for @scanTitle.
  ///
  /// In ar, this message translates to:
  /// **'مسح البطاقة'**
  String get scanTitle;

  /// No description provided for @attendanceMonthTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحضور والغياب'**
  String get attendanceMonthTitle;

  /// No description provided for @attendanceRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الحضور {rate}%'**
  String attendanceRate(String rate);

  /// No description provided for @schoolDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام الدراسة'**
  String get schoolDays;

  /// No description provided for @absentDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام الغياب'**
  String get absentDays;

  /// No description provided for @excusedDays.
  ///
  /// In ar, this message translates to:
  /// **'بعذر'**
  String get excusedDays;

  /// No description provided for @unexcusedDays.
  ///
  /// In ar, this message translates to:
  /// **'بلا عذر'**
  String get unexcusedDays;

  /// No description provided for @reportAbsence.
  ///
  /// In ar, this message translates to:
  /// **'بلّغ عن غياب'**
  String get reportAbsence;

  /// No description provided for @absenceFrom.
  ///
  /// In ar, this message translates to:
  /// **'من تاريخ'**
  String get absenceFrom;

  /// No description provided for @absenceTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى تاريخ'**
  String get absenceTo;

  /// No description provided for @absenceNote.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get absenceNote;

  /// No description provided for @absenceSaved.
  ///
  /// In ar, this message translates to:
  /// **'سجّلنا البلاغ.'**
  String get absenceSaved;

  /// No description provided for @absenceCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء البلاغ'**
  String get absenceCancel;

  /// No description provided for @absenceCancelled.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي البلاغ.'**
  String get absenceCancelled;

  /// No description provided for @upcomingAbsences.
  ///
  /// In ar, this message translates to:
  /// **'بلاغات قادمة'**
  String get upcomingAbsences;

  /// No description provided for @notesTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات المعلّمة'**
  String get notesTitle;

  /// No description provided for @devicesTitle.
  ///
  /// In ar, this message translates to:
  /// **'أجهزتي'**
  String get devicesTitle;

  /// No description provided for @deviceCurrent.
  ///
  /// In ar, this message translates to:
  /// **'هذا الجهاز'**
  String get deviceCurrent;

  /// No description provided for @deviceSignOut.
  ///
  /// In ar, this message translates to:
  /// **'إخراج الجهاز'**
  String get deviceSignOut;

  /// No description provided for @deviceSignedOut.
  ///
  /// In ar, this message translates to:
  /// **'أُخرج الجهاز.'**
  String get deviceSignedOut;

  /// No description provided for @lastUsed.
  ///
  /// In ar, this message translates to:
  /// **'آخر استخدام {time}'**
  String lastUsed(String time);

  /// No description provided for @staffAttendanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'حضور اليوم'**
  String get staffAttendanceTitle;

  /// No description provided for @markAbsentAction.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل غياب من لم يصل'**
  String get markAbsentAction;

  /// No description provided for @markAbsentConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيُسجّل غياب كل من لم يصل اليوم. متابعة؟'**
  String get markAbsentConfirm;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @filterNotArrived.
  ///
  /// In ar, this message translates to:
  /// **'لم يصل'**
  String get filterNotArrived;

  /// No description provided for @filterPresent.
  ///
  /// In ar, this message translates to:
  /// **'حاضر'**
  String get filterPresent;

  /// No description provided for @filterAbsent.
  ///
  /// In ar, this message translates to:
  /// **'غائب'**
  String get filterAbsent;

  /// No description provided for @selectChild.
  ///
  /// In ar, this message translates to:
  /// **'اختر الطفل'**
  String get selectChild;

  /// No description provided for @pickDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get pickDate;

  /// No description provided for @eventsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفعاليات'**
  String get eventsTitle;

  /// No description provided for @bookingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتي'**
  String get bookingsTitle;

  /// No description provided for @seatsLeft.
  ///
  /// In ar, this message translates to:
  /// **'{count} مقعد متبقٍ'**
  String seatsLeft(String count);

  /// No description provided for @priceFrom.
  ///
  /// In ar, this message translates to:
  /// **'تبدأ من {price}'**
  String priceFrom(String price);

  /// No description provided for @eventProgram.
  ///
  /// In ar, this message translates to:
  /// **'البرنامج'**
  String get eventProgram;

  /// No description provided for @eventChildren.
  ///
  /// In ar, this message translates to:
  /// **'الأبناء'**
  String get eventChildren;

  /// No description provided for @eligible.
  ///
  /// In ar, this message translates to:
  /// **'مؤهّل للحجز'**
  String get eligible;

  /// No description provided for @notEligible.
  ///
  /// In ar, this message translates to:
  /// **'غير مؤهّل'**
  String get notEligible;

  /// No description provided for @booked.
  ///
  /// In ar, this message translates to:
  /// **'محجوز'**
  String get booked;

  /// No description provided for @bookingSoon.
  ///
  /// In ar, this message translates to:
  /// **'الحجز من التطبيق قيد الإضافة.'**
  String get bookingSoon;

  /// No description provided for @participantsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مشارك'**
  String participantsCount(String count);

  /// No description provided for @cancelBooking.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز'**
  String get cancelBooking;

  /// No description provided for @bookingCancelled.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي الحجز.'**
  String get bookingCancelled;

  /// No description provided for @cancelBookingConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيُلغى هذا الحجز. متابعة؟'**
  String get cancelBookingConfirm;

  /// No description provided for @staffActivitiesTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنشطة الطلاب'**
  String get staffActivitiesTitle;

  /// No description provided for @addActivity.
  ///
  /// In ar, this message translates to:
  /// **'إضافة نشاط'**
  String get addActivity;

  /// No description provided for @activityFor.
  ///
  /// In ar, this message translates to:
  /// **'نشاط {name}'**
  String activityFor(String name);

  /// No description provided for @activityDay.
  ///
  /// In ar, this message translates to:
  /// **'يوم النشاط {date}'**
  String activityDay(String date);

  /// No description provided for @activityNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة المعلّمة'**
  String get activityNote;

  /// No description provided for @activityTemplates.
  ///
  /// In ar, this message translates to:
  /// **'رسائل جاهزة'**
  String get activityTemplates;

  /// No description provided for @publishNow.
  ///
  /// In ar, this message translates to:
  /// **'نشر مباشرة'**
  String get publishNow;

  /// No description provided for @saveActivity.
  ///
  /// In ar, this message translates to:
  /// **'حفظ النشاط'**
  String get saveActivity;

  /// No description provided for @activitySaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ النشاط.'**
  String get activitySaved;

  /// No description provided for @activityExists.
  ///
  /// In ar, this message translates to:
  /// **'لهذا الطالب نشاط في هذا اليوم.'**
  String get activityExists;

  /// No description provided for @activityBlocked.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن إضافة نشاط الآن.'**
  String get activityBlocked;

  /// No description provided for @filterUnpublished.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار النشر'**
  String get filterUnpublished;

  /// No description provided for @filterPublished.
  ///
  /// In ar, this message translates to:
  /// **'منشور'**
  String get filterPublished;

  /// No description provided for @publish.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get publish;

  /// No description provided for @published.
  ///
  /// In ar, this message translates to:
  /// **'نُشر'**
  String get published;

  /// No description provided for @publishAll.
  ///
  /// In ar, this message translates to:
  /// **'نشر الكل'**
  String get publishAll;

  /// No description provided for @publishedCount.
  ///
  /// In ar, this message translates to:
  /// **'نُشر {count} نشاطاً.'**
  String publishedCount(String count);

  /// No description provided for @addedBy.
  ///
  /// In ar, this message translates to:
  /// **'أضافه {name}'**
  String addedBy(String name);

  /// No description provided for @missingActivity.
  ///
  /// In ar, this message translates to:
  /// **'بلا نشاط'**
  String get missingActivity;

  /// No description provided for @hrTitle.
  ///
  /// In ar, this message translates to:
  /// **'خدماتي'**
  String get hrTitle;

  /// No description provided for @hrPresentDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام الحضور'**
  String get hrPresentDays;

  /// No description provided for @hrAbsentDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام الغياب'**
  String get hrAbsentDays;

  /// No description provided for @hrLeaveDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام الإجازة'**
  String get hrLeaveDays;

  /// No description provided for @hrLateMinutes.
  ///
  /// In ar, this message translates to:
  /// **'دقائق التأخير'**
  String get hrLateMinutes;

  /// No description provided for @hrBalances.
  ///
  /// In ar, this message translates to:
  /// **'أرصدة الإجازات'**
  String get hrBalances;

  /// No description provided for @leavesTitle.
  ///
  /// In ar, this message translates to:
  /// **'إجازاتي'**
  String get leavesTitle;

  /// No description provided for @newLeave.
  ///
  /// In ar, this message translates to:
  /// **'طلب إجازة'**
  String get newLeave;

  /// No description provided for @leaveType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الإجازة'**
  String get leaveType;

  /// No description provided for @leaveReason.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get leaveReason;

  /// No description provided for @leaveDaysCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String leaveDaysCount(String count);

  /// No description provided for @leaveSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل الطلب.'**
  String get leaveSubmitted;

  /// No description provided for @withdraw.
  ///
  /// In ar, this message translates to:
  /// **'سحب الطلب'**
  String get withdraw;

  /// No description provided for @withdrawn.
  ///
  /// In ar, this message translates to:
  /// **'سُحب الطلب.'**
  String get withdrawn;

  /// No description provided for @violationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مخالفاتي'**
  String get violationsTitle;

  /// No description provided for @justify.
  ///
  /// In ar, this message translates to:
  /// **'تبرير'**
  String get justify;

  /// No description provided for @justification.
  ///
  /// In ar, this message translates to:
  /// **'التبرير'**
  String get justification;

  /// No description provided for @justifySent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل التبرير.'**
  String get justifySent;

  /// No description provided for @decisionDeadline.
  ///
  /// In ar, this message translates to:
  /// **'آخر موعد {date}'**
  String decisionDeadline(String date);

  /// No description provided for @minutesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} دقيقة'**
  String minutesCount(String count);

  /// No description provided for @balanceDays.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم متبقٍ'**
  String balanceDays(String count);

  /// No description provided for @paymentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مدفوعاتي'**
  String get paymentsTitle;

  /// No description provided for @paymentOpen.
  ///
  /// In ar, this message translates to:
  /// **'افتح صفحة الدفع'**
  String get paymentOpen;

  /// No description provided for @paymentOpened.
  ///
  /// In ar, this message translates to:
  /// **'فُتحت صفحة الدفع في المتصفح. بعد إتمامها ارجع هنا واضغط «تحقّق من الحالة».'**
  String get paymentOpened;

  /// No description provided for @paymentCheck.
  ///
  /// In ar, this message translates to:
  /// **'تحقّق من الحالة'**
  String get paymentCheck;

  /// No description provided for @paymentPaid.
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع بنجاح.'**
  String get paymentPaid;

  /// No description provided for @paymentFailed.
  ///
  /// In ar, this message translates to:
  /// **'لم تكتمل عملية الدفع.'**
  String get paymentFailed;

  /// No description provided for @paymentPending.
  ///
  /// In ar, this message translates to:
  /// **'العملية قيد التنفيذ.'**
  String get paymentPending;

  /// No description provided for @receipt.
  ///
  /// In ar, this message translates to:
  /// **'الإيصال'**
  String get receipt;

  /// No description provided for @invoicesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} فاتورة'**
  String invoicesCount(String count);

  /// No description provided for @cannotOpenLink.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح الرابط.'**
  String get cannotOpenLink;

  /// No description provided for @hrAttendanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل حضوري'**
  String get hrAttendanceTitle;

  /// No description provided for @correctionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات التصحيح'**
  String get correctionsTitle;

  /// No description provided for @newCorrection.
  ///
  /// In ar, this message translates to:
  /// **'طلب تصحيح'**
  String get newCorrection;

  /// No description provided for @correctionKind.
  ///
  /// In ar, this message translates to:
  /// **'نوع البصمة'**
  String get correctionKind;

  /// No description provided for @correctionIn.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get correctionIn;

  /// No description provided for @correctionOut.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get correctionOut;

  /// No description provided for @correctionTime.
  ///
  /// In ar, this message translates to:
  /// **'الوقت الصحيح'**
  String get correctionTime;

  /// No description provided for @correctionReason.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get correctionReason;

  /// No description provided for @correctionSent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل طلب التصحيح.'**
  String get correctionSent;

  /// No description provided for @expectedHours.
  ///
  /// In ar, this message translates to:
  /// **'الدوام {from} - {to}'**
  String expectedHours(String from, String to);

  /// No description provided for @lateBy.
  ///
  /// In ar, this message translates to:
  /// **'تأخير {count} د'**
  String lateBy(String count);

  /// No description provided for @earlyBy.
  ///
  /// In ar, this message translates to:
  /// **'خروج مبكر {count} د'**
  String earlyBy(String count);

  /// No description provided for @requestCorrectionForDay.
  ///
  /// In ar, this message translates to:
  /// **'اطلب تصحيحاً لهذا اليوم'**
  String get requestCorrectionForDay;

  /// No description provided for @absencesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الغياب'**
  String get absencesTitle;

  /// No description provided for @couponsTitle.
  ///
  /// In ar, this message translates to:
  /// **'قسائمي'**
  String get couponsTitle;

  /// No description provided for @subscriptionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات'**
  String get subscriptionsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'بياناتي'**
  String get profileTitle;

  /// No description provided for @nameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get nameLabel;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveChanges;

  /// No description provided for @profileSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت بياناتك.'**
  String get profileSaved;

  /// No description provided for @currentPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get currentPassword;

  /// No description provided for @currentPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'مطلوبة لتغيير البريد.'**
  String get currentPasswordHint;

  /// No description provided for @resetPassword.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get resetPassword;

  /// No description provided for @resetPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'سنرسل رابط التعيين إلى بريدك المسجّل.'**
  String get resetPasswordHint;

  /// No description provided for @couponValue.
  ///
  /// In ar, this message translates to:
  /// **'خصم {value}'**
  String couponValue(String value);

  /// No description provided for @couponEnds.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي {date}'**
  String couponEnds(String date);

  /// No description provided for @couponFor.
  ///
  /// In ar, this message translates to:
  /// **'لـ {names}'**
  String couponFor(String names);

  /// No description provided for @subscriptionPeriod.
  ///
  /// In ar, this message translates to:
  /// **'{from} إلى {to}'**
  String subscriptionPeriod(String from, String to);

  /// No description provided for @daysLeft.
  ///
  /// In ar, this message translates to:
  /// **'باقٍ {count} يوم'**
  String daysLeft(String count);

  /// No description provided for @currentSubscription.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراك الحالي'**
  String get currentSubscription;

  /// No description provided for @requestStop.
  ///
  /// In ar, this message translates to:
  /// **'طلب إيقاف الاشتراك'**
  String get requestStop;

  /// No description provided for @requestStopReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإيقاف'**
  String get requestStopReason;

  /// No description provided for @requestStopSent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل الطلب إلى الإدارة.'**
  String get requestStopSent;

  /// No description provided for @noChildSelected.
  ///
  /// In ar, this message translates to:
  /// **'اختر الطفل أولاً'**
  String get noChildSelected;

  /// No description provided for @documentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مستندات الطفل'**
  String get documentsTitle;

  /// No description provided for @documentsMissing.
  ///
  /// In ar, this message translates to:
  /// **'ناقصة'**
  String get documentsMissing;

  /// No description provided for @documentsExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهية'**
  String get documentsExpired;

  /// No description provided for @documentsExpiring.
  ///
  /// In ar, this message translates to:
  /// **'قاربت الانتهاء'**
  String get documentsExpiring;

  /// No description provided for @documentOpen.
  ///
  /// In ar, this message translates to:
  /// **'فتح المستند'**
  String get documentOpen;

  /// No description provided for @cardTitle.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة الطفل'**
  String get cardTitle;

  /// No description provided for @cardHint.
  ///
  /// In ar, this message translates to:
  /// **'اعرض هذا الرمز عند البوابة لتسجيل الحضور والانصراف.'**
  String get cardHint;

  /// No description provided for @weeklyTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملخص الأسبوعي'**
  String get weeklyTitle;

  /// No description provided for @weeklyPresent.
  ///
  /// In ar, this message translates to:
  /// **'أيام حضور'**
  String get weeklyPresent;

  /// No description provided for @weeklyAbsent.
  ///
  /// In ar, this message translates to:
  /// **'أيام غياب'**
  String get weeklyAbsent;

  /// No description provided for @weeklyActivities.
  ///
  /// In ar, this message translates to:
  /// **'أنشطة'**
  String get weeklyActivities;

  /// No description provided for @mediaConsent.
  ///
  /// In ar, this message translates to:
  /// **'الموافقة على نشر الصور'**
  String get mediaConsent;

  /// No description provided for @mediaConsentOn.
  ///
  /// In ar, this message translates to:
  /// **'مفعّلة'**
  String get mediaConsentOn;

  /// No description provided for @mediaConsentOff.
  ///
  /// In ar, this message translates to:
  /// **'موقوفة'**
  String get mediaConsentOff;

  /// No description provided for @studentTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملف الطالب'**
  String get studentTitle;

  /// No description provided for @addNote.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ملاحظة'**
  String get addNote;

  /// No description provided for @notePositive.
  ///
  /// In ar, this message translates to:
  /// **'إيجابية'**
  String get notePositive;

  /// No description provided for @noteNegative.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج متابعة'**
  String get noteNegative;

  /// No description provided for @noteShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركتها مع ولي الأمر'**
  String get noteShare;

  /// No description provided for @noteSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت الملاحظة.'**
  String get noteSaved;

  /// No description provided for @markAbsent.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل غياب'**
  String get markAbsent;

  /// No description provided for @absenceExcused.
  ///
  /// In ar, this message translates to:
  /// **'بعذر'**
  String get absenceExcused;

  /// No description provided for @absenceUnexcused.
  ///
  /// In ar, this message translates to:
  /// **'بلا عذر'**
  String get absenceUnexcused;

  /// No description provided for @absenceSavedStaff.
  ///
  /// In ar, this message translates to:
  /// **'سُجّل الغياب.'**
  String get absenceSavedStaff;

  /// No description provided for @parentsLabel.
  ///
  /// In ar, this message translates to:
  /// **'أولياء الأمر'**
  String get parentsLabel;

  /// No description provided for @teachersLabel.
  ///
  /// In ar, this message translates to:
  /// **'المعلّمات'**
  String get teachersLabel;

  /// No description provided for @bookNow.
  ///
  /// In ar, this message translates to:
  /// **'احجز الآن'**
  String get bookNow;

  /// No description provided for @bookingTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجز الفعالية'**
  String get bookingTitle;

  /// No description provided for @participants.
  ///
  /// In ar, this message translates to:
  /// **'المشاركون'**
  String get participants;

  /// No description provided for @bookingContact.
  ///
  /// In ar, this message translates to:
  /// **'بيانات التواصل'**
  String get bookingContact;

  /// No description provided for @bookingAnswers.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الحجز'**
  String get bookingAnswers;

  /// No description provided for @bookingAddons.
  ///
  /// In ar, this message translates to:
  /// **'الإضافات'**
  String get bookingAddons;

  /// No description provided for @previewBooking.
  ///
  /// In ar, this message translates to:
  /// **'معاينة المبلغ'**
  String get previewBooking;

  /// No description provided for @bookingTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي {total}'**
  String bookingTotal(String total);

  /// No description provided for @bookingDiscount.
  ///
  /// In ar, this message translates to:
  /// **'الخصم {amount}'**
  String bookingDiscount(String amount);

  /// No description provided for @willWait.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مقاعد كافية — سيدخل الحجز قائمة الانتظار.'**
  String get willWait;

  /// No description provided for @consentText.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على شروط المشاركة في الفعالية.'**
  String get consentText;

  /// No description provided for @confirmBooking.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحجز'**
  String get confirmBooking;

  /// No description provided for @bookingCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم الحجز.'**
  String get bookingCreated;

  /// No description provided for @payBooking.
  ///
  /// In ar, this message translates to:
  /// **'ادفع الحجز'**
  String get payBooking;

  /// No description provided for @fileFieldWeb.
  ///
  /// In ar, this message translates to:
  /// **'هذا النموذج يطلب مرفقاً — أكمل الحجز من موقع الحضانة.'**
  String get fileFieldWeb;

  /// No description provided for @selectAtLeastOne.
  ///
  /// In ar, this message translates to:
  /// **'اختر مشاركاً واحداً على الأقل.'**
  String get selectAtLeastOne;

  /// No description provided for @quantity.
  ///
  /// In ar, this message translates to:
  /// **'العدد'**
  String get quantity;

  /// No description provided for @scanIn.
  ///
  /// In ar, this message translates to:
  /// **'مسح الحضور'**
  String get scanIn;

  /// No description provided for @scanOut.
  ///
  /// In ar, this message translates to:
  /// **'مسح الانصراف'**
  String get scanOut;

  /// No description provided for @scanAgain.
  ///
  /// In ar, this message translates to:
  /// **'مسح بطاقة أخرى'**
  String get scanAgain;

  /// No description provided for @scanMode.
  ///
  /// In ar, this message translates to:
  /// **'نوع المسح'**
  String get scanMode;

  /// No description provided for @scanCancelled.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي المسح.'**
  String get scanCancelled;

  /// No description provided for @scanUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا غير متاحة على هذا الجهاز.'**
  String get scanUnavailable;

  /// No description provided for @scanCardUnknown.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة غير معروفة.'**
  String get scanCardUnknown;

  /// No description provided for @attachFile.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق ملف'**
  String get attachFile;

  /// No description provided for @attachmentRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا النوع يتطلب مرفقاً.'**
  String get attachmentRequired;

  /// No description provided for @removeAttachment.
  ///
  /// In ar, this message translates to:
  /// **'إزالة المرفق'**
  String get removeAttachment;

  /// No description provided for @addDocument.
  ///
  /// In ar, this message translates to:
  /// **'رفع مستند'**
  String get addDocument;

  /// No description provided for @documentTitle.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستند'**
  String get documentTitle;

  /// No description provided for @documentExpires.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء (اختياري)'**
  String get documentExpires;

  /// No description provided for @documentUploaded.
  ///
  /// In ar, this message translates to:
  /// **'رُفع المستند.'**
  String get documentUploaded;

  /// No description provided for @uploading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الرفع…'**
  String get uploading;

  /// No description provided for @errorNotFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'غير موجود'**
  String get errorNotFoundTitle;

  /// No description provided for @errorNotFoundBody.
  ///
  /// In ar, this message translates to:
  /// **'لم نجد ما تبحث عنه. ربما حُذف أو تغيّر.'**
  String get errorNotFoundBody;

  /// No description provided for @errorForbiddenTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا تملك صلاحية'**
  String get errorForbiddenTitle;

  /// No description provided for @errorForbiddenBody.
  ///
  /// In ar, this message translates to:
  /// **'هذه الصفحة غير متاحة لحسابك. تواصل مع إدارة الحضانة.'**
  String get errorForbiddenBody;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال'**
  String get errorNetworkTitle;

  /// No description provided for @errorServerTitle.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الخادم'**
  String get errorServerTitle;

  /// No description provided for @errorServerBody.
  ///
  /// In ar, this message translates to:
  /// **'حدث خلل مؤقت عندنا. حاول بعد قليل.'**
  String get errorServerBody;

  /// No description provided for @errorValidationTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحقّق من البيانات'**
  String get errorValidationTitle;

  /// No description provided for @errorSessionTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة'**
  String get errorSessionTitle;

  /// No description provided for @errorDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل فنية'**
  String get errorDetails;

  /// No description provided for @retryIn.
  ///
  /// In ar, this message translates to:
  /// **'حاول بعد {seconds} ثانية'**
  String retryIn(String seconds);

  /// No description provided for @goBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get goBack;

  /// No description provided for @errorConflictTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إتمام العملية'**
  String get errorConflictTitle;

  /// No description provided for @errorConfigTitle.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إعداد التطبيق'**
  String get errorConfigTitle;

  /// No description provided for @errorConfigBody.
  ///
  /// In ar, this message translates to:
  /// **'مفاتيح الاتصال بالخادم غير صحيحة. أبلغ المطوّر.'**
  String get errorConfigBody;

  /// No description provided for @errorReauthTitle.
  ///
  /// In ar, this message translates to:
  /// **'أعد تسجيل الدخول'**
  String get errorReauthTitle;

  /// No description provided for @errorTooLargeTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف كبير'**
  String get errorTooLargeTitle;

  /// No description provided for @errorDemoTitle.
  ///
  /// In ar, this message translates to:
  /// **'نسخة تجربة'**
  String get errorDemoTitle;

  /// No description provided for @errorGatewayTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال ببوابة الدفع'**
  String get errorGatewayTitle;

  /// No description provided for @errorCardTitle.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة غير معروفة'**
  String get errorCardTitle;

  /// No description provided for @errorAccountBlockedTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحساب موقوف'**
  String get errorAccountBlockedTitle;

  /// No description provided for @errorAccountInactiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحساب غير نشِط'**
  String get errorAccountInactiveTitle;

  /// No description provided for @cardFront.
  ///
  /// In ar, this message translates to:
  /// **'الوجه الأمامي'**
  String get cardFront;

  /// No description provided for @cardBack.
  ///
  /// In ar, this message translates to:
  /// **'الوجه الخلفي'**
  String get cardBack;

  /// No description provided for @cardDownload.
  ///
  /// In ar, this message translates to:
  /// **'تحميل البطاقة'**
  String get cardDownload;

  /// No description provided for @cardSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت البطاقة'**
  String get cardSaved;

  /// No description provided for @cardSaveCancelled.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي الحفظ'**
  String get cardSaveCancelled;

  /// No description provided for @cardSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إنشاء صورة البطاقة'**
  String get cardSaveFailed;

  /// No description provided for @minLengthHint.
  ///
  /// In ar, this message translates to:
  /// **'{count} أحرف على الأقل'**
  String minLengthHint(String count);

  /// No description provided for @payslipsTitle.
  ///
  /// In ar, this message translates to:
  /// **'راتبي'**
  String get payslipsTitle;

  /// No description provided for @payslipsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد قسائم رواتب معتمدة بعد.'**
  String get payslipsEmpty;

  /// No description provided for @payslipTitle.
  ///
  /// In ar, this message translates to:
  /// **'قسيمة الراتب'**
  String get payslipTitle;

  /// No description provided for @payslipLast.
  ///
  /// In ar, this message translates to:
  /// **'آخر راتب'**
  String get payslipLast;

  /// No description provided for @payslipNet.
  ///
  /// In ar, this message translates to:
  /// **'الصافي'**
  String get payslipNet;

  /// No description provided for @payslipGross.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get payslipGross;

  /// No description provided for @payslipDeductions.
  ///
  /// In ar, this message translates to:
  /// **'الاستقطاعات'**
  String get payslipDeductions;

  /// No description provided for @payslipEarnings.
  ///
  /// In ar, this message translates to:
  /// **'الاستحقاقات'**
  String get payslipEarnings;

  /// No description provided for @payslipBasic.
  ///
  /// In ar, this message translates to:
  /// **'الراتب الأساسي'**
  String get payslipBasic;

  /// No description provided for @payslipUnpaidDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام بلا أجر'**
  String get payslipUnpaidDays;

  /// No description provided for @payslipOvertime.
  ///
  /// In ar, this message translates to:
  /// **'العمل الإضافي'**
  String get payslipOvertime;

  /// No description provided for @payslipBank.
  ///
  /// In ar, this message translates to:
  /// **'البنك'**
  String get payslipBank;

  /// No description provided for @payslipPaidOn.
  ///
  /// In ar, this message translates to:
  /// **'صُرف في {date}'**
  String payslipPaidOn(String date);

  /// No description provided for @checkoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'دفع المستحق'**
  String get checkoutTitle;

  /// No description provided for @checkoutEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير مستحقة الآن.'**
  String get checkoutEmpty;

  /// No description provided for @checkoutTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get checkoutTotal;

  /// No description provided for @checkoutSelected.
  ///
  /// In ar, this message translates to:
  /// **'{count} فاتورة محدّدة'**
  String checkoutSelected(String count);

  /// No description provided for @checkoutBusy.
  ///
  /// In ar, this message translates to:
  /// **'الفاتورة {number} يدفعها ولي أمر آخر الآن حتى {time}'**
  String checkoutBusy(String number, String time);

  /// No description provided for @paymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethod;

  /// No description provided for @couponLabel.
  ///
  /// In ar, this message translates to:
  /// **'كود الخصم'**
  String get couponLabel;

  /// No description provided for @couponApply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get couponApply;

  /// No description provided for @couponSuggested.
  ///
  /// In ar, this message translates to:
  /// **'قسيمة متاحة {code} — خصم {amount}'**
  String couponSuggested(String code, String amount);

  /// No description provided for @couponUse.
  ///
  /// In ar, this message translates to:
  /// **'استخدمها'**
  String get couponUse;

  /// No description provided for @invoicePdf.
  ///
  /// In ar, this message translates to:
  /// **'تحميل الفاتورة'**
  String get invoicePdf;

  /// No description provided for @invoicePdfFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إنشاء نسخة الفاتورة.'**
  String get invoicePdfFailed;

  /// No description provided for @editActivity.
  ///
  /// In ar, this message translates to:
  /// **'تعديل النشاط'**
  String get editActivity;

  /// No description provided for @deleteActivity.
  ///
  /// In ar, this message translates to:
  /// **'حذف النشاط'**
  String get deleteActivity;

  /// No description provided for @deleteActivityConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف النشاط وبنوده. هل تريد المتابعة؟'**
  String get deleteActivityConfirm;

  /// No description provided for @activityDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف النشاط'**
  String get activityDeleted;

  /// No description provided for @activityPublished.
  ///
  /// In ar, this message translates to:
  /// **'نُشر النشاط'**
  String get activityPublished;

  /// No description provided for @activityUnpublished.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي نشر النشاط'**
  String get activityUnpublished;

  /// No description provided for @unpublish.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء النشر'**
  String get unpublish;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @allClassrooms.
  ///
  /// In ar, this message translates to:
  /// **'كل الفصول'**
  String get allClassrooms;

  /// No description provided for @undoAbsence.
  ///
  /// In ar, this message translates to:
  /// **'تراجع عن الغياب'**
  String get undoAbsence;

  /// No description provided for @undoAbsenceConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف تسجيل غياب اليوم لهذا الطالب.'**
  String get undoAbsenceConfirm;

  /// No description provided for @absenceRemoved.
  ///
  /// In ar, this message translates to:
  /// **'حُذف تسجيل الغياب'**
  String get absenceRemoved;

  /// No description provided for @filterUnread.
  ///
  /// In ar, this message translates to:
  /// **'غير المقروءة'**
  String get filterUnread;

  /// No description provided for @filterUnacked.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار التأكيد'**
  String get filterUnacked;

  /// No description provided for @filterDue.
  ///
  /// In ar, this message translates to:
  /// **'المستحقة'**
  String get filterDue;

  /// No description provided for @filterPaid.
  ///
  /// In ar, this message translates to:
  /// **'المدفوعة'**
  String get filterPaid;

  /// No description provided for @filterUnpaid.
  ///
  /// In ar, this message translates to:
  /// **'غير المدفوعة'**
  String get filterUnpaid;

  /// No description provided for @filterExpired.
  ///
  /// In ar, this message translates to:
  /// **'المنتهية'**
  String get filterExpired;

  /// No description provided for @filterPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد التنفيذ'**
  String get filterPending;

  /// No description provided for @filterFailed.
  ///
  /// In ar, this message translates to:
  /// **'المتعثّرة'**
  String get filterFailed;

  /// No description provided for @filterCurrent.
  ///
  /// In ar, this message translates to:
  /// **'السارية'**
  String get filterCurrent;

  /// No description provided for @filterUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'القادمة'**
  String get filterUpcoming;

  /// No description provided for @filterUnviewed.
  ///
  /// In ar, this message translates to:
  /// **'غير المشاهدة'**
  String get filterUnviewed;

  /// No description provided for @filterForMyChildren.
  ///
  /// In ar, this message translates to:
  /// **'لأبنائي'**
  String get filterForMyChildren;

  /// No description provided for @filterActive.
  ///
  /// In ar, this message translates to:
  /// **'النشطة'**
  String get filterActive;

  /// No description provided for @filterConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'المؤكَّدة'**
  String get filterConfirmed;

  /// No description provided for @filterCancelled.
  ///
  /// In ar, this message translates to:
  /// **'الملغاة'**
  String get filterCancelled;

  /// No description provided for @eventTrip.
  ///
  /// In ar, this message translates to:
  /// **'رحلات'**
  String get eventTrip;

  /// No description provided for @eventActivity.
  ///
  /// In ar, this message translates to:
  /// **'أنشطة'**
  String get eventActivity;

  /// No description provided for @eventWorkshop.
  ///
  /// In ar, this message translates to:
  /// **'ورش'**
  String get eventWorkshop;

  /// No description provided for @eventCamp.
  ///
  /// In ar, this message translates to:
  /// **'مخيّمات'**
  String get eventCamp;

  /// No description provided for @eventCelebration.
  ///
  /// In ar, this message translates to:
  /// **'حفلات'**
  String get eventCelebration;

  /// No description provided for @acceptBooking.
  ///
  /// In ar, this message translates to:
  /// **'قبول الحجز'**
  String get acceptBooking;

  /// No description provided for @bookingAccepted.
  ///
  /// In ar, this message translates to:
  /// **'قُبل الحجز'**
  String get bookingAccepted;

  /// No description provided for @renewBooking.
  ///
  /// In ar, this message translates to:
  /// **'تجديد المهلة'**
  String get renewBooking;

  /// No description provided for @bookingRenewed.
  ///
  /// In ar, this message translates to:
  /// **'جُدِّدت مهلة الدفع'**
  String get bookingRenewed;

  /// No description provided for @bookingInvoice.
  ///
  /// In ar, this message translates to:
  /// **'الفاتورة'**
  String get bookingInvoice;

  /// No description provided for @surveyTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقييم الفعالية'**
  String get surveyTitle;

  /// No description provided for @surveySent.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لتقييمك'**
  String get surveySent;

  /// No description provided for @surveyAlreadySent.
  ///
  /// In ar, this message translates to:
  /// **'أرسلتَ تقييماً سابقاً، والإرسال الآن يستبدله.'**
  String get surveyAlreadySent;

  /// No description provided for @surveyNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get surveyNotes;

  /// No description provided for @attachments.
  ///
  /// In ar, this message translates to:
  /// **'المرفقات'**
  String get attachments;

  /// No description provided for @openAttachment.
  ///
  /// In ar, this message translates to:
  /// **'فتح المرفق'**
  String get openAttachment;

  /// No description provided for @downloading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التنزيل…'**
  String get downloading;

  /// No description provided for @fileSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ الملف'**
  String get fileSaved;

  /// No description provided for @assignActivities.
  ///
  /// In ar, this message translates to:
  /// **'إسناد أنشطة'**
  String get assignActivities;

  /// No description provided for @activitiesAssigned.
  ///
  /// In ar, this message translates to:
  /// **'أُسندت الأنشطة'**
  String get activitiesAssigned;

  /// No description provided for @couponAccepted.
  ///
  /// In ar, this message translates to:
  /// **'خصم {discount} — الإجمالي بعد الخصم {total}'**
  String couponAccepted(String discount, String total);

  /// No description provided for @activityPdf.
  ///
  /// In ar, this message translates to:
  /// **'تحميل تقرير اليوم'**
  String get activityPdf;

  /// No description provided for @disablePush.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف إشعارات هذا الجهاز'**
  String get disablePush;

  /// No description provided for @pushDisabled.
  ///
  /// In ar, this message translates to:
  /// **'أُوقفت إشعارات هذا الجهاز'**
  String get pushDisabled;

  /// No description provided for @filterEveryone.
  ///
  /// In ar, this message translates to:
  /// **'الجميع'**
  String get filterEveryone;

  /// No description provided for @filterMine.
  ///
  /// In ar, this message translates to:
  /// **'ما أضفتُه'**
  String get filterMine;

  /// No description provided for @copy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copy;

  /// No description provided for @couponCopied.
  ///
  /// In ar, this message translates to:
  /// **'نُسخ الكود'**
  String get couponCopied;

  /// No description provided for @couponNoInvoices.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير مستحقة يصلح لها هذا الكوبون.'**
  String get couponNoInvoices;

  /// No description provided for @showInvoice.
  ///
  /// In ar, this message translates to:
  /// **'عرض الفاتورة'**
  String get showInvoice;

  /// No description provided for @allChildren.
  ///
  /// In ar, this message translates to:
  /// **'كل الأبناء'**
  String get allChildren;

  /// No description provided for @scanHint.
  ///
  /// In ar, this message translates to:
  /// **'امسحي بطاقة الطفل من تبويب «الحضور» لتسجيل الدخول أو الانصراف.'**
  String get scanHint;

  /// No description provided for @showAmounts.
  ///
  /// In ar, this message translates to:
  /// **'إظهار المبالغ'**
  String get showAmounts;

  /// No description provided for @hideAmounts.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء المبالغ'**
  String get hideAmounts;

  /// No description provided for @leaveTypesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أنواع إجازات مفعّلة حالياً. راجعي إدارة النظام.'**
  String get leaveTypesEmpty;

  /// No description provided for @balancesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أرصدة إجازات مسجّلة على ملفك.'**
  String get balancesEmpty;

  /// No description provided for @withdrawLeaveConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيُسحب طلب الإجازة ولن يُعرض على الإدارة. متابعة؟'**
  String get withdrawLeaveConfirm;

  /// No description provided for @working.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التنفيذ…'**
  String get working;

  /// No description provided for @scanSending.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ إرسال البطاقة…'**
  String get scanSending;

  /// No description provided for @markAbsentBusy.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تسجيل الغياب…'**
  String get markAbsentBusy;

  /// No description provided for @formHiddenUntilOpen.
  ///
  /// In ar, this message translates to:
  /// **'يظهر نموذج الإضافة تلقائياً فور فتح النافذة.'**
  String get formHiddenUntilOpen;

  /// No description provided for @changePhoto.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة'**
  String get changePhoto;

  /// No description provided for @photoUploading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ رفع الصورة…'**
  String get photoUploading;

  /// No description provided for @photoUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الصورة'**
  String get photoUpdated;

  /// No description provided for @markPresent.
  ///
  /// In ar, this message translates to:
  /// **'تحضير'**
  String get markPresent;

  /// No description provided for @markPresentNote.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل وصول الطالب الآن وإلغاء غياب اليوم إن وُجد.'**
  String get markPresentNote;

  /// No description provided for @markCheckedOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل انصراف'**
  String get markCheckedOut;

  /// No description provided for @markCheckedOutNote.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل مغادرة الطالب الآن.'**
  String get markCheckedOutNote;

  /// No description provided for @markUnexcused.
  ///
  /// In ar, this message translates to:
  /// **'غياب بدون عذر'**
  String get markUnexcused;

  /// No description provided for @markUnexcusedNote.
  ///
  /// In ar, this message translates to:
  /// **'يُسجَّل غياباً ويُبلَّغ ولي الأمر.'**
  String get markUnexcusedNote;

  /// No description provided for @markExcused.
  ///
  /// In ar, this message translates to:
  /// **'غياب بعذر'**
  String get markExcused;

  /// No description provided for @markExcusedNote.
  ///
  /// In ar, this message translates to:
  /// **'يُطلب سبب الغياب ثم يُسجَّل ويُبلَّغ ولي الأمر.'**
  String get markExcusedNote;

  /// No description provided for @markAbsentOneConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيُسجَّل غياب {name} اليوم ويُبلَّغ ولي الأمر. متابعة؟'**
  String markAbsentOneConfirm(String name);

  /// No description provided for @absenceReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الغياب'**
  String get absenceReason;

  /// No description provided for @saved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ'**
  String get saved;

  /// No description provided for @studentActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات الطالب'**
  String get studentActions;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppL10nAr();
    case 'en': return AppL10nEn();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
