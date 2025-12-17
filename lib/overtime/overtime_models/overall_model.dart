class OverallModel {
  final double? totalOtEmployees;
  final double? totalHrPermittedHours;
  final double? totalEmpOtHours;
  final double? totalOtWithoutPermission;
  final double? totalOtMandays;

  const OverallModel({
    this.totalOtEmployees,
    this.totalHrPermittedHours,
    this.totalEmpOtHours,
    this.totalOtWithoutPermission,
    this.totalOtMandays,
  });

  factory OverallModel.fromJson(Map<String, dynamic> json) {
    return OverallModel(
      totalOtEmployees:
          (json['TOTAL_OT_EMPLOYEES'] as num?)?.toDouble(),
      totalHrPermittedHours:
          (json['TOTAL_HR_PERMITTED_HOURS'] as num?)?.toDouble(),
      totalEmpOtHours:
          (json['TOTAL_EMP_OT_HOURS'] as num?)?.toDouble(),
      totalOtWithoutPermission:
          (json['TOTAL_OT_WITHOUT_PERMISSION'] as num?)?.toDouble(),
      totalOtMandays:
          (json['TOTAL_OT_MANDAYS'] as num?)?.toDouble(),
    );
  }
}
