import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class PatrollingProvider extends ChangeNotifier {
  String _scanResult = "No data scanned";
  String _selectedPatrolling = "";
  String _selectedShift = '';
  bool _isSubmitting = false;

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

  Future<void> startScan() async {
    if (await Permission.camera.request().isGranted) {
      try {
        String scanResult = await FlutterBarcodeScanner.scanBarcode(
            '#FF6666', 'Cancel', true, ScanMode.QR);

        if (scanResult != '-1') {
          _scanResult = scanResult;
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

  Future<void> submitScanData(String empNo) async {
    const String apiUrl = "http://10.3.0.70:8088/api/PS_MAP/SCANNED_QR_DATA";

    String longitude = '';
    String latitude = '';
    String locationName = '';

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
      _scanResult = "Failed to parse scan data.";
      notifyListeners();
      return;
    }

    final Map<String, String> queryParams = {
      'longitude': longitude,
      'latitude': latitude,
      'locationName': locationName,
      'userId': empNo,
    };

    _isSubmitting = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(apiUrl).replace(queryParameters: queryParams),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        _scanResult = "Data submitted successfully.";
      } else {
        _scanResult = "Failed to submit data. Status code: ${response.statusCode}";
      }
    } catch (e) {
      _scanResult = "Error submitting data: $e";
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
