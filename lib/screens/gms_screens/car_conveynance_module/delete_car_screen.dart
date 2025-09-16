import 'package:animated_movies_app/model/get_cars_details_model.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeleteCarScreen extends StatefulWidget {
  final LoginModelApi userData;
  const DeleteCarScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<DeleteCarScreen> createState() => _DeleteCarScreenState();
}

class _DeleteCarScreenState extends State<DeleteCarScreen> {
  late Future<GetCarsDetailsModel> _futureCars;

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

  Future<void> deleteCar(String carNo) async {
    final String url = "http://10.3.0.70:9042/api/Car_Conveyance_/car/$carNo";
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Car deleted successfully")),
      );
      // Refresh the list
      setState(() {
        _futureCars = fetchCars();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete car")),
      );
    }
  }

  void confirmDelete(BuildContext context, String carNo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this car?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              deleteCar(carNo);
            },
          ),
        ],
      ),
    );
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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(car.caRName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("No: ${car.caRNo}"),
                      Text("Capacity: ${car.capacity}"),
                      Text("Driver: ${car.driveRName}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => confirmDelete(context, car.caRNo),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
