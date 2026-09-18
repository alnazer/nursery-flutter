import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/staff_api.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/file_pick.dart';
import '../../../core/util/formatters.dart';
import '../../../core/util/image_export.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_widgets.dart';
import '../../common/list_views.dart';
import '../../common/paged_cubit.dart';
import '../../common/confirm_dialog.dart';
import '../../common/failure_view.dart';
import 'leave_balances_page.dart';

/// إجازاتي: الطلبات وحالتها مع سحب الطلب، وطلب جديد.
class LeavesPage extends StatelessWidget {
  const LeavesPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const LeavesPage(),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final StaffApi api = context.read<StaffApi>();

    return BlocProvider<PagedCubit<LeaveRequest>>(
      create: (BuildContext context) => PagedCubit<LeaveRequest>((int page) => api.leaves(page: page))..load(),
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(title: Text(l10n.leavesTitle)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final bool? saved = await Navigator.of(context).push<bool>(LeaveFormPage.route());
              if (saved == true && context.mounted) {
                context.read<PagedCubit<LeaveRequest>>().load(refresh: true);
              }
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.newLeave),
          ),
          body: PagedListView<PagedCubit<LeaveRequest>, LeaveRequest>(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemBuilder: (BuildContext context, LeaveRequest item) => _LeaveTile(leave: item, api: api),
          ),
        ),
      ),
    );
  }
}

class _LeaveTile extends StatelessWidget {
  const _LeaveTile({required this.leave, required this.api});

  final LeaveRequest leave;
  final StaffApi api;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final bool approved = leave.status == 'approved';
    final bool rejected = leave.status == 'rejected' || leave.status == 'cancelled';

    final Color accent = approved ? colors.green : (rejected ? colors.coral : colors.sun);
    final Color accentSoft = approved ? colors.greenSoft : (rejected ? colors.coralSoft : colors.sunSoft);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconBadge(
            icon: approved
                ? Icons.event_available_outlined
                : (rejected ? Icons.event_busy_outlined : Icons.pending_actions_outlined),
            color: accent,
            background: accentSoft,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(leave.typeTitle, style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
              ),
              StatusChip(
                text: leave.statusLabel,
                color: accent,
                background: accentSoft,
                icon: approved
                    ? Icons.check_circle_outline
                    : (rejected ? Icons.cancel_outlined : Icons.schedule),
              ),
            ],
          ),
          const SizedBox(height: 8),
          IconLine(
            icon: Icons.date_range_outlined,
            text: '${formatDate(leave.startDate)} - ${formatDate(leave.endDate)}',
          ),
          IconLine(icon: Icons.today_outlined, text: l10n.leaveDaysCount('${leave.days}')),
          if (leave.reason.isNotEmpty)
            IconLine(icon: Icons.sticky_note_2_outlined, text: leave.reason, fontSize: 13),
          if (leave.hasAttachment || leave.canWithdraw)
            Row(
              children: <Widget>[
                if (leave.hasAttachment)
                  TextButton.icon(
                    onPressed: () => _openAttachment(context),
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: Text(l10n.openAttachment),
                  ),
                const Spacer(),
                if (leave.canWithdraw)
                  TextButton.icon(
                    icon: Icon(Icons.undo, size: 18, color: colors.coral),
                    onPressed: () async {
                      final PagedCubit<LeaveRequest> cubit = context.read<PagedCubit<LeaveRequest>>();
                      final bool yes = await showConfirmDialog(
                        context,
                        title: l10n.withdraw,
                        message: l10n.withdrawLeaveConfirm,
                        icon: Icons.undo,
                        destructive: true,
                      );
                      if (!yes) {
                        return;
                      }
                      try {
                        await api.withdrawLeave(leave.id);
                        if (context.mounted) {
                          showSuccessSnack(context, l10n.withdrawn);
                          cubit.load(refresh: true);
                        }
                      } on ApiFailure catch (failure) {
                        if (context.mounted) {
                          showFailureSnack(context, failure);
                        }
                      }
                    },
                    label: Text(l10n.withdraw, style: TextStyle(color: colors.coral)),
                  ),
              ],
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// المرفق يُنزَّل بترويسات الاعتماد ثم يُحفظ بحوار النظام (لا يصلح فتحه برابط).
  Future<void> _openAttachment(BuildContext context) async {
    final AppL10n l10n = AppL10n.of(context);
    showInfoSnack(context, l10n.downloading);
    try {
      final DownloadedFile file = await api.leaveAttachment(leave.id);
      if (!context.mounted) {
        return;
      }
      final String? path = await saveBytes(filename: file.filename, bytes: file.bytes);
      if (context.mounted && path != null) {
        showSuccessSnack(context, l10n.fileSaved);
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }
}

/// طلب إجازة جديد مع معاينة عدد الأيام من الخادم.
class LeaveFormPage extends StatefulWidget {
  const LeaveFormPage({super.key});

  static Route<bool> route() => MaterialPageRoute<bool>(
        builder: (BuildContext context) => const LeaveFormPage(),
      );

  @override
  State<LeaveFormPage> createState() => _LeaveFormPageState();
}

class _LeaveFormPageState extends State<LeaveFormPage> {
  final TextEditingController _reason = TextEditingController();

  List<LeaveType> _types = <LeaveType>[];
  LeaveType? _type;
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();
  String _preview = '';
  UploadFile? _attachment;
  bool _loading = true;
  bool _busy = false;
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  String _iso(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  /// إعادة المحاولة من زر «إعادة» في تنبيه «لا توجد أنواع».
  Future<void> _reloadTypes() async {
    setState(() {
      _loading = true;
      _failure = null;
    });
    await _loadTypes();
  }

  Future<void> _loadTypes() async {
    try {
      final List<LeaveType> types = await context.read<StaffApi>().leaveTypes();
      if (mounted) {
        setState(() {
          _types = types;
          _type = types.isEmpty ? null : types.first;
          _loading = false;
        });
        await _refreshPreview();
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failure = failure;
        });
      }
    }
  }

  Future<void> _refreshPreview() async {
    final LeaveType? type = _type;
    if (type == null) {
      return;
    }
    try {
      final Map<String, dynamic> preview = await context.read<StaffApi>().previewLeave(
            leaveTypeId: type.id,
            startDate: _iso(_from),
            endDate: _iso(_to),
          );
      if (mounted) {
        setState(() => _preview = '${preview['total_days'] ?? ''}');
      }
    } on ApiFailure {
      if (mounted) {
        setState(() => _preview = '');
      }
    }
  }

  Future<void> _pick({required bool isFrom}) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to.isBefore(_from)) {
          _to = picked;
        }
      } else {
        _to = picked.isBefore(_from) ? _from : picked;
      }
    });
    await _refreshPreview();
  }

  Future<void> _submit() async {
    final LeaveType? type = _type;
    if (type == null || _busy) {
      return;
    }
    final AppL10n l10n = AppL10n.of(context);
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final UploadFile? attachment = _attachment;
      if (attachment != null) {
        await context.read<StaffApi>().storeLeaveWithAttachment(
              leaveTypeId: type.id,
              startDate: _iso(_from),
              endDate: _iso(_to),
              reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
              attachment: attachment,
            );
      } else {
        await context.read<StaffApi>().storeLeave(
              leaveTypeId: type.id,
              startDate: _iso(_from),
              endDate: _iso(_to),
              reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
            );
      }
      if (mounted) {
        showSuccessSnack(context, l10n.leaveSubmitted);
        Navigator.of(context).pop(true);
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newLeave)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                if (_types.isEmpty)
                  ErrorNote(
                    text: l10n.leaveTypesEmpty,
                    onRetry: _reloadTypes,
                    retryLabel: l10n.retry,
                  )
                else
                  DropdownButtonFormField<LeaveType>(
                    value: _type,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.leaveType,
                      prefixIcon: const Icon(Icons.event_note_outlined),
                    ),
                    items: _types
                        .map((LeaveType type) => DropdownMenuItem<LeaveType>(
                              value: type,
                              child: Text(type.title, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (LeaveType? value) {
                      setState(() => _type = value);
                      _refreshPreview();
                    },
                  ),
                if (_type != null) ...<Widget>[
                  const SizedBox(height: 8),
                  IconLine(
                    icon: Icons.account_balance_wallet_outlined,
                    text: l10n.balanceDays(_number(_type!.balance)),
                    color: _type!.balance <= 0 ? colors.coral : colors.green,
                    fontSize: 13,
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _DateField(label: l10n.absenceFrom, value: _iso(_from), onTap: () => _pick(isFrom: true)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateField(label: l10n.absenceTo, value: _iso(_to), onTap: () => _pick(isFrom: false)),
                    ),
                  ],
                ),
                if (_preview.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  SoftNote(text: l10n.leaveDaysCount(_preview), icon: Icons.event_note_outlined),
                ],
                const SizedBox(height: 14),
                TextField(
                  controller: _reason,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.leaveReason, alignLabelWithHint: true),
                ),
                const SizedBox(height: 12),
                _AttachmentRow(
                  attachment: _attachment,
                  required: _type?.requiresAttachment ?? false,
                  onPick: () async {
                    final UploadFile? file = await pickUploadFile(
                      field: 'attachment',
                      extensions: <String>['pdf', 'jpg', 'jpeg', 'png'],
                    );
                    if (file != null && mounted) {
                      setState(() => _attachment = file);
                    }
                  },
                  onRemove: () => setState(() => _attachment = null),
                ),
                if (_failure != null) ...<Widget>[
                  const SizedBox(height: 12),
                  FailureView(failure: _failure!, compact: true),
                ],
                const SizedBox(height: 16),
                PrimaryButton(label: l10n.send, busy: _busy, onPressed: _type == null ? null : _submit),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(LeaveBalancesPage.route()),
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                  label: Text(l10n.hrBalances),
                ),
              ],
            ),
    );
  }

  static String _number(double value) =>
      value == value.roundToDouble() ? '${value.round()}' : value.toStringAsFixed(1);
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_today, size: 18)),
        child: Text(value, style: TextStyle(color: context.colors.ink)),
      ),
    );
  }
}


/// صف اختيار المرفق: زر الإرفاق، واسم الملف المختار، وإزالته.
class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({
    required this.attachment,
    required this.required,
    required this.onPick,
    required this.onRemove,
  });

  final UploadFile? attachment;
  final bool required;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final UploadFile? file = attachment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.attach_file, size: 18),
                label: Text(l10n.attachFile),
              ),
            ),
            if (file != null) ...<Widget>[
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.removeAttachment,
                onPressed: onRemove,
                icon: Icon(Icons.close, color: colors.coral),
              ),
            ],
          ],
        ),
        if (file != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(file.filename, style: TextStyle(color: colors.muted, fontSize: 12)),
          )
        else if (required)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(l10n.attachmentRequired, style: TextStyle(color: colors.coral, fontSize: 12)),
          ),
      ],
    );
  }
}
