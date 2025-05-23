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

class PlantChanged extends AssetEvent {
  final String plant;
  PlantChanged(this.plant);
}

class AssetTypeChanged extends AssetEvent {
  final String assetType; // "Network" or "Desktop"
  AssetTypeChanged(this.assetType);
}

class IssueTypeChanged extends AssetEvent {
  final String issueType;
  IssueTypeChanged(this.issueType);
}

class EmailChanged extends AssetEvent {
  final String email;
  EmailChanged(this.email);
}

class PhoneChanged extends AssetEvent {
  final String phone;
  PhoneChanged(this.phone);
}
class FetchAssetIds extends AssetEvent {}


class SubmitAsset extends AssetEvent {}
