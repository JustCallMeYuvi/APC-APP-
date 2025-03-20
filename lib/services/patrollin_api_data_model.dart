import 'dart:convert';

PatrollingApiData patrollingApiDataFromJson(String str) =>
    PatrollingApiData.fromJson(json.decode(str));

String patrollingApiDataToJson(PatrollingApiData data) =>
    json.encode(data.toJson());

class PatrollingApiData {
  String message;
  PatrollingData data;

  PatrollingApiData({
    required this.message,
    required this.data,
  });

  factory PatrollingApiData.fromJson(Map<String, dynamic> json) =>
      PatrollingApiData(
        message: json["message"],
        data: PatrollingData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
      };
}

class PatrollingData {
  List<Datum> data;

  PatrollingData({
    required this.data,
  });

  factory PatrollingData.fromJson(Map<String, dynamic> json) => PatrollingData(
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
  List<StopPoint> stopPoints;

  Datum({
    required this.id,
    required this.userId,
    required this.patrollingType,
    required this.shift,
    required this.createdAt,
    required this.stopPoints,
  });

  // factory Datum.fromJson(Map<String, dynamic> json) => Datum(
  //       id: json["id"],
  //       userId: json["userID"],
  //       patrollingType: json["patrollingType"],
  //       shift: json["shift"],
  //       createdAt: DateTime.parse(json["createdAt"]),
  //       stopPoints: List<StopPoint>.from(
  //           json["stop_Points"].map((x) => StopPoint.fromJson(x))),
  //     );

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"] ?? "",
        userId: json["userID"] ?? "",
        patrollingType: json["patrollingType"] ?? "Unknown",
        shift: json["shift"] ?? "Unknown",
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : DateTime.now(),
        stopPoints: json["stop_Points"] != null
            ? List<StopPoint>.from(
                json["stop_Points"].map((x) => StopPoint.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userID": userId,
        "patrollingType": patrollingType,
        "shift": shift,
        "createdAt": createdAt.toIso8601String(),
        "stop_Points": List<dynamic>.from(stopPoints.map((x) => x.toJson())),
      };
}

class StopPoint {
  int rowindex;
  String locationid;
  String location;
  String date;

  StopPoint({
    required this.rowindex,
    required this.locationid,
    required this.location,
    required this.date,
  });

  factory StopPoint.fromJson(Map<String, dynamic> json) => StopPoint(
        rowindex: json["rowindex"],
        locationid: json["locationid"],
        location: json["location"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "rowindex": rowindex,
        "locationid": locationid,
        "location": location,
        "date": date,
      };
}
