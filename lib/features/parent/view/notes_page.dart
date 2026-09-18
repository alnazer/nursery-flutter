import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/parent_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';

/// ملاحظات المعلّمة المشاركة مع ولي الأمر.
class NotesPage extends StatelessWidget {
  const NotesPage({super.key, required this.childId, required this.childName});

  final int childId;
  final String childName;

  static Route<void> route(int childId, String childName) => MaterialPageRoute<void>(
        builder: (BuildContext context) => NotesPage(childId: childId, childName: childName),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notesTitle)),
      body: BlocProvider<PagedCubit<ChildNote>>(
        create: (BuildContext context) =>
            PagedCubit<ChildNote>((int page) => api.notes(childId, page: page))..load(),
        child: PagedListView<PagedCubit<ChildNote>, ChildNote>(
          itemBuilder: (BuildContext context, ChildNote note) => _NoteTile(note: note),
        ),
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note});

  final ChildNote note;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool positive = note.type == 'positive';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconBadge(
            icon: positive ? Icons.sentiment_satisfied_alt_outlined : Icons.sticky_note_2_outlined,
            color: positive ? colors.green : colors.primaryInk,
            background: positive ? colors.greenSoft : colors.soft,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(note.by, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 6),
                Text(note.note, style: TextStyle(color: colors.body, height: 1.6, fontSize: 14)),
                const SizedBox(height: 6),
                IconLine(icon: Icons.schedule_outlined, text: formatDateTime(note.createdAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
