import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_failure.dart';
import '../../core/native/native_bridge.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/image_export.dart';
import '../../core/models/parent_models.dart';
import '../../l10n/app_localizations.dart';
import 'failure_view.dart';

/// شبكة مرفقات النشاط: مصغّرات الصور وأيقونة PDF.
/// الضغط يفتح المعاينة، والضغط المطوّل أو زر التحميل يحفظ الملف.
class AttachmentsView extends StatelessWidget {
  const AttachmentsView({
    super.key,
    required this.files,
    this.onDelete,
    this.title = true,
  });

  final List<ActivityFile> files;

  /// حذف المرفق (للمشرفة قبل النشر) — null يخفي زر الحذف.
  final Future<void> Function(ActivityFile file)? onDelete;
  final bool title;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const SizedBox.shrink();
    }
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title) ...<Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.attach_file, size: 18, color: colors.primaryInk),
              const SizedBox(width: 8),
              Text(
                l10n.attachmentsCount('${files.length}'),
                style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: files
              .map((ActivityFile file) => _FileTile(file: file, onDelete: onDelete))
              .toList(),
        ),
      ],
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({required this.file, required this.onDelete});

  final ActivityFile file;
  final Future<void> Function(ActivityFile file)? onDelete;

  static const double _size = 104;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return SizedBox(
      width: _size,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => openAttachment(context, file),
                child: Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    color: colors.bg2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.line),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: file.isImage
                      ? Image.network(
                          file.url,
                          fit: BoxFit.cover,
                          width: _size,
                          height: _size,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
                              Icon(Icons.broken_image_outlined, color: colors.muted),
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) =>
                              progress == null
                                  ? child
                                  : const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                        )
                      : Icon(Icons.picture_as_pdf_outlined, size: 38, color: colors.coral),
                ),
              ),
              if (onDelete != null)
                PositionedDirectional(
                  top: -6,
                  end: -6,
                  child: _DeleteButton(file: file, onDelete: onDelete!),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: colors.body),
          ),
          if (file.sizeLabel.isNotEmpty)
            Text(file.sizeLabel, style: TextStyle(fontSize: 10, color: colors.muted)),
        ],
      ),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  const _DeleteButton({required this.file, required this.onDelete});

  final ActivityFile file;
  final Future<void> Function(ActivityFile file) onDelete;

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Material(
      color: colors.surface,
      shape: CircleBorder(side: BorderSide(color: colors.line)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _busy
            ? null
            : () async {
                setState(() => _busy = true);
                await widget.onDelete(widget.file);
                if (mounted) {
                  setState(() => _busy = false);
                }
              },
        child: SizedBox(
          width: 26,
          height: 26,
          child: _busy
              ? const Padding(
                  padding: EdgeInsets.all(6),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.close, size: 16, color: colors.coral),
        ),
      ),
    );
  }
}

/// يفتح المرفق: الصور في عارض داخل التطبيق، وPDF في متصفّح النظام.
Future<void> openAttachment(BuildContext context, ActivityFile file) async {
  if (!file.isImage) {
    await const NativeBridge().openUrl(file.url);

    return;
  }
  await Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (BuildContext context) => AttachmentViewerPage(file: file),
  ));
}

/// عارض صورة بملء الشاشة مع التكبير والتحميل.
class AttachmentViewerPage extends StatefulWidget {
  const AttachmentViewerPage({super.key, required this.file});

  final ActivityFile file;

  @override
  State<AttachmentViewerPage> createState() => _AttachmentViewerPageState();
}

class _AttachmentViewerPageState extends State<AttachmentViewerPage> {
  bool _busy = false;

  Future<void> _download() async {
    if (_busy) {
      return;
    }
    final AppL10n l10n = AppL10n.of(context);
    setState(() => _busy = true);
    try {
      final DownloadedFile file = await context
          .read<ApiClient>()
          .downloadUrl(widget.file.url, fallbackName: widget.file.name);
      if (!mounted) {
        return;
      }
      final String? path = await saveBytes(
        filename: widget.file.name.isEmpty ? file.filename : widget.file.name,
        bytes: Uint8List.fromList(file.bytes),
      );
      if (mounted && path != null) {
        showSuccessSnack(context, l10n.fileSaved);
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        showFailureSnack(context, failure);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.file.name, style: const TextStyle(fontSize: 15)),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.download,
            onPressed: _busy ? null : _download,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.network(
            widget.file.url,
            fit: BoxFit.contain,
            errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
                const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) =>
                progress == null ? child : const CircularProgressIndicator(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
