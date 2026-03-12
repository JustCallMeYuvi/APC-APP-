// abstract class SalaryEvent {}

// class FetchSalary extends SalaryEvent {
//   final String barcode;
//   final String fromDate;
//   final String toDate;

//   FetchSalary({
//     required this.barcode,
//     required this.fromDate,
//     required this.toDate,
//   });
// }


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

/// NEW EVENT
/// /// DOWNLOAD PAYSLIP EVENT
class DownloadPayslip extends SalaryEvent {
  final String barcode;
  final String dob;
  final String bookNo;

  DownloadPayslip({
    required this.barcode,
    required this.dob,
    required this.bookNo,
  });
}