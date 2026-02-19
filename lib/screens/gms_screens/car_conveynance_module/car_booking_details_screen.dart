import 'dart:convert';
import 'dart:io';
import 'package:animated_movies_app/screens/gms_screens/car_conveynance_module/car_tracking_details_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';

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

  String? selectedCarOutTime;

  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController mailCc1Controller = TextEditingController();
  final TextEditingController mailCc2Controller = TextEditingController();
  String _carDisplayText(Map<String, dynamic> car) {
    return "${car["carNo"]} • ${car["carName"]} • ${car["capacity"]} seats";
  }

  bool _isApproved(dynamic status) {
    if (status == null) return false;
    return status.toString().toLowerCase().contains("approved");
  }

  final TextEditingController remarkController = TextEditingController();

  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70, // compress
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path); // Only one image stored
      });
    }
  }

  void removeImage() {
    setState(() {
      selectedImage = null;
    });
  }

  void showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : bookingDetails == null
                  ? const Center(child: Text("No details found"))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Card(
                          //   elevation: 3,
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(12),
                          //   ),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(16),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         _row("Booking ID",
                          //             bookingDetails!["carBookingId"]),
                          //         _row("Name", bookingDetails!["name"]),
                          //         _row("Department",
                          //             bookingDetails!["department"]),
                          //         _row("Position", bookingDetails!["position"]),
                          //         _row("Booking Type",
                          //             bookingDetails!["selectedBookingType"]),
                          //         _row("Reason", bookingDetails!["reason"]),
                          //         _row("Travel From",
                          //             bookingDetails!["travelFrom"]),
                          //         _row("Travel To",
                          //             bookingDetails!["destinationTo"]),
                          //         _row("Reach Time",
                          //             bookingDetails!["reachTime"]),
                          //         _row("Trip Duration",
                          //             bookingDetails!["tripDuration"]),
                          //         _row("Distance", bookingDetails!["distance"]),
                          //         _row("Travellers Count",
                          //             bookingDetails!["travellersCount"]),
                          //         _row("Incharge Status",
                          //             bookingDetails!["inchargeStatus"]),
                          //         _row("Secretary Status",
                          //             bookingDetails!["secStatus"]),
                          //         _row("GMO Status",
                          //             bookingDetails!["gmoStatus"]),
                          //         _row("CAR Assign",
                          //             bookingDetails!["secSpvStatus"]),
                          //         _row("Final Status",
                          //             bookingDetails!["finalStatus"]),
                          //         _row("Car Name", bookingDetails!["carName"]),
                          //         _row("Car No", bookingDetails!["carNo"]),

                          //         // 🚗 CAR ASSIGN DROPDOWN
                          //         if (availableCars.isNotEmpty) ...[
                          //           const SizedBox(height: 20),
                          //           const Text(
                          //             "Car Assign",
                          //             style: TextStyle(
                          //               fontSize: 16,
                          //               fontWeight: FontWeight.bold,
                          //             ),
                          //           ),
                          //           const SizedBox(height: 8),
                          //           // DropdownButtonFormField<String>(
                          //           //   decoration: InputDecoration(
                          //           //     hintText: "Select Car",
                          //           //     border: OutlineInputBorder(
                          //           //       borderRadius: BorderRadius.circular(12),
                          //           //     ),
                          //           //     contentPadding: const EdgeInsets.symmetric(
                          //           //         horizontal: 12, vertical: 14),
                          //           //   ),
                          //           //   value: selectedCarId,
                          //           //   isExpanded: true, // ✅ IMPORTANT
                          //           //   items: availableCars
                          //           //       .map<DropdownMenuItem<String>>((car) {
                          //           //     return DropdownMenuItem<String>(
                          //           //       value: car["carId"],
                          //           //       child: Row(
                          //           //         children: [
                          //           //           const Icon(Icons.directions_car,
                          //           //               size: 18),
                          //           //           const SizedBox(width: 8),

                          //           //           // ✅ FIX: bounded width, NO Expanded
                          //           //           SizedBox(
                          //           //             width: 200,
                          //           //             child: Text(
                          //           //               "${car["carNo"]} • ${car["carName"]} • ${car["capacity"]} seats",
                          //           //               maxLines: 1,
                          //           //               overflow: TextOverflow.ellipsis,
                          //           //               style: const TextStyle(fontSize: 12),
                          //           //             ),
                          //           //           ),
                          //           //         ],
                          //           //       ),
                          //           //     );
                          //           //   }).toList(),
                          //           //   onChanged: (value) {
                          //           //     setState(() {
                          //           //       selectedCarId = value;
                          //           //     });
                          //           //     debugPrint("Selected Car ID: $selectedCarId");
                          //           //   },
                          //           // ),

                          //           DropdownSearch<Map<String, dynamic>>(
                          //             selectedItem: availableCars
                          //                     .firstWhere(
                          //                       (car) =>
                          //                           car["carId"] ==
                          //                           selectedCarId,
                          //                       orElse: () => {},
                          //                     )
                          //                     .isEmpty
                          //                 ? null
                          //                 : availableCars.firstWhere(
                          //                     (car) =>
                          //                         car["carId"] == selectedCarId,
                          //                   ),
                          //             items: availableCars,
                          //             itemAsString: (car) =>
                          //                 _carDisplayText(car),
                          //             popupProps: const PopupProps.menu(
                          //               showSearchBox: true,
                          //               searchFieldProps: TextFieldProps(
                          //                 decoration: InputDecoration(
                          //                   hintText: "Search car...",
                          //                   border: OutlineInputBorder(),
                          //                 ),
                          //               ),
                          //             ),
                          //             dropdownDecoratorProps:
                          //                 const DropDownDecoratorProps(
                          //               dropdownSearchDecoration:
                          //                   InputDecoration(
                          //                 labelText: "Car Assign",
                          //                 hintText: "Select Car",
                          //                 border: OutlineInputBorder(),
                          //                 contentPadding: EdgeInsets.symmetric(
                          //                     horizontal: 12, vertical: 14),
                          //               ),
                          //             ),
                          //             onChanged: (car) {
                          //               setState(() {
                          //                 selectedCarId = car?["carId"];
                          //               });

                          //               debugPrint(
                          //                   "Selected Car ID: $selectedCarId");
                          //             },
                          //           ),
                          //         ],

                          //         const SizedBox(height: 20),
                          //         const Divider(),
                          //         const Center(
                          //           child: Text(
                          //             "End of Details",
                          //             style: TextStyle(
                          //               fontWeight: FontWeight.w500,
                          //               color: Colors.grey,
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          // 🔷 BOOKING DETAILS
                          buildGlassCard(
                            title: "Booking Details",
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildDetailRow("Booking ID",
                                    bookingDetails!["carBookingId"]),
                                buildDetailRow("Name", bookingDetails!["name"]),
                                buildDetailRow("Department",
                                    bookingDetails!["department"]),
                                buildDetailRow(
                                    "Position", bookingDetails!["position"]),
                                buildDetailRow(
                                    "Reason", bookingDetails!["reason"]),
                                buildDetailRow("Travel From",
                                    bookingDetails!["travelFrom"]),
                                buildDetailRow("Destination",
                                    bookingDetails!["destinationTo"]),
                                buildDetailRow(
                                    "Reach Time", bookingDetails!["reachTime"]),
                                buildDetailRow("Duration",
                                    bookingDetails!["tripDuration"]),
                                buildDetailRow(
                                    "Distance", bookingDetails!["distance"]),
                                buildDetailRow("Travellers",
                                    bookingDetails!["travellersCount"]),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 🔷 APPROVAL TRACKING
                          buildGlassCard(
                            title: "Approval Tracking",
                            child: Column(
                              children: [
                                CarTrackingDetailsStep(
                                  title: "Incharge Approval",
                                  isCompleted: _isApproved(
                                      bookingDetails!["inchargeStatus"]),
                                  isLast: false,
                                ),
                                CarTrackingDetailsStep(
                                  title: "Secretary Approval",
                                  isCompleted:
                                      _isApproved(bookingDetails!["secStatus"]),
                                  isLast: false,
                                ),
                                CarTrackingDetailsStep(
                                  title: "GMO Approval",
                                  isCompleted:
                                      _isApproved(bookingDetails!["gmoStatus"]),
                                  isLast: false,
                                ),
                                CarTrackingDetailsStep(
                                  title: "Car Assigned",
                                  isCompleted: _isApproved(
                                      bookingDetails!["secSpvStatus"]),
                                  isLast: false,
                                ),
                                CarTrackingDetailsStep(
                                  title: "Final Approval",
                                  isCompleted: _isApproved(
                                      bookingDetails!["finalStatus"]),
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 🔷 ASSIGN VEHICLE
                          if (availableCars.isNotEmpty)
                            buildGlassCard(
                              title: "Assign Vehicle",
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🚗 DROPDOWN
                                  DropdownSearch<Map<String, dynamic>>(
                                    items: availableCars,
                                    itemAsString: (car) => _carDisplayText(car),
                                    dropdownDecoratorProps:
                                        const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "Select Car",
                                        labelStyle:
                                            TextStyle(color: Colors.white),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white38),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.cyan),
                                        ),
                                      ),
                                    ),
                                    dropdownButtonProps:
                                        const DropdownButtonProps(
                                      icon: Icon(Icons.keyboard_arrow_down,
                                          color: Colors.white),
                                    ),
                                    dropdownBuilder: (context, selectedItem) {
                                      return Text(
                                        selectedItem == null
                                            ? "Select Car"
                                            : _carDisplayText(selectedItem),
                                        style: const TextStyle(
                                          color: Colors
                                              .white, // ✅ Selected text white
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    },
                                    onChanged: (car) {
                                      setState(() {
                                        selectedCarId = car?["carId"];
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

// ⏰ CAR OUT TIME
                                  if (selectedCarId != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Car Out Time",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: selectedCarOutTime == null
                                              ? () async {
                                                  TimeOfDay? picked =
                                                      await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now(),
                                                  );

                                                  if (picked != null) {
                                                    setState(() {
                                                      selectedCarOutTime =
                                                          "${picked.hour}:${picked.minute}";
                                                    });
                                                  }
                                                }
                                              : null,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 14),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.white38),
                                              color: Colors.white
                                                  .withOpacity(0.05),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  selectedCarOutTime ??
                                                      "Select Time",
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                const Icon(Icons.access_time,
                                                    color: Colors.white70),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 16),

                                  TextField(
                                    controller: driverNameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: "Driver Name",
                                      labelStyle: const TextStyle(
                                          color: Colors.white70),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white38),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.cyan),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: mailCc1Controller,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: "Mail CC1",
                                      labelStyle: const TextStyle(
                                          color: Colors.white70),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white38),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.cyan),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  TextField(
                                    controller: mailCc2Controller,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: "Mail CC2",
                                      labelStyle: const TextStyle(
                                          color: Colors.white70),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white38),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.cyan),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // 📝 REMARK FIELD
                                  TextField(
                                    controller: remarkController,
                                    maxLines: 3,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: "Remarks",
                                      labelStyle:
                                          TextStyle(color: Colors.white70),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white38),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.cyan),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // 📸 UPLOAD BUTTON
                                  GestureDetector(
                                    onTap: showImageSourceSheet,
                                    child: Container(
                                      height: 50,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo_outlined,
                                              size: 20,
                                              color: Colors.pinkAccent),
                                          SizedBox(height: 8),
                                          Text(
                                            "Tap to Upload Image",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // 🖼 IMAGE PREVIEW
                                  // if (imageUrl != null)
                                  if (selectedImage != null)
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            selectedImage!,
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: GestureDetector(
                                            onTap: removeImage,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),

                                  const SizedBox(height: 20),

                                  // ✅ ASSIGN BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        backgroundColor:
                                            Colors.cyanAccent.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Car Assigned Successfully!"),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Assign Car",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget buildGlassCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
          const Divider(color: Colors.white24),
          child,
        ],
      ),
    );
  }

  Widget buildDetailRow(String title, dynamic value) {
    if (!_hasValue(value)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(title, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            flex: 6,
            child: Text(value.toString(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
