// import 'package:animated_movies_app/Salary_Module/salary_repository.dart';
// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'salary_bloc.dart';
// import 'salary_event.dart';
// import 'salary_state.dart';
// import 'salary_model.dart';

// class SalaryScreen extends StatefulWidget {
//   final LoginModelApi userData;

//   const SalaryScreen({super.key, required this.userData});

//   @override
//   State<SalaryScreen> createState() => _SalaryScreenState();
// }

// class _SalaryScreenState extends State<SalaryScreen> {
//   late SalaryBloc _salaryBloc;

//   DateTime fromDate = DateTime.now();
//   DateTime toDate = DateTime.now();

//   String formatDate(DateTime date) =>
//       "${date.year}${date.month.toString().padLeft(2, '0')}";

//   // bool get isAdmin => widget.userData.useRRole == 1;

//   bool get isAdmin => widget.userData.useRRole == "1";

//   final TextEditingController _searchController = TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//     _salaryBloc = SalaryBloc(SalaryRepository());

//     _fetchSalary();
//   }

//   // void _fetchSalary() {
//   void _fetchSalary({String? barcode}) {
//     _salaryBloc.add(
//       FetchSalary(
//         // barcode: widget.userData.empNo.toString(),
//         barcode: barcode ?? widget.userData.empNo.toString(),
//         fromDate: formatDate(fromDate),
//         toDate: formatDate(toDate),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _salaryBloc.close();
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: _salaryBloc,
//       child: Scaffold(
//         body: Column(
//           children: [
//             /// 🔥 SHOW SEARCH BAR ONLY IF ROLE == 1
//             if (isAdmin)
//               Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     // hintText: "Search by Month (YYYYMM)",
//                     hintText: "Enter Barcode",
//                     prefixIcon: const Icon(Icons.search),
//                     suffixIcon: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         /// 🔥 SEARCH BUTTON
//                         IconButton(
//                           icon: const Icon(Icons.send),
//                           onPressed: () {
//                             if (_searchController.text.isNotEmpty) {
//                               _fetchSalary(
//                                 barcode: _searchController.text.trim(),
//                               );
//                             }
//                           },
//                         ),

//                         /// 🔥 CLEAR BUTTON
//                         IconButton(
//                           icon: const Icon(Icons.clear),
//                           onPressed: () {
//                             _searchController.clear();
//                             _fetchSalary(); // reload own salary
//                           },
//                         ),
//                       ],
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   // onChanged: (value) {
//                   //   setState(() {});
//                   // },

//                   /// 🔥 SEARCH ON ENTER PRESS
//                   onSubmitted: (value) {
//                     if (value.isNotEmpty) {
//                       _fetchSalary(barcode: value.trim());
//                     }
//                   },
//                 ),
//               ),

//             /// 🔹 FROM & TO DATE SELECTOR
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _dateButton(
//                       label: "From",
//                       date: fromDate,
//                       onTap: () => _pickDate(isFrom: true),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: _dateButton(
//                       label: "To",
//                       date: toDate,
//                       onTap: () => _pickDate(isFrom: false),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             /// 🔹 SALARY CONTENT
//             Expanded(
//               child: BlocBuilder<SalaryBloc, SalaryState>(
//                 builder: (context, state) {
//                   if (state is SalaryLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   /// ✅ NO DATA UI
//                   if (state is SalaryNoData) {
//                     return const Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.receipt_long,
//                             size: 60,
//                             color: Colors.grey,
//                           ),
//                           SizedBox(height: 10),
//                           Text(
//                             "No Salary Records Found",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   if (state is SalaryLoaded) {
//                     List<SalaryModel> salaries = state.salaries;

//                     /// 🔥 FILTER ONLY FOR ADMIN
//                     if (isAdmin && _searchController.text.isNotEmpty) {
//                       salaries = salaries
//                           .where(
//                               (s) => s.bookNo.contains(_searchController.text))
//                           .toList();
//                     }
//                     return ListView.builder(
//                       padding: const EdgeInsets.all(12),
//                       itemCount: state.salaries.length,
//                       itemBuilder: (context, index) {
//                         final salary = state.salaries[index];

//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 12),
//                           child: salaryCard(salary), // ✅ single item passed
//                         );
//                       },
//                     );
//                   }

//                   if (state is SalaryError) {
//                     return Center(
//                       child: Text(
//                         state.message,
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     );
//                   }

//                   return const SizedBox();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 🔹 Date Picker
//   /// 🔥 DATE PICKER WITH 6 MONTH RESTRICTION
//   Future<void> _pickDate({required bool isFrom}) async {
//     DateTime firstAllowedDate;

//     if (isAdmin) {
//       firstAllowedDate = DateTime(2020);
//     } else {
//       firstAllowedDate = DateTime.now().subtract(const Duration(days: 180));
//     }

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: isFrom ? fromDate : toDate,
//       firstDate: firstAllowedDate,
//       lastDate: DateTime.now(),
//     );

//     if (picked != null) {
//       setState(() {
//         if (isFrom) {
//           fromDate = picked;
//         } else {
//           toDate = picked;
//         }
//       });

//       _fetchSalary();
//     }
//   }

//   /// 🔹 Date Button UI
//   Widget _dateButton({
//     required String label,
//     required DateTime date,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.blue.shade50,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 5),
//             Text("${date.month}/${date.year}"),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 🔹 Salary Card
//   Widget salaryCard(SalaryModel salary) {
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// 🔹 Header Row (Month + Name)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   salary.bookNo, // 202602
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   salary.empName,
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),

//             const Divider(height: 25),

//             /// 🔹 Earnings
//             const Text(
//               "Earnings",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//               ),
//             ),

//             const SizedBox(height: 8),

//             salaryRow("Basic Salary", salary.basicSalary),
//             salaryRow("DA Salary", salary.daSalary),
//             salaryRow("Diligence Bonus", salary.diligenceBonus),
//             salaryRow("Performance Bonus", salary.performanceBonus),

//             const Divider(height: 25),

//             salaryRow("Gross Salary", salary.grossSalary, isBold: true),
//             salaryRow("Earned Gross", salary.earnedGrossSalary),

//             const Divider(height: 25),

//             /// 🔹 Deductions
//             const Text(
//               "Deductions",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red,
//               ),
//             ),

//             const SizedBox(height: 8),

//             salaryRow("Total Deduction", salary.deductionTotal),

//             const Divider(height: 25),

//             /// 🔹 Net Salary Container
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Net Salary",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   Text(
//                     "₹ ${salary.actualSalary.toStringAsFixed(2)}",
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.blue),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget salaryRow(String title, double amount, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title,
//               style: TextStyle(
//                   fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//           Text("₹ ${amount.toStringAsFixed(2)}",
//               style: TextStyle(
//                   fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//         ],
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SalaryScreen extends StatefulWidget {
  final LoginModelApi userData;

  const SalaryScreen({super.key, required this.userData});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final PdfViewerController _pdfViewerController = PdfViewerController();

  bool loading = false;
  File? pdfFile;

  bool isDownloading = false;

  Future<void> viewPayslip() async {
    final barcode = widget.userData.empNo.toString();
    final dob = _dobController.text.trim();
    final month = _monthController.text.trim();

    if (dob.isEmpty || month.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter DOB and Month")),
      );
      return;
    }

    setState(() {
      loading = true;
      pdfFile = null; // remove old payslip
    });

    final url = Uri.parse(
      "${ApiHelper.payslipUrl}PayslipDownload_"
      "?company=APC"
      "&barcode=$barcode"
      "&dob=$dob"
      "&book_no=$month",
    );

    try {
      final response = await http.get(url);

      /// ❗ Server error
      if (response.statusCode != 200) {
        _showAlert("Server Error", "Please try again later.");
        setState(() => loading = false);
        return;
      }

      /// ❗ Invalid DOB or No Payslip
      if (!response.headers['content-type']!.contains("pdf")) {
        String message = "Payslip not available for selected month.";

        /// If API returns DOB error text
        String body = String.fromCharCodes(response.bodyBytes);

        if (body.toLowerCase().contains("dob") ||
            body.toLowerCase().contains("invalid")) {
          message = "DOB is not correct. Please enter valid DOB.";
        }

        _showAlert("Payslip Error", message);

        setState(() {
          loading = false;
          pdfFile = null;
        });

        return;
      }

      /// Save PDF
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/payslip_$month.pdf");

      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        pdfFile = file;
      });
    } catch (e) {
      _showAlert("Error", "Something went wrong.\n$e");
    }

    setState(() {
      loading = false;
    });
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> downloadPayslip() async {
    if (pdfFile == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Download Failed"),
          content: const Text("No payslip available to download."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
      return;
    }

    setState(() {
      isDownloading = true;
    });

    /// loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      /// download folder path
      Directory? dir = Directory('/storage/emulated/0/Download');

      final fileName = pdfFile!.uri.pathSegments.last;

      final downloadFile = File("${dir.path}/$fileName");

      await pdfFile!.copy(downloadFile.path);

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Download Successful"),
          content: Text(
            "Payslip saved in Downloads folder\n\n${downloadFile.path}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Download Failed"),
          content: Text("Error downloading payslip:\n$e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }

    setState(() {
      isDownloading = false;
    });
  }

  @override
  void dispose() {
    _dobController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// DOB

            TextField(
              controller: _dobController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Select DOB",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);

                  setState(() {
                    _dobController.text = formattedDate;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            /// MONTH
            // TextField(
            //   controller: _monthController,
            //   readOnly: true,
            //   decoration: const InputDecoration(
            //     labelText: "Select Month",
            //     border: OutlineInputBorder(),
            //     suffixIcon: Icon(Icons.calendar_today),
            //   ),
            //   onTap: () async {
            //     DateTime today = DateTime.now();

            //     DateTime lastDate;
            //     DateTime firstDate;

            //     /// If today < 10 → allow previous 3 months
            //     if (today.day < 10) {
            //       lastDate = DateTime(today.year, today.month - 1);
            //       firstDate = DateTime(lastDate.year, lastDate.month - 2);
            //     }

            //     /// If today >= 10 → allow current + previous 2 months
            //     else {
            //       lastDate = DateTime(today.year, today.month);
            //       firstDate = DateTime(lastDate.year, lastDate.month - 2);
            //     }

            //     DateTime? pickedMonth = await showDatePicker(
            //       context: context,
            //       initialDate: lastDate,
            //       firstDate: firstDate,
            //       lastDate: lastDate,
            //       helpText: "Select Payslip Month",
            //     );

            //     if (pickedMonth != null) {
            //       String formattedMonth =
            //           "${pickedMonth.year}${pickedMonth.month.toString().padLeft(2, '0')}";

            //       setState(() {
            //         _monthController.text = formattedMonth;
            //       });
            //     }
            //   },
            // ),

            TextField(
              controller: _monthController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Select Month",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime today = DateTime.now();

                // ✅ Always previous 3 months (no 10th logic)
                DateTime lastDate = DateTime(today.year, today.month - 1);
                DateTime firstDate =
                    DateTime(lastDate.year, lastDate.month - 2);

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Select Payslip Month"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (index) {
                          DateTime month =
                              DateTime(lastDate.year, lastDate.month - index);

                          return ListTile(
                            leading: const Icon(Icons.calendar_month),
                            title: Text(
                              DateFormat('MMMM yyyy').format(month),
                            ),
                            onTap: () {
                              String formatted =
                                  "${month.year}${month.month.toString().padLeft(2, '0')}";

                              setState(() {
                                _monthController.text = formatted;
                              });

                              Navigator.pop(context);
                            },
                          );
                        }),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("View Payslip"),
                    onPressed: viewPayslip,
                  ),

            const SizedBox(height: 20),

            /// ZOOM CONTROLS
            if (pdfFile != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_out),
                    onPressed: () {
                      _pdfViewerController.zoomLevel =
                          _pdfViewerController.zoomLevel - 0.25;
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in),
                    onPressed: () {
                      _pdfViewerController.zoomLevel =
                          _pdfViewerController.zoomLevel + 0.25;
                    },
                  ),
                ],
              ),

            /// SHOW PDF HERE
            if (pdfFile != null)
              Expanded(
                  child:
                      // SfPdfViewer.file(pdfFile!),
                      SfPdfViewer.file(
                pdfFile!,
                controller: _pdfViewerController,
              )),

            const SizedBox(height: 10),

            /// DOWNLOAD BUTTON
            if (pdfFile != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text("Download Payslip"),
                  onPressed: downloadPayslip,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
