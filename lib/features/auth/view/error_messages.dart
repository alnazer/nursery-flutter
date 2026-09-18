import '../../../core/api/api_failure.dart';
import '../../../core/native/native_bridge.dart';
import '../../../l10n/app_localizations.dart';

/// رسالة للعرض: نفضّل رسالة الخادم (تصل بلغة الطلب) ونرجع لنصوصنا عند غيابها.
String failureMessage(AppL10n l10n, ApiFailure failure) {
  if (failure.isNetwork) {
    return l10n.networkError;
  }
  if (failure.displayMessage.isNotEmpty) {
    return failure.displayMessage;
  }
  switch (failure.code) {
    case ApiCode.tooManyRequests:
      return l10n.tooManyBody(((failure.retryAfter ?? 60) / 60).ceil());
    case ApiCode.smsUnavailable:
      return l10n.smsUnavailable;
    case ApiCode.otpUnavailable:
      return l10n.otpUnavailable;
    case ApiCode.accountAppDisabled:
      return l10n.accountBlockedBody;
    case ApiCode.accountInactive:
      return l10n.accountInactiveBody;
    case ApiCode.maintenance:
      return l10n.maintenanceBody;
    case ApiCode.appUpdateRequired:
      return l10n.updateBody;
    case ApiCode.reauthRequired:
      return l10n.biometricReauth;
    case ApiCode.biometricInvalid:
      return failure.reason == 'key_revoked' ? l10n.biometricRevoked : l10n.biometricRetry;
    case ApiCode.invalidClient:
      return l10n.configMissing;
    default:
      return l10n.serverError;
  }
}

/// سطر فني قصير: رمز الخطأ ورقم الحالة والسبب إن وُجد.
String failureDetail(ApiFailure failure) => <String>[
      failure.code,
      if (failure.status > 0) '${failure.status}',
      if (failure.reason != null) failure.reason!,
      if (failure.path.isNotEmpty) failure.path,
    ].join(' · ');

String biometricErrorMessage(AppL10n l10n, BiometricError error) {
  switch (error.code) {
    case 'not_enrolled':
      return l10n.biometricNotEnrolled;
    case 'locked':
      return l10n.biometricLocked;
    case 'key_invalidated':
    case 'no_key':
      return l10n.biometricRevoked;
    case 'cancelled':
      return '';
    default:
      return l10n.biometricUnavailable;
  }
}
