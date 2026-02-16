class PowerPanelHistoryModel {
  final PanelDetails panelDetails;
  final Summary summary;
  final List<Record> records;

  PowerPanelHistoryModel({
    required this.panelDetails,
    required this.summary,
    required this.records,
  });

  factory PowerPanelHistoryModel.fromJson(Map<String, dynamic> json) {
    return PowerPanelHistoryModel(
      panelDetails: PanelDetails.fromJson(json['panelDetails']),
      summary: Summary.fromJson(json['summary']),
      records: (json['records'] as List)
          .map((e) => Record.fromJson(e))
          .toList(),
    );
  }
}

class PanelDetails {
  final int id;
  final String powerPanelId;
  final String dB_NAME;
  final String incoming;
  final String outgoing;
  final String capacity;
  final String location;
  final String plant;
  final String panelType;
  final String createdAt;

  PanelDetails({
    required this.id,
    required this.powerPanelId,
    required this.dB_NAME,
    required this.incoming,
    required this.outgoing,
    required this.capacity,
    required this.location,
    required this.plant,
    required this.panelType,
    required this.createdAt,
  });

  factory PanelDetails.fromJson(Map<String, dynamic> json) {
    return PanelDetails(
      id: json['id'] ?? 0,
      powerPanelId: json['powerPanelId'] ?? '',
      dB_NAME: json['dB_NAME'] ?? '',
      incoming: json['incoming'] ?? '',
      outgoing: json['outgoing'] ?? '',
      capacity: json['capacity'] ?? '',
      location: json['location'] ?? '',
      plant: json['plant'] ?? '',
      panelType: json['panelType'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class Summary {
  final int totalCount;
  final int panelGood;
  final int panelNotGood;
  final int switchGood;
  final int switchNotGood;
  final int cableGood;
  final int cableNotGood;
  final int overallGood;
  final int overallNotGood;

  Summary({
    required this.totalCount,
    required this.panelGood,
    required this.panelNotGood,
    required this.switchGood,
    required this.switchNotGood,
    required this.cableGood,
    required this.cableNotGood,
    required this.overallGood,
    required this.overallNotGood,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalCount: json['totalCount'] ?? 0,
      panelGood: json['panel_Good_Count'] ?? 0,
      panelNotGood: json['panel_NotGood_Count'] ?? 0,
      switchGood: json['switch_Good_Count'] ?? 0,
      switchNotGood: json['switch_NotGood_Count'] ?? 0,
      cableGood: json['cable_Good_Count'] ?? 0,
      cableNotGood: json['cable_NotGood_Count'] ?? 0,
      overallGood: json['overall_Good_Count'] ?? 0,
      overallNotGood: json['overall_NotGood_Count'] ?? 0,
    );
  }
}

class Record {
  final int id;
  final String powerPanelId;
  final int panelCondition;
  final int switchCondition;
  final int cableCondition;
  final int overallCondition;
  final int createdBy;
  final String createdDate;

  Record({
    required this.id,
    required this.powerPanelId,
    required this.panelCondition,
    required this.switchCondition,
    required this.cableCondition,
    required this.overallCondition,
    required this.createdBy,
    required this.createdDate,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'] ?? 0,
      powerPanelId: json['powerPanelId'] ?? '',
      panelCondition: json['panelCondition'] ?? 0,
      switchCondition: json['switchCondition'] ?? 0,
      cableCondition: json['cableFasteningCondition'] ?? 0,
      overallCondition: json['overallCondition'] ?? 0,
      createdBy: json['createdBy'] ?? 0,
      createdDate: json['createdDate'] ?? '',
    );
  }
}
