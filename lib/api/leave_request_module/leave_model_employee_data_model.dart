class EmployeeData {
  final String empNo;
  final String deptName;
  final String username;
  final String position;
  final String deptNo;
  final String workNo; // 🔥 ADD THIS

  EmployeeData({
    required this.empNo,
    required this.deptName,
    required this.username,
    required this.position,
    required this.deptNo,
    required this.workNo,
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    print("EMP JSON: $json");

    return EmployeeData(
      empNo: json['Barcode']?.toString() ?? '',
      deptName: json['Department']?.toString() ?? '',
      username: json['Name']?.toString() ?? '',
      position: json['Position']?.toString() ?? '',

      // 🔥 FIXED HERE
      deptNo: json['Dept_NO']?.toString() ?? '',
      workNo: json['Work_NO']?.toString() ?? '', // 🔥 IMPORTANT
    );
  }
}

class ApproverData {
  final String name;
  final String id;

  ApproverData({
    required this.name,
    required this.id,
  });

  factory ApproverData.fromJson(Map<String, dynamic> json) {
    print("APPROVER JSON: $json");

    return ApproverData(
      name: json['Name']?.toString() ?? '',
      id: json['Barcode']?.toString() ?? '',
    );
  }
}

class HrApprover {
  final String name;
  final String id;

  HrApprover({
    required this.name,
    required this.id,
  });

  factory HrApprover.fromJson(Map<String, dynamic> json) {
    return HrApprover(
      name: json['NameS']?.toString() ?? '',
      id: json['BarcodeS']?.toString() ?? '',
    );
  }
}
