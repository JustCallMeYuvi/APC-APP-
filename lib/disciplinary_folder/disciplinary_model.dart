class DisciplinaryModel {
  final String awpnNo;
  final String empName;
  final String empNo;
  final String deptName;
  final String reason;
  final String status;
  final String disciplinaryDate;
  final String lastDate;
  final String rewardQty;
  final String rewardAmount;

  DisciplinaryModel({
    required this.awpnNo,
    required this.empName,
    required this.empNo,
    required this.deptName,
    required this.reason,
    required this.status,
    required this.disciplinaryDate,
    required this.lastDate,
    required this.rewardQty,
    required this.rewardAmount,
  });

  factory DisciplinaryModel.fromJson(Map<String, dynamic> json) {
    return DisciplinaryModel(
      awpnNo: json['awpnNo'] ?? '',
      empName: json['empName'] ?? '',
      empNo: json['empNo'] ?? '',
      deptName: json['deptName'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      disciplinaryDate: json['disciplinaryDate'] ?? '',
      lastDate: json['lastDate'] ?? '',
      rewardQty: json['rewardQuantity'] ?? '0',
      rewardAmount: json['rewardAmount'] ?? '0',
    );
  }
}