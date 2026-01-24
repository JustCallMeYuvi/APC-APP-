import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CarBookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const CarBookingDetailsScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<CarBookingDetailsScreen> createState() =>
      _CarBookingDetailsScreenState();
}

class _CarBookingDetailsScreenState extends State<CarBookingDetailsScreen> {
  bool _isLoading = true;

  Map<String, dynamic>? bookingDetails;
  // List<dynamic> availableCars = [];
  List<Map<String, dynamic>> availableCars = [];
  String? selectedCarId;

  String _carDisplayText(Map<String, dynamic> car) {
    return "${car["carNo"]} • ${car["carName"]} • ${car["capacity"]} seats";
  }

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  // 🔹 API CALL
  Future<void> _fetchBookingDetails() async {
    try {
      final url =
          '${ApiHelper.carConveynanceUrl}approve-details/${widget.bookingId}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          bookingDetails = decoded["bookingDetails"];
          // availableCars = decoded["availableCars"] ?? [];
          availableCars = List<Map<String, dynamic>>.from(
            decoded["availableCars"] ?? [],
          );
          _isLoading = false;
        });
      } else {
        _showError("Failed to load booking details");
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // 🔹 NULL / EMPTY SAFE CHECK
  bool _hasValue(dynamic value) {
    return value != null &&
        value.toString().trim().isNotEmpty &&
        value.toString().toLowerCase() != "null";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text("Car Booking Details"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingDetails == null
              ? const Center(child: Text("No details found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row("Booking ID", bookingDetails!["carBookingId"]),
                          _row("Name", bookingDetails!["name"]),
                          _row("Department", bookingDetails!["department"]),
                          _row("Position", bookingDetails!["position"]),
                          _row("Booking Type",
                              bookingDetails!["selectedBookingType"]),
                          _row("Reason", bookingDetails!["reason"]),
                          _row("Travel From", bookingDetails!["travelFrom"]),
                          _row("Travel To", bookingDetails!["destinationTo"]),
                          _row("Reach Time", bookingDetails!["reachTime"]),
                          _row(
                              "Trip Duration", bookingDetails!["tripDuration"]),
                          _row("Distance", bookingDetails!["distance"]),
                          _row("Travellers Count",
                              bookingDetails!["travellersCount"]),
                          _row("Incharge Status",
                              bookingDetails!["inchargeStatus"]),
                          _row("GMO Status", bookingDetails!["gmoStatus"]),
                          _row("Security Status", bookingDetails!["secStatus"]),
                          _row("SPV Status", bookingDetails!["secSpvStatus"]),
                          _row("Final Status", bookingDetails!["finalStatus"]),
                          _row("Car Name", bookingDetails!["carName"]),
                          _row("Car No", bookingDetails!["carNo"]),

                          // 🚗 CAR ASSIGN DROPDOWN
                          if (availableCars.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text(
                              "Car Assign",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // DropdownButtonFormField<String>(
                            //   decoration: InputDecoration(
                            //     hintText: "Select Car",
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(12),
                            //     ),
                            //     contentPadding: const EdgeInsets.symmetric(
                            //         horizontal: 12, vertical: 14),
                            //   ),
                            //   value: selectedCarId,
                            //   isExpanded: true, // ✅ IMPORTANT
                            //   items: availableCars
                            //       .map<DropdownMenuItem<String>>((car) {
                            //     return DropdownMenuItem<String>(
                            //       value: car["carId"],
                            //       child: Row(
                            //         children: [
                            //           const Icon(Icons.directions_car,
                            //               size: 18),
                            //           const SizedBox(width: 8),

                            //           // ✅ FIX: bounded width, NO Expanded
                            //           SizedBox(
                            //             width: 200,
                            //             child: Text(
                            //               "${car["carNo"]} • ${car["carName"]} • ${car["capacity"]} seats",
                            //               maxLines: 1,
                            //               overflow: TextOverflow.ellipsis,
                            //               style: const TextStyle(fontSize: 12),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     );
                            //   }).toList(),
                            //   onChanged: (value) {
                            //     setState(() {
                            //       selectedCarId = value;
                            //     });
                            //     debugPrint("Selected Car ID: $selectedCarId");
                            //   },
                            // ),

                            DropdownSearch<Map<String, dynamic>>(
                              selectedItem: availableCars
                                      .firstWhere(
                                        (car) => car["carId"] == selectedCarId,
                                        orElse: () => {},
                                      )
                                      .isEmpty
                                  ? null
                                  : availableCars.firstWhere(
                                      (car) => car["carId"] == selectedCarId,
                                    ),
                              items: availableCars,
                              itemAsString: (car) => _carDisplayText(car),
                              popupProps: const PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    hintText: "Search car...",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              dropdownDecoratorProps:
                                  const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "Car Assign",
                                  hintText: "Select Car",
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                              ),
                              onChanged: (car) {
                                setState(() {
                                  selectedCarId = car?["carId"];
                                });

                                debugPrint("Selected Car ID: $selectedCarId");
                              },
                            ),
                          ],

                          const SizedBox(height: 20),
                          const Divider(),
                          const Center(
                            child: Text(
                              "End of Details",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  // 🔹 ROW BUILDER (NULL SAFE)
  Widget _row(String title, dynamic value) {
    if (!_hasValue(value)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
