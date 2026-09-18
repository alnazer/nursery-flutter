import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/parent_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';

/// جرس الإشعارات.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, this.asTab = false});

  final bool asTab;

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const NotificationsPage(),
      );

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _unread = false;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<PagedCubit<NotificationItem>>(
      key: ValueKey<bool>(_unread),
      create: (BuildContext context) =>
          PagedCubit<NotificationItem>((int page) => api.notifications(page: page, unread: _unread))..load(),
      child: Builder(
        builder: (BuildContext context) {
          final Widget filter = FilterBar<bool>(
            selected: _unread,
            onSelected: (bool value) => setState(() => _unread = value),
            options: <FilterOption<bool>>[
              FilterOption<bool>(value: false, label: l10n.filterAll),
              FilterOption<bool>(
                value: true,
                label: l10n.filterUnread,
                icon: Icons.mark_email_unread_outlined,
              ),
            ],
          );
          final Widget body = PagedListView<PagedCubit<NotificationItem>, NotificationItem>(
            itemBuilder: (BuildContext context, NotificationItem item) => _NotificationTile(item: item),
          );

          if (widget.asTab) {
            return Column(
              children: <Widget>[
                _MarkAllRow(api: api),
                filter,
                Expanded(child: body),
              ],
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.notificationsTitle),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    await api.markAllNotificationsRead();
                    if (context.mounted) {
                      context.read<PagedCubit<NotificationItem>>().load(refresh: true);
                    }
                  },
                  child: Text(l10n.markAllRead),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                filter,
                Expanded(child: body),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MarkAllRow extends StatelessWidget {
  const _MarkAllRow({required this.api});

  final ParentApi api;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextButton(
          onPressed: () async {
            await api.markAllNotificationsRead();
            if (context.mounted) {
              context.read<PagedCubit<NotificationItem>>().load(refresh: true);
            }
          },
          child: Text(l10n.markAllRead),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final NotificationItem item;

  /// أيقونة حسب نوع الإشعار كما يرسله الخادم.
  static IconData _icon(String type) {
    if (type.contains('invoice') || type.contains('payment')) {
      return Icons.receipt_long_outlined;
    }
    if (type.contains('absence')) {
      return Icons.event_busy_outlined;
    }
    if (type.contains('activity')) {
      return Icons.auto_awesome_outlined;
    }
    if (type.contains('announcement') || type.contains('circular')) {
      return Icons.campaign_outlined;
    }
    if (type.contains('attendance') || type.contains('checkin')) {
      return Icons.how_to_reg_outlined;
    }
    if (type.contains('event') || type.contains('booking')) {
      return Icons.celebration_outlined;
    }
    if (type.contains('document')) {
      return Icons.folder_outlined;
    }

    return Icons.notifications_none;
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool unread = !item.read;

    return AppCard(
      onTap: () async {
        if (!item.read) {
          await context.read<ParentApi>().markNotificationRead(item.id);
          if (context.mounted) {
            context.read<PagedCubit<NotificationItem>>().load(refresh: true);
          }
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconBadge(
            icon: _icon(item.type),
            color: unread ? colors.primaryInk : colors.muted,
            background: unread ? colors.soft : colors.bg2,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(item.title,
                          style: TextStyle(
                            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                            color: colors.ink,
                          )),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
                if (item.body.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(item.body, style: TextStyle(color: colors.body, fontSize: 13, height: 1.5)),
                ],
                const SizedBox(height: 6),
                IconLine(icon: Icons.schedule_outlined, text: formatDateTime(item.createdAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
