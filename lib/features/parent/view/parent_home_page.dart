import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/child_avatar.dart';
import '../../common/list_views.dart';
import '../../session/session_cubit.dart';
import '../cubit/parent_home_cubit.dart';
import 'activities_page.dart';
import 'child_page.dart';
import 'absences_page.dart';
import 'circulars_page.dart';
import 'coupons_page.dart';
import 'events_page.dart';
import 'subscriptions_page.dart';
import 'invoices_page.dart';
import 'notifications_page.dart';
import '../../common/failure_view.dart';

/// الرئيسية: الأبناء وحالة اليوم، وما ينتظر تصرّف ولي الأمر، وآخر نشاط.
class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ParentHomeCubit>(
      create: (BuildContext context) => ParentHomeCubit(context.read<ParentApi>())..load(),
      child: const _ParentHomeView(),
    );
  }
}

class _ParentHomeView extends StatelessWidget {
  const _ParentHomeView();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final SessionState session = context.watch<SessionCubit>().state;

    return BlocBuilder<ParentHomeCubit, ParentHomeState>(
      builder: (BuildContext context, ParentHomeState state) {
        if (state.loading && state.children.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final ApiFailure? failure = state.failure;
        if (failure != null && state.children.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: FailureView(failure: failure, onRetry: () => context.read<ParentHomeCubit>().load()),
            ),
          );
        }
        final Child? child = state.selectedChild;

        return RefreshIndicator(
          onRefresh: () => context.read<ParentHomeCubit>().load(refresh: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              _Header(unread: state.unreadNotifications, name: session.session?.userName ?? ''),
              if (state.children.length > 1) ...<Widget>[
                const SizedBox(height: 16),
                _ChildrenChips(children: state.children, selectedId: child?.id),
              ],
              if (child != null) ...<Widget>[
                const SizedBox(height: 16),
                _TodayCard(child: child),
              ],
              if (state.pendingInvoice != null || state.pendingAnnouncement != null) ...<Widget>[
                const SizedBox(height: 22),
                Text(l10n.pendingTitle,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 10),
                if (state.pendingInvoice != null) _PendingInvoice(invoice: state.pendingInvoice!),
                if (state.pendingAnnouncement != null) ...<Widget>[
                  const SizedBox(height: 10),
                  _PendingAnnouncement(announcement: state.pendingAnnouncement!),
                ],
              ],
              const SizedBox(height: 22),
              Text(l10n.servicesTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.ink)),
              const SizedBox(height: 10),
              const _ServicesGrid(),
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  Text(l10n.todayActivity,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.ink)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(ActivitiesPage.route()),
                    child: Text(l10n.viewAll),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _ActivityCard(activity: state.latestActivity),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.unread, required this.name});

  final int unread;
  final String name;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppL10n l10n = AppL10n.of(context);
    final SessionState session = context.watch<SessionCubit>().state;

    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 24,
          backgroundColor: colors.soft,
          child: Text(
            name.isEmpty ? '?' : name.substring(0, 1),
            style: TextStyle(color: colors.primaryInk, fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.welcome(name),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.ink)),
              const SizedBox(height: 2),
              Text(session.meta.name, style: TextStyle(fontSize: 13, color: colors.muted)),
            ],
          ),
        ),
        Stack(
          children: <Widget>[
            IconButton(
              onPressed: () => Navigator.of(context).push(NotificationsPage.route()),
              icon: Icon(Icons.notifications_none, color: colors.ink),
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: colors.coral, borderRadius: BorderRadius.circular(999)),
                  child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChildrenChips extends StatelessWidget {
  const _ChildrenChips({required this.children, required this.selectedId});

  final List<Child> children;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final Child child = children[index];
          final bool selected = child.id == selectedId;

          return ChoiceChip(
            selected: selected,
            onSelected: (bool _) {
              context.read<ParentHomeCubit>().selectChild(child.id);
              context.read<ParentHomeCubit>().reloadActivity();
            },
            avatar: ChildAvatar(name: child.firstName, url: child.avatarUrl, size: 26),
            label: Text(child.firstName),
            labelStyle: TextStyle(
              color: selected ? Colors.white : colors.ink,
              fontWeight: FontWeight.w700,
            ),
            selectedColor: colors.primary,
            backgroundColor: colors.surface,
            side: BorderSide(color: selected ? colors.primary : colors.line),
          );
        },
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final _StatusStyle style = _StatusStyle.of(context, child.today.status);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ChildAvatar(name: child.firstName, url: child.avatarUrl, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Text(child.name,
                    style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
              ),
              StatusChip(text: style.label, color: style.color, background: style.background, icon: style.icon),
            ],
          ),
          const SizedBox(height: 10),
          if (child.today.checkedInAt != null)
            Text(l10n.arrivedAt(formatTime(child.today.checkedInAt)),
                style: TextStyle(color: colors.body, fontSize: 14)),
          if (child.today.checkedOutAt != null)
            Text(l10n.leftAt(formatTime(child.today.checkedOutAt)),
                style: TextStyle(color: colors.body, fontSize: 14)),
          const SizedBox(height: 4),
          Text('${child.classroom} · ${child.branch}', style: TextStyle(color: colors.muted, fontSize: 13)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(ChildPage.route(child.id, child.name)),
            child: Text(l10n.childCard),
          ),
        ],
      ),
    );
  }
}

class _PendingInvoice extends StatelessWidget {
  const _PendingInvoice({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return AppCard(
      onTap: () => Navigator.of(context).push(InvoicesPage.route()),
      child: Row(
        children: <Widget>[
          Icon(Icons.receipt_long_outlined, color: colors.primaryInk),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.invoiceNumber(invoice.number),
                    style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 4),
                Text(
                  '${invoice.isOverdue ? l10n.overdue : l10n.dueOn(formatDate(invoice.dueDate))} · ${invoice.total} ${invoice.currency}',
                  style: TextStyle(color: colors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(InvoiceDetailPage.route(invoice.id)),
            child: Text(l10n.payNow),
          ),
        ],
      ),
    );
  }
}

class _PendingAnnouncement extends StatelessWidget {
  const _PendingAnnouncement({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return AppCard(
      onTap: () => Navigator.of(context).push(CircularsPage.route()),
      child: Row(
        children: <Widget>[
          Icon(Icons.campaign_outlined, color: colors.primaryInk),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(announcement.title, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 4),
                Text(l10n.needsAck, style: TextStyle(color: colors.muted, fontSize: 13)),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await context.read<ParentApi>().acknowledge(announcement.id);
              if (context.mounted) {
                context.read<ParentHomeCubit>().load(refresh: true);
              }
            },
            child: Text(l10n.acknowledge),
          ),
        ],
      ),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final List<_Service> services = <_Service>[
      _Service(l10n.activitiesTitle, Icons.auto_awesome_outlined, () => ActivitiesPage.route()),
      _Service(l10n.absencesTitle, Icons.event_busy_outlined, () => AbsencesPage.route()),
      _Service(l10n.serviceInvoices, Icons.receipt_long_outlined, () => InvoicesPage.route()),
      _Service(l10n.subscriptionsTitle, Icons.card_membership_outlined, () => SubscriptionsPage.route()),
      _Service(l10n.couponsTitle, Icons.local_offer_outlined, () => CouponsPage.route()),
      _Service(l10n.serviceCirculars, Icons.campaign_outlined, () => CircularsPage.route()),
      _Service(l10n.serviceEvents, Icons.celebration_outlined, () => EventsPage.route()),
      _Service(l10n.bookingsTitle, Icons.confirmation_number_outlined, () => BookingsPage.route()),
      _Service(l10n.notificationsTitle, Icons.notifications_none, () => NotificationsPage.route()),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: services.map((_Service service) => _ServiceTile(service: service)).toList(),
    );
  }
}

class _Service {
  const _Service(this.title, this.icon, this.route);

  final String title;
  final IconData icon;
  final Route<void> Function() route;
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});

  final _Service service;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(8),
      onTap: () => Navigator.of(context).push(service.route()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(service.icon, color: colors.primaryInk),
          const SizedBox(height: 6),
          Text(
            service.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: colors.ink),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final Activity? activity;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final Activity? item = activity;
    if (item == null) {
      return AppCard(child: Text(l10n.noActivityYet, style: TextStyle(color: colors.muted)));
    }

    return AppCard(
      onTap: () => Navigator.of(context).push(ActivityDetailPage.route(item.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ChildAvatar(name: item.studentName, url: item.studentAvatar, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item.studentName,
                    style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
              ),
              Text(formatTime(item.publishedAt), style: TextStyle(color: colors.muted, fontSize: 12)),
            ],
          ),
          if (item.note.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(item.note, style: TextStyle(color: colors.body, height: 1.6)),
          ],
        ],
      ),
    );
  }
}

/// ألوان ونصوص حالة اليوم.
class _StatusStyle {
  const _StatusStyle(this.label, this.color, this.background, this.icon);

  final String label;
  final Color color;
  final Color background;
  final IconData icon;

  static _StatusStyle of(BuildContext context, String status) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    switch (status) {
      case 'present':
        return _StatusStyle(l10n.statusPresent, colors.green, colors.greenSoft, Icons.check_circle_outline);
      case 'checked_out':
        return _StatusStyle(l10n.statusCheckedOut, colors.skyInk, colors.sky, Icons.logout);
      case 'absent':
        return _StatusStyle(l10n.statusAbsent, colors.coral, colors.coralSoft, Icons.event_busy_outlined);
      case 'closed':
        return _StatusStyle(l10n.statusClosed, colors.sun, colors.sunSoft, Icons.beach_access_outlined);
      default:
        return _StatusStyle(l10n.statusNotArrived, colors.muted, colors.bg2, Icons.schedule);
    }
  }
}
