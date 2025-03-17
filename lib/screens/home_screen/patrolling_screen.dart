// import 'package:animated_movies_app/screens/home_screen/patrolling_details_page.dart';
// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;

// // Assuming LoginModelApi is already defined somewhere in your project
// class PatrollingScreen extends StatefulWidget {
//   final LoginModelApi userData; // Pass userData with empNo

//   const PatrollingScreen({Key? key, required this.userData}) : super(key: key);

//   @override
//   _PatrollingScreenState createState() => _PatrollingScreenState();
// }

// class _PatrollingScreenState extends State<PatrollingScreen> {
//   String _scanResult = "No data scanned";
//   String _selectedPatrolling = "Patrolling 1"; // Default value
//   String _selectedShift = 'Shift A'; // Set default value

//   Future<void> _startScan() async {
//     // Request camera permission if not already granted
//     if (await Permission.camera.request().isGranted) {
//       try {
//         // Start the QR code scan
//         String scanResult = await FlutterBarcodeScanner.scanBarcode(
//             '#FF6666', // Line color
//             'Cancel', // Cancel button text
//             true, // Show flash button
//             ScanMode.QR // QR scan mode
//             );

//         if (!mounted) return;

//         setState(() {
//           _scanResult = scanResult != '-1' ? scanResult : "Scan cancelled";
//         });
//       } catch (e) {
//         setState(() {
//           _scanResult = "Failed to scan QR code.";
//         });
//       }
//     } else {
//       setState(() {
//         _scanResult = "Camera permission denied";
//       });
//     }
//   }

//   Future<void> _submitScanData() async {
//     const String apiUrl = "http://10.3.0.70:8088/api/PS_MAP/SCANNED_QR_DATA";
//     String longitude = '';
//     String latitude = '';
//     String locationName = '';

//     // Parse _scanResult
//     final parts = _scanResult.split('\n');
//     for (var part in parts) {
//       if (part.contains('Longitude:')) {
//         longitude = part.split(':')[1].trim();
//       } else if (part.contains('Latitude:')) {
//         latitude = part.split(':')[1].trim();
//       } else if (part.contains('Location:')) {
//         locationName = part.split(':')[1].trim();
//       }
//     }

//     if (longitude.isEmpty || latitude.isEmpty || locationName.isEmpty) {
//       setState(() {
//         _scanResult = "Failed to parse scan data.";
//       });
//       return;
//     }

//     // Prepare parameters with parsed values
//     final Map<String, String> queryParams = {
//       'longitude': longitude,
//       'latitude': latitude,
//       'locationName': locationName,
//       'userId': widget.userData.empNo,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl).replace(queryParameters: queryParams),
//         headers: {"Content-Type": "application/json"},
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _scanResult = "Data submitted successfully.";
//         });
//       } else {
//         setState(() {
//           _scanResult =
//               "Failed to submit data. Status code: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _scanResult = "Error submitting data: $e";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             // mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Dropdown Button
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.green, width: 1.5),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.2),
//                       spreadRadius: 2,
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: _selectedPatrolling,
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _selectedPatrolling = newValue!;
//                       });
//                     },
//                     items: <String>[
//                       'Patrolling 1',
//                       'Patrolling 2',
//                       'Patrolling 3'
//                     ].map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(
//                           value,
//                           style: const TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.w500),
//                         ),
//                       );
//                     }).toList(),
//                     icon:
//                         const Icon(Icons.arrow_drop_down, color: Colors.green),
//                     dropdownColor: Colors.white,
//                     isExpanded: true,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               // Dropdown Button
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.green, width: 1.5),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.2),
//                       spreadRadius: 2,
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: _selectedShift,
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _selectedShift = newValue!;
//                       });
//                     },
//                     items: <String>[
//                       'Shift A',
//                       'Shift B',
//                       'Shift C',
//                     ].map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(
//                           value,
//                           style: const TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.w500),
//                         ),
//                       );
//                     }).toList(),
//                     icon:
//                         const Icon(Icons.arrow_drop_down, color: Colors.green),
//                     dropdownColor: Colors.white,
//                     isExpanded: true,
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 height: 10,
//               ),

//               // MaterialButton(
//               //   onPressed: () {
//               //     // Navigator.push(
//               //     //   context,
//               //     //   MaterialPageRoute(
//               //     //       builder: (context) => PatrollingDetailsPage(
//               //     //             selectedPatrolling: _selectedPatrolling,
//               //     //             userData: widget.userData,
//               //     //           )),
//               //     // );
//               //   },
//               //   color: Colors.blue, // Background color
//               //   textColor: Colors.white, // Text color
//               //   padding: EdgeInsets.symmetric(
//               //       vertical: 12.0, horizontal: 24.0), // Button padding
//               //   shape: RoundedRectangleBorder(
//               //     borderRadius: BorderRadius.circular(30), // Rounded corners
//               //   ),
//               //   elevation: 8, // Shadow effect
//               //   highlightElevation: 12, // Elevation when button is pressed
//               //   splashColor:
//               //       Colors.blueAccent.withOpacity(0.3), // Splash effect on tap
//               //   child: Text(
//               //     'Start',
//               //     style: TextStyle(
//               //       fontSize: 16, // Text size
//               //       fontWeight: FontWeight.bold, // Bold text
//               //     ),
//               //   ),
//               // ),

//               // const SizedBox(height: 30),
//               ElevatedButton.icon(
//                 onPressed: _startScan,
//                 icon: const Icon(Icons.camera_alt),
//                 label: const Text("Open Camera to Scan QR Code"),
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   backgroundColor: Colors.lightGreen,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   textStyle: const TextStyle(fontSize: 16),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       spreadRadius: 3,
//                       blurRadius: 5,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Scan Result:',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       _scanResult,
//                       style: const TextStyle(fontSize: 16),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               ElevatedButton.icon(
//                 onPressed: _scanResult != "No data scanned" &&
//                         _scanResult != "Scan cancelled"
//                     ? _submitScanData
//                     : null,
//                 icon: const Icon(Icons.upload),
//                 label: const Text("Submit Scan Data"),
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   backgroundColor: Colors.blueAccent,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   textStyle: const TextStyle(fontSize: 16),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 "Point the camera at a QR code on another device or paper",
//                 style: TextStyle(fontSize: 14, color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:animated_movies_app/screens/home_screen/scan_result_widget.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:animated_movies_app/services/provider_services.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class PatrollingScreen extends StatefulWidget {
  final LoginModelApi userData;

  const PatrollingScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<PatrollingScreen> createState() => _PatrollingScreenState();
}

class _PatrollingScreenState extends State<PatrollingScreen> {
  late TextEditingController patrollingController;
  late TextEditingController shiftController;
  late PatrollingProvider _provider; // Store provider reference
  // bool _cleared = false;
  // @override
  // void initState() {
  //   super.initState();
  //   // Initialize controllers with initial values from provider.
  //   final provider = Provider.of<PatrollingProvider>(context, listen: false);
  //   patrollingController =
  //       TextEditingController(text: provider.selectedPatrolling);
  //   shiftController = TextEditingController(text: provider.selectedShift);
  // }
  @override
  void initState() {
    super.initState();
    patrollingController = TextEditingController();
    shiftController = TextEditingController();
  }

  // @override
  // void dispose() {
  //   patrollingController.dispose();
  //   shiftController.dispose();
  //   super.dispose();
  // }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save provider reference so it's safe to use later
    _provider = Provider.of<PatrollingProvider>(context, listen: false);
    // Optionally, initialize the controllers with current provider values.
    patrollingController.text = _provider.selectedPatrolling;
    shiftController.text = _provider.selectedShift;
  }

  Future<bool> _onWillPop() async {
    // Clear the provider values and controllers before leaving
    _provider.setSelectedPatrolling('');
    _provider.setSelectedShift('');
    patrollingController.clear();
    shiftController.clear();
    // Clear scan result when user presses the back button.
    _provider.clearScanResult();
    return true; // Allow pop
  }

  @override
  void dispose() {
    patrollingController.dispose();
    shiftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatrollingProvider>(context);
    // Define a global variable
    // ScanResultWidget? globalScanResult;

    // // Extract Next Stop Point Name from scanResult JSON
    // String nextStopPointName = "No Next Stop Point";
    // if (provider.scanResult.isNotEmpty) {
    //   try {
    //     final decodedData = jsonDecode(provider.scanResult);
    //     if (decodedData is Map<String, dynamic> &&
    //         decodedData.containsKey("NextStopPoint")) {
    //       nextStopPointName = decodedData["NextStopPoint"];
    //     }
    //   } catch (e) {
    //     print("Error decoding JSON: $e");
    //   }
    // }

    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  buildDropDownSearchField(
                    label: 'Patrolling',
                    value: provider.selectedPatrolling,
                    items: ['Patrolling 1', 'Patrolling 2', 'Patrolling 3'],
                    onChanged: provider.setSelectedPatrolling,
                    controller: patrollingController,
                  ),
                  // Text('Next Stop Point is $provider,'),
                  // Text('Next stop point is'),
                  // Show Next Stop Point Name
                  // Text(
                  //   "Next Stop Point: $nextStopPointName",
                  //   style: const TextStyle(
                  //       fontSize: 18, fontWeight: FontWeight.bold),
                  // ),

                  const SizedBox(height: 10),
                  buildDropDownSearchField(
                    label: 'Shift',
                    value: provider.selectedShift,
                    items: ['Shift A', 'Shift B', 'Shift C'],
                    onChanged: provider.setSelectedShift,
                    controller: shiftController,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    maxLines: 5, // Allows up to 5 lines
                    decoration: const InputDecoration(
                      hintText: "Patrolling Review...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ElevatedButton.icon(
                  //   onPressed: provider.startScan,
                  //   icon: const Icon(Icons.camera_alt),
                  //   label: const Text("Open Camera to Scan QR Code"),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.lightGreen,
                  //     foregroundColor: Colors.white,
                  //   ),
                  // ),

                  //  final url = '${ApiHelper.gmsUrl}SavePatrolling';
                  ElevatedButton.icon(
                    onPressed: () {
                      if (patrollingController.text.isEmpty ||
                          shiftController.text.isEmpty) {
                        // Show an alert dialog if any field is empty
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Please Select Values'),
                              content: const Text(
                                  'Please select both Patrolling and Shift before scanning.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Both fields have values, so start the scan.
                        // provider.startScan();
                        provider.startScan(widget.userData.empNo);
                      }
                      // shiftController.clear();
                      // patrollingController.clear();
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Open Camera to Scan QR Code"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Text(
                  //   'Scan Result: ${provider.scanResult}',
                  //   style: const TextStyle(fontSize: 16),
                  //   textAlign: TextAlign.center,
                  // ),
                  provider.scanResult != "No data scanned"
                      ? ScanResultWidget(
                          jsonString: provider.scanResult,
                          userData: widget.userData)
                      : const SizedBox.shrink(),

                  // ScanResultWidget(jsonString: provider.scanResult),

                  // ScanResultWidget(jsonString: provider.scanResult),
                  // const SizedBox(height: 20),
                  // ElevatedButton.icon(
                  //   onPressed: (provider.scanResult != "No data scanned" &&
                  //           provider.scanResult != "Scan cancelled" &&
                  //           !provider.isSubmitting)
                  //       ? () => provider.submitScanData(widget.userData.empNo)
                  //       : null,
                  //   icon: provider.isSubmitting
                  //       ? const CircularProgressIndicator(
                  //           color: Colors.white,
                  //         )
                  //       : const Icon(Icons.upload),
                  //   label: provider.isSubmitting
                  //       ? const Text("Submitting...")
                  //       : const Text("Submit Scan Data"),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.blueAccent,
                  //     foregroundColor: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildDropDownSearchField({
  required String label,
  required String value,
  required List<String> items,
  required ValueChanged<String> onChanged,
  required TextEditingController controller,
}) {
  return DropDownSearchField<String>(
    textFieldConfiguration: TextFieldConfiguration(
      controller: controller,
      autofocus: false,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        suffixIcon: const Icon(Icons.search),
      ),
      onChanged: (text) {
        onChanged(text);
      },
    ),
    // Always return a Future<List<String>> based on the current search pattern.
    suggestionsCallback: (pattern) async {
      if (pattern.isEmpty) {
        return items;
      }
      return items
          .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
          .toList();
    },
    itemBuilder: (context, item) {
      return ListTile(
        title: Text(item),
      );
    },
    onSuggestionSelected: (suggestion) {
      onChanged(suggestion);
      controller.text = suggestion;
    },
    displayAllSuggestionWhenTap: true,
    isMultiSelectDropdown: false,
  );
}
