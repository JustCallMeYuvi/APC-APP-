

import 'package:animated_movies_app/MNT_Modules/Panels_Screen/panels_due_model.dart';

abstract class PanelsDueState {}

class PanelsDueInitial extends PanelsDueState {}

class PanelsDueLoading extends PanelsDueState {}

class PanelsDueLoaded extends PanelsDueState {
  final PanelsDueResponse data;
  PanelsDueLoaded(this.data);
}

class PanelsDueError extends PanelsDueState {
  final String message;
  PanelsDueError(this.message);
}
