class PanelsDueResponse {
  final Summary summary;
  final List<DuePanel> duePanels;

  PanelsDueResponse({
    required this.summary,
    required this.duePanels,
  });

  factory PanelsDueResponse.fromJson(Map<String, dynamic> json) {
    return PanelsDueResponse(
      summary: Summary.fromJson(json['summary']),
      duePanels: (json['duePanels'] as List)
          .map((e) => DuePanel.fromJson(e))
          .toList(),
    );
  }
}

class Summary {
  final int totalPanels;
  final int dueToday;
  final int upcoming;

  Summary({
    required this.totalPanels,
    required this.dueToday,
    required this.upcoming,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalPanels: json['totalPanels'],
      dueToday: json['dueToday'],
      upcoming: json['upcoming'],
    );
  }
}

class DuePanel {
  final String powerPanelId;
  final String dBName;
  final String plant;
  final int intervalDays;
  final String lastCreatedDate;
  final int daysCompleted;

  DuePanel({
    required this.powerPanelId,
    required this.dBName,
    required this.plant,
    required this.intervalDays,
    required this.lastCreatedDate,
    required this.daysCompleted,
  });

  factory DuePanel.fromJson(Map<String, dynamic> json) {
    return DuePanel(
      powerPanelId: json['powerPanelId'],
      dBName: json['dB_NAME'],
      plant: json['plant'],
      intervalDays: json['intervalDays'],
      lastCreatedDate: json['lastCreatedDate'],
      daysCompleted: json['daysCompleted'],
    );
  }
}
