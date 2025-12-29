class EndpointModel {
  final int id;
  final String server;
  final String projectName;
  final String publicApiUrl;
  final String localApiUrl;
  final bool isActive;
    final String createdAt;
  final String updatedAt;

  EndpointModel({
    required this.id,
    required this.server,
    required this.projectName,
    required this.publicApiUrl,
    required this.localApiUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EndpointModel.fromJson(Map<String, dynamic> json) {
    return EndpointModel(
      id: json['id'],
      server: json['server'],
      projectName: json['projectName'],
      publicApiUrl: json['publicApiUrl'],
      localApiUrl: json['localApiUrl'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  // ✅ ADD THIS METHOD
  EndpointModel copyWith({
    String? projectName,
    String? publicApiUrl,
    String? localApiUrl,
    bool? isActive,
  }) {
    return EndpointModel(
      id: id,
      server: server,
      projectName: projectName ?? this.projectName,
      publicApiUrl: publicApiUrl ?? this.publicApiUrl,
      localApiUrl: localApiUrl ?? this.localApiUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
