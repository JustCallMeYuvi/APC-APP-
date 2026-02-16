import 'dart:convert';
import 'package:animated_movies_app/MNT_Modules/Power_panels/power_panel_history_model.dart';
import 'package:animated_movies_app/MNT_Modules/Power_panels/power_panel_names_model.dart';
import 'package:http/http.dart' as http;

class PowerPanelRepository {

  // 🔹 Dropdown API
  Future<List<PowerPanelNamesModel>> fetchPanels() async {
    final response = await http.get(
      Uri.parse('http://10.3.0.70:9042/api/MNT_/panels-names'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((e) => PowerPanelNamesModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load panels");
    }
  }

  // 🔥 History API (MUST BE INSIDE CLASS)
  Future<PowerPanelHistoryModel> fetchPanelHistory(
    String powerPanelId,
    String fromDate,
    String toDate,
  ) async {

    final response = await http.get(
      Uri.parse(
        'http://10.3.0.70:9042/api/MNT_/panels-history'
        '?powerPanelId=$powerPanelId'
        '&fromDate=$fromDate'
        '&toDate=$toDate',
      ),
    );

    if (response.statusCode == 200) {
      return PowerPanelHistoryModel.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception("Failed to load history");
    }
  }

}
