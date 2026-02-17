import 'package:animated_movies_app/Salary_Module/salary_model.dart';

abstract class SalaryState {}

class SalaryInitial extends SalaryState {}

class SalaryLoading extends SalaryState {}

class SalaryLoaded extends SalaryState {
  final List<SalaryModel> salaries;

  SalaryLoaded(this.salaries);
}

class SalaryNoData extends SalaryState {}

class SalaryError extends SalaryState {
  final String message;

  SalaryError(this.message);
}
