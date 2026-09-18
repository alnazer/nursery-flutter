import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../../widgets/child_avatar.dart';
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import '../../common/child_filter.dart';
import '../../common/failure_view.dart';

/// قائمة الأنشطة اليومية المنشورة.
class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key, this.asTab = false});

  final bool asTab;

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const ActivitiesPage(),
      );

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  bool _unviewed = false;
  int? _child;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    final Widget body = Column(
      children: <Widget>[
        FilterBar<bool>(
          selected: _unviewed,
          onSelected: (bool value) => setState(() => _unviewed = value),
          options: <FilterOption<bool>>[
            FilterOption<bool>(value: false, label: l10n.filterAll),
            FilterOption<bool>(value: true, label: l10n.filterUnviewed, icon: Icons.visibility_off_outlined),
          ],
        ),
        ChildFilterBar(selected: _child, onSelected: (int? value) => setState(() => _child = value)),
        Expanded(
          child: BlocProvider<PagedCubit<Activity>>(
            key: ValueKey<String>('$_unviewed|$_child'),
            create: (BuildContext context) => PagedCubit<Activity>(
              (int page) => api.activities(page: page, unviewed: _unviewed, studentId: _child),
            )..load(),
            child: PagedListView<PagedCubit<Activity>, Activity>(
              itemBuilder: (BuildContext context, Activity item) => _ActivityTile(activity: item),
            ),
          ),
        ),
      ],
    );

    if (widget.asTab) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activitiesTitle)),
      body: body,
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.of(context).push(ActivityDetailPage.route(activity.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ChildAvatar(name: activity.studentName, url: activity.studentAvatar, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(activity.studentName,
                          style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                    ),
                    if (!activity.viewed)
                      StatusChip(
                        text: l10n.filterUnviewed,
                        color: colors.primaryInk,
                        background: colors.soft,
                        icon: Icons.fiber_new_outlined,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                IconLine(icon: Icons.event_outlined, text: formatDate(activity.date)),
                if (activity.options.isNotEmpty)
                  IconLine(
                    icon: Icons.auto_awesome_outlined,
                    text: activity.options.map((ActivityOption option) => option.title).take(3).join(' · '),
                  ),
                if (activity.note.isNotEmpty)
                  IconLine(icon: Icons.edit_note_outlined, text: activity.note, fontSize: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// تفاصيل النشاط: بنوده (أيقونات/نجوم/نص) وملاحظة المعلّمة.
class ActivityDetailPage extends StatelessWidget {
  const ActivityDetailPage({super.key, required this.id});

  final int id;

  static Route<void> route(int id) => MaterialPageRoute<void>(
        builder: (BuildContext context) => ActivityDetailPage(id: id),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<DetailCubit<Activity>>(
      create: (BuildContext context) => DetailCubit<Activity>(() => api.activity(id))..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.todayActivity)),
        body: BlocBuilder<DetailCubit<Activity>, DetailState<Activity>>(
          builder: (BuildContext context, DetailState<Activity> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(failure: state.failure!, onRetry: () => context.read<DetailCubit<Activity>>().load()),
              );
            }
            final Activity activity = state.data!;
            final AppColors colors = context.colors;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ChildAvatar(name: activity.studentName, url: activity.studentAvatar, size: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(activity.studentName,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.ink)),
                          const SizedBox(height: 5),
                          IconLine(icon: Icons.event_outlined, text: formatDate(activity.date), fontSize: 13),
                          if (activity.publishedAt != null)
                            IconLine(
                              icon: Icons.publish_outlined,
                              text: formatDateTime(activity.publishedAt),
                              fontSize: 13,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...activity.options.map((ActivityOption option) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OptionCard(option: option),
                    )),
                if (activity.note.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  SoftNote(text: activity.note, icon: Icons.edit_note_outlined),
                ],
                const SizedBox(height: 16),
                _ActivityPdfButton(activity: activity),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.option});

  final ActivityOption option;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return AppCard(
      child: Row(
        children: <Widget>[
          Icon(
            option.type == 'stars'
                ? Icons.star_outline
                : (option.type == 'icons' ? Icons.emoji_emotions_outlined : Icons.notes_outlined),
            size: 18,
            color: colors.primaryInk,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(option.title, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
          ),
          if (option.type == 'stars')
            Row(
              children: List<Widget>.generate(
                option.maxStars ?? 5,
                (int index) => Icon(
                  index < (option.stars ?? 0) ? Icons.star : Icons.star_border,
                  size: 18,
                  color: colors.sun,
                ),
              ),
            )
          else if (option.type == 'icons')
            Row(
              children: option.images
                  .take(4)
                  .map((String url) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Image.network(
                          url,
                          width: 26,
                          height: 26,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
                              Icon(Icons.image_not_supported_outlined, size: 20, color: colors.muted),
                        ),
                      ))
                  .toList(),
            )
          else
            Flexible(
              child: Text(
                option.text ?? '',
                textAlign: TextAlign.end,
                style: TextStyle(color: colors.body),
              ),
            ),
        ],
      ),
    );
  }
}

/// تحميل تقرير اليوم PDF — الرابط مؤقّت يطلبه التطبيق عند الضغط.
class _ActivityPdfButton extends StatefulWidget {
  const _ActivityPdfButton({required this.activity});

  final Activity activity;

  @override
  State<_ActivityPdfButton> createState() => _ActivityPdfButtonState();
}

class _ActivityPdfButtonState extends State<_ActivityPdfButton> {
  bool _busy = false;

  Future<void> _open() async {
    if (_busy) {
      return;
    }
    final AppL10n l10n = AppL10n.of(context);
    setState(() => _busy = true);
    try {
      final String direct = widget.activity.pdfUrl ?? '';
      final String url = direct.isNotEmpty ? direct : await context.read<ParentApi>().activityPdf(widget.activity.id);
      if (!mounted) {
        return;
      }
      if (url.isEmpty) {
        showInfoSnack(context, l10n.invoicePdfFailed);
      } else {
        await const NativeBridge().openUrl(url);
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        showFailureSnack(context, failure);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return OutlinedButton.icon(
      onPressed: _busy ? null : _open,
      icon: _busy
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.picture_as_pdf_outlined, size: 18),
      label: Text(l10n.activityPdf),
    );
  }
}
