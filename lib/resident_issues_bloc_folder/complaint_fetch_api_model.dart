class ComplaintFetchAPIModel {
  final String complaintId;
  final String issueType;
  final String description;
  final String status;
  final String createdDate;

  ComplaintFetchAPIModel({
    required this.complaintId,
    required this.issueType,
    required this.description,
    required this.status,
    required this.createdDate,
  });

  factory ComplaintFetchAPIModel.fromJson(Map<String, dynamic> json) {
    return ComplaintFetchAPIModel(
      complaintId: json['id'].toString(),                // ✅ id
      issueType: json['complaint'] ?? '',                // ✅ complaint
      description: json['complaintRelatedDept'] ?? '',   // ✅ related dept
      status: (json['active'] == 1)                      // ✅ active → status
          ? 'Open'
          : 'Closed',
      createdDate: json['raisedDate'] ?? '',             // ✅ raisedDate
    );
  }
}
