// production_state.dart
import 'package:animated_movies_app/screens/gms_screens/production_data_model.dart';

abstract class ProductionState {}

class ProductionInitial extends ProductionState {}

class ProductionLoading extends ProductionState {}

class ProductionLoaded extends ProductionState {
  final List<Map<String, String>> deptNames;
  final List<Map<String, String>> companyLists;
  final List<Map<String, dynamic>> departmentData;
  final List<Map<String, dynamic>> filteredDepartmentData;
  final List<Department> summaryList;

  ProductionLoaded({
    required this.deptNames,
    required this.companyLists,
    required this.departmentData,
    required this.filteredDepartmentData,
    required this.summaryList,
  });
}

class ProductionError extends ProductionState {
  final String message;

  ProductionError(this.message);
}
