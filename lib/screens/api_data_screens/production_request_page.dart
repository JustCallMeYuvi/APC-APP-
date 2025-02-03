// import 'package:flutter/material.dart';

// class AdminPage extends StatefulWidget {
//   const AdminPage({Key? key}) : super(key: key);

//   @override
//   State<AdminPage> createState() => _AdminPageState();
// }

// class _AdminPageState extends State<AdminPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           'Welcome to the Admin Page!',
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 16),
//         Text(
//           'Here are some important details:',
//           style: TextStyle(fontSize: 20),
//         ),
//         ListTile(
//           leading: Icon(Icons.info),
//           title: Text('Detail 1: Important information'),
//         ),
//         ListTile(
//           leading: Icon(Icons.check),
//           title: Text('Detail 2: Another key point'),
//         ),
//         ListTile(
//           leading: Icon(Icons.star),
//           title: Text('Detail 3: Some additional info'),
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/screens/home_screen/api_data_screen.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
//import 'package:intl/intl.dart';

//import 'package:uni_links/uni_links.dart';

class SkillMappingRequestPage extends StatefulWidget {
  // final String userData;
  // final String userName;
  final LoginModelApi userData; // Use userData directly

  const SkillMappingRequestPage({
    super.key,
    required this.userData,
    // required this.userName,
  });

  @override
  _SkillMappingRequestPageState createState() =>
      _SkillMappingRequestPageState();
}

class _SkillMappingRequestPageState extends State<SkillMappingRequestPage>
    with SingleTickerProviderStateMixin {
  // Controllers for text fields
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController empNameController = TextEditingController();
  final TextEditingController leaveDateController = TextEditingController();
  final TextEditingController headCountController = TextEditingController();
  late AnimationController _animationController;
  double approvalPercent = 0.0;
  // Variables for state management
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  String selectedPlant = '';
  String selectedDept = '';
  String selectedProcessType = '';
  String selectedSkill = '';
  String headCount = '';
  //double approvalPercent = 0.0;
  List<Map<String, String>> employeeList = [];
  List<Map<String, String>> plantAbsentList = [];
  DateTime? selectedDate;
  bool isBarcodeReadOnly = false;
  bool isEmpNameReadOnly = false;
  bool showEmployeeDetails = false;
  bool showAddButton = true;
  bool isUpdateButtonVisible = false;
  bool isHeadReadOnly = false;
  bool submitButton = true;
  bool showdepthead = true;
  bool isApproveStatus = false;
  bool absentieslist = true;
  bool text = false;
  bool flow = false;
  bool approvedplant = false;
  bool statusConfirmed = false;
  bool frstplant = true;
  bool _isLoading = false;
  // Sample data lists
  List<String> plants = ['Plant A', 'Plant B'];
  List<String> departments = ['Dept X', 'Dept Y'];
  List<String> processTypes = ['Process 1', 'Process 2'];
  List<String> skillNames = ['Skill A', 'Skill B'];
  bool allApproved = false;
  String absentList = '';
  // Employee list and suggestions
  List<Map<String, String>> suggestions = [];
  List<Map<String, String>> employees = [];
  List<Map<String, String>> absenties = [];
  List<String> selectedBarcodes = [];
  final Map<String, String> _approvalStatus = {
    'plant assistant': 'Pending',
    'plant incharge': 'Pending',
    'production manager': 'Pending',
    'rita': 'Pending',
  };
  final Map<String, bool> _showSendNotifyButtons = {
    'plant assistant': false,
    'plant incharge': false,
    'production manager': false,
    'rita': false,
  };
  final Map<String, String> _approvalTime = {
    'plant assistant': 'null',
    'plant incharge': 'null',
    'production manager': 'null',
    'rita': 'null',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fetchPlants();
    _fetchEmployeesData();
    _fetchProcessTypes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _notifyStatus(String role) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // String url =
      //     'http://10.3.0.70:9060/api/HR/Notify?Role=$role&plant=$selectedPlant';

      String url = ApiHelper.notifyApiforLeaveRequest(role, selectedPlant);

      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        // Handle successful response
        String responseBody = response.body;
        _showSnackBar('Success: $responseBody', Colors.green);
      } else if (response.statusCode == 404) {
        // Handle not found error
        _showSnackBar('Not Found: ${response.body}', Colors.red);
      } else {
        // Handle other errors
        _showSnackBar('Failed to Notify: ${response.body}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, String>>> _plantAbsentData() async {
    List<Map<String, String>> absentList = [];
    try {
      // String url =
      //     'http://10.3.0.70:9060/api/HR/GetAbsentList?Plant=$selectedPlant';
      String url =
          'http://10.3.0.208:8084/api/HR/GetAbsentList?Plant=$selectedPlant';
      // String url = ApiHelper.getAbsentListApi(selectedPlant);

      final response = await http.get(Uri.parse(url));

      // Check for successful response
      if (response.statusCode == 200) {
        // Parse the response body as a list
        final List<dynamic> responseData = jsonDecode(response.body);

        // Check if the first element indicates confirmation
        if (responseData.isNotEmpty &&
            responseData[0].contains("Already Confirmed")) {
          statusConfirmed = true; // Update the status
        }

        // Process all entries for the absent list
        for (int i = 0; i < responseData.length; i++) {
          String entry = responseData[i];

          // Split each entry by comma and trim whitespace
          final parts = entry.split(',').map((part) => part.trim()).toList();

          // Ensure the parts list has the expected number of elements
          if (parts.length == 5) {
            absentList.add({
              'plant': parts[0],
              'barcode': parts[1],
              'empName': parts[2],
              'departmentCode': parts[3],
              'skillType': parts[4],
            });
          }
        }
      } else if (response.statusCode == 400) {
        // Handle bad requests
        String responseMessage = response.body;

        if (responseMessage.contains('No records found')) {
          _showSnackBar('Please add employees.', Colors.red);
        } else {
          //_showNotification('Bad request. Please check the input.', Colors.red);
        }
      } else {
        // Handle other unsuccessful response statuses
        _showSnackBar(
          'Failed to load Employees. Status code: ${response.statusCode}',
          Colors.red,
        );
      }
    } catch (e) {
      // Handle any errors during the request
      _showSnackBar(
        'An error occurred while fetching Employees: $e',
        Colors.red,
      );
    }

    // Return the processed absent list
    return absentList;
  }

  void filterSuggestions(String input) {
    setState(() {
      final inputLetter =
          input.toUpperCase(); // Convert input to uppercase for comparison
      final selectedPlant = this.selectedPlant;

      // Filter employees based on the selected plant
      final filteredByPlant = employeeList.where((employee) {
        final plant = employee['plant']?.toUpperCase() ?? '';
        return plant == selectedPlant;
      }).toList();

      // Further filter the results based on the input criteria
      suggestions = filteredByPlant.where((employee) {
        final empName = employee['empName']?.toUpperCase() ?? '';
        final barcode = employee['barcode']?.toUpperCase() ?? '';

        // Check if barcode or employee name matches the input
        final matchesBarcode =
            inputLetter.isNotEmpty ? barcode.startsWith(inputLetter) : true;
        final matchesEmpName =
            inputLetter.isNotEmpty ? empName.contains(inputLetter) : true;

        return matchesBarcode || matchesEmpName;
      }).toList();
    });
  }

  // void showSuggestions(String text) {
  //   // Filter the suggestions based on the input text
  //   final filteredSuggestions = suggestions.where((employee) {
  //     final empName = employee['empName']?.toLowerCase() ?? '';
  //     final barcode = employee['barcode']?.toLowerCase() ?? '';
  //     final plant = employee['plant']?.toLowerCase() ?? '';
  //     final searchText = text.toLowerCase();

  //     // Check if any of the fields contain the search text
  //     return empName.contains(searchText) ||
  //         barcode.contains(searchText) ||
  //         plant.contains(searchText);
  //   }).toList();

  //   if (filteredSuggestions.isEmpty) return;

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled:
  //         true, // This allows the bottom sheet to adjust its height based on content
  //     builder: (context) {
  //       return Container(
  //         color: Colors.white,
  //         child: Wrap(
  //           children: [
  //             Container(
  //               color: Colors.grey[200],
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const Padding(
  //                     padding: EdgeInsets.all(8.0),
  //                     child: Text(
  //                       'Select Employee',
  //                       style: TextStyle(
  //                         color: Colors.blue,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 18.0,
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: MediaQuery.of(context).size.height *
  //                         0.42, // Adjusts the height to 3/4 of the screen
  //                     child: ListView.builder(
  //                       padding: const EdgeInsets.symmetric(vertical: 8.0),
  //                       itemCount: filteredSuggestions.length,
  //                       itemBuilder: (context, index) {
  //                         final employee = filteredSuggestions[index];
  //                         return ListTile(
  //                           contentPadding: const EdgeInsets.symmetric(
  //                               vertical: 8.0, horizontal: 12.0),
  //                           title: Text(
  //                             employee['empName'] ?? '',
  //                             style: const TextStyle(
  //                                 color: Colors.blue,
  //                                 fontWeight: FontWeight.bold),
  //                           ),
  //                           subtitle: Text(
  //                             'Barcode: ${employee['barcode'] ?? ''} | Plant: ${employee['plant'] ?? ''}',
  //                             style: const TextStyle(color: Colors.grey),
  //                           ),
  //                           tileColor: Colors.grey[200],
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(8.0),
  //                           ),
  //                           onTap: () {
  //                             setState(() {
  //                               barcodeController.text =
  //                                   employee['barcode'] ?? '';
  //                               empNameController.text =
  //                                   employee['empName'] ?? '';
  //                               isBarcodeReadOnly = true;
  //                               isEmpNameReadOnly = true;
  //                             });
  //                             Navigator.pop(context); // Close the modal
  //                           },
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<void> _fetchEmployeesData() async {
    try {
      // String url = 'http://10.3.0.70:9060/api/HR/GetEmployeeList';
      // String url = 'http://10.3.0.70:9042/api/HR/GetEmployeeList';
      String url = ApiHelper.getEmployeeListApi();
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData.containsKey('retData1') &&
            responseData['retData1'] is List<dynamic>) {
          final employeeListData = responseData['retData1'] as List<dynamic>;
          setState(() {
            employeeList = employeeListData.map<Map<String, String>>((e) {
              return {
                'barcode': e['barcode']?.toString() ?? '',
                'empName': e['empName'] ?? '',
                'plant': e['plant'] ?? '',
              };
            }).toList();
          });
        } else {
          _showSnackBar(
              'Unexpected data format: Expected a list under "retData1".',
              Colors.red);
        }
      } else {
        _showSnackBar('Failed to load Employees', Colors.red);
      }
    } catch (e) {
      _showSnackBar(
          'An error occurred while fetching Employees: $e', Colors.red);
    }
  }

  Future<void> _fetchPlants() async {
    //getLinks();
    try {
      // String url = 'http://10.3.0.70:9060/api/HR/GetPlants';
      // String url = 'http://10.3.0.70:9042/api/HR/GetPlants';
      String url = ApiHelper.getPlantsforLeaves();

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          plants = responseData.cast<String>();
        });
      } else {
        _showSnackBar('Failed to load plants', Colors.red);
      }
    } catch (e) {
      _showSnackBar('An error occurred while fetching plants: $e', Colors.red);
    }
  }

  Future<void> _fetchProcessTypes() async {
    try {
      // String url = 'http://10.3.0.70:9060/api/HR/GetProcessType';
      // String url = 'http://10.3.0.70:9042/api/HR/GetProcessType';
      String url = ApiHelper.getProcessTypes();

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          processTypes = responseData.cast<String>();
        });
      } else {
        _showSnackBar('Failed to load process Types', Colors.red);
      }
    } catch (e) {
      _showSnackBar(
          'An error occurred while fetching process Types: $e', Colors.red);
    }
  }

  Future<void> _fetchDepartments(String plant) async {
    try {
      statusConfirmed = false;
      // String url =
      //     'http://10.3.0.70:9060/api/HR/GetProductionLines?plant=$plant';
      // String url =
      //     'http://10.3.0.70:9042/api/HR/GetProductionLines?plant=$plant';

      String url = ApiHelper.getProductionLinesApi(plant);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          departments = responseData.cast<String>();
          selectedDept = '';
          headCount = '';
          headCountController.clear();
        });
      } else {
        _showSnackBar('Failed to load departments', Colors.red);
      }
    } catch (e) {
      _showSnackBar(
          'An error occurred while fetching departments: $e', Colors.red);
    }
  }

  Future<void> _fetchskill(String process) async {
    try {
      // String url =
      //     'http://10.3.0.70:9060/api/HR/GetSkillNames?processType=$process';
      // String url =
      //     'http://10.3.0.70:9042/api/HR/GetSkillNames?processType=$process';

      String apiUrl = ApiHelper.getSkillNamesApi(process);
      // final response = await http.get(Uri.parse(url));
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          skillNames = responseData.cast<String>();
          //selectedSkill = '';
        });
      } else {
        _showSnackBar('Failed to load departments', Colors.red);
      }
    } catch (e) {
      _showSnackBar(
          'An error occurred while fetching departments: $e', Colors.red);
    }
  }

  Future<void> _checkData() async {
    try {
      // final url =
      //     'http://10.3.0.70:9060/api/HR/CheckDept?plant=$selectedPlant&deptCode=$selectedDept';
      // final url =
      //     'http://10.3.0.70:9042/api/HR/CheckDept?plant=$selectedPlant&deptCode=$selectedDept';

      // Generate the  URL
      String url = ApiHelper.checkDeptApi(selectedPlant, selectedDept);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> resultData = json.decode(response.body);

        // Iterate through the result list
        for (var item in resultData) {
          final Map<String, dynamic> data = item as Map<String, dynamic>;

          if (data['isSuccess'] == true) {
            if (data['retdata'] != null) {
              final retdataString = data['retdata'] as String;
              final Map<String, dynamic> absenteeData =
                  json.decode(retdataString) as Map<String, dynamic>;

              if (absenteeData['Data'] != null &&
                  absenteeData['Data'] is List<dynamic> &&
                  absenteeData['Data'].isNotEmpty) {
                List<Map<String, String>> absentees =
                    (absenteeData['Data'] as List<dynamic>).map((item) {
                  final absentee = item as Map<String, dynamic>;
                  return {
                    'PLANT': absentee['PLANT']?.toString() ?? '',
                    'BARCODE': absentee['BARCODE']?.toString() ?? '',
                    'EMP_NAME': absentee['EMP_NAME']?.toString() ?? '',
                    'DEPARTMENTCODE':
                        absentee['DEPARTMENTCODE']?.toString() ?? '',
                    'SKILL_TYPE': absentee['SKILL_TYPE']?.toString() ?? '',
                    'SKILL_NAME': absentee['SKILL_NAME']?.toString() ?? '',
                    'LEAVEDATE': absentee['LEAVEDATE']?.toString() ?? '',
                  };
                }).toList();

                setState(() {
                  absenties = absentees;
                  showEmployeeDetails = true;
                  isHeadReadOnly = true;
                  submitButton = false;
                });
              } else {
                absenties = [];
                _showSnackBar('No absentee data found.', Colors.orange);
              }
            } else {
              absenties = [];
              _showSnackBar("Unexpected response: $resultData", Colors.red);
            }
          } else {
            // Handle failure
            if (data['errMsg'] != null &&
                data['errMsg'].contains('No records found')) {
              // _showSnackBar("Please Submit Data", Colors.orange);
              setState(() {
                absenties = [];
                showEmployeeDetails = false;
                isHeadReadOnly = true;
                submitButton = true;
              });
            } else if (data['errMsg'] != null &&
                data['errMsg']
                    .contains('No data found for the specified criteria.')) {
              // _showSnackBar("Please Add Absenties Data", Colors.orange);
              setState(() {
                absenties = [];
                showEmployeeDetails = true;
                isHeadReadOnly = true;
                submitButton = false;
              });
            } else {
              _showSnackBar(
                  "Error: ${data['errMsg'] ?? 'An unknown error occurred'}",
                  Colors.red);
              setState(() {
                absenties = [];
                showEmployeeDetails = true;
                isHeadReadOnly = true;
              });
            }
          }
        }
      } else {
        _showSnackBar(
            'Submission failed with status code ${response.statusCode}',
            Colors.red);
      }
    } catch (e) {
      _showSnackBar('An error occurred while fetching data: $e', Colors.red);
    }
  }

  void _handleSubmit() async {
    if (selectedPlant.isEmpty) {
      _showSnackBar("Please select a plant.", Colors.red);
      return;
    }
    if (selectedDept.isEmpty) {
      _showSnackBar("Please select a department.", Colors.red);
      return;
    }
    if (headCount.isEmpty || int.tryParse(headCount) == null) {
      // Ensure headCount is a valid number
      _showSnackBar("Please enter a head count.", Colors.red);
      return;
    }

    try {
      // const url = 'http://10.3.0.70:9060/api/HR/SubmitPlantData';
      // const url = 'http://10.3.0.70:9042/api/HR/SubmitPlantData';
      // Generate the API URL for SubmitPlantData
      String url = ApiHelper.submitPlantDataApi();

      // Preparing data for submission
      final data = {
        'plant': selectedPlant,
        'deptCode': selectedDept,
        'headCount': headCount, // headCount is sent as a string
        'username': widget.userData.empNo,
        // 'username': widget.userName,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      // Parsing response body
      final result = response.body;

      // Handling different status codes and response messages
      if (response.statusCode == 200) {
        if (result.contains("Submission is not allowed after 2:00 PM")) {
          _showSnackBar(
              "Submission is not allowed after 2:00 PM.", Colors.orange);
        } else if (result.contains("The record already exists.")) {
          _showSnackBar("The record already exists.", Colors.orange);
          setState(() {
            showEmployeeDetails = true;
            isHeadReadOnly = true;
            submitButton = false;
          });
        } else if (result.contains("Already confirmed")) {
          _showSnackBar("Already confirmed.", Colors.orange);
          setState(() {
            submitButton = false;
          });
        } else if (result.contains("Data submitted successfully")) {
          _showSnackBar('Data submitted successfully.', Colors.green);
          setState(() {
            isUpdateButtonVisible = false;
            showEmployeeDetails = true;
            isHeadReadOnly = true;
            submitButton = false;
            showAddButton = true;
          });
        } else {
          _showSnackBar("Unexpected response: $result", Colors.red);
        }
      } else {
        _showSnackBar(
            'Submission failed with status code ${response.statusCode}',
            Colors.red);
      }
    } catch (e) {
      _showSnackBar('An error occurred while submitting data: $e', Colors.red);
    }
  }

  Future<void> _fetchHeadCount() async {
    try {
      // String url =
      //     'http://10.3.0.70:9060/api/HR/GetHeadCount?plant=$selectedPlant&departmentCode=$selectedDept';

      // String url =
      //     'http://10.3.0.70:9042/api/HR/GetHeadCount?plant=$selectedPlant&departmentCode=$selectedDept';
      // Generate the API URL for GetHeadCount
      String url = ApiHelper.getHeadCountApi(selectedPlant, selectedDept);

      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseBody = response.body;
        final regex = RegExp(r'HeadCount:\s*(\d+)');
        final match = regex.firstMatch(responseBody);
        if (match != null) {
          final headCountString = match.group(1);
          setState(() {
            headCount = headCountString ?? '';
            headCountController.text = headCount;
          });
        } else {
          setState(() {
            isHeadReadOnly = false;
          });
          //_showNotification('Enter head count', Colors.red);
        }
      } else {
        _showSnackBar(
            'Failed to load head count (Status Code: ${response.statusCode})',
            Colors.red);
      }
    } catch (e) {
      _showSnackBar(
          'An error occurred while fetching head count: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _getApprovalStatus(String plant) async {
    try {
      // String url =
      //     'http://10.3.0.70:9060/api/HR/GetApprovedStatus?plant=$plant';
      // String url =
      //     'http://10.3.0.70:9042/api/HR/GetApprovedStatus?plant=$plant';

      // Generate the API URL for GetApprovedStatus
      String url = ApiHelper.getApprovedStatusApi(selectedPlant);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['isSuccess'] == true) {
          if (responseData['errMsg'] == 'No records') {
            setState(() {
              isApproveStatus = false;
              showdepthead = true;
              submitButton = true;
              showEmployeeDetails = false;
              flow = false;
              text = false;
              approvedplant = false;
              frstplant = true;
            });
            // _showSnackBar('Please submit data', Colors.orange);
          } else {
            // Parse the Retdata which contains the status and signatures
            final retData = jsonDecode(responseData['retdata']);
            String status = retData['ConfirmedStatus'];
            String signature1 = retData['Signature1'];
            String signature2 = retData['Signature2'];
            String signature3 = retData['Signature3'];
            String signature4 = retData['Signature4'];
            // Update the approval status based on the retrieved data
            _approvalStatus['plant assistant'] =
                signature1 == '1' ? 'Approved' : 'Pending';
            _approvalStatus['plant incharge'] =
                signature2 == '1' ? 'Approved' : 'Pending';
            _approvalStatus['production manager'] =
                signature3 == '1' ? 'Approved' : 'Pending';
            _approvalStatus['rita'] =
                signature4 == '1' ? 'Approved' : 'Pending';
            _approvalTime['plant assistant'] = retData['SIGN1TIME'] ?? 'null';
            _approvalTime['plant incharge'] = retData['SIGN2TIME'] ?? 'null';
            _approvalTime['production manager'] =
                retData['SIGN3TIME'] ?? 'null';
            _approvalTime['rita'] = retData['SIGN4TIME'] ?? 'null';
            _updateApprovalPercent();
            // Check if status is 'Confirmed'
            if (status == 'Confirmed') {
              setState(() {
                showdepthead = false;
                showEmployeeDetails = false;
                absenties = [];
                isApproveStatus = true;
                submitButton = false;
                flow = true;
                text = true;
                approvedplant = true;
                frstplant = false;
              });
            } else {
              // _showSnackBar('Approval not confirmed', Colors.orange);
              setState(() {
                showdepthead = true;
                showEmployeeDetails = false;
                //absenties = [];
                isApproveStatus = false;
                submitButton = false;
                flow = false;
                text = false;
                approvedplant = false;
                frstplant = true;
                showAddButton = true;
                cancelEmployee();
              });
            }
          }
        } else {
          // Handle the error message from the response
          if (responseData['ErrMsg'] != null) {
            _showSnackBar('Error: ${responseData['ErrMsg']}', Colors.red);
          } else {
            _showSnackBar('Unknown error occurred', Colors.red);
          }
        }
      } else {
        // Handle the case where the response status code is not 200
        _showSnackBar(
            'Failed to load, status code: ${response.statusCode}', Colors.red);
      }
    } catch (e) {
      // Handle general exceptions
      _showSnackBar('An error occurred: $e', Colors.red);
    }
  }

  void _updateApprovalPercent() {
    int approvedCount =
        _approvalStatus.values.where((status) => status == 'Approved').length;
    setState(() {
      approvalPercent = approvedCount / 4.0; // Total of 4 roles
    });
    _animationController.forward(from: 0.0); // Animates the progress
    _updateButtonVisibility(); // Updates the button visibility based on status
  }

  void _updateButtonVisibility() {
    String nextApprover = _getNextApprover();
    for (var role in _showSendNotifyButtons.keys) {
      setState(() {
        _showSendNotifyButtons[role] = role == nextApprover;
      });
    }
  }

  String _getNextApprover() {
    if (_approvalStatus['plant assistant'] == 'Pending') {
      return 'plant assistant';
    } else if (_approvalStatus['plant incharge'] == 'Pending') {
      return 'plant incharge';
    } else if (_approvalStatus['production manager'] == 'Pending') {
      return 'production manager';
    } else if (_approvalStatus['rita'] == 'Pending') {
      return 'rita';
    }
    return '';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime threeDaysFromNow = now.add(const Duration(days: 3));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: threeDaysFromNow,
      selectableDayPredicate: (DateTime date) {
        // Exclude Sundays and today's date
        return date.weekday != DateTime.sunday && date != now;
      },
    );

    if (picked != null) {
      // If a date is picked, update the selected date and text controller
      setState(() {
        selectedDate = picked;
        leaveDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    } else {
      // If no date is picked, clear the selected date and text controller
      setState(() {
        selectedDate = null; // Clear the selected date
        leaveDateController.text = ''; // Clear the text controller
      });
    }
  }

  // Function to add employee
  void addEmployee() async {
    // Check if all fields are filled
    if (absenties.length <= int.parse(headCountController.text)) {
      if (selectedPlant.isEmpty ||
          selectedDept.isEmpty ||
          empNameController.text.isEmpty ||
          selectedProcessType.isEmpty ||
          selectedSkill.isEmpty ||
          leaveDateController.text.isEmpty ||
          barcodeController.text.isEmpty) {
        _showSnackBar(
          'Please fill in all required fields.',
          Colors.orange,
        );
        return;
      }

      bool isSuccess = false;
// Generate the API URL for InsertAbsentList
      String url = ApiHelper.insertAbsentListApi();
      try {
        // const url = 'http://10.3.0.70:9060/api/HR/InsertAbsentList';
        // const url = 'http://10.3.0.70:9042/api/HR/InsertAbsentList';

        // Preparing data for submission
        final data = {
          'plant': selectedPlant,
          'barcode': barcodeController.text,
          'deptCode': selectedDept,
          'empName': empNameController.text,
          'processType': selectedProcessType,
          'skillName': selectedSkill,
          'leaveDate': leaveDateController.text,
          'user': widget.userData.empNo,
          // 'user': widget.userName,
        };

        // Sending POST request
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );

        // Parsing response body
        if (response.statusCode == 200) {
          final resultData = json.decode(response.body);

          // Checking for success status
          if (resultData['IsSuccess'] == true) {
            // Handle success case with absentee data
            if (resultData['Retdata'] != null) {
              final absenteeData = json.decode(resultData['Retdata']);
              if (absenteeData['Data'] != null &&
                  absenteeData['Data'].isNotEmpty) {
                // Casting the data to List<Map<String, String>>
                List<Map<String, String>> absentees =
                    (absenteeData['Data'] as List<dynamic>).map((absentee) {
                  return {
                    'PLANT': absentee['PLANT'].toString(),
                    'BARCODE': absentee['BARCODE'].toString(),
                    'EMP_NAME': absentee['EMP_NAME'].toString(),
                    'DEPARTMENTCODE': absentee['DEPARTMENTCODE'].toString(),
                    'SKILL_TYPE': absentee['SKILL_TYPE'].toString(),
                    'SKILL_NAME': absentee['SKILL_NAME'].toString(),
                    'LEAVEDATE': absentee['LEAVEDATE'].toString(),
                  };
                }).toList();

                // Update the state to store absentees
                setState(() {
                  absenties = absentees;
                  isSuccess = true;
                  showEmployeeDetails = true;
                  isHeadReadOnly = true;
                  submitButton = false;
                });
                _showSnackBar('Employee Added successfully.', Colors.green);
              } else {
                _showSnackBar('No absentee data found.', Colors.orange);
              }
            } else if (resultData['RetData1'] != null &&
                resultData['RetData1']
                    .contains('Data submitted successfully')) {
              _showSnackBar('Employee Added successfully.', Colors.green);
            } else {
              _showSnackBar("Unexpected response: $resultData", Colors.red);
            }
          } else {
            // Handle failure case (e.g., unique constraint error)
            if (resultData['ErrMsg'] != null &&
                resultData['ErrMsg'].contains('ORA-00001')) {
              _showSnackBar('The record already exists.', Colors.orange);
            } else {
              _showSnackBar(
                "Error: ${resultData['ErrMsg'] ?? 'An unknown error occurred'}",
                Colors.red,
              );
            }
          }
        } else {
          _showSnackBar(
            'Submission failed with status code ${response.statusCode}',
            Colors.red,
          );
        }
      } catch (e) {
        _showSnackBar(
          'An error occurred while submitting data: $e',
          Colors.red,
        );
      } finally {
        // Clear fields and reset states
        setState(() {
          barcodeController.clear();
          empNameController.clear();
          leaveDateController.text = '';
          selectedProcessType = '';
          selectedSkill = '';
          isBarcodeReadOnly = false;
        });

        if (!isSuccess) {}
      }
    } else {
      _showSnackBar(
        'Absenties count should be lessthan or equal to headcount',
        Colors.red,
      );
      setState(() {
        showEmployeeDetails = false;
        submitButton = false;
        showdepthead = true;
        absentieslist = true;
      });
    }
  }

  void editEmployee(Map<String, String> employee) {
    // Fetch skills based on the skill type
    _fetchskill(employee['SKILL_TYPE'] ?? '');
    setState(() {
      // Update controllers and other states with correct values
      barcodeController.text = employee['BARCODE'] ?? '';
      empNameController.text = employee['EMP_NAME'] ?? '';
      leaveDateController.text = employee['LEAVEDATE'] ?? '';
      selectedProcessType = employee['SKILL_TYPE'] ?? '';
      selectedSkill = employee['SKILL_NAME'] ?? '';

      // Make barcode and employee name read-only
      isBarcodeReadOnly = true;
      isEmpNameReadOnly = true;

      // Show/Hide buttons based on edit mode
      showAddButton = false;
      isUpdateButtonVisible = true;
    });
  }

  Future<void> deleteEmployee(Map<String, String> employee) async {
    // Show confirmation dialog
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Are you sure you want to delete ',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                TextSpan(
                  text: employee['EMP_NAME'], // Employee name
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Customize the color here
                  ),
                ),
                const TextSpan(
                  text: ' with barcode ',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                TextSpan(
                  text: employee['BARCODE'], // Employee barcode
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red, // Customize the color here
                  ),
                ),
                const TextSpan(
                  text: '?',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled the delete
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange, // Customize the Cancel button color
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed the delete
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Customize the Yes button color
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Construct the URL with dynamic values
      // final String url =
      //     'http://10.3.0.70:9060/api/HR/DeleteData?plant=$selectedPlant&deptCode=$selectedDept&barcode=${employee['BARCODE']}';
      // final String url =
      //     'http://10.3.0.70:9042/api/HR/DeleteData?plant=$selectedPlant&deptCode=$selectedDept&barcode=${employee['BARCODE']}';

// Construct the URL by accessing _baseUrl from the ApiHelper class
      String deleteLeaveEmployeeUrl =
          '${ApiHelper.baseUrl}DeleteData?plant=$selectedPlant&deptCode=$selectedDept&barcode=${employee['BARCODE']}';

      try {
        // Make the delete request
        final response = await http.delete(Uri.parse(deleteLeaveEmployeeUrl));

        if (response.statusCode == 200) {
          // Check for specific response messages in the body
          if (response.body.contains("Deletes cannot be made after 2:00 PM.")) {
            // Show notification when delete is not allowed after 2:00 PM
            _showSnackBar(
              'Deletes cannot be made after 2:00 PM.',
              Colors.orange,
            );
          } else if (response.body.contains("Deleted successfully")) {
            setState(() {
              absenties
                  .removeWhere((emp) => emp['BARCODE'] == employee['BARCODE']);
            });

            // Show a success notification
            _showSnackBar(
              'Employee ${employee['EMP_NAME']} deleted successfully',
              Colors.green,
            );
          }
        } else {
          _showSnackBar(
            'Failed to delete employee',
            Colors.red,
          );
        }
      } catch (e) {
        // Handle network errors or exceptions
        // print('Error occurred while deleting employee: $e');
        _showSnackBar('Error occurred while removing ${employee['EMP_NAME']}',
            Colors.red);
      }
    } else {
      //print('Deletion canceled');
    }
  }

  // Function to update employee
  void updateEmployee() async {
    if (selectedPlant.isEmpty ||
        selectedDept.isEmpty ||
        empNameController.text.isEmpty ||
        selectedProcessType.isEmpty ||
        selectedSkill.isEmpty ||
        leaveDateController.text.isEmpty ||
        barcodeController.text.isEmpty) {
      _showSnackBar(
        'Please fill in all required fields.',
        Colors.orange,
      );
      return;
    }

    bool isSuccess = false;

    try {
      // const url = 'http://10.3.0.70:9060/api/HR/UpdateAbsentList';
      // const url = 'http://10.3.0.70:9042/api/HR/UpdateAbsentList';
      String url = '${ApiHelper.baseUrl}UpdateAbsentList';

      // Preparing data for submission
      final data = {
        'plant': selectedPlant,
        'barcode': barcodeController.text,
        'deptCode': selectedDept,
        'empName': empNameController.text,
        'processType': selectedProcessType,
        'skillName': selectedSkill,
        'leaveDate': leaveDateController.text,
        'user': widget.userData.empNo,
        // 'user': widget.userName,
      };

      // Sending POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      // Parsing response body
      if (response.statusCode == 200) {
        final resultData = json.decode(response.body);

        // Checking for success status
        if (resultData['IsSuccess'] == true) {
          // Handle success case with absentee data
          if (resultData['Retdata'] != null) {
            final absenteeData = json.decode(resultData['Retdata']);
            if (absenteeData['Data'] != null &&
                absenteeData['Data'].isNotEmpty) {
              // Casting the data to List<Map<String, String>>
              List<Map<String, String>> absentees =
                  (absenteeData['Data'] as List<dynamic>).map((absentee) {
                return {
                  'PLANT': absentee['PLANT'].toString(),
                  'BARCODE': absentee['BARCODE'].toString(),
                  'EMP_NAME': absentee['EMP_NAME'].toString(),
                  'DEPARTMENTCODE': absentee['DEPARTMENTCODE'].toString(),
                  'SKILL_TYPE': absentee['SKILL_TYPE'].toString(),
                  'SKILL_NAME': absentee['SKILL_NAME'].toString(),
                  'LEAVEDATE': absentee['LEAVEDATE'].toString(),
                };
              }).toList();
              // _PlantAbsentData();
              // absentList = _getAbsentList(plantAbsentList);
              // Update the state to store absentees
              setState(() {
                absenties = absentees;
                isSuccess = true;
                showEmployeeDetails = true;
                isHeadReadOnly = true;
                isBarcodeReadOnly = false;
                submitButton = false;
              });
            } else {
              _showSnackBar('No absentee data found.', Colors.orange);
            }
          } else if (resultData['RetData1'] != null &&
              resultData['RetData1'].contains('Data submitted successfully')) {
            _showSnackBar('Employee Updated successfully.', Colors.green);
            // _PlantAbsentData();
            // absentList = _getAbsentList(plantAbsentList);
            setState(() {
              isUpdateButtonVisible = false;
              showAddButton = true;
              isBarcodeReadOnly = false;
            });
          } else {
            _showSnackBar("Unexpected response: $resultData", Colors.red);
          }
        } else {
          // Handle failure case (e.g., unique constraint error)
          if (resultData['ErrMsg'] != null &&
              resultData['ErrMsg']
                  .contains('Updates cannot be made after 2:00 PM.')) {
            _showSnackBar(
                'Updates cannot be made after 2:00 PM.', Colors.orange);
          } else {
            _showSnackBar(
              "Error: ${resultData['ErrMsg'] ?? 'An unknown error occurred'}",
              Colors.red,
            );
          }
        }
      } else {
        _showSnackBar(
          'Update failed with status code ${response.statusCode}',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar(
        'An error occurred while submitting data: $e',
        Colors.red,
      );
    } finally {
      // Clear fields and reset states
      setState(() {
        barcodeController.clear();
        empNameController.clear();
        leaveDateController.text = '';
        selectedProcessType = '';
        selectedSkill = '';
        isBarcodeReadOnly = false;
      });

      if (!isSuccess) {
        // Additional handling for failure cases if needed
        // e.g., clearing dropdowns or showing specific messages
      }
    }
  }

  // Function to cancel employee update
  void cancelEmployee() {
    setState(() {
      isUpdateButtonVisible = false;
      showAddButton = true;
      barcodeController.clear();
      empNameController.clear();
      leaveDateController.text = '';
      selectedProcessType = '';
      selectedSkill = '';
      isBarcodeReadOnly = false;
    });
  }

  // Function to delete selected employees
  void deleteSelectedEmployees() async {
    // Check if any employees are selected
    if (selectedBarcodes.isEmpty) {
      _showSnackBar('No employees selected for deletion.', Colors.orange);
      return;
    }

    // Prepare the list of selected employees for display in the dialog
    String selectedEmployeesList = _getSelectedEmployeesList();

    // Show confirmation dialog
    bool isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to delete the following employees?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                selectedEmployeesList,
                style: const TextStyle(color: Colors.blue),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Dismiss the dialog, return false
              },
            ),
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Confirm the action, return true
              },
            ),
          ],
        );
      },
    );

    // If the user did not confirm, exit the function
    if (!isConfirmed) {
      return;
    }

    // Prepare data for the API request
    final data = {
      'plant': selectedPlant,
      'deptCode': selectedDept,
      'barcodes': selectedBarcodes,
    };

    try {
      // Send DELETE request
      final response = await http.delete(
        // Uri.parse('http://10.3.0.70:9060/api/HR/DeleteSelectedData'),
        // Uri.parse('http://10.3.0.70:9042/api/HR/DeleteSelectedData'),
        Uri.parse('${ApiHelper.baseUrl}DeleteSelectedData'),

        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        //final resultData = json.decode(response.body);

        // Check response structure and content
        if (response.body == 'Deleted successfully.') {
          _showSnackBar('Employees deleted successfully!', Colors.green);

          // Update the employee list and clear selected barcodes
          setState(() {
            absenties.removeWhere(
                (employee) => selectedBarcodes.contains(employee['BARCODE']));
            selectedBarcodes.clear();
          });
        } else {
          // Display error message if any
          _showSnackBar(response.body, Colors.red);
        }
      } else {
        _showSnackBar(
            'Failed to delete employees. Status: ${response.statusCode}',
            Colors.red);
      }
    } catch (e) {
      // Catch any error that occurs during the request
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  // Function to get the list of selected employees formatted for display
  String _getSelectedEmployeesList() {
    // Build a formatted string from the selected barcodes
    return absenties
        .where((employee) => selectedBarcodes.contains(employee['BARCODE']))
        .map((e) => '${e['EMP_NAME']} (${e['BARCODE']})')
        .join('\n');
  }

  // Function to handle checkbox selection
  void handleCheckboxClick(String barcode) {
    setState(() {
      if (selectedBarcodes.contains(barcode)) {
        selectedBarcodes.remove(barcode);
      } else {
        selectedBarcodes.add(barcode);
      }
    });
  }

  // Function to confirm the Data
  void confirmdata(String PlantdataabsentList) async {
    // Check if a plant has been selected
    if (selectedPlant.isEmpty) {
      _showSnackBar('Please select the plant', Colors.orange);
      return;
    }

    // setState((){
    //  _isLoading = true;
    // });
    // Await the absent list from the API
    List<Map<String, String>> plantAbsentList = await _plantAbsentData();

    // If the list is empty, show a notification and return
    if (plantAbsentList.isEmpty) {
      //_showNotification('', Colors.orange);
      return;
    }

    // Format absent list for displaying
    String absentList = _getAbsentList(plantAbsentList);

    bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Submission'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Plant: $selectedPlant',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Absent List:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  absentList,
                  style: const TextStyle(color: Colors.blue),
                ),
                if (statusConfirmed == true)
                  const Text(
                    'Already confirmed',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false on cancel
              },
            ),
            if (statusConfirmed == false) // Show button only if not confirmed
              ElevatedButton(
                child: const Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true on confirm
                },
              ),
          ],
        );
      },
    );

    // Exit if user didn't confirm the action
    if (isConfirmed == false) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    // Prepare data for submission to API
    // const url = 'http://10.3.0.70:9060/api/HR/ConfirmData';
    // const url = 'http://10.3.0.70:9042/api/HR/ConfirmData';
    String url = '${ApiHelper.baseUrl}ConfirmData';

    final data = {
      'plant': selectedPlant,
      'username': widget.userData.empNo,
      // 'username': widget.userName,
    };

    try {
      // Send the POST request to the API
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      // Handle successful response (200 status)
      if (response.statusCode == 200) {
        final resultData = json.decode(response.body);

        if (resultData['IsSuccess'] == true) {
          if (resultData['ErrMsg'] == "Data confirmed successfully.") {
            _showSnackBar('Data confirmed successfully!', Colors.green);
            _getApprovalStatus(selectedPlant); // Refresh the approval status
            setState(() {
              absenties = [];
              showEmployeeDetails = false;
              submitButton = false;
              showdepthead = false;
              isApproveStatus = true;
              flow = true;
              text = true;
              approvedplant = true;
              frstplant = false;
            });
          } else if (resultData['ErrMsg'] == "Already confirmed.") {
            _showSnackBar('Data confirmed already!', Colors.orange);
            _getApprovalStatus(selectedPlant);
            setState(() {
              absenties = [];
              showEmployeeDetails = false;
              submitButton = false;
              showdepthead = false;
              isApproveStatus = true;
              text = true;
              flow = true;
              approvedplant = true;
              frstplant = false;
            });
          }
        } else {
          // Handle specific error messages
          String errorMessage = resultData['ErrMsg'] ?? 'Submission failed.';
          if (errorMessage == "Submission is not allowed after 2:00 PM.") {
            _showSnackBar(
                'Confirmation not allowed after 2:00 PM!', Colors.orange);
          } else if (errorMessage == "No plant data submitted.") {
            _showSnackBar('No plant data submitted.', Colors.orange);
            setState(() {
              showdepthead = true;
              submitButton = true;
            });
          } else if (errorMessage == "No employees added.") {
            _showSnackBar('Please add employee(s).', Colors.orange);
            setState(() {
              showEmployeeDetails = true;
              submitButton = false;
            });
          } else if (errorMessage ==
              "An error occurred: ORA-02289: sequence does not exist") {
            _showSnackBar('Notified User Not Login.', Colors.orange);
            _getApprovalStatus(selectedPlant); // Refresh the approval status
            setState(() {
              absenties = [];
              showEmployeeDetails = false;
              submitButton = false;
              showdepthead = false;
              isApproveStatus = true;
              flow = true;
              text = true;
              approvedplant = true;
              frstplant = false;
            });
          } else {
            _showSnackBar(errorMessage, Colors.red);
          }
        }
      } else {
        // If response is not 200, show error notification
        _showSnackBar('Failed to confirm data. Status: ${response.statusCode}',
            Colors.red);
      }
    } catch (e) {
      // Handle any exceptions during the API request
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// // Function to get the absent list formatted for display
  String _getAbsentList(List<Map<String, String>> absenties) {
    // Group employees by department
    Map<String, List<Map<String, String>>> groupedByDepartment = {};

    for (var employee in absenties) {
      String departmentCode = employee['departmentCode'] ?? '';
      if (!groupedByDepartment.containsKey(departmentCode)) {
        groupedByDepartment[departmentCode] = [];
      }
      groupedByDepartment[departmentCode]!.add(employee);
    }

    // Build a formatted string from the grouped data
    StringBuffer result = StringBuffer();

    groupedByDepartment.forEach((departmentCode, employees) {
      result.writeln('Department: $departmentCode');
      for (int index = 0; index < employees.length; index++) {
        Map<String, String> employee = employees[index];
        result.writeln(
            '${index + 1}. ${employee['empName']} (${employee['barcode']})');
      }
      result.writeln(); // Add a blank line after each department
    });

    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    String count = absenties.length.toString();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Plant Selection Dropdown
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // if (frstplant)
                    //   DropdownSearch<String>(
                    //     selectedItem:
                    //         selectedPlant.isEmpty ? null : selectedPlant,
                    //     dropdownDecoratorProps: const DropDownDecoratorProps(
                    //       dropdownSearchDecoration: InputDecoration(
                    //         labelText: 'Plantss',
                    //         hintText: 'Select Plant',
                    //         border: OutlineInputBorder(),
                    //       ),
                    //     ),
                    //     onChanged: (value) {
                    //       setState(() {
                    //         selectedPlant = value ?? '';
                    //       });
                    //       _fetchDepartments(selectedPlant);
                    //       _getApprovalStatus(selectedPlant);
                    //     },
                    //     items: plants,
                    //     popupProps: const PopupProps.menu(
                    //       showSearchBox: true,
                    //       searchFieldProps: TextFieldProps(
                    //         decoration: InputDecoration(
                    //           hintText: 'Search Plantss',
                    //           border: OutlineInputBorder(),
                    //         ),
                    //       ),
                    //     ),
                    //   ),

                    // using TypeAheadField for inside texfield search box and dropdown

                    TypeAheadField<String>(
                      suggestionsCallback: (pattern) {
                        // Perform the search for matching plants based on the entered pattern
                        return plants
                            .where((plant) => plant
                                .toLowerCase()
                                .contains(pattern.toLowerCase()))
                            .toList();
                      },
                      builder: (context, controller, focusNode) {
                        // Update the controller with the initial selectedPlant if needed
                        controller.text =
                            selectedPlant; // Ensures the TextField shows the selected value
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Plants',
                            hintText: 'Select Plant',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          // onTap: () {
                          //   // Open or close the dropdown when the TextField is tapped
                          //   if (_focusNode.hasFocus) {
                          //     _focusNode
                          //         .unfocus(); // Close dropdown if tapped again
                          //   } else {
                          //     _focusNode
                          //         .requestFocus(); // Open dropdown if tapped
                          //   }
                          // },
                        );
                      },
                      hideOnSelect:
                          false, // Ensures the dropdown closes on selection
                      itemBuilder: (context, plant) {
                        // Build the suggestion widget to display plant name
                        return ListTile(
                          title: Text(plant),
                        );
                      },
                      constraints: BoxConstraints(maxHeight: 200),
                      onSelected: (plant) {
                        setState(() {
                          selectedPlant = plant; // Update the selectedPlant
                          _controller.text = plant; // Update the TextField
                        });

                        _focusNode
                            .unfocus(); // Close dropdown when tapped again

                        // Update the controller with the selected value
                        _fetchDepartments(selectedPlant);
                        _getApprovalStatus(selectedPlant);

                        // Close the dropdown by unfocusing the text field
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),

                    const SizedBox(height: 20.0),
                    if (flow)
                      Column(
                        children: <Widget>[
                          for (var role in [
                            'plant assistant',
                            'plant incharge',
                            'production manager',
                            'rita'
                          ])
                            Visibility(
                              visible: _approvalStatus[role] != null,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Role: ${role.replaceAll(RegExp(r'([A-Z])'), ' ').trim()}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Status: ${_approvalStatus[role] == 'Approved' ? 'Approved' : 'Pending'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _approvalStatus[role] ==
                                                  'Approved'
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                      if (_approvalStatus[role] == 'Approved')
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                FontAwesomeIcons.circleCheck,
                                                color: Colors.green,
                                                size: 20.0,
                                              ),
                                              const SizedBox(width: 10),
                                              // Displaying the approval time
                                              Text(
                                                _approvalTime[role] != null &&
                                                        _approvalTime[role] !=
                                                            'null'
                                                    ? 'Approved at ${_approvalTime[role]}'
                                                    : 'Not Approved',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (_approvalStatus[role] == 'Pending')
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: _showSendNotifyButtons[role] ==
                                                  true
                                              ? ElevatedButton(
                                                  onPressed: () =>
                                                      _notifyStatus(role),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.teal,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 16.0),
                                                  ),
                                                  child: const Text('Notify'),
                                                )
                                              : Container(),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              if (showdepthead) ...[
                // Department Selection Dropdown
                // DropdownSearch<String>(
                //   selectedItem: selectedDept.isEmpty ? null : selectedDept,
                //   dropdownDecoratorProps: const DropDownDecoratorProps(
                //     dropdownSearchDecoration: InputDecoration(
                //       labelText: 'Department',
                //       hintText:
                //           'Select Department', // Use hintText instead of hint
                //       border: OutlineInputBorder(),
                //     ),
                //   ),
                //   onChanged: (value) {
                //     setState(() {
                //       selectedDept = value ?? ''; // Update selected department
                //     });
                //     _fetchHeadCount(); // Fetch headcount based on department
                //     _checkData(); // Check additional data if required
                //   },
                //   items: departments,
                //   popupProps: const PopupProps.menu(
                //     showSearchBox: true, // Explicitly enable search box
                //     searchFieldProps: TextFieldProps(
                //       decoration: InputDecoration(
                //         hintText: 'Search Departments',
                //         border: OutlineInputBorder(),
                //       ),
                //     ),
                //   ),
                // )
                // ,

                TypeAheadField<String>(
                  suggestionsCallback: (pattern) {
                    // Perform the search for matching plants based on the entered pattern
                    return departments
                        .where((dept) =>
                            dept.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  builder: (context, controller, focusNode) {
                    // Update the controller with the initial selectedPlant if needed
                    controller.text =
                        selectedDept; // Ensures the TextField shows the selected value
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        hintText: 'Select Dept',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  hideOnSelect:
                      false, // Ensures the dropdown closes on selection
                  itemBuilder: (context, dept) {
                    // Build the suggestion widget to display plant name
                    return ListTile(
                      title: Text(dept),
                    );
                  },
                  constraints: BoxConstraints(maxHeight: 200),
                  onSelected: (dept) {
                    setState(() {
                      selectedDept = dept;
                    });

                    _focusNode.unfocus(); // Close dropdown when tapped again

                    // Update the controller with the selected value
                    _fetchHeadCount(); // Fetch headcount based on the selected department
                    _checkData(); // Perform additional data checks

                    // Close the dropdown by unfocusing the text field
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),

                const SizedBox(height: 20),
                TextField(
                  controller: headCountController,
                  readOnly: isHeadReadOnly, // Ensure this is a valid boolean
                  decoration: const InputDecoration(
                    labelText: 'Head Count',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  ],
                  onChanged: (value) {
                    setState(() {
                      headCount = value.trim();
                    });
                  },
                ),

                const SizedBox(height: 20),
              ],

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blueGrey, // Customize the color
                  ),
                ),
              if (submitButton) ...[
                ElevatedButton(
                  onPressed: () {
                    _handleSubmit();
                  },
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 20),
              ],

              if (showEmployeeDetails) ...[
                // Barcode Input
                // TextFormField(
                //   controller: barcodeController,
                //   decoration: const InputDecoration(
                //     labelText: 'Barcodess',
                //     border: OutlineInputBorder(),
                //   ),
                //   keyboardType: TextInputType.number,
                //   // readOnly: isBarcodeReadOnly,
                //   onChanged: (text) {
                //     // bottom model sheet for barcodes
                //     filterSuggestions(text);
                //     showSuggestions(text);
                //   },
                // ),

                // SizedBox(
                //   height: 10,
                // ),
                // TypeAheadField(
                //   builder: (context, controller, focusNode) {
                //     return TextField(
                //       controller: controller,
                //       focusNode: focusNode,
                //       obscureText:
                //           false, // You can set obscureText to false for barcode input
                //       decoration: InputDecoration(
                //         border: OutlineInputBorder(
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //         labelText: 'Barcode', // Adjust the label
                //       ),
                //     );
                //   },
                //   onSelected: (value) {
                //     // Handle selection here
                //     print('Selected: $value');
                //   },
                //   suggestionsCallback: (String search) async {
                //     // Use the filterSuggestions method to get the filtered suggestions
                //     filterSuggestions(search);
                //     // showSuggestions(search);
                //   },
                //   itemBuilder: (context, employee) {
                //     // Display employee name and barcode
                //     return ListTile(
                //       title: Text('No name'),
                //       // subtitle: Text(
                //       //     'Barcode: ${employee['barcode'] ?? 'No barcode'}'),
                //     );
                //   },
                // ),

                TypeAheadField<Map<String, String>>(
                  controller: barcodeController,
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: barcodeController,
                      // controller: controller,

                      focusNode: focusNode,
                      obscureText:
                          false, // You can set obscureText to false for barcode input
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelText: 'Barcode', // Adjust the label
                      ),
                    );
                  },
                  suggestionsCallback: (String search) async {
                    // Filter suggestions based on input text
                    filterSuggestions(
                        search); // Ensure it updates the `suggestions` list
                    return suggestions; // Return the filtered list
                  },
                  itemBuilder: (context, Map<String, String> employee) {
                    // Replicate modal UI for each suggestion
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0,
                        ),
                        title: Text(
                          employee['empName'] ?? 'No Name',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Barcode: ${employee['barcode'] ?? ''} | Plant: ${employee['plant'] ?? ''}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        tileColor: Colors.grey[200],
                      ),
                    );
                  },
                  onSelected: (Map<String, String> selectedEmployee) {
                    // Handle selection and update controllers
                    setState(() {
                      barcodeController.text =
                          selectedEmployee['barcode'] ?? '';
                      empNameController.text =
                          selectedEmployee['empName'] ?? '';
                      isBarcodeReadOnly = true;
                      isEmpNameReadOnly = true;
                    });
                  },
                  hideOnSelect: true,
                  // hideOnEmpty: true, // Hides the dropdown if no suggestions
                  hideOnLoading:
                      false, // Optionally show loading indicator if needed
                ),

                const SizedBox(height: 20),
                // Employee Name Input
                TextFormField(
                  controller: empNameController,
                  decoration: const InputDecoration(
                    labelText: 'Employee Name',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: isEmpNameReadOnly,
                ),
                const SizedBox(height: 20),
                // Process Type Picker
                DropdownSearch<String>(
                  selectedItem:
                      selectedProcessType.isEmpty ? null : selectedProcessType,
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Process Type',
                      hintText:
                          'Select Process Type', // Use hintText instead of hint
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedProcessType = value ?? '';
                    });
                    _fetchskill(
                        selectedProcessType); // Fetch skills based on selected process type
                  },
                  items: processTypes,
                ),
                const SizedBox(height: 20),
                // Skill Name Picker
                // DropdownSearch<String>(
                //   selectedItem: selectedSkill.isEmpty ? null : selectedSkill,
                //   dropdownDecoratorProps: const DropDownDecoratorProps(
                //     dropdownSearchDecoration: InputDecoration(
                //       labelText: 'Skill Name',
                //       hintText: 'Select Skill', // Use hintText instead of hint
                //       border: OutlineInputBorder(),
                //     ),
                //   ),
                //   onChanged: (value) {
                //     setState(() {
                //       selectedSkill = value ?? '';
                //     });
                //     // Add any additional logic if needed
                //   },
                //   items: skillNames,
                //   popupProps: const PopupProps.menu(
                //     showSearchBox: true, // Explicitly enable search box
                //     searchFieldProps: TextFieldProps(
                //       decoration: InputDecoration(
                //         hintText: 'Search Skill',
                //         border: OutlineInputBorder(),
                //       ),
                //     ),
                //   ),
                // ),

                TypeAheadField<String>(
                  suggestionsCallback: (pattern) {
                    // Filter the skill names based on the entered pattern (search)
                    return skillNames
                        .where((skill) =>
                            skill.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  builder: (context, controller, focusNode) {
                    // Update the controller with the initial selectedSkill value
                    controller.text =
                        selectedSkill.isEmpty ? '' : selectedSkill;

                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Skill Name',
                        hintText: 'Select Skill',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  hideOnSelect:
                      true, // Ensures the dropdown closes on selection
                  itemBuilder: (context, skill) {
                    return ListTile(
                      title: Text(skill),
                    );
                  },
                  constraints: BoxConstraints(maxHeight: 200),
                  onSelected: (skill) {
                    setState(() {
                      selectedSkill = skill; // Update selected skill
                    });

                    // Optionally, perform additional logic when a skill is selected
                    _fetchHeadCount(); // Fetch headcount based on selected skill
                    _checkData(); // Perform additional data checks

                    // Close the dropdown by unfocusing the text field
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),

                const SizedBox(height: 20),

                // Date Picker for Leave Date
                TextFormField(
                  controller: leaveDateController,
                  decoration: InputDecoration(
                    labelText: 'Leave Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                      //onPressed: leaveDateController.clear,
                    ),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                // Add and Update Buttons
                // if (showAddButton)
                //   ElevatedButton(
                //     onPressed: addEmployee,
                //     child: const Text('Add Employee'),
                //   ),
                // Add and Update Buttons
                if (showAddButton)
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null // Disable button when loading
                        : () async {
                            setState(() {
                              _isLoading = true; // Start the loading indicator
                            });

                            addEmployee(); // Execute the async function

                            setState(() {
                              _isLoading = false; // Stop the loading indicator
                            });
                          },
                    child: _isLoading
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: Colors.red,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Add Employee'),
                  ),
                if (isUpdateButtonVisible)
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: updateEmployee,
                        child: const Text('Update'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: cancelEmployee,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
              ],
              // ElevatedButton(
              //     onPressed: () async {
              //       plantAbsentList = await _plantAbsentData();
              //       absentList = _getAbsentList(plantAbsentList);
              //       confirmdata(absentList);
              //     },
              //     child: Text('Confirm Leave Data')),
              const SizedBox(height: 20),
              if (absenties.isNotEmpty && absentieslist)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ABSENT COUNT: $count',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ...absenties.map((employee) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${employee['BARCODE']} ${employee['EMP_NAME']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                  '${employee['SKILL_NAME']} ${employee['LEAVEDATE']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => editEmployee(employee),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => deleteEmployee(employee),
                              ),
                            ],
                          ),
                          leading: Checkbox(
                            value:
                                selectedBarcodes.contains(employee['BARCODE']),
                            onChanged: (bool? value) {
                              if (value != null) {
                                handleCheckboxClick(employee['BARCODE']!);
                              }
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: deleteSelectedEmployees,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete Selected'),
                    ),
                  ],
                ),
              ElevatedButton(
                  onPressed: () async {
                    plantAbsentList = await _plantAbsentData();
                    absentList = _getAbsentList(plantAbsentList);
                    confirmdata(absentList);
                  },
                  child: const Text('Confirm Leave Data')),
            ],
          ),
        ),
      ),
    );
  }
}
