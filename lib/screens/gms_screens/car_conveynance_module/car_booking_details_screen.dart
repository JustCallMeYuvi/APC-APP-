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
  final String? level; // 👈 ADD

  const CarBookingDetailsScreen({
    Key? key,
    required this.bookingId,
    this.level,
  }) : super(key: key);

  @override
  State<CarBookingDetailsScreen> createState() =>
      _CarBookingDetailsScreenState();
}

class _CarBookingDetailsScreenState extends State<CarBookingDetailsScreen> {
  bool _isLoading = true;

  bool _isSubmitting = false;
  Map<String, dynamic>? bookingDetails;
  // List<dynamic> availableCars = [];
  List<Map<String, dynamic>> availableCars = [];
  String? selectedCarId;

  String? selectedCarOutTime;

  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverNumberController = TextEditingController();

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

  Map<String, dynamic>? selectedCar;
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

  Future<void> _approveBooking() async {
    try {
      setState(() {
        _isSubmitting = true;
      });
      final url = "${ApiHelper.carConveynanceUrl}CarAssign";

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(url),
      );

      // 🔥 COMMON BOOKING DETAILS
      request.fields["CarBookingId"] =
          bookingDetails?["carBookingId"]?.toString() ?? "";

      request.fields["Name"] = bookingDetails?["name"]?.toString() ?? "";

      request.fields["Department"] =
          bookingDetails?["department"]?.toString() ?? "";

      request.fields["Position"] =
          bookingDetails?["position"]?.toString() ?? "";

      request.fields["Reason"] = bookingDetails?["reason"]?.toString() ?? "";

      request.fields["Barcode"] = bookingDetails?["barcode"]?.toString() ?? "";

      request.fields["TravelFrom"] =
          bookingDetails?["travelFrom"]?.toString() ?? "";

      request.fields["DestinationTo"] =
          bookingDetails?["destinationTo"]?.toString() ?? "";

      request.fields["TripDuration"] =
          bookingDetails?["tripDuration"]?.toString() ?? "";

      request.fields["Distance"] =
          bookingDetails?["distance"]?.toString() ?? "";

      request.fields["Travellers"] =
          bookingDetails?["travellers"]?.toString() ?? "";

      request.fields["SelectedBookingType"] =
          bookingDetails?["selectedBookingType"]?.toString() ?? "";

      request.fields["ApplicantEmail"] =
          bookingDetails?["applicantEmail"]?.toString() ?? "";

      // 🔥 IMPORTANT PART — STATUS UPDATE

      request.fields["InchargeStatus"] = "APPROVED";
      request.fields["SecStatus"] =
          bookingDetails?["secStatus"]?.toString() ?? "";
      request.fields["GMOStatus"] =
          bookingDetails?["gmoStatus"]?.toString() ?? "";
      request.fields["SecSpvStatus"] =
          bookingDetails?["secSpvStatus"]?.toString() ?? "";
      request.fields["FinalStatus"] =
          bookingDetails?["finalStatus"]?.toString() ?? "";

      // 🔥 Remark
      request.fields["Remark"] = remarkController.text.trim();

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      setState(() {
        _isSubmitting = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        debugPrint("Approval Error: $responseData");
        _showError("Approval failed");
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showError("Something went wrong");
    }
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

  Future<void> _fetchCarOutTime(String carId) async {
    try {
      final url = "${ApiHelper.carConveynanceUrl}CarTime/$carId";

      final response = await http.get(Uri.parse(url));

      debugPrint("CarTime Response: ${response.body}");
      debugPrint("Car time out URL $url");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // ✅ If travelTime exists
        if (decoded is Map && decoded["travelTime"] != null) {
          setState(() {
            selectedCarOutTime = decoded["travelTime"].toString();
          });
        }
        // ✅ If message = No active booking found
        else if (decoded is Map &&
            decoded["message"] == "No active booking found") {
          setState(() {
            selectedCarOutTime = null; // allow manual
          });
        }
      } else {
        setState(() {
          selectedCarOutTime = null;
        });
      }
    } catch (e) {
      debugPrint("Car time error: $e");
      setState(() {
        selectedCarOutTime = null;
      });
    }
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

  // void _showError(String msg) {
  //   setState(() => _isLoading = false);
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  // }
  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Error",
            style: TextStyle(color: Colors.red),
          ),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // 🔹 NULL / EMPTY SAFE CHECK
  bool _hasValue(dynamic value) {
    return value != null &&
        value.toString().trim().isNotEmpty &&
        value.toString().toLowerCase() != "null";
  }

  Future<void> _assignCar() async {
    // ✅ Mandatory validations
    if (selectedCarId == null) {
      _showError("Please select a car");
      return;
    }

    if (selectedCarOutTime == null || selectedCarOutTime!.isEmpty) {
      _showError("Please select car out time");
      return;
    }

    if (driverNameController.text.trim().isEmpty) {
      _showError("Driver Name is required");
      return;
    }
    if (driverNumberController.text.trim().isEmpty) {
      _showError("Driver Number is required");
      return;
    }

    if (selectedImage == null) {
      _showError("Driver Image is required");
      return;
    }

    try {
      // 🔥 START LOADER
      setState(() {
        _isSubmitting = true;
      });
      final url = "${ApiHelper.carConveynanceUrl}CarAssign";

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(url),
      );

      // 🔥 Mandatory Fields from bookingDetails
      request.fields["CarBookingId"] =
          bookingDetails?["carBookingId"]?.toString() ?? "";

      request.fields["Name"] = bookingDetails?["name"]?.toString() ?? "";

      request.fields["Department"] =
          bookingDetails?["department"]?.toString() ?? "";

      request.fields["Position"] =
          bookingDetails?["position"]?.toString() ?? "";

      request.fields["Reason"] = bookingDetails?["reason"]?.toString() ?? "";

      request.fields["Barcode"] = bookingDetails?["barcode"]?.toString() ?? "";

      request.fields["TravelFrom"] =
          bookingDetails?["travelFrom"]?.toString() ?? "";

      request.fields["DestinationTo"] =
          bookingDetails?["destinationTo"]?.toString() ?? "";

      request.fields["TripDuration"] =
          bookingDetails?["tripDuration"]?.toString() ?? "";

      request.fields["Distance"] =
          bookingDetails?["distance"]?.toString() ?? "";

      request.fields["Travellers"] =
          bookingDetails?["travellers"]?.toString() ?? "";

      request.fields["SelectedBookingType"] =
          bookingDetails?["selectedBookingType"]?.toString() ?? "";

      request.fields["ApplicantEmail"] =
          bookingDetails?["applicantEmail"]?.toString() ?? "";

      request.fields["InchargeStatus"] =
          bookingDetails?["inchargeStatus"]?.toString() ?? "";

      request.fields["SecStatus"] =
          bookingDetails?["secStatus"]?.toString() ?? "";

      request.fields["GMOStatus"] =
          bookingDetails?["gmoStatus"]?.toString() ?? "";

      request.fields["SecSpvStatus"] =
          bookingDetails?["secSpvStatus"]?.toString() ?? "";

      request.fields["FinalStatus"] =
          bookingDetails?["finalStatus"]?.toString() ?? "";

      // 🔥 Car Details
      request.fields["CarDetailsId"] = selectedCarId!;
      request.fields["TravelStartTime"] = selectedCarOutTime!;

      // Optional
      // request.fields["CarName"] = bookingDetails?["carName"]?.toString() ?? "";

      // request.fields["CarNo"] = bookingDetails?["carNo"]?.toString() ?? "";

      request.fields["CarName"] = selectedCar?["carName"]?.toString() ?? "";

      request.fields["CarNo"] = selectedCar?["carNo"]?.toString() ?? "";

      request.fields["DriverName"] = driverNameController.text.trim();

      // request.fields["DriverNo"] = ""; // if you add field later
      request.fields["DriverNo"] = driverNumberController.text.trim();

      request.fields["ccmaiL1"] = mailCc1Controller.text.trim();

      request.fields["ccmaiL2"] = mailCc2Controller.text.trim();

      request.fields["Remark"] = remarkController.text.trim();

      // 🔥 Image
      request.files.add(
        await http.MultipartFile.fromPath(
          "DriverImage",
          selectedImage!.path,
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      // 🔥 STOP LOADER
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Car Assigned Successfully!")),
        // );

        _showSuccessDialog();
      } else {
        debugPrint("Assign Error: $responseData");
        debugPrint("Selected Car: $selectedCar");
        debugPrint("Car Name: ${selectedCar?["carName"]}");
        debugPrint("Car No: ${selectedCar?["carNo"]}");
        _showError("Failed to assign car");
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showError("Something went wrong");
    }
  }

  void _showSuccessDialog() {
    String message;

    if (widget.level == "Approval") {
      message = "Car Approved Successfully!";
    } else {
      message = "Car Assigned Successfully!";
    }
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 70,
                ),
                const SizedBox(height: 16),
                Text(
                  // "Car Assigned Successfully!",
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // go back screen
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                  : Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // 🔷 BOOKING DETAILS
                              buildGlassCard(
                                title: "Booking Details",
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildDetailRow(
                                        "Barcode", bookingDetails!["barcode"]),
                                    buildDetailRow("Travellers",
                                        bookingDetails!["travellers"]),
                                    buildDetailRow("Booking ID",
                                        bookingDetails!["carBookingId"]),
                                    buildDetailRow(
                                        "Booking Type",
                                        bookingDetails?[
                                                "selectedBookingType"] ??
                                            "-"),
                                    buildDetailRow("Department",
                                        bookingDetails!["department"]),
                                    buildDetailRow(
                                        "Name", bookingDetails!["name"]),
                                    buildDetailRow("Position",
                                        bookingDetails!["position"]),
                                    buildDetailRow(
                                        "Reason", bookingDetails!["reason"]),
                                    buildDetailRow("Travel From",
                                        bookingDetails!["travelFrom"]),
                                    buildDetailRow("Destination",
                                        bookingDetails!["destinationTo"]),
                                    buildDetailRow("Reach Time",
                                        bookingDetails!["reachTime"]),
                                    buildDetailRow("Duration",
                                        bookingDetails!["tripDuration"]),
                                    buildDetailRow("Distance",
                                        bookingDetails!["distance"]),
                                    buildDetailRow("Travellers Count",
                                        bookingDetails!["travellersCount"]),
                                    buildDetailRow("Application Mail",
                                        bookingDetails!["applicantEmail"]),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // 🔷 APPROVAL TRACKING
                              // buildGlassCard(
                              //   title: "Approval Tracking",
                              //   child: Column(
                              //     children: [
                              //       CarTrackingDetailsStep(
                              //         title: "Incharge Approval",
                              //         isCompleted: _isApproved(
                              //             bookingDetails!["inchargeStatus"]),
                              //         isLast: false,
                              //       ),
                              //       CarTrackingDetailsStep(
                              //         title: "Secretary Approval",
                              //         isCompleted:
                              //             _isApproved(bookingDetails!["secStatus"]),
                              //         isLast: false,
                              //       ),
                              //       CarTrackingDetailsStep(
                              //         title: "GMO Approval",
                              //         isCompleted:
                              //             _isApproved(bookingDetails!["gmoStatus"]),
                              //         isLast: false,
                              //       ),
                              //       CarTrackingDetailsStep(
                              //         title: "Car Assigned",
                              //         isCompleted: _isApproved(
                              //             bookingDetails!["secSpvStatus"]),
                              //         isLast: false,
                              //       ),
                              //       CarTrackingDetailsStep(
                              //         title: "Final Approval",
                              //         isCompleted: _isApproved(
                              //             bookingDetails!["finalStatus"]),
                              //         isLast: true,
                              //       ),
                              //     ],
                              //   ),
                              // ),

                              buildGlassCard(
                                title: "Approval Tracking",
                                child: Column(
                                  children: [
                                    // 🔵 COMMON STEPS (Both Approval & Car Assign)
                                    CarTrackingDetailsStep(
                                      title: "Incharge Approval",
                                      isCompleted: _isApproved(
                                          bookingDetails!["inchargeStatus"]),
                                      isLast: false,
                                    ),
                                    CarTrackingDetailsStep(
                                      title: "Secretary Approval",
                                      isCompleted: _isApproved(
                                          bookingDetails!["secStatus"]),
                                      isLast: false,
                                    ),

                                    // 🟢 EXTRA STEPS ONLY FOR CAR ASSIGN
                                    if (widget.level == "Car Assign") ...[
                                      CarTrackingDetailsStep(
                                        title: "GMO Approval",
                                        isCompleted: _isApproved(
                                            bookingDetails!["gmoStatus"]),
                                        isLast: false,
                                      ),
                                      CarTrackingDetailsStep(
                                        title: "Car Assigned",
                                        isCompleted: _isApproved(
                                            bookingDetails!["secSpvStatus"]),
                                        isLast: false,
                                      ),
                                    ],

                                    // 🔴 FINAL APPROVAL (Always Last)
                                    CarTrackingDetailsStep(
                                      title: "Final Approval",
                                      isCompleted: _isApproved(
                                          bookingDetails!["finalStatus"]),
                                      isLast: true,
                                    ),

                                    const SizedBox(height: 20),

                                    // 🟡 SHOW REMARK + BUTTON ONLY FOR APPROVAL TYPE
                                    if (widget.level == "Approval") ...[
                                      TextField(
                                        controller: remarkController,
                                        maxLines: 3,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: const InputDecoration(
                                          labelText: "Remarks (Optional)",
                                          labelStyle:
                                              TextStyle(color: Colors.white70),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white38),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.cyan),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            backgroundColor:
                                                Colors.orangeAccent,
                                          ),
                                          onPressed: _approveBooking,
                                          child: const Text(
                                            "Approval",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 🔷 ASSIGN VEHICLE
                              if (availableCars.isNotEmpty)
                                buildGlassCard(
                                  title: "Assign Vehicle",
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 🚗 DROPDOWN
                                      DropdownSearch<Map<String, dynamic>>(
                                        items: availableCars,
                                        itemAsString: (car) =>
                                            _carDisplayText(car),
                                        dropdownDecoratorProps:
                                            const DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            labelText: "Select Car",
                                            labelStyle:
                                                TextStyle(color: Colors.white),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white38),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.cyan),
                                            ),
                                          ),
                                        ),
                                        dropdownButtonProps:
                                            const DropdownButtonProps(
                                          icon: Icon(Icons.keyboard_arrow_down,
                                              color: Colors.white),
                                        ),
                                        dropdownBuilder:
                                            (context, selectedItem) {
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
                                            selectedCar = car;
                                            selectedCarId = car?["carId"];
                                            selectedCarOutTime =
                                                null; // reset first
                                          });
                                          if (selectedCarId != null) {
                                            _fetchCarOutTime(
                                                selectedCarId!); // 👈 CALL API
                                          }
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
                                              onTap: () async {
                                                TimeOfDay? picked =
                                                    await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                );

                                                if (picked != null) {
                                                  setState(() {
                                                    selectedCarOutTime =
                                                        "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 14),
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
                                                    const Icon(
                                                        Icons.access_time,
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
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: "Driver Name",
                                          labelStyle: const TextStyle(
                                              color: Colors.white70),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.white38),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.cyan),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      TextField(
                                        controller: driverNumberController,
                                        keyboardType: TextInputType.phone,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: "Driver Number",
                                          labelStyle: const TextStyle(
                                              color: Colors.white70),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.white38),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.cyan),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: mailCc1Controller,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: "Mail CC1",
                                          labelStyle: const TextStyle(
                                              color: Colors.white70),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.white38),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.cyan),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      TextField(
                                        controller: mailCc2Controller,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: "Mail CC2",
                                          labelStyle: const TextStyle(
                                              color: Colors.white70),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.white38),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.cyan),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // 📝 REMARK FIELD
                                      TextField(
                                        controller: remarkController,
                                        maxLines: 3,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: const InputDecoration(
                                          labelText: "Remarks",
                                          labelStyle:
                                              TextStyle(color: Colors.white70),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white38),
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
                                            borderRadius:
                                                BorderRadius.circular(16),
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
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(6),
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
                                          // onPressed: () {
                                          //   ScaffoldMessenger.of(context)
                                          //       .showSnackBar(
                                          //     const SnackBar(
                                          //       content: Text(
                                          //           "Car Assigned Successfully!"),
                                          //     ),
                                          //   );
                                          // },
                                          onPressed: _assignCar,
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
                        // 🔥 LOADER OVERLAY (MUST BE INSIDE STACK)
                        if (_isSubmitting)
                          Container(
                            color: Colors.black.withOpacity(0.4),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.cyanAccent,
                              ),
                            ),
                          ),
                      ],
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
