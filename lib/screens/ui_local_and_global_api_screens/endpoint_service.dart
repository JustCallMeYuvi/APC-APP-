import 'dart:convert';
import 'package:animated_movies_app/model/endpoint_model.dart';
import 'package:http/http.dart' as http;

class EndpointService {
  static const String baseUrl = "http://10.3.0.70:9042/api/HR";
  static const String fetchUrl = "$baseUrl/Endpoints";

  // ✅ ALREADY EXISTING – NO CHANGE
  static Future<List<EndpointModel>> fetchEndpoints() async {
    final response = await http.get(Uri.parse(fetchUrl));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => EndpointModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load endpoints");
    }
  }

  // ➕ ADD NEW API
  static Future<bool> addEndpoint(EndpointModel model) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": 0,
        "server": model.server,
        "projectName": model.projectName,
        "publicApiUrl": model.publicApiUrl,
        "localApiUrl": model.localApiUrl,
        "isActive": true,
        "createdAt": DateTime.now().toIso8601String(),
        "updatedAt": DateTime.now().toIso8601String(),
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }




  // ✅ TOGGLE ACTIVE / INACTIVE
  static Future<bool> updateActive(
    EndpointModel model,
    bool isActive,
  ) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": model.id,
        "server": model.server,
        "projectName": model.projectName,
        "publicApiUrl": model.publicApiUrl,
        "localApiUrl": model.localApiUrl,
        "isActive": isActive,
        "createdAt": model.createdAt,
        "updatedAt": DateTime.now().toIso8601String(),
      }),
    );

    return response.statusCode == 200;
  }



static Future<bool> updateEndpoint(EndpointModel model) async {
  final response = await http.put(
    Uri.parse("http://10.3.0.70:9042/api/HR/${model.id}"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "id": model.id,
      "server": model.server,
      "projectName": model.projectName,
      "publicApiUrl": model.publicApiUrl,
      "localApiUrl": model.localApiUrl,
      "isActive": model.isActive,
    }),
  );

  return response.statusCode == 200 || response.statusCode == 204;
}



  static Future<bool> deleteEndpoint(int id) async {
  final response = await http.delete(
    Uri.parse("http://10.3.0.70:9042/api/HR/$id"),
  );

  return response.statusCode == 200 || response.statusCode == 204;
}

}
