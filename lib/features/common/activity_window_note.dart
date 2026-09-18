import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/models/staff_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/formatters.dart';
import '../../l10n/app_localizations.dart';

/// بطاقة نافذة إضافة الأنشطة:
/// مفتوحة → خلفية خضراء وعدّاد حتى الإغلاق وزر «إضافة نشاط»،
/// مغلقة → خلفية صفراء وعدّاد حتى إعادة الفتح.
/// عند وصول العدّاد إلى الصفر تُستدعى [onExpired] لإعادة جلب الحالة من الخادم.
class ActivityWindowNote extends StatefulWidget {
  const ActivityWindowNote({
    super.key,
    required this.window,
    this.onExpired,
    this.onAdd,
    this.blocked = '',
  });

  final ActivityWindow window;

  /// إعادة تحميل البيانات بعد انتهاء المهلة.
  final Future<void> Function()? onExpired;

  /// زر «إضافة نشاط» — يظهر فقط حين تكون النافذة مفتوحة.
  final VoidCallback? onAdd;

  /// سبب منع إضافي من الخادم (الطالب غائب، خارج الفترة الدراسية…).
  final String blocked;

  @override
  State<ActivityWindowNote> createState() => _ActivityWindowNoteState();
}

class _ActivityWindowNoteState extends State<ActivityWindowNote> {
  Timer? _timer;
  Duration _left = Duration.zero;
  bool _refreshing = false;

  /// لحظة تغيّر الحالة محسوبة مرة واحدة، حتى يعمل العدّاد
  /// أيضاً حين يرسل الخادم الثواني المتبقية بلا تاريخ.
  DateTime _deadline = DateTime.now();

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(ActivityWindowNote oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ActivityWindow previous = oldWidget.window;
    final ActivityWindow current = widget.window;
    if (previous.open != current.open ||
        previous.changesAt != current.changesAt ||
        previous.secondsLeft != current.secondsLeft) {
      _refreshing = false;
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    final DateTime now = DateTime.now();
    _left = widget.window.remaining(now);
    _deadline = now.add(_left);
    if (!widget.window.enabled || _left == Duration.zero) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final Duration left = _deadline.difference(DateTime.now());
      final Duration value = left.isNegative ? Duration.zero : left;
      if (value == Duration.zero) {
        timer.cancel();
        _expired();
      }
      if (mounted) {
        setState(() => _left = value);
      }
    });
  }

  /// انتهاء المهلة: تتغيّر الحالة على الخادم، فنعيد الجلب ليتحدّث الصندوق.
  Future<void> _expired() async {
    if (!mounted || widget.onExpired == null || _refreshing) {
      return;
    }
    setState(() => _refreshing = true);
    try {
      await widget.onExpired!();
    } catch (_) {
      // تبقى البطاقة على حالها، والسحب للتحديث متاح
    }
    if (!mounted) {
      return;
    }
    setState(() => _refreshing = false);
    // إن لم يتغيّر شيء (فارق ساعة أو خطأ شبكة) نعيد المحاولة بهدوء.
    if (widget.window.remaining() == Duration.zero) {
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 30), _expired);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final ActivityWindow window = widget.window;
    if (!window.enabled) {
      return const SizedBox.shrink();
    }
    final bool open = window.open;
    final Color tint = open ? colors.green : colors.sun;
    final Color background = open ? colors.greenSoft : colors.sunSoft;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tint.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(open ? Icons.lock_open_outlined : Icons.lock_clock, size: 20, color: tint),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  open ? l10n.windowOpenNow : l10n.windowClosed,
                  style: TextStyle(color: colors.ink, fontWeight: FontWeight.w700, fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
          if (_left > Duration.zero) ...<Widget>[
            const SizedBox(height: 10),
            _Countdown(
              label: open ? l10n.windowClosesIn : l10n.windowOpensIn,
              value: formatCountdown(_left),
              tint: tint,
            ),
          ],
          if (_refreshing) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: tint),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.windowUpdating, style: TextStyle(color: colors.body, fontSize: 12)),
                ),
              ],
            ),
          ],
          if (window.hours.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            _Line(icon: Icons.schedule_outlined, text: l10n.windowHoursNote(window.hours)),
          ],
          if (!open && window.opensAt != null)
            _Line(icon: Icons.event_available_outlined, text: l10n.windowReopensAt(formatTime(window.opensAt))),
          if (open && window.closesAt != null)
            _Line(icon: Icons.event_busy_outlined, text: l10n.windowClosesAt(formatTime(window.closesAt))),
          if (widget.blocked.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            _Line(icon: Icons.info_outline, text: widget.blocked),
          ],
          if (open && widget.onAdd != null) ...<Widget>[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.add_task, size: 18),
                label: Text(l10n.addActivity),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// سطر العدّاد: أيقونة مؤقّت ونص «يُفتح بعد» ورقم بخانات ثابتة.
class _Countdown extends StatelessWidget {
  const _Countdown({required this.label, required this.value, required this.tint});

  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Row(
      children: <Widget>[
        Icon(Icons.timer_outlined, size: 18, color: tint),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: colors.body, fontSize: 13)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: tint.withValues(alpha: 0.4)),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              style: TextStyle(color: tint, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 15, color: colors.muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: TextStyle(color: colors.body, fontSize: 12, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
