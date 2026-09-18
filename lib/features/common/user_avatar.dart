import 'package:flutter/material.dart';

import '../../core/models/staff_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/staff_abilities.dart';
import '../../widgets/child_avatar.dart';

/// صورة حساب الموظفة أينما لزمت: تتحدّث وحدها فور وصول `GET /staff/me`،
/// وتسقط على الحرف الأول من الاسم إن لم تكن هناك صورة.
class StaffAvatar extends StatelessWidget {
  const StaffAvatar({super.key, this.size = 44, this.fallbackName = ''});

  final double size;

  /// اسم من الجلسة يُستعمل قبل وصول بيانات الحساب.
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StaffMe>(
      valueListenable: StaffAbilities.me,
      builder: (BuildContext context, StaffMe me, Widget? child) => ChildAvatar(
        name: me.name.isEmpty ? fallbackName : me.name,
        url: me.avatarUrl,
        size: size,
      ),
    );
  }
}

/// سطر تعريف الحساب: الصورة، ثم الاسم، ثم المسمّى والفرع.
class StaffIdentity extends StatelessWidget {
  const StaffIdentity({
    super.key,
    required this.name,
    this.subtitle = '',
    this.size = 56,
    this.nameSize = 18,
  });

  final String name;

  /// سطر بديل يظهر حين لا يصل المسمّى من الخادم (اسم الحضانة مثلاً).
  final String subtitle;
  final double size;
  final double nameSize;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return ValueListenableBuilder<StaffMe>(
      valueListenable: StaffAbilities.me,
      builder: (BuildContext context, StaffMe me, Widget? child) {
        final String title = me.name.isEmpty ? name : me.name;
        final String line = me.subtitle.isEmpty ? subtitle : me.subtitle;

        return Row(
          children: <Widget>[
            ChildAvatar(name: title, url: me.avatarUrl, size: size),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(fontSize: nameSize, fontWeight: FontWeight.w700, color: colors.ink),
                  ),
                  if (line.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Icon(Icons.badge_outlined, size: 14, color: colors.muted),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            line,
                            style: TextStyle(fontSize: 13, color: colors.muted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
