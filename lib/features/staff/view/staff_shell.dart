import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/staff_api.dart';
import '../../../core/util/staff_abilities.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/user_avatar.dart';
import '../../parent/view/account_page.dart';
import '../../parent/view/circulars_page.dart';
import '../../parent/view/notifications_page.dart';
import 'staff_activities_page.dart';
import 'staff_attendance_page.dart';
import 'staff_students_page.dart';
import 'staff_today_page.dart';

/// تطبيق المشرفات بعد الدخول.
class StaffShell extends StatefulWidget {
  const StaffShell({super.key});

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // الحساب والصلاحيات يُحمّلان مرة واحدة لكل التطبيق (الصورة والاسم والأزرار).
    if (!StaffAbilities.loaded) {
      StaffAbilities.load(context.read<StaffApi>()).then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final List<String> titles = <String>[
      l10n.navToday,
      l10n.staffAttendanceTitle,
      l10n.staffActivitiesTitle,
      l10n.navStudents,
      l10n.navAccount,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.circularsTitle,
            onPressed: () => Navigator.of(context).push(CircularsPage.route()),
            icon: const Icon(Icons.campaign_outlined),
          ),
          IconButton(
            tooltip: l10n.notificationsTitle,
            onPressed: () => Navigator.of(context).push(NotificationsPage.route()),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const <Widget>[
            StaffTodayPage(),
            StaffAttendancePage(),
            StaffActivitiesPage(),
            StaffStudentsPage(),
            AccountPage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int index) => setState(() => _index = index),
        destinations: <NavigationDestination>[
          NavigationDestination(icon: const Icon(Icons.today_outlined), label: titles[0]),
          NavigationDestination(icon: const Icon(Icons.how_to_reg_outlined), label: titles[1]),
          NavigationDestination(icon: const Icon(Icons.auto_awesome_outlined), label: titles[2]),
          NavigationDestination(icon: const Icon(Icons.groups_outlined), label: titles[3]),
          NavigationDestination(
            icon: const StaffAvatar(size: 24),
            selectedIcon: const StaffAvatar(size: 26),
            label: titles[4],
          ),
        ],
      ),
    );
  }
}
