import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CarsInOutScreen extends StatefulWidget {
  final LoginModelApi userData;
  const CarsInOutScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _CarsInOutScreenState createState() => _CarsInOutScreenState();
}

class _CarsInOutScreenState extends State<CarsInOutScreen> {
  final TextEditingController _statusController = TextEditingController();
  String? _selectedStatus;
  List<dynamic> _cars = [];
  bool _isLoading = false;

  final List<String> statusOptions = ["In", "Out"];

  @override
  void initState() {
    super.initState();
    // ✅ Set default as OUT
    _selectedStatus = "Out";
    _statusController.text = "Out";

    // ✅ Fetch OUT cars initially
    _fetchCars("Out");
  }

  Future<void> _fetchCars(String status) async {
    setState(() => _isLoading = true);
    final url = Uri.parse('${ApiHelper.carConveynanceUrl}Ps_Cars?status=$status');

    // final url =
    //     "http://10.3.0.70:9042/api/Car_Conveyance_/Ps_Cars?status=$status";
    debugPrint("Fetching cars from: $url");

    try {
      final response = await http.get(url);

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is Map && decoded.containsKey("data")) {
          final data = decoded["data"];

          if (data == null || (data is List && data.isEmpty)) {
            // ✅ No records case
            setState(() => _cars = []);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No cars found")),
            );
          } else if (data is List) {
            // ✅ Valid list of cars
            setState(() => _cars = data);
          } else {
            // ✅ Unexpected format
            setState(() => _cars = []);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Unexpected API format")),
            );
          }
        } else {
          setState(() => _cars = []);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid API response")),
          );
        }
      } else {
        setState(() => _cars = []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Error ${response.statusCode}: ${response.reasonPhrase}"),
          ),
        );
      }
    } catch (e) {
      setState(() => _cars = []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Something went wrong. Please try again.")),
      );
      debugPrint("Exception: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            /// DropdownSearchField
            DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _statusController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Select Status",
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return statusOptions
                    .where((option) =>
                        option.toLowerCase().contains(pattern.toLowerCase()))
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
                _fetchCars(suggestion);
              },
              displayAllSuggestionWhenTap: true,
              isMultiSelectDropdown: false,
            ),

            const SizedBox(height: 20),

            /// Data Section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _cars.isEmpty
                      ? const Center(child: Text("No cars found"))
                      : ListView.builder(
                          itemCount: _cars.length,
                          itemBuilder: (context, index) {
                            final car = _cars[index];

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 6),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue.shade50, Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(2, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Car No + Booking Type
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Car No: ${car['cardetails'] ?? '-'}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade100,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            car['selectedBookingType'] ?? "-",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    /// Travellers
                                    Row(
                                      children: [
                                        const Icon(Icons.group,
                                            size: 18, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "Travellers: ${car['travellers'] ?? '-'}",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    /// Travel From - To
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 18, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "From: ${car['travelfrom'] ?? '-'}\nTo: ${car['destinationto'] ?? '-'}",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    /// Destination
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 18, color: Colors.redAccent),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "Destination: ${car['designation'] ?? '-'}",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const Divider(height: 20, thickness: 1),

                                    /// Car In & Out
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Car In Time: ${car['carIntime']?.isEmpty ?? true ? '-' : car['carIntime']}",
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.green),
                                            ),
                                            Text(
                                              "Car Out Time: ${car['carOuttime'] ?? '-'}",
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.red),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          car['currentState'] ?? '-',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: (car['currentState'] ==
                                                    "Car Outed")
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    /// Action Button
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              _selectedStatus == "In"
                                                  ? Colors.green
                                                  : Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                        ),
                                        onPressed: () async {
                                          final action = _selectedStatus == "In"
                                              ? "IN"
                                              : "OUT";

                                          final bool? confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text("Confirm $action"),
                                              content: Text(
                                                  "Are you sure you want to mark this car as $action?"),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: const Text("Cancel"),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        action == "IN"
                                                            ? Colors.green
                                                            : Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: const Text("OK"),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            // ✅ Proceed with API call
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Car marked as $action")),
                                            );

                                            // TODO: Call API for IN/OUT here
                                          }
                                        },
                                        child: Text(
                                          _selectedStatus == "In"
                                              ? "IN"
                                              : "OUT",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
