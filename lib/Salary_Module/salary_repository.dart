import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:http/http.dart' as http;
import 'salary_model.dart';

class SalaryRepository {

  Future<List<SalaryModel>?> fetchSalary({
    required String barcode,
    required String fromDate,
    required String toDate,
  }) async {

    final url = Uri.parse(
      '${ApiHelper.baseUrl}getsalaryslip'
      '?barcode=$barcode&fromdate=$fromDate&todate=$toDate',
    );

    final response = await http.get(url);

    /// ✅ SUCCESS
    if (response.statusCode == 200) {

      final List data = json.decode(response.body);

      if (data.isEmpty) return null;

      /// 🔥 Convert JSON List → List<SalaryModel>
      final salaries = data
          .map((e) => SalaryModel.fromJson(e))
          .toList();

      /// 🔥 Optional: Sort latest month first
      salaries.sort(
        (a, b) => b.bookNo.compareTo(a.bookNo),
      );

      return salaries;
    }

    /// ✅ NO DATA
    if (response.statusCode == 404) {
      return null;
    }

    /// ❌ OTHER ERROR
    throw Exception(
      'Server Error: ${response.statusCode}',
    );
  }
}
