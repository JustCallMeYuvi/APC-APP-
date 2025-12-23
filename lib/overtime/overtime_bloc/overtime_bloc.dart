import 'package:animated_movies_app/overtime/overtime_models/datewise_model.dart';
import 'package:animated_movies_app/overtime/overtime_models/overall_model.dart';
import 'package:animated_movies_app/overtime/overtime_models/weekwise_model.dart';
import 'package:animated_movies_app/overtime/overtime_services/overtime_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'overtime_event.dart';
import 'overtime_state.dart';

class OverTimeBloc extends Bloc<OverTimeEvent, OverTimeState> {
  final OverTimeService service;

  OverTimeBloc(this.service) : super(OverTimeInitial()) {
    on<FetchOverTime>(_onFetchOverTime);
  }

  Future<void> _onFetchOverTime(
    FetchOverTime event,
    Emitter<OverTimeState> emit,
  ) async {
    emit(OverTimeLoading());

    try {
      final result = await service.fetchOverTime(
        type: event.type,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );
      // 🔴 NO DATA
      if (result == null || (result is List && result.isEmpty)) {
        emit(OverTimeNoData());
        return;
      }

      if (result is OverallModel) {
        emit(OverTimeLoaded(overall: result));
      } else if (result is List<WeekwiseModel>) {
        emit(OverTimeLoaded(weekwise: result));
      } else if (result is List<DatewiseModel>) {
        emit(OverTimeLoaded(datewise: result));
      } else {
        emit(const OverTimeError("Unexpected data format"));
      }
    } catch (e) {
      emit(OverTimeError(e.toString()));
    }
  }
}
