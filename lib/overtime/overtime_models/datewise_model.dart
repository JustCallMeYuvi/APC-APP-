class DatewiseModel {
  final DateTime attDate;
  final double? totalHrPermittedHours;
  final double? totalEmpOtHours;
  final double? totalOtWithoutPermission;
  final double? totalOtMandays;

  const DatewiseModel({
    required this.attDate,
    this.totalHrPermittedHours,
    this.totalEmpOtHours,
    this.totalOtWithoutPermission,
    this.totalOtMandays,
  });

  factory DatewiseModel.fromJson(Map<String, dynamic> json) {
    return DatewiseModel(
      attDate: DateTime.parse(json['ATT_DATE']),
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
