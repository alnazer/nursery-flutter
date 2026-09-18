import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/api/api_failure.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../auth/view/error_messages.dart';

/// شكل موحّد لأخطاء الخادم: أيقونة وعنوان ورسالة وزر، والتفاصيل الفنية مطوية.
class FailureView extends StatelessWidget {
  const FailureView({super.key, required this.failure, this.onRetry, this.compact = false});

  final ApiFailure failure;
  final VoidCallback? onRetry;

  /// نسخة مضغوطة تُستخدم داخل النماذج والبطاقات.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final _FailureStyle style = _FailureStyle.of(context, failure);
    final String message = failureMessage(l10n, failure);
    final bool sameAsTitle = message.trim() == style.title.trim();

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: style.background, borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(style.icon, size: 20, color: style.color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(message, style: TextStyle(color: colors.ink, height: 1.6, fontSize: 14)),
                  _details(context),
                  if (onRetry != null)
                    TextButton(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                      child: Text(l10n.retry),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final bool canPop = Navigator.of(context).canPop();
    final bool retryUseless = failure.code == ApiCode.notFound && canPop;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // دائرتان متداخلتان تعطيان الحالة وزناً بصرياً بلا صورة
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: style.background.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(color: style.background, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Icon(style.icon, size: 42, color: style.color),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                style.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.ink, height: 1.4),
              ),
              if (!sameAsTitle && message.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: colors.muted, height: 1.8),
                ),
              ],
              if (failure.retryAfter != null) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.bg2,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.retryIn('${failure.retryAfter}'),
                    style: TextStyle(fontSize: 13, color: colors.body),
                  ),
                ),
              ],
              const SizedBox(height: 26),
              if (retryUseless) ...<Widget>[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: Text(l10n.goBack),
                  ),
                ),
                if (onRetry != null)
                  TextButton(onPressed: onRetry, child: Text(l10n.retry)),
              ] else ...<Widget>[
                if (onRetry != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n.retry),
                    ),
                  ),
                if (canPop)
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(l10n.goBack),
                  ),
              ],
              _details(context),
            ],
          ),
        ),
      ),
    );
  }

  /// التفاصيل الفنية تظهر في وضع التطوير فقط — لا تزعج المستخدم النهائي.
  Widget _details(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(l10n.errorDetails, style: TextStyle(fontSize: 12, color: colors.muted)),
        children: <Widget>[
          SelectableText(
            failureDetail(failure),
            style: TextStyle(fontSize: 11, color: colors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// أيقونة وعنوان ولون لكل نوع خطأ.
class _FailureStyle {
  const _FailureStyle(this.title, this.icon, this.color, this.background);

  final String title;
  final IconData icon;
  final Color color;
  final Color background;

  static _FailureStyle of(BuildContext context, ApiFailure failure) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    if (failure.isNetwork) {
      return _FailureStyle(l10n.errorNetworkTitle, Icons.wifi_off_outlined, colors.sun, colors.sunSoft);
    }

    switch (failure.code) {
      // لا يوجد
      case ApiCode.notFound:
        return _FailureStyle(l10n.errorNotFoundTitle, Icons.search_off, colors.muted, colors.bg2);
      case 'card_not_recognised':
        return _FailureStyle(l10n.errorCardTitle, Icons.badge_outlined, colors.sun, colors.sunSoft);

      // صلاحيات وحسابات
      case ApiCode.forbidden:
      case 'ability_missing':
      case 'no_employee_profile':
        return _FailureStyle(l10n.errorForbiddenTitle, Icons.lock_outline, colors.coral, colors.coralSoft);
      case ApiCode.accountAppDisabled:
        return _FailureStyle(l10n.errorAccountBlockedTitle, Icons.block, colors.coral, colors.coralSoft);
      case ApiCode.accountInactive:
        return _FailureStyle(l10n.errorAccountInactiveTitle, Icons.person_off_outlined, colors.coral, colors.coralSoft);
      case ApiCode.unauthenticated:
        return _FailureStyle(l10n.errorSessionTitle, Icons.login, colors.sun, colors.sunSoft);
      case ApiCode.reauthRequired:
        return _FailureStyle(l10n.errorReauthTitle, Icons.lock_reset, colors.sun, colors.sunSoft);

      // إعداد التطبيق
      case ApiCode.invalidClient:
      case ApiCode.signatureExpired:
      case ApiCode.clientNotAllowed:
        return _FailureStyle(l10n.errorConfigTitle, Icons.vpn_key_outlined, colors.coral, colors.coralSoft);

      // مدخلات ومواعيد
      case ApiCode.validationFailed:
        return _FailureStyle(l10n.errorValidationTitle, Icons.edit_note, colors.sun, colors.sunSoft);
      case ApiCode.otpExpired:
        return _FailureStyle(l10n.otpTitle, Icons.timer_off_outlined, colors.sun, colors.sunSoft);
      case ApiCode.biometricInvalid:
        return _FailureStyle(l10n.biometricFailedTitle, Icons.fingerprint, colors.coral, colors.coralSoft);
      case 'payload_too_large':
        return _FailureStyle(l10n.errorTooLargeTitle, Icons.attach_file, colors.sun, colors.sunSoft);

      // تعارض في الحالة (409 وما شابهها): رسالة الخادم هي الأهم
      case 'conflict':
      case 'already_exists':
      case 'not_cancellable':
      case 'not_paid':
      case 'cannot_pay':
      case 'registration_closed':
      case 'survey_closed':
      case 'student_present':
      case 'student_absent':
      case 'nothing_recorded':
      case 'activity_window_closed':
      case 'outside_study_period':
      case 'activity_day_changed':
      case 'approved_locked':
        return _FailureStyle(l10n.errorConflictTitle, Icons.info_outline, colors.skyInk, colors.sky);

      // حالات تشغيلية
      case ApiCode.tooManyRequests:
        return _FailureStyle(l10n.tooManyTitle, Icons.hourglass_bottom, colors.sun, colors.sunSoft);
      case ApiCode.maintenance:
        return _FailureStyle(l10n.maintenanceTitle, Icons.build_outlined, colors.skyInk, colors.sky);
      case ApiCode.appUpdateRequired:
        return _FailureStyle(l10n.updateTitle, Icons.system_update_alt, colors.primaryInk, colors.soft);
      case 'demo_locked':
        return _FailureStyle(l10n.errorDemoTitle, Icons.science_outlined, colors.purple, colors.purpleSoft);
      case 'payment_gateway_error':
        return _FailureStyle(l10n.errorGatewayTitle, Icons.credit_card_off, colors.coral, colors.coralSoft);
      case 'sms_unavailable':
      case 'otp_unavailable':
        return _FailureStyle(l10n.errorServerTitle, Icons.sms_failed_outlined, colors.sun, colors.sunSoft);

      default:
        return _FailureStyle(l10n.errorServerTitle, Icons.cloud_off_outlined, colors.coral, colors.coralSoft);
    }
  }
}

/// شريط سفلي موحّد لأخطاء العمليات السريعة (حفظ، إرسال، مسح…).
void showFailureSnack(BuildContext context, ApiFailure failure) {
  final AppL10n l10n = AppL10n.of(context);
  final _FailureStyle style = _FailureStyle.of(context, failure);
  final String message = failureMessage(l10n, failure);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: context.colors.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: style.background, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(style.icon, size: 18, color: style.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message.isEmpty ? style.title : message,
                style: TextStyle(color: context.colors.ink, fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
}

/// رسالة نجاح بنفس الشكل حتى تتناسق الإشعارات القصيرة.
void showSuccessSnack(BuildContext context, String message) {
  final AppColors colors = context.colors;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: colors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: colors.greenSoft, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.check, size: 18, color: colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: colors.ink, fontSize: 14, height: 1.5)),
            ),
          ],
        ),
      ),
    );
}


/// رسالة معلوماتية قصيرة بنفس شكل الرسائل الأخرى.
void showInfoSnack(BuildContext context, String message) {
  final AppColors colors = context.colors;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: colors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: colors.soft, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.info_outline, size: 18, color: colors.primaryInk),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: colors.ink, fontSize: 14, height: 1.5)),
            ),
          ],
        ),
      ),
    );
}
