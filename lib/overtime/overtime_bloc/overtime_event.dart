import 'package:equatable/equatable.dart';

enum OtType { overall, weekwise, datewise }

abstract class OverTimeEvent extends Equatable {
  const OverTimeEvent();

  @override
  List<Object?> get props => [];
}

class FetchOverTime extends OverTimeEvent {
  final OtType type;
  final DateTime fromDate;
  final DateTime toDate;

  const FetchOverTime({
    required this.type,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [type, fromDate, toDate];
}
