abstract class PowerPanelEvent {}

class FetchPowerPanels extends PowerPanelEvent {}

class FetchPanelHistory extends PowerPanelEvent {
  final String powerPanelId;
  final String fromDate;
  final String toDate;

  FetchPanelHistory({
    required this.powerPanelId,
    required this.fromDate,
    required this.toDate,
  });
}
