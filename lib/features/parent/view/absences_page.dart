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
import '../../common/paged_cubit.dart';
import '../../common/child_filter.dart';
import 'absence_form_page.dart';
import '../../common/failure_view.dart';

/// بلاغات الغياب: العرض والإلغاء والتبليغ عن غياب جديد.
class AbsencesPage extends StatefulWidget {
  const AbsencesPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const AbsencesPage(),
      );

  @override
  State<AbsencesPage> createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  bool _upcoming = false;
  int? _child;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<PagedCubit<AbsenceItem>>(
      key: ValueKey<String>('$_upcoming|$_child'),
      create: (BuildContext context) => PagedCubit<AbsenceItem>(
        (int page) => api.absences(page: page, upcoming: _upcoming, studentId: _child),
      )..load(),
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(title: Text(l10n.absencesTitle)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _report(context, api),
            icon: const Icon(Icons.event_busy_outlined),
            label: Text(l10n.reportAbsence),
          ),
          body: Column(
            children: <Widget>[
              FilterBar<bool>(
                selected: _upcoming,
                onSelected: (bool value) => setState(() => _upcoming = value),
                options: <FilterOption<bool>>[
                  FilterOption<bool>(value: false, label: l10n.filterAll),
                  FilterOption<bool>(value: true, label: l10n.filterUpcoming, icon: Icons.upcoming_outlined),
                ],
              ),
              ChildFilterBar(selected: _child, onSelected: (int? value) => setState(() => _child = value)),
              Expanded(
                child: PagedListView<PagedCubit<AbsenceItem>, AbsenceItem>(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemBuilder: (BuildContext context, AbsenceItem item) =>
                      _AbsenceTile(absence: item, api: api),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// يختار الطفل أولاً حين يكون لولي الأمر أكثر من طفل.
  Future<void> _report(BuildContext context, ParentApi api) async {
    final AppL10n l10n = AppL10n.of(context);
    final PagedCubit<AbsenceItem> cubit = context.read<PagedCubit<AbsenceItem>>();
    final List<Child> children = await api.children();
    if (!context.mounted || children.isEmpty) {
      return;
    }
    Child? child = children.first;
    if (children.length > 1) {
      child = await showModalBottomSheet<Child>(
        context: context,
        builder: (BuildContext sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.selectChild,
                    style: TextStyle(fontWeight: FontWeight.w700, color: sheetContext.colors.ink)),
              ),
              ...children.map((Child item) => ListTile(
                    leading: ChildAvatar(name: item.firstName, url: item.avatarUrl, size: 40),
                    title: Text(item.name),
                    onTap: () => Navigator.of(sheetContext).pop(item),
                  )),
            ],
          ),
        ),
      );
    }
    if (child == null || !context.mounted) {
      return;
    }
    final bool? saved = await Navigator.of(context).push<bool>(
      AbsenceFormPage.route(childId: child.id, childName: child.name),
    );
    if (saved == true) {
      cubit.load(refresh: true);
    }
  }
}

class _AbsenceTile extends StatelessWidget {
  const _AbsenceTile({required this.absence, required this.api});

  final AbsenceItem absence;
  final ParentApi api;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconBadge(
            icon: Icons.event_busy_outlined,
            color: colors.sun,
            background: colors.sunSoft,
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
                      child: Text(formatDate(absence.date),
                          style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                    ),
                    if (absence.typeLabel.isNotEmpty)
                      StatusChip(
                        text: absence.typeLabel,
                        color: colors.sun,
                        background: colors.sunSoft,
                        icon: Icons.label_outline,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (absence.note.isNotEmpty)
                  IconLine(icon: Icons.sticky_note_2_outlined, text: absence.note, fontSize: 13),
                if (absence.cancellable)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: () async {
                        final PagedCubit<AbsenceItem> cubit = context.read<PagedCubit<AbsenceItem>>();
                        try {
                          await api.cancelAbsence(absence.id);
                          if (context.mounted) {
                            showSuccessSnack(context, l10n.absenceCancelled);
                            cubit.load(refresh: true);
                          }
                        } on ApiFailure catch (failure) {
                          if (context.mounted) {
                            showFailureSnack(context, failure);
                          }
                        }
                      },
                      icon: Icon(Icons.undo, size: 18, color: colors.coral),
                      label: Text(l10n.absenceCancel, style: TextStyle(color: colors.coral)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
