import 'package:animated_movies_app/overtime/overtime_models/datewise_model.dart';
import 'package:animated_movies_app/overtime/overtime_models/overall_model.dart';
import 'package:animated_movies_app/overtime/overtime_models/weekwise_model.dart';
import 'package:equatable/equatable.dart';


abstract class OverTimeState extends Equatable {
  const OverTimeState();

  @override
  List<Object?> get props => [];
}

class OverTimeInitial extends OverTimeState {}

class OverTimeLoading extends OverTimeState {}
class OverTimeNoData extends OverTimeState {}


class OverTimeError extends OverTimeState {
  final String message;
  const OverTimeError(this.message);

  @override
  List<Object?> get props => [message];
}

class OverTimeLoaded extends OverTimeState {
  final OverallModel? overall;
  final List<WeekwiseModel>? weekwise;
  final List<DatewiseModel>? datewise;

  const OverTimeLoaded({
    this.overall,
    this.weekwise,
    this.datewise,
  });

  @override
  List<Object?> get props => [overall, weekwise, datewise];
}
