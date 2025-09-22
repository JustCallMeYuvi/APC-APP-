  // To parse this JSON data, do
//
//     final getCarInOutDataModel = getCarInOutDataModelFromJson(jsonString);

import 'dart:convert';

GetCarInOutDataModel getCarInOutDataModelFromJson(String str) => GetCarInOutDataModel.fromJson(json.decode(str));

String getCarInOutDataModelToJson(GetCarInOutDataModel data) => json.encode(data.toJson());

class GetCarInOutDataModel {
    String message;
    List<Datum> data;

    GetCarInOutDataModel({
        required this.message,
        required this.data,
    });

    factory GetCarInOutDataModel.fromJson(Map<String, dynamic> json) => GetCarInOutDataModel(
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    int carBookingId;
    String selectedBookingType;
    String travellers;
    DateTime travelfrom;
    DateTime destinationto;
    String designation;
    String cardetails;
    String carIntime;
    DateTime carOuttime;
    String currentState;
    DateTime startDate;

    Datum({
        required this.carBookingId,
        required this.selectedBookingType,
        required this.travellers,
        required this.travelfrom,
        required this.destinationto,
        required this.designation,
        required this.cardetails,
        required this.carIntime,
        required this.carOuttime,
        required this.currentState,
        required this.startDate,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        carBookingId: json["carBookingId"],
        selectedBookingType: json["selectedBookingType"],
        travellers: json["travellers"],
        travelfrom: DateTime.parse(json["travelfrom"]),
        destinationto: DateTime.parse(json["destinationto"]),
        designation: json["designation"],
        cardetails: json["cardetails"],
        carIntime: json["carIntime"],
        carOuttime: DateTime.parse(json["carOuttime"]),
        currentState: json["currentState"],
        startDate: DateTime.parse(json["startDate"]),
    );

    Map<String, dynamic> toJson() => {
        "carBookingId": carBookingId,
        "selectedBookingType": selectedBookingType,
        "travellers": travellers,
        "travelfrom": travelfrom.toIso8601String(),
        "destinationto": destinationto.toIso8601String(),
        "designation": designation,
        "cardetails": cardetails,
        "carIntime": carIntime,
        "carOuttime": carOuttime.toIso8601String(),
        "currentState": currentState,
        "startDate": startDate.toIso8601String(),
    };
}
