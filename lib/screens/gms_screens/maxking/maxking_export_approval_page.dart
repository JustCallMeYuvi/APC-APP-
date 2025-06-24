import 'dart:convert';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/gms_screens/export_approval.dart';
import 'package:animated_movies_app/screens/gms_screens/maxking/maxking_export_approve.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MaxkingExportApprovalPage extends StatefulWidget {
  final String title;

  const MaxkingExportApprovalPage({super.key, required this.title});

  @override
  State<MaxkingExportApprovalPage> createState() =>
      _MaxkingExportApprovalPageState();
}

class _MaxkingExportApprovalPageState extends State<MaxkingExportApprovalPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isLoading = true;
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _filteredVehicles = [];
  // ApiHandler apiHandler = ApiHandler();
  String? _noVehiclesMessage; // null by default

  @override
  void initState() {
    super.initState();
    // _allVehicles = [];
    // _filteredVehicles = [];
    fetchVehiclesFromAPI();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _filteredVehicles = _allVehicles
            .where((vehicle) =>
                vehicle.vehicleID.toString().contains(_searchQuery) ||
                vehicle.vehicleNo
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                vehicle.createdBy
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();
      });
    });
  }

  // Future<void> fetchVehiclesFromAPI() async {
  //   setState(() {
  //     _isLoading = true; // Show loading state
  //   });

  //   try {
  //     final url = Uri.parse('${ApiHelper.maxkingGMSUrl}GMS_ExportVehicles');
  //     print('vehicles api $url');

  //     final response = await http.get(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     print('Response Status: ${response.statusCode}');
  //     print('Response Body: ${response.body}'); // Debugging output

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);

  //       // Extract the list of vehicles
  //       if (jsonResponse.containsKey('vehicles') &&
  //           jsonResponse['vehicles'] is List) {
  //         final List<dynamic> vehiclesJson = jsonResponse['vehicles'];

  //         List<Vehicle> vehicles =
  //             vehiclesJson.map((data) => Vehicle.fromJson(data)).toList();
  //         print('vehicles List: $vehicles');

  //         setState(() {
  //           _allVehicles = vehicles;
  //           _filteredVehicles = _allVehicles;
  //           _isLoading = false;
  //         });
  //       }
  //       else if (response.body.contains("No vehicles found")) {
  //         // Handle case where no vehicles are found
  //         setState(() {
  //           _allVehicles = [];
  //           _filteredVehicles = [];
  //           _isLoading = false;
  //         });
  //         // Optionally show a message that no vehicles are found (using a snackbar, alert, etc.)
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("No vehicles found.")),
  //         );
  //       }
  //     } else {
  //       throw Exception(
  //           'Failed to load vehicles. Status Code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching vehicles: $e');
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> fetchVehiclesFromAPI() async {
    setState(() {
      _isLoading = true;
      _noVehiclesMessage = null;
    });

    try {
      final url = Uri.parse('${ApiHelper.maxkingGMSUrl}GMS_ExportVehicles');
      print('vehicles api $url');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('vehicles') &&
            jsonResponse['vehicles'] is List) {
          final List<dynamic> vehiclesJson = jsonResponse['vehicles'];

          List<Vehicle> vehicles =
              vehiclesJson.map((data) => Vehicle.fromJson(data)).toList();
          print('vehicles List: $vehicles');

          setState(() {
            _allVehicles = vehicles;
            _filteredVehicles = _allVehicles;
            _isLoading = false;
          });
        } else {
          setState(() {
            _allVehicles = [];
            _filteredVehicles = [];
            _noVehiclesMessage = "No vehicles found.";
            _isLoading = false;
          });
        }
      } else {
        // ✅ Parse response and extract message for status 404 or other errors
        try {
          final Map<String, dynamic> errorResponse = json.decode(response.body);
          final message = errorResponse['message'] ?? 'Error loading vehicles.';
          setState(() {
            _noVehiclesMessage = message;
            _allVehicles = [];
            _filteredVehicles = [];
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            _noVehiclesMessage = 'Error loading vehicles.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
      setState(() {
        _noVehiclesMessage = "Error loading vehicles.";
        _isLoading = false;
      });
    }
  }

  Future<void> refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await fetchVehiclesFromAPI();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      //   centerTitle: true,
      //   backgroundColor: const Color.fromARGB(255, 15, 201, 39),
      // ),
      //     body: Stack(
      //   children: [
      //     RefreshIndicator(
      //       onRefresh: refreshData,
      //       child: Padding(
      //         padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      //         child: Column(
      //           children: [
      //             const SizedBox(
      //               height: 15,
      //             ),
      //             TextField(
      //               controller: _searchController,
      //               decoration: InputDecoration(
      //                 hintText: "Search for a Vehicle...",
      //                 prefixIcon: const Icon(Icons.search),
      //                 suffixIcon: IconButton(
      //                   icon: const Icon(Icons.clear),
      //                   onPressed: () {
      //                     _searchController.clear();
      //                     setState(() {
      //                       _filteredVehicles = _allVehicles;
      //                     });
      //                   },
      //                 ),
      //                 border: OutlineInputBorder(
      //                   borderRadius: BorderRadius.circular(10.0),
      //                 ),
      //               ),
      //             ),
      //             const SizedBox(height: 15),
      //             _isLoading
      //                 ? const Center(child: CircularProgressIndicator())
      //                 : Expanded(
      //                     child: ListView.builder(
      //                       itemCount: _filteredVehicles.length,
      //                       itemBuilder: (context, index) {
      //                         return GestureDetector(
      //                           onTap: () async {
      //                             final result = await Navigator.push(
      //                               context,
      //                               MaterialPageRoute(
      //                                 builder: (context) => MaxkingExportApprove(
      //                                     vehicleID:
      //                                         _filteredVehicles[index].vehicleID),
      //                               ),
      //                             );
      //                             if (result == true) {
      //                               setState(() {
      //                                 _isLoading = true;
      //                               });
      //                               await Future.delayed(
      //                                 const Duration(seconds: 2),
      //                               );
      //                               setState(() {
      //                                 _isLoading = false;
      //                               });
      //                               fetchVehiclesFromAPI();
      //                             }
      //                           },
      //                           child: Container(
      //                             margin: const EdgeInsets.only(bottom: 10),
      //                             padding: const EdgeInsets.all(10),
      //                             decoration: BoxDecoration(
      //                                 color: const Color.fromARGB(
      //                                     255, 248, 244, 244),
      //                                 border: Border.all(color: Colors.grey),
      //                                 borderRadius: BorderRadius.circular(10),
      //                                 boxShadow: const [
      //                                   BoxShadow(
      //                                     color: Color.fromARGB(
      //                                         255, 151, 150, 150),
      //                                     blurRadius: 5.0,
      //                                     spreadRadius: 0.0,
      //                                     offset: Offset(0, 5),
      //                                   )
      //                                 ]),
      //                             child: Column(
      //                               crossAxisAlignment: CrossAxisAlignment.start,
      //                               children: [
      //                                 Row(
      //                                   mainAxisAlignment:
      //                                       MainAxisAlignment.spaceBetween,
      //                                   children: [
      //                                     const Text(
      //                                       "Vehicle ID",
      //                                       style: TextStyle(
      //                                         fontWeight: FontWeight.bold,
      //                                         fontSize: 16,
      //                                         color: Colors.blue,
      //                                       ),
      //                                     ),
      //                                     Text(
      //                                       "${_filteredVehicles[index].vehicleID}",
      //                                       style: const TextStyle(fontSize: 16),
      //                                     )
      //                                   ],
      //                                 ),
      //                                 Row(
      //                                   mainAxisAlignment:
      //                                       MainAxisAlignment.spaceBetween,
      //                                   children: [
      //                                     const Text(
      //                                       "Vehicle No",
      //                                       style: TextStyle(
      //                                         fontWeight: FontWeight.bold,
      //                                         fontSize: 16,
      //                                         color: Colors.blue,
      //                                       ),
      //                                     ),
      //                                     Text(
      //                                       "${_filteredVehicles[index].vehicleNo}",
      //                                       style: const TextStyle(fontSize: 16),
      //                                     )
      //                                   ],
      //                                 ),
      //                                 Row(
      //                                   mainAxisAlignment:
      //                                       MainAxisAlignment.spaceBetween,
      //                                   children: [
      //                                     const Text(
      //                                       "CHA",
      //                                       style: TextStyle(
      //                                         fontWeight: FontWeight.bold,
      //                                         fontSize: 16,
      //                                         color: Colors.blue,
      //                                       ),
      //                                     ),
      //                                     Text(
      //                                       "${_filteredVehicles[index].createdBy}",
      //                                       style: const TextStyle(fontSize: 16),
      //                                     )
      //                                   ],
      //                                 ),
      //                               ],
      //                             ),
      //                           ),
      //                         );
      //                       },
      //                     ),
      //                   ),
      //           ],
      //         ),
      //       ),
      //     )
      //   ],
      // )

      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: refreshData,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search for a Vehicle...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _filteredVehicles = _allVehicles;
                            _noVehiclesMessage = null;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_noVehiclesMessage != null)
                    Expanded(
                      child: Center(
                        child: Text(
                          _noVehiclesMessage!,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else if (_filteredVehicles.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          "No vehicles to display.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredVehicles.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MaxkingExportApprove(
                                      vehicleID:
                                          _filteredVehicles[index].vehicleID),
                                ),
                              );
                              if (result == true) {
                                setState(() => _isLoading = true);
                                await Future.delayed(
                                    const Duration(seconds: 2));
                                fetchVehiclesFromAPI();
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 248, 244, 244),
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 151, 150, 150),
                                    blurRadius: 5.0,
                                    offset: Offset(0, 5),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRow(
                                      "Vehicle ID",
                                      _filteredVehicles[index]
                                          .vehicleID
                                          .toString()),
                                  _buildRow("Vehicle No",
                                      _filteredVehicles[index].vehicleNo),
                                  _buildRow("CHA",
                                      _filteredVehicles[index].createdBy),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
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
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
        ),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

class Vehicle {
  final int vehicleID;
  final String vehicleNo;
  final String createdBy;

  Vehicle({
    required this.vehicleID,
    required this.vehicleNo,
    required this.createdBy,
  });

  // // Factory method to create a Vehicle object from JSON
  // factory Vehicle.fromJson(Map<String, dynamic> json) {
  //   return Vehicle(
  //     vehicleID: json['vehicleID'],
  //     vehicleNo: json['vehicleNo'],
  //     createdBy: json['createdBy'],
  //   );
  // }

  // Factory method to create a Vehicle object from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleID: json['id'], // Match the 'id' key from the JSON
      vehicleNo: json['truckno'], // Match the 'truckno' key from the JSON
      createdBy: json['createdBy'], // Match the 'createdBy' key from the JSON
    );
  }
}
