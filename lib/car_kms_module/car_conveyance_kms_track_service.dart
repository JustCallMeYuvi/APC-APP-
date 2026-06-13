import 'dart:convert';
import 'package:http/http.dart' as http;

import 'car_booking_model.dart';

class CarConveyanceService {
  static const String _baseUrl = 'http://10.3.0.70:9042/api/Car_Conveyance_';

  /// Fetch KMS report for a date range.
  /// Endpoint: POST /GetKmsReport
  /// Body: { "fromdate": "YYYY-MM-DD", "todate": "YYYY-MM-DD" }
  static Future<List<CarBookingTrack>> getKmsReport({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final url = Uri.parse('$_baseUrl/GetKmsReport');

    final body = jsonEncode({
      'fromdate': _formatDate(fromDate),
      'todate': _formatDate(toDate),
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'accept': 'text/plain',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => CarBookingTrack.fromJson(e)).toList();
    } else {
      throw Exception(
          'Failed to load KMS report: ${response.statusCode} ${response.body}');
    }
  }

  /// Update actual KMs for a booking.
  /// Endpoint: POST /UpdateActualKms
  /// Body: { "caR_IN_TIME": "...", "actualKms": 10, "caR_DETAILS": 26 }
  static Future<void> updateActualKms({
    required DateTime carInTime,
    // required int actualKms,
     required double actualKms,
    required int carDetails,
  }) async {
    final url = Uri.parse('$_baseUrl/UpdateActualKms');

    final body = jsonEncode({
      'caR_IN_TIME': carInTime.toIso8601String(),
      'actualKms': actualKms,
      'caR_DETAILS': carDetails,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'accept': 'text/plain',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update KMs: ${response.statusCode} ${response.body}');
    }
  }

  static String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
