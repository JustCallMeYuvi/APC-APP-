import 'package:animated_movies_app/MNT_Modules/Power_panels/power_panel_event.dart';
import 'package:animated_movies_app/MNT_Modules/Power_panels/power_panel_repository.dart';
import 'package:animated_movies_app/MNT_Modules/Power_panels/power_panel_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PowerPanelBloc extends Bloc<PowerPanelEvent, PowerPanelState> {
  final PowerPanelRepository repository;

  PowerPanelBloc(this.repository) : super(PowerPanelInitial()) {
    on<FetchPowerPanels>((event, emit) async {
      emit(PowerPanelLoading());
      try {
        final panels = await repository.fetchPanels();
        emit(PowerPanelLoaded(panels));
      } catch (e) {
        emit(PowerPanelError(e.toString()));
      }
    });
    // 🔥 ADD THIS FOR HISTORY API
    on<FetchPanelHistory>((event, emit) async {
      emit(PowerPanelHistoryLoading());
      try {
        final history = await repository.fetchPanelHistory(
          event.powerPanelId,
          event.fromDate,
          event.toDate,
        );

        if (history.records.isEmpty) {
          emit(PowerPanelHistoryEmpty());
        } else {
          emit(PowerPanelHistoryLoaded(history));
        }
      } catch (e) {
        emit(PowerPanelError(e.toString()));
      }
    });
  }
}
