import 'dart:convert';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/gms_screens/car_conveynance_module/car_booking_screen.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:http/http.dart' as http;
// Make sure you have dropdown_search or your custom DropDownSearchField available

class CarAvailabilityScreen extends StatefulWidget {
  final LoginModelApi userData;
  const CarAvailabilityScreen({Key? key, required this.userData})
      : super(key: key);

  @override
  _CarAvailabilityScreenState createState() => _CarAvailabilityScreenState();
}

class _CarAvailabilityScreenState extends State<CarAvailabilityScreen> {
  DateTime? fromDate;
  DateTime? toDate;

  String? _selectedCarType;
  // String? _selectedStatus;
  bool _isLoading = false;

  List<CarAvailability> _cars = [];

  final List<String> carTypes = ["NORMAL", "VIP", "EMERGENCY"];
  final List<String> statusTypes = ["PENDING", "APPROVED", "REJECTED"];

  final TextEditingController _carTypeController = TextEditingController();
  // final TextEditingController _statusController = TextEditingController();

  // Future<void> _pickDate(bool isFrom) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(2030),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       if (isFrom) {
  //         fromDate = picked;
  //       } else {
  //         toDate = picked;
  //       }
  //     });
  //   }
  // }

  Future<void> _pickDate(bool isFrom) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isFrom) {
            fromDate = finalDateTime;
          } else {
            toDate = finalDateTime;
          }
        });
      }
    }
  }

  Future<void> fetchCarAvailability() async {
    if (fromDate == null || toDate == null || _selectedCarType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select from date, to date, and car type')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String from =
          "${fromDate!.year}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}";
      String to =
          "${toDate!.year}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}";
      // String url =
      //     "http://10.3.0.70:9042/api/Car_Conveyance_/Cars_Availability?selectedBookingType=$_selectedCarType&travelFrom=$from&destinationTo=$to";
      final url = Uri.parse(
          '${ApiHelper.carConveynanceUrl}Cars_Availability?selectedBookingType=$_selectedCarType&travelFrom=$from&destinationTo=$to');

      final response = await http.get(url);
      print('url car availability ${url}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        setState(() {
          _cars = data.map((item) => CarAvailability.fromJson(item)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          // Text(
                          //   fromDate == null
                          //       ? "From Date"
                          //       : "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}",
                          //   style: textStyle,
                          // ),
                          Text(
                        fromDate == null
                            ? "From Date"
                            : "${fromDate!.day.toString().padLeft(2, '0')}/${fromDate!.month.toString().padLeft(2, '0')}/${fromDate!.year} ${fromDate!.hour.toString().padLeft(2, '0')}:${fromDate!.minute.toString().padLeft(2, '0')}",
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          //  Text(
                          //   toDate == null
                          //       ? "To Date"
                          //       : "${toDate!.day}/${toDate!.month}/${toDate!.year}",
                          //   style: textStyle,
                          // ),
                          Text(
                        toDate == null
                            ? "To Date"
                            : "${toDate!.day.toString().padLeft(2, '0')}/${toDate!.month.toString().padLeft(2, '0')}/${toDate!.year} ${toDate!.hour.toString().padLeft(2, '0')}:${toDate!.minute.toString().padLeft(2, '0')}",
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
            // DropDownSearchField(
            //   textFieldConfiguration: TextFieldConfiguration(
            //     controller: _statusController,
            //     decoration: const InputDecoration(
            //       labelText: "Approval Status",
            //       border: OutlineInputBorder(),
            //       suffixIcon: Icon(Icons.arrow_drop_down),
            //     ),
            //   ),
            //   suggestionsCallback: (pattern) async {
            //     return statusTypes
            //         .where((status) =>
            //             status.toLowerCase().contains(pattern.toLowerCase()))
            //         .toList();
            //   },
            //   itemBuilder: (context, suggestion) {
            //     return ListTile(title: Text(suggestion));
            //   },
            //   onSuggestionSelected: (suggestion) {
            //     setState(() {
            //       _selectedStatus = suggestion;
            //       _statusController.text = suggestion;
            //     });
            //   },
            //   displayAllSuggestionWhenTap: true,
            //   isMultiSelectDropdown: false,
            // ),
            // const SizedBox(height: 30),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _cars.isEmpty
                      ? const Center(child: Text('No cars available'))
                      : ListView.builder(
                          itemCount: _cars.length,
                          itemBuilder: (context, index) {
                            final car = _cars[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: ListTile(
                                leading:
                                    const Icon(Icons.directions_car, size: 40),
                                title: Text(car.carName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Car No: ${car.carNo}"),
                                    Text("Capacity: ${car.capacity}"),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
            ),

            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  fetchCarAvailability();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Search", style: TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 20),
            if (_cars.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const CarBookingScreen(
                            // carName: car.carName,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.lightGreen, // Set the button color here
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Book Car",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

            if (_isLoading)
              SizedBox(
                height: 150,
                child: Image.asset(
                  'assets/car.gif',
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CarAvailability {
  final String carNo;
  final String carName;
  final String capacity;

  CarAvailability({
    required this.carNo,
    required this.carName,
    required this.capacity,
  });

  factory CarAvailability.fromJson(Map<String, dynamic> json) {
    return CarAvailability(
      carNo: json['carNo'] ?? '',
      carName: json['carName'] ?? '',
      capacity: json['capacity'] ?? '',
    );
  }
}
