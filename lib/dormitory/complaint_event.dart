import 'package:equatable/equatable.dart';
import 'department_model.dart';

abstract class ComplaintEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadComplaintTypes extends ComplaintEvent {}

class SelectComplaintType extends ComplaintEvent {
  final DepartmentModel department;
  SelectComplaintType(this.department);

  @override
  List<Object?> get props => [department];
}

class SubmitComplaint extends ComplaintEvent {
  final String description;
  final String empNo;
  final String employeeDept;

  SubmitComplaint({
    required this.description,
    required this.empNo,
    required this.employeeDept,
  });

  @override
  List<Object?> get props => [description, empNo, employeeDept];
}
