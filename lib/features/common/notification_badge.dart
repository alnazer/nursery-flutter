import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// شارة عدّاد حمراء فوق أيقونة أو بطاقة: «٣» أو «+٩٩».
/// لا تُبنى أصلاً حين يكون العدد صفراً — استعمل [NotificationBadge.when].
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key, required this.count, this.max = 99});

  final int count;

  /// أعلى رقم يُكتب كما هو، وما بعده يظهر «+99».
  final int max;

  /// تعيد null حين لا شيء ينتظر — تسهّل الاستعمال داخل قوائم الودجت.
  static Widget? when(int count) => count > 0 ? NotificationBadge(count: count) : null;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }
    final AppColors colors = context.colors;
    final String label = count > max ? '+$max' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.coral,
        borderRadius: BorderRadius.circular(999),
        // حدّ بلون الخلفية يفصل الشارة عن حافة البطاقة تحتها
        border: Border.all(color: colors.surface, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}

/// نقطة صغيرة بلا رقم — لِما يحتاج انتباهاً بلا عدد معلوم.
class AttentionDot extends StatelessWidget {
  const AttentionDot({super.key, this.size = 10});

  final double size;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.coral,
        shape: BoxShape.circle,
        border: Border.all(color: colors.surface, width: 1.5),
      ),
    );
  }
}
