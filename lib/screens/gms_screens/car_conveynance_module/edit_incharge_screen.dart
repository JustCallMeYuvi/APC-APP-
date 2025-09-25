import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/model/get_incharge_car_details_model.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditInchargeScreen extends StatefulWidget {
  final LoginModelApi userData;
  const EditInchargeScreen({Key? key, required this.userData})
      : super(key: key);

  @override
  State<EditInchargeScreen> createState() => _EditInchargeScreenState();
}

class _EditInchargeScreenState extends State<EditInchargeScreen> {
  List<Datum> inchargeData = []; // Local list of cars
  bool isLoading = true; // For initial loading
  Datum? selectedCar;

  TextEditingController searchController = TextEditingController();
  List<Datum> filteredInchargeData = [];

// Controllers for editing the incharge car details
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController deptController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController email2Controller = TextEditingController();
  final TextEditingController insertedByController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInchargeCars();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchController.text.trim().toLowerCase();
    setState(() {
      filteredInchargeData = inchargeData
          .where((car) => car.dept.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fetch incharge cars from API
  Future<void> fetchInchargeCars() async {
    final url = Uri.parse('${ApiHelper.carConveynanceUrl}Get_Incharges');

    // const String url =
    //     "http://10.3.0.70:9042/api/Car_Conveyance_/Get_Incharges";
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final model = getInchargeCarsDetailsModelFromJson(response.body);
        setState(() {
          inchargeData = model.data;
          isLoading = false;
          filteredInchargeData = inchargeData; // Initially show all cars
        });
      } else {
        throw Exception("Failed to load incharge cars");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching cars: $e")),
      );
    }
  } // Update a car

  Future<bool> updateCar(Datum car) async {
    final url = Uri.parse('${ApiHelper.carConveynanceUrl}UpdateIncharge');

    // const String url =
    //     "http://10.3.0.70:9042/api/Car_Conveyance_/UpdateIncharge";

    final Map<String, dynamic> body = {
      "barcode": barcodeController.text.trim(),
      "name": nameController.text.trim(),
      "dept": deptController.text.trim(),
      "email": emailController.text.trim(),
      "email2": email2Controller.text.trim(),
      "inserted_By": widget.userData.empNo, // API expects this field
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Update local list immediately6
        int index = inchargeData.indexWhere((c) => c.barcode == car.barcode);
        if (index != -1) {
          setState(() {
            inchargeData[index].barcode = barcodeController.text.trim();
            inchargeData[index].name = nameController.text.trim();
            inchargeData[index].dept = deptController.text.trim();
            inchargeData[index].email = emailController.text.trim();
            inchargeData[index].email2 = email2Controller.text.trim();
            inchargeData[index].insertedBy = widget.userData.empNo;
          });
        }
        return true;
      } else {
        print("Failed to update: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updating car: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Search by Department",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredInchargeData.isEmpty
                      ? const Center(child: Text("No matching barcode found"))
                      : ListView.builder(
                          itemCount: filteredInchargeData.length,
                          itemBuilder: (context, index) {
                            final car = filteredInchargeData[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    selectedCar = car;
                                    nameController.text = car.name;
                                    barcodeController.text = car.barcode;
                                    deptController.text = car.dept;
                                    emailController.text = car.email;
                                    email2Controller.text = car.email2;
                                    showEditCarDialog();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          car.dept,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        buildDetailRow("Barcode:", car.barcode),
                                        // buildDetailRow("Department:", car.dept),
                                        buildDetailRow("Name:", car.name),

                                        buildDetailRow("Email:", car.email),
                                        buildDetailRow("Email2:", car.email2),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

      // cars.isEmpty
      //     ? const Center(child: Text("No data available"))
      //     : ListView.builder(
      //         itemCount: cars.length,
      //         itemBuilder: (context, index) {
      //           final car = cars[index];
      //           return Padding(
      //             padding: const EdgeInsets.symmetric(
      //                 horizontal: 16.0, vertical: 8.0),
      //             child: Card(
      //               elevation: 4,
      //               shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(10)),
      //               child: InkWell(
      //                 borderRadius: BorderRadius.circular(10),
      //                 onTap: () {
      //                   selectedCar = car;
      //                   nameController.text = car.name;
      //                   barcodeController.text = car.barcode;
      //                   deptController.text = car.dept;
      //                   emailController.text = car.email;
      //                   email2Controller.text =
      //                       car.email2; // <-- populate email2
      //                   showEditCarDialog();
      //                 },
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(16.0),
      //                   child: Column(
      //                     crossAxisAlignment: CrossAxisAlignment.center,
      //                     children: [
      //                       Text(
      //                         car.name,
      //                         style: const TextStyle(
      //                             fontSize: 18,
      //                             fontWeight: FontWeight.bold),
      //                       ),
      //                       const SizedBox(height: 8),
      //                       buildDetailRow("Barcode:", car.barcode),
      //                       buildDetailRow("Department:", car.dept),
      //                       buildDetailRow("Email:", car.email),
      //                       buildDetailRow("Email2:", car.email2),
      //                     ],
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           );
      //         },
      //       ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Set common width for all labels
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void showEditCarDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Edit Car Details",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  buildTextField(deptController, "Department", readOnly: true),
                  const SizedBox(height: 12),
                  buildTextField(barcodeController, "Barcode"),
                  const SizedBox(height: 12),
                  buildTextField(nameController, "Name"),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  buildTextField(emailController, "Email"),
                  const SizedBox(height: 20),
                  buildTextField(email2Controller, "Email2"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12)),
                        child: const Text("Cancel",
                            style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedCar != null) {
                            bool success = await updateCar(selectedCar!);
                            Navigator.of(context).pop(); // Close dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? "Incharge updated successfully"
                                    : "Failed to update incharge"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Update",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
