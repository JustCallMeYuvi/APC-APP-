// class ChangePasswordApi {
//   bool status;
//   String message;

//   ChangePasswordApi({
//     required this.status,
//     required this.message,
//   });

//   factory ChangePasswordApi.fromJson(Map<String, dynamic> json) => ChangePasswordApi(
//         status: json['Status'],
//         message: json['Message'],
//       );

//   Map<String, dynamic> toJson() => {
//         'Status': status,
//         'Message': message,
//       };
// }


// To parse this JSON data, do
//
//     final changePasswordApi = changePasswordApiFromJson(jsonString);

// below is 9042 api

import 'dart:convert';

ChangePasswordApi changePasswordApiFromJson(String str) => ChangePasswordApi.fromJson(json.decode(str));

String changePasswordApiToJson(ChangePasswordApi data) => json.encode(data.toJson());

class ChangePasswordApi {
    bool status;
    String message;
    int httpCode;
    dynamic data;
    int statusCode;

    ChangePasswordApi({
        required this.status,
        required this.message,
        required this.httpCode,
        required this.data,
        required this.statusCode,
    });

    factory ChangePasswordApi.fromJson(Map<String, dynamic> json) => ChangePasswordApi(
        status: json["status"],
        message: json["message"],
        httpCode: json["httpCode"],
        data: json["data"],
        statusCode: json["statusCode"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "httpCode": httpCode,
        "data": data,
        "statusCode": statusCode,
    };
}
