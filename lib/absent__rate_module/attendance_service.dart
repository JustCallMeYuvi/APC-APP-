// import 'dart:convert';

// import 'package:animated_movies_app/absent__rate_module/attendance_report_model.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// class AttendanceService {
//   static Future<List<AttendanceReportModel>> getAttendanceReport({
//     required DateTime fromDate,
//     required DateTime toDate,
//     required String type,
//   }) async {
//     final response = await http.post(
//       Uri.parse(
//           "http://10.3.0.70:9042/api/HR/GetAttendanceReport"),
//       headers: {
//         "Content-Type": "application/json",
//       },
//       body: jsonEncode({
//         "fromDate":
//             DateFormat('yyyy-MM-dd').format(fromDate),
//         "toDate":
//             DateFormat('yyyy-MM-dd').format(toDate),
//         "type": type.toLowerCase(),
//       }),
//     );

//     if (response.statusCode == 200) {
//       final List data = jsonDecode(response.body);

//       return data
//           .map((e) => AttendanceReportModel.fromJson(e))
//           .toList();
//     }

//     throw Exception("Failed to load report");
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'attendance_report_model.dart';

class AttendanceService {
  static Future<List<AttendanceReportModel>> getAttendanceReport({
    required DateTime fromDate,
    required DateTime toDate,
    required String type,
  }) async {
    final requestBody = {
      "fromDate": DateFormat('yyyy-MM-dd').format(fromDate),
      "toDate": DateFormat('yyyy-MM-dd').format(toDate),
      "type": type,
    };

    print("REQUEST => ${jsonEncode(requestBody)}");


    final response = await http.post(
      Uri.parse("http://10.3.0.70:9042/api/HR/GetAttendanceReport"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    );

    print("STATUS CODE => ${response.statusCode}");
    print("RESPONSE => ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((e) => AttendanceReportModel.fromJson(e))
          .toList();
    }

    throw Exception(
      "Failed to load report\n"
      "Status: ${response.statusCode}\n"
      "Response: ${response.body}",
    );
  }
}