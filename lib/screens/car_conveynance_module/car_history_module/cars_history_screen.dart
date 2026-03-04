import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/car_conveynance_module/car_history_module/car_row_screen.dart';
import 'package:animated_movies_app/screens/car_conveynance_module/car_history_module/cars_state_sction_screen.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CarsHistoryScreen extends StatefulWidget {
  final LoginModelApi userData;
  const CarsHistoryScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<CarsHistoryScreen> createState() => _CarsHistoryScreenState();
}

class _CarsHistoryScreenState extends State<CarsHistoryScreen> {
  String selectedFilter = "Overall";

  DateTime? fromDate;
  DateTime? toDate;

  bool isLoading = false;

  List<dynamic> cars = [];

  int grandTotalTrips = 0;
  int grandTotalTravellers = 0;
  double grandTotalKms = 0;
  int vehicleCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCarPerformance();
  }

  final TextEditingController _filterController = TextEditingController();

  final List<String> filterTypes = [
    "Overall",
    "Date Wise",
  ];
  Future<void> _pickDate(bool isFrom) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });

      if (selectedFilter == "Date Wise" && fromDate != null && toDate != null) {
        fetchCarPerformance();
      }
    }
  }

  Future<void> fetchCarPerformance() async {
    try {
      setState(() => isLoading = true);

      Uri url;

      if (selectedFilter == "Overall") {
        url = Uri.parse(
          '${ApiHelper.carConveynanceUrl}GetCarPerformance?condition=overall',
        );
      } else {
        if (fromDate == null || toDate == null) {
          setState(() => isLoading = false);
          return;
        }

        String from =
            "${fromDate!.year}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}";

        String to =
            "${toDate!.year}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}";

        url = Uri.parse(
          '${ApiHelper.carConveynanceUrl}GetCarPerformance'
          '?condition=datewise&fromDate=$from&toDate=$to',
        );
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          cars = data["cars"] ?? [];
          grandTotalTrips = data["grandTotalTrips"] ?? 0;
          grandTotalTravellers = data["grandTotalTravellers"] ?? 0;
          grandTotalKms = (data["grandTotalKms"] ?? 0).toDouble();
          vehicleCount = data["vehicleCount"] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),
      body: Column(
        children: [
          /// 🔷 HEADER
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          //   decoration: const BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [Color(0xff2C3E50), Color(0xff4CA1AF)],
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //     ),
          //   ),
          //   child: const Column(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Text("APC Administrative",
          //           style: TextStyle(fontSize: 12, color: Colors.white70)),
          //       SizedBox(height: 4),
          //       Text("Car History",
          //           style: TextStyle(
          //               fontSize: 20,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.white)),
          //     ],
          //   ),
          // ),

          const SizedBox(height: 12),

          /// 🔽 FILTER DROPDOWN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _filterController,
                decoration: InputDecoration(
                  labelText: "Filter Type",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return filterTypes
                    .where((type) =>
                        type.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  selectedFilter = suggestion;
                  _filterController.text = suggestion;
                });

                if (selectedFilter == "Overall") {
                  fetchCarPerformance();
                }
              },
              displayAllSuggestionWhenTap: true,
              isMultiSelectDropdown: false,
            ),
          ),
          const SizedBox(height: 16),

          /// 📅 DATE PICKERS
          if (selectedFilter == "Date Wise")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(true),
                      child: _dateBox(fromDate, "From Date"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(false),
                      child: _dateBox(toDate, "To Date"),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          /// 📊 BODY
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      StatsSection(
                        totalTrips: grandTotalTrips.toString(),
                        totalKms: grandTotalKms.toStringAsFixed(0),
                        travellers: grandTotalTravellers.toString(),
                        activeCars: vehicleCount.toString(),
                      ),
                      const SizedBox(height: 28),
                      // const SectionHeader(title: "Top Performing Cars"),
                      const SizedBox(height: 14),
                      ...cars.map((car) {
                        return CarRow(
                          name: car["caR_NAME"] ?? "",
                          number: car["caR_NO"] ?? "",
                          trips: car["totalTrips"] ?? 0,
                          totalKms: (car["total_Kms_Driven"] ?? 0)
                              .toDouble(), // 👈 ADD THIS
                          color: Colors.primaries[
                              cars.indexOf(car) % Colors.primaries.length],
                        );
                      }).toList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _dateBox(DateTime? date, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        date == null ? hint : "${date.day}-${date.month}-${date.year}",
      ),
    );
  }
}
