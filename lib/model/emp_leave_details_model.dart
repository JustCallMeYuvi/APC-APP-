// To parse this JSON data, do
//
//     final empLeaveDetails = empLeaveDetailsFromJson(jsonString);

import 'dart:convert';

List<EmpLeaveDetails> empLeaveDetailsFromJson(String str) => List<EmpLeaveDetails>.from(json.decode(str).map((x) => EmpLeaveDetails.fromJson(x)));

String empLeaveDetailsToJson(List<EmpLeaveDetails> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EmpLeaveDetails {
    String holidayId;
    String empNo;
    String deptNo;
    String holidayKind;
    DateTime startDate;
    DateTime endDate;
    // int holidayQty;
    double holidayQty; // Adjusted to double to match backend

    EmpLeaveDetails({
        required this.holidayId,
        required this.empNo,
        required this.deptNo,
        required this.holidayKind,
        required this.startDate,
        required this.endDate,
        required this.holidayQty,
    });

    factory EmpLeaveDetails.fromJson(Map<String, dynamic> json) => EmpLeaveDetails(
        holidayId: json["HOLIDAY_ID"],
        empNo: json["EMP_NO"],
        deptNo: json["DEPT_NO"],
        holidayKind: json["HOLIDAY_KIND"],
        startDate: DateTime.parse(json["START_DATE"]),
        endDate: DateTime.parse(json["END_DATE"]),
        // holidayQty: json["HOLIDAY_QTY"],
    holidayQty: json["HOLIDAY_QTY"].toDouble(), // Convert to double
    );

    Map<String, dynamic> toJson() => {
        "HOLIDAY_ID": holidayId,
        "EMP_NO": empNo,
        "DEPT_NO": deptNo,
        "HOLIDAY_KIND": holidayKind,
        "START_DATE": startDate.toIso8601String(),
        "END_DATE": endDate.toIso8601String(),
        "HOLIDAY_QTY": holidayQty,
    };
}
