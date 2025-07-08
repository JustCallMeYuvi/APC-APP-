// import 'dart:convert';

// List<GateOutVehiclesModel> gateOutVehiclesModelFromJson(String str) =>
//     List<GateOutVehiclesModel>.from(
//         json.decode(str).map((x) => GateOutVehiclesModel.fromJson(x)));

// String gateOutVehiclesModelToJson(List<GateOutVehiclesModel> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class GateOutVehiclesModel {
//   String vehicleNumber;
//   String vehicleId;
//   DateTime mainGateEntry;
//   DateTime mainGateExit;

//   GateOutVehiclesModel({
//     required this.vehicleNumber,
//     required this.vehicleId,
//     required this.mainGateEntry,
//     required this.mainGateExit,
//   });

//   factory GateOutVehiclesModel.fromJson(Map<String, dynamic> json) =>
//       GateOutVehiclesModel(
//         vehicleNumber: json["vehicleNumber"],
//         vehicleId: json["vehicleId"],
//         mainGateEntry: DateTime.parse(json["mainGateEntry"]),
//         mainGateExit: DateTime.parse(json["mainGateExit"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "vehicleNumber": vehicleNumber,
//         "vehicleId": vehicleId,
//         "mainGateEntry": mainGateEntry.toIso8601String(),
//         "mainGateExit": mainGateExit.toIso8601String(),
//       };
// }


// To parse this JSON data, do
//
//     final gateOutVehiclesModel = gateOutVehiclesModelFromJson(jsonString);

import 'dart:convert';

List<GateOutVehiclesModel> gateOutVehiclesModelFromJson(String str) => List<GateOutVehiclesModel>.from(json.decode(str).map((x) => GateOutVehiclesModel.fromJson(x)));

String gateOutVehiclesModelToJson(List<GateOutVehiclesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GateOutVehiclesModel {
    String vehicleNumber;
    String vehicleId;
    String fireGateEntry;
    String fireGateExit;

    GateOutVehiclesModel({
        required this.vehicleNumber,
        required this.vehicleId,
        required this.fireGateEntry,
        required this.fireGateExit,
    });

    factory GateOutVehiclesModel.fromJson(Map<String, dynamic> json) => GateOutVehiclesModel(
        vehicleNumber: json["vehicleNumber"],
        vehicleId: json["vehicleId"],
        fireGateEntry: (json["fireGateEntry"]),
        fireGateExit: (json["fireGateExit"]),
    );

    Map<String, dynamic> toJson() => {
        "vehicleNumber": vehicleNumber,
        "vehicleId": vehicleId,
        "fireGateEntry": fireGateEntry,
        "fireGateExit": fireGateExit,
    };
}
