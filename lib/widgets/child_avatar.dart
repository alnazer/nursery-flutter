import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// صورة الطفل — وإن لم تتوفر أو تعذّر تحميلها نعرض حرفه الأول بلون الهوية.
class ChildAvatar extends StatelessWidget {
  const ChildAvatar({super.key, required this.name, this.url, this.size = 44});

  final String name;
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Widget fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: colors.soft,
      child: Text(
        name.trim().isEmpty ? '؟' : name.trim().substring(0, 1),
        style: TextStyle(
          color: colors.primaryInk,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
        ),
      ),
    );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null || url!.isEmpty
            ? fallback
            : Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error, StackTrace? stack) => fallback,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) =>
                    progress == null ? child : fallback,
              ),
      ),
    );
  }
}
