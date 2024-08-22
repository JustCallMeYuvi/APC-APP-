import 'dart:convert';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/model/get_emp_details.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TokenScreen extends StatefulWidget {
  final LoginModelApi userData; // Add this line
  final List<GetEmpDetails> empDetailsList; // Add this line

  const TokenScreen({
    Key? key,
    required this.userData,
    required this.empDetailsList,
  }) : super(key: key);

  @override
  _TokenScreenState createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final TextEditingController _textFieldController = TextEditingController();
  String? _selectedBarcode;
  final List<String> _barcodes = ['70068', '71202', '67757', '70643'];
  List<GetEmpDetails> empDetailsList = []; // Declare the list here

  @override
  void initState() {
    super.initState();
    // Fetch data when the screen initializes
    fetchData(widget.userData.empNo);
  }

  Future<void> fetchData(String empNo) async {
    final url =
        Uri.parse('http://10.3.0.70:9042/api/HR/GetEmpDetails?empNo=$empNo');

    print('URL: $url');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        // Debug: Print the raw response body
        print('Response body: ${response.body}');

        // Debug: Print the parsed JSON data
        jsonResponse.forEach((data) {
          print('Parsed JSON item: $data');
        });

        setState(() {
          empDetailsList =
              jsonResponse.map((data) => GetEmpDetails.fromJson(data)).toList();

          // Debug: Print the list of empDetailsList
          empDetailsList.forEach((detail) {
            print(
                'Emp Detail: ${detail.emPNo}, ${detail.emPName}, ${detail.depTName}, ${detail.position}');
          });
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
        // Handle error case, show error message or retry logic
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error case, show error message or retry logic
    }
  }

  Future<void> submitData(String text, String barcode) async {
    final url = Uri.parse('http://10.3.0.70:9042/api/HR/Submitdata');
    final username =
        empDetailsList.isNotEmpty ? empDetailsList[0].emPName : 'Unknown';

    final Map<String, dynamic> data = {
      // 'username': username,
      // 'text': text,
      // 'barcode': barcode,
      'Message': text,
      'Barcode': barcode,
      'UserName': username,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // Handle success
        print('Data submitted successfully: ${response.body}');
      } else {
        // Handle error
        print('Failed to submit data: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // Log response body for debugging
      }
    } catch (e) {
      print('Error submitting data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Get the username from the first item in empDetailsList
    final username =
        empDetailsList.isNotEmpty ? empDetailsList[0].emPName : 'Loading...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Screen'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: UiConstants.backgroundGradient.gradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the username
              // Text(
              //   'Welcome, $username',
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 20),
              // Text field for entering token
              TextField(
                controller: _textFieldController,

                decoration: const InputDecoration(
                  labelText: 'Enter Text',
                  labelStyle:
                      TextStyle(color: Colors.white), // Change label text color
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white), // Change border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // Change enabled border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.green), // Change focused border color
                  ),
                ),
                style: const TextStyle(color: Colors.white), // Change text color
              ),
              const SizedBox(height: 20),
              // Dropdown for selecting barcode
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Barcode',
                  labelStyle:
                      TextStyle(color: Colors.white), // Change label text color
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white), // Change border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // Change enabled border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.green), // Change focused border color
                  ),
                ),
                dropdownColor:
                    Colors.blueGrey, // Change dropdown menu background color
                value: _selectedBarcode,
                items: _barcodes.map((String barcode) {
                  return DropdownMenuItem<String>(
                    value: barcode,
                    child: Text(barcode,
                        style: const TextStyle(
                            color: Colors
                                .white)), // Change text color in dropdown),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBarcode = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              // Button to handle submission
              // ElevatedButton(
              //   onPressed: () {
              //     String token = _textFieldController.text;
              //     String barcode = _selectedBarcode ?? 'No barcode selected';
              //     print('Token: $token, Barcode: $barcode');
              //     // Perform further actions with the token and barcode
              //     submitData(token, barcode); // Call submitData method
              //   },
              //   child: Text('Submit'),
              // ),
              MaterialButton(
                onPressed: () {
                  String token = _textFieldController.text;
                  String barcode = _selectedBarcode ?? 'No barcode selected';
                  print('Token: $token, Barcode: $barcode');
                  // Perform further actions with the token and barcode
                  submitData(token, barcode); // Call submitData method
                },
                color: Colors.transparent, // Transparent background
                elevation: 0, // Remove default shadow
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.deepPurple,
                        Colors.purpleAccent
                      ], // Gradient colors
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(
                        maxWidth: double.infinity, minHeight: 50.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontSize: 18, // Text size
                        fontWeight: FontWeight.bold, // Text weight
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
