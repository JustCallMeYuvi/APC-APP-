// // emp_count_model.dart
// import 'dart:convert';

// List<EmpCount> empCountFromJson(String str) =>
//     List<EmpCount>.from(json.decode(str).map((x) => EmpCount.fromJson(x)));

// String empCountToJson(List<EmpCount> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class EmpCount {
//   int year;
//   int totalJoined;
//   int totalResigned;

//   EmpCount({
//     required this.year,
//     required this.totalJoined,
//     required this.totalResigned,
//   });

//   factory EmpCount.fromJson(Map<String, dynamic> json) => EmpCount(
//         year: json["year"],
//         totalJoined: json["total_joined"],
//         totalResigned: json["total_resigned"],
//       );

//   Map<String, dynamic> toJson() => {
//         "year": year,
//         "total_joined": totalJoined,
//         "total_resigned": totalResigned,
//       };
// }

// To parse this JSON data, do
//
//     final empCount = empCountFromJson(jsonString);

// import 'dart:convert';

// EmpCount empCountFromJson(String str) => EmpCount.fromJson(json.decode(str));

// String empCountToJson(EmpCount data) => json.encode(data.toJson());

// class EmpCount {
//   int totalActive;
//   List<Datum> data;

//   EmpCount({
//     required this.totalActive,
//     required this.data,
//   });

//   factory EmpCount.fromJson(Map<String, dynamic> json) {
//     final rawData = json["data"];
//     List<Datum> parsedData = [];

//     if (rawData is List) {
//       // ✔ Case 1: data is a JSON array
//       parsedData = rawData
//           .where((e) => e != null)
//           .map<Datum>((e) => Datum.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } else if (rawData is Map) {
//       // ✔ Case 2: data is a JSON object / map
//       parsedData = (rawData as Map).entries.map<Datum>((entry) {
//         final keyStr = entry.key.toString();
//         final value = entry.value;

//         if (value is Map<String, dynamic>) {
//           // data: { "2020": { "total_joined": ..., "total_resigned": ... } }
//           return Datum(
//             year: value["year"] ?? int.tryParse(keyStr) ?? 0,
//             totalJoined: (value["total_joined"] ?? 0) as int,
//             totalResigned: (value["total_resigned"] ?? 0) as int,
//           );
//         } else if (value is num) {
//           // data: { "2020": 10, "2021": 15 }  -> only totalJoined
//           return Datum(
//             year: int.tryParse(keyStr) ?? 0,
//             totalJoined: value.toInt(),
//             totalResigned: 0,
//           );
//         } else {
//           // Unknown format -> default safe object
//           return Datum(
//             year: int.tryParse(keyStr) ?? 0,
//             totalJoined: 0,
//             totalResigned: 0,
//           );
//         }
//       }).toList();
//     }

//     return EmpCount(
//       totalActive: (json["total_active"] ?? 0) as int,
//       data: parsedData,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "total_active": totalActive,
//         "data": List<dynamic>.from(data.map((x) => x.toJson())),
//       };
// }

// class Datum {
//   int year;
//   int totalJoined;
//   int totalResigned;

//   Datum({
//     required this.year,
//     required this.totalJoined,
//     required this.totalResigned,
//   });

//   factory Datum.fromJson(Map<String, dynamic> json) => Datum(
//         year: json["year"],
//         totalJoined: json["total_joined"],
//         totalResigned: json["total_resigned"],
//       );

//   Map<String, dynamic> toJson() => {
//         "year": year,
//         "total_joined": totalJoined,
//         "total_resigned": totalResigned,
//       };
// }


// To parse this JSON data, do
//
//   final empCount = empCountFromJson(jsonString);

import 'dart:convert';

EmpCount empCountFromJson(String str) =>
    EmpCount.fromJson(json.decode(str));

String empCountToJson(EmpCount data) =>
    json.encode(data.toJson());

class EmpCount {
  final int totalActive;
  final List<EmpItem> data; // always a list in Dart

  EmpCount({
    required this.totalActive,
    required this.data,
  });

  factory EmpCount.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    // data can be:
    // 1) List    -> allyears / allmonthsofyear
    // 2) Object  -> monthwise
    final List<dynamic> list;
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map<String, dynamic>) {
      list = [rawData]; // wrap single item as list of length 1
    } else {
      list = [];
    }

    return EmpCount(
      totalActive: json['total_active'] ?? 0,
      data: list
          .map((e) => EmpItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_active': totalActive,
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class EmpItem {
  final int year;
  final int? month;        // 👈 nullable, because allyears has no month
  final int totalJoined;
  final int totalResigned;

  EmpItem({
    required this.year,
    this.month,
    required this.totalJoined,
    required this.totalResigned,
  });

  factory EmpItem.fromJson(Map<String, dynamic> json) => EmpItem(
        year: json['year'] ?? 0,
        month: json['month'], // may be null
        totalJoined: json['total_joined'] ?? 0,
        totalResigned: json['total_resigned'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'year': year,
        if (month != null) 'month': month, // only send if not null
        'total_joined': totalJoined,
        'total_resigned': totalResigned,
      };
}
