import 'dart:convert';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/services/patrollin_api_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class PatrollingProvider extends ChangeNotifier {
  String _scanResult = "No data scanned";
  String _selectedPatrolling = "";
  String _selectedShift = '';
  bool _isSubmitting = false;
  String? _scannedId; // Store extracted ID

  String get scanResult => _scanResult;
  String get selectedPatrolling => _selectedPatrolling;
  String get selectedShift => _selectedShift;
  bool get isSubmitting => _isSubmitting;

  void setSelectedPatrolling(String value) {
    _selectedPatrolling = value;
    notifyListeners();
  }

  void setSelectedShift(String value) {
    _selectedShift = value;
    notifyListeners();
  }

  // Clear scan result on screen close
  void clearScanResult() {
    _scanResult = "No data scanned"; // ✅ Directly assign to _scanResult
    notifyListeners();
  }

  Future<void> startScan(String userId) async {
    if (await Permission.camera.request().isGranted) {
      try {
        String scanResult = await FlutterBarcodeScanner.scanBarcode(
            '#FF6666', 'Cancel', true, ScanMode.QR);

        if (scanResult != '-1') {
          _scanResult = scanResult;
          // After scanning, automatically call API
          await savePatrollingData(scanResult, userId);
        } else {
          _scanResult = "Scan cancelled";
        }
      } catch (e) {
        _scanResult = "Failed to scan QR code.";
      }
    } else {
      _scanResult = "Camera permission denied";
    }
    notifyListeners();
  }

  // Future<void> savePatrollingData(String scannedValue, String userId) async {
  //   _isSubmitting = true;
  //   notifyListeners();

  //   // final apiUrl =
  //   //     '${ApiHelper.gmsUrl}SavePatrolling?userid=67657&patrollintype=${Uri.encodeComponent(selectedPatrolling)}&shift=${Uri.encodeComponent(selectedShift)}&value=$scannedValue';
  //   final apiUrl = '${ApiHelper.gmsUrl}SavePatrolling'
  //       '?userid=$userId'
  //       '&patrollintype=${Uri.encodeComponent(selectedPatrolling)}'
  //       '&shift=${Uri.encodeComponent(selectedShift)}'
  //       '&value=$scannedValue';

  //   print(apiUrl);
  //   try {
  //     final response = await http.post(Uri.parse(apiUrl));
  //     print(response.body);
  //     if (response.statusCode == 200) {
  //       // Extract ID from response
  //       // Decode the JSON response before using it
  //       final Map<String, dynamic> responseData = jsonDecode(response.body);
  //       if (responseData['data'] != null &&
  //           responseData['data']['data'] != null) {
  //         List<dynamic> dataList = responseData['data']['data'];
  //         if (dataList.isNotEmpty) {
  //           _scannedId = dataList[0]['id']; // Store the extracted ID
  //           print("Extracted ID: $_scannedId");
  //         }
  //       }

  //       _scanResult = ('API Response: ${response.body}');
  //     } else {
  //       _scanResult =
  //           ('Failed to save patrolling data (Code: ${response.statusCode})');
  //     }
  //   } catch (e) {
  //     _scanResult = ('Error calling API: $e');
  //   } finally {
  //     _isSubmitting = false;
  //     notifyListeners();
  //   }
  // }

//   Future<void> savePatrollingData(String scannedValue, String userId) async {
//   _isSubmitting = true;
//   notifyListeners();

//   final apiUrl = '${ApiHelper.gmsUrl}SavePatrolling'
//       '?userid=$userId'
//       '&patrollintype=${Uri.encodeComponent(selectedPatrolling)}'
//       '&shift=${Uri.encodeComponent(selectedShift)}'
//       '&value=$scannedValue';

//   print(apiUrl);
//   // try {
//   //   final response = await http.post(Uri.parse(apiUrl));
//   //   print(response.body);
    
//   //   if (response.statusCode == 200) {
//   //     final patrollingData = patrollingApiDataFromJson(response.body);

//   //     if (patrollingData.data.data.isNotEmpty) {
//   //       _scannedId = patrollingData.data.data[0].id; // Extract ID from first item
//   //       print("Extracted ID: $_scannedId");
//   //     }

//   //     _scanResult = 'API Response: ${response.body}';
//   //   } else {
//   //     _scanResult = 'Failed to save patrolling data (Code: ${response.statusCode})';
//   //   }
//   // } catch (e) {
//   //   _scanResult = 'Error calling API: $e';
//   // } finally {
//   //   _isSubmitting = false;
//   //   notifyListeners();
//   // }
  

//   try {
//   final response = await http.post(Uri.parse(apiUrl));
//   print("API Response: ${response.body}");
//      // ✅ Moved response validation **after** the API call
//     if (!response.body.startsWith('{') && !response.body.startsWith('[')) {
//       print("Received non-JSON response: ${response.body}");
//       _scanResult = "Unexpected response format. Check API.";
//       return;
//     }


//   if (response.statusCode == 200) {
//     try {
//       final patrollingData = patrollingApiDataFromJson(response.body);
//       if (patrollingData.data.data.isNotEmpty) {
//         _scannedId = patrollingData.data.data[0].id;
//         print("Extracted ID: $_scannedId");
//       }
//       _scanResult = 'API Response: ${response.body}';
//     } catch (e) {
//       print("JSON Decoding Error: $e");
//       _scanResult = "Invalid JSON format received from API.";
//     }
//   } else {
//     _scanResult = 'Failed to save patrolling data (Code: ${response.statusCode})';
//   }
// } catch (e) {
//   _scanResult = 'Error calling API: $e';
// }
// }


Future<void> savePatrollingData(String scannedValue, String userId) async {
  _isSubmitting = true;
  notifyListeners();

  final apiUrl = '${ApiHelper.gmsUrl}SavePatrolling'
      '?userid=$userId'
      '&patrollintype=${Uri.encodeComponent(selectedPatrolling)}'
      '&shift=${Uri.encodeComponent(selectedShift)}'
      '&value=$scannedValue';

  print("API URL: $apiUrl");

  try {
    final response = await http.post(Uri.parse(apiUrl));
    print("API Response: ${response.body}");

    if (response.statusCode != 200) {
      _scanResult = 'Failed to save patrolling data (Code: ${response.statusCode})';
      return;
    }

    // Validate response format before parsing
    final dynamic jsonResponse = json.decode(response.body);
    
    if (jsonResponse is! Map<String, dynamic>) {
      print("Unexpected JSON format: $jsonResponse");
      _scanResult = "Unexpected response format. Check API.";
      return;
    }

    final patrollingData = PatrollingApiData.fromJson(jsonResponse);

    if (patrollingData.data.data.isNotEmpty) {
      _scannedId = patrollingData.data.data[0].id;
      print("Extracted ID: $_scannedId");
    }

    _scanResult = 'API Response: ${response.body}';
  } catch (e) {
    print("Error parsing JSON: $e");
    _scanResult = 'Error calling API: $e';
  } finally {
    _isSubmitting = false;
    notifyListeners();
  }
}

  Future<void> submitPatrollingComplete(BuildContext context) async {
    if (_scannedId == null) {
      _scanResult = "No valid ID found for submission.";
      notifyListeners();
      return;
    }

    final apiUrl = '${ApiHelper.gmsUrl}PatrollingComplete?id=$_scannedId';

    try {
      final response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        _scanResult = 'Patrolling Completed Successfully!';
        _showSuccessDialog(context, _scanResult);
      } else {
        _scanResult =
            'Failed to complete patrolling (Code: ${response.statusCode})';
        _showErrorDialog(context, _scanResult);
      }
    } catch (e) {
      _scanResult = 'Error submitting completion: $e';
      _showErrorDialog(context, _scanResult);
    }
    notifyListeners();
  }

// Show Success Dialog
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

// Show Error Dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> submitScanData(String empNo) async {
  //   const String apiUrl = "http://10.3.0.70:8088/api/PS_MAP/SCANNED_QR_DATA";

  //   String longitude = '';
  //   String latitude = '';
  //   String locationName = '';

  //   final parts = _scanResult.split('\n');
  //   for (var part in parts) {
  //     if (part.contains('Longitude:')) {
  //       longitude = part.split(':')[1].trim();
  //     } else if (part.contains('Latitude:')) {
  //       latitude = part.split(':')[1].trim();
  //     } else if (part.contains('Location:')) {
  //       locationName = part.split(':')[1].trim();
  //     }
  //   }

  //   if (longitude.isEmpty || latitude.isEmpty || locationName.isEmpty) {
  //     _scanResult = "Failed to parse scan data.";
  //     notifyListeners();
  //     return;
  //   }

  //   final Map<String, String> queryParams = {
  //     'longitude': longitude,
  //     'latitude': latitude,
  //     'locationName': locationName,
  //     'userId': empNo,
  //   };

  //   _isSubmitting = true;
  //   notifyListeners();

  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl).replace(queryParameters: queryParams),
  //       headers: {"Content-Type": "application/json"},
  //     );

  //     if (response.statusCode == 200) {
  //       _scanResult = "Data submitted successfully.";
  //     } else {
  //       _scanResult = "Failed to submit data. Status code: ${response.statusCode}";
  //     }
  //   } catch (e) {
  //     _scanResult = "Error submitting data: $e";
  //   } finally {
  //     _isSubmitting = false;
  //     notifyListeners();
  //   }
  // }
}
