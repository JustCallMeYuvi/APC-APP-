import 'dart:convert';

import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:http/http.dart' as http;

class AddCarsScreen extends StatefulWidget {
  final LoginModelApi userData;
  const AddCarsScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _AddCarsScreenState createState() => _AddCarsScreenState();
}

class _AddCarsScreenState extends State<AddCarsScreen> {
  final TextEditingController _carNameController = TextEditingController();
  final TextEditingController _carNoController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _carTypeController = TextEditingController();

  final List<String> carTypes = ["NORMAL", "VIP", "EMERGENCY"];
  String? _selectedCarType;
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();

    // Set the driver name to the empNo from userData when the screen loads
    // _driverNameController.text = widget.userData.empNo;

    // Optionally, fetch other initial data or perform setup here
  }

  // Future<void> updateCar() async {
  //   final String url = "http://10.3.0.70:9042/api/Car_Conveyance_/NewcarsAdd";

  //   final Map<String, dynamic> body = {
  //     "caR_NAME": _carNameController.text.trim(),
  //     "caR_NO": _carNoController.text.trim(),
  //     "capacity": _capacityController.text.trim(),
  //     "driveR_NAME": _driverNameController.text.trim(),
  //     "caR_BOOKING_TYPE": _selectedCarType ?? "",
  //     "inserted_By": widget.userData.empNo,
  //     "querytype": "" // Send "update" or "" depending on backend
  //   };

  //   print("Update body: ${jsonEncode(body)}");

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(body),
  //     );

  //     if (response.statusCode == 200) {
  //       final res = jsonDecode(response.body);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(res["message"] ?? "Updated successfully")),
  //       );
  //       setState(() {
  //         isUpdate = false; // reset after update
  //       });
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Failed to update car: ${response.body}")),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: $e")),
  //     );
  //   }
  // }

  Future<void> updateCar() async {
    final String url = "http://10.3.0.70:9042/api/Car_Conveyance_/NewcarsAdd";

    final Map<String, dynamic> body = {
      "caR_NAME": _carNameController.text.trim(),
      "caR_NO": _carNoController.text.trim(),
      "capacity": _capacityController.text.trim(),
      "driveR_NAME": _driverNameController.text.trim(),
      "caR_BOOKING_TYPE": _selectedCarType ?? "",
      "inserted_By": widget.userData.empNo,
      "querytype":
          "" // Depending on backend, send "update" or empty string as required
    };

    print("Update body: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        showAlert(
            context, "Update Car", res["message"] ?? "Updated successfully");
        setState(() {
          isUpdate = false; // Reset after update
        });
      } else {
        showAlert(context, "Error", "Failed to update car: ${response.body}");
      }
    } catch (e) {
      showAlert(context, "Exception", "Error: $e");
    }
  }

  // Future<void> addNewCar() async {
  //   final String url = "http://10.3.0.70:9042/api/Car_Conveyance_/NewcarsAdd";

  //   final Map<String, dynamic> body = {
  //     // "carName": _carNameController.text.trim(),
  //     // "carNo": _carNoController.text.trim(),
  //     // "capacity": _capacityController.text.trim(),
  //     // "driverName": _driverNameController.text.trim(),
  //     // "carBookingType": _selectedCarType ?? "",
  //     // "insertedBy": widget.userData.empNo,
  //     // "querytype": 'insert'

  //     "caR_NAME": _carNameController.text.trim(),
  //     "caR_NO": _carNoController.text.trim(),
  //     "capacity": _capacityController.text.trim(), // Send as string
  //     "driveR_NAME": _driverNameController.text.trim(),
  //     "caR_BOOKING_TYPE": _selectedCarType ?? "",
  //     "inserted_By": widget.userData.empNo, // Already a string
  //     "querytype": "insert", // As required by backend
  //   };

  //   print("Request body: ${jsonEncode(body)}"); // Debugging output

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(body),
  //     );

  //     if (response.statusCode == 200) {
  //       print("Success: ${response.body}");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Car added successfully")),
  //       );
  //     } else {
  //       print("Error ${response.statusCode}: ${response.body}");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Failed to add car: ${response.body}")),
  //       );
  //     }
  //   } catch (e) {
  //     print("Exception: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: $e")),
  //     );
  //   }
  // }

  Future<void> addNewCar() async {
    // Check if all fields are filled
    if (_carNameController.text.trim().isEmpty ||
        _carNoController.text.trim().isEmpty ||
        _capacityController.text.trim().isEmpty ||
        _driverNameController.text.trim().isEmpty ||
        (_selectedCarType == null || _selectedCarType!.trim().isEmpty)) {
      showAlert(context, "Validation Error", "Please fill in all fields.");
      return;
    }
    final String url = "http://10.3.0.70:9042/api/Car_Conveyance_/NewcarsAdd";

    final Map<String, dynamic> body = {
      "caR_NAME": _carNameController.text.trim(),
      "caR_NO": _carNoController.text.trim(),
      "capacity": _capacityController.text.trim(),
      "driveR_NAME": _driverNameController.text.trim(),
      "caR_BOOKING_TYPE": _selectedCarType ?? "",
      "inserted_By": widget.userData.empNo,
      "querytype": "insert"
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);

        if (res["message"] == "Car already exists") {
          // Show update dialog
          showAlert(context, "Car already exists", "You can update it.");

          // Populate fields from existing data if available
          final carData = res["data"];
          if (carData != null) {
            _carNameController.text = carData["caR_NAME"] ?? "";
            _carNoController.text = carData["caR_NO"] ?? "";
            _capacityController.text = carData["capacity"] ?? "";
            _driverNameController.text = carData["driveR_NAME"] ?? "";
            _selectedCarType = carData["caR_BOOKING_TYPE"] ?? "";
            _carTypeController.text = _selectedCarType!;
          }

          setState(() {
            isUpdate = true; // Show the update button
          });
        } else {
          setState(() {
            isUpdate = false;
          });
          showAlert(
              context, "Success", res["message"] ?? "Car added successfully");
        }
      } else {
        showAlert(context, "Error", "Error: ${response.statusCode}");
      }
    } catch (e) {
      showAlert(context, "Exception", "Exception: $e");
    }
  }

// ✅ Helper method to show alert dialog
  void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Car Name
              TextField(
                controller: _carNameController,
                decoration: const InputDecoration(
                  labelText: "Car Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Car Number
              TextField(
                controller: _carNoController,
                decoration: const InputDecoration(
                  labelText: "Car Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Capacity
              TextField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Capacity",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Driver Name
              TextField(
                controller: _driverNameController,
                decoration: const InputDecoration(
                  labelText: "Driver Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Car Booking Type Search Dropdown
              DropDownSearchField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _carTypeController,
                  decoration: const InputDecoration(
                    labelText: "Car Booking Type",
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
              const SizedBox(height: 30),

              // Submit Button
              // ElevatedButton(
              //   onPressed: () {
              //     String carName = _carNameController.text;
              //     String carNo = _carNoController.text;
              //     String capacity = _capacityController.text;
              //     String driverName = _driverNameController.text;
              //     String carType = _selectedCarType ?? "";

              //     submitForm();
              //     print("Emp No: ${widget.userData.empNo}");
              //     print("Car Name: $carName");
              //     print("Car No: $carNo");
              //     print("Capacity: $capacity");
              //     print("Driver Name: $driverName");
              //     print("Car Type: $carType");

              //     // Here you can call an API to insert the data using widget.userData.empNo
              //   },
              //   child: const Text("Submit"),
              // ),
              // Your text fields here

              // isUpdate
              //     ? ElevatedButton(
              //         onPressed: updateCar,
              //         child: const Text("Update"),
              //       )
              //     : ElevatedButton(
              //         onPressed: addNewCar,
              //         child: const Text("Add Car"),
              //       ),
              ElevatedButton(
                onPressed: addNewCar,
                child: const Text("Add Car"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
