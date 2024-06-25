// // To parse this JSON data, do
// //
// //     final loginModelApi = loginModelApiFromJson(jsonString);

// import 'dart:convert';

// List<LoginModelApi> loginModelApiFromJson(String str) => List<LoginModelApi>.from(json.decode(str).map((x) => LoginModelApi.fromJson(x)));

// String loginModelApiToJson(List<LoginModelApi> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class LoginModelApi {
//     int id;
//     dynamic username;
//     dynamic email;
//     String empNo;
//     String password;
//     String message;
//     bool success;
//     dynamic deptName;
//     dynamic empName;
//     dynamic position;
//     bool status;

//     LoginModelApi({
//         required this.id,
//         required this.username,
//         required this.email,
//         required this.empNo,
//         required this.password,
//         required this.message,
//         required this.success,
//         required this.deptName,
//         required this.empName,
//         required this.position,
//         required this.status,
//     });

//     factory LoginModelApi.fromJson(Map<String, dynamic> json) => LoginModelApi(
//         id: json["ID"],
//         username: json["Username"],
//         email: json["Email"],
//         empNo: json["EMP_NO"],
//         password: json["Password"],
//         message: json["Message"],
//         success: json["Success"],
//         deptName: json["DEPT_NAME"],
//         empName: json["EMP_NAME"],
//         position: json["POSITION"],
//         status: json["Status"],
//     );

//     Map<String, dynamic> toJson() => {
//         "ID": id,
//         "Username": username,
//         "Email": email,
//         "EMP_NO": empNo,
//         "Password": password,
//         "Message": message,
//         "Success": success,
//         "DEPT_NAME": deptName,
//         "EMP_NAME": empName,
//         "POSITION": position,
//         "Status": status,
//     };
// }
