import 'dart:convert';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/gms_screens/car_conveynance_module/car_booking_details_screen.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:http/http.dart' as http;
// Make sure you have dropdown_search or your custom DropDownSearchField available

class CarApprovalsScreen extends StatefulWidget {
  final LoginModelApi userData;
  const CarApprovalsScreen({Key? key, required this.userData})
      : super(key: key);

  @override
  _CarApprovalsScreenState createState() => _CarApprovalsScreenState();
}

class _CarApprovalsScreenState extends State<CarApprovalsScreen> {
  DateTime? fromDate;
  DateTime? toDate;

  String? _selectedCarType;
  // String? _selectedStatus;
  bool _isLoading = false;

  // final List<String> carTypes = ["NORMAL", "VIP", "EMERGENCY"];
  // final List<String> statusTypes = ["PENDING"];

  String? _selectedLevel; // from carTypes
  String? _selectedStatus; // from statusTypes
  final List<String> carTypes = ["Approval", "Car Assign"];
  final List<String> statusTypes = ["PENDING", "APPROVED", "REJECTED"];

  Map<String, List<dynamic>> groupedBookings = {};

  final TextEditingController _carTypeController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  final List<String> bookingTypeOrder = [
    "NORMAL",
    "VIP",
    "EMERGENCY",
  ];

  Future<void> _pickDate(bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  bool _hasValue(dynamic value) {
    return value != null &&
        value.toString().trim().isNotEmpty &&
        value.toString().toLowerCase() != "null";
  }

  List<dynamic> _carBookings = []; // Store API results here

  // /// Fetch car booking records
  // Future<void> _fetchCarBookings() async {
  //   if (_selectedStatus == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please select Approval Status")),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //     _carBookings.clear();
  //   });

  //   try {
  //     final userId = widget.userData.empNo ?? "0"; // Use your empNo field
  //     // final url =
  //     //     "http://10.3.0.70:9042/api/Car_Conveyance_/CarBookingRecords?USERID=$userId&MANAGE=$_selectedStatus";
  //     final url =
  //         '${ApiHelper.carConveynanceUrl}CarBookingRecords?USERID=$userId&MANAGE=$_selectedStatus';
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       setState(() {
  //         _carBookings = data;
  //       });
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text("Failed to load data: ${response.statusCode}")),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error fetching data: $e")),
  //     );
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _fetchCarBookings() async {
    if (_selectedLevel == null || _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Level and Status")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _carBookings.clear();
      groupedBookings.clear(); // ✅ clear previous groups
    });

    try {
      final url = '${ApiHelper.carConveynanceUrl}'
          'CarApprovalRecords?level=$_selectedLevel&status=$_selectedStatus';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // ✅ GROUP BY selectedBookingType
        for (var item in data) {
          final String type = item["selectedBookingType"] ?? "UNKNOWN";

          if (!groupedBookings.containsKey(type)) {
            groupedBookings[type] = [];
          }

          groupedBookings[type]!.add(item);
        }

        setState(() {
          _carBookings = data; // optional (keep if needed elsewhere)
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load data: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Car Type Search Dropdown
            DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _carTypeController,
                decoration: const InputDecoration(
                  labelText: "Approval Type",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return carTypes
                    .where((type) =>
                        type.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(title: Text(suggestion));
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  // _selectedCarType = suggestion;
                  _selectedLevel = suggestion; // ✅ LEVEL
                  _carTypeController.text = suggestion;
                });
              },
              displayAllSuggestionWhenTap: true,
              isMultiSelectDropdown: false,
            ),
            const SizedBox(height: 20),

            // Status Search Dropdown
            DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _statusController,
                decoration: const InputDecoration(
                  labelText: "Approval Status",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return statusTypes
                    .where((status) =>
                        status.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(title: Text(suggestion));
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  _selectedStatus = suggestion;
                  _statusController.text = suggestion;
                });
              },
              displayAllSuggestionWhenTap: true,
              isMultiSelectDropdown: false,
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _fetchCarBookings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Submit", style: TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 20),

            if (_isLoading)
              SizedBox(
                height: 150,
                child: Image.asset(
                  'assets/car.gif',
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 20),

            if (!_isLoading && groupedBookings.isNotEmpty)
              Expanded(
                child: ListView(
                  children: bookingTypeOrder
                      .where((type) => groupedBookings.containsKey(type))
                      .map((bookingType) {
                    final bookings = groupedBookings[bookingType]!;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        initiallyExpanded:
                            bookingType == "NORMAL", // ✅ NORMAL open first
                        title: Text(
                          bookingType,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        children: bookings.map<Widget>((booking) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      // CarBookingDetailsScreen(booking: booking),
                                      CarBookingDetailsScreen(
                                    bookingId: booking["carBookingId"],
                                         level: _selectedLevel, // 👈 ADD THIS
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🔹 TOP ROW: Booking ID + Status
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Booking ID
                                      Text(
                                        "Booking #${booking["carBookingId"] ?? "-"}",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      // STATUS CHIP (only if status exists)
                                      if (_hasValue(booking["inchargeStatus"]))
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: booking["inchargeStatus"] ==
                                                    "APPROVED"
                                                ? Colors.green.shade100
                                                : booking["inchargeStatus"] ==
                                                        "REJECTED"
                                                    ? Colors.red.shade100
                                                    : Colors.orange.shade100,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            booking["inchargeStatus"],
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: booking[
                                                          "inchargeStatus"] ==
                                                      "APPROVED"
                                                  ? const Color.fromARGB(
                                                      255, 89, 131, 90)
                                                  : booking["inchargeStatus"] ==
                                                          "REJECTED"
                                                      ? Colors.red
                                                      : Colors.orange,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // 🔹 TRAVEL ROW
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 18, color: Colors.blueAccent),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "${booking["travelFrom"] ?? "-"}  →  ${booking["destinationTo"] ?? "-"}",
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // 🔹 BOTTOM ROW: EXTRA STATUS
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (booking["gmoStatus"] != null)
                                        _statusChip(
                                            "GMO", booking["gmoStatus"]),
                                      if (booking["secStatus"] != null)
                                        _statusChip(
                                            "SEC", booking["secStatus"]),
                                      if (booking["secSpvStatus"] != null)
                                        _statusChip(
                                            "SPV", booking["secSpvStatus"]),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),

            if (!_isLoading && _carBookings.isEmpty && _selectedStatus != null)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "No records found",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$label: $status",
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
