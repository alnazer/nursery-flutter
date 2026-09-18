import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/staff_api.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import '../../common/failure_view.dart';

/// طلبات تصحيح البصمة: القائمة مع سحب الطلب، وطلب جديد.
class CorrectionsPage extends StatelessWidget {
  const CorrectionsPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const CorrectionsPage(),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final StaffApi api = context.read<StaffApi>();

    return BlocProvider<PagedCubit<Correction>>(
      create: (BuildContext context) => PagedCubit<Correction>((int page) => api.corrections(page: page))..load(),
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(title: Text(l10n.correctionsTitle)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final bool? saved = await Navigator.of(context).push<bool>(CorrectionFormPage.route());
              if (saved == true && context.mounted) {
                context.read<PagedCubit<Correction>>().load(refresh: true);
              }
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.newCorrection),
          ),
          body: PagedListView<PagedCubit<Correction>, Correction>(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemBuilder: (BuildContext context, Correction item) => _CorrectionTile(correction: item, api: api),
          ),
        ),
      ),
    );
  }
}

class _CorrectionTile extends StatelessWidget {
  const _CorrectionTile({required this.correction, required this.api});

  final Correction correction;
  final StaffApi api;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final bool approved = correction.status == 'approved';
    final bool rejected = correction.status == 'rejected' || correction.status == 'cancelled';

    final Color accent = approved ? colors.green : (rejected ? colors.coral : colors.sun);
    final Color accentSoft = approved ? colors.greenSoft : (rejected ? colors.coralSoft : colors.sunSoft);
    final bool isOut = correction.kind == 'out';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconBadge(
            icon: isOut ? Icons.logout : Icons.login,
            color: accent,
            background: accentSoft,
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
                      child: Text(isOut ? l10n.correctionOut : l10n.correctionIn,
                          style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                    ),
                    StatusChip(
                      text: correction.statusLabel,
                      color: accent,
                      background: accentSoft,
                      icon: approved
                          ? Icons.check_circle_outline
                          : (rejected ? Icons.cancel_outlined : Icons.schedule),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                IconLine(icon: Icons.event_outlined, text: formatDate(correction.date)),
                IconLine(icon: Icons.access_time, text: correction.requestedTime),
                if (correction.reason.isNotEmpty)
                  IconLine(icon: Icons.sticky_note_2_outlined, text: correction.reason, fontSize: 13),
                if (correction.canWithdraw)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: () async {
                        final PagedCubit<Correction> cubit = context.read<PagedCubit<Correction>>();
                        try {
                          await api.withdrawCorrection(correction.id);
                          if (context.mounted) {
                            showSuccessSnack(context, l10n.withdrawn);
                            cubit.load(refresh: true);
                          }
                        } on ApiFailure catch (failure) {
                          if (context.mounted) {
                            showFailureSnack(context, failure);
                          }
                        }
                      },
                      icon: Icon(Icons.undo, size: 18, color: colors.coral),
                      label: Text(l10n.withdraw, style: TextStyle(color: colors.coral)),
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

/// نموذج طلب تصحيح: اليوم ونوع البصمة والوقت الصحيح والسبب.
class CorrectionFormPage extends StatefulWidget {
  const CorrectionFormPage({super.key, this.date});

  final String? date;

  static Route<bool> route({String? date}) => MaterialPageRoute<bool>(
        builder: (BuildContext context) => CorrectionFormPage(date: date),
      );

  @override
  State<CorrectionFormPage> createState() => _CorrectionFormPageState();
}

class _CorrectionFormPageState extends State<CorrectionFormPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _reason = TextEditingController();

  late DateTime _date;
  String _kind = 'in';
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  bool _busy = false;
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    _date = DateTime.tryParse(widget.date ?? '') ?? DateTime.now().subtract(const Duration(days: 1));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  String get _isoDate =>
      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  String get _isoTime =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _submit() async {
    final FormState? form = _form.currentState;
    if (form == null || !form.validate() || _busy) {
      return;
    }
    final AppL10n l10n = AppL10n.of(context);
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await context.read<StaffApi>().storeCorrection(
            date: _isoDate,
            kind: _kind,
            requestedTime: _isoTime,
            reason: _reason.text.trim(),
          );
      if (mounted) {
        showSuccessSnack(context, l10n.correctionSent);
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newCorrection)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.pickDate,
                suffixIcon: const Icon(Icons.calendar_today, size: 18),
              ),
              child: Text(formatDate(_isoDate), style: TextStyle(color: colors.ink)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: SegmentedButton<String>(
                  segments: <ButtonSegment<String>>[
                    ButtonSegment<String>(value: 'in', label: Text(l10n.correctionIn)),
                    ButtonSegment<String>(value: 'out', label: Text(l10n.correctionOut)),
                  ],
                  selected: <String>{_kind},
                  onSelectionChanged: (Set<String> values) => setState(() => _kind = values.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(16),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.correctionTime,
                suffixIcon: const Icon(Icons.schedule, size: 18),
              ),
              child: Text(_isoTime, style: TextStyle(color: colors.ink)),
            ),
          ),
          const SizedBox(height: 14),
          Form(
            key: _form,
            child: TextFormField(
              controller: _reason,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.correctionReason, alignLabelWithHint: true),
              validator: (String? value) =>
                  (value == null || value.trim().length < 3) ? l10n.fieldRequired : null,
            ),
          ),
          if (_failure != null) ...<Widget>[
            const SizedBox(height: 12),
            FailureView(failure: _failure!, compact: true),
          ],
          const SizedBox(height: 16),
          PrimaryButton(label: l10n.send, busy: _busy, onPressed: _submit),
        ],
      ),
    );
  }
}
