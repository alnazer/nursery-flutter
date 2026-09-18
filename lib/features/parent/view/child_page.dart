import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/api/api_client.dart';
import '../../common/detail_cubit.dart';
import '../../common/editable_avatar.dart';
import '../../common/list_views.dart';
import 'attendance_page.dart';
import 'child_card_page.dart';
import 'documents_page.dart';
import 'notes_page.dart';
import 'weekly_summary_page.dart';
import '../../common/failure_view.dart';

/// ملف الطفل: حالة اليوم، والفصل، والمعلّمات، والمستندات الناقصة.
class ChildPage extends StatelessWidget {
  const ChildPage({super.key, required this.id, required this.name});

  final int id;
  final String name;

  static Route<void> route(int id, String name) => MaterialPageRoute<void>(
        builder: (BuildContext context) => ChildPage(id: id, name: name),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<DetailCubit<Map<String, dynamic>>>(
      create: (BuildContext context) => DetailCubit<Map<String, dynamic>>(() => api.child(id))..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(name)),
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
            final Map<String, dynamic> child = state.data ?? <String, dynamic>{};
            final AppColors colors = context.colors;
            final Map<String, dynamic> today =
                child['today'] is Map ? Map<String, dynamic>.from(child['today'] as Map) : <String, dynamic>{};
            final Map<String, dynamic> documents = child['documents'] is Map
                ? Map<String, dynamic>.from(child['documents'] as Map)
                : <String, dynamic>{};
            final List<dynamic> teachers = child['teachers'] is List ? child['teachers'] as List<dynamic> : <dynamic>[];
            final Map<String, dynamic> subscription = child['subscription'] is Map
                ? Map<String, dynamic>.from(child['subscription'] as Map)
                : <String, dynamic>{};

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(AttendancePage.route(id, name)),
                        icon: const Icon(Icons.event_available_outlined, size: 18),
                        label: Text(l10n.attendanceMonthTitle),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(NotesPage.route(id, name)),
                        icon: const Icon(Icons.sticky_note_2_outlined, size: 18),
                        label: Text(l10n.notesTitle),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(DocumentsPage.route(id, name)),
                        icon: const Icon(Icons.folder_outlined, size: 18),
                        label: Text(l10n.documentsTitle),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(ChildCardPage.route(
                          id,
                          name,
                          avatarUrl: child['avatar_url'] as String?,
                        )),
                        icon: const Icon(Icons.qr_code_2, size: 18),
                        label: Text(l10n.cardTitle),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(WeeklySummaryPage.route(id, name)),
                  icon: const Icon(Icons.calendar_view_week_outlined, size: 18),
                  label: Text(l10n.weeklyTitle),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          EditableAvatar(
                            name: '${child['name'] ?? name}',
                            url: child['avatar_url'] as String?,
                            size: 72,
                            onPick: (UploadFile file) => api.updateChildPhoto(id, file),
                            onChanged: (String _) => context.read<DetailCubit<Map<String, dynamic>>>().load(),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text('${child['name'] ?? name}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.ink)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        <String>[
                          '${child['status'] ?? ''}',
                          if (child['birth_date'] != null) formatDate('${child['birth_date']}'),
                        ].where((String part) => part.trim().isNotEmpty).join(' · '),
                        style: TextStyle(color: colors.muted, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Text('${today['status'] ?? ''}', style: TextStyle(color: colors.body)),
                    ],
                  ),
                ),
                if (child['media_consent'] != null) ...<Widget>[
                  const SizedBox(height: 12),
                  _MediaConsentCard(childId: id, value: child['media_consent'] == true),
                ],
                if (teachers.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('👩‍🏫', style: TextStyle(color: colors.ink)),
                        const SizedBox(height: 6),
                        Text(
                          teachers
                              .whereType<Map<dynamic, dynamic>>()
                              .map((Map<dynamic, dynamic> teacher) => '${teacher['name'] ?? ''}')
                              .join('، '),
                          style: TextStyle(color: colors.body),
                        ),
                      ],
                    ),
                  ),
                ],
                if (subscription.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  AppCard(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text('${subscription['title'] ?? ''}',
                              style: TextStyle(color: colors.ink, fontWeight: FontWeight.w700)),
                        ),
                        Text(
                          '${formatDate('${subscription['starts_at'] ?? ''}')} - ${formatDate('${subscription['ends_at'] ?? ''}')}',
                          style: TextStyle(color: colors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                if (documents.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  AppCard(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.folder_outlined, color: colors.primaryInk),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${documents['missing'] ?? 0} / ${documents['expired'] ?? 0} / ${documents['expiring'] ?? 0}',
                            style: TextStyle(color: colors.body),
                          ),
                        ),
                      ],
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
}


/// موافقة نشر صور الطفل — تُغيّر فوراً على الخادم.
class _MediaConsentCard extends StatefulWidget {
  const _MediaConsentCard({required this.childId, required this.value});

  final int childId;
  final bool value;

  @override
  State<_MediaConsentCard> createState() => _MediaConsentCardState();
}

class _MediaConsentCardState extends State<_MediaConsentCard> {
  late bool _value = widget.value;
  bool _busy = false;

  Future<void> _toggle(bool next) async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _value = next;
    });
    try {
      final bool saved = await context.read<ParentApi>().setMediaConsent(widget.childId, next);
      if (mounted) {
        setState(() {
          _value = saved;
          _busy = false;
        });
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() {
          _value = !next;
          _busy = false;
        });
        showFailureSnack(context, failure);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return AppCard(
      padding: EdgeInsets.zero,
      child: SwitchListTile.adaptive(
        value: _value,
        onChanged: _busy ? null : _toggle,
        secondary: Icon(Icons.photo_camera_outlined, color: colors.primaryInk),
        title: Text(l10n.mediaConsent, style: TextStyle(color: colors.ink)),
        subtitle: Text(
          _value ? l10n.mediaConsentOn : l10n.mediaConsentOff,
          style: TextStyle(color: colors.muted, fontSize: 13),
        ),
      ),
    );
  }
}
