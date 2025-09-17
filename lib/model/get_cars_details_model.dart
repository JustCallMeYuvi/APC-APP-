// To parse this JSON data, do
//
//     final getCarsDetailsModel = getCarsDetailsModelFromJson(jsonString);

import 'dart:convert';

GetCarsDetailsModel getCarsDetailsModelFromJson(String str) =>
    GetCarsDetailsModel.fromJson(json.decode(str));

String getCarsDetailsModelToJson(GetCarsDetailsModel data) =>
    json.encode(data.toJson());

class GetCarsDetailsModel {
  String message;
  List<Datum> data;

  GetCarsDetailsModel({
    required this.message,
    required this.data,
  });

  factory GetCarsDetailsModel.fromJson(Map<String, dynamic> json) =>
      GetCarsDetailsModel(
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  String caRName;
  String caRNo;
  String capacity;
  String driveRName;
  CaRBookingType caRBookingType;
  dynamic insertedBy;
  dynamic querytype;

  Datum({
    required this.caRName,
    required this.caRNo,
    required this.capacity,
    required this.driveRName,
    required this.caRBookingType,
    required this.insertedBy,
    required this.querytype,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        caRName: json["caR_NAME"],
        caRNo: json["caR_NO"],
        capacity: json["capacity"],
        driveRName: json["driveR_NAME"],
        caRBookingType: caRBookingTypeValues.map[json["caR_BOOKING_TYPE"]]!,
        insertedBy: json["inserted_By"],
        querytype: json["querytype"],
      );

  Map<String, dynamic> toJson() => {
        "caR_NAME": caRName,
        "caR_NO": caRNo,
        "capacity": capacity,
        "driveR_NAME": driveRName,
        "caR_BOOKING_TYPE": caRBookingTypeValues.reverse[caRBookingType],
        "inserted_By": insertedBy,
        "querytype": querytype,
      };
}

enum CaRBookingType { EMERGENCY, EMPTY, NORMAL, VIP }

final caRBookingTypeValues = EnumValues({
  "EMERGENCY": CaRBookingType.EMERGENCY,
  "": CaRBookingType.EMPTY,
  "NORMAL": CaRBookingType.NORMAL,
  "VIP": CaRBookingType.VIP
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
