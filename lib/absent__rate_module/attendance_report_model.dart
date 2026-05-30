class AttendanceReportModel {
  final String date;
  final String? fromDate;
  final String? toDate;

  final int activeEmployees;
  final int presentEmployees;
  final int totalEmployees;

  final int maleEmpCount;
  final int femaleEmpCount;

  final double maleAbsentCount;
  final double femaleAbsentCount;
  final double totalAbsentCount;

  final double maleAbsentEmpPercentage;
  final double femaleAbsentEmpPercentage;
  final double totalAbsentEmpPercentage;

  final double maleAbsentPercentage;
  final double femaleAbsentPercentage;
  final double totalAbsentPercentage;

  final int totalWorkingDays;

  AttendanceReportModel({
    required this.date,
    this.fromDate,
    this.toDate,
    required this.activeEmployees,
    required this.presentEmployees,
    required this.totalEmployees,
    required this.maleEmpCount,
    required this.femaleEmpCount,
    required this.maleAbsentCount,
    required this.femaleAbsentCount,
    required this.totalAbsentCount,
    required this.maleAbsentEmpPercentage,
    required this.femaleAbsentEmpPercentage,
    required this.totalAbsentEmpPercentage,
    required this.maleAbsentPercentage,
    required this.femaleAbsentPercentage,
    required this.totalAbsentPercentage,
    required this.totalWorkingDays,
  });

  factory AttendanceReportModel.fromJson(Map<String, dynamic> json) {
    return AttendanceReportModel(
      date: json["atT_DATE"] ?? "",
      fromDate: json["froM_DATE"],
      toDate: json["tO_DATE"],
      activeEmployees: json["activE_EMPLOYEES_COUNT"] ?? 0,
      presentEmployees: json["presenT_EMPLOYEES_COUNT"] ?? 0,
      totalEmployees: json["totaL_EMPLOYEES_COUNT"] ?? 0,
      maleEmpCount: json["malE_EMP_COUNT"] ?? 0,
      femaleEmpCount: json["femalE_EMP_COUNT"] ?? 0,
      maleAbsentCount:
          (json["malE_ABSENT_COUNT"] ?? 0).toDouble(),
      femaleAbsentCount:
          (json["femalE_ABSENT_COUNT"] ?? 0).toDouble(),
      totalAbsentCount:
          (json["totaL_ABSENT_COUNT"] ?? 0).toDouble(),
      maleAbsentEmpPercentage:
          (json["malE_ABSENT_EMP_PERCENTAGE"] ?? 0).toDouble(),
      femaleAbsentEmpPercentage:
          (json["femalE_ABSENT_EMP_PERCENTAGE"] ?? 0).toDouble(),
      totalAbsentEmpPercentage:
          (json["totaL_ABSENT_EMP_PERCENTAGE"] ?? 0).toDouble(),
      maleAbsentPercentage:
          (json["malE_ABSENT_PERCENTAGE"] ?? 0).toDouble(),
      femaleAbsentPercentage:
          (json["femalE_ABSENT_PERCENTAGE"] ?? 0).toDouble(),
      totalAbsentPercentage:
          (json["totaL_ABSENT_PERCENTAGE"] ?? 0).toDouble(),
      totalWorkingDays: json["totaL_WORKING_DAYS"] ?? 0,
    );
  }
}