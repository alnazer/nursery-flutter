import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/parent_api.dart';
import '../../../core/models/parent_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/detail_cubit.dart';
import '../../common/list_views.dart';
import '../../common/failure_view.dart';

/// أجهزتي: الأجهزة المتصلة بالحساب مع إخراج أي جهاز.
class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (BuildContext context) => const DevicesPage(),
      );

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ParentApi api = context.read<ParentApi>();

    return BlocProvider<DetailCubit<List<DeviceItem>>>(
      create: (BuildContext context) => DetailCubit<List<DeviceItem>>(api.devices)..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.devicesTitle),
          actions: <Widget>[
            Builder(
              builder: (BuildContext inner) => IconButton(
                tooltip: l10n.disablePush,
                icon: const Icon(Icons.notifications_off_outlined),
                onPressed: () async {
                  try {
                    await api.disablePush();
                    if (inner.mounted) {
                      showSuccessSnack(inner, l10n.pushDisabled);
                    }
                  } on ApiFailure catch (failure) {
                    if (inner.mounted) {
                      showFailureSnack(inner, failure);
                    }
                  }
                },
              ),
            ),
          ],
        ),
        body: BlocBuilder<DetailCubit<List<DeviceItem>>, DetailState<List<DeviceItem>>>(
          builder: (BuildContext context, DetailState<List<DeviceItem>> state) {
            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null && state.data == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: FailureView(failure: state.failure!, onRetry: () => context.read<DetailCubit<List<DeviceItem>>>().load()),
              );
            }
            final List<DeviceItem> devices = state.data ?? <DeviceItem>[];
            if (devices.isEmpty) {
              return EmptyNote(text: l10n.emptyList);
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: devices.length,
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) => _DeviceTile(device: devices[index], api: api),
            );
          },
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.api});

  final DeviceItem device;
  final ParentApi api;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;

    return AppCard(
      child: Row(
        children: <Widget>[
          Icon(
            device.platform == 'ios' ? Icons.phone_iphone : Icons.phone_android,
            color: colors.primaryInk,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(device.name,
                          style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
                    ),
                    if (device.current) ...<Widget>[
                      const SizedBox(width: 8),
                      StatusChip(text: l10n.deviceCurrent, color: colors.green, background: colors.greenSoft),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  <String>[
                    if (device.appVersion.isNotEmpty) device.appVersion,
                    if (device.lastUsedAt != null) l10n.lastUsed(formatDateTime(device.lastUsedAt)),
                  ].join(' · '),
                  style: TextStyle(color: colors.muted, fontSize: 12),
                ),
                if (device.biometricEnabled) ...<Widget>[
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Icon(Icons.fingerprint, size: 14, color: colors.primaryInk),
                      const SizedBox(width: 4),
                      Text(l10n.biometricLabel, style: TextStyle(color: colors.muted, fontSize: 12)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!device.current)
            IconButton(
              tooltip: l10n.deviceSignOut,
              onPressed: () async {
                await api.signOutDevice(device.id);
                if (context.mounted) {
                  showSuccessSnack(context, l10n.deviceSignedOut);
                  context.read<DetailCubit<List<DeviceItem>>>().load();
                }
              },
              icon: Icon(Icons.logout, color: colors.coral),
            ),
        ],
      ),
    );
  }
}
