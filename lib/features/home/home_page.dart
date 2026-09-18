import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_config.dart';
import '../parent/view/parent_shell.dart';
import '../staff/view/staff_shell.dart';

/// يوجّه إلى واجهة النسخة الصحيحة بعد الدخول.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return context.read<AppConfig>().isStaff ? const StaffShell() : const ParentShell();
  }
}
