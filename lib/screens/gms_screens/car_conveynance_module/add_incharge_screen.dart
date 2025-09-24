import 'dart:convert';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:http/http.dart' as http;

class AddInchargeScreen extends StatefulWidget {
  final LoginModelApi userData;
  const AddInchargeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _AddInchargeScreenState createState() => _AddInchargeScreenState();
}

class _AddInchargeScreenState extends State<AddInchargeScreen> {
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController deptController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController email2Controller = TextEditingController();

  // List<String> barcodes = []; // store fetched barcodes
  List<Map<String, dynamic>> barcodeData = [];

  final List<String> carTypes = ["NORMAL", "VIP", "EMERGENCY"];
  String? _selectedCarType;
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    fetchBarcodes();
  }

  // Future<void> fetchBarcodes() async {
  //   const String url = "http://10.3.0.70:9042/api/Car_Conveyance_/barcodes";

  //   try {
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body);

  //       setState(() {
  //         // ✅ Only keep the barcode field
  //         barcodes = data.map((item) => item['barcode'].toString()).toList();
  //       });
  //     } else {
  //       showAlert(context, "Error", "Failed to fetch barcodes");
  //     }
  //   } catch (e) {
  //     showAlert(context, "Exception", "Error: $e");
  //   }
  // }

  Future<void> fetchBarcodes() async {
    // const String url = "http://10.3.0.70:9042/api/Car_Conveyance_/barcodes";
    final String url = '${ApiHelper.carConveynanceUrl}barcodes';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          // ✅ Keep full map (barcode + name + dept + email...)
          barcodeData = List<Map<String, dynamic>>.from(data);
        });
      } else {
        showAlert(context, "Error", "Failed to fetch barcodes");
      }
    } catch (e) {
      showAlert(context, "Exception", "Error: $e");
    }
  }

  Future<void> addInchargeNewCar() async {
    // Validate all fields
    if (barcodeController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        deptController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        email2Controller.text.trim().isEmpty) {
      showAlert(context, "Validation Error", "Please fill in all fields.");
      return;
    }

    // Validate email format
    if (!emailController.text.trim().endsWith("@in.apachefootwear.com")) {
      showAlert(context, "Invalid Email",
          "Email must end with @in.apachefootwear.com");
      return;
    }

    if (!email2Controller.text.trim().endsWith("@in.apachefootwear.com")) {
      showAlert(context, "Invalid Email",
          "Email 2 must end with @in.apachefootwear.com");
      return;
    }

    // const String url =
    //     "http://10.3.0.70:9042/api/Car_Conveyance_/InsertIncharge";

    final url = Uri.parse('${ApiHelper.carConveynanceUrl}InsertIncharge');

    final Map<String, dynamic> body = {
      "barcode": barcodeController.text.trim(),
      "name": nameController.text.trim(),
      "dept": deptController.text.trim(),
      "email": emailController.text.trim(),
      "email2": email2Controller.text.trim(),
      "inserted_By": widget.userData.empNo,
    };

    print("Request Body: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        // Uri.parse(url),
        url, // ✅ already parsed
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);

        if (res["message"] == "Car already exists") {
          showAlert(context, "Car already exists", "You can update it.");

          final carData = res["data"];
          if (carData != null) {
            barcodeController.text = carData["barcode"] ?? "";
            nameController.text = carData["name"] ?? "";
            deptController.text = carData["dept"] ?? "";
            emailController.text = carData["email"] ?? "";
            email2Controller.text = carData["email2"] ?? "";
          }

          setState(() {
            isUpdate = true;
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
              // Barcode
              // TextField(
              //   controller: barcodeController,
              //   decoration: const InputDecoration(
              //     labelText: "Barcode",
              //     border: OutlineInputBorder(),
              //   ),
              // ),

              // DropDownSearchField(
              //   textFieldConfiguration: TextFieldConfiguration(
              //     controller: barcodeController,
              //     decoration: const InputDecoration(
              //       border: OutlineInputBorder(),
              //       labelText: "Select Barcode",
              //       suffixIcon: Icon(Icons.arrow_drop_down),
              //     ),
              //   ),
              //   suggestionsCallback: (pattern) async {
              //     return barcodes
              //         .where((barcode) =>
              //             barcode.toLowerCase().contains(pattern.toLowerCase()))
              //         .toList();
              //   },
              //   itemBuilder: (context, suggestion) {
              //     return ListTile(title: Text(suggestion)); // ✅ Only barcode
              //   },
              //   onSuggestionSelected: (suggestion) {
              //     setState(() {
              //       barcodeController.text = suggestion;
              //     });

              //     // Later you can fetch details (name, dept, email...) based on barcode
              //   },
              //   displayAllSuggestionWhenTap: true,
              //   isMultiSelectDropdown: false,
              // ),

              DropDownSearchField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: barcodeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Select Barcode",
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return barcodeData
                      .where((item) => item['barcode']
                          .toString()
                          .toLowerCase()
                          .contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion['barcode']
                        .toString()), // ✅ Show only barcode
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    barcodeController.text = suggestion['barcode'].toString();
                    nameController.text =
                        suggestion['name'].toString(); // ✅ Auto-fill name
                    // you can also fill dept, email, etc. here if needed
                  });
                },
                displayAllSuggestionWhenTap: true,
                isMultiSelectDropdown: false,
              ),

              const SizedBox(height: 16),

// Name
              TextField(
                readOnly: true,
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

// Department
              TextField(
                controller: deptController,
                decoration: const InputDecoration(
                  labelText: "Department",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

// Email 1
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

// Email 2
              TextField(
                controller: email2Controller,
                decoration: const InputDecoration(
                  labelText: "Email 2",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.30, // 3% of screen height
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // 🔹 button color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: addInchargeNewCar,
                  child: const Text(
                    "Add",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
