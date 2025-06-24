import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MaxkingExportApprove extends StatefulWidget {
  final int vehicleID;

  const MaxkingExportApprove({super.key, required this.vehicleID});

  @override
  _MaxkingExportApproveState createState() => _MaxkingExportApproveState();
}

class _MaxkingExportApproveState extends State<MaxkingExportApprove> {
  bool _isLoading = true;
  VehicleDetailsModel? _vehicle;

  @override
  void initState() {
    super.initState();
    fetchVehicleDetails(widget.vehicleID);
  }

  Future<void> fetchVehicleDetails(int vehicleID) async {
    final uri = Uri.parse('${ApiHelper.maxkingGMSUrl}ExportArrovals?id=$vehicleID');

    print('vehicles apis $uri');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Debug statement

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('details') &&
            jsonResponse['details'] is List) {
          final List<dynamic> detailsJson = jsonResponse['details'];
          if (detailsJson.isNotEmpty) {
            setState(() {
              _vehicle = VehicleDetailsModel.fromJson(detailsJson[0]);
              _isLoading = false;
            });
          } else {
            print('Details array is empty');
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          print('Key "details" not found or not a list in JSON response');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print(
            'Failed to load vehicle details, status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching vehicle details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showApprovalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Approval"),
          content: const Text("Are you sure you want to approve this vehicle?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Approve"),
              onPressed: () {
                Navigator.of(context).pop();
                approveVehicle(context, widget.vehicleID);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> approveVehicle(BuildContext context, int vehicleID) async {
    try {
      final uri = Uri.parse('${ApiHelper.maxkingGMSUrl}Approve?id=$vehicleID');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('ApprovalVehicle: $uri');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Success"),
                content: const Text("Vehicle approved successfully"),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.of(context)
                          .pop(true); // Go back and refresh previous screen
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: const Text(
                    "Failed to approve the vehicle, please try again!"),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error approving vehicle: $e');
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content:
                  const Text("An unexpected error occurred, please try again!"),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicle Details"),
        centerTitle: true,
        // backgroundColor: Colors.green[700],
         backgroundColor: Colors.lightGreen,
        
        elevation: 5,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.green,
        textColor: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        onPressed: _showApprovalDialog,
        // onPressed: () {
        //   approveVehicle(context, widget.vehicleID);
        // },
        child: const Text(
          "Approve",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 5,
                      shadowColor: Colors.green[200],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailText(
                                "Vehicle ID", _vehicle!.id.toString()),
                            _buildDetailText("Vehicle No", _vehicle!.vehicleNo),
                            _buildDetailText(
                                "Carrier Book No", _vehicle!.carrierBookNo),
                            _buildDetailText("Container Number",
                                _vehicle!.containerNumberIN),
                            _buildDetailText(
                                "Linear Seal", _vehicle!.linearSeal),
                            _buildDetailText("RC Number", _vehicle!.rcnumber),
                            _buildDetailText(
                                "Driver Name", _vehicle!.driverNameIN),
                            _buildDetailText(
                                "License Number", _vehicle!.licenseNumberIN),
                            _buildDetailText(
                                "Driver Mobile No", _vehicle!.driverMobileNo),
                            _buildDetailText("Arrival Time",
                                _vehicle!.arrivalTime.toString()),
                            _buildDetailText(
                                "Vehicle Type", _vehicle!.vehicleTypeIN),
                            _buildDetailText("Created By", _vehicle!.createdBy),
                            _buildDetailText("Ship Mode", _vehicle!.shipMode),
                            _buildDetailText("Created Date",
                                _vehicle!.createdDate.toString()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class VehicleDetailsModel {
  final int id;
  final String vehicleNo;
  final String carrierBookNo;
  final String containerNumberIN;
  final String linearSeal;
  final String rcnumber;
  final String driverNameIN;
  final String licenseNumberIN;
  final String driverMobileNo;
  final DateTime arrivalTime;
  final String vehicleTypeIN;
  final String createdBy;
  final String shipMode;
  final DateTime createdDate;

  VehicleDetailsModel({
    required this.id,
    required this.vehicleNo,
    required this.carrierBookNo,
    required this.containerNumberIN,
    required this.linearSeal,
    required this.rcnumber,
    required this.driverNameIN,
    required this.licenseNumberIN,
    required this.driverMobileNo,
    required this.arrivalTime,
    required this.vehicleTypeIN,
    required this.createdBy,
    required this.shipMode,
    required this.createdDate,
  });

  factory VehicleDetailsModel.fromJson(Map<String, dynamic> json) {
    return VehicleDetailsModel(
      id: json['id'],
      vehicleNo: json['vehicleNo'],
      carrierBookNo: json['carrier_bookNo'],
      containerNumberIN: json['container_Number_IN'],
      linearSeal: json['linear_Seal'],
      rcnumber: json['rcnumber'],
      driverNameIN: json['driverName_IN'],
      licenseNumberIN: json['licenseNumber_IN'],
      driverMobileNo: json['driverMobileNo'],
      arrivalTime: DateTime.parse(json['arrivalTime']),
      vehicleTypeIN: json['vehicle_Type_IN'],
      createdBy: json['createdBy'],
      shipMode: json['ship_Mode'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}
