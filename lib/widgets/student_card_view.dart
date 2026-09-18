import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/models/card_design.dart';

/// وجه واحد من بطاقة الطالب مرسوماً من تصميم لوحة التحكم.
/// المقاسات في التصميم بالمليمتر وحجم الخط بالنقطة، والرسم هنا يحوّلها إلى بكسل.
class StudentCardView extends StatelessWidget {
  const StudentCardView({
    super.key,
    required this.card,
    required this.face,
    this.width,
  });

  final StudentCard card;
  final String face;

  /// عرض البطاقة بالبكسل. إن تُرك فارغاً يملأ العرض المتاح.
  final double? width;

  /// نقطة واحدة (pt) = 0.352778 مليمتر.
  static const double _ptToMm = 0.352778;

  @override
  Widget build(BuildContext context) {
    if (width != null) {
      return _build(width!);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => _build(
        constraints.hasBoundedWidth ? constraints.maxWidth : 320,
      ),
    );
  }

  Widget _build(double boxWidth) {
    final CardDesign design = card.design;
    final double scale = design.width <= 0 ? 1 : boxWidth / design.width;
    final double boxHeight = design.height * scale;
    final CardFace? current = design.face(face);

    return Directionality(
      // إحداثيات التصميم من اليسار دائماً، فالوجه نفسه لا يُعكس مع لغة التطبيق
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: boxWidth,
        height: boxHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(design.radius * scale),
          child: Stack(
            children: <Widget>[
              if (current != null) _background(current.background, scale),
              if (current != null)
                ...current.elements.where((CardElement element) => element.visible).map(
                      (CardElement element) => _positioned(element, scale),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _background(CardBackground background, double scale) {
    final String? url = card.imageUrl(background.image);

    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: background.color2 == null ? background.color : null,
                gradient: background.color2 == null
                    ? null
                    : _gradient(background.color, background.color2!, background.angle),
              ),
            ),
          ),
          if (url != null)
            Positioned.fill(
              child: Opacity(
                opacity: background.opacity.clamp(0, 1).toDouble(),
                child: _network(url, _fit(background.fit)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _positioned(CardElement element, double scale) {
    Widget child = _element(element, scale);
    if (element.rotate != 0) {
      child = Transform.rotate(angle: element.rotate * math.pi / 180, child: child);
    }
    if (element.opacity < 1) {
      child = Opacity(opacity: element.opacity.clamp(0, 1).toDouble(), child: child);
    }

    return Positioned(
      left: element.x * scale,
      top: element.y * scale,
      width: element.w * scale,
      height: element.h * scale,
      child: child,
    );
  }

  Widget _element(CardElement element, double scale) {
    switch (element.type) {
      case 'text':
        return _text(element, scale);
      case 'photo':
        return _photo(element, scale);
      case 'image':
        return _image(element, scale);
      case 'qr':
        return _qr(element, scale);
      default:
        return _shape(element, scale);
    }
  }

  Widget _text(CardElement element, double scale) {
    final String value = resolveCardText(element.text, card.vars);
    if (element.hideEmpty && (value.trim().isEmpty || hasEmptyCardVar(element.text, card.vars))) {
      return const SizedBox.shrink();
    }
    final double fontSize = element.fontSize * _ptToMm * scale;
    final TextAlign align = _align(element.align);

    Widget text = Text(
      value,
      textAlign: align,
      softWrap: element.wrap,
      maxLines: element.wrap ? null : 1,
      overflow: TextOverflow.clip,
      textDirection: _isRtl(value) ? TextDirection.rtl : TextDirection.ltr,
      style: TextStyle(
        fontSize: fontSize <= 0 ? 1 : fontSize,
        height: element.lineHeight,
        color: element.color,
        fontWeight: element.bold ? FontWeight.w700 : FontWeight.w400,
        fontStyle: element.italic ? FontStyle.italic : FontStyle.normal,
        decoration: element.underline ? TextDecoration.underline : TextDecoration.none,
      ),
    );
    if (element.shrink) {
      text = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: _fittedAlignment(element.align),
        child: text,
      );
    }

    return Container(
      padding: EdgeInsets.all(element.padding * scale),
      decoration: BoxDecoration(
        color: element.background,
        borderRadius: BorderRadius.circular(element.radius * scale),
        border: element.borderWidth > 0
            ? Border.all(color: element.borderColor, width: element.borderWidth * scale)
            : null,
      ),
      child: Align(
        alignment: Alignment(0, _valign(element.valign)),
        child: SizedBox(width: double.infinity, child: text),
      ),
    );
  }

  Widget _photo(CardElement element, double scale) {
    final String? url = card.photoUrl;
    final Widget inner = url == null || url.isEmpty
        ? Container(color: element.background ?? const Color(0xFFE5E7EB))
        : _network(url, _fit(element.fit), placeholder: element.background ?? const Color(0xFFE5E7EB));
    final BorderRadius radius = element.shape == 'circle'
        ? BorderRadius.all(Radius.elliptical(element.w * scale / 2, element.h * scale / 2))
        : BorderRadius.circular(element.shape == 'rect' ? 0 : element.radius * scale);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: element.borderWidth > 0
            ? Border.all(color: element.borderColor, width: element.borderWidth * scale)
            : null,
      ),
      child: ClipRRect(borderRadius: radius, child: inner),
    );
  }

  Widget _image(CardElement element, double scale) {
    final String? url = card.imageUrl(element.src);
    if (url == null) {
      return const SizedBox.shrink();
    }
    final BorderRadius radius = BorderRadius.circular(element.radius * scale);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: element.borderWidth > 0
            ? Border.all(color: element.borderColor, width: element.borderWidth * scale)
            : null,
      ),
      child: ClipRRect(borderRadius: radius, child: _network(url, _fit(element.fit))),
    );
  }

  Widget _qr(CardElement element, double scale) {
    // هامش التصميم بالوحدات (modules) — تقريبه بجزء من ضلع الرمز يكفي بصرياً
    final double padding = element.w * scale * element.margin / 27;

    return Container(
      decoration: BoxDecoration(
        color: element.qrBackground,
        borderRadius: BorderRadius.circular(element.radius * scale),
      ),
      padding: EdgeInsets.all(padding),
      child: card.qrImage == null
          ? Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  card.qr,
                  style: TextStyle(color: element.qrForeground, fontWeight: FontWeight.w700),
                ),
              ),
            )
          : Image.memory(
              card.qrImage!,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              gaplessPlayback: true,
            ),
    );
  }

  Widget _shape(CardElement element, double scale) {
    final BorderRadius radius = element.ellipse
        ? BorderRadius.all(Radius.elliptical(element.w * scale / 2, element.h * scale / 2))
        : BorderRadius.circular(element.radius * scale);

    return Container(
      decoration: BoxDecoration(
        color: element.fill2 == null ? element.fill : null,
        gradient: element.fill2 == null ? null : _gradient(element.fill, element.fill2!, element.angle),
        borderRadius: radius,
        border: element.borderWidth > 0
            ? Border.all(color: element.borderColor, width: element.borderWidth * scale)
            : null,
      ),
    );
  }

  Widget _network(String url, BoxFit fit, {Color? placeholder}) => Image.network(
        url,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            Container(color: placeholder ?? const Color(0x00000000)),
      );

  /// زاوية CSS: صفر إلى الأعلى و90 إلى اليمين.
  static LinearGradient _gradient(Color from, Color to, double angle) {
    final double radians = angle * math.pi / 180;
    final double dx = math.sin(radians);
    final double dy = -math.cos(radians);

    return LinearGradient(
      begin: Alignment(-dx, -dy),
      end: Alignment(dx, dy),
      colors: <Color>[from, to],
    );
  }

  static BoxFit _fit(String value) {
    switch (value) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      default:
        return BoxFit.cover;
    }
  }

  static TextAlign _align(String value) {
    switch (value) {
      case 'left':
        return TextAlign.left;
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.right;
    }
  }

  static Alignment _fittedAlignment(String value) {
    switch (value) {
      case 'left':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      default:
        return Alignment.centerRight;
    }
  }

  static double _valign(String value) {
    switch (value) {
      case 'top':
        return -1;
      case 'bottom':
        return 1;
      default:
        return 0;
    }
  }

  static bool _isRtl(String value) => RegExp(r'[؀-ۿݐ-ݿ]').hasMatch(value);
}

final RegExp _cardVariable = RegExp(r'\{([A-Za-z0-9_]+)\}');

/// يستبدل `{student_name}` وأخواتها بقيم الطالب.
String resolveCardText(String template, Map<String, String> vars) =>
    template.replaceAllMapped(_cardVariable, (Match match) => vars[match.group(1)] ?? '');

/// هل في النص متغيّر قيمته فارغة؟ (لإخفاء العنصر عند تفعيل hideEmpty)
bool hasEmptyCardVar(String template, Map<String, String> vars) => _cardVariable
    .allMatches(template)
    .any((Match match) => (vars[match.group(1)] ?? '').trim().isEmpty);
