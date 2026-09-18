import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// يصوّر ما بداخل RepaintBoundary صورةً PNG.
/// [targetWidth] عرض الصورة المطلوب بالبكسل — تُحسب منه دقّة التصوير.
Future<Uint8List?> captureAsPng(GlobalKey key, {double targetWidth = 1080}) async {
  final RenderObject? object = key.currentContext?.findRenderObject();
  if (object is! RenderRepaintBoundary) {
    return null;
  }
  final double width = object.size.width;
  final double ratio = width <= 0 ? 3 : (targetWidth / width).clamp(1.0, 6.0).toDouble();
  final ui.Image image = await object.toImage(pixelRatio: ratio);
  try {
    final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);

    return data?.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

/// يفتح حوار الحفظ في النظام ويكتب البايتات. يعيد المسار أو null إن أُلغي.
Future<String?> saveBytes({required String filename, required Uint8List bytes}) async {
  try {
    return await FilePicker.platform.saveFile(fileName: filename, bytes: bytes);
  } catch (_) {
    return null;
  }
}
