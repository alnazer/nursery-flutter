import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// يعرض حاجب تحميل غير قابل للإغلاق أثناء انتظار الخادم، ثم يزيله مهما كانت النتيجة.
/// يُستعمل مع الطلبات التي لا تملك شاشتها الخاصة (المسح، تسجيل الغياب…).
Future<T> runBusy<T>(
  BuildContext context, {
  required Future<T> Function() action,
  String? label,
}) async {
  final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
  bool open = true;
  // لا ننتظر الحوار: يُغلق من finally بعد انتهاء الطلب.
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black26,
    useRootNavigator: true,
    builder: (BuildContext dialogContext) => PopScope(
      canPop: false,
      child: Center(child: BusyCard(label: label)),
    ),
  ).then((_) {
    open = false;
  });

  try {
    return await action();
  } finally {
    if (open) {
      open = false;
      navigator.pop();
    }
  }
}

/// بطاقة «جارٍ التنفيذ…» بمؤشّر دائري.
class BusyCard extends StatelessWidget {
  const BusyCard({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppL10n l10n = AppL10n.of(context);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 14),
            Text(
              label ?? l10n.working,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.body, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
