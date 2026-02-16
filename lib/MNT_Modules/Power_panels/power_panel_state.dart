import 'package:animated_movies_app/MNT_Modules/Power_panels/power_panel_history_model.dart';
import 'package:animated_movies_app/MNT_Modules/Power_panels/power_panel_names_model.dart';

abstract class PowerPanelState {}

class PowerPanelInitial extends PowerPanelState {}

class PowerPanelLoading extends PowerPanelState {}

class PowerPanelLoaded extends PowerPanelState {
  final List<PowerPanelNamesModel> panels;
  PowerPanelLoaded(this.panels);
}

class PowerPanelError extends PowerPanelState {
  final String message;
  PowerPanelError(this.message);
}

class PowerPanelHistoryLoading extends PowerPanelState {}

class PowerPanelHistoryLoaded extends PowerPanelState {
  final PowerPanelHistoryModel history;
  PowerPanelHistoryLoaded(this.history);
}

class PowerPanelHistoryEmpty extends PowerPanelState {}
