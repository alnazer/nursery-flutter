import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/staff_api.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import '../../common/prompt_dialog.dart';
import '../../common/failure_view.dart';

/// مخالفاتي مع إرسال التبرير قبل انتهاء المهلة.
class ViolationsPage extends StatelessWidget {
  const ViolationsPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const ViolationsPage(),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final StaffApi api = context.read<StaffApi>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.violationsTitle)),
      body: BlocProvider<PagedCubit<Violation>>(
        create: (BuildContext context) => PagedCubit<Violation>((int page) => api.violations(page: page))..load(),
        child: PagedListView<PagedCubit<Violation>, Violation>(
          itemBuilder: (BuildContext context, Violation item) => _ViolationTile(violation: item, api: api),
        ),
      ),
    );
  }
}

class _ViolationTile extends StatelessWidget {
  const _ViolationTile({required this.violation, required this.api});

  final Violation violation;
  final StaffApi api;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    final bool open = violation.canJustify;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconBadge(
            icon: open ? Icons.gavel_outlined : Icons.verified_outlined,
            color: open ? colors.sun : colors.muted,
            background: open ? colors.sunSoft : colors.bg2,
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
                      child: Text(violation.typeLabel,
                          style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                    ),
                    StatusChip(
                      text: violation.statusLabel,
                      color: open ? colors.sun : colors.muted,
                      background: open ? colors.sunSoft : colors.bg2,
                      icon: open ? Icons.priority_high : Icons.check_circle_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                IconLine(icon: Icons.event_outlined, text: formatDate(violation.date)),
                if (violation.minutes > 0)
                  IconLine(icon: Icons.timelapse_outlined, text: l10n.minutesCount('${violation.minutes}')),
                if (violation.deadline.isNotEmpty)
                  IconLine(
                    icon: Icons.hourglass_bottom_outlined,
                    text: l10n.decisionDeadline(formatDate(violation.deadline)),
                    color: open ? colors.coral : null,
                  ),
                if (violation.justification.isNotEmpty)
                  IconLine(
                    icon: Icons.record_voice_over_outlined,
                    text: violation.justification,
                    fontSize: 13,
                    maxLines: 4,
                  ),
                if (open)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: () => _justify(context),
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: Text(l10n.justify),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _justify(BuildContext context) async {
    final AppL10n l10n = AppL10n.of(context);
    final PromptResult? result = await showPromptDialog(
      context,
      title: l10n.justification,
      initial: violation.justification,
      maxLines: 4,
      minLength: 5,
      withAttachment: true,
      extensions: <String>['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.text.isEmpty || !context.mounted) {
      return;
    }
    try {
      await api.justifyViolation(violation.id, result.text, attachment: result.attachment);
      if (context.mounted) {
        showSuccessSnack(context, l10n.justifySent);
        context.read<PagedCubit<Violation>>().load(refresh: true);
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }
}
