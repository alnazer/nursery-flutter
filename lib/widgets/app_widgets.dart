import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// زر أساسي بحالة تحميل.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed, this.busy = false});

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            )
          : Text(label),
    );
  }
}

/// زر البصمة المربّع بجانب زر المتابعة داخل شاشة الدخول.
class FingerprintButton extends StatelessWidget {
  const FingerprintButton({super.key, required this.onPressed, this.busy = false, this.tooltip});

  final VoidCallback? onPressed;
  final bool busy;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Widget button = SizedBox(
      width: 54,
      height: 54,
      child: Material(
        color: colors.soft,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: busy ? null : onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primaryInk, width: 1.5),
            ),
            alignment: Alignment.center,
            child: busy
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: colors.primaryInk),
                  )
                : Icon(Icons.fingerprint, size: 30, color: colors.primaryInk),
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// ملاحظة هادئة (خلفية فاتحة بلون الهوية).
class SoftNote extends StatelessWidget {
  const SoftNote({super.key, required this.text, this.icon = Icons.verified_user_outlined});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: colors.soft, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: colors.primaryInk),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: colors.ink, height: 1.6, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

/// رسالة خطأ فوق الزر.
class ErrorNote extends StatelessWidget {
  const ErrorNote({super.key, required this.text, this.onRetry, this.retryLabel, this.detail});

  final String text;
  final VoidCallback? onRetry;
  final String? retryLabel;

  /// سطر فني صغير (رمز الخطأ ورقم الحالة) يساعد على معرفة سبب المشكلة.
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: colors.coralSoft, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.error_outline, size: 20, color: colors.coral),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(text, style: TextStyle(color: colors.ink, height: 1.6, fontSize: 14)),
                if (detail != null && detail!.isNotEmpty)
                  Text(detail!, style: TextStyle(color: colors.muted, fontSize: 11)),
                if (onRetry != null && retryLabel != null)
                  TextButton(onPressed: onRetry, child: Text(retryLabel!)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// شعار الحضانة (أو بديل بلون الهوية قبل تحميله).
class NurseryLogo extends StatelessWidget {
  const NurseryLogo({super.key, this.url, this.size = 96});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(size * 0.31),
        border: Border.all(color: colors.line, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: url == null || url!.isEmpty
          ? Icon(Icons.spa_outlined, size: size * 0.45, color: colors.primaryInk)
          : Image.network(
              url!,
              fit: BoxFit.contain,
              errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
                  Icon(Icons.spa_outlined, size: size * 0.45, color: colors.primaryInk),
            ),
    );
  }
}
