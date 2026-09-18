import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'account_page.dart';
import 'activities_page.dart';
import 'invoices_page.dart';
import 'notifications_page.dart';
import 'parent_home_page.dart';

/// تطبيق ولي الأمر بعد الدخول: خمسة أقسام في شريط سفلي.
class ParentShell extends StatefulWidget {
  const ParentShell({super.key});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final List<String> titles = <String>[
      l10n.navHome,
      l10n.navActivities,
      l10n.navPayments,
      l10n.navNotifications,
      l10n.navAccount,
    ];

    return Scaffold(
      appBar: _index == 0 ? null : AppBar(title: Text(titles[_index])),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const <Widget>[
            ParentHomePage(),
            ActivitiesPage(asTab: true),
            InvoicesPage(asTab: true),
            NotificationsPage(asTab: true),
            AccountPage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int index) => setState(() => _index = index),
        destinations: <NavigationDestination>[
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: titles[0]),
          NavigationDestination(icon: const Icon(Icons.auto_awesome_outlined), label: titles[1]),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), label: titles[2]),
          NavigationDestination(icon: const Icon(Icons.notifications_none), label: titles[3]),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: titles[4]),
        ],
      ),
    );
  }
}
