// // To parse this JSON data, do
// //
// //     final productionEmpList = productionEmpListFromJson(jsonString);

// import 'dart:convert';

// ProductionEmpList productionEmpListFromJson(String str) => ProductionEmpList.fromJson(json.decode(str));

// String productionEmpListToJson(ProductionEmpList data) => json.encode(data.toJson());

// class ProductionEmpList {
//     bool isSuccess;
//     dynamic errMsg;
//     dynamic retdata;
//     List<RetData1> retData1;

//     ProductionEmpList({
//         required this.isSuccess,
//         required this.errMsg,
//         required this.retdata,
//         required this.retData1,
//     });

//     factory ProductionEmpList.fromJson(Map<String, dynamic> json) => ProductionEmpList(
//         isSuccess: json["isSuccess"],
//         errMsg: json["errMsg"],
//         retdata: json["retdata"],
//         retData1: List<RetData1>.from(json["retData1"].map((x) => RetData1.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "isSuccess": isSuccess,
//         "errMsg": errMsg,
//         "retdata": retdata,
//         "retData1": List<dynamic>.from(retData1.map((x) => x.toJson())),
//     };
// }

// class RetData1 {
//     String barcode;
//     String empName;
//     Plant plant;

//     RetData1({
//         required this.barcode,
//         required this.empName,
//         required this.plant,
//     });

//     factory RetData1.fromJson(Map<String, dynamic> json) => RetData1(
//         barcode: json["barcode"],
//         empName: json["empName"],
//         plant: plantValues.map[json["plant"]]!,
//     );

//     Map<String, dynamic> toJson() => {
//         "barcode": barcode,
//         "empName": empName,
//         "plant": plantValues.reverse[plant],
//     };
// }

// enum Plant {
//     AP1,
//     AP10,
//     AP11,
//     AP12,
//     AP2,
//     AP3,
//     AP5,
//     AP6,
//     AP7,
//     AP8,
//     AP9,
//     APC,
//     API,
//     SPD,
//     TRAINING_CENTER
// }

// final plantValues = EnumValues({
//     "AP1": Plant.AP1,
//     "AP10": Plant.AP10,
//     "AP11": Plant.AP11,
//     "AP12": Plant.AP12,
//     "AP2": Plant.AP2,
//     "AP3": Plant.AP3,
//     "AP5": Plant.AP5,
//     "AP6": Plant.AP6,
//     "AP7": Plant.AP7,
//     "AP8": Plant.AP8,
//     "AP9": Plant.AP9,
//     "APC": Plant.APC,
//     "API": Plant.API,
//     "SPD": Plant.SPD,
//     "Training Center": Plant.TRAINING_CENTER
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

ProductionEmpList productionEmpListFromJson(String str) =>
    ProductionEmpList.fromJson(json.decode(str));

String productionEmpListToJson(ProductionEmpList data) => json.encode(data.toJson());

class ProductionEmpList {
  final bool isSuccess;
  final String? errMsg;
  final dynamic retdata;
  final List<RetData1> retData1;

  ProductionEmpList({
    required this.isSuccess,
    this.errMsg,
    this.retdata,
    required this.retData1,
  });

  factory ProductionEmpList.fromJson(Map<String, dynamic> json) {
    return ProductionEmpList(
      isSuccess: json["isSuccess"],
      errMsg: json["errMsg"],
      retdata: json["retdata"],
      retData1: json["retData1"] == null
          ? []
          : List<RetData1>.from(json["retData1"].map((x) => RetData1.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "isSuccess": isSuccess,
        "errMsg": errMsg,
        "retdata": retdata,
        "retData1": List<dynamic>.from(retData1.map((x) => x.toJson())),
      };
}

class RetData1 {
  final String barcode;
  final String empName;
  final Plant? plant;

  RetData1({
    required this.barcode,
    required this.empName,
    this.plant,
  });

  factory RetData1.fromJson(Map<String, dynamic> json) => RetData1(
        barcode: json["barcode"],
        empName: json["empName"],
        plant: json["plant"] == null ? null : plantValues.map[json["plant"]],
      );

  Map<String, dynamic> toJson() => {
        "barcode": barcode,
        "empName": empName,
        "plant": plantValues.reverse[plant],
      };
}

enum Plant {
  AP1,
  AP10,
  AP11,
  AP12,
  AP2,
  AP3,
  AP5,
  AP6,
  AP7,
  AP8,
  AP9,
  APC,
  API,
  SPD,
  TRAINING_CENTER
}

final plantValues = EnumValues({
  "AP1": Plant.AP1,
  "AP10": Plant.AP10,
  "AP11": Plant.AP11,
  "AP12": Plant.AP12,
  "AP2": Plant.AP2,
  "AP3": Plant.AP3,
  "AP5": Plant.AP5,
  "AP6": Plant.AP6,
  "AP7": Plant.AP7,
  "AP8": Plant.AP8,
  "AP9": Plant.AP9,
  "APC": Plant.APC,
  "API": Plant.API,
  "SPD": Plant.SPD,
  "Training Center": Plant.TRAINING_CENTER
});

class EnumValues<T> {
  final Map<String, T> map;
  late final Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
