// To parse this JSON data, do
//
//     final getEmpDetails = getEmpDetailsFromJson(jsonString);

import 'dart:convert';

List<GetEmpDetails> getEmpDetailsFromJson(String str) => List<GetEmpDetails>.from(json.decode(str).map((x) => GetEmpDetails.fromJson(x)));

String getEmpDetailsToJson(List<GetEmpDetails> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetEmpDetails {
    int id;
    String username;
    dynamic email;
    String empNo;
    String password;
    dynamic message;
    bool success;
    String deptName;
    String empName;
    String position;
    bool status;

    GetEmpDetails({
        required this.id,
        required this.username,
        required this.email,
        required this.empNo,
        required this.password,
        required this.message,
        required this.success,
        required this.deptName,
        required this.empName,
        required this.position,
        required this.status,
    });

    factory GetEmpDetails.fromJson(Map<String, dynamic> json) => GetEmpDetails(
        id: json["ID"],
        username: json["Username"],
        email: json["Email"],
        empNo: json["EMP_NO"],
        password: json["Password"],
        message: json["Message"],
        success: json["Success"],
        deptName: json["DEPT_NAME"],
        empName: json["EMP_NAME"],
        position: json["POSITION"],
        status: json["Status"],
    );

    Map<String, dynamic> toJson() => {
        "ID": id,
        "Username": username,
        "Email": email,
        "EMP_NO": empNo,
        "Password": password,
        "Message": message,
        "Success": success,
        "DEPT_NAME": deptName,
        "EMP_NAME": empName,
        "POSITION": position,
        "Status": status,
    };
}
