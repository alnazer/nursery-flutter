import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api/api_failure.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'paged_cubit.dart';
import 'failure_view.dart';

/// قائمة مرقّمة جاهزة: تحميل، وخطأ، وفراغ، وسحب للتحديث، وتحميل تلقائي للصفحة
/// التالية عند بلوغ آخر القائمة مع مؤشّر تحميل ثم إلحاق العناصر الجديدة.
class PagedListView<C extends PagedCubit<T>, T> extends StatelessWidget {
  const PagedListView({
    super.key,
    required this.itemBuilder,
    this.header,
    this.padding = const EdgeInsets.all(16),
    this.emptyText,
  });

  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget? header;
  final EdgeInsets padding;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return BlocBuilder<C, ListState<T>>(
      builder: (BuildContext context, ListState<T> state) {
        if (state.loading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final ApiFailure? failure = state.failure;
        if (failure != null && state.items.isEmpty) {
          return Padding(
            padding: padding,
            child: Center(
              child: FailureView(failure: failure, onRetry: () => context.read<C>().load()),
            ),
          );
        }
        final bool hasFooter = state.hasMore || state.loadingMore;

        return RefreshIndicator(
          onRefresh: () => context.read<C>().load(refresh: true),
          child: ListView.separated(
            padding: padding,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount:
                state.items.length + (header != null ? 1 : 0) + (hasFooter ? 1 : 0) + (state.isEmpty ? 1 : 0),
            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              int cursor = index;
              if (header != null) {
                if (cursor == 0) {
                  return header!;
                }
                cursor -= 1;
              }
              if (state.isEmpty) {
                return EmptyNote(text: emptyText ?? l10n.emptyList);
              }
              if (cursor >= state.items.length) {
                return PagedFooter<C, T>(state: state);
              }

              return itemBuilder(context, state.items[cursor]);
            },
          ),
        );
      },
    );
  }
}

/// ذيل القائمة: بمجرّد ظهوره يطلب الصفحة التالية ويعرض مؤشّر التحميل،
/// وعند فشل الطلب يعرض زر إعادة المحاولة بدل الدوران إلى ما لا نهاية.
class PagedFooter<C extends PagedCubit<T>, T> extends StatefulWidget {
  const PagedFooter({super.key, required this.state});

  final ListState<T> state;

  @override
  State<PagedFooter<C, T>> createState() => _PagedFooterState<C, T>();
}

class _PagedFooterState<C extends PagedCubit<T>, T> extends State<PagedFooter<C, T>> {
  @override
  void initState() {
    super.initState();
    _request();
  }

  @override
  void didUpdateWidget(covariant PagedFooter<C, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _request();
  }

  void _request() {
    if (widget.state.failure != null || widget.state.loadingMore || !widget.state.hasMore) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        context.read<C>().loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ApiFailure? failure = widget.state.failure;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: failure != null
            ? TextButton.icon(
                onPressed: () => context.read<C>().loadMore(),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.loadMore),
              )
            : const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
      ),
    );
  }
}

/// بطاقة بسيطة بحواف الهوية.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(14)});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.line),
          ),
          child: child,
        ),
      ),
    );
  }
}

class EmptyNote extends StatelessWidget {
  const EmptyNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: <Widget>[
          Icon(Icons.inbox_outlined, size: 44, color: colors.muted),
          const SizedBox(height: 10),
          Text(text, style: TextStyle(color: colors.muted, fontSize: 15), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// شارة صغيرة (حالة اليوم، حالة الفاتورة…).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.text, required this.color, required this.background, this.icon});

  final String text;
  final Color color;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// مربّع أيقونة ملوّن يتصدّر بطاقات القوائم.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    this.size = 46,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(size * 0.3)),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: size * 0.5),
      );
}

/// سطر معلومة صغير بأيقونة داخل البطاقات.
class IconLine extends StatelessWidget {
  const IconLine({
    super.key,
    required this.icon,
    required this.text,
    this.color,
    this.bold = false,
    this.fontSize = 12,
    this.maxLines = 2,
  });

  final IconData icon;
  final String text;
  final Color? color;
  final bool bold;
  final double fontSize;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: fontSize + 2, color: color ?? colors.muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color ?? colors.muted,
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// خيار واحد في شريط التصفية. [avatar] يسبق [icon] إن وُجد (صورة طفل مثلاً).
class FilterOption<T> {
  const FilterOption({required this.value, required this.label, this.icon, this.avatar});

  final T value;
  final String label;
  final IconData? icon;
  final Widget? avatar;
}

/// شريط تصفية أفقي فوق القوائم الكبيرة.
/// تغيير الخيار مسؤولية الشاشة (تعيد بناء الـ Cubit بمفتاح جديد).
class FilterBar<T> extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 2),
  });

  final List<FilterOption<T>> options;
  final T selected;
  final void Function(T value) onSelected;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Padding(
      padding: padding,
      child: SizedBox(
        height: 40,
        child: Row(
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: options.length,
                separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  final FilterOption<T> option = options[index];
                  final bool active = option.value == selected;

                  return ChoiceChip(
                    selected: active,
                    onSelected: (bool _) => onSelected(option.value),
                    avatar: option.avatar ??
                        (option.icon == null
                            ? null
                            : Icon(option.icon, size: 16, color: active ? Colors.white : colors.muted)),
                    label: Text(option.label),
                    selectedColor: colors.primary,
                    labelStyle: TextStyle(color: active ? Colors.white : colors.ink, fontSize: 13),
                    backgroundColor: colors.surface,
                    side: BorderSide(color: active ? colors.primary : colors.line),
                  );
                },
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
