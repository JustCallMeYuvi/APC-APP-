class PowerPanelNamesModel {
  final String powerPanelId;
  final String displayName;

  PowerPanelNamesModel({
    required this.powerPanelId,
    required this.displayName,
  });

  factory PowerPanelNamesModel.fromJson(Map<String, dynamic> json) {
    return PowerPanelNamesModel(
      powerPanelId: json['powerPanelId'] ?? '',
      displayName: json['displayName'] ?? '',
    );
  }
}
