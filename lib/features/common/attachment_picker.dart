import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/file_pick.dart';
import '../../l10n/app_localizations.dart';
import 'list_views.dart';

/// ورقة اختيار مرفق: التقاط بالكاميرا، أو من معرض الصور، أو ملف PDF.
/// تعيد الملف جاهزاً للرفع، أو null إن أُلغي الاختيار.
Future<UploadFile?> pickAttachment(BuildContext context, {String field = 'files'}) async {
  final _Source? source = await showModalBottomSheet<_Source>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      final AppL10n l10n = AppL10n.of(sheetContext);
      final AppColors colors = sheetContext.colors;

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: IconBadge(
                icon: Icons.photo_camera_outlined,
                color: colors.primaryInk,
                background: colors.soft,
                size: 42,
              ),
              title: Text(l10n.attachCamera, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
              onTap: () => Navigator.of(sheetContext).pop(_Source.camera),
            ),
            ListTile(
              leading: IconBadge(
                icon: Icons.photo_library_outlined,
                color: colors.skyInk,
                background: colors.sky,
                size: 42,
              ),
              title: Text(l10n.attachGallery, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
              onTap: () => Navigator.of(sheetContext).pop(_Source.gallery),
            ),
            ListTile(
              leading: IconBadge(
                icon: Icons.picture_as_pdf_outlined,
                color: colors.coral,
                background: colors.coralSoft,
                size: 42,
              ),
              title: Text(l10n.attachFile, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
              onTap: () => Navigator.of(sheetContext).pop(_Source.file),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  switch (source) {
    case _Source.camera:
      return pickImageFile(field: field, camera: true);
    case _Source.gallery:
      return pickImageFile(field: field, camera: false);
    case _Source.file:
      return pickUploadFile(field: field, extensions: <String>['jpg', 'jpeg', 'png', 'webp', 'pdf']);
    case null:
      return null;
  }
}

enum _Source { camera, gallery, file }
