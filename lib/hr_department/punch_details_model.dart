// class PunchDetailModel {
//   final int visE_ID;
//   final String emP_NO;
//   final DateTime inserT_DATE;
//   final String visE_BECAUSE;

//   PunchDetailModel({
//     required this.visE_ID,
//     required this.emP_NO,
//     required this.inserT_DATE,
//     required this.visE_BECAUSE,
//   });

//   factory PunchDetailModel.fromJson(Map<String, dynamic> json) {
//     return PunchDetailModel(
//       visE_ID: json['visE_ID'],
//       emP_NO: json['emP_NO'],
//       inserT_DATE: DateTime.parse(json['inserT_DATE']),
//       visE_BECAUSE: json['visE_BECAUSE'],
//     );
//   }
// }
class PunchDetailModel {
  final int viseId;
  final String empNo;
  final DateTime insertDate;
  final String viseBecause;

  PunchDetailModel({
    required this.viseId,
    required this.empNo,
    required this.insertDate,
    required this.viseBecause,
  });

  factory PunchDetailModel.fromJson(Map<String, dynamic> json) {
    return PunchDetailModel(
      viseId: json['visE_ID'],
      empNo: json['emP_NO'],
      insertDate: DateTime.parse(json['inserT_DATE']),
      viseBecause: json['visE_BECAUSE'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visE_ID': viseId,
      'emP_NO': empNo,
      'inserT_DATE': insertDate.toIso8601String(),
      'visE_BECAUSE': viseBecause,
    };
  }
}
