import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/file_pick.dart';
import '../../l10n/app_localizations.dart';
import 'confirm_dialog.dart';

/// نتيجة حوار الإدخال: النص، والمرفق إن طُلب.
class PromptResult {
  const PromptResult({required this.text, this.attachment});

  final String text;
  final UploadFile? attachment;
}

/// حوار إدخال نص (مع مرفق اختياري).
///
/// المتحكّم يعيش داخل الحوار ويُتخلَّص منه في dispose الخاص به: التخلّص منه فور
/// عودة showDialog يقع قبل انتهاء حركة الإغلاق والحقل ما يزال في الشجرة، فينهار
/// التطبيق عند تفكيكها (_dependents.isEmpty).
Future<PromptResult?> showPromptDialog(
  BuildContext context, {
  required String title,
  String? note,
  String? label,
  String initial = '',
  int maxLines = 1,
  int minLength = 0,
  bool withAttachment = false,
  List<String>? extensions,
  String attachmentField = 'attachment',
  String? confirmLabel,
}) {
  return showDialog<PromptResult>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => _PromptDialog(
      title: title,
      note: note,
      label: label,
      initial: initial,
      maxLines: maxLines,
      minLength: minLength,
      withAttachment: withAttachment,
      extensions: extensions,
      attachmentField: attachmentField,
      confirmLabel: confirmLabel,
    ),
  );
}

class _PromptDialog extends StatefulWidget {
  const _PromptDialog({
    required this.title,
    required this.note,
    required this.label,
    required this.initial,
    required this.maxLines,
    required this.minLength,
    required this.withAttachment,
    required this.extensions,
    required this.attachmentField,
    required this.confirmLabel,
  });

  final String title;
  final String? note;
  final String? label;
  final String initial;
  final int maxLines;
  final int minLength;
  final bool withAttachment;
  final List<String>? extensions;
  final String attachmentField;
  final String? confirmLabel;

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  late final TextEditingController _text = TextEditingController(text: widget.initial);
  UploadFile? _attachment;
  bool _picking = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    if (_picking) {
      return;
    }
    setState(() => _picking = true);
    final UploadFile? file = await pickUploadFile(
      field: widget.attachmentField,
      extensions: widget.extensions,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _picking = false;
      if (file != null) {
        _attachment = file;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return AlertDialog(
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colors.ink),
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.note != null && widget.note!.isNotEmpty) ...<Widget>[
              Text(widget.note!, style: TextStyle(fontSize: 12, color: colors.muted)),
              const SizedBox(height: 10),
            ],
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _text,
              builder: (BuildContext context, TextEditingValue value, Widget? child) => TextField(
                controller: _text,
                maxLines: widget.maxLines,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: widget.label,
                  border: const OutlineInputBorder(),
                  counterText: widget.minLength > 0 && value.text.trim().length < widget.minLength
                      ? l10n.minLengthHint('${widget.minLength}')
                      : null,
                ),
              ),
            ),
            if (widget.withAttachment) ...<Widget>[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _picking ? null : _pick,
                icon: _picking
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.attach_file, size: 18),
                label: Text(
                  _attachment?.filename ?? l10n.attachFile,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: <Widget>[
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _text,
          builder: (BuildContext context, TextEditingValue value, Widget? child) => DialogActions(
            confirmLabel: widget.confirmLabel ?? l10n.send,
            confirmIcon: Icons.send,
            onConfirm: value.text.trim().length < widget.minLength
                ? null
                : () => Navigator.of(context).pop(
                      PromptResult(text: value.text.trim(), attachment: _attachment),
                    ),
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
