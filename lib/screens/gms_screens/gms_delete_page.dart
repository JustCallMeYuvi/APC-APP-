import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/gms_screens/gms_files_page.dart';
import 'package:animated_movies_app/screens/gms_screens/vehicle_id_details_gms_page.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_symbols_icons/symbols.dart';

class GMSDeletePage extends StatefulWidget {
  const GMSDeletePage({Key? key}) : super(key: key);

  @override
  _GMSDeletePageState createState() => _GMSDeletePageState();
}

class _GMSDeletePageState extends State<GMSDeletePage> {
  bool isLoadingAllVehiclesData = false;
  String? _selectedVehicleNumber; // To store the selected vehicle
  Map<String, dynamic>?
      _selectedVehicleDetails; // To store details of the selected vehicle
  List<Map<String, dynamic>> _allVehicles = []; // All vehicles data
  final TextEditingController _vehicleTrackController = TextEditingController();
  // final String apiUrl = "http://10.3.0.208:8084/api/GMS/status-report";

  @override
  void initState() {
    super.initState();
    _fetchAllVehicles(); // Fetch data on page load
  }

  Future<void> _fetchAllVehicles() async {
    setState(() {
      isLoadingAllVehiclesData = true;
    });
    try {
      final url = ApiHelper.getVehicleTacking(); // Get the URL
      print("API URL: $url"); // Debug: Print the URL

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _allVehicles = data
              .map<Map<String, dynamic>>((vehicle) => {
                    'vehicleNumber': vehicle['vehicleNumber'],
                    'details': vehicle,
                  })
              .toList();
        });
      } else {
        throw Exception("Failed to load vehicle numbers");
      }
    } catch (e) {
      print("Error fetching vehicles: $e");
    } finally {
      setState(() {
        isLoadingAllVehiclesData = false;
      });
    }
  }

// Fetch vehicle data from the backend API
  Future<List<Map<String, dynamic>>> _fetchSuggestions(String pattern) async {
    try {
      final response = await http.get(Uri.parse(ApiHelper.getVehicleTacking()));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Filter the vehicle list by the search pattern
        return data
            .where((vehicle) => vehicle['vehicleNumber']
                .toString()
                .toLowerCase()
                .contains(pattern.toLowerCase()))
            .map<Map<String, dynamic>>((vehicle) => {
                  'vehicleNumber': vehicle['vehicleNumber'],
                  'details': vehicle,
                })
            .toList();
      } else {
        throw Exception("Failed to load vehicle numbers");
      }
    } catch (e) {
      print("Error fetching suggestions: $e");
      return [];
    }
  }

  Widget _buildVehicleDetailsCard() {
    if (_selectedVehicleDetails == null) {
      // Show all vehicle data in a scrollable list
      return Expanded(
        child: ListView.builder(
          itemCount: _allVehicles.length,
          itemBuilder: (context, index) {
            final vehicle = _allVehicles[index]['details'];
            return _buildVehicleCard(vehicle);
          },
        ),
      );
    }

    // Show selected vehicle details
    return _buildVehicleCard(_selectedVehicleDetails!);
  }

  // this is used to without stepper

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    // Define status messages based on the status code
    String getStatusMessage(int status) {
      switch (status) {
        case 0:
          return "Waiting for Export Approval";
        case 1:
          return "Waiting for Main Gate In";
        case 2:
          return "Waiting for Fire Gate In";
        case 3:
          return "Waiting for FG In";
        case 4:
          return "Waiting for FG Out";
        case 5:
          return "Waiting for Fire Gate Out";
        case 6:
          return "Waiting for Main Gate Out";
        default:
          return "Unknown Status";
      }
    }

    // Safely parse the status as an integer
    int status;
    try {
      status = int.parse(vehicle['status'].toString());
    } catch (e) {
      status = -1; // Use -1 as a fallback for unknown status
    }

    String statusMessage = getStatusMessage(status);

    return GestureDetector(
      onTap: () {
        // Navigate to the GMS files page and pass the vehicle ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                // GmsFilesPage(vehicleId: vehicle['id'].toString()),
                VehicleIdDetailsGmsPage(vehicleId: vehicle['id'].toString()),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow("Vehicle ID:", vehicle['id'].toString()),
              const SizedBox(height: 8),
              _buildRow("Vehicle Number:", vehicle['vehicleNumber'].toString()),
              const SizedBox(height: 8),
              _buildRow("Status:", statusMessage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("GMS Tracking Page"),
      //   backgroundColor: Colors.greenAccent,
      //   elevation: 4.0,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            isLoadingAllVehiclesData
                ? Center(child: CircularProgressIndicator())
                : Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: DropDownSearchField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller:
                            _vehicleTrackController, // Attach the controller
                        autofocus: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Search Vehicle Number",
                          suffixIcon: Icon(Icons.search),
                        ),
                        onChanged: (text) {
                          setState(() {
                            if (text.isEmpty) {
                              // If search field is cleared, show all vehicles
                              _selectedVehicleDetails =
                                  null; // Reset selected vehicle details
                            }
                          });
                        },
                      ),
                      suggestionsCallback: (pattern) async {
                        if (pattern.isEmpty) {
                          // Return all vehicles if search field is empty
                          return _allVehicles;
                        }
                        return await _fetchSuggestions(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: const Icon(Icons.directions_car),
                          title: Text(suggestion['vehicleNumber']),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        setState(() {
                          _selectedVehicleNumber = suggestion['vehicleNumber'];
                          _vehicleTrackController.text =
                              _selectedVehicleNumber!;
                          _selectedVehicleDetails = suggestion['details'];
                        });
                        print("Selected Vehicle: $_selectedVehicleNumber");
                      },
                      displayAllSuggestionWhenTap: true,
                      isMultiSelectDropdown: false,
                    ),
                  ),
            const SizedBox(height: 20),
            _buildVehicleDetailsCard(),
          ],
        ),
      ),
    );
  }
}
