import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// إظهار أو إخفاء مبالغ الراتب. الافتراضي مخفي، والحالة مشتركة بين
/// «خدماتي» و«راتبي» وقسيمة الراتب، وتعود للإخفاء عند الخروج من الحساب.
class SalaryVisibility {
  const SalaryVisibility._();

  static final ValueNotifier<bool> visible = ValueNotifier<bool>(false);

  static void toggle() => visible.value = !visible.value;

  static void reset() => visible.value = false;

  /// ما يظهر بدل المبلغ حين يكون مخفيّاً.
  static const String mask = '••••••';
}

/// مبلغ لا يظهر إلّا بعد الضغط على زر العين.
class SalaryText extends StatelessWidget {
  const SalaryText(this.text, {super.key, this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SalaryVisibility.visible,
      builder: (BuildContext context, bool visible, Widget? child) => Text(
        visible ? text : SalaryVisibility.mask,
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}

/// زر العين في شريط العنوان: يبدّل إظهار كل المبالغ في الشاشة.
class SalaryEyeButton extends StatelessWidget {
  const SalaryEyeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: SalaryVisibility.visible,
      builder: (BuildContext context, bool visible, Widget? child) => IconButton(
        tooltip: visible ? l10n.hideAmounts : l10n.showAmounts,
        onPressed: SalaryVisibility.toggle,
        icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
      ),
    );
  }
}
