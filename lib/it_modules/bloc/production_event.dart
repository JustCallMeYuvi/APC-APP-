// production_event.dart
abstract class ProductionEvent {}

class FetchProductionData extends ProductionEvent {
  final DateTime date;

  FetchProductionData(this.date);
}

class FilterDepartmentData extends ProductionEvent {
  final String? selectedDeptId;
  final DateTime selectedDate;

  FilterDepartmentData(this.selectedDeptId, this.selectedDate);
}
