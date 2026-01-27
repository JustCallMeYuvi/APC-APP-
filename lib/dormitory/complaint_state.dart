import 'package:equatable/equatable.dart';
import 'department_model.dart';

class ComplaintState extends Equatable {
  final List<DepartmentModel> departments;
  final DepartmentModel? selectedDept;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const ComplaintState({
    required this.departments,
    this.selectedDept,
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  factory ComplaintState.initial() =>
      const ComplaintState(departments: []);

  ComplaintState copyWith({
    List<DepartmentModel>? departments,
    DepartmentModel? selectedDept,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return ComplaintState(
      departments: departments ?? this.departments,
      selectedDept: selectedDept ?? this.selectedDept,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [departments, selectedDept, isLoading, isSuccess, error];
}
