import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../common/detail_cubit.dart';
import '../../common/failure_view.dart';
import '../../common/list_views.dart';

/// تقييم الفعالية بعد انتهائها: نجوم لبعض العناصر ونص لأخرى، وملاحظات اختيارية.
/// الردّ السابق — إن وُجد — يُعبَّأ في الحقول ويستبدله الإرسال.
class EventSurveyPage extends StatelessWidget {
  const EventSurveyPage({super.key, required this.eventId, required this.eventTitle});

  final int eventId;
  final String eventTitle;

  static Route<void> route(int eventId, String eventTitle) => MaterialPageRoute<void>(
        builder: (BuildContext context) => EventSurveyPage(eventId: eventId, eventTitle: eventTitle),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<DetailCubit<Map<String, dynamic>>>(
      create: (BuildContext context) =>
          DetailCubit<Map<String, dynamic>>(() => api.eventSurvey(eventId))..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.surveyTitle)),
        body: BlocBuilder<DetailCubit<Map<String, dynamic>>, DetailState<Map<String, dynamic>>>(
          builder: (BuildContext context, DetailState<Map<String, dynamic>> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(
                  failure: state.failure!,
                  onRetry: () => context.read<DetailCubit<Map<String, dynamic>>>().load(),
                ),
              );
            }

            return _SurveyForm(
              eventId: eventId,
              eventTitle: eventTitle,
              data: state.data ?? <String, dynamic>{},
              api: api,
            );
          },
        ),
      ),
    );
  }
}

class _SurveyForm extends StatefulWidget {
  const _SurveyForm({
    required this.eventId,
    required this.eventTitle,
    required this.data,
    required this.api,
  });

  final int eventId;
  final String eventTitle;
  final Map<String, dynamic> data;
  final ParentApi api;

  @override
  State<_SurveyForm> createState() => _SurveyFormState();
}

class _SurveyFormState extends State<_SurveyForm> {
  final Map<int, int> _ratings = <int, int>{};
  final Map<int, TextEditingController> _texts = <int, TextEditingController>{};
  final TextEditingController _notes = TextEditingController();

  bool _busy = false;
  ApiFailure? _failure;

  List<Map<String, dynamic>> get _items => widget.data['items'] is List
      ? (widget.data['items'] as List<dynamic>)
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
          .toList()
      : <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _seed();
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _texts.values) {
      controller.dispose();
    }
    _notes.dispose();
    super.dispose();
  }

  TextEditingController _controller(int id) => _texts.putIfAbsent(id, () => TextEditingController());

  void _seed() {
    final dynamic existing = widget.data['existing'];
    if (existing is! Map) {
      return;
    }
    _notes.text = '${existing['notes'] ?? ''}';
    final dynamic answers = existing['answers'];
    if (answers is! List) {
      return;
    }
    for (final dynamic answer in answers) {
      if (answer is! Map) {
        continue;
      }
      final int id = (answer['item_id'] as int?) ?? 0;
      final dynamic rating = answer['rating'];
      if (rating is num) {
        _ratings[id] = rating.toInt();
      }
      final dynamic text = answer['text'];
      if (text is String && text.isNotEmpty) {
        _controller(id).text = text;
      }
    }
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    final AppL10n l10n = AppL10n.of(context);
    FocusScope.of(context).unfocus();
    final Map<String, dynamic> items = <String, dynamic>{};
    for (final Map<String, dynamic> item in _items) {
      final int id = (item['id'] as int?) ?? 0;
      if (id == 0) {
        continue;
      }
      if ('${item['type']}' == 'stars') {
        final int? value = _ratings[id];
        if (value != null && value > 0) {
          items['$id'] = <String, dynamic>{'rating': value};
        }
      } else {
        final String text = _controller(id).text.trim();
        if (text.isNotEmpty) {
          items['$id'] = <String, dynamic>{'text': text};
        }
      }
    }
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await widget.api.submitEventSurvey(widget.eventId, <String, dynamic>{
        'booking': widget.data['booking'],
        'items': items,
        if (widget.data['allow_notes'] == true) 'notes': _notes.text.trim(),
      });
      if (mounted) {
        showSuccessSnack(context, l10n.surveySent);
        Navigator.of(context).pop();
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
    final String title = '${widget.data['title'] ?? widget.eventTitle}';
    final String intro = '${widget.data['intro'] ?? ''}';
    final bool allowNotes = widget.data['allow_notes'] == true;
    final bool answered = widget.data['existing'] is Map;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.ink)),
        if (intro.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text(intro, style: TextStyle(color: colors.muted, fontSize: 13, height: 1.6)),
        ],
        if (answered) ...<Widget>[
          const SizedBox(height: 12),
          SoftNote(text: l10n.surveyAlreadySent, icon: Icons.info_outline),
        ],
        const SizedBox(height: 16),
        ..._items.map(_itemCard),
        if (allowNotes) ...<Widget>[
          const SizedBox(height: 4),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: '${widget.data['notes_label'] ?? l10n.surveyNotes}',
              alignLabelWithHint: true,
            ),
          ),
        ],
        if (_failure != null) ...<Widget>[
          const SizedBox(height: 12),
          FailureView(failure: _failure!, compact: true),
        ],
        const SizedBox(height: 16),
        PrimaryButton(label: l10n.send, busy: _busy, onPressed: _submit),
      ],
    );
  }

  Widget _itemCard(Map<String, dynamic> item) {
    final AppColors colors = context.colors;
    final int id = (item['id'] as int?) ?? 0;
    final bool stars = '${item['type']}' == 'stars';
    final int max = (item['max_stars'] as int?) ?? 5;
    final String help = '${item['help'] ?? ''}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('${item['label'] ?? ''}',
                      style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                ),
                if (item['required'] == true)
                  Text('*', style: TextStyle(color: colors.coral, fontWeight: FontWeight.w700)),
              ],
            ),
            if (help.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(help, style: TextStyle(color: colors.muted, fontSize: 12)),
            ],
            const SizedBox(height: 8),
            if (stars)
              Row(
                children: List<Widget>.generate(
                  max,
                  (int index) => IconButton(
                    onPressed: () => setState(() => _ratings[id] = index + 1),
                    icon: Icon(
                      index < (_ratings[id] ?? 0) ? Icons.star : Icons.star_border,
                      color: colors.sun,
                      size: 30,
                    ),
                  ),
                ),
              )
            else
              TextField(
                controller: _controller(id),
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
          ],
        ),
      ),
    );
  }
}
