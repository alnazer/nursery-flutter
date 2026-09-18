import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/native/native_bridge.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../../widgets/child_avatar.dart';
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import 'booking_page.dart';
import 'event_survey_page.dart';
import '../../common/confirm_dialog.dart';
import '../../common/failure_view.dart';

/// الفعاليات المعروضة لولي الأمر.
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const EventsPage(),
      );

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  /// '' الكل · 'mine' المؤهل لأبنائي · وإلا تصنيف الفعالية
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eventsTitle),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).push(BookingsPage.route()),
            child: Text(l10n.bookingsTitle),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          FilterBar<String>(
            selected: _filter,
            onSelected: (String value) => setState(() => _filter = value),
            options: <FilterOption<String>>[
              FilterOption<String>(value: '', label: l10n.filterAll),
              FilterOption<String>(value: 'mine', label: l10n.filterForMyChildren, icon: Icons.child_care_outlined),
              FilterOption<String>(value: 'trip', label: l10n.eventTrip),
              FilterOption<String>(value: 'activity', label: l10n.eventActivity),
              FilterOption<String>(value: 'workshop', label: l10n.eventWorkshop),
              FilterOption<String>(value: 'camp', label: l10n.eventCamp),
              FilterOption<String>(value: 'celebration', label: l10n.eventCelebration),
            ],
          ),
          Expanded(
            child: BlocProvider<PagedCubit<EventItem>>(
              key: ValueKey<String>(_filter),
              create: (BuildContext context) => PagedCubit<EventItem>(
                (int page) => api.events(
                  page: page,
                  forMe: _filter == 'mine',
                  category: _filter.isEmpty || _filter == 'mine' ? null : _filter,
                ),
              )..load(),
              child: PagedListView<PagedCubit<EventItem>, EventItem>(
                itemBuilder: (BuildContext context, EventItem item) => _EventTile(event: item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(EventDetailPage.route(event.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                event.imageUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error, StackTrace? stack) => Container(
                  height: 140,
                  color: colors.soft,
                  alignment: Alignment.center,
                  child: Icon(Icons.celebration_outlined, size: 40, color: colors.primaryInk),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(event.title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.ink)),
                    ),
                    if (event.phaseLabel.isNotEmpty)
                      StatusChip(
                        text: event.phaseLabel,
                        color: event.canRegister ? colors.green : colors.muted,
                        background: event.canRegister ? colors.greenSoft : colors.bg2,
                        icon: event.canRegister ? Icons.how_to_reg_outlined : Icons.lock_clock,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (event.summary.isNotEmpty)
                  IconLine(icon: Icons.info_outline, text: event.summary, fontSize: 13),
                if (event.startsAt != null)
                  IconLine(icon: Icons.event_outlined, text: formatDateTime(event.startsAt), fontSize: 13),
                if (event.location.isNotEmpty)
                  IconLine(icon: Icons.place_outlined, text: event.location, fontSize: 13),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    if (event.priceFrom.isNotEmpty) ...<Widget>[
                      Icon(Icons.sell_outlined, size: 18, color: colors.primaryInk),
                      const SizedBox(width: 6),
                      Text(l10n.priceFrom('${event.priceFrom} ${event.currency}'),
                          style: TextStyle(color: colors.ink, fontWeight: FontWeight.w700)),
                    ],
                    const Spacer(),
                    if (event.remainingSeats != null) ...<Widget>[
                      Icon(Icons.event_seat_outlined, size: 16, color: colors.muted),
                      const SizedBox(width: 5),
                      Text(l10n.seatsLeft('${event.remainingSeats}'),
                          style: TextStyle(color: colors.muted, fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// تفاصيل الفعالية: البرنامج والأبناء المؤهّلون.
class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, required this.id});

  final int id;

  static Route<void> route(int id) => MaterialPageRoute<void>(
        builder: (BuildContext context) => EventDetailPage(id: id),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<DetailCubit<Map<String, dynamic>>>(
      create: (BuildContext context) => DetailCubit<Map<String, dynamic>>(() => api.event(id))..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.eventsTitle)),
        body: BlocBuilder<DetailCubit<Map<String, dynamic>>, DetailState<Map<String, dynamic>>>(
          builder: (BuildContext context, DetailState<Map<String, dynamic>> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(failure: state.failure!, onRetry: () => context.read<DetailCubit<Map<String, dynamic>>>().load()),
              );
            }
            final Map<String, dynamic> event = state.data ?? <String, dynamic>{};
            final AppColors colors = context.colors;
            final List<dynamic> days = event['days'] is List ? event['days'] as List<dynamic> : <dynamic>[];
            final List<dynamic> children =
                event['children'] is List ? event['children'] as List<dynamic> : <dynamic>[];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Text('${event['title'] ?? ''}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 16),
                if (days.isNotEmpty) ...<Widget>[
                  Text(l10n.eventProgram,
                      style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                  const SizedBox(height: 8),
                  ...days.whereType<Map<dynamic, dynamic>>().map((Map<dynamic, dynamic> raw) {
                    final Map<String, dynamic> day = Map<String, dynamic>.from(raw);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        child: Row(
                          children: <Widget>[
                            Expanded(child: Text(formatDate('${day['date'] ?? ''}'),
                                style: TextStyle(color: colors.ink))),
                            Text('${day['starts_time'] ?? ''} - ${day['ends_time'] ?? ''}',
                                style: TextStyle(color: colors.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
                if (children.isNotEmpty) ...<Widget>[
                  Text(l10n.eventChildren, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                  const SizedBox(height: 8),
                  ...children.whereType<Map<dynamic, dynamic>>().map((Map<dynamic, dynamic> raw) {
                    final Map<String, dynamic> entry = Map<String, dynamic>.from(raw);
                    final Map<String, dynamic> student = entry['student'] is Map
                        ? Map<String, dynamic>.from(entry['student'] as Map)
                        : <String, dynamic>{};
                    final bool eligible = entry['eligible'] == true;
                    final bool booked = entry['booked'] == true;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        child: Row(
                          children: <Widget>[
                            ChildAvatar(
                              name: '${student['name'] ?? ''}',
                              url: student['avatar_url'] as String?,
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('${student['name'] ?? ''}',
                                  style: TextStyle(color: colors.ink, fontWeight: FontWeight.w700)),
                            ),
                            StatusChip(
                              text: booked
                                  ? l10n.booked
                                  : eligible
                                      ? l10n.eligible
                                      : l10n.notEligible,
                              color: booked ? colors.skyInk : (eligible ? colors.green : colors.muted),
                              background: booked ? colors.sky : (eligible ? colors.greenSoft : colors.bg2),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 16),
                if (children.any((dynamic entry) =>
                    entry is Map && entry['eligible'] == true && entry['booked'] != true))
                  FilledButton.icon(
                    onPressed: () async {
                      final bool? booked = await Navigator.of(context).push<bool>(
                        BookingPage.route(id, event),
                      );
                      if (booked == true && context.mounted) {
                        context.read<DetailCubit<Map<String, dynamic>>>().load();
                      }
                    },
                    icon: const Icon(Icons.event_available_outlined),
                    label: Text(l10n.bookNow),
                  )
                else
                  SoftNote(text: l10n.bookingSoon, icon: Icons.event_available_outlined),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// حجوزاتي مع إمكانية الإلغاء.
class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const BookingsPage(),
      );

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String _status = '';

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingsTitle)),
      body: Column(
        children: <Widget>[
          FilterBar<String>(
            selected: _status,
            onSelected: (String value) => setState(() => _status = value),
            options: <FilterOption<String>>[
              FilterOption<String>(value: '', label: l10n.filterAll),
              FilterOption<String>(value: 'active', label: l10n.filterActive, icon: Icons.event_available_outlined),
              FilterOption<String>(value: 'confirmed', label: l10n.filterConfirmed),
              FilterOption<String>(value: 'pending', label: l10n.filterPending),
              FilterOption<String>(value: 'cancelled', label: l10n.filterCancelled),
            ],
          ),
          Expanded(
            child: BlocProvider<PagedCubit<EventBooking>>(
              key: ValueKey<String>(_status),
              create: (BuildContext context) => PagedCubit<EventBooking>(
                (int page) => api.bookings(page: page, status: _status.isEmpty ? null : _status),
              )..load(),
              child: PagedListView<PagedCubit<EventBooking>, EventBooking>(
                itemBuilder: (BuildContext context, EventBooking item) => _BookingTile(booking: item, api: api),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking, required this.api});

  final EventBooking booking;
  final ParentApi api;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconBadge(
                icon: booking.status == 'confirmed' ? Icons.confirmation_number_outlined : Icons.pending_outlined,
                color: booking.status == 'confirmed' ? colors.green : colors.sun,
                background: booking.status == 'confirmed' ? colors.greenSoft : colors.sunSoft,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(booking.eventTitle,
                    style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
              ),
              StatusChip(
                text: booking.statusLabel,
                color: booking.status == 'confirmed' ? colors.green : colors.sun,
                background: booking.status == 'confirmed' ? colors.greenSoft : colors.sunSoft,
                icon: booking.status == 'confirmed' ? Icons.check_circle_outline : Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (booking.startsAt != null)
            IconLine(icon: Icons.event_outlined, text: formatDateTime(booking.startsAt), fontSize: 13),
          IconLine(
            icon: Icons.groups_outlined,
            text: l10n.participantsCount('${booking.participants}'),
            fontSize: 13,
          ),
          if (booking.total.isNotEmpty)
            IconLine(
              icon: Icons.payments_outlined,
              text: '${booking.total} ${booking.currency}',
              fontSize: 13,
              bold: true,
            ),
          if (booking.code.isNotEmpty) IconLine(icon: Icons.qr_code_2, text: booking.code, fontSize: 13),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 4,
            children: <Widget>[
              if (booking.canAccept)
                TextButton.icon(
                  onPressed: () => _action(context, () => api.acceptBooking(booking.reference), l10n.bookingAccepted),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(l10n.acceptBooking),
                ),
              if (booking.canRenew)
                TextButton.icon(
                  onPressed: () => _action(context, () => api.renewBooking(booking.reference), l10n.bookingRenewed),
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  label: Text(l10n.renewBooking),
                ),
              TextButton.icon(
                onPressed: () => _invoice(context),
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                label: Text(l10n.bookingInvoice),
              ),
              if (booking.eventId > 0)
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    EventSurveyPage.route(booking.eventId, booking.eventTitle),
                  ),
                  icon: const Icon(Icons.rate_review_outlined, size: 18),
                  label: Text(l10n.surveyTitle),
                ),
              if (booking.canCancel)
                TextButton(
                  onPressed: () => _cancel(context),
                  child: Text(l10n.cancelBooking, style: TextStyle(color: colors.coral)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// إجراء بسيط على الحجز مع رسالة نجاح وإعادة تحميل القائمة.
  Future<void> _action(
    BuildContext context,
    Future<Map<String, dynamic>> Function() run,
    String done,
  ) async {
    final PagedCubit<EventBooking> cubit = context.read<PagedCubit<EventBooking>>();
    try {
      await run();
      if (context.mounted) {
        showSuccessSnack(context, done);
        cubit.load(refresh: true);
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }

  /// فاتورة الحجز: رابط مؤقّت يُفتح خارج التطبيق.
  Future<void> _invoice(BuildContext context) async {
    final AppL10n l10n = AppL10n.of(context);
    try {
      final Map<String, dynamic> data = await api.bookingInvoice(booking.reference);
      final String url = '${data['url'] ?? ''}';
      if (!context.mounted) {
        return;
      }
      if (url.isEmpty) {
        showInfoSnack(context, l10n.invoicePdfFailed);
      } else {
        await const NativeBridge().openUrl(url);
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }

  Future<void> _cancel(BuildContext context) async {
    final AppL10n l10n = AppL10n.of(context);
    final bool confirmed = await showConfirmDialog(
      context,
      title: l10n.cancelBooking,
      message: l10n.cancelBookingConfirm,
      icon: Icons.event_busy_outlined,
      confirmIcon: Icons.check_circle_outline,
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await api.cancelBooking(booking.reference);
    if (context.mounted) {
      showSuccessSnack(context, l10n.bookingCancelled);
      context.read<PagedCubit<EventBooking>>().load(refresh: true);
    }
  }
}
