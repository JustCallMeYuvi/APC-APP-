import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class PatrollingController extends GetxController {
  var selectedPatrolling = Rx<String>(""); // Default empty value
  var selectedShift = Rx<String>(""); // Default empty value
  var scanResult = Rx<String>("No data scanned"); // Default text
  var isSubmitting = RxBool(false); // Default false

  void setSelectedPatrolling(String value) {
    selectedPatrolling.value = value;
  }

  void setSelectedShift(String value) {
    selectedShift.value = value;
  }

  Future<void> startScan() async {
    if (await Permission.camera.request().isGranted) {
      try {
        String result = await FlutterBarcodeScanner.scanBarcode(
            '#FF6666', 'Cancel', true, ScanMode.QR);
        scanResult.value = result != '-1' ? result : "Scan cancelled";
      } catch (e) {
        scanResult.value = "Failed to scan QR code.";
      }
    } else {
      scanResult.value = "Camera permission denied";
    }
  }

  Future<void> submitScanData(String empNo) async {
    const String apiUrl = "http://10.3.0.70:8088/api/PS_MAP/SCANNED_QR_DATA";

    String longitude = '', latitude = '', locationName = '';

    final parts = scanResult.value.split('\n');
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
      scanResult.value = "Failed to parse scan data.";
      return;
    }

    final Map<String, String> queryParams = {
      'longitude': longitude,
      'latitude': latitude,
      'locationName': locationName,
      'userId': empNo,
    };

    isSubmitting.value = true;

    try {
      final response = await http.post(
        Uri.parse(apiUrl).replace(queryParameters: queryParams),
        headers: {"Content-Type": "application/json"},
      );

      scanResult.value = response.statusCode == 200
          ? "Data submitted successfully."
          : "Failed to submit data. Status: ${response.statusCode}";
    } catch (e) {
      scanResult.value = "Error submitting data: $e";
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearData() {
    selectedPatrolling.value = '';
    selectedShift.value = '';
    scanResult.value = 'No data scanned';
  }
}
