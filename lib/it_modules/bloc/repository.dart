import 'dart:convert';
import 'package:http/http.dart' as http;

class AssetRepository {
  // Future<List<String>> fetchAssetIds() async {
  //   final url = Uri.parse('http://10.3.0.70:9093/api/Login/GetAssetDropdown');

  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     print('Asset Details ${response.body}');
  //     final List<dynamic> data = json.decode(response.body);
  //     return data.map((item) => item.toString()).toList(); // Ensure it's List<String>
  //   } else {
  //     throw Exception('Failed to load asset IDs');
  //   }
  // }
  Future<List<String>> fetchAssetIds() async {
  final url = Uri.parse('http://10.3.0.70:9093/api/Login/GetAssetDropdown');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    print('Asset Details ${response.body}');
    final List<dynamic> data = json.decode(response.body);
    return data.map<String>((item) => item['asseT_ID'] as String).toList();
  } else {
    throw Exception('Failed to load asset IDs');
  }
}

}
