import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../../widgets/child_avatar.dart';
import '../../common/list_views.dart';
import 'payments_page.dart';
import '../../common/failure_view.dart';

/// حجز فعالية: اختيار الأبناء، والإضافات، وحقول النموذج الديناميكية، ثم المعاينة والتأكيد.
class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.eventId, required this.event});

  final int eventId;
  final Map<String, dynamic> event;

  static Route<bool> route(int eventId, Map<String, dynamic> event) => MaterialPageRoute<bool>(
        builder: (BuildContext context) => BookingPage(eventId: eventId, event: event),
      );

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final Map<String, TextEditingController> _controllers = <String, TextEditingController>{};
  final Map<String, String> _values = <String, String>{};
  final Set<String> _selected = <String>{};
  final Map<String, Map<String, int>> _participantAddons = <String, Map<String, int>>{};
  final Map<String, int> _bookingAddons = <String, int>{};

  bool _consent = false;
  bool _busy = false;
  ApiFailure? _failure;
  Map<String, dynamic>? _preview;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> contact = _map(widget.event['contact']);
    _controllers['contact.name'] = TextEditingController(text: '${contact['name'] ?? ''}');
    _controllers['contact.phone'] = TextEditingController(text: '${contact['phone'] ?? ''}');
    _controllers['contact.email'] = TextEditingController(text: '${contact['email'] ?? ''}');
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  List<dynamic> _list(dynamic value) => value is List ? value : <dynamic>[];

  TextEditingController _controller(String key) =>
      _controllers.putIfAbsent(key, () => TextEditingController());

  List<Map<String, dynamic>> get _children => _list(widget.event['children'])
      .whereType<Map<dynamic, dynamic>>()
      .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
      .toList();

  List<Map<String, dynamic>> get _addons => _list(widget.event['addons'])
      .whereType<Map<dynamic, dynamic>>()
      .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
      .toList();

  List<Map<String, dynamic>> _fields(String group) {
    final Map<String, dynamic> form = _map(widget.event['form']);

    return _list(form[group])
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .toList();
  }

  bool get _hasFileField => <Map<String, dynamic>>[..._fields('booking_fields'), ..._fields('participant_fields')]
      .any((Map<String, dynamic> field) => field['type'] == 'file');

  /// يبني الحمولة بنفس أسماء الحقول التي يتوقعها الخادم.
  Map<String, dynamic> _payload() {
    final Map<String, dynamic> participants = <String, dynamic>{};
    for (final String key in _selected) {
      final Map<String, dynamic> answers = <String, dynamic>{};
      for (final Map<String, dynamic> field in _fields('participant_fields')) {
        final String name = '${field['key']}';
        final String value = _valueFor('p.$key.$name');
        if (value.isNotEmpty) {
          answers[name] = value;
        }
      }
      participants[key] = <String, dynamic>{
        'selected': 1,
        if (answers.isNotEmpty) 'answers': answers,
        if ((_participantAddons[key] ?? <String, int>{}).isNotEmpty) 'addons': _participantAddons[key],
      };
    }

    final Map<String, dynamic> answers = <String, dynamic>{};
    for (final Map<String, dynamic> field in _fields('booking_fields')) {
      final String name = '${field['key']}';
      final String value = _valueFor('b.$name');
      if (value.isNotEmpty) {
        answers[name] = value;
      }
    }

    return <String, dynamic>{
      'contact': <String, dynamic>{
        'name': _controller('contact.name').text.trim(),
        'phone': _controller('contact.phone').text.trim(),
        'email': _controller('contact.email').text.trim(),
      },
      'participants': participants,
      if (answers.isNotEmpty) 'answers': answers,
      if (_bookingAddons.isNotEmpty) 'booking_addons': _bookingAddons,
      'consent': _consent,
    };
  }

  String _valueFor(String key) => _values[key] ?? _controllers[key]?.text.trim() ?? '';

  Future<void> _runPreview() async {
    final AppL10n l10n = AppL10n.of(context);
    if (_selected.isEmpty) {
      setState(() => _failure = ApiFailure(code: 'validation_failed', message: l10n.selectAtLeastOne));

      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final Map<String, dynamic> preview =
          await context.read<ParentApi>().previewBooking(widget.eventId, _payload());
      if (mounted) {
        setState(() {
          _preview = preview;
          _busy = false;
        });
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

  Future<void> _confirm() async {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final Map<String, dynamic> booking = await api.createBooking(widget.eventId, _payload());
      if (!mounted) {
        return;
      }
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.bookingCreated)));
      final String reference = '${booking['reference'] ?? ''}';
      if (booking['can_pay'] == true && reference.isNotEmpty) {
        final PaymentStart start = await api.payBooking(reference);
        if (!mounted) {
          return;
        }
        navigator.pushReplacement(
          PaymentStatusPage.route(start.reference, paymentUrl: start.paymentUrl),
        );

        return;
      }
      navigator.pop(true);
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
    final Map<String, dynamic>? preview = _preview;
    final bool requiresConsent = preview?['requires_consent'] == true;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('${widget.event['title'] ?? ''}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.ink)),
          if (_hasFileField) ...<Widget>[
            const SizedBox(height: 12),
            SoftNote(text: l10n.fileFieldWeb, icon: Icons.attach_file),
          ],
          const SizedBox(height: 18),
          Text(l10n.participants, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
          const SizedBox(height: 8),
          ..._children.map(_participantTile),
          if (_fields('booking_fields').isNotEmpty) ...<Widget>[
            const SizedBox(height: 18),
            Text(l10n.bookingAnswers, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
            const SizedBox(height: 8),
            ..._fields('booking_fields').map((Map<String, dynamic> field) => _field(field, 'b.${field['key']}')),
          ],
          if (_addons.where((Map<String, dynamic> addon) => addon['scope'] == 'booking').isNotEmpty) ...<Widget>[
            const SizedBox(height: 18),
            Text(l10n.bookingAddons, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
            const SizedBox(height: 8),
            ..._addons
                .where((Map<String, dynamic> addon) => addon['scope'] == 'booking')
                .map((Map<String, dynamic> addon) => _addonRow(addon, _bookingAddons)),
          ],
          const SizedBox(height: 18),
          Text(l10n.bookingContact, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller('contact.name'),
            decoration: InputDecoration(labelText: l10n.nameLabel),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller('contact.phone'),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l10n.mobileLabel),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller('contact.email'),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.emailLabel),
          ),
          if (preview != null) ...<Widget>[
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.bookingTotal('${preview['total'] ?? ''} ${preview['currency'] ?? ''}'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.primaryInk),
                  ),
                  if ('${preview['discount'] ?? '0'}' != '0.000' && '${preview['discount'] ?? ''}'.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(l10n.bookingDiscount('${preview['discount']}'),
                        style: TextStyle(color: colors.green, fontSize: 13)),
                  ],
                  if (preview['will_wait'] == true) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(l10n.willWait, style: TextStyle(color: colors.sun, fontSize: 13)),
                  ],
                ],
              ),
            ),
            if (requiresConsent) ...<Widget>[
              const SizedBox(height: 10),
              CheckboxListTile(
                value: _consent,
                onChanged: (bool? value) => setState(() => _consent = value ?? false),
                title: Text(l10n.consentText, style: TextStyle(color: colors.ink, fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ],
          if (_failure != null) ...<Widget>[
            const SizedBox(height: 14),
            FailureView(failure: _failure!, compact: true),
          ],
          const SizedBox(height: 18),
          if (preview == null)
            PrimaryButton(label: l10n.previewBooking, busy: _busy, onPressed: _runPreview)
          else ...<Widget>[
            PrimaryButton(
              label: l10n.confirmBooking,
              busy: _busy,
              onPressed: requiresConsent && !_consent ? null : _confirm,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : () => setState(() => _preview = null),
              child: Text(l10n.previewBooking),
            ),
          ],
        ],
      ),
    );
  }

  Widget _participantTile(Map<String, dynamic> entry) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final Map<String, dynamic> student = _map(entry['student']);
    final String key = '${entry['key'] ?? ''}';
    final bool eligible = entry['eligible'] == true;
    final bool booked = entry['booked'] == true;
    final bool selected = _selected.contains(key);
    final List<Map<String, dynamic>> participantAddons =
        _addons.where((Map<String, dynamic> addon) => addon['scope'] == 'participant').toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(
                  value: selected,
                  onChanged: eligible && !booked
                      ? (bool? value) => setState(() {
                            if (value == true) {
                              _selected.add(key);
                            } else {
                              _selected.remove(key);
                            }
                          })
                      : null,
                ),
                ChildAvatar(name: '${student['name'] ?? ''}', url: student['avatar_url'] as String?, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('${student['name'] ?? ''}',
                      style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                ),
                if (booked)
                  StatusChip(text: l10n.booked, color: colors.skyInk, background: colors.sky)
                else if (!eligible)
                  StatusChip(text: l10n.notEligible, color: colors.muted, background: colors.bg2),
              ],
            ),
            if (selected) ...<Widget>[
              ..._fields('participant_fields')
                  .map((Map<String, dynamic> field) => _field(field, 'p.$key.${field['key']}')),
              ...participantAddons.map((Map<String, dynamic> addon) => _addonRow(
                    addon,
                    _participantAddons.putIfAbsent(key, () => <String, int>{}),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  /// حقل ديناميكي حسب نوعه في نموذج الفعالية.
  Widget _field(Map<String, dynamic> field, String key) {
    final AppColors colors = context.colors;
    final String type = '${field['type'] ?? 'text'}';
    final String label = '${field['label'] ?? ''}${field['required'] == true ? ' *' : ''}';
    final List<dynamic> choices = _list(field['choices']);

    if (type == 'file') {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text('$label — ${AppL10n.of(context).fileFieldWeb}',
            style: TextStyle(color: colors.muted, fontSize: 12)),
      );
    }

    if (type == 'select' && choices.isNotEmpty) {
      final List<String> options = choices.map((dynamic item) {
        if (item is Map) {
          return '${item['value'] ?? item['label'] ?? ''}';
        }

        return '$item';
      }).toList();

      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: DropdownButtonFormField<String>(
          value: _values[key],
          decoration: InputDecoration(labelText: label, helperText: field['help'] as String?),
          items: options
              .map((String option) => DropdownMenuItem<String>(value: option, child: Text(option)))
              .toList(),
          onChanged: (String? value) => setState(() => _values[key] = value ?? ''),
        ),
      );
    }

    if (type == 'checkbox') {
      final bool value = _values[key] == '1';

      return CheckboxListTile(
        value: value,
        onChanged: (bool? next) => setState(() => _values[key] = next == true ? '1' : ''),
        title: Text(label, style: TextStyle(color: colors.ink, fontSize: 14)),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      );
    }

    if (type == 'date') {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: InkWell(
          onTap: () async {
            final DateTime now = DateTime.now();
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(now.year - 20),
              lastDate: DateTime(now.year + 5),
            );
            if (picked != null) {
              setState(() => _values[key] =
                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: InputDecorator(
            decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_today, size: 18)),
            child: Text(_values[key] ?? '', style: TextStyle(color: colors.ink)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: _controller(key),
        keyboardType: type == 'number'
            ? TextInputType.number
            : type == 'phone'
                ? TextInputType.phone
                : type == 'email'
                    ? TextInputType.emailAddress
                    : TextInputType.text,
        maxLines: type == 'textarea' ? 3 : 1,
        decoration: InputDecoration(labelText: label, helperText: field['help'] as String?),
      ),
    );
  }

  Widget _addonRow(Map<String, dynamic> addon, Map<String, int> target) {
    final AppColors colors = context.colors;
    final String id = '${addon['id'] ?? ''}';
    final int quantity = target[id] ?? 0;
    final int max = (addon['max_quantity'] as int?) ?? 10;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${addon['title'] ?? ''}', style: TextStyle(color: colors.ink)),
                Text('${addon['price'] ?? ''}', style: TextStyle(color: colors.muted, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: quantity == 0
                ? null
                : () => setState(() {
                      if (quantity - 1 <= 0) {
                        target.remove(id);
                      } else {
                        target[id] = quantity - 1;
                      }
                    }),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$quantity', style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
          IconButton(
            onPressed: quantity >= max ? null : () => setState(() => target[id] = quantity + 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
