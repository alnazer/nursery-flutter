import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/parent_api.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import '../../common/failure_view.dart';

/// التعاميم: قائمة مصفّاة، وتفاصيل مع زر «اطّلعت» حين يُطلب.
class CircularsPage extends StatefulWidget {
  const CircularsPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const CircularsPage(),
      );

  @override
  State<CircularsPage> createState() => _CircularsPageState();
}

class _CircularsPageState extends State<CircularsPage> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.circularsTitle)),
      body: Column(
        children: <Widget>[
          FilterBar<String>(
            selected: _filter,
            onSelected: (String value) => setState(() => _filter = value),
            options: <FilterOption<String>>[
              FilterOption<String>(value: '', label: l10n.filterAll),
              FilterOption<String>(value: 'unread', label: l10n.filterUnread, icon: Icons.mark_email_unread_outlined),
              FilterOption<String>(value: 'unacked', label: l10n.filterUnacked, icon: Icons.task_alt),
            ],
          ),
          Expanded(
            child: BlocProvider<PagedCubit<Announcement>>(
              key: ValueKey<String>(_filter),
              create: (BuildContext context) => PagedCubit<Announcement>(
                (int page) => api.announcements(page: page, filter: _filter.isEmpty ? null : _filter),
              )..load(),
              child: PagedListView<PagedCubit<Announcement>, Announcement>(
                itemBuilder: (BuildContext context, Announcement item) => _CircularTile(announcement: item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularTile extends StatelessWidget {
  const _CircularTile({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final bool unread = !announcement.read;
    final bool needsAck = announcement.requireAck && !announcement.acknowledged;

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.of(context).push(CircularDetailPage.route(announcement.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconBadge(
            icon: needsAck ? Icons.assignment_late_outlined : Icons.campaign_outlined,
            color: needsAck ? colors.sun : (unread ? colors.primaryInk : colors.muted),
            background: needsAck ? colors.sunSoft : (unread ? colors.soft : colors.bg2),
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(announcement.title,
                          style: TextStyle(
                            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                            color: colors.ink,
                          )),
                    ),
                    if (announcement.requireAck)
                      StatusChip(
                        text: announcement.acknowledged ? l10n.acknowledged : l10n.acknowledge,
                        color: announcement.acknowledged ? colors.green : colors.sun,
                        background: announcement.acknowledged ? colors.greenSoft : colors.sunSoft,
                        icon: announcement.acknowledged ? Icons.check_circle_outline : Icons.priority_high,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                IconLine(icon: Icons.schedule_outlined, text: formatDateTime(announcement.sentAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircularDetailPage extends StatelessWidget {
  const CircularDetailPage({super.key, required this.id});

  final int id;

  static Route<void> route(int id) => MaterialPageRoute<void>(
        builder: (BuildContext context) => CircularDetailPage(id: id),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<DetailCubit<Announcement>>(
      create: (BuildContext context) => DetailCubit<Announcement>(() => api.announcement(id))..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.circularsTitle)),
        body: BlocBuilder<DetailCubit<Announcement>, DetailState<Announcement>>(
          builder: (BuildContext context, DetailState<Announcement> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(failure: state.failure!, onRetry: () => context.read<DetailCubit<Announcement>>().load()),
              );
            }
            final Announcement announcement = state.data!;
            final AppColors colors = context.colors;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Text(announcement.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 6),
                IconLine(icon: Icons.schedule_outlined, text: formatDateTime(announcement.sentAt), fontSize: 12),
                const SizedBox(height: 16),
                Text(
                  _plainText(announcement.bodyHtml),
                  style: TextStyle(color: colors.body, height: 1.7, fontSize: 15),
                ),
                if (announcement.attachments.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 20),
                  Text(l10n.attachments, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                  const SizedBox(height: 8),
                  ...announcement.attachments.map((Attachment file) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          onTap: () => const NativeBridge().openUrl(file.url),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                file.isImage ? Icons.image_outlined : Icons.description_outlined,
                                color: colors.primaryInk,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(file.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: colors.ink, fontWeight: FontWeight.w600)),
                                    if (file.sizeLabel.isNotEmpty)
                                      Text(file.sizeLabel, style: TextStyle(color: colors.muted, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Icon(Icons.open_in_new, size: 18, color: colors.muted),
                            ],
                          ),
                        ),
                      )),
                ],
                const SizedBox(height: 24),
                if (announcement.requireAck)
                  FilledButton.icon(
                    onPressed: announcement.acknowledged
                        ? null
                        : () async {
                            await api.acknowledge(announcement.id);
                            if (context.mounted) {
                              context.read<DetailCubit<Announcement>>().load();
                            }
                          },
                    icon: Icon(announcement.acknowledged ? Icons.check_circle_outline : Icons.task_alt, size: 18),
                    label: Text(announcement.acknowledged ? l10n.acknowledged : l10n.acknowledge),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// نص التعميم يصل HTML — نعرضه نصاً بسيطاً بلا مكتبة عرض HTML.
String _plainText(String html) => html
    .replaceAll(RegExp(r'<br\s*/?>'), '\n')
    .replaceAll(RegExp(r'</p>'), '\n\n')
    .replaceAll(RegExp(r'<[^>]+>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .trim();
