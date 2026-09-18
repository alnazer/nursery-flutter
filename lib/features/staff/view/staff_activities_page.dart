import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/staff_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/child_avatar.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import 'activity_form_page.dart';
import '../../common/confirm_dialog.dart';
import '../../common/failure_view.dart';

/// أنشطة الطلاب: بانتظار النشر والمنشورة، مع نشر فردي أو جماعي.
class StaffActivitiesPage extends StatefulWidget {
  const StaffActivitiesPage({super.key});

  @override
  State<StaffActivitiesPage> createState() => _StaffActivitiesPageState();
}

class _StaffActivitiesPageState extends State<StaffActivitiesPage> {
  final TextEditingController _search = TextEditingController();

  String _status = 'unpublished';
  String _query = '';
  int? _classroom;
  bool _mine = false;
  List<Classroom> _classrooms = <Classroom>[];

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    try {
      final List<Classroom> rooms = await context.read<StaffApi>().classrooms();
      if (mounted) {
        setState(() => _classrooms = rooms);
      }
    } catch (_) {
      // تُترك فارغة فيختفي شريط الفصول
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final StaffApi api = context.read<StaffApi>();

    return BlocProvider<PagedCubit<StaffActivity>>(
      key: ValueKey<String>('$_status|$_query|$_classroom|$_mine'),
      create: (BuildContext context) => PagedCubit<StaffActivity>(
        (int page) => api.activities(
          page: page,
          status: _status,
          search: _query.isEmpty ? null : _query,
          classroom: _classroom,
          mine: _mine,
        ),
      )..load(),
      child: Builder(
        builder: (BuildContext context) => Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: (String value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            FilterBar<String>(
              selected: _status,
              onSelected: (String value) => setState(() => _status = value),
              options: <FilterOption<String>>[
                FilterOption<String>(value: 'unpublished', label: l10n.filterUnpublished),
                FilterOption<String>(value: 'published', label: l10n.filterPublished),
                FilterOption<String>(value: '', label: l10n.filterAll),
              ],
              trailing: _status == 'unpublished'
                  ? TextButton(
                      onPressed: () => _publishAll(context, api),
                      child: Text(l10n.publishAll),
                    )
                  : null,
            ),
            FilterBar<bool>(
              selected: _mine,
              onSelected: (bool value) => setState(() => _mine = value),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              options: <FilterOption<bool>>[
                FilterOption<bool>(value: false, label: l10n.filterEveryone),
                FilterOption<bool>(value: true, label: l10n.filterMine, icon: Icons.person_outline),
              ],
            ),
            if (_classrooms.isNotEmpty)
              FilterBar<int?>(
                selected: _classroom,
                onSelected: (int? value) => setState(() => _classroom = value),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                options: <FilterOption<int?>>[
                  FilterOption<int?>(value: null, label: l10n.allClassrooms),
                  ..._classrooms.map((Classroom room) => FilterOption<int?>(value: room.id, label: room.title)),
                ],
              ),
            Expanded(
              child: PagedListView<PagedCubit<StaffActivity>, StaffActivity>(
                itemBuilder: (BuildContext context, StaffActivity item) =>
                    _ActivityRow(activity: item, api: api),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publishAll(BuildContext context, StaffApi api) async {
    final AppL10n l10n = AppL10n.of(context);
    final PagedCubit<StaffActivity> cubit = context.read<PagedCubit<StaffActivity>>();
    final List<int> ids = cubit.state.items
        .where((StaffActivity activity) => activity.canPublish && !activity.published)
        .map((StaffActivity activity) => activity.id)
        .toList();
    if (ids.isEmpty) {
      return;
    }
    final Map<String, dynamic> result = await api.publishMany(ids);
    if (!context.mounted) {
      return;
    }
    final List<dynamic> published =
        result['published'] is List ? result['published'] as List<dynamic> : <dynamic>[];
    showInfoSnack(context, l10n.publishedCount('${published.length}'));
    cubit.load(refresh: true);
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity, required this.api});

  final StaffActivity activity;
  final StaffApi api;

  Future<void> _run(BuildContext context, Future<void> Function() action, String done) async {
    final PagedCubit<StaffActivity> cubit = context.read<PagedCubit<StaffActivity>>();
    try {
      await action();
      if (context.mounted) {
        showSuccessSnack(context, done);
        cubit.load(refresh: true);
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }

  Future<void> _edit(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);
    final PagedCubit<StaffActivity> cubit = context.read<PagedCubit<StaffActivity>>();
    try {
      final Map<String, dynamic> full = await api.activity(activity.id);
      final Map<String, dynamic> values =
          full['values'] is Map ? Map<String, dynamic>.from(full['values'] as Map) : <String, dynamic>{};
      final bool? saved = await navigator.push(ActivityFormPage.editRoute(
        activityId: activity.id,
        studentId: activity.studentId,
        studentName: activity.studentName,
        avatarUrl: activity.studentAvatar,
        values: values,
        note: '${full['note'] ?? activity.note}',
        files: ActivityFile.listFrom(full['files']),
      ));
      if (saved == true) {
        cubit.load(refresh: true);
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final AppL10n l10n = AppL10n.of(context);
    final bool yes = await showConfirmDialog(
      context,
      title: l10n.deleteActivity,
      message: l10n.deleteActivityConfirm,
      confirmLabel: l10n.delete,
      icon: Icons.delete_outline,
      confirmIcon: Icons.delete_outline,
      destructive: true,
    );
    if (yes && context.mounted) {
      await _run(context, () => api.deleteActivity(activity.id), l10n.activityDeleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final bool hasMenu = activity.canUpdate || activity.canDelete || (activity.published && activity.canPublish);

    return AppCard(
      child: Row(
        children: <Widget>[
          ChildAvatar(name: activity.studentName, url: activity.studentAvatar, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(activity.studentName, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 4),
                Text(
                  <String>[
                    formatDate(activity.date),
                    if (activity.addedBy.isNotEmpty) l10n.addedBy(activity.addedBy),
                  ].join(' · '),
                  style: TextStyle(color: colors.muted, fontSize: 12),
                ),
                if (activity.note.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    activity.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.body, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          if (activity.published)
            StatusChip(text: l10n.published, color: colors.green, background: colors.greenSoft)
          else if (activity.canPublish)
            TextButton(
              onPressed: () => _run(context, () => api.publishActivity(activity.id), l10n.activityPublished),
              child: Text(l10n.publish),
            ),
          if (hasMenu)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colors.muted),
              onSelected: (String value) {
                switch (value) {
                  case 'edit':
                    _edit(context);
                    break;
                  case 'unpublish':
                    _run(context, () => api.unpublishActivity(activity.id), l10n.activityUnpublished);
                    break;
                  case 'delete':
                    _confirmDelete(context);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                if (activity.canUpdate)
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 10),
                        Text(l10n.editActivity),
                      ],
                    ),
                  ),
                if (activity.published && activity.canPublish)
                  PopupMenuItem<String>(
                    value: 'unpublish',
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.visibility_off_outlined, size: 18),
                        const SizedBox(width: 10),
                        Text(l10n.unpublish),
                      ],
                    ),
                  ),
                if (activity.canDelete)
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.delete_outline, size: 18, color: colors.coral),
                        const SizedBox(width: 10),
                        Text(l10n.delete, style: TextStyle(color: colors.coral)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
