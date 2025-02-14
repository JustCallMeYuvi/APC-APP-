import 'package:animated_movies_app/screens/home_screen/patrolling_details_page.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

// Assuming LoginModelApi is already defined somewhere in your project
class PatrollingScreen extends StatefulWidget {
  final LoginModelApi userData; // Pass userData with empNo

  const PatrollingScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _PatrollingScreenState createState() => _PatrollingScreenState();
}

class _PatrollingScreenState extends State<PatrollingScreen> {
  String _scanResult = "No data scanned";
  String _selectedPatrolling = "Patrolling 1"; // Default value
  String _selectedShift = 'Shift A'; // Set default value

  Future<void> _startScan() async {
    // Request camera permission if not already granted
    if (await Permission.camera.request().isGranted) {
      try {
        // Start the QR code scan
        String scanResult = await FlutterBarcodeScanner.scanBarcode(
            '#FF6666', // Line color
            'Cancel', // Cancel button text
            true, // Show flash button
            ScanMode.QR // QR scan mode
            );

        if (!mounted) return;

        setState(() {
          _scanResult = scanResult != '-1' ? scanResult : "Scan cancelled";
        });
      } catch (e) {
        setState(() {
          _scanResult = "Failed to scan QR code.";
        });
      }
    } else {
      setState(() {
        _scanResult = "Camera permission denied";
      });
    }
  }

  Future<void> _submitScanData() async {
    const String apiUrl = "http://10.3.0.70:8088/api/PS_MAP/SCANNED_QR_DATA";
    String longitude = '';
    String latitude = '';
    String locationName = '';

    // Parse _scanResult
    final parts = _scanResult.split('\n');
    for (var part in parts) {
      if (part.contains('Longitude:')) {
        longitude = part.split(':')[1].trim();
      } else if (part.contains('Latitude:')) {
        latitude = part.split(':')[1].trim();
      } else if (part.contains('Location:')) {
        locationName = part.split(':')[1].trim();
      }
    }

    if (longitude.isEmpty || latitude.isEmpty || locationName.isEmpty) {
      setState(() {
        _scanResult = "Failed to parse scan data.";
      });
      return;
    }

    // Prepare parameters with parsed values
    final Map<String, String> queryParams = {
      'longitude': longitude,
      'latitude': latitude,
      'locationName': locationName,
      'userId': widget.userData.empNo,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl).replace(queryParameters: queryParams),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          _scanResult = "Data submitted successfully.";
        });
      } else {
        setState(() {
          _scanResult =
              "Failed to submit data. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _scanResult = "Error submitting data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dropdown Button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPatrolling,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPatrolling = newValue!;
                      });
                    },
                    items: <String>[
                      'Patrolling 1',
                      'Patrolling 2',
                      'Patrolling 3'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.green),
                    dropdownColor: Colors.white,
                    isExpanded: true,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Dropdown Button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedShift,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedShift = newValue!;
                      });
                    },
                    items: <String>[
                      'Shift A',
                      'Shift B',
                      'Shift C',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.green),
                    dropdownColor: Colors.white,
                    isExpanded: true,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              // MaterialButton(
              //   onPressed: () {
              //     // Navigator.push(
              //     //   context,
              //     //   MaterialPageRoute(
              //     //       builder: (context) => PatrollingDetailsPage(
              //     //             selectedPatrolling: _selectedPatrolling,
              //     //             userData: widget.userData,
              //     //           )),
              //     // );
              //   },
              //   color: Colors.blue, // Background color
              //   textColor: Colors.white, // Text color
              //   padding: EdgeInsets.symmetric(
              //       vertical: 12.0, horizontal: 24.0), // Button padding
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(30), // Rounded corners
              //   ),
              //   elevation: 8, // Shadow effect
              //   highlightElevation: 12, // Elevation when button is pressed
              //   splashColor:
              //       Colors.blueAccent.withOpacity(0.3), // Splash effect on tap
              //   child: Text(
              //     'Start',
              //     style: TextStyle(
              //       fontSize: 16, // Text size
              //       fontWeight: FontWeight.bold, // Bold text
              //     ),
              //   ),
              // ),

              // const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _startScan,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Open Camera to Scan QR Code"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.lightGreen,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Scan Result:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _scanResult,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                onPressed: _scanResult != "No data scanned" &&
                        _scanResult != "Scan cancelled"
                    ? _submitScanData
                    : null,
                icon: const Icon(Icons.upload),
                label: const Text("Submit Scan Data"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Point the camera at a QR code on another device or paper",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
