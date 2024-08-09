// // // To parse this JSON data, do
// // //
// // //     final empLeaveDetails = empLeaveDetailsFromJson(jsonString);

// import 'dart:convert';

// List<EmpLeaveDetails> empLeaveDetailsFromJson(String str) => List<EmpLeaveDetails>.from(json.decode(str).map((x) => EmpLeaveDetails.fromJson(x)));

// String empLeaveDetailsToJson(List<EmpLeaveDetails> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class EmpLeaveDetails {
//     String holidayId;
//     String empNo;
//     String deptNo;
//     String holidayKind;
//     DateTime startDate;
//     DateTime endDate;
//     // int holidayQty;
//     double holidayQty; // Adjusted to double to match backend

//     EmpLeaveDetails({
//         required this.holidayId,
//         required this.empNo,
//         required this.deptNo,
//         required this.holidayKind,
//         required this.startDate,
//         required this.endDate,
//         required this.holidayQty,
//     });

//     factory EmpLeaveDetails.fromJson(Map<String, dynamic> json) => EmpLeaveDetails(
//         holidayId: json["HOLIDAY_ID"],
//         empNo: json["EMP_NO"],
//         deptNo: json["DEPT_NO"],
//         holidayKind: json["HOLIDAY_KIND"],
//         startDate: DateTime.parse(json["START_DATE"]),
//         endDate: DateTime.parse(json["END_DATE"]),
//         // holidayQty: json["HOLIDAY_QTY"],
//     holidayQty: json["HOLIDAY_QTY"].toDouble(), // Convert to double
//     );

//     Map<String, dynamic> toJson() => {
//         "HOLIDAY_ID": holidayId,
//         "EMP_NO": empNo,
//         "DEPT_NO": deptNo,
//         "HOLIDAY_KIND": holidayKind,
//         "START_DATE": startDate.toIso8601String(),
//         "END_DATE": endDate.toIso8601String(),
//         "HOLIDAY_QTY": holidayQty,
//     };
// }



 // below is 9042 localhost api
// To parse this JSON data, do
//
//     final empLeaveDetails = empLeaveDetailsFromJson(jsonString);

// import 'dart:convert';

// List<EmpLeaveDetails> empLeaveDetailsFromJson(String str) => List<EmpLeaveDetails>.from(json.decode(str).map((x) => EmpLeaveDetails.fromJson(x)));

// String empLeaveDetailsToJson(List<EmpLeaveDetails> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class EmpLeaveDetails {
//     // HolidaYId holidaYId;
//     String holidaYId;
//     String emPNo;
//     DepTNo depTNo;
//     String holidaYKind;
//     DateTime starTDate;
//     DateTime enDDate;
//     // int holidaYQty;
//      double holidaYQty; // Adjusted to double to match backend
//     dynamic message;

//     EmpLeaveDetails({
//         required this.holidaYId,
//         required this.emPNo,
//         required this.depTNo,
//         required this.holidaYKind,
//         required this.starTDate,
//         required this.enDDate,
//         required this.holidaYQty,
//         required this.message,
//     });

//     factory EmpLeaveDetails.fromJson(Map<String, dynamic> json) => EmpLeaveDetails(
//         // holidaYId: holidaYIdValues.map[json["holidaY_ID"]]!,
//        holidaYId: json["HOLIDAY_ID"],
//         emPNo: json["emP_NO"],
//         depTNo: depTNoValues.map[json["depT_NO"]]!,
//         holidaYKind: json["holidaY_KIND"],
//         starTDate: DateTime.parse(json["starT_DATE"]),
//         enDDate: DateTime.parse(json["enD_DATE"]),
//         holidaYQty: json["holidaY_QTY"].toDouble(),
//             // holidaYQty: json["HOLIDAY_QTY"].toDouble(), // Convert to double
//         message: json["message"],
//     );

//     Map<String, dynamic> toJson() => {
//         // "holidaY_ID": holidaYIdValues.reverse[holidaYId],
//          "HOLIDAY_ID": holidaYId,
//         "emP_NO": emPNo,
//         "depT_NO": depTNoValues.reverse[depTNo],
//         "holidaY_KIND": holidaYKind,
//         "starT_DATE": starTDate.toIso8601String(),
//         "enD_DATE": enDDate.toIso8601String(),
//         "holidaY_QTY": holidaYQty,
//           //  "HOLIDAY_QTY": holidaYQty,
//         "message": message,
//     };
// }

// enum DepTNo {
//     M8112
// }

// final depTNoValues = EnumValues({
//     "M8112": DepTNo.M8112
// });

// enum HolidaYId {
//     CJ0_C2401008800
// }

// final holidaYIdValues = EnumValues({
//     "CJ0C2401008800": HolidaYId.CJ0_C2401008800
// });

// class EnumValues<T> {
//     Map<String, T> map;
//     late Map<T, String> reverseMap;

//     EnumValues(this.map);

//     Map<T, String> get reverse {
//             reverseMap = map.map((k, v) => MapEntry(v, k));
//             return reverseMap;
//     }
// }





import 'dart:convert';

List<EmpLeaveDetails> empLeaveDetailsFromJson(String str) => List<EmpLeaveDetails>.from(json.decode(str).map((x) => EmpLeaveDetails.fromJson(x)));

String empLeaveDetailsToJson(List<EmpLeaveDetails> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EmpLeaveDetails {
    String holidaYId;
    String emPNo;
    String depTNo;
    String holidaYKind;
    DateTime starTDate;
    DateTime enDDate;
    double holidaYQty;
    dynamic message;

    EmpLeaveDetails({
        required this.holidaYId,
        required this.emPNo,
        required this.depTNo,
        required this.holidaYKind,
        required this.starTDate,
        required this.enDDate,
        required this.holidaYQty,
        required this.message,
    });

    factory EmpLeaveDetails.fromJson(Map<String, dynamic> json) => EmpLeaveDetails(
        holidaYId: json["holidaY_ID"],
        emPNo: json["emP_NO"],
        depTNo: json["depT_NO"],
        holidaYKind: json["holidaY_KIND"],
        starTDate: DateTime.parse(json["starT_DATE"]),
        enDDate: DateTime.parse(json["enD_DATE"]),
        holidaYQty: json["holidaY_QTY"].toDouble(),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "holidaY_ID": holidaYId,
        "emP_NO": emPNo,
        "depT_NO": depTNo,
        "holidaY_KIND": holidaYKind,
        "starT_DATE": starTDate.toIso8601String(),
        "enD_DATE": enDDate.toIso8601String(),
        "holidaY_QTY": holidaYQty,
        "message": message,
    };
}
