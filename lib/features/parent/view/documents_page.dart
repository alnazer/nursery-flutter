import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/parent_api.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import '../../common/failure_view.dart';

/// مستندات الطفل: الموجودة، والناقصة، والمنتهية أو التي قاربت الانتهاء.
class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key, required this.childId, required this.childName});

  final int childId;
  final String childName;

  static Route<void> route(int childId, String childName) => MaterialPageRoute<void>(
        builder: (BuildContext context) => DocumentsPage(childId: childId, childName: childName),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<DetailCubit<Map<String, dynamic>>>(
      create: (BuildContext context) =>
          DetailCubit<Map<String, dynamic>>(() => api.documents(childId))..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.documentsTitle)),
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
            final Map<String, dynamic> data = state.data ?? <String, dynamic>{};
            final AppColors colors = context.colors;
            final List<dynamic> items = data['items'] is List ? data['items'] as List<dynamic> : <dynamic>[];
            final List<dynamic> missing = data['missing'] is List ? data['missing'] as List<dynamic> : <dynamic>[];
            final List<dynamic> expired = data['expired'] is List ? data['expired'] as List<dynamic> : <dynamic>[];
            final List<dynamic> expiring = data['expiring'] is List ? data['expiring'] as List<dynamic> : <dynamic>[];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Text(childName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 14),
                if (missing.isNotEmpty) ...<Widget>[
                  _Group(
                    title: l10n.documentsMissing,
                    color: colors.coral,
                    background: colors.coralSoft,
                    lines: missing.map((dynamic item) => '$item').toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (expired.isNotEmpty) ...<Widget>[
                  _Group(
                    title: l10n.documentsExpired,
                    color: colors.coral,
                    background: colors.coralSoft,
                    lines: expired.map(_label).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (expiring.isNotEmpty) ...<Widget>[
                  _Group(
                    title: l10n.documentsExpiring,
                    color: colors.sun,
                    background: colors.sunSoft,
                    lines: expiring.map(_label).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (items.isEmpty && missing.isEmpty && expired.isEmpty && expiring.isEmpty)
                  EmptyNote(text: l10n.emptyList),
                ...items.whereType<Map<dynamic, dynamic>>().map((Map<dynamic, dynamic> raw) {
                  final Map<String, dynamic> item = Map<String, dynamic>.from(raw);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => const NativeBridge().openUrl('${item['url'] ?? ''}'),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.description_outlined, color: colors.primaryInk),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('${item['title'] ?? ''}',
                                    style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                                const SizedBox(height: 4),
                                Text(
                                  <String>[
                                    if (item['uploaded_at'] != null) formatDate('${item['uploaded_at']}'),
                                    if (item['expires_at'] != null) formatDate('${item['expires_at']}'),
                                  ].join(' · '),
                                  style: TextStyle(color: colors.muted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.open_in_new, size: 18, color: colors.muted),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _label(dynamic item) {
    if (item is Map) {
      final String title = '${item['title'] ?? ''}';
      final String date = item['date'] == null ? '' : formatDate('${item['date']}');

      return date.isEmpty ? title : '$title · $date';
    }

    return '$item';
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.color, required this.background, required this.lines});

  final String title;
  final Color color;
  final Color background;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 8),
          ...lines.map((String line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $line', style: TextStyle(color: colors.ink, fontSize: 13)),
              )),
        ],
      ),
    );
  }
}
