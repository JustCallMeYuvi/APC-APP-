import 'dart:convert';

import 'package:animated_movies_app/disciplinary_folder/disciplinary_filter_widget.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'disciplinary_records_widget.dart';

class DisciplinaryRecordsScreen extends StatefulWidget {
  final LoginModelApi userData;
  const DisciplinaryRecordsScreen({super.key, required this.userData});

  @override
  State<DisciplinaryRecordsScreen> createState() =>
      _DisciplinaryRecordsScreenState();
}

class _DisciplinaryRecordsScreenState extends State<DisciplinaryRecordsScreen> {
  TextEditingController empController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  List records = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    empController.text = widget.userData.empNo;
    applyFilter(); // default load
  }

  // ================= API =================
  Future<void> applyFilter() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.3.0.70:9042/api/HR/Get_Disciplinary_Data"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "empNo": empController.text,
          "fromDate":
              fromDateController.text.isEmpty ? null : fromDateController.text,
          "toDate":
              toDateController.text.isEmpty ? null : toDateController.text,
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        records = data['data'] ?? [];
      });
    } catch (e) {
      print(e);
    }

    setState(() => isLoading = false);
  }

  // ================= STATUS =================
  String getStatus(String status) {
    switch (status) {
      case "1":
        return "Approved";
      case "2":
        return "Pending";
      case "3":
        return "Rejected";
      default:
        return "Unknown";
    }
  }

  // ================= DATE PICKER =================
  Future<void> pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(80),
      //   child: SafeArea(
      //     child: Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Row(
      //             children: [
      //               const Icon(Icons.menu, color: Color(0xFF005EA4)),
      //               const SizedBox(width: 15),
      //               Text(
      //                 'Disciplinary Records',
      //                 style: GoogleFonts.manrope(
      //                   fontWeight: FontWeight.bold,
      //                   fontSize: 18,
      //                   color: const Color(0xFF191C1D),
      //                 ),
      //               ),
      //             ],
      //           ),
      //           Container(
      //             width: 40,
      //             height: 40,
      //             decoration: BoxDecoration(
      //               shape: BoxShape.circle,
      //               border: Border.all(color: const Color(0xFF0077CE), width: 2),
      //               image: const DecorationImage(
      //                 image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDeUSWvuNIoORYlh7o2Ygw0tHNo5qx1Z-VMFgxXz9wWWwKfug80XXOlKg-sINEYwMfiPEIoiqVSml8ZtXynZz3MDocfXOpKsZ5p7JmRf0KQrptLqS_3Q9c_Ryj0Xxwgy6SY3FG971NbXdMgIi7REJXyPictEcxRhdCS259K7sFRyqO5DF9YvKqXW8zjTyz836rpPtPwZpoxUWigQiLdWN6ZUjpEGDXgz7L9JWtQD55LoahCLvbFrRXbIa5k8fHlru0QX-J0QHXBv82_'),
      //                 fit: BoxFit.cover,
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              FilterSection(
                empController: empController,
                fromDateController: fromDateController,
                toDateController: toDateController,
                onApply: applyFilter,
                onPickDate: pickDate,
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (records.isEmpty)
                const Text("No Records Found")
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final item = records[index];

                    return Column(
                      children: [
                        RecordCard(
                          name: item['empName'] ?? '',
                          empId: item['empNo'] ?? '',
                          awpnNo: item['awpnNo'] ?? '',
                          status: getStatus(item['status']),
                          department: item['deptName'] ?? '',
                          description: item['reason'] ?? '',
                          issueDate: item['disciplinaryDate'] ?? '',
                          lastUpdated: item['lastDate'] ?? '',
                          hasRewardImpact: item['rewardQuantity'] != "0" ||
                              item['rewardAmount'] != "0",
                          deptIcon: Icons.apartment,
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 100),
            ],
          )),
    );
  }
}
