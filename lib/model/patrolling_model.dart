// To parse this JSON data, do
//
//     final patrollindData = patrollindDataFromJson(jsonString);

import 'dart:convert';

PatrollindData patrollindDataFromJson(String str) => PatrollindData.fromJson(json.decode(str));

String patrollindDataToJson(PatrollindData data) => json.encode(data.toJson());

class PatrollindData {
    String message;
    Data data;

    PatrollindData({
        required this.message,
        required this.data,
    });

    factory PatrollindData.fromJson(Map<String, dynamic> json) => PatrollindData(
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    List<Datum> data;

    Data({
        required this.data,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String id;
    String userId;
    String patrollingType;
    String shift;
    DateTime createdAt;
    StopPoints stopPoints;

    Datum({
        required this.id,
        required this.userId,
        required this.patrollingType,
        required this.shift,
        required this.createdAt,
        required this.stopPoints,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        userId: json["userID"],
        patrollingType: json["patrollingType"],
        shift: json["shift"],
        createdAt: DateTime.parse(json["createdAt"]),
        stopPoints: StopPoints.fromJson(json["stop_Points"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "userID": userId,
        "patrollingType": patrollingType,
        "shift": shift,
        "createdAt": createdAt.toIso8601String(),
        "stop_Points": stopPoints.toJson(),
    };
}

class StopPoints {
    DateTime stopPoint1;
    dynamic stopPoint2;
    DateTime stopPoint3;
    DateTime stopPoint4;
    dynamic stopPoint5;
    dynamic stopPoint6;
    dynamic stopPoint7;
    dynamic stopPoint8;
    dynamic stopPoint9;
    dynamic stopPoint10;
    dynamic stopPoint11;
    dynamic stopPoint12;
    dynamic stopPoint13;
    dynamic stopPoint14;
    dynamic stopPoint15;

    StopPoints({
        required this.stopPoint1,
        required this.stopPoint2,
        required this.stopPoint3,
        required this.stopPoint4,
        required this.stopPoint5,
        required this.stopPoint6,
        required this.stopPoint7,
        required this.stopPoint8,
        required this.stopPoint9,
        required this.stopPoint10,
        required this.stopPoint11,
        required this.stopPoint12,
        required this.stopPoint13,
        required this.stopPoint14,
        required this.stopPoint15,
    });

    factory StopPoints.fromJson(Map<String, dynamic> json) => StopPoints(
        stopPoint1: DateTime.parse(json["stop_Point_1"]),
        stopPoint2: json["stop_Point_2"],
        stopPoint3: DateTime.parse(json["stop_Point_3"]),
        stopPoint4: DateTime.parse(json["stop_Point_4"]),
        stopPoint5: json["stop_Point_5"],
        stopPoint6: json["stop_Point_6"],
        stopPoint7: json["stop_Point_7"],
        stopPoint8: json["stop_Point_8"],
        stopPoint9: json["stop_Point_9"],
        stopPoint10: json["stop_Point_10"],
        stopPoint11: json["stop_Point_11"],
        stopPoint12: json["stop_Point_12"],
        stopPoint13: json["stop_Point_13"],
        stopPoint14: json["stop_Point_14"],
        stopPoint15: json["stop_Point_15"],
    );

    Map<String, dynamic> toJson() => {
        "stop_Point_1": stopPoint1.toIso8601String(),
        "stop_Point_2": stopPoint2,
        "stop_Point_3": stopPoint3.toIso8601String(),
        "stop_Point_4": stopPoint4.toIso8601String(),
        "stop_Point_5": stopPoint5,
        "stop_Point_6": stopPoint6,
        "stop_Point_7": stopPoint7,
        "stop_Point_8": stopPoint8,
        "stop_Point_9": stopPoint9,
        "stop_Point_10": stopPoint10,
        "stop_Point_11": stopPoint11,
        "stop_Point_12": stopPoint12,
        "stop_Point_13": stopPoint13,
        "stop_Point_14": stopPoint14,
        "stop_Point_15": stopPoint15,
    };
}
