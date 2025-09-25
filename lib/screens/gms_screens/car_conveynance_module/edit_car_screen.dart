import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/model/get_cars_details_model.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Import your GetCarsDetailsModel here

class EditCarScreen extends StatefulWidget {
  final LoginModelApi userData;
  const EditCarScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  late Future<GetCarsDetailsModel> _futureCars;
  Datum? selectedCar;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController noController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController driverController = TextEditingController();
// Dropdown for booking type
  String? selectedBookingType;
  final List<String> bookingTypes = ["NORMAL", "VIP", "EMERGENCY"];

  TextEditingController searchController = TextEditingController();
  List<Datum> filteredCars = [];
  List<Datum> snapshotData = [];

  @override
  void initState() {
    super.initState();
    _futureCars = fetchCars();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = searchController.text.trim().toLowerCase();
    setState(() {
      filteredCars = (snapshotData ?? [])
          .where((car) => car.caRNo.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<GetCarsDetailsModel> fetchCars() async {
    final url = Uri.parse('${ApiHelper.carConveynanceUrl}Get_Cars');

    // const String url = "http://10.3.0.70:9042/api/Car_Conveyance_/Get_Cars";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return getCarsDetailsModelFromJson(response.body);
    } else {
      throw Exception("Failed to load cars");
    }
  }

  Future<void> updateCar(Datum car) async {
    final url = Uri.parse('${ApiHelper.carConveynanceUrl}UpdateCar');

    // const String url = "http://10.3.0.70:9042/api/Car_Conveyance_/UpdateCar";

    final Map<String, dynamic> body = {
      "caR_NAME": nameController.text.trim(),
      "caR_NO": noController.text.trim(),
      "capacity": capacityController.text.trim(),
      "driveR_NAME": driverController.text.trim(),
      // "caR_BOOKING_TYPE": car.caRBookingType.name, // or map accordingly
      "caR_BOOKING_TYPE": selectedBookingType ??
          car.caRBookingType.name, // ✅ Use updated booking type
      "inserted_By": widget.userData.empNo, // or appropriate user id
      // "querytype": "update" // assuming backend handles this
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      // Successfully updated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Car details updated successfully")),
      );
      // Refresh the list after update
      setState(() {
        _futureCars = fetchCars();
      });
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update car details")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GetCarsDetailsModel>(
      future: _futureCars,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          // final cars = snapshot.data!.data;
          snapshotData = snapshot.data!.data;
          filteredCars = searchController.text.isEmpty
              ? snapshotData
              : snapshotData
                  .where((car) => car.caRNo
                      .toLowerCase()
                      .contains(searchController.text.trim().toLowerCase()))
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: "Search by Car No",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: cars.length,
              //     itemBuilder: (context, index) {
              //       final car = cars[index];
              //       return Padding(
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 16.0, vertical: 8.0),
              //         child: Card(
              //           elevation: 4,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: InkWell(
              //             borderRadius: BorderRadius.circular(10),
              //             onTap: () {
              //               setState(() {
              //                 selectedCar = car;
              //                 nameController.text = car.caRName;
              //                 noController.text = car.caRNo;
              //                 capacityController.text = car.capacity;
              //                 driverController.text = car.driveRName;
              //                 showEditCarDialog();
              //               });
              //             },
              //             child: Padding(
              //               padding: const EdgeInsets.all(16.0),
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Text(
              //                     car.caRName,
              //                     style: const TextStyle(
              //                         fontSize: 18,
              //                         fontWeight: FontWeight.bold),
              //                   ),
              //                   const SizedBox(height: 8),
              //                   Text("Car No: ${car.caRNo}"),
              //                   Text("Capacity: ${car.capacity}"),
              //                   Text("Driver: ${car.driveRName}"),
              //                 ],
              //               ),
              //             ),
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
              Expanded(
                child: filteredCars.isEmpty
                    ? const Center(child: Text("No matching car number found"))
                    : ListView.builder(
                        itemCount: filteredCars.length,
                        itemBuilder: (context, index) {
                          final car = filteredCars[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  setState(() {
                                    selectedCar = car;
                                    nameController.text = car.caRName;
                                    noController.text = car.caRNo;
                                    capacityController.text = car.capacity;
                                    driverController.text = car.driveRName;
                                    selectedBookingType = car.caRBookingType
                                        .name; // ✅ Set the booking type here

                                    showEditCarDialog(car);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        car.caRName,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text("Car No: ${car.caRNo}"),
                                      Text("Capacity: ${car.capacity}"),
                                      Text("Driver: ${car.driveRName}"),
                                      Text(
                                          "Booking Type: ${car.caRBookingType.name}"),
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
          );
        }
      },
    );
  }

  // void showEditCarDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // User must press buttons to close
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         elevation: 5,
  //         backgroundColor: Colors.transparent,
  //         child: Container(
  //           padding: const EdgeInsets.all(20),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(20),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.2),
  //                 blurRadius: 10,
  //                 offset: const Offset(0, 5),
  //               ),
  //             ],
  //           ),
  //           child: SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 const Text(
  //                   "Edit Car Details",
  //                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 buildTextField(noController, "Car No", readOnly: true),
  //                 const SizedBox(height: 12),
  //                 buildTextField(nameController, "Car Name"),
  //                 const SizedBox(height: 12),
  //                 buildTextField(capacityController, "Capacity"),
  //                 const SizedBox(height: 12),
  //                 buildTextField(driverController, "Driver Name"),
  //                 const SizedBox(height: 20),
  //                 buildTextField(driverController, "Driver Name"),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     TextButton(
  //                       onPressed: () {
  //                         Navigator.of(context).pop(); // Close dialog
  //                       },
  //                       style: TextButton.styleFrom(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 20, vertical: 12),
  //                       ),
  //                       child: const Text(
  //                         "Cancel",
  //                         style: TextStyle(fontSize: 16),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 10),
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         if (selectedCar != null) {
  //                           updateCar(selectedCar!);
  //                           Navigator.of(context)
  //                               .pop(); // Close dialog after updating
  //                         }
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 20, vertical: 12),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                       ),
  //                       child: const Text(
  //                         "Update",
  //                         style: TextStyle(fontSize: 16),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void showEditCarDialog(Datum car) {
    // Initialize the fields
    noController.text = car.caRNo;
    nameController.text = car.caRName;
    capacityController.text = car.capacity;
    driverController.text = car.driveRName;
    selectedBookingType = car.caRBookingType.name;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Edit Car Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  buildTextField(noController, "Car No", readOnly: true),
                  const SizedBox(height: 12),
                  buildTextField(nameController, "Car Name"),
                  const SizedBox(height: 12),
                  buildTextField(capacityController, "Capacity"),
                  const SizedBox(height: 12),
                  buildTextField(driverController, "Driver Name"),
                  const SizedBox(height: 12),

                  // Booking Type Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedBookingType,
                    decoration: const InputDecoration(
                      labelText: "Booking Type",
                      border: OutlineInputBorder(),
                    ),
                    items: bookingTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBookingType = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedBookingType != null) {
                            updateCar(car);
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please select booking type")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Update",
                          style: TextStyle(fontSize: 16),
                        ),
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
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
