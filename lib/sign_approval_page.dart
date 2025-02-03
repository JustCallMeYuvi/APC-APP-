// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
// import 'package:flutter/material.dart';
// import 'package:percent_indicator/percent_indicator.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:dropdown_search/dropdown_search.dart';

// class SignApprovalPage extends StatefulWidget {
//   // final String userCode;
//   // final String userName;
//   final LoginModelApi userData; // Use userData directly

//   const SignApprovalPage({
//     super.key,
//     required this.userData,
//     // required this.userCode, required this.userName
//   });

//   @override
//   // ignore: library_private_types_in_public_api
//   _SignApprovalPageState createState() => _SignApprovalPageState();
// }

// class _SignApprovalPageState extends State<SignApprovalPage>
//     with SingleTickerProviderStateMixin {
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   // bool _showApproveModal = false;
//   List<String> plants = ['Plant A', 'Plant B'];
//   String selectedPlant = '';
//   bool flow = false;
//   final Map<String, String> _approvalStatus = {
//     'plant assistant': 'Pending',
//     'plant incharge': 'Pending',
//     'production manager': 'Pending',
//     'rita': 'Pending',
//   };
//   final Map<String, bool> _showApproveButtons = {
//     'plant assistant': false,
//     'plant incharge': false,
//     'production manager': false,
//     'rita': false,
//   };
//   final Map<String, String> _approvalTime = {
//     'plant assistant': 'null',
//     'plant incharge': 'null',
//     'production manager': 'null',
//     'rita': 'null',
//   };
//   late TextEditingController _usernameController;
//   late TextEditingController _passwordController;

//   late AnimationController _animationController;
//   double _approvalPercent = 0.0;
//   bool showApproveModal = false;
//   bool _approval = false;
//   bool _isPasswordVisible = false; // Variable to manage password visibility
//   bool text = false;
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _usernameController = TextEditingController(text: widget.userData.empNo);
//     _passwordController = TextEditingController();
//     _updateApprovalPercent();
//     _fetchPlants();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _showNotification(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//       ),
//     );
//   }

//   Future<void> _getApprovalStatus(String plant) async {
//     try {
//       String url =
//           'http://10.3.0.70:9060/api/HR/GetApprovedStatus?plant=$plant';
//       final response = await http.get(Uri.parse(url));
//       print('Get Approval Api $url');
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);

//         if (responseData['isSuccess'] == true) {
//           if (responseData['errMsg'] == 'No records') {
//             setState(() {
//               flow = false;
//               _approval = false;
//               text = false;
//             });
//             _showNotification('Data not confirmed and submited', Colors.orange);
//             setState(() {
//               _approval = false;
//               text = false;
//             });
//           } else {
//             final retData = jsonDecode(responseData['retdata']);

//             // Update the approval status dynamically from the API
//             _approvalStatus['plant assistant'] =
//                 retData['Signature1'] == '1' ? 'Approved' : 'Pending';
//             _approvalStatus['plant incharge'] =
//                 retData['Signature2'] == '1' ? 'Approved' : 'Pending';
//             _approvalStatus['production manager'] =
//                 retData['Signature3'] == '1' ? 'Approved' : 'Pending';
//             _approvalStatus['rita'] =
//                 retData['Signature4'] == '1' ? 'Approved' : 'Pending';
//             _approvalTime['plant assistant'] = retData['SIGN1TIME'] ?? 'null';
//             _approvalTime['plant incharge'] = retData['SIGN2TIME'] ?? 'null';
//             _approvalTime['production manager'] =
//                 retData['SIGN3TIME'] ?? 'null';
//             _approvalTime['rita'] = retData['SIGN4TIME'] ?? 'null';
//             // Update the approval percent and button visibility
//             _updateApprovalPercent();

//             // Handle the confirmation status
//             String status = retData['ConfirmedStatus'];
//             if (status == 'Confirmed') {
//               setState(() {
//                 flow = true;
//                 _approval = true;
//                 text = true;
//               });
//             } else {
//               setState(() {
//                 flow = false;
//                 _approval = false;
//                 text = false;
//               });
//               _showNotification('Approval not confirmed', Colors.orange);
//             }
//           }
//         } else {
//           _showNotification(
//               'Error: ${responseData['ErrMsg'] ?? "Unknown error occurred"}',
//               Colors.red);
//         }
//       } else {
//         _showNotification(
//             'Failed to load, status code: ${response.statusCode}', Colors.red);
//       }
//     } catch (e) {
//       _showNotification('An error occurred: $e', Colors.red);
//     }
//   }

//   Future<void> _fetchPlants() async {
//     try {
//       String url = 'http://10.3.0.70:9060/api/HR/GetPlants';
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body) as List<dynamic>;
//         setState(() {
//           plants = responseData.cast<String>();
//         });
//       } else {
//         _showNotification('Failed to load plants', Colors.red);
//       }
//     } catch (e) {
//       _showNotification(
//           'An error occurred while fetching plants: $e', Colors.red);
//     }
//   }

//   void _updateApprovalPercent() {
//     int approvedCount =
//         _approvalStatus.values.where((status) => status == 'Approved').length;
//     setState(() {
//       _approvalPercent = approvedCount / 4.0; // Total of 4 roles
//     });
//     _animationController.forward(from: 0.0); // Animates the progress
//     _updateButtonVisibility(); // Updates the button visibility based on status
//   }

//   void _updateButtonVisibility() {
//     String nextApprover = _getNextApprover();
//     for (var role in _showApproveButtons.keys) {
//       setState(() {
//         _showApproveButtons[role] = role == nextApprover;
//       });
//     }
//   }

//   void _approveStatus(String role) {
//     setState(() {
//       showApproveModal = true; // Show approval modal for username/password
//     });
//   }

//   // void _onConfirmApprove() {
//   //   if (_usernameController.text.isEmpty) {
//   //     _showNotification(
//   //       'Please Enter Username.',
//   //       Colors.red,
//   //     );
//   //     return;
//   //   }
//   //   if (_passwordController.text.isEmpty) {
//   //     _showNotification(
//   //       'Please Enter Password.',
//   //       Colors.red,
//   //     );
//   //     return;
//   //   }

//   //   String nextApprover = _getNextApprover();
//   //   if (nextApprover.isNotEmpty) {
//   //     setState(() {
//   //       _approvalStatus[nextApprover] = 'Approved';
//   //       _approvalTime[nextApprover] = DateTime.now();
//   //       showApproveModal = false;
//   //       _updateApprovalPercent(); // Update percentage and visibility
//   //     });
//   //   }
//   // }
//   _clearFields() {
//     _usernameController.text = '';
//     _passwordController.text = '';
//   }

//   Future<void> _onConfirmApprove() async {
//     if (_usernameController.text.isEmpty) {
//       _showNotification(
//         'Please Enter Username.',
//         Colors.red,
//       );
//       return;
//     }
//     if (_passwordController.text.isEmpty) {
//       _showNotification(
//         'Please Enter Password.',
//         Colors.red,
//       );
//       return;
//     }
//     String currentApprover = _getNextApprover();
//     print(
//       _passwordController.text,
//     );
//     print(_usernameController.text);
//     try {
//       String url = 'http://10.3.0.70:9060/api/HR/ApproveStatus';
//       final data = {
//         'plant': selectedPlant,
//         'password': _passwordController.text,
//         'username': _usernameController.text,
//         'statusKey': currentApprover,
//       };
//       // Send a POST request with the necessary data
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode(data),
//       );
//       // Check the response status code
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);

//         // Check if the response was successful
//         if (responseData.containsKey('isSuccess') &&
//             responseData['isSuccess']) {
//           String nextApprover = _getNextApprover(); // Get next approver

//           if (nextApprover.isNotEmpty) {
//             setState(() {
//               // Update approval status and time for the next approver
//               _approvalStatus[nextApprover] = 'Approved';

//               // Close the approval modal
//               showApproveModal = false;
//               _getApprovalStatus(selectedPlant);
//               // Update percentage and visibility
//               // _updateApprovalPercent();
//               _approval = true;
//               text = true;
//             });

//             // Show a success notification
//             _showNotification('Approval Successful', Colors.green);
//           } else {
//             // No next approver, show notification or handle case
//             _showNotification(
//                 'Approval complete, no further approvers', Colors.green);
//           }
//         } else {
//           // Check if 'ErrMsg' exists in the responseData and show it
//           String errorMessage = responseData.containsKey('ErrMsg')
//               ? responseData['ErrMsg']
//               : 'Unknown error occurred';

//           // Handle specific error messages
//           if (errorMessage == 'Invalid credentials or role') {
//             _showNotification(
//                 'Invalid credentials or role. Please check your login details.',
//                 Colors.red);
//           } else {
//             _showNotification(errorMessage, Colors.red);
//           }
//         }
//       } else {
//         if (response.statusCode == 400) {
//           if (response.body.contains("Invalid credentials or role")) {
//             _showNotification('InvalidCredentails', Colors.red);
//             _usernameController.text = '';
//             _passwordController.text = '';
//           }
//         } else {
//           // Handle the case where the API returns an error status code
//           _showNotification('Server error: ${response.statusCode}', Colors.red);
//         }
//       }
//     } catch (error) {
//       // Handle any errors during the request
//       _showNotification('An error occurred: $error', Colors.red);
//     }
//   }

//   void _closeApproveModal() {
//     setState(() {
//       showApproveModal = false;
//     });
//   }

//   String _getNextApprover() {
//     if (_approvalStatus['plant assistant'] == 'Pending') {
//       return 'plant assistant';
//     } else if (_approvalStatus['plant incharge'] == 'Pending') {
//       return 'plant incharge';
//     } else if (_approvalStatus['production manager'] == 'Pending') {
//       return 'production manager';
//     } else if (_approvalStatus['rita'] == 'Pending') {
//       return 'rita';
//     }
//     return '';
//   }

//   Future<bool> _onWillPop() async {
//     Navigator.of(context).pop();
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // bool allApproved =
//     //     _approvalStatus.values.every((status) => status == 'Approved');

//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//           key: _scaffoldKey,
//           // appBar: AppBar(
//           //   title: const Text('Sign Approval'),
//           //   backgroundColor: Colors.teal,
//           //   leading: IconButton(
//           //     icon: const Icon(Icons.arrow_back),
//           //     onPressed: () {
//           //       Navigator.push(
//           //         context,
//           //         MaterialPageRoute(
//           //           builder: (context) => HomePage(
//           //             userCode: widget.userCode,
//           //             UserName: widget.userName,
//           //             userName: '',
//           //           ),
//           //         ),
//           //       );
//           //     },
//           //   ),
//           // ),
//           body: Stack(
//             children: [
//               SingleChildScrollView(
//                 child: Container(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: <Widget>[
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment
//                             .spaceBetween, // Distribute space evenly
//                         crossAxisAlignment: CrossAxisAlignment
//                             .center, // Align center vertically
//                         children: [
//                           // Plant Dropdown
//                           SizedBox(
//                             width: 200.0, // Fixed width for the dropdown
//                             child: DropdownSearch<String>(
//                               items: plants, // Dropdown items (plant list)
//                               dropdownDecoratorProps: DropDownDecoratorProps(
//                                 dropdownSearchDecoration: InputDecoration(
//                                   hintText: "Plant",
//                                   labelText: "Select Plant", // Optional label
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 10.0, vertical: 5.0),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10.0),
//                                   ),
//                                 ),
//                               ),
//                               onChanged: (String? newValue) {
//                                 setState(() {
//                                   selectedPlant =
//                                       newValue!; // Update the selected plant
//                                 });
//                                 if (newValue != null) {
//                                   _getApprovalStatus(
//                                       newValue); // Call function with selected plant
//                                 }
//                               },
//                               selectedItem:
//                                   selectedPlant, // Display the selected item
//                               popupProps: const PopupProps.menu(
//                                 showSearchBox: true, // Enable search box
//                                 searchFieldProps: TextFieldProps(
//                                   decoration: InputDecoration(
//                                     hintText: 'Search Plant',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // Percentage Indicator Column
//                           if (_approval)
//                             Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 // Circular Percent Indicator with conditional icon/loading
//                                 Stack(
//                                   alignment: Alignment
//                                       .center, // Center the elements within the chart
//                                   children: [
//                                     CircularPercentIndicator(
//                                       radius: 31.0, // Circular size
//                                       lineWidth:
//                                           8.0, // Circular border thickness
//                                       percent:
//                                           _approvalPercent, // Progress value
//                                       backgroundColor: Colors.grey[
//                                           300]!, // Background color of circle
//                                       progressColor: _approvalPercent == 1.0
//                                           ? Colors.green // Green if complete
//                                           : Colors
//                                               .orange, // Orange for incomplete progress
//                                       circularStrokeCap:
//                                           CircularStrokeCap.round,
//                                       center: _approvalPercent < 1.0
//                                           ? const Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Icon(
//                                                   Icons
//                                                       .hourglass_empty, // Pending symbol if approval not complete
//                                                   color: Colors.blueGrey,
//                                                   size: 14,
//                                                 ),
//                                                 SizedBox(height: 5),
//                                                 // Text(
//                                                 //   'Pending', // Show pending text
//                                                 //   style: TextStyle(
//                                                 //     color: Colors.blueGrey,
//                                                 //     fontSize: 8.0,
//                                                 //   ),
//                                                 // ),
//                                               ],
//                                             )
//                                           : const Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Icon(
//                                                   Icons
//                                                       .check_circle, // Approved icon
//                                                   color: Colors.green,
//                                                   size: 18,
//                                                 ),
//                                                 SizedBox(height: 5),
//                                                 Text(
//                                                   'Approved', // Show approved text
//                                                   style: TextStyle(
//                                                     color: Colors.green,
//                                                     fontSize: 7.0,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           // Percentage text
//                           if (text)
//                             Text(
//                               '${(_approvalPercent * 100).toStringAsFixed(1)}%',
//                               style: const TextStyle(
//                                 fontSize: 14.0,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 20.0),
//                       if (flow)
//                         Column(
//                           children: <Widget>[
//                             for (var role in [
//                               'plant assistant',
//                               'plant incharge',
//                               'production manager',
//                               'rita'
//                             ])
//                               Visibility(
//                                 visible: _approvalStatus[role] != null,
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 8.0),
//                                   child: Container(
//                                     padding: const EdgeInsets.all(16.0),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(8.0),
//                                       boxShadow: const [
//                                         BoxShadow(
//                                           color: Colors.black26,
//                                           blurRadius: 5.0,
//                                           offset: Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Role: ${role.replaceAll(RegExp(r'([A-Z])'), ' ').trim()}',
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8.0),
//                                         Text(
//                                           'Status: ${_approvalStatus[role] == 'Approved' ? 'Approved' : 'Pending'}',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: _approvalStatus[role] ==
//                                                     'Approved'
//                                                 ? Colors.green
//                                                 : Colors.orange,
//                                           ),
//                                         ),
//                                         if (_approvalStatus[role] == 'Approved')
//                                           Padding(
//                                             padding:
//                                                 const EdgeInsets.only(top: 8.0),
//                                             child: Row(
//                                               children: [
//                                                 const Icon(
//                                                   FontAwesomeIcons.circleCheck,
//                                                   color: Colors.green,
//                                                   size: 20.0,
//                                                 ),
//                                                 const SizedBox(width: 10),
//                                                 Text(
//                                                   _approvalTime[role] != null &&
//                                                           _approvalTime[role] !=
//                                                               'null'
//                                                       ? 'Approved at ${_approvalTime[role]}'
//                                                       : 'Not Approved',
//                                                   style: const TextStyle(
//                                                       fontSize: 14),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         if (_approvalStatus[role] == 'Pending')
//                                           Align(
//                                             alignment: Alignment.centerRight,
//                                             child: _showApproveButtons[role] ==
//                                                     true
//                                                 ? ElevatedButton(
//                                                     onPressed: () =>
//                                                         _approveStatus(role),
//                                                     style: ElevatedButton
//                                                         .styleFrom(
//                                                       backgroundColor:
//                                                           Colors.teal,
//                                                       foregroundColor:
//                                                           Colors.white,
//                                                       padding: const EdgeInsets
//                                                           .symmetric(
//                                                           vertical: 8.0,
//                                                           horizontal: 16.0),
//                                                     ),
//                                                     child:
//                                                         const Text('Approve'),
//                                                   )
//                                                 : Container(),
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             // if (_approvalPercent > 0)
//                             //   Container(
//                             //     padding: const EdgeInsets.only(top: 20.0),
//                             //     child: Align(
//                             //       alignment: Alignment.bottomCenter,
//                             //       child: AnimatedBuilder(
//                             //         animation: _animationController,
//                             //         builder: (context, child) {
//                             //           return CircularPercentIndicator(
//                             //             radius: 80.0,
//                             //             lineWidth: 10.0,
//                             //             percent: _approvalPercent,
//                             //             center: Text(
//                             //               '${(_approvalPercent * 100).toStringAsFixed(1)}%',
//                             //               style:
//                             //                   const TextStyle(fontSize: 18.0),
//                             //             ),
//                             //             progressColor: Colors.green,
//                             //             backgroundColor: Colors.grey[300]!,
//                             //           );
//                             //         },
//                             //       ),
//                             //     ),
//                             //   ),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (showApproveModal)
//                 Stack(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         _closeApproveModal(); // Close modal when clicking outside
//                         _clearFields(); // Clear fields when modal closes
//                       },
//                       child: Container(
//                         color:
//                             Colors.black.withOpacity(0.5), // Darken background
//                         width: double.infinity,
//                         height: double.infinity,
//                       ),
//                     ),
//                     Center(
//                       child: GestureDetector(
//                         onTap:
//                             () {}, // Prevent closing when tapping inside the modal
//                         child: Container(
//                           padding: const EdgeInsets.all(20.0),
//                           margin: const EdgeInsets.symmetric(horizontal: 20.0),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius:
//                                 BorderRadius.circular(20.0), // Circular edges
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.3),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 5),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: <Widget>[
//                               const Text(
//                                 'Approval Confirmation',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 20.0),
//                               TextField(
//                                 controller: _usernameController,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Username',
//                                   border: OutlineInputBorder(),
//                                 ),
//                               ),
//                               const SizedBox(height: 10.0),
//                               TextField(
//                                 controller: _passwordController,
//                                 obscureText:
//                                     !_isPasswordVisible, // Toggle visibility
//                                 decoration: InputDecoration(
//                                   labelText: 'Password',
//                                   border: const OutlineInputBorder(),
//                                   suffixIcon: IconButton(
//                                     icon: Icon(
//                                       _isPasswordVisible
//                                           ? Icons
//                                               .visibility // Show icon when password is visible
//                                           : Icons
//                                               .visibility_off, // Hide icon when password is hidden
//                                     ),
//                                     onPressed: () {
//                                       setState(() {
//                                         _isPasswordVisible =
//                                             !_isPasswordVisible; // Toggle the state
//                                       });
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 20.0),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: <Widget>[
//                                   ElevatedButton(
//                                     onPressed: () {
//                                       _onConfirmApprove();
//                                       _clearFields(); // Clear fields on approval
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.teal,
//                                     ),
//                                     child: const Text('Confirm'),
//                                   ),
//                                   ElevatedButton(
//                                     onPressed: () {
//                                       _closeApproveModal();
//                                       _clearFields(); // Clear fields on cancel
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.red,
//                                     ),
//                                     child: const Text('Cancel'),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//             ],
//           )),
//     );
//   }
// }
