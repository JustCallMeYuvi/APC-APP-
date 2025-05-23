class AssetState {
  final DateTime selectedDate;
  final String? selectedAssetId;
  final String description;
  final String? selectedPlants;
  final String? assetType; // Network or Desktop
  final String? issueType; // Issue from dropdown
  final String? email;
  final String? phone;
  final List<String> assetIds; // ✅ Add this field
  
  

  AssetState({
    required this.selectedDate,
    this.selectedAssetId,
    this.description = '',
    this.selectedPlants,
    this.assetType,
    this.issueType,
    this.email,
    this.phone,
    this.assetIds = const [], // ✅ Now correctly placed in constructor
  });

  AssetState classDetails({
    DateTime? selectedDate,
    String? selectedAssetId,
    String? description,
    String? selectedPlants,
    String? assetType,
    String? issueType,
    String? email,
    String? phone,
    List<String>? assetIds,
  }) {
    return AssetState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedAssetId: selectedAssetId ?? this.selectedAssetId,
      description: description ?? this.description,
      selectedPlants: selectedPlants ?? this.selectedPlants,
      assetType: assetType ?? this.assetType,
      issueType: issueType ?? this.issueType,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      assetIds: assetIds ?? this.assetIds,
    );
  }
}
