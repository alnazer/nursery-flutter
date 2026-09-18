import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_failure.dart';
import '../../../core/api/staff_api.dart';
import '../../../core/models/staff_models.dart';

class StaffTodayState {
  const StaffTodayState({this.loading = true, this.today = StaffToday.empty, this.failure});

  final bool loading;
  final StaffToday today;
  final ApiFailure? failure;
}

/// لوحة اليوم للمشرفة: الحضور والأنشطة ونافذة الإضافة.
class StaffTodayCubit extends Cubit<StaffTodayState> {
  StaffTodayCubit(this.api) : super(const StaffTodayState());

  final StaffApi api;

  Future<void> load({bool refresh = false}) async {
    emit(StaffTodayState(loading: !refresh, today: state.today));
    try {
      final StaffToday today = await api.today();
      emit(StaffTodayState(loading: false, today: today));
    } on ApiFailure catch (failure) {
      emit(StaffTodayState(loading: false, today: state.today, failure: failure));
    }
  }
}
