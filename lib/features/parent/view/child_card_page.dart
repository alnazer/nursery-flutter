import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/parent_api.dart';
import '../../common/student_card_page.dart';

/// بطاقة الطفل — الشاشة المشتركة ببيانات تطبيق ولي الأمر.
class ChildCardPage extends StatelessWidget {
  const ChildCardPage({super.key, required this.childId, required this.childName, this.avatarUrl});

  final int childId;
  final String childName;
  final String? avatarUrl;

  static Route<void> route(int childId, String childName, {String? avatarUrl}) => MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            ChildCardPage(childId: childId, childName: childName, avatarUrl: avatarUrl),
      );

  @override
  Widget build(BuildContext context) {
    final ParentApi api = context.read<ParentApi>();

    return StudentCardPage(
      studentName: childName,
      avatarUrl: avatarUrl,
      loader: () => api.card(childId),
    );
  }
}
