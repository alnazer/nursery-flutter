# تطبيق الحضانة (Flutter)

نسختان من نفس الكود: **ولي الأمر** و**المشرفات**، بإدارة حالة Cubit/BLoC.

## التشغيل

من Android Studio: اختر إعداد التشغيل «ولي الأمر (parent)» أو «المشرفات (staff)» من القائمة العلوية
بعد وضع مفاتيح الـ API فيه (Run ← Edit Configurations).

أو من الطرفية:

```bash
flutter pub get

flutter run --flavor parent -t lib/main_parent.dart \
  --dart-define=API_BASE_URL=https://nursery.local \
  --dart-define=PARENT_API_KEY=... --dart-define=PARENT_API_SECRET=...

flutter run --flavor staff -t lib/main_staff.dart \
  --dart-define=API_BASE_URL=https://nursery.local \
  --dart-define=STAFF_API_KEY=... --dart-define=STAFF_API_SECRET=...
```

من محاكي Android يكون عنوان جهازك هو `http://10.0.2.2`.
لتشغيل الوضع الموقّع (HMAC) أضف `--dart-define=API_SIGN=true`.

## البنية

```
lib/
  app/            إعدادات النسخة (flavor) وجذر التطبيق
  core/api/       عميل HTTP على dart:io، غلاف { data, meta }، مسارات الدخول
  core/native/    القناة مع الكود الأصلي: الجهاز، التخزين الآمن، البصمة
  core/storage/   الرمز ومفتاح البصمة ومعرّف التثبيت واللغة
  core/theme/     ألوان الهوية (فاتح وداكن)
  features/       session + auth (Cubits وشاشات) + home
  l10n/           العربية والإنجليزية
```

## المكتبات

`flutter_bloc` لإدارة الحالة، و`crypto` لتوقيع الطلبات، و`intl` + `flutter_localizations` للترجمة.
كل ما عدا ذلك من Flutter نفسه أو كود أصلي في المشروع:

| الوظيفة | بدل مكتبة |
|---|---|
| الاتصال بالـ API | `dart:io` بدل http/dio |
| التخزين الآمن | Keystore/Keychain بدل flutter_secure_storage |
| البصمة | BiometricPrompt وSecure Enclave بدل local_auth |
| معلومات الجهاز | قناة أصلية بدل device_info_plus |

## ملاحظات

- Android: أقل إصدار مدعوم 10 (API 29) لأن البصمة تستخدم `BiometricPrompt` من النظام.
- iOS: النسختان لم تُضبطا كـ schemes في Xcode بعد؛ التشغيل عليه حالياً بلا `--flavor`.
- الاختبارات: `flutter test`.
# nursery-flutter
