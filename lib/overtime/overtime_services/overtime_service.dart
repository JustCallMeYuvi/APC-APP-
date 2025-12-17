import 'dart:convert';
import 'package:animated_movies_app/overtime/overtime_bloc/overtime_event.dart';
import 'package:animated_movies_app/overtime/overtime_models/datewise_model.dart';
import 'package:animated_movies_app/overtime/overtime_models/overall_model.dart';
import 'package:animated_movies_app/overtime/overtime_models/weekwise_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../api/apis_page.dart';

class OverTimeService {
  final DateFormat _apiFormat = DateFormat("yyyy-MM-dd");

  String _from(DateTime d) => _apiFormat.format(d);

  String _to(DateTime d) => _apiFormat.format(d.add(const Duration(days: 1)));

  Future<dynamic> fetchOverTime({
    required OtType type,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final typeStr = {
      OtType.overall: "overall",
      OtType.weekwise: "weekwise",
      OtType.datewise: "datewise",
    }[type]!;

    final url =
        "${ApiHelper.baseUrl}OtCount?type=$typeStr&fromdate=${_from(fromDate)}&todate=${_to(toDate)}";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch OT data (${response.statusCode})");
    }

    final data = json.decode(response.body);
    // 🔴 HANDLE NO DATA
    if (data == null || data is! List || data.isEmpty) {
      return null; // 👈 IMPORTANT
    }
    switch (type) {
      case OtType.overall:
        return OverallModel.fromJson(data[0]);

      case OtType.weekwise:
        return (data as List).map((e) => WeekwiseModel.fromJson(e)).toList();

      case OtType.datewise:
        return (data as List).map((e) => DatewiseModel.fromJson(e)).toList();
    }
  }
}
