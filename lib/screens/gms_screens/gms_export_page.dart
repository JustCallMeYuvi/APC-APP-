import 'dart:convert';
import 'dart:io';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/gms_screens/custom_switch_button.dart';
import 'package:animated_movies_app/screens/gms_screens/gms_files_page.dart';
import 'package:animated_movies_app/screens/gms_screens/inspected_barcodes.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class GmsExportPage extends StatefulWidget {
  final LoginModelApi userData;
  const GmsExportPage({Key? key, required this.userData}) : super(key: key);

  @override
  _GmsExportPageState createState() => _GmsExportPageState();
}

class _GmsExportPageState extends State<GmsExportPage> {
  final TextEditingController _typeAheadController = TextEditingController();

  var loadingAreas = '';
  String _userDept = ''; // get dept of barcode
  bool _showPickButtonsandSubmit = false;
  bool _imagesShows = false;

  bool _isSubmitted = false; // Submit Save Details Success after this is true
  bool _isSubmittingTimeProgressforSubmit =
      false; // State to track if submitting is in progress

  bool _hideUI = false; // Flag to control UI visibility
  String _selectedInspectedBarcode =
      ''; // this is for fire gate out search barcode

  String _previousResult = ""; // To track the previous inspection result
  bool _isInitialCheckDoneForInspectionResultAlert =
      false; // Ensure no alert on first load

  final Map<String, String> _inspectionPointsRadioButtons = {
    "Bumper": "",
    "Engine": "",
    "Tires": "",
    "Floors of the cab": "",
    "Fuel Tanks": "",
    "Outside and inside of the cab": "",
    "Air tank": "",
    "Drive Shafts": "",
    "Fifth Wheel": "",
    "Outside OR Undercarriage": "",
    "Floors_of_the_Container_OR_Box_of_the_Truck": "",
    "Inside_and_Outside_of_the_door_of_the_container_OR_Box_of_the_Truck": "",
    "Side_wall_of_the_Container_OR_Box_of_the_Truck": "",
    "Inside_Ceiling_and_Outside_roof_of_the_Container_OR_Box_of_the_Truck": "",
    "Front_Wall_of_the_Container_OR_Box_of_the_Truck": "",
    "Refrigeration_Unit": "",
    "Exhaust": "",
  };
  final Map<String, String> _agricultureInspectionRadioButtons = {
    "Contamination": "",
    "Measures": "",
  };

  final Map<String, String> _agricultureCheckListRadioButtons = {
    "Plants": "",
    "Seeds": "",
    "Egg_Masses": "",
    "Insects": "",
    "Snails": "",
    "Animals": "",
    "Animal_Droppings": "",
    "Sand": "",
    "Soil": "",
    // "Liquid Oil OR Water": "",
    "Liquid": "",
  };

  final Map<String, String> _otherInspections = {
    "First_Aid": "",
    "Fire_Extinguisher": "",
    "Pollution_Certificate": "",
    "Explosive_Certificate": "",
    "Vehicle_License": "",
  };

  bool _isChecked = false; // This holds the state of the checkbox
  bool _truckRefused = false; // This holds the state of the truck refusal

  // fire gate out expansion tile
  final TextEditingController _invoicePackingController =
      TextEditingController();
  final TextEditingController _buyersPoController = TextEditingController();
  final TextEditingController _consigneeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pieceCountController = TextEditingController();
  final TextEditingController _cartonBoxesController = TextEditingController();
  final TextEditingController _grossWeightController = TextEditingController();
  final TextEditingController _forwarderDetailsController =
      TextEditingController();
  final TextEditingController _engineNoController = TextEditingController();
  final TextEditingController _chassisNoController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  String getInspectionResult() {
    // // Check if all inspection points are filled with "Ok"
    // bool isInspectionPointsValid =
    //     _inspectionPointsRadioButtons.values.every((value) => value == "Ok");

    // Check if all inspection points are filled with "Ok" or "N/A"
    bool isInspectionPointsValid = _inspectionPointsRadioButtons.values
        .every((value) => value == "Ok" || value == "N/A");

    // // Check if all agriculture inspection points are filled with "Ok"
    // bool isAgricultureInspectionValid = _agricultureInspectionRadioButtons
    //     .values
    //     .every((value) => value == "Ok");

    // Check if all agriculture inspection are filled with "Ok" or "N/A"
    bool isAgricultureInspectionValid = _agricultureInspectionRadioButtons
        .values
        .every((value) => value == "Ok" || value == "N/A");

    // Check the condition for agriculture checklist validation
    bool areAllChecklistNotPresent = _agricultureCheckListRadioButtons.values
        .every((value) => value == "Not Present");

    bool isAgricultureCheckListValid =
        areAllChecklistNotPresent || // Pass if all are "Not Present"
            (_agricultureCheckListRadioButtons.values
                    .any((value) => value == "Present") &&
                _isChecked); // Pass if one is "Present" and checkbox is true

    // Determine inspection result
    if (isInspectionPointsValid &&
        isAgricultureInspectionValid &&
        isAgricultureCheckListValid) {
      return "Pass"; // All conditions are met
    } else {
      return "Fail"; // Any condition failed
    }
  }

  void _checkInspectionResult() {
    String currentResult = getInspectionResult(); // Get latest result
    Color resultColor = currentResult == "Pass" ? Colors.green : Colors.red;
    // If it's the first check, just store the result and don't show alert
    if (!_isInitialCheckDoneForInspectionResultAlert) {
      _previousResult = currentResult;
      _isInitialCheckDoneForInspectionResultAlert = true;
      return; // Prevent popup on first load
    }
    if (_previousResult != currentResult) {
      // Detect if result changed
      _previousResult = currentResult; // Update the previous result

      // Show the alert dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Inspection Result"),
            content: RichText(
              textAlign: TextAlign.center, // Center align text
              text: TextSpan(
                text: currentResult,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: resultColor,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the alert box
                },
                child: const Text("Check Again"),
              ),
            ],
          );
        },
      );
    }
  }

  Widget buildInspectionResult() {
    // Get the inspection result
    String inspectionResult = getInspectionResult();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInspectionResult(); // Check for changes in result
    });

    // Set _truckRefused based on inspection result
    _truckRefused = inspectionResult ==
        "Fail"; // If "Fail", set _truckRefused to true; else false
    return Column(
      children: [
        Text('Inspection Result: ${getInspectionResult()}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        // Optional: Display Truck_Refused state
        // Text(
        //   'Truck Refused: ${_truckRefused ? "True" : "False"}',
        //   style: TextStyle(fontSize: 16, color: Colors.red),
        // ),
      ],
    );
  }

  final TextEditingController _loadingPoinstController =
      TextEditingController();
  final TextEditingController _loadingPoinstControllerforFGOUT =
      TextEditingController();

// String _manifestVehicleNumber='';
  late Map<String, dynamic>
      _manifestData; // Declare the variable to store the manifest details

// You can use this model if you prefer to use a custom class instead of Map
// ManifestData _manifestData;

  String _selectedVehicleNumber = '';
  bool _isLoading = false;
  List<Map<String, String>> _vehicleNumbers = [];

  bool _isDetailsLoading = false;
  String _vehicleId = '';
  String _barcode = '';
  String _createdBy = '';
  String _mainGateEntry = '';
  String _mainGateExit = '';
  String _fireGateEntry = '';
  String _firegateExit = '';
  String _FGEntry = '';
  String _FGExit = '';

  String _exportManager = '';
  String _combineLoadingPoints = '';
  String _sourceTo = '';

  String _manifestEngineNumber = '';
  String _manifestChasisNumber = '';

  String _processLevel = ''; // processLevel extracted from the API response
  String _status = ''; // processLevel extracted from the API response
  String _active = ''; // processLevel extracted from the API response
  String? _inspection = '';
  String _driverNameIN = '';
  String _rcNumber = '';
  String _vehicleType = '';
  String _truckNumber = '';
  String _container_Number_IN = '';
  String _outward_Serial_No = '';
  String _inward_Serial_No = '';
  String _stageIN = '';
  String _purpose = '';
  String _sealNo = '';
  String _linearSeal = '';
  String _customSeal = '';
  String _otherSeal = '';
  String _driverNameOut = '';
  String _licenseNumberIN = '';
  // String _fireGateOutSourceToInTextFormField = '';
  String _fireGateOutSourceToInTextFormField = 'Chennai'; // Default value
  String _fireGateOutPurposeInTextFormField = 'Export';
  String _fireGateOutDescriptionTextFormFieldController = 'Finished Goods';
  String _loadingLocationsFireGateOut = '';

  String _buyersPo = '';
  String _invoicePacking = '';
  String _pieceCount = '';
  String _cartonBox = '';
  String _chaFetchData = '';

  String _licenseNumberOut = '';
  String _remark = '';

  final FocusNode _focusNode = FocusNode();

  String _gateType = ''; // Define _gateType as a class variable

  // Main Gate Controllers
  final TextEditingController _mainGateFromInController =
      TextEditingController();
  final TextEditingController _mainGateStageInController =
      TextEditingController();
  final TextEditingController _mainGatePurposeController =
      TextEditingController();

// Fire Gate Controllers
  final TextEditingController _fireGateDriverPassController =
      TextEditingController();
  final TextEditingController _fireGateLockNumberController =
      TextEditingController();
  final TextEditingController _fireGatePurposeController =
      TextEditingController();
  final TextEditingController _fireGateTruckLicenseController =
      TextEditingController();
  final TextEditingController _fireGateDestinyController =
      TextEditingController();

// Fire Gate OUT Controllers
  final TextEditingController _fireGateOutVVVTProcessController =
      TextEditingController();
  final TextEditingController _fireGateOutSourceToController =
      TextEditingController();
  final TextEditingController _fireGateOutStageInController =
      TextEditingController();
  final TextEditingController _fireGateOutPurposeController =
      TextEditingController();

  // final TextEditingController _fromInController = TextEditingController();
  // final TextEditingController _stageInController = TextEditingController();
  // final TextEditingController _purposeController = TextEditingController();

  // Fire Gate Out Controllers
  final TextEditingController _sealNoController = TextEditingController();
  final TextEditingController _linearSealController = TextEditingController();
  final TextEditingController _customSealContoller = TextEditingController();
  final TextEditingController _otherSealController = TextEditingController();
  final TextEditingController _combinedSealController = TextEditingController();

  bool _isUpdatingCombinedSeal = false;
  final TextEditingController _driverNameInController = TextEditingController();

  final TextEditingController _driverNameOutController =
      TextEditingController();
  final TextEditingController __licenseNumberOutController =
      TextEditingController();

  void _updateCombinedSeal() {
    if (_isUpdatingCombinedSeal) return;

    setState(() {
      _combinedSealController.text = [
        _sealNoController.text,
        _linearSealController.text,
        _customSealContoller.text,
        _otherSealController.text,
      ].where((seal) => seal.isNotEmpty).join(", ");
    });
  }

  void _onCombinedSealChanged(String value) {
    setState(() {
      _isUpdatingCombinedSeal = true; // Prevent triggering listeners
      _combinedSealController.text = value; // Update combined seal only
      _isUpdatingCombinedSeal = false; // Allow listeners after update
    });
  }

  File? _selectedMedia;
  // bool _isUploading = false;
  final List<File> _mediaFiles = [];

  final ImagePicker _imagePicker = ImagePicker();

  // final List<File> _selectedImages = [];
  // final List<File> _selectedVideos = [];
  bool _isUploading = false;
  // VideoPlayerController? _videoPlayerController;
  Map<File, VideoPlayerController> _videoPlayerController =
      {}; // Map to store controllers

  // loading Points
  String _selectedLoadingPoint = '';
  String _selectedLoadingPointofFGOut = '';

  List<String> _allLoadingPoints = [];
  // FG OUT
  bool _enableToggleButton =
      false; // for FG out submit button shows when this switch is on
  // String?
  //     _currentlyPlayingVideo; // Store the path of the currently playing video
  File? _currentlyPlayingVideo; // Track the currently playing video

// // the below is ui shows without scroll
// this pick media is not capture image and videos not saved in local device but works image and video saved in db perfect
//   Future<void> _pickMedia(String type) async {
//     if (type == 'image') {
//       // Show dialog to choose between camera and file picker
//       await showModalBottomSheet(
//         context: context,
//         builder: (context) => Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Icon(Icons.camera_alt),
//               title: Text('Take a Picture'),
//               onTap: () async {
//                 Navigator.of(context).pop(); // Close the bottom sheet
//                 final pickedFile = await _imagePicker.pickImage(
//                   source: ImageSource.camera,
//                   imageQuality: 80, // Adjust image quality
//                 );
//                 if (pickedFile != null) {
//                   setState(() {
//                     // _selectedImages.add(File(pickedFile.path));
//                     _mediaFiles
//                         .add(File(pickedFile.path)); // Add to _mediaFiles
//                   });
//                 } else {
//                   _showSnackBar('No image captured.');
//                 }
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.photo_library),
//               title: Text('Choose from Gallery'),
//               onTap: () async {
//                 Navigator.of(context).pop(); // Close the bottom sheet
//                 final result = await FilePicker.platform.pickFiles(
//                   type: FileType.custom,
//                   allowedExtensions: [
//                     'jpeg',
//                     'jpg',
//                     'png'
//                   ], // JPEG and PNG only
//                   allowMultiple: true,
//                 );
//                 if (result != null) {
//                   setState(() {
//                     // _selectedImages
//                     //     .addAll(result.paths.map((path) => File(path!)));
//                     _mediaFiles.addAll(result.paths
//                         .map((path) => File(path!))); // Add to _mediaFiles
//                   });
//                   print(_mainGateFromInController.text);
//                 } else {
//                   _showSnackBar('No images selected.');
//                 }
//               },
//             ),
//           ],
//         ),
//       );
//     } else if (type == 'video') {
//       // Show dialog to choose between video capture and file picker
//       await showModalBottomSheet(
//         context: context,
//         builder: (context) => Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Icon(Icons.videocam),
//               title: Text('Capture Video'),
//               onTap: () async {
//                 Navigator.of(context).pop(); // Close the bottom sheet
//                 final pickedFile = await _imagePicker.pickVideo(
//                   source: ImageSource.camera,
//                   maxDuration: const Duration(seconds: 60), // Set max duration
//                 );
//                 if (pickedFile != null) {
//                   setState(() {
//                     // _selectedVideos.add(File(pickedFile.path));
//                     _mediaFiles
//                         .add(File(pickedFile.path)); // Add to _mediaFiles
//                   });
//                 } else {
//                   _showSnackBar('No video captured.');
//                 }
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.video_library),
//               title: Text('Choose from Gallery'),
//               onTap: () async {
//                 Navigator.of(context).pop(); // Close the bottom sheet
//                 final result = await FilePicker.platform.pickFiles(
//                   type: FileType.video,
//                   allowMultiple: true,
//                 );
//                 if (result != null) {
//                   setState(() {
//                     // _selectedVideos
//                     //     .addAll(result.paths.map((path) => File(path!)));
//                     _mediaFiles.addAll(result.paths
//                         .map((path) => File(path!))); // Add to _mediaFiles
//                   });
//                 } else {
//                   _showSnackBar('No videos selected.');
//                 }
//               },
//             ),
//           ],
//         ),
//       );
//     }
//   }

// below pick medis is images and videos saved in local device now testing db saved or not
  Future<void> _pickMedia(String type) async {
    if (type == 'image') {
      await showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Picture'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (pickedFile != null) {
                  File newFile = File(pickedFile.path);
                  if (_mediaFiles.length >= 30) {
                    _showSnackBar('Maximum of 30 files reached.');
                    return;
                  }
                  // ✅ Request permission before saving
                  if (await _requestPermission('image')) {
                    final result =
                        await ImageGallerySaver.saveFile(newFile.path);
                    print("Image Saved: $result");
                    _showSnackBar('Image saved to gallery!');
                  } else {
                    _showSnackBar('Permission denied.');
                  }

                  setState(() {
                    _mediaFiles.add(newFile);
                  });
                } else {
                  _showSnackBar('No image captured.');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: true,
                );
                if (result != null) {
                  int totalFilesAfterPick =
                      _mediaFiles.length + result.paths.length;
                  if (totalFilesAfterPick > 30) {
                    _showSnackBar('You can only select up to 30 files.');
                  } else {
                    setState(() {
                      _mediaFiles
                          .addAll(result.paths.map((path) => File(path!)));
                    });
                  }
                } else {
                  _showSnackBar('No images selected.');
                }
              },
            ),
          ],
        ),
      );
    } else if (type == 'video') {
      await showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Capture Video'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile = await _imagePicker.pickVideo(
                  source: ImageSource.camera,
                  maxDuration: const Duration(seconds: 60),
                );
                if (pickedFile != null) {
                  File newFile = File(pickedFile.path);
                  if (_mediaFiles.length >= 30) {
                    _showSnackBar('Maximum of 30 files reached.');
                    return;
                  }
                  // ✅ Request permission before saving
                  if (await _requestPermission('video')) {
                    final result =
                        await ImageGallerySaver.saveFile(newFile.path);
                    print("Video Saved: $result");
                    _showSnackBar('Video saved to gallery!');
                  } else {
                    _showSnackBar('Permission denied.');
                  }

                  setState(() {
                    _mediaFiles.add(newFile);
                  });
                } else {
                  _showSnackBar('No video captured.');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.video,
                  allowMultiple: true,
                );
                if (result != null) {
                  int totalFilesAfterPick =
                      _mediaFiles.length + result.paths.length;
                  if (totalFilesAfterPick > 30) {
                    _showSnackBar('You can only select up to 30 files.');
                  } else {
                    setState(() {
                      _mediaFiles
                          .addAll(result.paths.map((path) => File(path!)));
                    });
                  }
                } else {
                  _showSnackBar('No videos selected.');
                }
              },
            ),
          ],
        ),
      );
    }
  }

// // ✅ Request Storage Permission
// Future<bool> _requestPermission() async {
//   var status = await Permission.storage.request();
//   if (status.isGranted) {
//     return true;
//   }
//   return false;
// }

  // below code is not working android version 13

  // Future<bool> _requestPermission(String mediaType) async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //   int sdkInt = androidInfo.version.sdkInt;

  //   PermissionStatus permissionStatus;

  //   if (sdkInt < 33) {
  //     // ✅ For Android 12 and below, request full storage access
  //     permissionStatus = await Permission.storage.request();
  //   } else if (sdkInt == 33) {
  //     // ✅ For Android 13 (API 33), request specific permissions
  //     if (mediaType == 'image') {
  //       permissionStatus = await Permission.photos.request();
  //     } else if (mediaType == 'video') {
  //       permissionStatus = await Permission.videos.request();
  //     } else {
  //       permissionStatus = await Permission.storage.request();
  //     }
  //   } else {
  //     // ✅ For Android 14+ (API 34), use READ_MEDIA_IMAGES & READ_MEDIA_VIDEO
  //     List<Permission> permissions = [];

  //     if (mediaType == 'image') {
  //       permissions.add(Permission.photos);
  //       permissions.add(Permission.mediaLibrary);
  //     } else if (mediaType == 'video') {
  //       permissions.add(Permission.videos);
  //       permissions.add(Permission.mediaLibrary);
  //     }

  //     Map<Permission, PermissionStatus> statuses = await permissions.request();
  //     permissionStatus = statuses.values.contains(PermissionStatus.granted)
  //         ? PermissionStatus.granted
  //         : PermissionStatus.denied;
  //   }

  //   if (permissionStatus == PermissionStatus.granted) {
  //     return true;
  //   } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
  //     // 🚀 Open app settings if permission is permanently denied
  //     await openAppSettings();
  //     return false;
  //   } else {
  //     return false;
  //   }
  // }

  // below code is working all android versions
  Future<bool> _requestPermission(String mediaType) async {
    try {
      PermissionStatus permissionStatus;

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo =
            await deviceInfo.androidInfo; // ✅ Only call this on Android
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt < 33) {
          permissionStatus = await Permission.storage.request();
        } else {
          permissionStatus =
              PermissionStatus.granted; // Android 13+ auto-grants permission
        }
      } else if (Platform.isIOS) {
        permissionStatus =
            await Permission.photos.request(); // ✅ iOS-specific permission
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // ✅ Skip permission checks for Web, Linux, Windows, and macOS
        print("⚠️ Skipping permission request on non-mobile platforms");
        return true;
      } else {
        print("❌ Unsupported platform");
        return false;
      }

      if (permissionStatus == PermissionStatus.granted) {
        return true;
      } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
        print("🚨 Permission permanently denied, opening settings...");
        await openAppSettings();
        return false;
      } else {
        print("❌ Permission denied");
        return false;
      }
    } catch (e) {
      print('❌ Error checking permission: $e');
      return false;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // // Upload Media (Placeholder)
  Future<void> _uploadMedia() async {
    setState(() {
      _isUploading = true;
    });

    // Simulate Upload
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Media uploaded successfully!'),
    ));
  }

  void _playVideo(File video) async {
    // Pause and dispose of the currently playing video controller if it exists
    if (_currentlyPlayingVideo != null &&
        _videoPlayerController[_currentlyPlayingVideo] != null) {
      await _videoPlayerController[_currentlyPlayingVideo]!.pause();
    }

    // // Initialize the new VideoPlayerController for the selected video
    // print('Initializing video player for: ${video.path}');
    // _videoPlayerController = VideoPlayerController.file(video);

// Initialize the selected video's controller if not already done
    if (!_videoPlayerController.containsKey(video)) {
      _videoPlayerController[video] = VideoPlayerController.file(video);
      await _videoPlayerController[video]!.initialize();
    }
    try {
      // Start video initialization and print debug messages
      print('Starting video initialization...');
      await _videoPlayerController[video]!.initialize();
      print('Video initialization complete.');

      // Force a UI update after initialization
      setState(() {
        _currentlyPlayingVideo = video;
      });
      await _videoPlayerController[video]!.play();

      // Play the video
      print('Playing the video...');
      await _videoPlayerController[video]!.play();
      setState(() {}); // Ensure UI rebuild to show the video
    } catch (e) {
      print('Error during video initialization: $e');
    }
  }

  @override
  void dispose() {
    // Dispose of all controllers
    _videoPlayerController.values.forEach((controller) {
      controller.dispose();
    });
    _sealNoController.dispose();
    _linearSealController.dispose();
    _customSealContoller.dispose();
    _otherSealController.dispose();
    _combinedSealController.dispose();
    super.dispose();
  }

  void _showFullImage(File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Image.file(imageFile),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchBarcodeData(widget.userData.empNo);
    // Set initial value of the controller
    _mainGateFromInController.addListener(() {
      print(_mainGateFromInController.text);
    });

    // _driverNameOutController = TextEditingController();
    // _driverNameInController = TextEditingController();
    _driverNameOutController.text = _driverNameIN;
    _driverNameInController.text = _driverNameIN;
    // __licenseNumberOutController = TextEditingController();
    __licenseNumberOutController.text = _licenseNumberIN;
    // Initialize the controller with the value of _driverNameIN
    // _driverNameOutController = TextEditingController(text: _driverNameIN);
    // Assuming _driverNameIN is already defined and not null

    // _fetchLoadingPoints();

    // Add listeners to individual seal controllers to update combined seal
    _sealNoController.addListener(_updateCombinedSeal);
    _linearSealController.addListener(_updateCombinedSeal);
    _customSealContoller.addListener(_updateCombinedSeal);
    _otherSealController.addListener(_updateCombinedSeal);
  }

  // get loading points

  Future<List<String>> _fetchLoadingPoints() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      // final url = 'http://10.3.0.208:8084/api/GMS/getloadingpoints';
      final url = '${ApiHelper.gmsUrl}getloadingpoints';
      print(
          'Requesting data from URL: $url'); // Print the URL in the debug console

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print(
            'Response body: ${response.body}'); // Print the response body to debug

        // Try to decode the response body
        final dynamic data = json.decode(response.body);

        // Check if the data contains the 'loadingPoints' key
        if (data is Map && data.containsKey('loadingPoints')) {
          final List<dynamic> loadingPoints = data['loadingPoints'];

          // Update the _allLoadingPoints list with the fetched data
          setState(() {
            _allLoadingPoints = loadingPoints
                .map((item) => item['loadingPoint'].toString())
                .toList();
          });

          return _allLoadingPoints;
        } else {
          print(
              'Error: Expected a map with key "loadingPoints", but got: $data');
          throw Exception(
              'Expected a map with key "loadingPoints", but got: $data');
        }
      } else {
        print('Error: Request failed with status: ${response.statusCode}');
        throw Exception(
            'Failed to load loading points, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e'); // Print the error to the console
      throw Exception('Failed to load loading points: $e');
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false
      });
    }
  }

// Filter loading points based on query
  List<String> _getSuggestionsLoadingPoints(
      String query, List<String> allLoadingPoints) {
    return allLoadingPoints
        .where((loadingPoint) =>
            loadingPoint.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> _fetchBarcodeData(String barcode) async {
    setState(() {
      _isLoading = true;
    });

    final url = '${ApiHelper.gmsUrl}barcode?barcode=$barcode';
    print('Request URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data);

        if (data is Map && data['vehicleNumbers'] is List) {
          setState(() {
            _vehicleNumbers = (data['vehicleNumbers'] as List)
                .map((vehicle) => {
                      'vehicleNumber': vehicle['vehicleNumber'].toString(),
                      'vehicleId': vehicle['vehicleId'].toString(),
                    })
                .toList();
          });
          _userDept = data['loginDetails'][0]['department'] ?? '';
          final processLevel = data['loginDetails'][0]['processLevel'] ?? '';
          // final exportManager = data['loginDetails'][0]['exportManager'] ?? '';
          final exportManager = data['loginDetails'][0]['exporT_MANAGER'] ??
              ''; // here export manager value binds
          final barcode = data['loginDetails'][0]['barcode'] ?? '';
          // final createdBy = data['loginDetails'][0]['createdBy'] ?? '';

          setState(() {
            _processLevel = processLevel;
            _exportManager = exportManager; // Bind the exportManager value
            _barcode = barcode;
            // _createdBy = createdBy;
          });
          print('Process Level: $_processLevel');
        } else if (data is Map && data['message'] == 'no access') {
          _showAlertDialog(
            title: "Access Denied",
            message: "You do not have access to this page.",
            onOkPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          );
        } else {
          _showErrorDialog("Invalid data structure for vehicle numbers.");
        }
      } else if (response.statusCode == 401) {
        _showAlertDialog(
          title: "You don't Access",
          message: "You are not authorized to access this resource.",
          onOkPressed: () {
            Navigator.pop(context);
          },
        );
      } else {
        _showErrorDialog(
            "Error: Unable to fetch data (Status Code: ${response.statusCode})");
      }
    } catch (e) {
      _showErrorDialog("Failed to fetch data. Please try again. Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchVehicleDetails(
      String vehicleId, String processLevel) async {
    setState(() {
      _isDetailsLoading = true;
    });

    // final url =
    //     'http://10.3.0.208:8084/api/GMS/getvehicledetails?id=$vehicleId&processlevel=$processLevel';
    final url =
        '${ApiHelper.gmsUrl}getvehicledetails?id=$vehicleId&processlevel=$processLevel';

    print('Vehicle details URL ${url}');
    print("Driver Name IN: $_driverNameIN");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print("Response body: ${response.body}");

        final data = json.decode(response.body);

        // Check if the response is a list and contains at least one vehicle
        if (data is List && data.isNotEmpty) {
          final vehicleDetails =
              data[0]; // Access the first vehicle in the list

          // Extract vehicle ID (truckno) and process level (status)
          setState(() {
            // Handle null values by providing fallback defaults

            _imagesShows = true;

            _vehicleId = vehicleDetails['id'].toString();
            // _barcode = vehicleDetails['barcode']??'N/A';
            _inspection = vehicleDetails['inspection'] ?? 'N/A';
            _driverNameIN = vehicleDetails['driverName_IN'] ?? 'N/A';

            _licenseNumberIN = vehicleDetails['licenseNumber_IN'] ?? 'N/A';
            _rcNumber = vehicleDetails['rcnumber'] ?? 'N/A';
            _vehicleType = vehicleDetails['vehicle_Type_IN'] ?? 'N/A';
            _truckNumber =
                vehicleDetails['truckno'] ?? 'N/A'; // Handle null truckno

            _outward_Serial_No =
                vehicleDetails['outward_Serial_No'].toString() ?? 'N/A';
            _inward_Serial_No =
                vehicleDetails['inward_Serial_No'].toString() ?? 'N/A';
            _container_Number_IN =
                vehicleDetails['container_Number_IN'].toString() ?? 'N/A';

            _stageIN = vehicleDetails['stagE_IN'] ?? 'N/A';
            _mainGateEntry = vehicleDetails['maingatE_ENTRY'] ?? '';
            _mainGateExit = vehicleDetails['maingatE_EXIT'] ?? '';
            _fireGateEntry = vehicleDetails['firegatE_ENTRY'] ?? '';
            _firegateExit = vehicleDetails['firegatE_EXIT'] ?? '';
            _FGEntry = vehicleDetails['fG_ENTRY'] ?? '';
            _FGExit = vehicleDetails['fG_EXIT'] ?? '';

            _stageIN = vehicleDetails['stagE_IN'] ?? 'N/A';
            _purpose = vehicleDetails['purpose'] ?? 'N/A';
            _sourceTo = vehicleDetails['sourcE_TO'] ?? 'N/A';
            _sealNo = vehicleDetails['seal_NO'] ?? 'N/A';
            _linearSeal = vehicleDetails['linear_Seal'] ?? 'N/A';
            _customSeal = vehicleDetails['custom_Seal'] ?? 'N/A';
            _otherSeal = vehicleDetails['other_Seal'] ?? 'N/A';

            // _buyersPo =vehicleDetails['buyers_Po']?? 'N/A';
            // _invoicePacking =vehicleDetails['invoice_Packing']?? 'N/A';
            // _pieceCount =vehicleDetails['piece_Count']?? 'N/A';
            // _cartonBox =vehicleDetails['carton_boxes']?? 'N/A';
            // _chaFetchData =vehicleDetails['cha']?? 'N/A';
            _buyersPo = vehicleDetails['buyers_Po'] ?? '';
            _invoicePacking = vehicleDetails['invoice_Packing'] ?? '';
            _pieceCount = vehicleDetails['piece_Count'] ?? '';
            _cartonBox = vehicleDetails['carton_boxes'] ?? '';
            _chaFetchData = vehicleDetails['cha'] ?? '';

// ✅ Bind to controllers (THIS IS IMPORTANT)
            _buyersPoController.text = _buyersPo;
            _invoicePackingController.text = _invoicePacking;
            _pieceCountController.text = _pieceCount;
            _cartonBoxesController.text = _cartonBox;
            _forwarderDetailsController.text =
                _chaFetchData; // assuming CHA = Forwarder

            _driverNameOut = vehicleDetails['driverName_OUT'] ?? 'N/A';
            _licenseNumberOut = vehicleDetails['licenseNumber_OUT'] ?? 'N/A';
            _remark = vehicleDetails['remark'] ?? 'N/A';
            _combineLoadingPoints =
                vehicleDetails['combinedLoadingPoints'] ?? 'N/A';

            // Set the processLevel (status) value
            _processLevel = vehicleDetails['status']?.toString() ??
                'N/A'; // Convert to String
            _status = vehicleDetails['status'] ?? 'N/A';

            _active = vehicleDetails['active']?.toString() ?? 'N/A';
            _createdBy = vehicleDetails['createdBy'] ?? 'N/A';

            final String status = vehicleDetails['status']?.toString() ?? 'N/A';
            final String active = vehicleDetails['active']?.toString() ?? 'N/A';
            // Logic to determine gate type
            if (_status == "1" && _active == "1" && _userDept == "Main Gate") {
              _gateType = "Main Gate";
              _showPickButtonsandSubmit = true;
            } else if (_status == "2" &&
                _active == "1" &&
                _userDept == "Fire Gate") {
              _gateType = "Fire Gate";
              _showPickButtonsandSubmit = true;
            } else if (_status == "3" && _active == "1" && _userDept == "FG") {
              _gateType = "FG IN";
              _showPickButtonsandSubmit = true;
            } else if (_status == "4" && _active == "1" && _userDept == "FG") {
              _gateType = "FG OUT";
              _showPickButtonsandSubmit = true;
              _isSubmitted = false;
              // setState(() {
              //   _gateType = "FG OUT";
              //   _showPickButtonsandSubmit = true;
              // });
            } else if (_status == "5" &&
                _active == "1" &&
                _userDept == "Fire Gate") {
              _gateType = "Fire Gate OUT";
              _showPickButtonsandSubmit = true;
            } else if (_status == "6" &&
                _active == "1" &&
                _userDept == "Main Gate") {
              _gateType = "Main Gate OUT";
              _showPickButtonsandSubmit = true;
            } else if (_status == "6" && _active == "2") {
              _gateType = "Already Vehicle Exited";
              _showPickButtonsandSubmit = false;
            } else if (_status == "0") {
              _gateType = "Export team not Approved";
              _showPickButtonsandSubmit = false;
            } else if (_status == "1") {
              _gateType = "Vehicle waiting at Main Gate In";
              _showPickButtonsandSubmit = false;
            } else if (_status == "2") {
              _gateType =
                  "Vehicle Exited from Main Gate,Waiting at Fire Gate In";
              _showPickButtonsandSubmit = false;
            } else if (_status == "3") {
              _gateType = "Vehicle Exited from Fire Gate,Waiting at FG In";
              _showPickButtonsandSubmit = false;
            } else if (_status == "4") {
              _gateType = "Vehicle Entered in FG,Waiting for Loading Complete";
              _showPickButtonsandSubmit = false;
            } else if (_status == "5") {
              _gateType = "Vehicle Exited from FG,Waiting at Fire Gate Out";
              _showPickButtonsandSubmit = false;
            } else if (_status == "6") {
              _gateType =
                  "Vehicle Exited from Fire Gate ,Waiting at Main Gate Out";
              _showPickButtonsandSubmit = false;
            }
          });
        } else {
          _showErrorDialog("Error: No vehicle details found.");
        }
      } else {
        _showErrorDialog("Error: Unable to fetch vehicle details.");
      }
    } catch (e) {
      _showErrorDialog("Failed to fetch vehicle details. Error: $e");
    } finally {
      setState(() {
        _isDetailsLoading = false;
      });
    }
  }

  void _showAlertDialog({
    required String title,
    required String message,
    required VoidCallback onOkPressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: onOkPressed,
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  List<String> _getSuggestions(String query) {
    return _vehicleNumbers
        .where((vehicle) => vehicle['vehicleNumber']!
            .toLowerCase()
            .contains(query.toLowerCase()))
        .map((vehicle) => vehicle['vehicleNumber']!)
        .toList();
  }

  /// Get Vehicle ID by Vehicle Number
  String _getVehicleIdByNumber(String vehicleNumber) {
    return _vehicleNumbers.firstWhere(
            (vehicle) => vehicle['vehicleNumber'] == vehicleNumber,
            orElse: () => {'vehicleId': ''})['vehicleId'] ??
        '';
  }

// Method to fetch the manifest details from the API
  Future<void> _fetchManifestDetails(String vehicleNumber) async {
    // final String apiUrl =
    //     'http://203.153.32.85:54329/api/GMS/ManifestReport?vehicleNo=$vehicleNumber';
    final url = '${ApiHelper.gmsUrl}ManifestReport?vehicleNo=$vehicleNumber';
    print('Manifest$url');
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the response if the API call is successful
        var data = json.decode(response.body);

        // Handle the manifest details data as needed
        print('Manifest details: $data');

        // You can update the UI or store the data here based on your requirements
        setState(() {
          // Example: Store the fetched manifest data in a variable
          _manifestData = data;
          // Bind the engine and chassis numbers to the variables
          _manifestEngineNumber =
              data['engine_No'] ?? ''; // Use empty string if key doesn't exist
          _manifestChasisNumber =
              data['chassis_No'] ?? ''; // Use empty string if key doesn't exist
        });
      } else {
        // Handle the error if the API call fails
        print('Failed to load manifest details');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("GMS Export Page"),
      //   backgroundColor: Colors.blueAccent,
      //   elevation: 4.0,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            //  mainAxisSize: MainAxisSize.min, // Keep column centered
            // crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
            children: [
              // if (_isLoading)
              //   CircularProgressIndicator(
              //     color: Colors.black,
              //   ),
              // _isLoading
              //     ? CircularProgressIndicator(
              //         color: Colors.black,
              //       )
              //     :

              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 4,
                child: TypeAheadField<String>(
                  suggestionsCallback: (pattern) {
                    return _getSuggestions(
                        pattern); // Generate suggestions based on input
                  },
                  hideOnSelect:
                      true, // Ensures the dropdown closes on selection
                  constraints: const BoxConstraints(maxHeight: 300),
                  builder: (context, controller, focusNode) {
                    controller.text =
                        _selectedVehicleNumber; // Update the field with the selected value if any
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: "Search Vehicle Numbers",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                    );
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSelected: (suggestion) {
                    setState(() {
                      _selectedVehicleNumber =
                          suggestion; // Update selected vehicle
                      _typeAheadController.text =
                          suggestion; // Update controller text

                      // here below _showPickButtonsandSubmit,_isSubmitted when user submit after vehicle search bar tap then this two values is true
                      _showPickButtonsandSubmit = true; // Show submit button
                      _isSubmitted = false; // Reset submission state
                    });
                    _focusNode.unfocus(); // Close dropdown when tapped again

                    // Close the dropdown by unfocusing the text field
                    FocusScope.of(context).requestFocus(FocusNode());
                    final vehicleId = _getVehicleIdByNumber(suggestion);

                    // Fetch manifest details using the selected vehicle number
                    _fetchManifestDetails(
                        suggestion); // Pass the selected vehicle number here

                    _fetchVehicleDetails(
                        vehicleId, _processLevel); // Fetch details
                    // Optional: If you need to clear other fields, do it here (but not the vehicle number)
                    _clearGateControllersforvechicleNumbers(); // Make sure it's only clearing necessary fields
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              if (_gateType.isNotEmpty)
                Text(
                  _gateType,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              if (_selectedVehicleNumber.isNotEmpty)
                if (_isDetailsLoading) const CircularProgressIndicator(),
              if (!_isDetailsLoading && _vehicleId.isNotEmpty) ...[
                const SizedBox(height: 16.0),

                // Main Gate
                if (_gateType == "Main Gate") ...[
                  _vehicleDetails("Vehicle ID", _vehicleId),
                  _vehicleDetails("Vehicle Number", _selectedVehicleNumber),
                  _vehicleDetails("Driver Name (IN)", _driverNameIN),
                  _vehicleDetails("Truck Number", _truckNumber),
                  _vehicleDetails("License Number (IN)", _licenseNumberIN),
                  _vehicleDetails("Vehicle Type", _vehicleType),
                  // _vehicleDetails("Container Number", _container_Number_IN),

                  // Conditionally show "Container Number" only if _container_Number_IN has data
                  if (_container_Number_IN.isNotEmpty)
                    _vehicleDetails("Container Number", _container_Number_IN),
                  // FROM_IN TextField
                  _customTextField("FROM_IN", _mainGateFromInController),

                  // STAGE_IN TextField
                  _customTextField("STAGE_IN", _mainGateStageInController),

                  // PURPOSE TextField
                  _customTextField("PURPOSE", _mainGatePurposeController),
                ]

                // Fire Gate
                else if (_gateType == "Fire Gate") ...[
                  _vehicleDetails("Vehicle ID", _vehicleId),
                  _vehicleDetails("Vehicle Type", _vehicleType),
                  // Conditionally show "Container Number" only if _container_Number_IN has data
                  if (_container_Number_IN.isNotEmpty)
                    _vehicleDetails("Container Number", _container_Number_IN),
                  // _vehicleDetails("Container Number", _container_Number_IN),
                  _vehicleDetails("Truck Number", _truckNumber),
                  _vehicleDetails("RC Number", _rcNumber),
                  _vehicleDetails("Stage In", _stageIN),
                  _vehicleDetails("Inward Serial Number", _inward_Serial_No),
                  _customTextField(
                      "Driver Pass No", _fireGateDriverPassController),
                  _customTextField(
                      "Lock Number", _fireGateLockNumberController),
                  // _customTextField("Purpose ", _fireGatePurposeController),
                  _customTextField("Purpose ", _mainGatePurposeController),

                  _customTextField(
                      "Truck License No ", _fireGateTruckLicenseController),
                  _customTextField(
                      "Destiny Country ", _fireGateDestinyController),

                  ExpansionTile(
                    title: const Text(
                      'Inspection Points',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      ..._inspectionPointsRadioButtons.keys.map((point) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Point Title
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    point,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Radio Buttons
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // "Ok" Radio Button with Label
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: "Ok",
                                            groupValue:
                                                _inspectionPointsRadioButtons[
                                                    point],
                                            onChanged: (value) {
                                              setState(() {
                                                _inspectionPointsRadioButtons[
                                                    point] = value!;
                                              });
                                            },
                                          ),
                                          const Text("Ok",
                                              style: TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                      // "Reject" Radio Button with Label
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: "Reject",
                                            groupValue:
                                                _inspectionPointsRadioButtons[
                                                    point],
                                            onChanged: (value) {
                                              setState(() {
                                                _inspectionPointsRadioButtons[
                                                    point] = value!;
                                              });
                                            },
                                          ),
                                          const Text("Reject",
                                              style: TextStyle(
                                                  fontSize:
                                                      10)), // "N/A" Radio Button (Only for Refrigeration_Unit)
                                          if (point == "Refrigeration_Unit")
                                            Row(
                                              children: [
                                                Radio<String>(
                                                  value: "N/A",
                                                  groupValue:
                                                      _inspectionPointsRadioButtons[
                                                          point],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _inspectionPointsRadioButtons[
                                                          point] = value!;
                                                    });
                                                  },
                                                ),
                                                const Text("N/A",
                                                    style: TextStyle(
                                                        fontSize: 10)),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(
                        height: 10,
                      ),
                      InspectedBarcodesWidget(
                        onBarcodeSelected: (selectedBarcode) {
                          setState(() {
                            _selectedInspectedBarcode = selectedBarcode;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ExpansionTile(
                    title: const Text(
                      'Agriculture Inspection',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      ..._agricultureInspectionRadioButtons.keys.map((point) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Inspection Point Title
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    point,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Radio Buttons
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // "Ok" Radio Button with Label
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: "Ok",
                                            groupValue:
                                                _agricultureInspectionRadioButtons[
                                                    point],
                                            onChanged: (value) {
                                              setState(() {
                                                _agricultureInspectionRadioButtons[
                                                    point] = value!;
                                              });
                                            },
                                          ),
                                          const Text("Ok",
                                              style: TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                      // "Reject" Radio Button with Label
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: "Reject",
                                            groupValue:
                                                _agricultureInspectionRadioButtons[
                                                    point],
                                            onChanged: (value) {
                                              setState(() {
                                                _agricultureInspectionRadioButtons[
                                                    point] = value!;
                                              });
                                            },
                                          ),
                                          const Text("Reject",
                                              style: TextStyle(fontSize: 10)),
                                          if (point == "Measures")
                                            Row(
                                              children: [
                                                Radio<String>(
                                                  value: "N/A",
                                                  groupValue:
                                                      _agricultureInspectionRadioButtons[
                                                          point],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _agricultureInspectionRadioButtons[
                                                          point] = value!;
                                                    });
                                                  },
                                                ),
                                                const Text("N/A",
                                                    style: TextStyle(
                                                        fontSize: 10)),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ExpansionTile(
                    title: const Text(
                      'Agriculture Checklist',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      ..._agricultureCheckListRadioButtons.keys.map((point) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Inspection Point Title
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    point,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Radio Buttons
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // "Present" Radio Button with Label
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: "Present",
                                            groupValue:
                                                _agricultureCheckListRadioButtons[
                                                    point],
                                            onChanged: (value) {
                                              setState(() {
                                                _agricultureCheckListRadioButtons[
                                                    point] = value!;
                                              });
                                            },
                                          ),
                                          const Text("Present",
                                              style: TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                      // "Not Present" Radio Button with Label
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: "Not Present",
                                            groupValue:
                                                _agricultureCheckListRadioButtons[
                                                    point],
                                            onChanged: (value) {
                                              setState(() {
                                                _agricultureCheckListRadioButtons[
                                                    point] = value!;
                                              });
                                            },
                                          ),
                                          const Text("Not Present",
                                              style: TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),

                  ExpansionTile(
                    title: const Text(
                      'Other Inspection',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      ..._otherInspections.keys.map((point) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Inspection Point Title
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    point,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Radio Buttons Section
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // "Available" Radio Button with Label
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: "Available",
                                            groupValue:
                                                _otherInspections[point],
                                            onChanged: (value) {
                                              setState(() {
                                                _otherInspections[point] =
                                                    value!;
                                              });
                                            },
                                          ),
                                          const Text("Available",
                                              style: TextStyle(fontSize: 11)),
                                        ],
                                      ),
                                      // "Not Available" Radio Button with Label
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: "Not Available",
                                            groupValue:
                                                _otherInspections[point],
                                            onChanged: (value) {
                                              setState(() {
                                                _otherInspections[point] =
                                                    value!;
                                              });
                                            },
                                          ),
                                          const Text("Not Available",
                                              style: TextStyle(fontSize: 11)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _isChecked
                              ? "Container/Truck cleaned & Used for loading"
                              : "Container/Truck cleaned & Used for loading",
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Checkbox(
                        value: _isChecked,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _isChecked = newValue ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  // Display the inspection result here
                  buildInspectionResult(),
                ]

                // FG IN
                else if (_gateType == "FG IN") ...[
                  _vehicleDetails("Vehicle ID", _vehicleId),
                  _vehicleDetails("Vehicle Type", _vehicleType),
                  _vehicleDetails("Vehicle Number", _truckNumber),

                  // Conditionally show "Container Number" only if _container_Number_IN has data
                  if (_container_Number_IN.isNotEmpty)
                    _vehicleDetails("Container Number", _container_Number_IN),

                  const SizedBox(
                    height: 10,
                  ),
                  TypeAheadField<String>(
                    suggestionsCallback: (pattern) async {
                      // Fetch the loading points if the list is empty
                      if (_allLoadingPoints.isEmpty && !_isLoading) {
                        await _fetchLoadingPoints(); // Wait until data is fetched
                      }
                      // Return the filtered list
                      return _getSuggestionsLoadingPoints(
                          pattern, _allLoadingPoints);
                    },
                    hideOnSelect: true,
                    constraints: const BoxConstraints(maxHeight: 300),
                    builder: (context, controller, focusNode) {
                      controller.text =
                          _selectedLoadingPoint; // Set initial text if any
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: "Search Loading Point",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                      );
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title:
                            Text(suggestion), // Display suggestion in dropdown
                      );
                    },
                    onSelected: (suggestion) {
                      setState(() {
                        _selectedLoadingPoint =
                            suggestion; // Update selected loading point
                        _loadingPoinstController.text =
                            suggestion; // Update controller text
                      });
                      FocusScope.of(context)
                          .unfocus(); // Optionally unfocus the text field
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InspectedBarcodesWidget(
                    onBarcodeSelected: (selectedBarcode) {
                      setState(() {
                        _selectedInspectedBarcode = selectedBarcode;
                      });
                    },
                  ),
                ]

                // FG OUT
                else if (_gateType == "FG OUT") ...[
                  _vehicleDetails("Vehicle ID", _vehicleId),
                  _vehicleDetails("Vehicle Type", _vehicleType),
                  // Conditionally show "Container Number" only if _container_Number_IN has data
                  if (_container_Number_IN.isNotEmpty)
                    _vehicleDetails("Container Number", _container_Number_IN),
                  // _vehicleDetails("Container Number", _container_Number_IN),
                  // FireGateExitManifestWidget(),

                  const SizedBox(
                    height: 10,
                  ),
                  TypeAheadField<String>(
                    suggestionsCallback: (pattern) async {
                      // Fetch the loading points if the list is empty
                      if (_allLoadingPoints.isEmpty && !_isLoading) {
                        await _fetchLoadingPoints(); // Wait until data is fetched
                      }
                      // Return the filtered list
                      return _getSuggestionsLoadingPoints(
                          pattern, _allLoadingPoints);
                    },
                    hideOnSelect: true,
                    constraints: const BoxConstraints(maxHeight: 300),
                    builder: (context, controller, focusNode) {
                      controller.text =
                          _selectedLoadingPointofFGOut; // Set initial text if any
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: "Search Loading Point",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                      );
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title:
                            Text(suggestion), // Display suggestion in dropdown
                      );
                    },
                    onSelected: (suggestion) {
                      setState(() {
                        _selectedLoadingPointofFGOut =
                            suggestion; // Update selected loading point
                        _loadingPoinstControllerforFGOUT.text =
                            suggestion; // Update controller text
                      });
                      FocusScope.of(context)
                          .unfocus(); // Optionally unfocus the text field
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InspectedBarcodesWidget(
                    onBarcodeSelected: (selectedBarcode) {
                      setState(() {
                        _selectedInspectedBarcode = selectedBarcode;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Last Loading Point ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          CustomSwitch(
                            value: _enableToggleButton,
                            onChanged: (bool val) {
                              setState(() {
                                _enableToggleButton = val;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      if (_enableToggleButton)
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "This is  last loading point",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "(ఇది చివరి లోడ్ పాయింట్)",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                ]

                // Fire Gate Out
                else if (_gateType == "Fire Gate OUT") ...[
                  _vehicleDetails("Vehicle ID", _vehicleId),
                  _vehicleDetails("Vehicle Type", _vehicleType),
                  // Conditionally show "Container Number" only if _container_Number_IN has data
                  if (_container_Number_IN.isNotEmpty)
                    _vehicleDetails("Container Number", _container_Number_IN),
                  // _vehicleDetails("Container Number", _container_Number_IN),
                  _vehicleDetails("Truck Number", _truckNumber),
                  _vehicleDetails("RC Number", _rcNumber),
                  _vehicleDetails("Outward Serial Number", _outward_Serial_No),
                  _vehicleDetails("Inward Serial Number", _inward_Serial_No),
                  _vehicleDetails("Driver IN", _driverNameIN),

                  _vehicleDetails("Licence Number IN", _licenseNumberIN),

                  _customTextFormField(
                    "VVVT Process",
                    _fireGateOutVVVTProcessController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value';
                      }
                      return null;
                    },
                  ),
                  // _customTextFormField(
                  //   "Source To",
                  //   _fireGateOutSourceToController,
                  //   (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter a value';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  _customTextFormField(
                    "Stage In",
                    _fireGateOutStageInController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _fireGateOutSourceToInTextFormField,

                    // initialValue: 'HI',

                    //controller:
                    //   _driverNameOutController, // Bind the controller to manage the input
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Source To', // Label text for the field
                    ),
                    onChanged: (text) {
                      // You can also update a variable or state if needed
                      setState(() {
                        _fireGateOutSourceToInTextFormField =
                            text; // Update the variable or field with the new value
                      });
                      // Handle the change if needed
                      print('Entered text: $text');
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    initialValue: _fireGateOutPurposeInTextFormField,

                    // initialValue: 'HI',

                    //controller:
                    //   _driverNameOutController, // Bind the controller to manage the input
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Purpose', // Label text for the field
                    ),
                    onChanged: (text) {
                      // You can also update a variable or state if needed
                      setState(() {
                        _fireGateOutPurposeInTextFormField =
                            text; // Update the variable or field with the new value
                      });
                      // Handle the change if needed
                      print('Entered text: $text');
                    },
                  ),
                  // _customTextFormField(
                  //   "Purpose",
                  //   _fireGateOutPurposeController,
                  //   (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter a value';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  _customTextFormField(
                    "Seal No",
                    _sealNoController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value';
                      }
                      return null;
                    },
                  ),
                  _customTextFormField(
                    "Linear Seal",
                    _linearSealController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value';
                      }
                      return null;
                    },
                  ),

                  _customTextFormField(
                    "Custom Seal",
                    _customSealContoller,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value';
                      }
                      return null;
                    },
                  ),

                  _customTextFormField(
                    "Other Seal ",
                    _otherSealController,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value';
                      }
                      return null;
                    },
                  ),

                  TextFormField(
                    initialValue: ' $_driverNameIN',

                    // initialValue: 'HI',

                    //controller:
                    //   _driverNameOutController, // Bind the controller to manage the input
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Driver Name OUT', // Label text for the field
                    ),
                    onChanged: (text) {
                      // You can also update a variable or state if needed
                      setState(() {
                        _driverNameIN =
                            text; // Update the variable or field with the new value
                      });
                      // Handle the change if needed
                      print('Entered text: $text');
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    initialValue: ' $_licenseNumberIN',

                    // initialValue: 'HI',

                    //controller:
                    //   _driverNameOutController, // Bind the controller to manage the input
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText:
                          'License Number OUT', // Label text for the field
                    ),
                    onChanged: (text) {
                      // You can also update a variable or state if needed
                      setState(() {
                        _licenseNumberIN =
                            text; // Update the variable or field with the new value
                      });
                      // Handle the change if needed
                      print('Entered text: $text');
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  ExpansionTile(
                    title: const Text(
                      "Manifest Check Report Details",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 20),
                    ),
                    children: [
                      _customTextField(
                          enabled: false,
                          "Invoice Packing",
                          _invoicePackingController),
                      _customTextField(
                        "Buyer's PO",
                        _buyersPoController,
                        enabled: false,
                      ),
                      _customTextField("Consignee", _consigneeController),
                      // _customTextField("Description", _descriptionController),
                      TextFormField(
                        initialValue:
                            _fireGateOutDescriptionTextFormFieldController,

                        // initialValue: 'HI',

                        //controller:
                        //   _driverNameOutController, // Bind the controller to manage the input
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Description', // Label text for the field
                        ),
                        onChanged: (text) {
                          // You can also update a variable or state if needed
                          setState(() {
                            _fireGateOutDescriptionTextFormFieldController =
                                text; // Update the variable or field with the new value
                          });
                          // Handle the change if needed
                          print('Entered text: $text');
                        },
                      ),
                      _customTextField(
                        "Piece Count",
                        _pieceCountController,
                        enabled: false,
                      ),
                      _customTextField(
                        "Carton Boxes",
                        _cartonBoxesController,
                        enabled: false,
                      ),
                      _customTextField("Gross Weight", _grossWeightController),
                      _customTextField(
                          "Forwarder Details", _forwarderDetailsController),
                      // _customTextField("Engine No", _engineNoController),
                      // _customTextField("Chassis No", _chassisNoController),
                      TextFormField(
                        initialValue: _manifestEngineNumber,

                        // initialValue: 'HI',

                        //controller:
                        //   _driverNameOutController, // Bind the controller to manage the input
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Engine No', // Label text for the field
                        ),
                        onChanged: (text) {
                          // You can also update a variable or state if needed
                          setState(() {
                            _manifestEngineNumber =
                                text; // Update the variable or field with the new value
                          });
                          // Handle the change if needed
                          print('Entered text: $text');
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        initialValue: _manifestChasisNumber,

                        // initialValue: 'HI',

                        //controller:
                        //   _driverNameOutController, // Bind the controller to manage the input
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Chassis No', // Label text for the field
                        ),
                        onChanged: (text) {
                          // You can also update a variable or state if needed
                          setState(() {
                            _manifestChasisNumber =
                                text; // Update the variable or field with the new value
                          });
                          // Handle the change if needed
                          print('Entered text: $text');
                        },
                      ),
                      _customTextField("Destination", _destinationController),

                      TextFormField(
                        controller: _combinedSealController,
                        decoration: const InputDecoration(
                          labelText: "Seal No",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _onCombinedSealChanged,
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        initialValue: _combineLoadingPoints,

                        // initialValue: 'HI',

                        //controller:
                        //   _driverNameOutController, // Bind the controller to manage the input
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText:
                              'Loading Locations', // Label text for the field
                        ),
                        onChanged: (text) {
                          // You can also update a variable or state if needed
                          setState(() {
                            _combineLoadingPoints =
                                text; // Update the variable or field with the new value
                          });
                          // Handle the change if needed
                          print('Entered text: $text');
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        initialValue: _exportManager,

                        // initialValue: 'HI',

                        //controller:
                        //   _driverNameOutController, // Bind the controller to manage the input
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText:
                              'Logistics_Manager', // Label text for the field
                        ),
                        onChanged: (text) {
                          // You can also update a variable or state if needed
                          setState(() {
                            _exportManager =
                                text; // Update the variable or field with the new value
                          });
                          // Handle the change if needed
                          print('Entered text: $text');
                        },
                      ),
                      // _exportManager
                      // _combineLoadingPoints
                      const SizedBox(
                        height: 10,
                      ),
                      InspectedBarcodesWidget(
                        onBarcodeSelected: (selectedBarcode) {
                          setState(() {
                            _selectedInspectedBarcode = selectedBarcode;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                ]

                // Main Gate OUT
                else if (_gateType == "Main Gate OUT") ...[
                  _vehicleDetails("Vehicle ID", _vehicleId),
                  _vehicleDetails("Vehicle Number", _truckNumber),
                  _vehicleDetails("Stage In", _stageIN),

                  _vehicleDetails("Source To", _sourceTo),
                  _vehicleDetails("Vehicle Type", _vehicleType),
                  _vehicleDetails("Purpose", _purpose),
                  _vehicleDetails("Linear Seal", _linearSeal),
                  _vehicleDetails("Custom Seal", _customSeal),
                  _vehicleDetails("Other Seal", _otherSeal),
                  // _vehicleDetails("Seal No", _sealNo),

                  // Conditionally show "Container Number" only if _container_Number_IN has data
                  if (_container_Number_IN.isNotEmpty)
                    _vehicleDetails("Container Number", _container_Number_IN),
                  // _vehicleDetails("Container Number", _container_Number_IN),
                  _vehicleDetails("Driver Name", _driverNameOut),
                  _vehicleDetails("Licence Number", _licenseNumberOut),
                  // _vehicleDetails("Remark", _remark),
                  _vehicleDetails("RC Number", _rcNumber),
                  _vehicleDetails("Inward Serial Number", _inward_Serial_No),

                  _vehicleDetails("Outward Serial Number", _outward_Serial_No),
                ],
              ],

              const SizedBox(height: 10.0),

              // Upload Buttons
              if (_showPickButtonsandSubmit)
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     ElevatedButton.icon(
                //       onPressed: () => _pickMedia('image'),
                //       icon: Icon(Icons.image),
                //       label: Text('Pick Images'),
                //     ),
                //     ElevatedButton.icon(
                //       onPressed: () => _pickMedia('video'),
                //       icon: Icon(Icons.videocam),
                //       label: Text('Pick Videos'),
                //     ),
                //   ],
                // ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _pickMedia('image'),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 36,
                            color: Colors.indigoAccent,
                          ), // bigger icon like Instagram
                          SizedBox(height: 4),
                          Text('Images', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _pickMedia('video'),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.video_call_outlined,
                            size: 36,
                            color: Colors.indigoAccent,
                          ),
                          SizedBox(height: 4),
                          Text('Videos', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16.0),
// Check if there are media files
              _mediaFiles.isNotEmpty
                  ? SizedBox(
                      height: 250, // Fixed height for the grid view
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal, // Horizontal scroll
                        itemCount: _mediaFiles.length, // Use _mediaFiles length
                        itemBuilder: (context, index) {
                          final file = _mediaFiles[index];
                          final fileExtension = file.path
                              .split('.')
                              .last
                              .toLowerCase(); // Get file extension
                          bool isVideoPlaying = _currentlyPlayingVideo == file;

                          return Container(
                            margin: const EdgeInsets.only(
                                right: 8.0), // Spacing between items
                            child: Stack(
                              children: [
                                // Check if the file is a video
                                fileExtension == 'mp4' || fileExtension == 'mov'
                                    ? GestureDetector(
                                        onTap: () {
                                          _playVideo(
                                              file); // Play video when tapped
                                        },
                                        child: Container(
                                          color: Colors.black12,
                                          height: 250,
                                          width:
                                              250, // Fixed size for each video thumbnail
                                          child: Center(
                                            child: isVideoPlaying &&
                                                    _videoPlayerController[
                                                            file] !=
                                                        null &&
                                                    _videoPlayerController[
                                                            file]!
                                                        .value
                                                        .isInitialized
                                                ? Container(
                                                    height:
                                                        100, // Adjust to fit video thumbnail
                                                    width: double.infinity,
                                                    child: VideoPlayer(
                                                      _videoPlayerController[
                                                          file]!,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.play_circle_fill,
                                                    size: 50), // Play icon
                                          ),
                                        ),
                                      )
                                    : Image.file(
                                        file,
                                        height: 250,
                                        width: 250,
                                        fit: BoxFit.cover,
                                      ),
                                Positioned(
                                  right: -12,
                                  top: -12,
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        // Remove the file from _mediaFiles
                                        _mediaFiles.removeAt(index);

                                        // Handle removal of video controller if it's a video
                                        if (fileExtension == 'mp4' ||
                                            fileExtension == 'mov') {
                                          if (_videoPlayerController[file] !=
                                              null) {
                                            _videoPlayerController[file]!
                                                .dispose();
                                            _videoPlayerController.remove(file);
                                          }
                                        }

                                        // Reset the currently playing video if it is the one being removed
                                        if (_currentlyPlayingVideo == file) {
                                          _currentlyPlayingVideo = null;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox
                      .shrink(), // This avoids adding unnecessary height when there are no files
              const SizedBox(
                height: 15,
              ),
              if (_imagesShows)
                SizedBox(
                  width: double.infinity, // Makes the button take full width
                  child: MaterialButton(
                    onPressed: () async {
                      // Your onPressed logic here
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GmsFilesPage(vehicleId: _vehicleId)),
                      );
                    },
                    color: Colors.lightGreen, // Background color
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners
                    ),
                    elevation: 8, // Button shadow
                    highlightElevation:
                        12, // Elevation when the button is pressed
                    splashColor: Colors.blueAccent
                        .withOpacity(0.3), // Splash color on tap
                    textColor: Colors.white,
                    child: const Text(
                      'View Files',
                      style: TextStyle(
                        fontSize: 16, // Text size
                        fontWeight: FontWeight.bold, // Text boldness
                        color: Colors.white, // Text color
                      ),
                    ), // Text color on tap
                  ),
                ),

              const SizedBox(height: 10.0),
              if (_isLoading)
                const CircularProgressIndicator(
                  color: Colors.red,
                ),
              if (_showPickButtonsandSubmit)
                _isSubmitted // this logic after submit success submit button will be hide
                    ? const SizedBox()
                    // : _isLoading // Check if loading
                    //     ? const CircularProgressIndicator() // Show loading indicator when _isLoading is true
                    : SizedBox(
                        width: double.infinity,
                        child: MaterialButton(
                          onPressed: () async {
                            // Your submit logic here for FG IN, Fire Gate OUT, or Main Gate OUT
                            _validateAndSubmit();
                            _showAlertforManifestChasisAndEngineNo(context);
                            _validateCheckList();
                            // _clearGateControllers();
                            // await submitData(
                            //     // _mainGateFromInController.text,
                            //     // _mainGateStageInController.text,
                            //     // _mainGatePurposeController.text
                            //     );
                            // await _clearGateControllers();
                            // setState(() {
                            //   _isLoading = false; // Hide the loading indicator
                            //   _isSubmitted =
                            //       true; // Mark submission as successful
                            // });

                            // setState(() {
                            //   _isLoading = true; // Start loading
                            // });

                            // if (_isLoading) CircularProgressIndicator();
                            print("Submit button pressed for $_gateType");
                          },
                          color: Colors.blue, // Background color
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 20.0), // Button padding
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30), // Rounded corners
                          ),
                          elevation: 8, // Button shadow
                          highlightElevation:
                              12, // Elevation when the button is pressed
                          splashColor: Colors.blueAccent
                              .withOpacity(0.3), // Splash color on tap
                          textColor: Colors.white,
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16, // Text size
                              fontWeight: FontWeight.bold, // Text boldness
                              color: Colors.white, // Text color
                            ),
                          ), // Text color on tap
                        ),
                      ),
              // if (_isLoading)
              //   CircularProgressIndicator(
              //     color: Colors.red,
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method for consistent styling of text rows
  Widget _vehicleDetails(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Modify TextFields to show error state
  // Widget _customTextField(
  //   String label,
  //   TextEditingController controller, {
  //   bool enabled = true,
  // }) {
  //   final isError = _highlightedControllers.contains(controller);
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: TextField(
  //       controller: controller,
  //       enabled: true,
  //       decoration: InputDecoration(
  //         labelText: label,
  //         filled: true,
  //         fillColor: Colors.grey[50],
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(8),
  //           borderSide: BorderSide(
  //             color: isError ? Colors.red : Colors.grey, // Highlight error
  //           ),
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(8),
  //           borderSide: BorderSide(
  //             color: isError ? Colors.red : Colors.grey, // Highlight error
  //           ),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(8),
  //           borderSide: BorderSide(
  //             color: isError ? Colors.red : Colors.blue, // Highlight error
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Modify TextFields to show error state + disable support and show error state
  Widget _customTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true, // 👈 NEW
  }) {
    final isError = _highlightedControllers.contains(controller);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled, // 👈 IMPORTANT
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: enabled
              ? Colors.grey[50]
              : Colors.grey[200], // 👈 grey when disabled
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.grey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _customTextFormField(String label, TextEditingController controller,
      FormFieldValidator<String>? validator) {
    final isError = _highlightedControllers.contains(controller);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: validator, // Validation logic
        autovalidateMode: AutovalidateMode
            .onUserInteraction, // Automatically validate on user interaction
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.grey, // Highlight error
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.grey, // Highlight error
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.blue, // Highlight error
            ),
          ),
        ),
      ),
    );
  }

  // Method to show alert when both fields are empty
  // void _showAlertforManifestChasisAndEngineNo(BuildContext context) {
  //   if (_manifestEngineNumber.isEmpty && _manifestChasisNumber.isEmpty) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Input Required'),
  //           content: Text(
  //               'Both fields (Engine Number and Chasis Number) are required.'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop(); // Close the alert
  //               },
  //               child: Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  // Method to show alert when both fields are empty in fire gate out
  void _showAlertforManifestChasisAndEngineNo(BuildContext context) {
    if (_gateType == "Fire Gate OUT" &&
        _manifestEngineNumber.isEmpty &&
        _manifestChasisNumber.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Input Required'),
            content: const Text(
                'Both fields (Engine Number and Chasis Number) are required.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the alert
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _validateAgricultureCheckList(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Validation Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _validateCheckList() {
    if (_gateType == "Fire Gate") {
      bool isAgricultureCheckListValid = _agricultureCheckListRadioButtons
          .values
          .every((value) => value.isNotEmpty);

      if (!isAgricultureCheckListValid) {
        _showErrorDialogInGms(
            "Please select 'Present' or 'Not Present' for all Agriculture Checklist items.");
        return;
      }
    }

    // If everything is valid, proceed with submission
    print("Form is valid! Proceeding...");
  }

  Future<void> _validateAndSubmit() async {
    // Define validation rules for each gate type
    final validationRules = {
      "Fire Gate OUT": [
        _fireGateOutVVVTProcessController,
        // _fireGateOutPurposeController,
        // _fireGateOutSourceToController,
        _fireGateOutStageInController,
        // _invoicePackingController, // for not mandatory
        // _buyersPoController, // for not mandatory
        _consigneeController,
        // _descriptionController,
        // _pieceCountController, // for not mandatory
        // _cartonBoxesController, // for not mandatory
        _grossWeightController,
        _forwarderDetailsController,
        // _engineNoController,
        // _chassisNoController,
        _destinationController,
        _combinedSealController,
      ],
      "Fire Gate": [
        _fireGateDriverPassController,
        _fireGateLockNumberController,
        // _fireGatePurposeController,
        _fireGateTruckLicenseController,
        _fireGateDestinyController,
        _mainGatePurposeController,
      ],
      "Main Gate": [
        _mainGateFromInController,
        _mainGatePurposeController,
        _mainGateStageInController,
      ],
      // Add more gate types as needed
    };
    if (_gateType == "Main Gate") {
      if (_mainGateFromInController.text.trim().isEmpty) {
        _validateAgricultureCheckList("Please Select Main gate From IN.");
        return;
      }
      if (_mainGateStageInController.text.trim().isEmpty) {
        _validateAgricultureCheckList("Please enter Main Gate Stage IN.");
        return;
      }
      if (_mainGatePurposeController.text.trim().isEmpty) {
        _validateAgricultureCheckList("Please enter Main Gate Purpose.");
        return;
      }
    }

    if (_gateType == "Fire Gate") {
      if (_fireGateDriverPassController.text.trim().isEmpty) {
        _validateAgricultureCheckList("Please Select Fire gate Driver Pass.");
        return;
      }
      if (_fireGateLockNumberController.text.trim().isEmpty) {
        _validateAgricultureCheckList("Please enter Fire Gate Lock .");
        return;
      }
      if (_mainGatePurposeController.text.trim().isEmpty) {
        _validateAgricultureCheckList("Please enter Fire Gate Purpose .");
        return;
      }
      if (_fireGateTruckLicenseController.text.trim().isEmpty) {
        _validateAgricultureCheckList("Please enter Fire Gate License Number.");
        return;
      }
      if (_fireGateDestinyController.text.trim().isEmpty) {
        _validateAgricultureCheckList("Please enter Fire Gate Destiny .");
        return;
      }
      if (_agricultureCheckListRadioButtons.isEmpty) {
        _validateAgricultureCheckList("Please Select Agriculture Checklist .");
      }
      // Check if barcode is selected
      if (_selectedInspectedBarcode.isEmpty) {
        _validateAgricultureCheckList("Please Select Barcode.");
        return; // Exit the function if no barcode is selected
      }
      // Check if all mandatory fields are selected and validated
      bool isInspectionPointsValid = _inspectionPointsRadioButtons.values.every(
          (value) =>
              value.isNotEmpty); // Check if any value is selected, not empty
      bool isAgricultureInspectionValid =
          _agricultureInspectionRadioButtons.values.every((value) =>
              value.isNotEmpty); // Check if any value is selected, not empty

      // Check if any value is selected for agriculture checklist (could be "Present", "Not Present", etc.)
      bool isAgricultureCheckListValid =
          _agricultureCheckListRadioButtons.values.any((value) =>
              value.isNotEmpty); // Check if any value is selected, not empty

      // Check if other inspections are filled (non-empty)
      bool isOtherInspectionsValid = _otherInspections.values.every((value) =>
          value.isNotEmpty); // Ensure no empty values in other inspections

      // Debug print statements to check the values of each
      print("Inspection Points Valid: $isInspectionPointsValid");
      print("Agriculture Inspection Valid: $isAgricultureInspectionValid");
      print("Agriculture Check List Valid: $isAgricultureCheckListValid");
      print("Other Inspections Valid: $isOtherInspectionsValid");

      // If all conditions are met, proceed with form submission
      if (isInspectionPointsValid &&
          isAgricultureInspectionValid &&
          isAgricultureCheckListValid &&
          isOtherInspectionsValid) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Form Submitted Successfully!")),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select all options.")),
        );
        return; // Exit the method if validation fails
      }
    }

// Mandatory image validation for gate types other than "Main Gate" and "Fire Gate"
    // if (_gateType != "Main Gate" &&
    //     _gateType != "Main Gate OUT" ||
    //     // _selectedImages.isEmpty) {
    //     _mediaFiles.isEmpty) {
    //   _showErrorDialogInGms(
    //       "Picking image is mandatory. Please select an image.");
    //   return;
    // }

    if ((_gateType == "Fire Gate" ||
            _gateType == "Fire Gate OUT" ||
            _gateType == "FG IN" ||
            // (_gateType == "FG OUT" && !_enableToggleButton)) &&
            (_gateType == "FG OUT")) &&
        _mediaFiles.isEmpty) {
      _validateAgricultureCheckList(
          "Picking image is mandatory. Please select an image.");
      return;
    }
    // if (_gateType == "FG OUT" && !_enableToggleButton) {
    //   {
    //     if (_selectedInspectedBarcode.isEmpty) {
    //       _showErrorDialogInGms("Please Select Barcode.");
    //       return;
    //     }
    //     // if(_mediaFiles.isEmpty){
    //     //   _showErrorDialogInGms(
    //     //   "Picking image is mandatory. Please select an image.");
    //     //   return;
    //     // }
    //   }

    if (_gateType == "FG OUT") {
      {
        if (_selectedInspectedBarcode.isEmpty) {
          _validateAgricultureCheckList("Please Select Barcode.");
          return;
        }
        // if(_mediaFiles.isEmpty){
        //   _showErrorDialogInGms(
        //   "Picking image is mandatory. Please select an image.");
        //   return;
        // }
      }
    }

    // Additional validation for FG IN and FG OUT gate types
    // loading point
    if (_gateType == "FG IN") {
      if (_selectedLoadingPoint.isEmpty) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //       content: Text("Please select a loading point for FG IN.")),
        // );
        _validateAgricultureCheckList(
            "Please select a loading point for FG IN.");

        return; // Exit the method to prevent form submission
      }
      // Check if the selected loading point is empty for FG OUT

      // barcode
      if (_selectedInspectedBarcode.isEmpty) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text("Please select a barcode for FG IN."),
        //   ),

        // );
        _validateAgricultureCheckList("Please select a barcode for FG IN.");
        return; // Exit the method to prevent further execution
      }
    }

    if (_gateType == "FG OUT") {
      if (_selectedLoadingPointofFGOut.isEmpty) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //       content: Text("Please select a loading point for FG OUT.")),
        // );
        _validateAgricultureCheckList(
            "Please select a loading point for FG OUT.");
        return; // Exit the method to prevent form submission
      }
    }

    if (_gateType == "Fire Gate OUT") {
      // Check if at least one of the seal fields is filled

      // if (_sealNoController.text.isEmpty &&
      //     _linearSealController.text.isEmpty &&
      //     _customSealContoller.text.isEmpty &&
      //     _otherSealController.text.isEmpty) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("Please fill at least one seal field.")),
      //   );
      //   return; // Stop further execution
      // }
      // if (_selectedInspectedBarcode.isEmpty) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("Please select an inspected barcode.")),
      //   );
      //   return; // Prevent submission
      // }

      // Perform validations only if `_inspection` is 'Pass'
      if (_inspection == 'Pass') {
        // Get the fields to validate for "Fire Gate OUT"
        final fieldsToValidate = validationRules["Fire Gate OUT"] ?? [];
        final emptyControllers = <TextEditingController>[];

        for (final controller in fieldsToValidate) {
          if (controller.text.isEmpty) {
            emptyControllers.add(controller);
          }
        }

        if (emptyControllers.isNotEmpty) {
          // Highlight the empty fields
          setState(() {
            _highlightedControllers = emptyControllers;
          });

          _validateAgricultureCheckList(
              "All fields are mandatory for 'Fire Gate OUT' when inspection is 'Pass'. Please fill in all fields.");
          return;
        }

        // Ensure at least one seal field is filled
        if (_sealNoController.text.isEmpty &&
            _linearSealController.text.isEmpty &&
            _customSealContoller.text.isEmpty &&
            _otherSealController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Please fill at least one seal field.")),
          );
          return;
        }

        // Ensure inspected barcode is selected
        if (_selectedInspectedBarcode.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Please select an inspected barcode.")),
          );
          return;
        }
      } else {
        // If inspection is not 'Pass', skip mandatory validations for "Fire Gate OUT"
        print(
            "Skipping mandatory validations for 'Fire Gate OUT' as inspection is not 'Pass'.");
      }
    }

    // Get the current validation rule based on `_gateType`
    final fieldsToValidate = validationRules[_gateType] ?? [];

    // Store empty controllers
    final emptyControllers = <TextEditingController>[];

    for (final controller in fieldsToValidate) {
      if (controller.text.isEmpty) {
        emptyControllers.add(controller);
      }
    }

    if (emptyControllers.isNotEmpty) {
      // Highlight the empty fields
      setState(() {
        _highlightedControllers = emptyControllers;
      });

      // _showErrorDialogInGms(
      //     "All fields are mandatory for $_gateType. Please fill in all fields.");
      // return;
    }

    // If all validations pass, reset highlights
    setState(() {
      _highlightedControllers = [];
    });

    // All validations passed, call submitData()
    await submitData();
    // Show success snackbar and clear controllers
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text("Form Submitted Successfully!")),
    // );
  }

// Add a list to track controllers with errors
  List<TextEditingController> _highlightedControllers = [];

  void _showErrorDialogInGms(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mandatory Fields'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  _clearGateControllers() async {
    setState(() {
      _mainGateFromInController.clear();
      _mainGateStageInController.clear();
      _mainGatePurposeController.clear();
      _sealNoController.clear();
      _linearSealController.clear();
      _customSealContoller.clear();
      _otherSealController.clear();
      _driverNameOutController.clear();
      _fireGateDriverPassController.clear();
      _fireGateLockNumberController.clear();
      _fireGatePurposeController.clear();
      _fireGateTruckLicenseController.clear();
      _fireGateDestinyController.clear();

      _fireGateOutVVVTProcessController.clear();
      _fireGateOutSourceToController.clear();
      _fireGateOutStageInController.clear();
      _fireGateOutPurposeController.clear();
      _invoicePackingController.clear();
      _buyersPoController.clear();
      _consigneeController.clear();
      _descriptionController.clear();
      _pieceCountController.clear();
      _cartonBoxesController.clear();
      _grossWeightController.clear();
      _forwarderDetailsController.clear();
      _engineNoController.clear();
      _chassisNoController.clear();
      _manifestChasisNumber = _manifestChasisNumber;
      _manifestEngineNumber = _manifestEngineNumber;

      _destinationController.clear();
      _fireGateOutPurposeInTextFormField = 'Export';
      _fireGateOutSourceToInTextFormField = 'Chennai';
      _fireGateOutDescriptionTextFormFieldController = 'Finished Goods';
      _exportManager = _exportManager;

      // Clear selected images and videos
      // _selectedImages.clear();
      // _selectedVideos.clear();
      _mediaFiles.clear();
    });
  }

  _clearGateControllersforvechicleNumbers() {
    _mainGateFromInController.clear();
    _mainGateStageInController.clear();
    _mainGatePurposeController.clear();
    _sealNoController.clear();
    _linearSealController.clear();
    _customSealContoller.clear();
    _otherSealController.clear();
    _driverNameOutController.clear();
    _fireGateDriverPassController.clear();
    _fireGateLockNumberController.clear();
    _fireGatePurposeController.clear();
    _fireGateTruckLicenseController.clear();
    _fireGateDestinyController.clear();

    _fireGateOutVVVTProcessController.clear();
    _fireGateOutSourceToController.clear();
    _fireGateOutStageInController.clear();
    _fireGateOutPurposeController.clear();
    // Clear selected images and videos
    // _selectedImages.clear();
    // _selectedVideos.clear();
    _mediaFiles.clear();
  }

  Future<void> submitData() async {
    setState(() {
      _isLoading = true; // Start loading ind icator
    });
    // submitData() async {
    var apiUrl = '${ApiHelper.gmsUrl}SaveDetails';
    // var apiUrl =
    //     'http://10.3.0.208:8084/api/GMS/SaveDetails'; // Replace with your API URL

    if (_gateType == "FG IN") {
      loadingAreas = _loadingPoinstController.text;
    } else if (_gateType == "FG OUT") {
      loadingAreas = _loadingPoinstControllerforFGOUT.text;
    }
    // Create the data to be sent
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..fields['VehicleId'] = _vehicleId
      ..fields['VehicleNumber'] = _truckNumber
      ..fields['DriverName_IN'] = _driverNameIN
      ..fields['LicenseNumber_IN'] = _licenseNumberIN
      ..fields['VehicleType'] = _vehicleType
      ..fields['ProcessLevel'] = _processLevel
      ..fields['LoginBarcode'] = _barcode
      ..fields['Status'] = _status
      ..fields['CreatedBy'] = _createdBy
      ..fields['MainGateEntry'] = _mainGateEntry
      ..fields['MainGateExit'] = _mainGateExit
      ..fields['FireGateEntry'] = _fireGateEntry
      ..fields['FireGateExit'] = _firegateExit
      ..fields['FGEntry'] = _FGEntry
      ..fields['FGExit'] = _FGExit
      ..fields['FROM_IN'] = _mainGateFromInController.text
      ..fields['STAGE_IN'] = _mainGateStageInController.text
      // if(_status=='1'){
      //         ..fields['PURPOSE'] = _mainGatePurposeController.text
      // }
      ..fields['PURPOSE'] = _mainGatePurposeController.text

      // Fire Gate details DriverPassNo
      ..fields['DriverPassNo'] = _fireGateDriverPassController.text
      ..fields['LockNo'] = _fireGateLockNumberController.text
      // ..fields['PURPOSE'] = _mainGatePurposeController.text
      ..fields['Truck_License_No'] = _fireGateTruckLicenseController.text
      ..fields['Destination_Country'] = _fireGateDestinyController.text
      ..fields['Inspected_By'] = _selectedInspectedBarcode
      ..fields['MaxInwardNo'] = _inward_Serial_No
      ..fields['InspectionResult'] = getInspectionResult()
      ..fields['Container_No'] = _container_Number_IN

      // Fire Gate Inspection Points
      ..fields['Bumper'] = _inspectionPointsRadioButtons['Bumper'] ?? ''
      ..fields['Engine'] = _inspectionPointsRadioButtons['Engine'] ?? ''
      ..fields['Tires'] = _inspectionPointsRadioButtons['Tires'] ?? ''
      ..fields['Floors_of_the_Cab'] =
          _inspectionPointsRadioButtons['Floors of the cab'] ?? ''
      ..fields['Fuel_Tanks'] = _inspectionPointsRadioButtons['Fuel Tanks'] ?? ''
      ..fields['Outside_and_Inside_of_the_Cab'] =
          _inspectionPointsRadioButtons['Outside and inside of the cab'] ?? ''
      ..fields['Air_Tank'] = _inspectionPointsRadioButtons['Air tank'] ?? ''
      ..fields['Drive_Shafts'] =
          _inspectionPointsRadioButtons['Drive Shafts'] ?? ''
      ..fields['Fifth_Wheel'] =
          _inspectionPointsRadioButtons['Fifth Wheel'] ?? ''
      ..fields['Outside_OR_Undercarriage'] =
          _inspectionPointsRadioButtons['Outside and inside of the cab'] ?? ''
      ..fields['Floors_of_the_Container_OR_Box_of_the_Truck'] =
          _inspectionPointsRadioButtons[
                  'Floors_of_the_Container_OR_Box_of_the_Truck'] ??
              ''
      ..fields[
              'Inside_and_Outside_of_the_door_of_the_container_OR_Box_of_the_Truck'] =
          _inspectionPointsRadioButtons[
                  'Inside_and_Outside_of_the_door_of_the_container_OR_Box_of_the_Truck'] ??
              ''
      ..fields['Side_wall_of_the_Container_OR_Box_of_the_Truck'] =
          _inspectionPointsRadioButtons[
                  'Side_wall_of_the_Container_OR_Box_of_the_Truck'] ??
              ''
      ..fields[
              'Inside_Ceiling_and_Outside_roof_of_the_Container_OR_Box_of_the_Truck'] =
          _inspectionPointsRadioButtons[
                  'Inside_Ceiling_and_Outside_roof_of_the_Container_OR_Box_of_the_Truck'] ??
              ''
      ..fields['Front_Wall_of_the_Container_OR_Box_of_the_Truck'] =
          _inspectionPointsRadioButtons[
                  'Front_Wall_of_the_Container_OR_Box_of_the_Truck'] ??
              ''
      ..fields['Refrigeration_Unit'] =
          _inspectionPointsRadioButtons['Refrigeration_Unit'] ?? ''
      ..fields['Exhaust'] = _inspectionPointsRadioButtons['Exhaust'] ?? ''

      // Agriculture Inspection
      ..fields['Contamination'] =
          _agricultureInspectionRadioButtons['Contamination'] ?? ''
      ..fields['Measures'] =
          _agricultureInspectionRadioButtons['Measures'] ?? ''

      // Agriculture Checklist
      ..fields['Plants'] = _agricultureCheckListRadioButtons['Plants'] ?? 'N/A'
      ..fields['Seeds'] = _agricultureCheckListRadioButtons['Seeds'] ?? ''
      ..fields['Egg_Masses'] =
          _agricultureCheckListRadioButtons['Egg_Masses'] ?? ''
      ..fields['Insects'] = _agricultureCheckListRadioButtons['Insects'] ?? ''
      ..fields['Snails'] = _agricultureCheckListRadioButtons['Snails'] ?? ''
      ..fields['Animals'] = _agricultureCheckListRadioButtons['Animals'] ?? ''
      ..fields['Animal_Droppings'] =
          _agricultureCheckListRadioButtons['Animal_Droppings'] ?? ''
      ..fields['Sand'] = _agricultureCheckListRadioButtons['Sand'] ?? ''
      ..fields['Soil'] = _agricultureCheckListRadioButtons['Soil'] ?? ''
      ..fields['Liquid'] = _agricultureCheckListRadioButtons['Liquid'] ?? ''
      // ..fields['Liquid_Oil_OR_Water'] =
      //     _agricultureCheckListRadioButtons['Liquid_Oil_OR_Water'] ?? ''
      ..fields["Truck_Cleaned"] = _isChecked ? 'True' : 'False'
      ..fields['Truck_Refused'] = _truckRefused ? 'True' : 'False'

      // Other Inspections
      ..fields['First_Aid'] = _otherInspections['First_Aid'] ?? ''
      ..fields['Fire_Extinguisher'] =
          _otherInspections['Fire_Extinguisher'] ?? ''
      ..fields['Pollution_Certificate'] =
          _otherInspections['Pollution_Certificate'] ?? ''
      ..fields['Explosive_Certificate'] =
          _otherInspections['Explosive_Certificate'] ?? ''
      ..fields['Vehicle_License'] = _otherInspections['Vehicle_License'] ?? ''

      // FG In & Out

      ..fields['LoadingPoint'] = loadingAreas
      ..fields['LoadingCompleted'] = _enableToggleButton ? 'True' : 'False'
      ..fields['ImageBarcode'] = _selectedInspectedBarcode

      // FireGate Out
      ..fields['MaxOutwardNo'] = _outward_Serial_No
      ..fields['VVT_Process'] = _fireGateOutVVVTProcessController.text
      // ..fields['SourceTo'] = _fireGateOutSourceToController.text
      ..fields['SourceTo'] = _fireGateOutSourceToInTextFormField
      ..fields['StageTo'] = _fireGateOutStageInController.text
      // ..fields['PurposeTo'] = _fireGateOutPurposeController.text
      ..fields['PurposeTo'] = _fireGateOutPurposeInTextFormField
      ..fields['SealNo'] = ''
      ..fields['LinearSeal'] = _linearSealController.text
      ..fields['CustomSeal'] = _customSealContoller.text
      ..fields['OtherSeal'] = _otherSealController.text
      ..fields['SerialNo'] = _combinedSealController.text
      ..fields['DriverOutNo'] = _driverNameIN
      ..fields['LicenseOutNo'] = _licenseNumberIN
      ..fields['Invoice_Packing'] = _invoicePackingController.text
      ..fields['Buyers_Po'] = _buyersPoController.text
      ..fields['Consignee'] = _consigneeController.text
      // ..fields['Description'] = _descriptionController.text
      ..fields['Description'] = _fireGateOutDescriptionTextFormFieldController

      // _fireGateOutDefaultTextFormFieldController
      ..fields['Piece_Count'] = _pieceCountController.text
      ..fields['Carton_Boxes'] = _cartonBoxesController.text
      ..fields['Gross_Weight'] = _grossWeightController.text
      ..fields['Forwarder_Details'] = _forwarderDetailsController.text
      // ..fields['Engine_No'] = _engineNoController.text
      // ..fields['Chassis_No'] = _chassisNoController.text
      ..fields['Engine_No'] = _manifestEngineNumber
      ..fields['Chassis_No'] = _manifestChasisNumber
      ..fields['Destination'] = _destinationController.text
      ..fields['Seal_No_Report'] = _combinedSealController.text
      ..fields['LoadingLocations'] = _combineLoadingPoints
      ..fields['Security_Guard'] = _selectedInspectedBarcode
      ..fields['Logistics_Manager'] = _exportManager;

    // Add files as multipart form data (if any)
    if (_mediaFiles.isNotEmpty) {
      // for (File file in _mediaFiles) {
      // Iterate over a copy of the list to avoid modifying it during iteration
      for (File file in List.from(_mediaFiles)) {
        try {
          var fileStream = http.ByteStream(file.openRead());
          var length = await file.length();
          var multipartFile = http.MultipartFile('Files', fileStream, length,
              filename: file.uri.pathSegments.last);

          request.files.add(multipartFile);
          print('files print ${request.files}');
        } catch (e) {
          print("Error adding file: $e");
        }
      }
    }

    print('This is the request data: ${request.fields}');

    try {
      // Send POST request with multipart/form-data
      var response = await request.send();

      // Process the response
      if (response.statusCode == 200) {
        // Decode the response to extract the message
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = jsonDecode(responseBody);

        final message =
            decodedResponse['message'] ?? 'Operation completed successfully.';

        // Check the server message
        if (message == "Saved Successfully" ||
            message == "Images Uploaded Successfully") {
          // Show success SnackBar
          setState(() {
            _isSubmitted = true; // Hide the button after submission
            // _isLoading=false;
          });
          _selectedLoadingPoint = '';
          _selectedLoadingPointofFGOut = '';
          // _loadingPoinstControllerforFGOUT.text = '';
          // _loadingPoinstController.text = '';
          _selectedInspectedBarcode = '';
          loadingAreas = ''; // after success loading area is empty
          _gateType = ""; // after submit fields are hide
          _showPickButtonsandSubmit =
              false; // after submit this pick images and videos button hide
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Images and Data Saved Successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _clearGateControllers(); // Clear form controllers if applicable
        } else {
          // Unexpected success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unexpected response: $message'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Error response
        final errorBody = await response.stream.bytesToString();
        final decodedError = jsonDecode(errorBody);

        final errorMessage =
            decodedError['message'] ?? 'Failed to submit data.';

        // Show error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // General exception handling
      print('Error during submission: $e');
      debugPrintStack(label: 'Debugging Error Stack:', maxFrames: 20);

      // Show error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset loading state
      setState(() {
        _isLoading = false; // Stop loading indicator
      });
    }
  }
}
