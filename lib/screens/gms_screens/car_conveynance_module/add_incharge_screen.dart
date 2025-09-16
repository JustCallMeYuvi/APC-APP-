import 'dart:convert';

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

  final List<String> carTypes = ["NORMAL", "VIP", "EMERGENCY"];
  String? _selectedCarType;
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
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

    const String url =
        "http://10.3.0.70:9042/api/Car_Conveyance_/InsertIncharge";

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
        Uri.parse(url),
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
              TextField(
                controller: barcodeController,
                decoration: const InputDecoration(
                  labelText: "Barcode",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

// Name
              TextField(
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
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: addInchargeNewCar,
                child: const Text("Add Car"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
