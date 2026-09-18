import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api/api_failure.dart';

class DetailState<T> {
  const DetailState({this.loading = true, this.data, this.failure});

  final bool loading;
  final T? data;
  final ApiFailure? failure;
}

/// تحميل عنصر واحد (ملف طفل، نشاط، فاتورة، تعميم).
class DetailCubit<T> extends Cubit<DetailState<T>> {
  DetailCubit(this.loader) : super(DetailState<T>());

  final Future<T> Function() loader;

  Future<void> load() async {
    emit(DetailState<T>(loading: true, data: state.data));
    try {
      emit(DetailState<T>(loading: false, data: await loader()));
    } on ApiFailure catch (failure) {
      emit(DetailState<T>(loading: false, data: state.data, failure: failure));
    }
  }
}
