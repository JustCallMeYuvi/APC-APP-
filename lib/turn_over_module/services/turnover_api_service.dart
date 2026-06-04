
// ════════════════════════════════════════════════════════════
//  API SERVICE
// ════════════════════════════════════════════════════════════

import 'dart:convert';

import 'package:animated_movies_app/turn_over_module/models/turnover_record.dart';

import '../models/filter_state.dart';
import 'package:http/http.dart' as http;


class TurnoverApiService {
  static const String _baseUrl =
      'http://10.3.0.70:9042/api/HR/GetTurnOverReport';

  static Future<List<TurnoverRecord>> fetch(FilterState fs) async {
    final body =
        fs.subView == SubView.yearwise ? fs.yearwiseBody : fs.monthwiseBody;

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {'accept': '*/*', 'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('API failed [${response.statusCode}]: ${response.body}');
    }

    final List<dynamic> list = jsonDecode(response.body);
    return list
        .map((e) => TurnoverRecord.fromJson(e,
            isMonth: fs.subView == SubView.monthwise))
        .toList();
  }
}
