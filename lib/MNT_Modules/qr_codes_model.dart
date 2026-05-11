class OrgCodeModel {
  final int orgCode;
  final String orgName;

  OrgCodeModel({
    required this.orgCode,
    required this.orgName,
  });

  factory OrgCodeModel.fromJson(Map<String, dynamic> json) {
    return OrgCodeModel(
      orgCode: json['orG_CODE'],
      orgName: json['orG_NAME'],
    );
  }
}