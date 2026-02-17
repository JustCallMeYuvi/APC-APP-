class SalaryModel {
  final String bookNo;
  final String empName;
  final double basicSalary;
  final double daSalary;
  final double diligenceBonus;
  final double performanceBonus;
  final double grossSalary;
  final double earnedGrossSalary;
  final double deductionTotal;
  final double actualSalary;

  SalaryModel({
    required this.bookNo,
    required this.empName,
    required this.basicSalary,
    required this.daSalary,
    required this.diligenceBonus,
    required this.performanceBonus,
    required this.grossSalary,
    required this.earnedGrossSalary,
    required this.deductionTotal,
    required this.actualSalary,
  });

  factory SalaryModel.fromJson(Map<String, dynamic> json) {
    return SalaryModel(
      bookNo: json['book_No'],
      empName: json['emp_Name'],
      basicSalary: (json['basic_Salary'] ?? 0).toDouble(),
      daSalary: (json['da_Salary'] ?? 0).toDouble(),
      diligenceBonus: (json['diligence_Bonus'] ?? 0).toDouble(),
      performanceBonus: (json['performance_Bonus'] ?? 0).toDouble(),
      grossSalary: (json['gross_Salary'] ?? 0).toDouble(),
      earnedGrossSalary: (json['earned_Gross_Salary'] ?? 0).toDouble(),
      deductionTotal: (json['deduction_Total'] ?? 0).toDouble(),
      actualSalary: (json['actual_Salary'] ?? 0).toDouble(),
    );
  }
}
