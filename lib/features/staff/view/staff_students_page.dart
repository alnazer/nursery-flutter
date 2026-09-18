import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/staff_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../core/util/staff_abilities.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/child_avatar.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import 'activity_form_page.dart';
import 'staff_student_page.dart';

/// قائمة الطلاب مع حالة اليوم لكل طالب.
class StaffStudentsPage extends StatefulWidget {
  const StaffStudentsPage({super.key});

  /// نفس القائمة كشاشة مستقلة لاختيار طالب (من لوحة اليوم مثلاً).
  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(title: Text(AppL10n.of(context).pickStudent)),
          body: const SafeArea(child: StaffStudentsPage()),
        ),
      );

  @override
  State<StaffStudentsPage> createState() => _StaffStudentsPageState();
}

class _StaffStudentsPageState extends State<StaffStudentsPage> {
  final TextEditingController _search = TextEditingController();

  String _query = '';
  int? _classroom;
  List<Classroom> _classrooms = <Classroom>[];

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  /// الفصول تُحمّل مرة واحدة، وفشلها لا يمنع القائمة (يختفي الفلتر فقط).
  Future<void> _loadClassrooms() async {
    try {
      final List<Classroom> rooms = await context.read<StaffApi>().classrooms();
      if (mounted) {
        setState(() => _classrooms = rooms);
      }
    } catch (_) {
      // تُترك القائمة فارغة
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

    return BlocProvider<PagedCubit<Child>>(
      key: ValueKey<String>('$_query|$_classroom'),
      create: (BuildContext context) =>
          PagedCubit<Child>((int page) => api.students(page: page, search: _query, classroom: _classroom))..load(),
      child: Column(
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
          if (_classrooms.isNotEmpty)
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: <Widget>[
                  _RoomChip(
                    label: l10n.allClassrooms,
                    selected: _classroom == null,
                    onTap: () => setState(() => _classroom = null),
                  ),
                  ..._classrooms.map((Classroom room) => _RoomChip(
                        label: room.title,
                        selected: _classroom == room.id,
                        onTap: () => setState(() => _classroom = room.id),
                      )),
                ],
              ),
            ),
          Expanded(
            child: PagedListView<PagedCubit<Child>, Child>(
              itemBuilder: (BuildContext context, Child student) => _StudentTile(student: student),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student});

  final Child student;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    late final String label;
    late final Color color;
    late final Color background;
    switch (student.today.status) {
      case 'present':
        label = l10n.statusPresent;
        color = colors.green;
        background = colors.greenSoft;
        break;
      case 'checked_out':
        label = l10n.statusCheckedOut;
        color = colors.skyInk;
        background = colors.sky;
        break;
      case 'absent':
        label = l10n.statusAbsent;
        color = colors.coral;
        background = colors.coralSoft;
        break;
      default:
        label = l10n.statusNotArrived;
        color = colors.muted;
        background = colors.bg2;
    }

    return AppCard(
      onTap: () async {
        await Navigator.of(context).push(StaffStudentPage.route(
          id: student.id,
          name: student.name,
          avatarUrl: student.avatarUrl,
        ));
        if (context.mounted) {
          context.read<PagedCubit<Child>>().load(refresh: true);
        }
      },
      child: Row(
        children: <Widget>[
          ChildAvatar(name: student.firstName, url: student.avatarUrl, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(student.name, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 4),
                Text(
                  <String>[
                    student.classroom,
                    if (student.today.checkedInAt != null) formatTime(student.today.checkedInAt),
                  ].where((String part) => part.isNotEmpty).join(' · '),
                  style: TextStyle(color: colors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          StatusChip(text: label, color: color, background: background),
          if (StaffAbilities.can(StaffAbilities.addActivity)) ...<Widget>[
            const SizedBox(width: 6),
            _AddActivityButton(student: student),
          ],
        ],
      ),
    );
  }
}

/// زر «+» لإضافة نشاط للطالب مباشرة من القائمة.
/// النافذة المغلقة لا تُخفيه: شاشة الإضافة نفسها تعرض العدّاد وسبب المنع.
class _AddActivityButton extends StatelessWidget {
  const _AddActivityButton({required this.student});

  final Child student;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return Tooltip(
      message: l10n.addActivity,
      child: Material(
        color: colors.soft,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final PagedCubit<Child> cubit = context.read<PagedCubit<Child>>();
            final bool? saved = await Navigator.of(context).push<bool>(ActivityFormPage.route(
              studentId: student.id,
              studentName: student.name,
              avatarUrl: student.avatarUrl,
            ));
            if (saved == true) {
              cubit.load(refresh: true);
            }
          },
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(Icons.add, size: 22, color: colors.primaryInk),
          ),
        ),
      ),
    );
  }
}

/// شريحة فصل في شريط الفلترة.
class _RoomChip extends StatelessWidget {
  const _RoomChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        selected: selected,
        onSelected: (bool _) => onTap(),
        label: Text(label),
        selectedColor: colors.primary,
        labelStyle: TextStyle(color: selected ? Colors.white : colors.ink, fontSize: 13),
        backgroundColor: colors.surface,
      ),
    );
  }
}
