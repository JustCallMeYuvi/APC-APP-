import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _futureCars = fetchCars();
  }

  Future<GetCarsDetailsModel> fetchCars() async {
    const String url = "http://10.3.0.70:9042/api/Car_Conveyance_/Get_Cars";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return getCarsDetailsModelFromJson(response.body);
    } else {
      throw Exception("Failed to load cars");
    }
  }

  Future<void> updateCar(Datum car) async {
    const String url = "http://10.3.0.70:9042/api/Car_Conveyance_/NewcarsAdd";

    final Map<String, dynamic> body = {
      "caR_NAME": nameController.text.trim(),
      "caR_NO": noController.text.trim(),
      "capacity": capacityController.text.trim(),
      "driveR_NAME": driverController.text.trim(),
      "caR_BOOKING_TYPE": car.caRBookingType.name, // or map accordingly
      "inserted_By": widget.userData.empNo, // or appropriate user id
      "querytype": "update" // assuming backend handles this
    };

    final response = await http.post(
      Uri.parse(url),
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
          final cars = snapshot.data!.data;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
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
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (selectedCar != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Edit Car Details",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        buildTextField(nameController, "Car Name"),
                        const SizedBox(height: 12),
                        buildTextField(noController, "Car No"),
                        const SizedBox(height: 12),
                        buildTextField(capacityController, "Capacity"),
                        const SizedBox(height: 12),
                        buildTextField(driverController, "Driver Name"),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (selectedCar != null) {
                              updateCar(selectedCar!);
                            }
                          },
                          child: const Text(
                            "Update Car",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          );
        }
      },
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
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
