import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/models/card_design.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/image_export.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/child_avatar.dart';
import '../../widgets/student_card_view.dart';
import 'detail_cubit.dart';
import 'failure_view.dart';
import 'list_views.dart';

/// معاينة بطاقة الطالب وتحميلها — مشتركة بين تطبيق ولي الأمر وتطبيق المشرفات.
class StudentCardPage extends StatelessWidget {
  const StudentCardPage({
    super.key,
    required this.studentName,
    required this.loader,
    this.avatarUrl,
  });

  final String studentName;
  final Future<StudentCard> Function() loader;
  final String? avatarUrl;

  static Route<void> route({
    required String studentName,
    required Future<StudentCard> Function() loader,
    String? avatarUrl,
  }) =>
      MaterialPageRoute<void>(
        builder: (BuildContext context) => StudentCardPage(
          studentName: studentName,
          loader: loader,
          avatarUrl: avatarUrl,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return BlocProvider<DetailCubit<StudentCard>>(
      create: (BuildContext context) => DetailCubit<StudentCard>(loader)..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.cardTitle)),
        body: BlocBuilder<DetailCubit<StudentCard>, DetailState<StudentCard>>(
          builder: (BuildContext context, DetailState<StudentCard> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(
                  failure: state.failure!,
                  onRetry: () => context.read<DetailCubit<StudentCard>>().load(),
                ),
              );
            }

            return _CardBody(
              card: state.data ?? StudentCard.empty,
              studentName: studentName,
              avatarUrl: avatarUrl,
            );
          },
        ),
      ),
    );
  }
}

class _CardBody extends StatefulWidget {
  const _CardBody({required this.card, required this.studentName, this.avatarUrl});

  final StudentCard card;
  final String studentName;
  final String? avatarUrl;

  @override
  State<_CardBody> createState() => _CardBodyState();
}

class _CardBodyState extends State<_CardBody> {
  final GlobalKey _boundary = GlobalKey();
  String _face = 'front';
  bool _busy = false;

  Future<void> _download() async {
    final AppL10n l10n = AppL10n.of(context);
    setState(() => _busy = true);
    try {
      // إطار كامل قبل التصوير حتى تُرسم الصور المحمّلة حديثاً
      await Future<void>.delayed(const Duration(milliseconds: 120));
      final Uint8List? bytes = await captureAsPng(_boundary, targetWidth: 1240);
      if (bytes == null) {
        if (mounted) {
          showInfoSnack(context, l10n.cardSaveFailed);
        }

        return;
      }
      final String name = 'card-${_slug(widget.card.qr.isEmpty ? widget.studentName : widget.card.qr)}-$_face.png';
      final String? path = await saveBytes(filename: name, bytes: bytes);
      if (!mounted) {
        return;
      }
      if (path == null) {
        showInfoSnack(context, l10n.cardSaveCancelled);
      } else {
        showSuccessSnack(context, l10n.cardSaved);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  static String _slug(String value) {
    final String cleaned = value.replaceAll(RegExp(r'[^A-Za-z0-9؀-ۿ]+'), '-');

    return cleaned.replaceAll(RegExp(r'^-+|-+$'), '').isEmpty ? 'student' : cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final StudentCard card = widget.card;
    final bool hasDesign = !card.design.isEmpty;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Row(
          children: <Widget>[
            ChildAvatar(
              name: widget.studentName,
              url: card.photoUrl ?? widget.avatarUrl,
              size: 52,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    card.vars['student_name']?.isNotEmpty == true
                        ? card.vars['student_name']!
                        : widget.studentName,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.ink),
                  ),
                  const SizedBox(height: 5),
                  _Facts(vars: card.vars),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (hasDesign)
          Center(
            child: RepaintBoundary(
              key: _boundary,
              child: Material(
                elevation: 6,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(card.design.radius * 4),
                clipBehavior: Clip.antiAlias,
                child: StudentCardFace(card: card, face: _face),
              ),
            ),
          )
        else
          _FallbackCard(card: card, name: widget.studentName),
        if (hasDesign && card.design.hasBack) ...<Widget>[
          const SizedBox(height: 16),
          Center(
            child: SegmentedButton<String>(
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(value: 'front', label: Text(l10n.cardFront)),
                ButtonSegment<String>(value: 'back', label: Text(l10n.cardBack)),
              ],
              selected: <String>{_face},
              onSelectionChanged: (Set<String> values) => setState(() => _face = values.first),
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (hasDesign)
          PrimaryButton(
            label: l10n.cardDownload,
            busy: _busy,
            onPressed: _download,
          ),
        const SizedBox(height: 16),
        SoftNote(text: l10n.cardHint, icon: Icons.qr_code_2),
      ],
    );
  }
}

/// سطر ثانٍ تحت الاسم: بيانات الطالب التي قد يحتاجها المشرف أو مدير النظام،
/// بخط صغير وأيقونة لكل حقل. الحقول الفارغة تُحذف.
class _Facts extends StatelessWidget {
  const _Facts({required this.vars});

  final Map<String, String> vars;

  /// الترتيب هو ترتيب العرض: الأهم للمشرف أولاً.
  static const List<List<String>> _order = <List<String>>[
    <String>['classroom', 'meeting_room'],
    <String>['semester', 'schedule'],
    <String>['branch', 'place'],
    <String>['study_year', 'calendar'],
    <String>['status', 'verified'],
    <String>['age', 'cake'],
    <String>['gender', 'wc'],
    <String>['birth_date', 'event'],
    <String>['nationality', 'flag'],
    <String>['civil_id', 'badge'],
    <String>['student_code', 'tag'],
    <String>['parent_name', 'person'],
    <String>['parent_phone', 'phone'],
    <String>['branch_phone', 'call'],
  ];

  static IconData _icon(String name) {
    switch (name) {
      case 'meeting_room':
        return Icons.meeting_room_outlined;
      case 'schedule':
        return Icons.schedule_outlined;
      case 'place':
        return Icons.place_outlined;
      case 'calendar':
        return Icons.calendar_month_outlined;
      case 'verified':
        return Icons.verified_outlined;
      case 'cake':
        return Icons.cake_outlined;
      case 'wc':
        return Icons.wc;
      case 'event':
        return Icons.event_outlined;
      case 'flag':
        return Icons.flag_outlined;
      case 'badge':
        return Icons.badge_outlined;
      case 'tag':
        return Icons.tag;
      case 'person':
        return Icons.person_outline;
      case 'phone':
        return Icons.phone_outlined;
      default:
        return Icons.call_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final List<Widget> items = <Widget>[];
    for (final List<String> entry in _order) {
      final String value = (vars[entry.first] ?? '').trim();
      if (value.isEmpty) {
        continue;
      }
      items.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_icon(entry.last), size: 13, color: colors.muted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.muted, fontSize: 11.5),
            ),
          ),
        ],
      ));
    }
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(spacing: 12, runSpacing: 5, children: items);
  }
}

/// الوجه نفسه بمقاس مناسب للشاشة.
class StudentCardFace extends StatelessWidget {
  const StudentCardFace({super.key, required this.card, required this.face});

  final StudentCard card;
  final String face;

  @override
  Widget build(BuildContext context) {
    final double available = MediaQuery.of(context).size.width - 56;
    final double width = available.clamp(220.0, 420.0).toDouble();

    return StudentCardView(card: card, face: face, width: width);
  }
}

/// بديل بسيط حين لا يوجد تصميم محفوظ في لوحة التحكم.
class _FallbackCard extends StatelessWidget {
  const _FallbackCard({required this.card, required this.name});

  final StudentCard card;
  final String name;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          if (card.qrImage != null)
            Image.memory(card.qrImage!, width: 180, height: 180, filterQuality: FilterQuality.none),
          const SizedBox(height: 14),
          SelectableText(
            card.qr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              letterSpacing: 4,
              fontWeight: FontWeight.w700,
              color: colors.primaryInk,
            ),
          ),
        ],
      ),
    );
  }
}
