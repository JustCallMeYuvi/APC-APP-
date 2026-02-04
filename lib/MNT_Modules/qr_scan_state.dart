import 'package:animated_movies_app/MNT_Modules/power_panel_model.dart';

class QrScanState {
  final bool isLoading;

  final String? error;
  final PowerPanelModel? panel;

  const QrScanState({
    this.isLoading = false,
    this.error,
    this.panel,
  });

  QrScanState copyWith({
    bool? isLoading,
    String? error,
    PowerPanelModel? panel,
  }) {
    return QrScanState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      panel: panel ?? this.panel,
    );
  }
}
