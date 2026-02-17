import 'package:animated_movies_app/Salary_Module/salary_repository.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'salary_bloc.dart';
import 'salary_event.dart';
import 'salary_state.dart';
import 'salary_model.dart';

class SalaryScreen extends StatefulWidget {
  final LoginModelApi userData;

  const SalaryScreen({super.key, required this.userData});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  late SalaryBloc _salaryBloc;

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  String formatDate(DateTime date) =>
      "${date.year}${date.month.toString().padLeft(2, '0')}";

  // bool get isAdmin => widget.userData.useRRole == 1;

  bool get isAdmin => widget.userData.useRRole == "1";

  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _salaryBloc = SalaryBloc(SalaryRepository());

    _fetchSalary();
  }

  // void _fetchSalary() {
  void _fetchSalary({String? barcode}) {
    _salaryBloc.add(
      FetchSalary(
        // barcode: widget.userData.empNo.toString(),
        barcode: barcode ?? widget.userData.empNo.toString(),
        fromDate: formatDate(fromDate),
        toDate: formatDate(toDate),
      ),
    );
  }

  @override
  void dispose() {
    _salaryBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _salaryBloc,
      child: Scaffold(
        body: Column(
          children: [
            /// 🔥 SHOW SEARCH BAR ONLY IF ROLE == 1
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    // hintText: "Search by Month (YYYYMM)",
                    hintText: "Enter Barcode",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// 🔥 SEARCH BUTTON
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (_searchController.text.isNotEmpty) {
                              _fetchSalary(
                                barcode: _searchController.text.trim(),
                              );
                            }
                          },
                        ),

                        /// 🔥 CLEAR BUTTON
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _fetchSalary(); // reload own salary
                          },
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // onChanged: (value) {
                  //   setState(() {});
                  // },

                  /// 🔥 SEARCH ON ENTER PRESS
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _fetchSalary(barcode: value.trim());
                    }
                  },
                ),
              ),

            /// 🔹 FROM & TO DATE SELECTOR
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _dateButton(
                      label: "From",
                      date: fromDate,
                      onTap: () => _pickDate(isFrom: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dateButton(
                      label: "To",
                      date: toDate,
                      onTap: () => _pickDate(isFrom: false),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔹 SALARY CONTENT
            Expanded(
              child: BlocBuilder<SalaryBloc, SalaryState>(
                builder: (context, state) {
                  if (state is SalaryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  /// ✅ NO DATA UI
                  if (state is SalaryNoData) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "No Salary Records Found",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SalaryLoaded) {
                    List<SalaryModel> salaries = state.salaries;

                    /// 🔥 FILTER ONLY FOR ADMIN
                    if (isAdmin && _searchController.text.isNotEmpty) {
                      salaries = salaries
                          .where(
                              (s) => s.bookNo.contains(_searchController.text))
                          .toList();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: state.salaries.length,
                      itemBuilder: (context, index) {
                        final salary = state.salaries[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: salaryCard(salary), // ✅ single item passed
                        );
                      },
                    );
                  }

                  if (state is SalaryError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Date Picker
  /// 🔥 DATE PICKER WITH 6 MONTH RESTRICTION
  Future<void> _pickDate({required bool isFrom}) async {
    DateTime firstAllowedDate;

    if (isAdmin) {
      firstAllowedDate = DateTime(2020);
    } else {
      firstAllowedDate = DateTime.now().subtract(const Duration(days: 180));
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromDate : toDate,
      firstDate: firstAllowedDate,
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });

      _fetchSalary();
    }
  }

  /// 🔹 Date Button UI
  Widget _dateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("${date.month}/${date.year}"),
          ],
        ),
      ),
    );
  }

  /// 🔹 Salary Card
  Widget salaryCard(SalaryModel salary) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Header Row (Month + Name)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  salary.bookNo, // 202602
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  salary.empName,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const Divider(height: 25),

            /// 🔹 Earnings
            const Text(
              "Earnings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 8),

            salaryRow("Basic Salary", salary.basicSalary),
            salaryRow("DA Salary", salary.daSalary),
            salaryRow("Diligence Bonus", salary.diligenceBonus),
            salaryRow("Performance Bonus", salary.performanceBonus),

            const Divider(height: 25),

            salaryRow("Gross Salary", salary.grossSalary, isBold: true),
            salaryRow("Earned Gross", salary.earnedGrossSalary),

            const Divider(height: 25),

            /// 🔹 Deductions
            const Text(
              "Deductions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 8),

            salaryRow("Total Deduction", salary.deductionTotal),

            const Divider(height: 25),

            /// 🔹 Net Salary Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Net Salary",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "₹ ${salary.actualSalary.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget salaryRow(String title, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("₹ ${amount.toStringAsFixed(2)}",
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
