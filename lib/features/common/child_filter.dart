import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api/parent_api.dart';
import '../../core/models/parent_models.dart';
import '../../core/util/children_cache.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/child_avatar.dart';
import 'list_views.dart';

/// شريط «أبنائي»: يعرض كل الأبناء ويسمح بقصر القائمة على طفل واحد.
/// يختفي تماماً إن كان للحساب طفل واحد فقط (لا معنى للتصفية حينها).
class ChildFilterBar extends StatefulWidget {
  const ChildFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 0),
  });

  final int? selected;
  final void Function(int? studentId) onSelected;
  final EdgeInsets padding;

  @override
  State<ChildFilterBar> createState() => _ChildFilterBarState();
}

class _ChildFilterBarState extends State<ChildFilterBar> {
  List<Child> _children = ChildrenCache.items;

  @override
  void initState() {
    super.initState();
    if (_children.isEmpty) {
      _load();
    }
  }

  /// فشل التحميل يخفي الشريط فقط ولا يعطّل الشاشة.
  Future<void> _load() async {
    try {
      final List<Child> rows = await ChildrenCache.load(context.read<ParentApi>());
      if (mounted) {
        setState(() => _children = rows);
      }
    } catch (_) {
      // يبقى الشريط مخفياً
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_children.length < 2) {
      return const SizedBox.shrink();
    }
    final AppL10n l10n = AppL10n.of(context);

    return FilterBar<int?>(
      selected: widget.selected,
      onSelected: widget.onSelected,
      padding: widget.padding,
      options: <FilterOption<int?>>[
        FilterOption<int?>(value: null, label: l10n.allChildren, icon: Icons.groups_outlined),
        ..._children.map((Child child) => FilterOption<int?>(
              value: child.id,
              label: child.firstName.isEmpty ? child.name : child.firstName,
              avatar: ChildAvatar(
                name: child.firstName.isEmpty ? child.name : child.firstName,
                url: child.avatarUrl,
                size: 24,
              ),
            )),
      ],
    );
  }
}
