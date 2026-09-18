import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_failure.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/file_pick.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/child_avatar.dart';
import 'busy_overlay.dart';
import 'failure_view.dart';

/// صورة يمكن تغييرها: الصورة الحالية وفوقها زر كاميرا صغير.
/// الضغط يفتح منتقي الصور، ثم [onPick] ترفعها وتعيد الرابط الجديد،
/// ويتكفّل الودجت بحاجب التحميل ورسائل النجاح والخطأ.
class EditableAvatar extends StatelessWidget {
  const EditableAvatar({
    super.key,
    required this.name,
    required this.url,
    required this.onPick,
    this.size = 88,
    this.editable = true,
    this.onChanged,
  });

  final String name;
  final String? url;
  final double size;

  /// false تجعلها صورة عادية بلا زر (بلا صلاحية مثلاً).
  final bool editable;

  /// ترفع الملف وتعيد رابط الصورة الجديد.
  final Future<String?> Function(UploadFile file) onPick;

  /// يُستدعى بالرابط الجديد بعد نجاح الرفع.
  final void Function(String url)? onChanged;

  static const List<String> _extensions = <String>['jpg', 'jpeg', 'png', 'webp'];

  Future<void> _change(BuildContext context) async {
    final AppL10n l10n = AppL10n.of(context);
    final UploadFile? file = await pickUploadFile(field: 'avatar', extensions: _extensions);
    if (file == null || !context.mounted) {
      return;
    }
    try {
      final String? fresh = await runBusy<String?>(
        context,
        label: l10n.photoUploading,
        action: () => onPick(file),
      );
      if (!context.mounted) {
        return;
      }
      showSuccessSnack(context, l10n.photoUpdated);
      if (fresh != null && fresh.isNotEmpty) {
        onChanged?.call(fresh);
      }
    } on ApiFailure catch (failure) {
      if (context.mounted) {
        showFailureSnack(context, failure);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AppColors colors = context.colors;
    final Widget avatar = ChildAvatar(name: name, url: url, size: size);
    if (!editable) {
      return avatar;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          avatar,
          PositionedDirectional(
            end: -2,
            bottom: -2,
            child: Tooltip(
              message: l10n.changePhoto,
              child: Material(
                color: colors.primary,
                shape: CircleBorder(side: BorderSide(color: colors.surface, width: 2)),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _change(context),
                  child: SizedBox(
                    width: size * 0.34,
                    height: size * 0.34,
                    child: Icon(Icons.photo_camera_outlined, size: size * 0.19, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
