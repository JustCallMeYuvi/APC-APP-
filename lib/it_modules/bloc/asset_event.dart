abstract class AssetEvent {}

class DateChanged extends AssetEvent {
  final DateTime date;
  DateChanged(this.date);
}

class AssetIdChanged extends AssetEvent {
  final String assetId;
  AssetIdChanged(this.assetId);
}

class DescriptionChanged extends AssetEvent {
  final String description;
  DescriptionChanged(this.description);
}

class SubmitAsset extends AssetEvent {}
