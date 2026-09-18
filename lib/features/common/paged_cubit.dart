import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api/api_failure.dart';
import '../../core/models/paged.dart';

/// حالة قائمة مرقّمة: التحميل الأول، والمزيد، والتحديث بالسحب.
class ListState<T> {
  const ListState({
    this.items = const <Never>[],
    this.loading = true,
    this.loadingMore = false,
    this.failure,
    this.hasMore = false,
    this.page = 0,
    this.meta = const <String, dynamic>{},
  });

  final List<T> items;
  final bool loading;
  final bool loadingMore;
  final ApiFailure? failure;
  final bool hasMore;
  final int page;
  final Map<String, dynamic> meta;

  bool get isEmpty => !loading && failure == null && items.isEmpty;

  ListState<T> copyWith({
    List<T>? items,
    bool? loading,
    bool? loadingMore,
    ApiFailure? failure,
    bool clearFailure = false,
    bool? hasMore,
    int? page,
    Map<String, dynamic>? meta,
  }) =>
      ListState<T>(
        items: items ?? this.items,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        failure: clearFailure ? null : failure ?? this.failure,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
        meta: meta ?? this.meta,
      );
}

/// Cubit عام لكل القوائم المرقّمة (الأنشطة، الإشعارات، الفواتير، التعاميم، الطلاب).
class PagedCubit<T> extends Cubit<ListState<T>> {
  PagedCubit(this.loader) : super(ListState<T>());

  final Future<Paged<T>> Function(int page) loader;

  Future<void> load({bool refresh = false}) async {
    emit(state.copyWith(loading: !refresh || state.items.isEmpty, clearFailure: true));
    try {
      final Paged<T> page = await loader(1);
      emit(state.copyWith(
        items: page.items,
        loading: false,
        hasMore: page.hasMore,
        page: page.page,
        meta: page.meta,
        clearFailure: true,
      ));
    } on ApiFailure catch (failure) {
      emit(state.copyWith(loading: false, failure: failure));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.loading) {
      return;
    }
    emit(state.copyWith(loadingMore: true, clearFailure: true));
    try {
      final Paged<T> next = await loader(state.page + 1);
      emit(state.copyWith(
        items: <T>[...state.items, ...next.items],
        loadingMore: false,
        hasMore: next.hasMore,
        page: next.page,
        meta: next.meta,
        clearFailure: true,
      ));
    } on ApiFailure catch (failure) {
      emit(state.copyWith(loadingMore: false, failure: failure));
    }
  }

  void replaceItems(List<T> items) => emit(state.copyWith(items: items));
}
