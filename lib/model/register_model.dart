// To parse this JSON data, do
//
//     final registerModel = registerModelFromJson(jsonString);

import 'dart:convert';

List<RegisterModel> registerModelFromJson(String str) => List<RegisterModel>.from(json.decode(str).map((x) => RegisterModel.fromJson(x)));

String registerModelToJson(List<RegisterModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RegisterModel {
    int id;
    dynamic username;
    dynamic email;
    String empNo;
    dynamic password;
    String message;
    bool success;
    dynamic deptName;
    dynamic empName;
    dynamic position;
    bool status;

    RegisterModel({
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

    factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
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
