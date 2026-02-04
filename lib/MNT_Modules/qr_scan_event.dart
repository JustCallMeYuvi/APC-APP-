abstract class QrScanEvent {}

class StartQrScan extends QrScanEvent {}
class FetchPanelDetails extends QrScanEvent {
  final String panelId;
  FetchPanelDetails(this.panelId);
}