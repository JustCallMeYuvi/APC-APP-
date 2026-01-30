class QrScanState {
  final bool isLoading;
  final String? scannedData;
  final String? error;

  const QrScanState({
    this.isLoading = false,
    this.scannedData,
    this.error,
  });

  QrScanState copyWith({
    bool? isLoading,
    String? scannedData,
    String? error,
  }) {
    return QrScanState(
      isLoading: isLoading ?? this.isLoading,
      scannedData: scannedData ?? this.scannedData,
      error: error,
    );
  }
}
