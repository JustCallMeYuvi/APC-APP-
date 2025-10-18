import 'dart:convert';

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
  String? _selectedStatus;
  bool _isLoading = false;

  final List<String> carTypes = ["NORMAL", "VIP", "EMERGENCY"];
  final List<String> statusTypes = ["PENDING"];

  final TextEditingController _carTypeController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

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

  List<dynamic> _carBookings = []; // Store API results here

  /// Fetch car booking records
  Future<void> _fetchCarBookings() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Approval Status")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _carBookings.clear();
    });

    try {
      final userId = widget.userData.empNo ?? "0"; // Use your empNo field
      final url =
          "http://10.3.0.70:9042/api/Car_Conveyance_/CarBookingRecords?USERID=$userId&MANAGE=$_selectedStatus";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _carBookings = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to load data: ${response.statusCode}")),
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
    const textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // From & To Date
            // Row(
            //   children: [
            //     Expanded(
            //       child: InkWell(
            //         onTap: () => _pickDate(true),
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(
            //               vertical: 14, horizontal: 12),
            //           decoration: BoxDecoration(
            //             border: Border.all(color: Colors.grey.shade400),
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //           child: Text(
            //             fromDate == null
            //                 ? "From Date"
            //                 : "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}",
            //             style: textStyle,
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: InkWell(
            //         onTap: () => _pickDate(false),
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(
            //               vertical: 14, horizontal: 12),
            //           decoration: BoxDecoration(
            //             border: Border.all(color: Colors.grey.shade400),
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //           child: Text(
            //             toDate == null
            //                 ? "To Date"
            //                 : "${toDate!.day}/${toDate!.month}/${toDate!.year}",
            //             style: textStyle,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),

            // Car Type Search Dropdown
            DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _carTypeController,
                decoration: const InputDecoration(
                  labelText: "Car Type",
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
                  _selectedCarType = suggestion;
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

            // Apply Button
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text(
            //             "From: $fromDate | To: $toDate | Car: $_selectedCarType | Status: $_selectedStatus",
            //           ),
            //         ),
            //       );
            //     },
            //     style: ElevatedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(vertical: 14),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //     child: const Text("Apply", style: TextStyle(fontSize: 18)),
            //   ),
            // ),

            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () async {
            //       setState(() {
            //         _isLoading = true;
            //       });

            //       await Future.delayed(const Duration(seconds: 3));

            //       setState(() {
            //         _isLoading = false;
            //       });

            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text(
            //             "From: $fromDate | To: $toDate | Car: $_selectedCarType | Status: $_selectedStatus",
            //           ),
            //         ),
            //       );
            //     },
            //     style: ElevatedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(vertical: 14),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //     child: const Text("Apply", style: TextStyle(fontSize: 18)),
            //   ),
            // ),

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
                child: const Text("Apply", style: TextStyle(fontSize: 18)),
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

            // // Car Animation
            // SizedBox(
            //   height: 150,
            //   child: Image.asset(
            //     'assets/car.gif',
            //     fit: BoxFit.contain,
            //   ),
            // ),

            if (!_isLoading && _carBookings.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _carBookings.length,
                  itemBuilder: (context, index) {
                    final booking = _carBookings[index];
                    final status =
                        booking["final_status"]?.toString().toUpperCase() ??
                            "-";

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CarBookingDetailsScreen(booking: booking),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.directions_car,
                                  color: Colors.blueAccent, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking["name"] ?? "Unknown",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      "Booking ID: ${booking["carbookingid"] ?? "-"}",
                                      style: const TextStyle(fontSize: 13)),
                                  Text(
                                      "Type: ${booking["selectedbookingtype"] ?? "-"}",
                                      style: const TextStyle(fontSize: 13)),
                                  Text(
                                      "Destination: ${booking["destination"] ?? "-"}",
                                      style: const TextStyle(fontSize: 13)),
                                  Text(
                                      "Travel: ${booking["travelfrom"] ?? "-"} → ${booking["destinationto"] ?? "-"}",
                                      style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
}
