import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VehicleIdDetailsGmsPage extends StatefulWidget {
  final String vehicleId;
  const VehicleIdDetailsGmsPage({Key? key, required this.vehicleId})
      : super(key: key);

  @override
  _VehicleIdDetailsGmsPageState createState() =>
      _VehicleIdDetailsGmsPageState();
}

class _VehicleIdDetailsGmsPageState extends State<VehicleIdDetailsGmsPage> {
  Map<String, dynamic>? vehicleData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVehicleDetails();
  }

  Future<void> fetchVehicleDetails() async {
    final url = '${ApiHelper.gmsUrl}iddetails?vehicleid=${widget.vehicleId}';
    print('Id Details URL $url');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          vehicleData = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load vehicle data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching vehicle details: $e');
    }
  }

  Future<void> deleteVehicle() async {
    final url =
        '${ApiHelper.gmsUrl}deletevehicleid?vehicleid=${widget.vehicleId}';
    print('Delete ID URL $url');
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        // Show success message and pop back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vehicle deleted successfully")),
        );
        Navigator.of(context).pop(); // Go back after deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print('Error deleting vehicle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error occurred during deletion")),
      );
    }
  }

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this vehicle?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              deleteVehicle(); // perform delete
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200, // Fixed width to align all titles
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        backgroundColor: Colors.lightGreen,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.delete),
        //     onPressed: showDeleteConfirmationDialog,
        //   ),
        // ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicleData == null
              ? const Center(child: Text("No data found"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // buildDetailRow(
                      //     "Vehicle Number", vehicleData!['vehiclE_NUMBER']),
                      // buildDetailRow(
                      //     "Driver Name", vehicleData!['driveR_NAME']),
                      // buildDetailRow(
                      //     "License Number", vehicleData!['licensE_NUMBER']),
                      // buildDetailRow("CHA", vehicleData!['cha']),
                      // buildDetailRow("Inspection", vehicleData!['inspection']),
                      Stack(children: [
                        Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  buildDetailRow(
                                      "Vehicle ID", vehicleData!['vehicleid']),
                                  buildDetailRow("Vehicle Number",
                                      vehicleData!['vehiclE_NUMBER']),
                                  buildDetailRow("Driver Name",
                                      vehicleData!['driveR_NAME']),
                                  buildDetailRow("License Number",
                                      vehicleData!['licensE_NUMBER']),
                                  buildDetailRow("CHA", vehicleData!['cha']),
                                  buildDetailRow(
                                      "Inspection", vehicleData!['inspection']),
                                ],
                              ),
                            )),
                        // Positioned(
                        //   top: 90,
                        //   right: -10,
                        //   child: IconButton(
                        //     icon: const Icon(Icons.delete, color: Colors.red),
                        //     onPressed: showDeleteConfirmationDialog,
                        //   ),
                        // ),
                      ]),
                      const SizedBox(
                        height: 10,
                      ),
                      Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.red,
                                Colors.deepOrangeAccent,
                                Colors.orange
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: showDeleteConfirmationDialog,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              alignment: Alignment.center,
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
