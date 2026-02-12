class PowerPanelModel {
  final String? powerPanelId;
  final String? panelName;
  final String? capacity;
  final String? location;
  final String? panelType;
  final String? action;
  final String? lastServiceDate;
  final String? nextDueDate;
  final int? lastRecordId;
  final String? message; // ✅ ADD THIS

  PowerPanelModel({
    this.powerPanelId,
    this.panelName,
    this.capacity,
    this.location,
    this.panelType,
    this.action,
    this.lastServiceDate,
    this.nextDueDate,
    this.lastRecordId,
    this.message,
  });

  factory PowerPanelModel.fromJson(Map<String, dynamic> json) {
    return PowerPanelModel(
      powerPanelId: json['powerPanelId'],
      panelName: json['panelName'],
      capacity: json['capacity'],
      location: json['location'],
      panelType: json['panelType'],
      action: json['action'],
      lastServiceDate: json['lastServiceDate'],
      nextDueDate: json['nextDueDate'],
      lastRecordId: json['lastRecordId'],
      message: json['message'],
    );
  }
}
