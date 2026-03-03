import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/model/get_incharge_car_details_model.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeleteInchargeScreen extends StatefulWidget {
  final LoginModelApi userData;
  const DeleteInchargeScreen({Key? key, required this.userData})
      : super(key: key);

  @override
  _DeleteInchargeScreenState createState() => _DeleteInchargeScreenState();
}

class _DeleteInchargeScreenState extends State<DeleteInchargeScreen> {
  List<Datum> inchargeDataList = []; // Local list of cars
  bool isLoading = true; // For initial loading

  TextEditingController searchController = TextEditingController();
  List<Datum> filteredData = []; // Filtered list based on search

  @override
  void initState() {
    super.initState();
    fetchInchargeCars();
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
      filteredData = inchargeDataList
          .where((car) => car.dept.toLowerCase().contains(query))
          .toList();
    });
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
          inchargeDataList = model.data;
          isLoading = false;
          filteredData = model.data; // Initially show all data
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
  }

  // Delete incharge car by deptName
  Future<void> deleteInchargeCar(String deptName) async {
    final url = Uri.parse('${ApiHelper.carConveynanceUrl}incharge/$deptName');

    // final String url =
    //     "http://10.3.0.70:9042/api/Car_Conveyance_/incharge/$deptName";
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Car deleted successfully")),
        );
        // Refresh the list
        fetchInchargeCars();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
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
                  child: filteredData.isEmpty
                      ? const Center(child: Text("No matching barcode found"))
                      : ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final car = inchargeDataList[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                title: Center(
                                  child: Text(car.dept,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),

                                    // Text("Barcode: ${car.barcode}"),
                                    buildDetailRow("Barcode:", car.barcode),
                                    // Text("Name: ${car.name}"),
                                    buildDetailRow("Name:", car.name),
                                    // buildDetailRow("Email:", car.email),
                                    // buildDetailRow("Email2:", car.email2),

                                    // Text("Email: ${car.email}"),
                                    // Text("Email2: ${car.email2}"),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => confirmDelete(context,
                                      car.dept), // use dept or caRNo as needed
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
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

  void confirmDelete(BuildContext context, String deptName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this incharge?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteInchargeCar(deptName); // Call the delete function here
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
