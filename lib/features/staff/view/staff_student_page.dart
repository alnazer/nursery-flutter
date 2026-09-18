import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/staff_api.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/file_pick.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/util/staff_abilities.dart';
import '../../common/confirm_dialog.dart';
import '../../common/editable_avatar.dart';
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import '../../common/prompt_dialog.dart';
import '../../common/student_card_page.dart';
import 'activity_form_page.dart';
import '../../common/failure_view.dart';

/// ملف الطالب للمشرفة: بياناته وأولياء أمره، وإضافة نشاط أو ملاحظة أو غياب.
class StaffStudentPage extends StatelessWidget {
  const StaffStudentPage({super.key, required this.id, required this.name, this.avatarUrl});

  final int id;
  final String name;
  final String? avatarUrl;

  static Route<void> route({required int id, required String name, String? avatarUrl}) =>
      MaterialPageRoute<void>(
        builder: (BuildContext context) => StaffStudentPage(id: id, name: name, avatarUrl: avatarUrl),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final StaffApi api = context.read<StaffApi>();

    return BlocProvider<DetailCubit<Map<String, dynamic>>>(
      create: (BuildContext context) => DetailCubit<Map<String, dynamic>>(() => api.student(id))..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.studentTitle)),
        body: BlocBuilder<DetailCubit<Map<String, dynamic>>, DetailState<Map<String, dynamic>>>(
          builder: (BuildContext context, DetailState<Map<String, dynamic>> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(failure: state.failure!, onRetry: () => context.read<DetailCubit<Map<String, dynamic>>>().load()),
              );
            }
            final Map<String, dynamic> student = state.data ?? <String, dynamic>{};
            final AppColors colors = context.colors;
            final List<dynamic> parents =
                student['parents'] is List ? student['parents'] as List<dynamic> : <dynamic>[];
            final List<dynamic> teachers =
                student['teachers'] is List ? student['teachers'] as List<dynamic> : <dynamic>[];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    EditableAvatar(
                      name: name,
                      url: (student['avatar_url'] as String?) ?? avatarUrl,
                      size: 72,
                      editable: StaffAbilities.can(StaffAbilities.uploadDocument),
                      onPick: (UploadFile file) => api.updateStudentPhoto(id, file),
                      onChanged: (String _) => context.read<DetailCubit<Map<String, dynamic>>>().load(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${student['name'] ?? name}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.ink)),
                          const SizedBox(height: 4),
                          Text(
                            <String>[
                              if (student['birth_date'] != null) formatDate('${student['birth_date']}'),
                              if (student['assigned_activities'] != null)
                                '${student['assigned_activities']}',
                            ].join(' · '),
                            style: TextStyle(color: colors.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(ActivityFormPage.route(
                          studentId: id,
                          studentName: name,
                          avatarUrl: avatarUrl,
                        )),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(l10n.addActivity),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _addNote(context, api),
                        icon: const Icon(Icons.sticky_note_2_outlined, size: 18),
                        label: Text(l10n.addNote),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _absenceId(student) == null
                          ? OutlinedButton.icon(
                              onPressed: () => _markAbsent(context, api),
                              icon: const Icon(Icons.event_busy_outlined, size: 18),
                              label: Text(l10n.markAbsent),
                            )
                          : OutlinedButton.icon(
                              onPressed: () => _undoAbsence(context, api, _absenceId(student)!),
                              icon: const Icon(Icons.undo, size: 18),
                              label: Text(l10n.undoAbsence),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _assignActivities(context, api),
                  icon: const Icon(Icons.playlist_add_check, size: 18),
                  label: Text(l10n.assignActivities),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _uploadDocument(context, api),
                        icon: const Icon(Icons.upload_file_outlined, size: 18),
                        label: Text(l10n.addDocument),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(StudentCardPage.route(
                          studentName: name,
                          avatarUrl: avatarUrl,
                          loader: () => api.studentCard(id),
                        )),
                        icon: const Icon(Icons.qr_code_2, size: 18),
                        label: Text(l10n.cardTitle),
                      ),
                    ),
                  ],
                ),
                if (parents.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 20),
                  Text(l10n.parentsLabel, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                  const SizedBox(height: 8),
                  ...parents.whereType<Map<dynamic, dynamic>>().map((Map<dynamic, dynamic> raw) {
                    final Map<String, dynamic> parent = Map<String, dynamic>.from(raw);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('${parent['name'] ?? ''}',
                                      style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                                  if (parent['kinship'] != null)
                                    Text('${parent['kinship']}',
                                        style: TextStyle(color: colors.muted, fontSize: 12)),
                                ],
                              ),
                            ),
                            if (parent['mobile'] != null)
                              Text('${parent['mobile']}', style: TextStyle(color: colors.body, fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                if (teachers.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(l10n.teachersLabel, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Text(
                      teachers
                          .whereType<Map<dynamic, dynamic>>()
                          .map((Map<dynamic, dynamic> teacher) => '${teacher['name'] ?? ''}')
                          .join('، '),
                      style: TextStyle(color: colors.body),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _addNote(BuildContext context, StaffApi api) async {
    final AppL10n l10n = AppL10n.of(context);
    final _NoteResult? result = await showDialog<_NoteResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => const _NoteDialog(),
    );
    if (result == null || !context.mounted) {
      return;
    }
    try {
      await api.storeNote(
        studentId: id,
        type: result.type,
        note: result.note,
        shareWithParent: result.share,
      );
      if (context.mounted) {
        showSuccessSnack(context, l10n.noteSaved);
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }

  /// إسناد تعريفات أنشطة للطالب (يضيف دون إزالة المسند سابقاً).
  Future<void> _assignActivities(BuildContext context, StaffApi api) async {
    final AppL10n l10n = AppL10n.of(context);
    final List<int>? chosen = await showDialog<List<int>>(
      context: context,
      builder: (BuildContext dialogContext) => _AssignDialog(api: api),
    );
    if (chosen == null || chosen.isEmpty || !context.mounted) {
      return;
    }
    try {
      await api.assignActivities(studentId: id, activities: chosen);
      if (context.mounted) {
        showSuccessSnack(context, l10n.activitiesAssigned);
        context.read<DetailCubit<Map<String, dynamic>>>().load();
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }

  /// اختيار ملف ثم تسميته ورفعه كمستند للطالب.
  Future<void> _uploadDocument(BuildContext context, StaffApi api) async {
    final AppL10n l10n = AppL10n.of(context);
    final UploadFile? file = await pickUploadFile(
      field: 'file',
      extensions: <String>['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (file == null || !context.mounted) {
      return;
    }
    final PromptResult? named = await showPromptDialog(
      context,
      title: l10n.addDocument,
      note: file.filename,
      label: l10n.documentTitle,
      initial: file.filename.split('.').first,
      minLength: 2,
    );
    if (named == null || named.text.isEmpty || !context.mounted) {
      return;
    }
    showInfoSnack(context, l10n.uploading);
    try {
      await api.uploadDocument(studentId: id, title: named.text, file: file);
      if (context.mounted) {
        showSuccessSnack(context, l10n.documentUploaded);
        context.read<DetailCubit<Map<String, dynamic>>>().load();
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }

  /// معرّف غياب اليوم إن كان مسجَّلاً (من today.absence.id).
  static int? _absenceId(Map<String, dynamic> student) {
    final dynamic today = student['today'];
    if (today is! Map) {
      return null;
    }
    final dynamic absence = today['absence'];

    return absence is Map ? absence['id'] as int? : null;
  }

  /// التراجع عن غياب سُجّل بالخطأ.
  Future<void> _undoAbsence(BuildContext context, StaffApi api, int absenceId) async {
    final AppL10n l10n = AppL10n.of(context);
    final bool yes = await showConfirmDialog(
      context,
      title: l10n.undoAbsence,
      message: l10n.undoAbsenceConfirm,
      icon: Icons.undo,
      destructive: true,
    );
    if (!yes || !context.mounted) {
      return;
    }
    try {
      await api.deleteAbsence(absenceId);
      if (context.mounted) {
        showSuccessSnack(context, l10n.absenceRemoved);
        context.read<DetailCubit<Map<String, dynamic>>>().load();
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }

  Future<void> _markAbsent(BuildContext context, StaffApi api) async {
    final AppL10n l10n = AppL10n.of(context);
    final String? type = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.markAbsent),
        content: Text(l10n.markAbsentConfirm),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('excused'),
            child: Text(l10n.absenceExcused),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop('unexcused'),
            child: Text(l10n.absenceUnexcused),
          ),
        ],
      ),
    );
    if (type == null || !context.mounted) {
      return;
    }
    try {
      await api.storeAbsence(studentId: id, type: type);
      if (context.mounted) {
        showSuccessSnack(context, l10n.absenceSavedStaff);
        context.read<DetailCubit<Map<String, dynamic>>>().load();
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }
}

/// نتيجة حوار الملاحظة.
class _NoteResult {
  const _NoteResult({required this.type, required this.note, required this.share});

  final String type;
  final String note;
  final bool share;
}

/// حوار إضافة ملاحظة — يملك متحكّم النص ويتخلّص منه بنفسه.
class _NoteDialog extends StatefulWidget {
  const _NoteDialog();

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  static const int _minLength = 10;

  final TextEditingController _note = TextEditingController();
  String _type = 'positive';
  bool _share = true;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return AlertDialog(
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.colors.ink),
      title: Row(
        children: <Widget>[
          Icon(Icons.sticky_note_2_outlined, size: 22, color: context.colors.primaryInk),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.addNote)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SegmentedButton<String>(
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(value: 'positive', label: Text(l10n.notePositive)),
                ButtonSegment<String>(value: 'negative', label: Text(l10n.noteNegative)),
              ],
              selected: <String>{_type},
              onSelectionChanged: (Set<String> values) => setState(() => _type = values.first),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _note,
              builder: (BuildContext context, TextEditingValue value, Widget? child) => TextField(
                controller: _note,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  counterText: value.text.trim().length < _minLength ? l10n.minLengthHint('$_minLength') : null,
                ),
              ),
            ),
            SwitchListTile.adaptive(
              value: _share,
              onChanged: (bool value) => setState(() => _share = value),
              title: Text(l10n.noteShare, style: const TextStyle(fontSize: 13)),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: <Widget>[
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _note,
          builder: (BuildContext context, TextEditingValue value, Widget? child) => DialogActions(
            confirmLabel: l10n.send,
            confirmIcon: Icons.send,
            onConfirm: value.text.trim().length < _minLength
                ? null
                : () => Navigator.of(context).pop(
                      _NoteResult(type: _type, note: value.text.trim(), share: _share),
                    ),
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}

/// حوار اختيار الأنشطة المراد إسنادها.
class _AssignDialog extends StatefulWidget {
  const _AssignDialog({required this.api});

  final StaffApi api;

  @override
  State<_AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<_AssignDialog> {
  final Set<int> _selected = <int>{};

  List<ActivityDefinition> _definitions = <ActivityDefinition>[];
  bool _loading = true;
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failure = null;
    });
    try {
      final List<ActivityDefinition> rows = await widget.api.activityDefinitions();
      if (mounted) {
        setState(() {
          _definitions = rows;
          _loading = false;
        });
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failure = failure;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return AlertDialog(
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.colors.ink),
      title: Row(
        children: <Widget>[
          Icon(Icons.playlist_add_check, size: 22, color: context.colors.primaryInk),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.assignActivities)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            : _failure != null
                ? FailureView(failure: _failure!, compact: true, onRetry: _load)
                : _definitions.isEmpty
                    ? EmptyNote(text: l10n.emptyList)
                    : ListView(
                        shrinkWrap: true,
                        children: _definitions
                            .map((ActivityDefinition definition) => CheckboxListTile(
                                  value: _selected.contains(definition.id),
                                  onChanged: (bool? value) => setState(() {
                                    if (value == true) {
                                      _selected.add(definition.id);
                                    } else {
                                      _selected.remove(definition.id);
                                    }
                                  }),
                                  title: Text(definition.title),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ))
                            .toList(),
                      ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: <Widget>[
        DialogActions(
          confirmLabel: l10n.send,
          confirmIcon: Icons.send,
          onConfirm: _selected.isEmpty ? null : () => Navigator.of(context).pop(_selected.toList()),
          onCancel: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
