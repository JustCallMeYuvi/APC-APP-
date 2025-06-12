// lib/services/emp_details_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/model/get_emp_details.dart';

class EmpDetailsService {
  static Future<List<GetEmpDetails>> fetchEmpDetails(String empNo) async {
    final String urlString = ApiHelper.getEmpDetails(empNo);
    final Uri url = Uri.parse(urlString);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((data) => GetEmpDetails.fromJson(data))
            .toList();
      } else {
        // You can throw an exception or return an empty list
        throw Exception('Failed to load employee details');
      }
    } catch (e) {
      throw Exception('Error fetching employee data: $e');
    }
  }
}
