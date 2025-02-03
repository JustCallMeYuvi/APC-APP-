import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class PatrollingDetailsPage extends StatefulWidget {
  final String selectedPatrolling;
  final LoginModelApi userData; // Pass userData with empNo

  const PatrollingDetailsPage(
      {Key? key, required this.selectedPatrolling, required this.userData})
      : super(key: key);

  @override
  State<PatrollingDetailsPage> createState() => _PatrollingDetailsPageState();
}

class _PatrollingDetailsPageState extends State<PatrollingDetailsPage> {
  String _scanResult = "No data scanned";

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
      appBar: AppBar(
        title: Text(widget.selectedPatrolling),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${widget.userData.empNo} Has started",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _startScan,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Scan QR Code",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Scan Result:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _scanResult,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: _scanResult != "No data scanned" &&
                      _scanResult != "Scan cancelled"
                  ? _submitScanData
                  : null,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Submit Data",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Point the camera at a QR code to scan",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
