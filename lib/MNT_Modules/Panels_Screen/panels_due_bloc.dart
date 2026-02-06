import 'dart:convert';
import 'package:animated_movies_app/MNT_Modules/Panels_Screen/panels_due_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'panels_due_event.dart';
import 'panels_due_state.dart';


class PanelsDueBloc extends Bloc<PanelsDueEvent, PanelsDueState> {
  PanelsDueBloc() : super(PanelsDueInitial()) {
    on<FetchPanelsDue>(_fetchPanelsDue);
  }

  Future<void> _fetchPanelsDue(
      FetchPanelsDue event, Emitter<PanelsDueState> emit) async {
    emit(PanelsDueLoading());

    try {
      final response = await http.get(
        Uri.parse('http://10.3.0.70:9042/api/MNT_/panels-due-for-scan'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        emit(PanelsDueLoaded(PanelsDueResponse.fromJson(jsonData)));
      } else {
        emit(PanelsDueError('Failed to load data'));
      }
    } catch (e) {
      emit(PanelsDueError(e.toString()));
    }
  }
}
