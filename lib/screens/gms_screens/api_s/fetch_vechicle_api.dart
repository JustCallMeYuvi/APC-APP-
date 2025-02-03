
// import 'dart:convert';

// import 'package:flutter/material.dart';
//   import 'package:animated_movies_app/api/apis_page.dart';
// import 'package:http/http.dart' as http;

//   String _userDept = ''; // get dept of barcode
//   bool _showPickButtonsandSubmit = false;

//   bool _isSubmitted = false; // Submit Save Details Success after this is true

//   bool _hideUI = false; // Flag to control UI visibility
//   String _selectedInspectedBarcode =
//       ''; // this is for fire gate out search barcode

//   final Map<String, String> _inspectionPointsRadioButtons = {
//     "Bumper": "",
//     "Engine": "",
//     "Tires": "",
//     "Floors of the cab": "",
//     "Fuel Tanks": "",
//     "Outside and inside of the cab": "",
//     "Air tank": "",
//     "Drive Shafts": "",
//     "Fifth Wheel": "",
//     "Outside OR Undercarriage": "",
//     "Floors of the Container OR Box of the Truck": "",
//     "Inside and Outside of the door of the container OR Box of the Truck": "",
//     "Side wall of the Container OR Box of the Truck": "",
//     "Inside Ceiling and Outside roof of the Container OR Box of the Truck": "",
//     "Front Wall of the Container OR Box of the Truck": "",
//     "Refrigeration Unit": "",
//     "Exhaust": "",
//   };
//   final Map<String, String> _agricultureInspectionRadioButtons = {
//     "Contamination": "",
//     "Measures": "",
//   };

//   final Map<String, String> _agricultureCheckListRadioButtons = {
//     "Plants": "",
//     "Seeds": "",
//     "Egg Masses": "",
//     "Insects": "",
//     "Snails": "",
//     "Animals": "",
//     "Animal Droppings": "",
//     "Sand": "",
//     "Soil": "",
//     "Liquid Oil OR Water": "",
//   };

//   final Map<String, String> _otherInspections = {
//     "First Aid": "",
//     "Fire Extinguisher": "",
//     "Pollution Certificate": "",
//     "Explosive Certificate": "",
//     "Vehicle License": "",
//   };

//   bool _isChecked = false; // This holds the state of the checkbox
//   bool _truckRefused = false; // This holds the state of the truck refusal

//   // fire gate out expansion tile
//   final TextEditingController _invoicePackingController =
//       TextEditingController();
//   final TextEditingController _buyersPoController = TextEditingController();
//   final TextEditingController _consigneeController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _pieceCountController = TextEditingController();
//   final TextEditingController _cartonBoxesController = TextEditingController();
//   final TextEditingController _grossWeightController = TextEditingController();
//   final TextEditingController _forwarderDetailsController =
//       TextEditingController();
//   final TextEditingController _engineNoController = TextEditingController();
//   final TextEditingController _chassisNoController = TextEditingController();
//   final TextEditingController _destinationController = TextEditingController();

//   final List<Map<String, String>> _submittedDetails =
//       []; // State for submitted details
//   final List<Map<String, String>> _submitPostMethod = [];

//   String getInspectionResult() {
//     // Check if all inspection points are filled with "Ok"
//     bool isInspectionPointsValid =
//         _inspectionPointsRadioButtons.values.every((value) => value == "Ok");

//     // Check if all agriculture inspection points are filled with "Ok"
//     bool isAgricultureInspectionValid = _agricultureInspectionRadioButtons
//         .values
//         .every((value) => value == "Ok");

//     // Check the condition for agriculture checklist validation
//     bool areAllChecklistNotPresent = _agricultureCheckListRadioButtons.values
//         .every((value) => value == "Not Present");

//     bool isAgricultureCheckListValid =
//         areAllChecklistNotPresent || // Pass if all are "Not Present"
//             (_agricultureCheckListRadioButtons.values
//                     .any((value) => value == "Present") &&
//                 _isChecked); // Pass if one is "Present" and checkbox is true

//     // Determine inspection result
//     if (isInspectionPointsValid &&
//         isAgricultureInspectionValid &&
//         isAgricultureCheckListValid) {
//       return "Pass"; // All conditions are met
//     } else {
//       return "Fail"; // Any condition failed
//     }
//   }

//   Widget buildInspectionResult() {
//     // Get the inspection result
//     String inspectionResult = getInspectionResult();
//     // Set _truckRefused based on inspection result
//     _truckRefused = inspectionResult ==
//         "Fail"; // If "Fail", set _truckRefused to true; else false
//     return Column(
//       children: [
//         Text('Inspection Result: ${getInspectionResult()}',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         // Optional: Display Truck_Refused state
//         Text(
//           'Truck Refused: ${_truckRefused ? "True" : "False"}',
//           style: TextStyle(fontSize: 16, color: Colors.red),
//         ),
//       ],
//     );
//   }

//   final TextEditingController _loadingPoinstController =
//       TextEditingController();
//   final TextEditingController _loadingPoinstControllerforFGOUT =
//       TextEditingController();

//   String _selectedVehicleNumber = '';
//   bool _isLoading = false;
//   List<Map<String, String>> _vehicleNumbers = [];

//   bool _isDetailsLoading = false;
//   String _vehicleId = '';
//   String _barcode = '';
//   String _createdBy = '';
//   String _mainGateEntry = '';
//   String _mainGateExit = '';
//   String _fireGateEntry = '';
//   String _firegateExit = '';
//   String _FGEntry = '';
//   String _FGExit = '';

//   String _exportManager = '';
//   String _combineLoadingPoints = '';
//   String _sourceTo = '';

//   String _processLevel = ''; // processLevel extracted from the API response
//   String _status = ''; // processLevel extracted from the API response
//   String _active = ''; // processLevel extracted from the API response

//   String _driverNameIN = '';
//   String _rcNumber = '';
//   String _vehicleType = '';
//   String _truckNumber = '';
//   String _container_Number_IN = '';
//   String _outward_Serial_No = '';
//   String _inward_Serial_No = '';
//   String _stageIN = '';
//   String _purpose = '';
//   String _sealNo = '';
//   String _linearSeal = '';
//   String _customSeal = '';
//   String _otherSeal = '';
//   String _driverNameOut = '';
//   String _licenseNumberIN = '';

//   String _licenseNumberOut = '';
//   String _remark = '';

//   final FocusNode _focusNode = FocusNode();

//   String _gateType = ''; // Define _gateType as a class variable


  



//   // final List<File> _selectedImages = [];
//   // final List<File> _selectedVideos = [];
//   bool _isUploading = false;
//   // VideoPlayerController? _videoPlayerController;

//   String _selectedLoadingPoint = '';
//   String _selectedLoadingPointofFGOut = '';

//   List<String> _allLoadingPoints = [];
//   // FG OUT
  
// Future<void> _fetchVehicleDetails(
//       String vehicleId, String processLevel) async {
//     setState(() {
//       _isDetailsLoading = true;
//     });

//     // final url =
//     //     'http://10.3.0.208:8084/api/GMS/getvehicledetails?id=$vehicleId&processlevel=$processLevel';
//     final url =
//         '${ApiHelper.gmsUrl}getvehicledetails?id=$vehicleId&processlevel=$processLevel';

//     print('Vehicle details URL ${url}');
//     print("Driver Name IN: $_driverNameIN");
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         print("Response body: ${response.body}");

//         final data = json.decode(response.body);

//         // Check if the response is a list and contains at least one vehicle
//         if (data is List && data.isNotEmpty) {
//           final vehicleDetails =
//               data[0]; // Access the first vehicle in the list

//           // Extract vehicle ID (truckno) and process level (status)
//           setState(() {
//             // Handle null values by providing fallback defaults
//             _vehicleId = vehicleDetails['id'].toString();
//             // _barcode = vehicleDetails['barcode']??'N/A';

//             _driverNameIN = vehicleDetails['driverName_IN'] ?? 'N/A';
//             _licenseNumberIN = vehicleDetails['licenseNumber_IN'] ?? 'N/A';
//             _rcNumber = vehicleDetails['rcnumber'] ?? 'N/A';
//             _vehicleType = vehicleDetails['vehicle_Type_IN'] ?? 'N/A';
//             _truckNumber =
//                 vehicleDetails['truckno'] ?? 'N/A'; // Handle null truckno

//             _outward_Serial_No =
//                 vehicleDetails['outward_Serial_No'].toString() ?? 'N/A';
//             _inward_Serial_No =
//                 vehicleDetails['inward_Serial_No'].toString() ?? 'N/A';

//             _stageIN = vehicleDetails['stagE_IN'] ?? 'N/A';

//             _stageIN = vehicleDetails['stagE_IN'] ?? 'N/A';
//             _purpose = vehicleDetails['purpose'] ?? 'N/A';
//             _sourceTo = vehicleDetails['sourcE_TO'] ?? 'N/A';
//             _sealNo = vehicleDetails['seal_NO'] ?? 'N/A';
//             _linearSeal = vehicleDetails['linear_Seal'] ?? 'N/A';
//             _customSeal = vehicleDetails['custom_Seal'] ?? 'N/A';
//             _otherSeal = vehicleDetails['other_Seal'] ?? 'N/A';
//             _driverNameOut = vehicleDetails['driverName_OUT'] ?? 'N/A';
//             _licenseNumberOut = vehicleDetails['licenseNumber_OUT'] ?? 'N/A';
//             _remark = vehicleDetails['remark'] ?? 'N/A';
//             _combineLoadingPoints =
//                 vehicleDetails['combinedLoadingPoints'] ?? 'N/A';

//             // Set the processLevel (status) value
//             _processLevel = vehicleDetails['status']?.toString() ??
//                 'N/A'; // Convert to String
//             _status = vehicleDetails['status'] ?? 'N/A';

//             _active = vehicleDetails['active']?.toString() ?? 'N/A';
//             _createdBy = vehicleDetails['createdBy'] ?? 'N/A';

//             //  // Logic to display "Main Gate" or "Fire Gate" based on status
//             //     if (_processLevel == "1") {
//             //       _gateType = "Main Gate";
//             //     } else if (_processLevel == "2") {
//             //       _gateType = "Fire Gate";
//             //     } else if (_processLevel == "3"){
//             //       _gateType = "FG IN";
//             //     }else if (_processLevel == "4"){
//             //       _gateType = "FG OUT";
//             //     }else if (_processLevel == "5"){
//             //       _gateType = "Fire Gate OUT ";
//             //     }else if (_processLevel == "6"){
//             //       _gateType = "Main Gate OUT IN";
//             //     }

//             final String status = vehicleDetails['status']?.toString() ?? 'N/A';
//             final String active = vehicleDetails['active']?.toString() ?? 'N/A';
//             // Logic to determine gate type
//             if (_status == "1" && _active == "1" && _userDept == "Main Gate") {
//               _gateType = "Main Gate";
//               _showPickButtonsandSubmit = true;
//             } else if (_status == "2" &&
//                 _active == "1" &&
//                 _userDept == "Fire Gate") {
//               _gateType = "Fire Gate";
//               _showPickButtonsandSubmit = true;
//             } else if (_status == "3" && _active == "1" && _userDept == "FG") {
//               _gateType = "FG IN";
//               _showPickButtonsandSubmit = true;
//             } else if (_status == "4" && _active == "1" && _userDept == "FG") {
//               _gateType = "FG OUT";
//               _showPickButtonsandSubmit = true;
//             } else if (_status == "5" &&
//                 _active == "1" &&
//                 _userDept == "Fire Gate") {
//               _gateType = "Fire Gate OUT";
//               _showPickButtonsandSubmit = true;
//             } else if (_status == "6" &&
//                 _active == "1" &&
//                 _userDept == "Main Gate") {
//               _gateType = "Main Gate OUT";
//               _showPickButtonsandSubmit = true;
//             } else if (_status == "6" && _active == "2") {
//               _gateType = "Already Vehicle Exited";
//             } else if (_status == "0") {
//               _gateType = "Export team not Approved";
//             } else if (_status == "1") {
//               _gateType = "Vehicle waiting at Main Gate In";
//             } else if (_status == "2") {
//               _gateType =
//                   "Vehicle Exited from Main Gate,Waiting at Fire Gate In";
//             } else if (_status == "3") {
//               _gateType = "Vehicle Exited from Fire Gate,Waiting at FG In";
//             } else if (_status == "4") {
//               _gateType = "Vehicle Entered in FG,Waiting for Loading Complete";
//             } else if (_status == "5") {
//               _gateType = "Vehicle Exited from FG,Waiting at Fire Gate Out";
//             }
//           });
//         } else {
//           _showErrorDialog("Error: No vehicle details found.");
//         }
//       } else {
//         _showErrorDialog("Error: Unable to fetch vehicle details.");
//       }
//     } catch (e) {
//       _showErrorDialog("Failed to fetch vehicle details. Error: $e");
//     } finally {
//       setState(() {
//         _isDetailsLoading = false;
//       });
//     }
//   }
  
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Error"),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }