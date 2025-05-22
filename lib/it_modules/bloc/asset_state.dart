class AssetState {
  final DateTime selectedDate;
  final String? selectedAssetId;
  final String description;

  AssetState({
    required this.selectedDate,
    this.selectedAssetId,
    this.description = '',
  });

  AssetState copyWith({
    DateTime? selectedDate,
    String? selectedAssetId,
    String? description,
  }) {
    return AssetState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedAssetId: selectedAssetId ?? this.selectedAssetId,
      description: description ?? this.description,
    );
  }
}
