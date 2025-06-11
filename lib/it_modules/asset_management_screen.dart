import 'dart:io';

import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AssetManagementScreen extends StatefulWidget {
  final LoginModelApi userData;

  const AssetManagementScreen({Key? key, required this.userData})
      : super(key: key);

  @override
  State<AssetManagementScreen> createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, String>> assetItems = [];

  List<String> assetIds = [];
  String? selectedAssetId;
  String? email;
  String? phone;
  // final List<String> assetIds = ['A001', 'A002', 'A003', 'A004'];
  List<String> plantNames = [];
  String? selectedPlant;
  final TextEditingController _assetSearchController = TextEditingController();
  final TextEditingController _plantSearchController = TextEditingController();

  // final List<String> plantNames = [
  //   'Admin',
  //   'HR Buillding',
  //   'Plant1',
  //   'Plant2',
  //   'Plant3',
  //   'Plant4',
  //   'Plant5',
  // ];
  final List<String> networkIssues = [
    'No Internet',
    'Slow Speed',
    'Disconnected'
  ];
  final List<String> desktopIssues = [
    'Not Booting',
    'Blue Screen',
    'Keyboard Issue'
  ];
  @override
  void initState() {
    super.initState();
    fetchAssetDropdown();
    fetchPlantDropdown(); // fetch plants
  }

  Future<void> fetchAssetDropdown() async {
    const String url = 'http://10.3.0.70:9093/api/Login/GetAssetDropdown';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          assetItems = data.map<Map<String, String>>((item) {
            return {
              'id': item['asseT_ID'],
              'name': item['asseT_NAME'],
            };
          }).toList();
        });
      } else {
        print('Failed to load asset IDs. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching asset IDs: $e');
    }
  }

  DateTime selectedDate = DateTime.now();

  String selectedType = 'Network';
  String? selectedIssue;
  String? description;

  final List<String> priorityItems = ['High', 'Medium','Low'];
  String? selectedPriority;

  List<File> _selectedImages = [];
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // void _showPickerOptions(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (_) => SafeArea(
  //       child: Wrap(
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.photo_library),
  //             title: const Text('Pick from Gallery'),
  //             onTap: () {
  //               Navigator.of(context).pop();
  //               _pickImage(ImageSource.gallery);
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.camera_alt),
  //             title: const Text('Take a Photo'),
  //             onTap: () {
  //               Navigator.of(context).pop();
  //               _pickImage(ImageSource.camera);
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.image,
                );

                if (result != null) {
                  setState(() {
                    _selectedImages =
                        result.paths.map((path) => File(path!)).toList();
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.camera);

                if (pickedFile != null) {
                  setState(() {
                    _selectedImages.add(File(pickedFile.path));
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchPlantDropdown() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.3.0.70:9093/api/Login/GetAssetLocationDropdown'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Combine plant and line names, then make them unique
        plantNames = data
            .map<String>(
                (item) => "${item['asseT_PLANT']} - ${item['asseT_LINE']}")
            .toSet()
            .toList();
        setState(() {});
      } else {
        throw Exception('Failed to load plant names');
      }
    } catch (e) {
      print('Error fetching plant dropdown: $e');
    }
  }

  // Future<void> submitAssetData() async {
  //   // Combine issue + description into one string
  //   final combinedDescription = selectedIssue != null && description != null
  //       ? "$selectedIssue: $description"
  //       : null;

  //   if (selectedAssetId == null ||
  //       selectedPlant == null ||
  //       combinedDescription == null ||
  //       combinedDescription.isEmpty ||
  //       selectedIssue == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           content: Text('Please complete all fields before submitting.')),
  //     );
  //     return;
  //   }

  //   const url = 'http://10.3.0.70:9093/api/Login/InsertIncidentRecords';
  //   // 🔁 Convert images to base64 strings
  //   List<String> base64Images = [];
  //   for (File image in _selectedImages) {
  //     List<int> imageBytes = await image.readAsBytes();
  //     base64Images.add(base64Encode(imageBytes));
  //   }

  //   final Map<String, dynamic> payload = {
  //     "barcode": widget.userData.empNo,
  //     "assetId": selectedAssetId.toString(), // or just "string" if testing
  //     "incidentDate":
  //         DateFormat('dd/MM/yyyy').format(selectedDate), // ✅ Only date
  //     "reportedBy": widget.userData.empNo.toString(),
  //     "description": combinedDescription,
  //     // "issueType": selectedType,
  //     "issueType": selectedType, // ✅ Use selectedType with correct key
  //     "locationName": selectedPlant.toString(),
  //     "email": emailController.text.trim(), // ← from TextField
  //     "mobile": phoneController.text.trim(), // ← from TextField
  //     "priority": selectedPriority, // ✅ new field
  //     "images": base64Images, // ✅ new field
  //   };
  //   print('Submit asset data${payload}');
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(payload),
  //     );

  //     if (response.statusCode == 200) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Asset Data submitted successfully!')),
  //       );
  //       setState(() {
  //         _assetSearchController.clear();
  //         _plantSearchController.clear();
  //         selectedAssetId = null;
  //         selectedPlant = null;
  //         selectedIssue = null;
  //         description = null;
  //         emailController.clear();
  //         phoneController.clear();
  //         _selectedImages.clear();
  //       });
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text('Failed to submit incident: ${response.body}')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error submitting incident: $e')),
  //     );
  //   }
  // }

  Future<void> submitAssetData() async {
    if (selectedAssetId == null ||
        selectedPlant == null ||
        selectedIssue == null ||
        description == null ||
        description!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete all fields before submitting.')),
      );
      return;
    }

    const url = 'http://10.3.0.70:9093/api/Login/InsertIncidentRecords';
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add form fields
    request.fields['barcode'] = widget.userData.empNo.toString();
    request.fields['assetId'] = selectedAssetId.toString();
    request.fields['incidentDate'] =
        DateFormat('dd/MM/yyyy').format(selectedDate);
    request.fields['reportedBy'] = widget.userData.empNo.toString();
    request.fields['Created_By'] = widget.userData.empNo.toString();
    request.fields['description'] = "$selectedIssue: $description";
    request.fields['issueType'] = selectedType ?? "";
    request.fields['locationName'] = selectedPlant.toString();
    request.fields['email'] = emailController.text.trim();
    request.fields['mobile'] = phoneController.text.trim();
    request.fields['priority'] = selectedPriority ?? "";
    // request.fields['files'] = _selectedImages;

    // 🔽 Print the fields
    print("🔽 Submitting Incident Data:");
    print("Barcode: ${widget.userData.empNo}");
    print("Asset ID: $selectedAssetId");
    print("Incident Date: $selectedDate");
    print("Reported By: ${widget.userData.empNo}");
    print("Description: $description");
    print("Issue Type: $selectedType");
    print("Location: $selectedPlant");
    print("Email: ${emailController.text.trim()}");
    print("Mobile: ${phoneController.text.trim()}");
    print("Priority: $selectedPriority");
    // Attach image files
    // for (int i = 0; i < _selectedImages.length; i++) {
    //   File imageFile = _selectedImages[i];
    //   String fileName = imageFile.path.split('/').last;

    //   request.files.add(
    //     await http.MultipartFile.fromPath(
    //       'images', // ✅ Must match the expected field name in your backend
    //       imageFile.path,
    //       filename: fileName,
    //     ),
    //   );
    // }

    // Add image files
    for (var file in _selectedImages) {
      request.files.add(await http.MultipartFile.fromPath(
        'files', // The key used in your backend to receive the file

        file.path,
        contentType:
            MediaType('image', 'jpeg'), // or adjust based on actual file type
      ));
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print("🔁 Server response: ${response.statusCode}");
      print("🔁 Response body: ${response.body}");
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asset Data submitted successfully!')),
        );

        setState(() {
          _assetSearchController.clear();
          _plantSearchController.clear();
          selectedAssetId = null;
          selectedPlant = null;
          selectedIssue = null;
          description = null;
          emailController.clear();
          phoneController.clear();
          _selectedImages.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to submit incident: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting incident: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(title: const Text("Asset Management")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Center(
                //   child: Text(
                //     widget.userData.empNo,
                //     style: const TextStyle(
                //         fontSize: 20, fontWeight: FontWeight.bold),
                //   ),
                // ),
                // const SizedBox(height: 20),

                /// Date Picker
                Text('Selected Date',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: Text(formattedDate)),
                    IconButton(
                      icon: const Icon(Icons.calendar_today,
                          color: Colors.lightGreen),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    )
                  ],
                ),

                const SizedBox(height: 20),

                /// Asset ID Dropdown
                Text('Asset ID',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),

                DropDownSearchField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller:
                        _assetSearchController, // Add this TextEditingController
                    autofocus: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: "Search Asset ID",
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (text) {
                      setState(() {
                        if (text.isEmpty) {
                          selectedAssetId = null; // Reset selection
                        }
                      });
                    },
                  ),
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty) {
                      return assetItems;
                    }
                    // Filter list based on pattern
                    return assetItems.where((item) {
                      final combined =
                          '${item['name']} (${item['id']})'.toLowerCase();
                      return combined.contains(pattern.toLowerCase());
                    }).toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: const Icon(Icons.inventory),
                      title:
                          Text('${suggestion['name']} (${suggestion['id']})'),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      selectedAssetId = suggestion['id'];
                      _assetSearchController.text =
                          '${suggestion['name']} (${suggestion['id']})';
                    });
                    print("Selected Asset ID: $selectedAssetId");
                  },
                  displayAllSuggestionWhenTap: true,
                  isMultiSelectDropdown: false,
                ),

                const SizedBox(height: 20),

                /// Plant Dropdown
                Text('Select Plant:',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                DropDownSearchField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller:
                        _plantSearchController, // Define this controller in your state
                    autofocus: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: "Search Plant",
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (text) {
                      setState(() {
                        if (text.isEmpty) {
                          selectedPlant = null; // Reset if cleared
                        }
                      });
                    },
                  ),
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty) {
                      return plantNames;
                    }
                    return plantNames
                        .where((plant) =>
                            plant.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: const Icon(Icons.factory),
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      selectedPlant = suggestion;
                      _plantSearchController.text = suggestion;
                    });
                    print("Selected Plant: $selectedPlant");
                  },
                  displayAllSuggestionWhenTap: true,
                  isMultiSelectDropdown: false,
                ),

                const SizedBox(height: 20),

                /// Type (Radio)
                Text('Select Type:',
                    style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: ['Network', 'Desktop'].map((type) {
                    return Row(
                      children: [
                        Radio<String>(
                          value: type,
                          groupValue: selectedType,
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                              selectedIssue = null;
                            });
                          },
                        ),
                        Text(type),
                      ],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                /// Issue Dropdown
                Text('Issue', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: const Text('Select an Issue'),
                    value: selectedIssue,
                    items: (selectedType == 'Network'
                            ? networkIssues
                            : desktopIssues)
                        .map((issue) {
                      return DropdownMenuItem(value: issue, child: Text(issue));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedIssue = value),
                    buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      width: MediaQuery.of(context).size.width - 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                /// Description
                if (selectedIssue != null) ...[
                  const SizedBox(height: 20),
                  Text('Description',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  TextField(
                    onChanged: (value) => setState(() => description = value),
                    decoration: InputDecoration(
                      hintText: 'Describe the issue...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    maxLines: 3,
                  ),
                ],
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded:
                        true, // 🔥 This makes the button take full available width
                    hint: const Text(
                      'Select Priority',
                      style: TextStyle(
                        fontSize: 16,
                        // color: Colors.grey,
                      ),
                    ),
                    items: priorityItems
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ))
                        .toList(),
                    value: selectedPriority,
                    onChanged: (value) {
                      setState(() {
                        selectedPriority = value;
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      width: MediaQuery.of(context).size.width - 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(height: 20),
                Text('Email', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => setState(() => email = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    suffixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Phone', style: Theme.of(context).textTheme.titleMedium),

                const SizedBox(height: 6),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => setState(() => phone = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    final phoneRegex =
                        RegExp(r'^\d{10}$'); // Accepts only 10 digits
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    suffixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                // if (_imageFile != null)
                //   Image.file(_imageFile!, height: 200, fit: BoxFit.cover)
                // else
                //   const

                // _imageFile != null
                //     ? Stack(
                //         children: [
                //           Image.file(
                //             _imageFile!,
                //             height: 200,
                //             // width: double.infinity,
                //             fit: BoxFit.cover,
                //           ),
                //           Positioned(
                //             top: 8,
                //             right: 8,
                //             child: GestureDetector(
                //               onTap: () {
                //                 setState(() {
                //                   _imageFile = null;
                //                 });
                //               },
                //               child: Container(
                //                 decoration: BoxDecoration(
                //                   color: Colors.black.withOpacity(0.5),
                //                   shape: BoxShape.circle,
                //                 ),
                //                 child: const Padding(
                //                   padding: EdgeInsets.all(4.0),
                //                   child: Icon(
                //                     Icons.close,
                //                     color: Colors.white,
                //                     size: 20,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ],
                //       )
                //     : const Text("No image selected"),

                _selectedImages.isNotEmpty
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _selectedImages.map((image) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Image.file(
                                    image,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImages.remove(image);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        // color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      )
                    : const Center(child: Text("No images selected")),

                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity, // Makes the button take full width
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.image,
                      size: 24,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Choose Image",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.all(
                          14), // Equal padding on all sides
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () => _showPickerOptions(context),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: MaterialButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Your logic here
                        submitAssetData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please fix validation errors before submitting.')),
                        );
                      }
                    },
                    color: Colors.blueAccent,
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// below code bloc pattern UI CODE
// import 'package:animated_movies_app/it_modules/bloc/asset_bloc.dart';
// import 'package:animated_movies_app/it_modules/bloc/asset_event.dart';
// import 'package:animated_movies_app/it_modules/bloc/asset_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';

// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';

// class AssetManagementScreen extends StatefulWidget {
//   final LoginModelApi userData;

//   const AssetManagementScreen({Key? key, required this.userData})
//       : super(key: key);

//   @override
//   State<AssetManagementScreen> createState() => _AssetManagementScreenState();
// }

// class _AssetManagementScreenState extends State<AssetManagementScreen> {
//   // final List<String> assetIds = ['A001', 'A002', 'A003', 'A004'];

//   final List<String> plantNames = [
//     'Admin',
//     'HR Buillding',
//     'Plant1',
//     'Plant2',
//     'Plant3',
//     'Plant4',
//     'Plant5',
//   ];
//   final List<String> networkIssues = [
//     'No Internet',
//     'Slow Speed',
//     'Disconnected'
//   ];
//   final List<String> desktopIssues = [
//     'Not Booting',
//     'Blue Screen',
//     'Keyboard Issue'
//   ];

//   String selectedType = 'Network';
//   String? selectedIssue;
//   String? selectedPlants;
//   late final String? email;
//   late final String? phone;
// @override
// void initState() {
//   super.initState();
//   context.read<AssetBloc>().add(FetchAssetIds());
// }
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => AssetBloc(),
//       child: Scaffold(
//         body: BlocBuilder<AssetBloc, AssetState>(
//           builder: (context, state) {
//             final formattedDate =
//                 DateFormat('yyyy-MM-dd').format(state.selectedDate);
//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Card(
//                 elevation: 6,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Text(
//                           widget.userData.empNo,
//                           style: const TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),

//                       Text('Selected Date',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       const SizedBox(height: 6),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(formattedDate,
//                                 style: const TextStyle(fontSize: 16)),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.calendar_today),
//                             color: Colors.lightGreen,
//                             onPressed: () async {
//                               final pickedDate = await showDatePicker(
//                                 context: context,
//                                 initialDate: state.selectedDate,
//                                 firstDate: DateTime(2000),
//                                 lastDate: DateTime.now(),
//                               );
//                               if (pickedDate != null) {
//                                 context
//                                     .read<AssetBloc>()
//                                     .add(DateChanged(pickedDate));
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Text('Asset ID',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       const SizedBox(height: 6),
//                       state.assetIds.isEmpty
//                           ? const Center(child: CircularProgressIndicator())
//                           : 
//                           DropdownButtonHideUnderline(
//                               child: DropdownButton2<String>(
//                                 isExpanded: true,
//                                 hint: const Text('Select Asset ID'),
//                                 value: state.selectedAssetId,
//                                 // items: assetIds.map((String item) {
//                                 items: state.assetIds.map((String item) {
//                                   return DropdownMenuItem<String>(
//                                     value: item,
//                                     child: Text(item),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? value) {
//                                   if (value != null) {
//                                     context
//                                         .read<AssetBloc>()
//                                         .add(AssetIdChanged(value));
//                                   }
//                                 },
//                                 buttonStyleData: ButtonStyleData(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 14),
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10),
//                                     border: Border.all(color: Colors.grey),
//                                   ),
//                                 ),
//                                 dropdownStyleData: DropdownStyleData(
//                                   width: MediaQuery.of(context).size.width - 70,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                       const SizedBox(height: 20),
//                       Text('Select Plant:',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       DropdownButtonHideUnderline(
//                         child: DropdownButton2<String>(
//                           isExpanded: true,
//                           hint: const Text('Select Plant'),
//                           value: selectedPlants,
//                           items: plantNames
//                               .map((plant) => DropdownMenuItem(
//                                     value: plant,
//                                     child: Text(plant),
//                                   ))
//                               .toList(),
//                           // onChanged: (value) {
//                           //   setState(() {
//                           //     selectedIssue = value;
//                           //   });
//                           // },
//                           onChanged: (value) {
//                             setState(() {
//                               selectedPlants = value;
//                             });
//                             if (value != null) {
//                               context
//                                   .read<AssetBloc>()
//                                   .add(PlantChanged(value));
//                             }
//                           },
//                           buttonStyleData: ButtonStyleData(
//                             padding: const EdgeInsets.symmetric(horizontal: 14),
//                             height: 50,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: Colors.grey),
//                             ),
//                           ),
//                           dropdownStyleData: DropdownStyleData(
//                             width: MediaQuery.of(context).size.width - 70,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       /// 1. Select Type (Radio buttons)
//                       Text('Select Type:',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       Row(
//                         children: ['Network', 'Desktop'].map((type) {
//                           return Row(
//                             children: [
//                               Radio<String>(
//                                 value: type,
//                                 groupValue: selectedType,
//                                 // onChanged: (value) {
//                                 //   setState(() {
//                                 //     selectedType = value!;
//                                 //     selectedIssue = null;
//                                 //   });
//                                 // },
//                                 onChanged: (value) {
//                                   setState(() {
//                                     selectedType = value!;
//                                     selectedIssue = null;
//                                   });
//                                   context
//                                       .read<AssetBloc>()
//                                       .add(AssetTypeChanged(value!));
//                                 },
//                               ),
//                               Text(type),
//                             ],
//                           );
//                         }).toList(),
//                       ),

//                       /// 2. Issue Dropdown
//                       const SizedBox(height: 10),
//                       Text('Issue',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       const SizedBox(height: 6),
//                       DropdownButtonHideUnderline(
//                         child: DropdownButton2<String>(
//                           isExpanded: true,
//                           hint: const Text('Select an Issue'),
//                           value: selectedIssue,
//                           items: (selectedType == 'Network'
//                                   ? networkIssues
//                                   : desktopIssues)
//                               .map((issue) => DropdownMenuItem(
//                                     value: issue,
//                                     child: Text(issue),
//                                   ))
//                               .toList(),
//                           // onChanged: (value) {
//                           //   setState(() {
//                           //     selectedIssue = value;
//                           //   });
//                           // },
//                           onChanged: (value) {
//                             setState(() {
//                               selectedIssue = value;
//                             });
//                             if (value != null) {
//                               context
//                                   .read<AssetBloc>()
//                                   .add(IssueTypeChanged(value));
//                             }
//                           },
//                           buttonStyleData: ButtonStyleData(
//                             padding: const EdgeInsets.symmetric(horizontal: 14),
//                             height: 50,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: Colors.grey),
//                             ),
//                           ),
//                           dropdownStyleData: DropdownStyleData(
//                             width: MediaQuery.of(context).size.width - 70,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       ),

//                       /// 3. Show Description only if issue is selected
//                       if (selectedIssue != null) ...[
//                         const SizedBox(height: 20),
//                         Text('Description',
//                             style: Theme.of(context).textTheme.titleMedium),
//                         const SizedBox(height: 6),
//                         TextField(
//                           onChanged: (value) {
//                             context
//                                 .read<AssetBloc>()
//                                 .add(DescriptionChanged(value));
//                           },
//                           decoration: InputDecoration(
//                             hintText: 'Describe the issue...',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 14, vertical: 12),
//                           ),
//                           maxLines: 3,
//                         ),
//                       ],
//                       // Text('Description',
//                       //     style: Theme.of(context).textTheme.titleMedium),
//                       // const SizedBox(height: 6),
//                       // TextField(
//                       //   onChanged: (value) {
//                       //     context
//                       //         .read<AssetBloc>()
//                       //         .add(DescriptionChanged(value));
//                       //   },
//                       //   decoration: InputDecoration(
//                       //     hintText: 'Enter description...',
//                       //     border: OutlineInputBorder(
//                       //       borderRadius: BorderRadius.circular(10),
//                       //     ),
//                       //     contentPadding: const EdgeInsets.symmetric(
//                       //         horizontal: 14, vertical: 12),
//                       //   ),
//                       //   maxLines: 3,
//                       // ),

//                       const SizedBox(height: 20),
//                       Text('Gmail',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       const SizedBox(height: 6),
//                       TextField(
//                         keyboardType: TextInputType.emailAddress,
//                         onChanged: (value) {
//                           context.read<AssetBloc>().add(EmailChanged(value));
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Enter Gmail address',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 14, vertical: 12),
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                       Text('Phone Number',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       const SizedBox(height: 6),
//                       TextField(
//                         keyboardType: TextInputType.phone,
//                         onChanged: (value) {
//                           context.read<AssetBloc>().add(PhoneChanged(value));
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Enter Phone Number',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 14, vertical: 12),
//                         ),
//                       ),

//                       const SizedBox(height: 30),
//                       Center(
//                         child: MaterialButton(
//                           onPressed: () {
//                             context.read<AssetBloc>().add(SubmitAsset());
//                           },
//                           color: Colors.blueAccent,
//                           textColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 40, vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Text('Submit',
//                               style: TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.w600)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
