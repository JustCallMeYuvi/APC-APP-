// To parse this JSON data, do
//
//     final lineWiseDataModel = lineWiseDataModelFromJson(jsonString);

import 'dart:convert';

List<LineWiseDataModel> lineWiseDataModelFromJson(String str) => List<LineWiseDataModel>.from(json.decode(str).map((x) => LineWiseDataModel.fromJson(x)));

String lineWiseDataModelToJson(List<LineWiseDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LineWiseDataModel {
    String date;
    String department;
    int target;
    int output;
    int achievement;
    String achievementPercent;
    String manPower;

    LineWiseDataModel({
        required this.date,
        required this.department,
        required this.target,
        required this.output,
        required this.achievement,
        required this.achievementPercent,
        required this.manPower,
    });

    factory LineWiseDataModel.fromJson(Map<String, dynamic> json) => LineWiseDataModel(
        date: json["date"],
        department: json["department"],
        target: json["target"],
        output: json["output"],
        achievement: json["achievement"],
        achievementPercent: json["achievementPercent"],
        manPower: json["manPower"],
    );

    Map<String, dynamic> toJson() => {
        "date": date,
        "department": department,
        "target": target,
        "output": output,
        "achievement": achievement,
        "achievementPercent": achievementPercent,
        "manPower": manPower,
    };
}
