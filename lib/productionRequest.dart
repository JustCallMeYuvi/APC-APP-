import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
//import 'package:intl/intl.dart';

class ProductionRequestPage extends StatefulWidget {
  final String userCode;
  final String userName;

  const ProductionRequestPage({
    super.key,
    required this.userCode,
    required this.userName,
  });

  @override
  _ProductionRequestPageState createState() => _ProductionRequestPageState();
}

class _ProductionRequestPageState extends State<ProductionRequestPage>
    with SingleTickerProviderStateMixin {
  // Controllers for text fields
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController empNameController = TextEditingController();
  final TextEditingController leaveDateController = TextEditingController();
  final TextEditingController headCountController = TextEditingController();
  late AnimationController _animationController;
  double approvalPercent = 0.0;
  // Variables for state management
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
  bool frstplant = true;
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
      duration: const Duration(milliseconds: 500),
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

  void _notifyStatus(String role) {
    setState(() {});
  }

  Future<List<Map<String, String>>> _plantAbsentData() async {
    List<Map<String, String>> absentList = [];

    try {
      String url =
          'http://10.3.0.70:9060/api/HR/GetAbsentList?Plant=$selectedPlant';
      final response = await http.get(Uri.parse(url));

      // Check for successful response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List<dynamic>;

        absentList = responseData.map<Map<String, String>>((e) {
          // Split the string by comma and trim whitespace
          final parts = e.split(',').map((part) => part.trim()).toList();
          // Create a map from the split parts
          return {
            'barcode': parts[1], // Adjust index if necessary
            'empName': parts[2],
            'plant': parts[0],
            'departmentCode': parts[3],
            'skillType': parts[4],
          };
        }).toList();

        //print(absentList);
      } else if (response.statusCode == 400) {
        String responseMessage = response.body; // Capture the response body

        // Check if the response body matches the no records message
        if (responseMessage.contains('No records found')) {
          _showNotification('Please add employees.', Colors.red);
          //Navigator.of(context).pop(false);
        } else {
          _showNotification('Bad request. Please check the input.', Colors.red);
        }
      } else {
        _showNotification(
            'Failed to load Employees. Status code: ${response.statusCode}',
            Colors.red);
      }
    } catch (e) {
      _showNotification(
          'An error occurred while fetching Employees: $e', Colors.red);
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

  void showSuggestions(String text) {
    // Filter the suggestions based on the input text
    final filteredSuggestions = suggestions.where((employee) {
      final empName = employee['empName']?.toLowerCase() ?? '';
      final barcode = employee['barcode']?.toLowerCase() ?? '';
      final plant = employee['plant']?.toLowerCase() ?? '';
      final searchText = text.toLowerCase();

      // Check if any of the fields contain the search text
      return empName.contains(searchText) ||
          barcode.contains(searchText) ||
          plant.contains(searchText);
    }).toList();

    if (filteredSuggestions.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // This allows the bottom sheet to adjust its height based on content
      builder: (context) {
        return Container(
          color: Colors.white,
          child: Wrap(
            children: [
              Container(
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Select Employee',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.42, // Adjusts the height to 3/4 of the screen
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: filteredSuggestions.length,
                        itemBuilder: (context, index) {
                          final employee = filteredSuggestions[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            title: Text(
                              employee['empName'] ?? '',
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Barcode: ${employee['barcode'] ?? ''} | Plant: ${employee['plant'] ?? ''}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            tileColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            onTap: () {
                              setState(() {
                                barcodeController.text =
                                    employee['barcode'] ?? '';
                                empNameController.text =
                                    employee['empName'] ?? '';
                                isBarcodeReadOnly = true;
                                isEmpNameReadOnly = true;
                              });
                              Navigator.pop(context); // Close the modal
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchEmployeesData() async {
    try {
      String url = 'http://10.3.0.70:9060/api/HR/GetEmployeeList';
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
          _showNotification(
              'Unexpected data format: Expected a list under "retData1".',
              Colors.red);
        }
      } else {
        _showNotification('Failed to load Employees', Colors.red);
      }
    } catch (e) {
      _showNotification(
          'An error occurred while fetching Employees: $e', Colors.red);
    }
  }

  Future<void> _fetchPlants() async {
    try {
      String url = 'http://10.3.0.70:9060/api/HR/GetPlants';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          plants = responseData.cast<String>();
        });
      } else {
        _showNotification('Failed to load plants', Colors.red);
      }
    } catch (e) {
      _showNotification(
          'An error occurred while fetching plants: $e', Colors.red);
    }
  }

  Future<void> _fetchProcessTypes() async {
    try {
      String url = 'http://10.3.0.70:9060/api/HR/GetProcessType';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          processTypes = responseData.cast<String>();
        });
      } else {
        _showNotification('Failed to load process Types', Colors.red);
      }
    } catch (e) {
      _showNotification(
          'An error occurred while fetching process Types: $e', Colors.red);
    }
  }

  Future<void> _fetchDepartments(String plant) async {
    try {
      String url =
          'http://10.3.0.70:9060/api/HR/GetProductionLines?plant=$plant';
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
        _showNotification('Failed to load departments', Colors.red);
      }
    } catch (e) {
      _showNotification(
          'An error occurred while fetching departments: $e', Colors.red);
    }
  }

  Future<void> _fetchskill(String process) async {
    try {
      String url =
          'http://10.3.0.70:9060/api/HR/GetSkillNames?processType=$process';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          skillNames = responseData.cast<String>();
          //selectedSkill = '';
        });
      } else {
        _showNotification('Failed to load departments', Colors.red);
      }
    } catch (e) {
      _showNotification(
          'An error occurred while fetching departments: $e', Colors.red);
    }
  }

  Future<void> _checkData() async {
    try {
      final url =
          'http://10.3.0.70:9060/api/HR/CheckDept?plant=$selectedPlant&deptCode=$selectedDept';
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
                _showNotification('No absentee data found.', Colors.orange);
              }
            } else {
              absenties = [];
              _showNotification("Unexpected response: $resultData", Colors.red);
            }
          } else {
            // Handle failure
            if (data['errMsg'] != null &&
                data['errMsg'].contains('No records found')) {
              _showNotification("Please Submit Data", Colors.orange);
              setState(() {
                absenties = [];
                showEmployeeDetails = false;
                isHeadReadOnly = true;
                submitButton = true;
              });
            } else if (data['errMsg'] != null &&
                data['errMsg']
                    .contains('No data found for the specified criteria.')) {
              _showNotification("Please Add Absenties Data", Colors.orange);
              setState(() {
                absenties = [];
                showEmployeeDetails = true;
                isHeadReadOnly = true;
                submitButton = false;
              });
            } else {
              _showNotification(
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
        _showNotification(
            'Submission failed with status code ${response.statusCode}',
            Colors.red);
      }
    } catch (e) {
      _showNotification(
          'An error occurred while fetching data: $e', Colors.red);
    }
  }

  void _handleSubmit() async {
    if (selectedPlant.isEmpty) {
      _showNotification("Please select a plant.", Colors.red);
      return;
    }
    if (selectedDept.isEmpty) {
      _showNotification("Please select a department.", Colors.red);
      return;
    }
    if (headCount.isEmpty || int.tryParse(headCount) == null) {
      // Ensure headCount is a valid number
      _showNotification("Please enter a head count.", Colors.red);
      return;
    }

    try {
      const url = 'http://10.3.0.70:9060/api/HR/SubmitPlantData';

      // Preparing data for submission
      final data = {
        'plant': selectedPlant,
        'deptCode': selectedDept,
        'headCount': headCount, // headCount is sent as a string
        'username': widget.userName,
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
          _showNotification(
              "Submission is not allowed after 2:00 PM.", Colors.orange);
        } else if (result.contains("The record already exists.")) {
          _showNotification("The record already exists.", Colors.orange);
          setState(() {
            showEmployeeDetails = true;
            isHeadReadOnly = true;
            submitButton = false;
          });
        } else if (result.contains("Already confirmed")) {
          _showNotification("Already confirmed.", Colors.orange);
          setState(() {
            submitButton = false;
          });
        } else if (result.contains("Data submitted successfully")) {
          _showNotification('Data submitted successfully.', Colors.green);
          setState(() {
            isUpdateButtonVisible = false;
            showEmployeeDetails = true;
            isHeadReadOnly = true;
            submitButton = false;
            showAddButton = true;
          });
        } else {
          _showNotification("Unexpected response: $result", Colors.red);
        }
      } else {
        _showNotification(
            'Submission failed with status code ${response.statusCode}',
            Colors.red);
      }
    } catch (e) {
      _showNotification(
          'An error occurred while submitting data: $e', Colors.red);
    }
  }

  Future<void> _fetchHeadCount() async {
    try {
      String url =
          'http://10.3.0.70:9060/api/HR/GetHeadCount?plant=$selectedPlant&departmentCode=$selectedDept';
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
        _showNotification(
            'Failed to load head count (Status Code: ${response.statusCode})',
            Colors.red);
      }
    } catch (e) {
      _showNotification(
          'An error occurred while fetching head count: $e', Colors.red);
    }
  }

  void _showNotification(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _getApprovalStatus(String plant) async {
    try {
      String url =
          'http://10.3.0.70:9060/api/HR/GetApprovedStatus?plant=$plant';
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
            _showNotification('Please submit data', Colors.orange);
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
              _showNotification('Approval not confirmed', Colors.orange);
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
            _showNotification('Error: ${responseData['ErrMsg']}', Colors.red);
          } else {
            _showNotification('Unknown error occurred', Colors.red);
          }
        }
      } else {
        // Handle the case where the response status code is not 200
        _showNotification(
            'Failed to load, status code: ${response.statusCode}', Colors.red);
      }
    } catch (e) {
      // Handle general exceptions
      _showNotification('An error occurred: $e', Colors.red);
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
        _showNotification(
          'Please fill in all required fields.',
          Colors.orange,
        );
        return;
      }

      bool isSuccess = false;

      try {
        const url = 'http://10.3.0.70:9060/api/HR/InsertAbsentList';

        // Preparing data for submission
        final data = {
          'plant': selectedPlant,
          'barcode': barcodeController.text,
          'deptCode': selectedDept,
          'empName': empNameController.text,
          'processType': selectedProcessType,
          'skillName': selectedSkill,
          'leaveDate': leaveDateController.text,
          'user': widget.userName,
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
                _showNotification('Employee Added successfully.', Colors.green);
              } else {
                _showNotification('No absentee data found.', Colors.orange);
              }
            } else if (resultData['RetData1'] != null &&
                resultData['RetData1']
                    .contains('Data submitted successfully')) {
              _showNotification('Employee Added successfully.', Colors.green);
            } else {
              _showNotification("Unexpected response: $resultData", Colors.red);
            }
          } else {
            // Handle failure case (e.g., unique constraint error)
            if (resultData['ErrMsg'] != null &&
                resultData['ErrMsg'].contains('ORA-00001')) {
              _showNotification('The record already exists.', Colors.orange);
            } else {
              _showNotification(
                "Error: ${resultData['ErrMsg'] ?? 'An unknown error occurred'}",
                Colors.red,
              );
            }
          }
        } else {
          _showNotification(
            'Submission failed with status code ${response.statusCode}',
            Colors.red,
          );
        }
      } catch (e) {
        _showNotification(
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
      _showNotification(
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
      final String url =
          'http://10.3.0.70:9060/api/HR/DeleteData?plant=$selectedPlant&deptCode=$selectedDept&barcode=${employee['BARCODE']}';

      try {
        // Make the delete request
        final response = await http.delete(Uri.parse(url));

        if (response.statusCode == 200) {
          // Check for specific response messages in the body
          if (response.body.contains("Deletes cannot be made after 2:00 PM.")) {
            // Show notification when delete is not allowed after 2:00 PM
            _showNotification(
              'Deletes cannot be made after 2:00 PM.',
              Colors.orange,
            );
          } else if (response.body.contains("Deleted successfully")) {
            setState(() {
              absenties
                  .removeWhere((emp) => emp['BARCODE'] == employee['BARCODE']);
            });

            // Show a success notification
            _showNotification(
              'Employee ${employee['EMP_NAME']} deleted successfully',
              Colors.green,
            );
          }
        } else {
          _showNotification(
            'Failed to delete employee',
            Colors.red,
          );
        }
      } catch (e) {
        // Handle network errors or exceptions
        // print('Error occurred while deleting employee: $e');
        _showNotification(
            'Error occurred while removing ${employee['EMP_NAME']}',
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
      _showNotification(
        'Please fill in all required fields.',
        Colors.orange,
      );
      return;
    }

    bool isSuccess = false;

    try {
      const url = 'http://10.3.0.70:9060/api/HR/UpdateAbsentList';

      // Preparing data for submission
      final data = {
        'plant': selectedPlant,
        'barcode': barcodeController.text,
        'deptCode': selectedDept,
        'empName': empNameController.text,
        'processType': selectedProcessType,
        'skillName': selectedSkill,
        'leaveDate': leaveDateController.text,
        'user': widget.userName,
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
              _showNotification('No absentee data found.', Colors.orange);
            }
          } else if (resultData['RetData1'] != null &&
              resultData['RetData1'].contains('Data submitted successfully')) {
            _showNotification('Employee Updated successfully.', Colors.green);
            // _PlantAbsentData();
            // absentList = _getAbsentList(plantAbsentList);
            setState(() {
              isUpdateButtonVisible = false;
              showAddButton = true;
              isBarcodeReadOnly = false;
            });
          } else {
            _showNotification("Unexpected response: $resultData", Colors.red);
          }
        } else {
          // Handle failure case (e.g., unique constraint error)
          if (resultData['ErrMsg'] != null &&
              resultData['ErrMsg']
                  .contains('Updates cannot be made after 2:00 PM.')) {
            _showNotification(
                'Updates cannot be made after 2:00 PM.', Colors.orange);
          } else {
            _showNotification(
              "Error: ${resultData['ErrMsg'] ?? 'An unknown error occurred'}",
              Colors.red,
            );
          }
        }
      } else {
        _showNotification(
          'Update failed with status code ${response.statusCode}',
          Colors.red,
        );
      }
    } catch (e) {
      _showNotification(
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
      _showNotification('No employees selected for deletion.', Colors.orange);
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
        Uri.parse('http://10.3.0.70:9060/api/HR/DeleteSelectedData'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        //final resultData = json.decode(response.body);

        // Check response structure and content
        if (response.body == 'Deleted successfully.') {
          _showNotification('Employees deleted successfully!', Colors.green);

          // Update the employee list and clear selected barcodes
          setState(() {
            absenties.removeWhere(
                (employee) => selectedBarcodes.contains(employee['BARCODE']));
            selectedBarcodes.clear();
          });
        } else {
          // Display error message if any
          _showNotification(response.body, Colors.red);
        }
      } else {
        _showNotification(
            'Failed to delete employees. Status: ${response.statusCode}',
            Colors.red);
      }
    } catch (e) {
      // Catch any error that occurs during the request
      _showNotification('Error: ${e.toString()}', Colors.red);
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

//   void confirmdata(String PlantdataabsentList) async {
//     // Check if all required fields are filled
//     if (selectedPlant.isEmpty) {
//       _showNotification('Please select the plant', Colors.orange);
//       return;
//     }
//     plantAbsentList = _PlantAbsentData() as List<Map<String, String>>;
//     absentList = _getAbsentList(plantAbsentList);
//     // Show confirmation dialog
//     bool isConfirmed = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Submission'),
//           content: SingleChildScrollView(
//             // Enable scrolling when content exceeds size
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Plant: $selectedPlant',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const Text(
//                   'Absent List:',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   absentList, // Display the properly formatted absent list
//                   style: const TextStyle(color: Colors.blue),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context)
//                     .pop(false); // Dismiss the dialog, return false
//               },
//             ),
//             ElevatedButton(
//               child: const Text('Confirm'),
//               onPressed: () {
//                 Navigator.of(context)
//                     .pop(true); // Confirm the action, return true
//               },
//             ),
//           ],
//         );
//       },
//     );

//     // If the user did not confirm, exit the function
//     if (!isConfirmed) {
//       return;
//     }

//     const url = 'http://10.3.0.70:9060/api/HR/ConfirmData';

//     // Prepare data for the API request
//     final data = {
//       'plant': selectedPlant,
//       'username': widget.userName,
//     };

//     try {
//       // Send POST request
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(data),
//       );

//       // Check for success response (status code 200)
//       if (response.statusCode == 200) {
//         final resultData = json.decode(response.body);

//         /// Check response structure and content
//         if (resultData['IsSuccess'] == true) {
//           if (resultData['ErrMsg'] == "Data confirmed successfully.") {
//             _showNotification('Data confirmed successfully!', Colors.green);
//             // Update plant Assistant status to 'Approved'
//             // _approvalStatus['plant Assistant'] = 'Approved';
//             //  _approvalTime['plant assistant'] = "${DateTime.now().toLocal().toString().substring(11, 16)} ${DateTime.now().toLocal().toString().substring(0, 10)}";
//             //_updateApprovalPercent();
//             _getApprovalStatus(selectedPlant);
//             // Update the state or UI with the approval status and percentage
//             setState(() {
//               absenties = [];
//               showEmployeeDetails = false;
//               //showAddButton = true;
//               submitButton = false;
//               showdepthead = false;
//               isApproveStatus = true;
//               flow = true;
//               text = true;
//               approvedplant = true;
//               frstplant = false;
//               // Update approvalPercent
//             });
//           }
//         } else {
//           if (resultData['ErrMsg'] == "Already confirmed.") {
//             _showNotification('Data confirmed Already!', Colors.orange);
//             // Update plant Assistant status to 'Approved'
//             //_approvalStatus['plant Assistant'] = 'Approved';
//             _getApprovalStatus(selectedPlant);
//             //_updateApprovalPercent();
//             setState(() {
//               absenties = [];
//               showEmployeeDetails = false;
//               showAddButton = false;
//               submitButton = false;
//               showdepthead = false;
//               isApproveStatus = true;
//               text = true;
//               // approvalPercent = approvalPercentage;
//               flow = true;
//               approvedplant = true;
//               frstplant = false;
//             });
//           } else if (resultData['ErrMsg'] ==
//               "Submission is not allowed after 2:00 PM.") {
//             _showNotification(
//                 'Submission is not allowed after 2:00 PM!', Colors.orange);
//             setState(() {
//               showdepthead = false;
//               absenties = [];
//               showEmployeeDetails = false;
//               submitButton = false;
//             });
//           } else if (resultData['ErrMsg'] == "No plant data submitted.") {
//             _showNotification('No plant data submitted.', Colors.orange);
//             setState(() {
//               showdepthead = true;
//               absenties = [];
//               showEmployeeDetails = false;
//               submitButton = true;
//             });
//           } else if (resultData['ErrMsg'] == "No employees added.") {
//             _showNotification('Please Add Employee', Colors.orange);
//             setState(() {
//               showdepthead = true;
//               absenties = [];
//               showEmployeeDetails = true;
//               submitButton = false;
//             });
//           } else {
//             // Check if ErrMsg exists and is not null or empty
//             String errorMessage = resultData['ErrMsg'] ?? 'Submission failed.';
//             _showNotification(errorMessage, Colors.red);
//             setState(() {
//               showdepthead = false;
//               absenties = [];
//               showEmployeeDetails = false;
//               submitButton = false;
//             });
//           }
//         }
//       } else {
//         _showNotification(
//             'Failed to confirm data. Status: ${response.statusCode}',
//             Colors.red);
//       }
//     } catch (e) {
//       // Catch any error that occurs during the request
//       _showNotification('Error: ${e.toString()}', Colors.red);
//     }
//   }

  void confirmdata(String PlantdataabsentList) async {
    // Check if a plant has been selected
    if (selectedPlant.isEmpty) {
      _showNotification('Please select the plant', Colors.orange);
      return;
    }

    // Await the absent list from the API
    List<Map<String, String>> plantAbsentList = await _plantAbsentData();

    // If the list is empty, show a notification and return
    if (plantAbsentList.isEmpty) {
     //_showNotification('No absent employees to display.', Colors.orange);
      return;
    }

    // Format absent list for displaying
    String absentList = _getAbsentList(plantAbsentList);

    // Show confirmation dialog
    bool isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Submission'),
          content: SingleChildScrollView(
            // Enable scrolling when content exceeds size
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
                  absentList, // Display the properly formatted absent list
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Dismiss the dialog, return false
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Confirm the action, return true
              },
            ),
          ],
        );
      },
    );

    // Exit if user didn't confirm the action
    if (!isConfirmed) {
      return;
    }

    // Prepare data for submission to API
    const url = 'http://10.3.0.70:9060/api/HR/ConfirmData';
    final data = {
      'plant': selectedPlant,
      'username': widget.userName,
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
            _showNotification('Data confirmed successfully!', Colors.green);
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
            _showNotification('Data confirmed already!', Colors.orange);
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
            _showNotification(
                'Confirmation not allowed after 2:00 PM!', Colors.orange);
          } else if (errorMessage == "No plant data submitted.") {
            _showNotification('No plant data submitted.', Colors.orange);
            setState(() {
              showdepthead = true;
              submitButton = true;
            });
          } else if (errorMessage == "No employees added.") {
            _showNotification('Please add employee(s).', Colors.orange);
            setState(() {
              showEmployeeDetails = true;
              submitButton = false;
            });
          } else {
            _showNotification(errorMessage, Colors.red);
          }
        }
      } else {
        // If response is not 200, show error notification
        _showNotification(
            'Failed to confirm data. Status: ${response.statusCode}',
            Colors.red);
      }
    } catch (e) {
      // Handle any exceptions during the API request
      _showNotification('Error: ${e.toString()}', Colors.red);
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
      appBar: AppBar(
        title: const Text('Production Request'),
        backgroundColor: Colors.teal,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => HomePage(
        //           userCode: widget.userCode,
        //           userName: widget.userName,
        //           UserName: widget.userName,
        //         ),
        //       ),
        //     );
        //   },
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Confirm Data',
            onPressed: () {
              _plantAbsentData();
              absentList = _getAbsentList(plantAbsentList);
              confirmdata(absentList);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Plant Selection Dropdown
              SingleChildScrollView(
                child: Container(
                  //padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      if (frstplant)
                        DropdownSearch<String>(
                          selectedItem:
                              selectedPlant.isEmpty ? null : selectedPlant,
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Plant',
                              hintText: 'Select Plant',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedPlant = value ?? '';
                            });
                            _fetchDepartments(selectedPlant);
                            _getApprovalStatus(selectedPlant);
                          },
                          items: plants,
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Search Plants',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      if (approvedplant)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Plant Dropdown
                            SizedBox(
                              width: 200.0,
                              child: DropdownSearch<String>(
                                items: plants,
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    hintText: "Plant",
                                    labelText: "Select Plant",
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedPlant =
                                          newValue; // Update the selected plant
                                    });
                                    _fetchDepartments(selectedPlant);
                                    _getApprovalStatus(
                                        newValue); // Call function with selected plant
                                  }
                                },
                                selectedItem: selectedPlant,
                                popupProps: const PopupProps.menu(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    decoration: InputDecoration(
                                      hintText: 'Search Plant',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Percentage Indicator Column
                            if (isApproveStatus)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularPercentIndicator(
                                        radius: 31.0,
                                        lineWidth: 8.0,
                                        percent: approvalPercent,
                                        backgroundColor: Colors.grey[300]!,
                                        progressColor: approvalPercent == 1.0
                                            ? Colors.green
                                            : Colors.orange,
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                        center: approvalPercent < 1.0
                                            ? const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.hourglass_empty,
                                                      color: Colors.blueGrey,
                                                      size: 16),
                                                  SizedBox(height: 5),
                                                  // Text('Pending',
                                                  //     style: TextStyle(
                                                  //         color:
                                                  //             Colors.blueGrey,
                                                  //         fontSize: 8.0)),
                                                ],
                                              )
                                            : const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 18),
                                                  SizedBox(height: 5),
                                                  Text('Approved',
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 7.0)),
                                                ],
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            // Percentage text
                            if (text)
                              Text(
                                '${(approvalPercent * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
                              ),
                          ],
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
                                            child: _showSendNotifyButtons[
                                                        role] ==
                                                    true
                                                ? ElevatedButton(
                                                    onPressed: () =>
                                                        _notifyStatus(role),
                                                    style: ElevatedButton
                                                        .styleFrom(
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
              ),
              if (showdepthead) ...[
                // Department Selection Dropdown
                DropdownSearch<String>(
                  selectedItem: selectedDept.isEmpty ? null : selectedDept,
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Department',
                      hintText:
                          'Select Department', // Use hintText instead of hint
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedDept = value ?? ''; // Update selected department
                    });
                    _fetchHeadCount(); // Fetch headcount based on department
                    _checkData(); // Check additional data if required
                  },
                  items: departments,
                  popupProps: const PopupProps.menu(
                    showSearchBox: true, // Explicitly enable search box
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: 'Search Departments',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
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
                TextFormField(
                  controller: barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Barcode',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  readOnly: isBarcodeReadOnly,
                  onChanged: (text) {
                    filterSuggestions(text);
                    showSuggestions(text);
                  },
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
                DropdownSearch<String>(
                  selectedItem: selectedSkill.isEmpty ? null : selectedSkill,
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Skill Name',
                      hintText: 'Select Skill', // Use hintText instead of hint
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedSkill = value ?? '';
                    });
                    // Add any additional logic if needed
                  },
                  items: skillNames,
                  popupProps: const PopupProps.menu(
                    showSearchBox: true, // Explicitly enable search box
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: 'Search Skill',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
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
                if (showAddButton)
                  ElevatedButton(
                    onPressed: addEmployee,
                    child: const Text('Add'),
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
            ],
          ),
        ),
      ),
    );
  }
}
