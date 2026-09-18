import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// تصميم بطاقة الطالب كما حُفظ في لوحة التحكم.
/// كل المقاسات بالمليمتر (البطاقة القياسية 85.6 × 54)، وحجم الخط بالنقطة (pt).
class CardDesign {
  const CardDesign({
    required this.width,
    required this.height,
    required this.radius,
    required this.faces,
  });

  final double width;
  final double height;
  final double radius;
  final Map<String, CardFace> faces;

  static const CardDesign empty = CardDesign(
    width: 85.6,
    height: 54,
    radius: 3,
    faces: <String, CardFace>{},
  );

  bool get isEmpty => faces.isEmpty;

  double get ratio => height <= 0 ? 0.63 : height / width;

  CardFace? face(String key) => faces[key];

  bool get hasBack {
    final CardFace? back = faces['back'];

    return back != null && back.elements.isNotEmpty;
  }

  factory CardDesign.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> size =
        json['size'] is Map ? Map<String, dynamic>.from(json['size'] as Map) : <String, dynamic>{};
    final Map<String, dynamic> faces =
        json['faces'] is Map ? Map<String, dynamic>.from(json['faces'] as Map) : <String, dynamic>{};
    final Map<String, CardFace> parsed = <String, CardFace>{};
    faces.forEach((String key, dynamic value) {
      if (value is Map) {
        parsed[key] = CardFace.fromJson(Map<String, dynamic>.from(value));
      }
    });

    return CardDesign(
      width: cardNumber(size['w'], 85.6),
      height: cardNumber(size['h'], 54),
      radius: cardNumber(json['radius'], 3),
      faces: parsed,
    );
  }
}

class CardFace {
  const CardFace({required this.background, required this.elements});

  final CardBackground background;
  final List<CardElement> elements;

  factory CardFace.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['elements'] is List ? json['elements'] as List<dynamic> : <dynamic>[];

    return CardFace(
      background: CardBackground.fromJson(
        json['bg'] is Map ? Map<String, dynamic>.from(json['bg'] as Map) : <String, dynamic>{},
      ),
      elements: raw
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => CardElement.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class CardBackground {
  const CardBackground({
    required this.color,
    required this.color2,
    required this.angle,
    required this.image,
    required this.fit,
    required this.opacity,
  });

  final Color color;
  final Color? color2;
  final double angle;
  final String? image;
  final String fit;
  final double opacity;

  factory CardBackground.fromJson(Map<String, dynamic> json) => CardBackground(
        color: cardColor(json['color']) ?? Colors.white,
        color2: cardColor(json['color2']),
        angle: cardNumber(json['angle'], 135),
        image: json['image'] is String && (json['image'] as String).isNotEmpty ? json['image'] as String : null,
        fit: '${json['fit'] ?? 'cover'}',
        opacity: cardNumber(json['opacity'], 1),
      );
}

/// عنصر واحد على وجه البطاقة. النوع يحدّد أي الحقول تُستعمل.
class CardElement {
  const CardElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.rotate,
    required this.opacity,
    required this.visible,
    required this.radius,
    required this.borderWidth,
    required this.borderColor,
    required this.text,
    required this.fontSize,
    required this.color,
    required this.bold,
    required this.italic,
    required this.underline,
    required this.align,
    required this.valign,
    required this.lineHeight,
    required this.wrap,
    required this.shrink,
    required this.hideEmpty,
    required this.background,
    required this.padding,
    required this.shape,
    required this.fit,
    required this.src,
    required this.qrForeground,
    required this.qrBackground,
    required this.margin,
    required this.fill,
    required this.fill2,
    required this.angle,
    required this.ellipse,
  });

  final String id;
  final String type;
  final double x;
  final double y;
  final double w;
  final double h;
  final double rotate;
  final double opacity;
  final bool visible;
  final double radius;
  final double borderWidth;
  final Color borderColor;

  // نص
  final String text;
  final double fontSize;
  final Color color;
  final bool bold;
  final bool italic;
  final bool underline;
  final String align;
  final String valign;
  final double lineHeight;
  final bool wrap;
  final bool shrink;
  final bool hideEmpty;
  final Color? background;
  final double padding;

  // صورة الطالب
  final String shape;
  final String fit;

  // صورة
  final String? src;

  // رمز QR
  final Color qrForeground;
  final Color qrBackground;
  final int margin;

  // شكل
  final Color fill;
  final Color? fill2;
  final double angle;
  final bool ellipse;

  factory CardElement.fromJson(Map<String, dynamic> json) => CardElement(
        id: '${json['id'] ?? ''}',
        type: '${json['type'] ?? 'shape'}',
        x: cardNumber(json['x'], 0),
        y: cardNumber(json['y'], 0),
        w: cardNumber(json['w'], 20),
        h: cardNumber(json['h'], 10),
        rotate: cardNumber(json['rotate'], 0),
        opacity: cardNumber(json['opacity'], 1),
        visible: json['visible'] != false,
        radius: cardNumber(json['radius'], 0),
        borderWidth: cardNumber(json['borderWidth'], 0),
        borderColor: cardColor(json['borderColor']) ?? const Color(0xFF000000),
        text: '${json['text'] ?? ''}',
        fontSize: cardNumber(json['size'], 9),
        color: cardColor(json['color']) ?? const Color(0xFF111827),
        bold: json['bold'] == true,
        italic: json['italic'] == true,
        underline: json['underline'] == true,
        align: '${json['align'] ?? 'right'}',
        valign: '${json['valign'] ?? 'middle'}',
        lineHeight: cardNumber(json['lineHeight'], 1.25),
        wrap: json['wrap'] != false,
        shrink: json['shrink'] == true,
        hideEmpty: json['hideEmpty'] == true,
        background: cardColor(json['bg']),
        padding: cardNumber(json['padding'], 0),
        shape: '${json['shape'] ?? 'rounded'}',
        fit: '${json['fit'] ?? 'cover'}',
        src: json['src'] is String && (json['src'] as String).isNotEmpty ? json['src'] as String : null,
        qrForeground: cardColor(json['fg']) ?? const Color(0xFF000000),
        qrBackground: cardColor(json['bgc']) ?? Colors.white,
        margin: cardNumber(json['margin'], 1).round(),
        fill: cardColor(json['fill']) ?? const Color(0xFF4F46E5),
        fill2: cardColor(json['fill2']),
        angle: cardNumber(json['angle'], 90),
        ellipse: json['ellipse'] == true,
      );
}

/// كل ما تحتاجه الشاشة لرسم البطاقة: التصميم + قيم الطالب + الصور.
class StudentCard {
  const StudentCard({
    required this.qr,
    required this.qrImage,
    required this.photoUrl,
    required this.branchLogoUrl,
    required this.appLogoUrl,
    required this.uploadsBase,
    required this.vars,
    required this.design,
  });

  final String qr;
  final Uint8List? qrImage;
  final String? photoUrl;
  final String? branchLogoUrl;
  final String? appLogoUrl;
  final String uploadsBase;
  final Map<String, String> vars;
  final CardDesign design;

  static const StudentCard empty = StudentCard(
    qr: '',
    qrImage: null,
    photoUrl: null,
    branchLogoUrl: null,
    appLogoUrl: null,
    uploadsBase: '',
    vars: <String, String>{},
    design: CardDesign.empty,
  );

  /// رابط صورة عنصر: `@app_logo` و`@branch_logo` أو ملف مرفوع في مجلد التصاميم.
  String? imageUrl(String? src) {
    if (src == null || src.isEmpty) {
      return null;
    }
    if (src == '@app_logo') {
      return appLogoUrl;
    }
    if (src == '@branch_logo') {
      return branchLogoUrl;
    }
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return src;
    }
    if (uploadsBase.isEmpty) {
      return null;
    }

    return uploadsBase.endsWith('/') ? '$uploadsBase$src' : '$uploadsBase/$src';
  }

  factory StudentCard.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> assets =
        json['assets'] is Map ? Map<String, dynamic>.from(json['assets'] as Map) : <String, dynamic>{};
    final Map<String, dynamic> vars =
        json['vars'] is Map ? Map<String, dynamic>.from(json['vars'] as Map) : <String, dynamic>{};
    final Map<String, String> values = <String, String>{};
    vars.forEach((String key, dynamic value) {
      values[key] = value == null ? '' : '$value';
    });

    return StudentCard(
      qr: '${json['qr'] ?? ''}',
      qrImage: decodeDataUri(json['qr_image'] as String?),
      photoUrl: json['photo_url'] as String?,
      branchLogoUrl: json['branch_logo_url'] as String?,
      appLogoUrl: assets['app_logo'] as String?,
      uploadsBase: '${assets['uploads_base'] ?? ''}',
      vars: values,
      design: json['design'] is Map
          ? CardDesign.fromJson(Map<String, dynamic>.from(json['design'] as Map))
          : CardDesign.empty,
    );
  }
}

double cardNumber(dynamic value, double fallback) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }

  return fallback;
}

/// `#rgb` و`#rgba` و`#rrggbb` و`#rrggbbaa` و`transparent`.
Color? cardColor(dynamic value) {
  if (value is! String) {
    return null;
  }
  final String raw = value.trim().toLowerCase();
  if (raw.isEmpty) {
    return null;
  }
  if (raw == 'transparent') {
    return const Color(0x00000000);
  }
  if (!raw.startsWith('#')) {
    return null;
  }
  String hex = raw.substring(1);
  if (hex.length == 3 || hex.length == 4) {
    hex = hex.split('').map((String part) => '$part$part').join();
  }
  if (hex.length == 6) {
    hex = 'ff$hex';
  } else if (hex.length == 8) {
    // في CSS الشفافية في الآخر، وفي Flutter في الأول
    hex = '${hex.substring(6)}${hex.substring(0, 6)}';
  } else {
    return null;
  }
  final int? parsed = int.tryParse(hex, radix: 16);

  return parsed == null ? null : Color(parsed);
}

/// يفكّ `data:image/png;base64,…` إلى بايتات.
Uint8List? decodeDataUri(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final int comma = value.indexOf(',');
  final String payload = comma >= 0 ? value.substring(comma + 1) : value;
  try {
    return base64Decode(payload);
  } catch (_) {
    return null;
  }
}
