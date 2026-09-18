import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../common/failure_view.dart';

/// بلاغ غياب لمدى من الأيام.
class AbsenceFormPage extends StatefulWidget {
  const AbsenceFormPage({super.key, required this.childId, required this.childName});

  final int childId;
  final String childName;

  static Route<bool> route({required int childId, required String childName}) => MaterialPageRoute<bool>(
        builder: (BuildContext context) => AbsenceFormPage(childId: childId, childName: childName),
      );

  @override
  State<AbsenceFormPage> createState() => _AbsenceFormPageState();
}

class _AbsenceFormPageState extends State<AbsenceFormPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _note = TextEditingController();

  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();
  bool _busy = false;
  ApiFailure? _failure;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String _iso(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  Future<void> _pick({required bool isFrom}) async {
    final DateTime now = DateTime.now();
    final DateTime initial = isFrom ? _from : _to;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to.isBefore(_from)) {
          _to = picked;
        }
      } else {
        _to = picked.isBefore(_from) ? _from : picked;
      }
    });
  }

  Future<void> _submit() async {
    final FormState? form = _form.currentState;
    if (form == null || !form.validate() || _busy) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await context.read<ParentApi>().reportAbsence(
            studentId: widget.childId,
            from: _iso(_from),
            to: _iso(_to),
            note: _note.text.trim(),
          );
      if (mounted) {
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
      appBar: AppBar(title: Text(l10n.reportAbsence)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(widget.childName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.ink)),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(child: _DateField(label: l10n.absenceFrom, value: _iso(_from), onTap: () => _pick(isFrom: true))),
              const SizedBox(width: 12),
              Expanded(child: _DateField(label: l10n.absenceTo, value: _iso(_to), onTap: () => _pick(isFrom: false))),
            ],
          ),
          const SizedBox(height: 16),
          Form(
            key: _form,
            child: TextFormField(
              controller: _note,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: l10n.absenceNote,
                alignLabelWithHint: true,
                errorText: _failure?.fieldError('note'),
              ),
              validator: (String? value) =>
                  (value == null || value.trim().length < 3) ? l10n.fieldRequired : null,
            ),
          ),
          if (_failure != null && _failure!.errors.isEmpty) ...<Widget>[
            const SizedBox(height: 8),
            FailureView(failure: _failure!, compact: true),
          ],
          const SizedBox(height: 12),
          PrimaryButton(label: l10n.send, busy: _busy, onPressed: _submit),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_today, size: 18)),
        child: Text(value, style: TextStyle(color: context.colors.ink)),
      ),
    );
  }
}
