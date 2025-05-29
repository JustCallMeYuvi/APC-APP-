// To parse this JSON data, do
//
//     final productionData = productionDataFromJson(jsonString);

import 'dart:convert';

ProductionDataModel productionDataFromJson(String str) =>
    ProductionDataModel.fromJson(json.decode(str));

String productionDataToJson(ProductionDataModel data) =>
    json.encode(data.toJson());

class ProductionDataModel {
  List<Department> summary;
  List<Department> departments;
  List<String> departmentList;
  List<String> companyList;

  ProductionDataModel({
    required this.summary,
    required this.departments,
    required this.departmentList,
    required this.companyList,
  });

  factory ProductionDataModel.fromJson(Map<String, dynamic> json) =>
      ProductionDataModel(
        summary: List<Department>.from(
            json["summary"].map((x) => Department.fromJson(x))),
        departments: List<Department>.from(
            json["departments"].map((x) => Department.fromJson(x))),
        departmentList: List<String>.from(json["departmentList"].map((x) => x)),
        companyList: List<String>.from(json["companyList"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "summary": List<dynamic>.from(summary.map((x) => x.toJson())),
        "departments": List<dynamic>.from(departments.map((x) => x.toJson())),
        "departmentList": List<dynamic>.from(departmentList.map((x) => x)),
        "companyList": List<dynamic>.from(companyList.map((x) => x)),
      };
}

// class Department {
//   ScanDate scanDate;
//   String udf05;
//   int target;
//   int output;
//   int achievement;
//   String achievementPercent;

//   Department({
//     required this.scanDate,
//     required this.udf05,
//     required this.target,
//     required this.output,
//     required this.achievement,
//     required this.achievementPercent,
//   });

//   factory Department.fromJson(Map<String, dynamic> json) => Department(
//         scanDate: scanDateValues.map[json["scanDate"]]!,
//         udf05: json["udf05"],
//         target: json["target"],
//         output: json["output"],
//         achievement: json["achievement"],
//         achievementPercent: json["achievementPercent"],
//       );

//   Map<String, dynamic> toJson() => {
//         "scanDate": scanDateValues.reverse[scanDate],
//         "udf05": udf05,
//         "target": target,
//         "output": output,
//         "achievement": achievement,
//         "achievementPercent": achievementPercent,
//       };
// }

class Department {
  String scanDate; // changed from ScanDate to String
  String udf05;
  int target;
  int output;
  int achievement;
  String achievementPercent;

  Department({
    required this.scanDate,
    required this.udf05,
    required this.target,
    required this.output,
    required this.achievement,
    required this.achievementPercent,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        scanDate: json["scanDate"], // now a String
        udf05: json["udf05"],
        target: json["target"],
        output: json["output"],
        achievement: json["achievement"],
        achievementPercent: json["achievementPercent"],
      );

  Map<String, dynamic> toJson() => {
        "scanDate": scanDate,
        "udf05": udf05,
        "target": target,
        "output": output,
        "achievement": achievement,
        "achievementPercent": achievementPercent,
      };
}

// enum ScanDate { THE_20250529 }

// final scanDateValues = EnumValues({"2025/05/29": ScanDate.THE_20250529});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
