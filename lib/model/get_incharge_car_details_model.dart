// To parse this JSON data, do
//
//     final getInchargeCarsDetailsModel = getInchargeCarsDetailsModelFromJson(jsonString);

import 'dart:convert';

GetInchargeCarsDetailsModel getInchargeCarsDetailsModelFromJson(String str) => GetInchargeCarsDetailsModel.fromJson(json.decode(str));

String getInchargeCarsDetailsModelToJson(GetInchargeCarsDetailsModel data) => json.encode(data.toJson());

class GetInchargeCarsDetailsModel {
    String message;
    List<Datum> data;

    GetInchargeCarsDetailsModel({
        required this.message,
        required this.data,
    });

    factory GetInchargeCarsDetailsModel.fromJson(Map<String, dynamic> json) => GetInchargeCarsDetailsModel(
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String barcode;
    String name;
    String dept;
    String email;
    String email2;
    dynamic insertedBy;

    Datum({
        required this.barcode,
        required this.name,
        required this.dept,
        required this.email,
        required this.email2,
        required this.insertedBy,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        barcode: json["barcode"],
        name: json["name"],
        dept: json["dept"],
        email: json["email"],
        email2: json["email2"],
        insertedBy: json["inserted_By"],
    );

    Map<String, dynamic> toJson() => {
        "barcode": barcode,
        "name": name,
        "dept": dept,
        "email": email,
        "email2": email2,
        "inserted_By": insertedBy,
    };
}
