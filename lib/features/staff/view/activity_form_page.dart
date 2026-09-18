import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/staff_api.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../../widgets/child_avatar.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/parent_models.dart';
import '../../common/activity_window_note.dart';
import '../../common/attachment_picker.dart';
import '../../common/attachments_view.dart';
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import '../../common/failure_view.dart';

/// إضافة نشاط لطالب أو تعديل نشاط قبل نشره:
/// بنود أيقونات ونجوم ونص، وملاحظة، ونشر مباشر.
class ActivityFormPage extends StatelessWidget {
  const ActivityFormPage({
    super.key,
    required this.studentId,
    required this.studentName,
    this.avatarUrl,
    this.activityId,
    this.initialValues = const <String, dynamic>{},
    this.initialNote = '',
    this.initialFiles = const <ActivityFile>[],
  });

  final int studentId;
  final String studentName;
  final String? avatarUrl;

  /// معرّف النشاط عند التعديل (null عند الإضافة).
  final int? activityId;
  final Map<String, dynamic> initialValues;
  final String initialNote;

  /// مرفقات النشاط المحفوظة (وضع التعديل).
  final List<ActivityFile> initialFiles;

  bool get isEdit => activityId != null;

  static Route<bool> route({
    required int studentId,
    required String studentName,
    String? avatarUrl,
  }) =>
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => ActivityFormPage(
          studentId: studentId,
          studentName: studentName,
          avatarUrl: avatarUrl,
        ),
      );

  /// شاشة التعديل: القيم الحالية تأتي من GET /student-activities/{id}.
  static Route<bool> editRoute({
    required int activityId,
    required int studentId,
    required String studentName,
    String? avatarUrl,
    Map<String, dynamic> values = const <String, dynamic>{},
    String note = '',
    List<ActivityFile> files = const <ActivityFile>[],
  }) =>
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => ActivityFormPage(
          studentId: studentId,
          studentName: studentName,
          avatarUrl: avatarUrl,
          activityId: activityId,
          initialValues: values,
          initialNote: note,
          initialFiles: files,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final StaffApi api = context.read<StaffApi>();

    return BlocProvider<DetailCubit<ActivityForm>>(
      create: (BuildContext context) => DetailCubit<ActivityForm>(() => api.activityForm(studentId))..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(isEdit ? l10n.editActivity : l10n.addActivity)),
        body: BlocBuilder<DetailCubit<ActivityForm>, DetailState<ActivityForm>>(
          builder: (BuildContext context, DetailState<ActivityForm> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(failure: state.failure!, onRetry: () => context.read<DetailCubit<ActivityForm>>().load()),
              );
            }

            return _FormBody(
              form: state.data ?? ActivityForm.empty,
              studentName: studentName,
              avatarUrl: avatarUrl,
              api: api,
              activityId: activityId,
              initialValues: initialValues,
              initialNote: initialNote,
              initialFiles: initialFiles,
            );
          },
        ),
      ),
    );
  }
}

class _FormBody extends StatefulWidget {
  const _FormBody({
    required this.form,
    required this.studentName,
    required this.avatarUrl,
    required this.api,
    required this.activityId,
    required this.initialValues,
    required this.initialNote,
    required this.initialFiles,
  });

  final ActivityForm form;
  final String studentName;
  final String? avatarUrl;
  final StaffApi api;
  final int? activityId;
  final Map<String, dynamic> initialValues;
  final String initialNote;
  final List<ActivityFile> initialFiles;

  bool get isEdit => activityId != null;

  @override
  State<_FormBody> createState() => _FormBodyState();
}

class _FormBodyState extends State<_FormBody> {
  final Map<int, List<String>> _icons = <int, List<String>>{};
  final Map<int, int> _stars = <int, int>{};
  final Map<int, TextEditingController> _texts = <int, TextEditingController>{};
  final TextEditingController _note = TextEditingController();

  /// مرفقات مختارة لم تُرفع بعد (وضع الإضافة) — تُرفع بعد حفظ النشاط.
  final List<UploadFile> _pending = <UploadFile>[];

  /// مرفقات محفوظة على الخادم (وضع التعديل).
  late final List<ActivityFile> _files = List<ActivityFile>.from(widget.initialFiles);

  /// أقصى عدد مرفقات للنشاط — نفس حدّ الخادم.
  static const int _maxFiles = 5;

  bool _publish = false;
  bool _busy = false;
  bool _uploading = false;
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    _seed();
  }

  /// تعبئة الحقول بقيم النشاط عند التعديل. القيمة تُفسَّر حسب نوع البند.
  void _seed() {
    if (!widget.isEdit) {
      return;
    }
    _note.text = widget.initialNote;
    for (final ActivityDefinition definition in widget.form.definitions) {
      final dynamic value = widget.initialValues['${definition.id}'];
      if (value == null) {
        continue;
      }
      switch (definition.type) {
        case 'icons':
          if (value is List) {
            _icons[definition.id] = value.map((dynamic item) => '$item').toList();
          } else {
            _icons[definition.id] =
                '$value'.split(',').map((String part) => part.trim()).where((String part) => part.isNotEmpty).toList();
          }
          break;
        case 'stars':
          _stars[definition.id] = value is num ? value.toInt() : (int.tryParse('$value') ?? 0);
          break;
        default:
          _controller(definition.id).text = '$value';
      }
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _texts.values) {
      controller.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  TextEditingController _controller(int id) => _texts.putIfAbsent(id, () => TextEditingController());

  Map<String, dynamic> _options() {
    final Map<String, dynamic> options = <String, dynamic>{};
    for (final ActivityDefinition definition in widget.form.definitions) {
      switch (definition.type) {
        case 'icons':
          final List<String> selected = _icons[definition.id] ?? <String>[];
          if (selected.isNotEmpty) {
            options['${definition.id}'] = selected;
          }
          break;
        case 'stars':
          final int? value = _stars[definition.id];
          if (value != null && value > 0) {
            options['${definition.id}'] = value;
          }
          break;
        default:
          final String text = _controller(definition.id).text.trim();
          if (text.isNotEmpty) {
            options['${definition.id}'] = text;
          }
      }
    }

    return options;
  }

  /// إضافة مرفق: في التعديل يُرفع فوراً، وفي الإضافة ينتظر حفظ النشاط.
  Future<void> _addAttachment() async {
    final AppL10n l10n = AppL10n.of(context);
    final int used = _files.length + _pending.length;
    if (used >= _maxFiles) {
      showInfoSnack(context, l10n.attachmentsLimit('$_maxFiles'));

      return;
    }
    final UploadFile? file = await pickAttachment(context);
    if (file == null || !mounted) {
      return;
    }
    if (!widget.isEdit) {
      setState(() => _pending.add(file));

      return;
    }
    setState(() => _uploading = true);
    try {
      final List<ActivityFile> saved = await widget.api.uploadActivityFiles(widget.activityId!, <UploadFile>[file]);
      if (mounted) {
        setState(() {
          _files.addAll(saved);
          _uploading = false;
        });
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() => _uploading = false);
        showFailureSnack(context, failure);
      }
    }
  }

  Future<void> _deleteAttachment(ActivityFile file) async {
    if (!widget.isEdit) {
      return;
    }
    try {
      await widget.api.deleteActivityFile(widget.activityId!, file.id);
      if (mounted) {
        setState(() => _files.removeWhere((ActivityFile row) => row.id == file.id));
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        showFailureSnack(context, failure);
      }
    }
  }

  /// رفع المرفقات المنتظرة بعد إنشاء النشاط — فشلها لا يُلغي النشاط المحفوظ.
  Future<void> _uploadPending(int activityId) async {
    if (_pending.isEmpty) {
      return;
    }
    try {
      await widget.api.uploadActivityFiles(activityId, _pending);
    } on ApiFailure catch (failure) {
      if (mounted) {
        showFailureSnack(context, failure);
      }
    }
  }

  Future<void> _submit() async {
    final AppL10n l10n = AppL10n.of(context);
    final Map<String, dynamic> options = _options();
    if (options.isEmpty || _busy) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final String? note = _note.text.trim().isEmpty ? null : _note.text.trim();
      if (widget.isEdit) {
        await widget.api.updateActivity(id: widget.activityId!, options: options, note: note);
      } else {
        final Map<String, dynamic> created = await widget.api.storeActivity(
          studentId: widget.form.studentId,
          options: options,
          date: widget.form.date,
          note: note,
          publish: _publish,
        );
        await _uploadPending((created['id'] as int?) ?? 0);
      }
      if (mounted) {
        showSuccessSnack(context, l10n.activitySaved);
        Navigator.of(context).pop(true);
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failure = failure;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final ActivityForm form = widget.form;
    // النافذة مغلقة: لا معنى لعرض النموذج — يظهر العدّاد وحده ثم يظهر النموذج عند الفتح.
    final bool closed = !widget.isEdit && form.window.enabled && !form.window.open;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            ChildAvatar(name: widget.studentName, url: widget.avatarUrl, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(form.studentName.isEmpty ? widget.studentName : form.studentName,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.ink)),
                  const SizedBox(height: 4),
                  Text(l10n.activityDay(formatDate(form.date)),
                      style: TextStyle(color: colors.muted, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (form.hasExisting && !widget.isEdit) ...<Widget>[
          SoftNote(text: l10n.activityExists, icon: Icons.info_outline),
          const SizedBox(height: 12),
        ],
        if (!widget.isEdit && form.window.enabled) ...<Widget>[
          // العدّاد يحدّث النموذج تلقائياً عند فتح النافذة أو إغلاقها
          ActivityWindowNote(
            window: form.window,
            blocked: form.canAdd ? '' : (form.blocked.isEmpty ? l10n.activityBlocked : form.blocked),
            onExpired: () => context.read<DetailCubit<ActivityForm>>().load(),
          ),
          const SizedBox(height: 12),
        ] else if (!widget.isEdit && !form.canAdd) ...<Widget>[
          ErrorNote(text: form.blocked.isEmpty ? l10n.activityBlocked : form.blocked),
          const SizedBox(height: 12),
        ],
        if (closed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: <Widget>[
                Icon(Icons.lock_outline, size: 16, color: colors.muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.formHiddenUntilOpen,
                    style: TextStyle(color: colors.muted, fontSize: 12, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        if (!closed) ...<Widget>[
        ...form.definitions.map((ActivityDefinition definition) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DefinitionCard(
                definition: definition,
                icons: _icons[definition.id] ?? <String>[],
                stars: _stars[definition.id] ?? 0,
                controller: definition.type == 'text' || definition.type == 'note'
                    ? _controller(definition.id)
                    : null,
                onIconToggle: (String value) => setState(() {
                  final List<String> selected = List<String>.from(_icons[definition.id] ?? <String>[]);
                  if (selected.contains(value)) {
                    selected.remove(value);
                  } else if (definition.multiple) {
                    selected.add(value);
                  } else {
                    selected
                      ..clear()
                      ..add(value);
                  }
                  _icons[definition.id] = selected;
                }),
                onStars: (int value) => setState(() => _stars[definition.id] = value),
              ),
            )),
        const SizedBox(height: 4),
        // المرفقات: صور من الكاميرا أو المعرض أو ملف PDF
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.attach_file, size: 18, color: colors.primaryInk),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.attachments,
                      style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink),
                    ),
                  ),
                  if (_uploading)
                    const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    TextButton.icon(
                      onPressed: _addAttachment,
                      icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: Text(l10n.attachAdd),
                    ),
                ],
              ),
              if (_files.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                AttachmentsView(
                  files: _files,
                  title: false,
                  onDelete: widget.isEdit ? _deleteAttachment : null,
                ),
              ],
              if (_pending.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _pending
                      .map((UploadFile file) => Chip(
                            avatar: Icon(
                              file.contentType.startsWith('image/')
                                  ? Icons.image_outlined
                                  : Icons.picture_as_pdf_outlined,
                              size: 18,
                              color: colors.primaryInk,
                            ),
                            label: Text(file.filename, overflow: TextOverflow.ellipsis),
                            onDeleted: () => setState(() => _pending.remove(file)),
                          ))
                      .toList(),
                ),
              ],
              if (_files.isEmpty && _pending.isEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  l10n.attachHint('$_maxFiles'),
                  style: TextStyle(color: colors.muted, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n.activityNote, alignLabelWithHint: true),
        ),
        if (form.templates.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Text(l10n.activityTemplates, style: TextStyle(color: colors.muted, fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: form.templates
                .map((String template) => ActionChip(
                      label: Text(template, overflow: TextOverflow.ellipsis),
                      onPressed: () => setState(() => _note.text = template),
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 12),
        if (!widget.isEdit)
          SwitchListTile.adaptive(
            value: _publish,
            onChanged: (bool value) => setState(() => _publish = value),
            title: Text(l10n.publishNow, style: TextStyle(color: colors.ink)),
            contentPadding: EdgeInsets.zero,
          ),
        if (_failure != null) ...<Widget>[
          const SizedBox(height: 8),
          FailureView(failure: _failure!, compact: true),
        ],
        const SizedBox(height: 12),
        PrimaryButton(
          label: l10n.saveActivity,
          busy: _busy,
          onPressed: widget.isEdit || form.canAdd ? _submit : null,
        ),
        ],
      ],
    );
  }
}

class _DefinitionCard extends StatelessWidget {
  const _DefinitionCard({
    required this.definition,
    required this.icons,
    required this.stars,
    required this.controller,
    required this.onIconToggle,
    required this.onStars,
  });

  final ActivityDefinition definition;
  final List<String> icons;
  final int stars;
  final TextEditingController? controller;
  final void Function(String value) onIconToggle;
  final void Function(int value) onStars;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(definition.title, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
          const SizedBox(height: 10),
          if (definition.type == 'stars')
            Row(
              children: List<Widget>.generate(
                definition.max ?? 5,
                (int index) => IconButton(
                  onPressed: () => onStars(index + 1),
                  icon: Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: colors.sun,
                    size: 30,
                  ),
                ),
              ),
            )
          else if (definition.type == 'icons')
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: definition.choices.map((ActivityChoice choice) {
                final bool selected = icons.contains(choice.value);

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onIconToggle(choice.value),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: selected ? colors.soft : colors.bg2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? colors.primaryInk : colors.line,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: choice.imageUrl == null || choice.imageUrl!.isEmpty
                        ? Center(
                            child: Text(
                              choice.value,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: colors.ink),
                            ),
                          )
                        : Image.network(
                            choice.imageUrl!,
                            errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
                                Icon(Icons.emoji_emotions_outlined, color: colors.muted),
                          ),
                  ),
                );
              }).toList(),
            )
          else
            TextField(
              controller: controller,
              maxLines: 2,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
        ],
      ),
    );
  }
}
