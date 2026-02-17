abstract class SalaryEvent {}

class FetchSalary extends SalaryEvent {
  final String barcode;
  final String fromDate;
  final String toDate;

  FetchSalary({
    required this.barcode,
    required this.fromDate,
    required this.toDate,
  });
}
