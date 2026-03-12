import 'dart:convert';
import 'dart:io';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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


Future<String> downloadPayslip({
  required String barcode,
  required String dob,
  required String bookNo,
}) async {

  final url = Uri.parse(
    "http://10.3.0.208:8089/api/Ess/PayslipDownload"
    "?company=APC"
    "&barcode=$barcode"
    "&dob=$dob"
    "&book_no=$bookNo",
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {

    final dir = await getTemporaryDirectory();

    final file = File("${dir.path}/payslip_$bookNo.pdf");

    await file.writeAsBytes(response.bodyBytes);

    return file.path;
  }

  throw Exception("Payslip download failed");
}
}
