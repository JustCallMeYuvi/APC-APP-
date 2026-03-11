// import 'dart:convert';
// import 'package:animated_movies_app/api/apis_page.dart';
// import 'package:animated_movies_app/auth_provider.dart';
// import 'package:animated_movies_app/constants/ui_constant.dart';
// import 'package:animated_movies_app/model/get_emp_details.dart';
// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';

// class TokenScreen extends StatefulWidget {
//   final LoginModelApi userData; // Add this line
//   final List<GetEmpDetails> empDetailsList; // Add this line

//   const TokenScreen({
//     Key? key,
//     required this.userData,
//     required this.empDetailsList,
//   }) : super(key: key);

//   @override
//   _TokenScreenState createState() => _TokenScreenState();
// }

// class _TokenScreenState extends State<TokenScreen> {
//   final TextEditingController _textFieldController = TextEditingController();
//   String? _selectedBarcode;
//   final List<String> _barcodes = [
//     '70068',
//     '71202',
//     '67657',
//     '70643',
//     '70920',
//     '59323apc',
//   ];
//   List<GetEmpDetails> empDetailsList = []; // Declare the list here

//   @override
//   void initState() {
//     super.initState();
//     // Fetch data when the screen initializes
//     // fetchData(widget.userData.empNo);
//     fetchData(widget.userData.username);

//     // fetchELCNotification(widget.userData.empNo);
//   }

//   // Future<void> fetchData(String empNo) async {
//   Future<void> fetchData(String username) async {
//     // final url =
//     //     // Uri.parse('http://10.3.0.70:9042/api/HR/GetEmpDetails?empNo=$empNo');
//     //     Uri.parse('http://10.3.0.70:9042/api/HR/GetEmpDetails?empNo=$username');
//     // final url = Uri.parse(ApiHelper.getEmpDetails(username));
//     final url = Uri.parse(ApiHelper.getEmpDetailsUserNameBased(username));

//     print('URL: $url');
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonResponse = json.decode(response.body);

//         // Debug: Print the raw response body
//         // print('Response body: ${response.body}');

//         // Debug: Print the parsed JSON data
//         jsonResponse.forEach((data) {
//           // print('Parsed JSON item: $data');
//         });

//         setState(() {
//           empDetailsList =
//               jsonResponse.map((data) => GetEmpDetails.fromJson(data)).toList();

//           // Debug: Print the list of empDetailsList
//           empDetailsList.forEach((detail) {
//             // print(
//             //     'Emp Detail: ${detail.emPNo}, ${detail.emPName}, ${detail.depTName}, ${detail.position}');
//           });
//         });
//       } else {
//         // print('Request failed with status: ${response.statusCode}');
//         // Handle error case, show error message or retry logic
//       }
//     } catch (e) {
//       // print('Error fetching data: $e');
//       // Handle error case, show error message or retry logic
//     }
//   }

//   // Future<void> fetchELCNotification(String empNo) async {
//   //   final url =
//   //       Uri.parse('http://10.3.0.70:9042/api/HR/FirstLoginAndNotify/$empNo');

//   //   print('URL: $url');
//   //   try {
//   //     // Sending POST request
//   //     final response = await http.post(url);

//   //     if (response.statusCode == 200) {
//   //       // Assuming the response is JSON formatted
//   //       final dynamic jsonResponse = json.decode(response.body);

//   //       // Debug: Print the raw response body
//   //       print('Response body: ${response.body}');

//   //       // Handle the JSON response based on its structure
//   //       // For example, if the response is a single object or a list of notifications

//   //       setState(() {
//   //         // Assuming you have a model to parse the response
//   //         // notificationList = jsonResponse.map((data) => NotificationModel.fromJson(data)).toList();

//   //         // Debug: Print the parsed notifications
//   //         print('Notification: $jsonResponse');
//   //       });
//   //     } else {
//   //       print('Request failed with status: ${response.statusCode}');
//   //       // Handle error case, show error message or retry logic
//   //     }
//   //   } catch (e) {
//   //     print('Error fetching data: $e');
//   //     // Handle error case, show error message or retry logic
//   //   }
//   // }

//   Future<void> submitData(String text, String barcode) async {
//     // final url = Uri.parse('http://10.3.0.70:9042/api/HR/Submitdata');
//     var apiforSendNotifications = '${ApiHelper.baseUrl}send-notification';
//     final url = Uri.parse(apiforSendNotifications);
//     // final url = Uri.parse('http://10.3.0.70:9042/api/HR/send-notification');
//     print(url);
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final deviceToken = authProvider.fcmToken;
//     final username =
//         empDetailsList.isNotEmpty ? empDetailsList[0].emPName : 'Unknown';

//     final Map<String, dynamic> data = {
//       // 'Message': text,
//       // 'Barcode': barcode,
//       // 'UserName': username,
//       'Title': username, // Match with the 'Title' field
//       'Body': text, // Match with the 'Body' field
//       'DeviceToken': deviceToken, // Match with the 'DeviceToken' field
//       'Barcode': barcode, // Match with the 'Barcode' field
//       'Name': username, // Match with the 'Name' field
//     };

//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(data),
//       );

//       if (response.statusCode == 200) {
//         // Handle success
//         print('Data submitted successfully: ${response.body}');
//         print('🔹 Sending notification payload: $data');
//         print('🔹 DeviceToken in Flutter: $deviceToken');
//       } else {
//         // Handle error
//         print('Failed to submit data: ${response.statusCode}');
//         print(
//             'Response body: ${response.body}'); // Log response body for debugging
//       }
//     } catch (e) {
//       print('Error submitting data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     // Get the username from the first item in empDetailsList
//     final username =
//         empDetailsList.isNotEmpty ? empDetailsList[0].emPName : 'Loading...';

//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text('Token Screen'),
//       //   backgroundColor: Colors.lightGreen,
//       // ),
//       body: Container(
//         height: size.height,
//         width: size.width,
//         decoration: BoxDecoration(
//           gradient: UiConstants.backgroundGradient.gradient,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Display the username
//               // Text(
//               //   'Welcome, $username',
//               //   style: TextStyle(
//               //     fontSize: 20,
//               //     fontWeight: FontWeight.bold,
//               //   ),
//               // ),
//               const SizedBox(height: 20),
//               // Text field for entering token
//               TextField(
//                 controller: _textFieldController,

//                 decoration: const InputDecoration(
//                   labelText: 'Enter Text',
//                   labelStyle:
//                       TextStyle(color: Colors.white), // Change label text color
//                   border: OutlineInputBorder(
//                     borderSide:
//                         BorderSide(color: Colors.white), // Change border color
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: Colors.blue), // Change enabled border color
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: Colors.green), // Change focused border color
//                   ),
//                 ),
//                 style:
//                     const TextStyle(color: Colors.white), // Change text color
//               ),
//               const SizedBox(height: 20),
//               // Dropdown for selecting barcode
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Select Barcode',
//                   labelStyle:
//                       TextStyle(color: Colors.white), // Change label text color
//                   border: OutlineInputBorder(
//                     borderSide:
//                         BorderSide(color: Colors.white), // Change border color
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: Colors.blue), // Change enabled border color
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: Colors.green), // Change focused border color
//                   ),
//                 ),
//                 dropdownColor:
//                     Colors.blueGrey, // Change dropdown menu background color
//                 value: _selectedBarcode,
//                 items: _barcodes.map((String barcode) {
//                   return DropdownMenuItem<String>(
//                     value: barcode,
//                     child: Text(barcode,
//                         style: const TextStyle(
//                             color: Colors
//                                 .white)), // Change text color in dropdown),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedBarcode = newValue;
//                   });
//                 },
//               ),
//               const SizedBox(height: 20),
//               // Button to handle submission
//               // ElevatedButton(
//               //   onPressed: () {
//               //     String token = _textFieldController.text;
//               //     String barcode = _selectedBarcode ?? 'No barcode selected';
//               //     print('Token: $token, Barcode: $barcode');
//               //     // Perform further actions with the token and barcode
//               //     submitData(token, barcode); // Call submitData method
//               //   },
//               //   child: Text('Submit'),
//               // ),
//               MaterialButton(
//                 onPressed: () {
//                   if (_selectedBarcode == null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Please select a barcode')),
//                     );
//                     return;
//                   }
//                   String token = _textFieldController.text;
//                   String barcode = _selectedBarcode ?? 'No barcode selected';
//                   print('Token: $token, Barcode: $barcode');
//                   // Perform further actions with the token and barcode
//                   submitData(token, barcode); // Call submitData method

//                   // Clear the text field controller after submission
//                   _textFieldController.clear();
//                   // Clear the dropdown selection
//                   setState(() {
//                     _selectedBarcode = null;
//                   });
//                 },
//                 color: Colors.transparent, // Transparent background
//                 elevation: 0, // Remove default shadow
//                 padding: const EdgeInsets.symmetric(
//                     vertical: 16.0, horizontal: 24.0),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 child: Ink(
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Colors.deepPurple,
//                         Colors.purpleAccent
//                       ], // Gradient colors
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                     ),
//                     borderRadius: BorderRadius.circular(12.0),
//                   ),
//                   child: Container(
//                     constraints: const BoxConstraints(
//                         maxWidth: double.infinity, minHeight: 50.0),
//                     alignment: Alignment.center,
//                     child: const Text(
//                       'Submit',
//                       style: TextStyle(
//                         color: Colors.white, // Text color
//                         fontSize: 18, // Text size
//                         fontWeight: FontWeight.bold, // Text weight
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/auth_provider.dart';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/model/get_emp_details.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TokenScreen extends StatefulWidget {
  final LoginModelApi userData;
  final List<GetEmpDetails> empDetailsList;

  const TokenScreen({
    Key? key,
    required this.userData,
    required this.empDetailsList,
  }) : super(key: key);

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  String? _selectedBarcode;

  final List<String> _barcodes = [
    '70068',
    '71202',
    '67657',
    '70643',
    '70920',
    '59323apc',
  ];

  List<GetEmpDetails> empDetailsList = [];

  @override
  void initState() {
    super.initState();
    fetchData(widget.userData.username);
  }

  Future<void> fetchData(String username) async {
    final url = Uri.parse(ApiHelper.getEmpDetailsUserNameBased(username));

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          empDetailsList =
              jsonResponse.map((data) => GetEmpDetails.fromJson(data)).toList();
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> submitData(String text, String barcode) async {
    var api = '${ApiHelper.baseUrl}send-notification';
    final url = Uri.parse(api);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final deviceToken = authProvider.fcmToken;

    final username =
        empDetailsList.isNotEmpty ? empDetailsList[0].emPName : 'Unknown';

    final Map<String, dynamic> data = {
      'Title': username,
      'Body': text,
      'DeviceToken': deviceToken,
      'Barcode': barcode,
      'Name': username,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification Sent Successfully")),
        );
      } else {
        print("Failed : ${response.body}");
      }
    } catch (e) {
      print('Error submitting data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final username =
        empDetailsList.isNotEmpty ? empDetailsList[0].emPName : 'Loading...';

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: UiConstants.backgroundGradient.gradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),

                      Text(
                        "Send Notification",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// TEXT FIELD

                      TextField(
                        controller: _textFieldController,
                        decoration: const InputDecoration(
                          labelText: "Enter Message",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.message),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// SEARCHABLE DROPDOWN

                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: DropDownSearchField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _barcodeController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Search Barcode",
                              suffixIcon: Icon(Icons.qr_code),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            if (pattern.isEmpty) {
                              return _barcodes;
                            }

                            return _barcodes
                                .where((barcode) => barcode
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase()))
                                .toList();
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              leading: const Icon(Icons.qr_code),
                              title: Text(suggestion.toString(  )),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            setState(() {
                              _selectedBarcode = suggestion.toString();
                              _barcodeController.text = _selectedBarcode!;
                            });
                          },
                          displayAllSuggestionWhenTap: true,
                          isMultiSelectDropdown: false,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// SUBMIT BUTTON

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.deepPurple,
                          ),
                          onPressed: () {
                            if (_barcodeController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please select a barcode")),
                              );
                              return;
                            }

                            String text = _textFieldController.text;
                            String barcode = _barcodeController.text;

                            submitData(text, barcode);

                            _textFieldController.clear();
                            _barcodeController.clear();

                            setState(() {
                              _selectedBarcode = null;
                            });
                          },
                          child: const Text(
                            "Submit",
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
