class PunchDetailModel {
  final int visE_ID;
  final String emP_NO;
  final DateTime inserT_DATE;
  final String visE_BECAUSE;

  PunchDetailModel({
    required this.visE_ID,
    required this.emP_NO,
    required this.inserT_DATE,
    required this.visE_BECAUSE,
  });

  factory PunchDetailModel.fromJson(Map<String, dynamic> json) {
    return PunchDetailModel(
      visE_ID: json['visE_ID'],
      emP_NO: json['emP_NO'],
      inserT_DATE: DateTime.parse(json['inserT_DATE']),
      visE_BECAUSE: json['visE_BECAUSE'],
    );
  }
}
