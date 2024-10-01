import 'dart:convert';

import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/model/change_password_model.dart';
import 'package:animated_movies_app/model/get_emp_details.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../auth_provider.dart';

class AccountDetailsScreen extends StatefulWidget {
  final LoginModelApi userData; // Add this line

  const AccountDetailsScreen({Key? key, required this.userData})
      : super(key: key);

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  List<GetEmpDetails> empDetailsList = [];
  // bool _obscureOldPassword = true;
  // bool _obscureNewPassword = true;
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  String _currentVersion = "";

  @override
  void initState() {
    super.initState();
    fetchData(widget.userData.empNo);
    _fetchAppVersion();
  }

  Future<void> _fetchAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = packageInfo.version;
    });
  }

  Future<void> fetchData(String empNo) async {
    // final url = Uri.parse(
    //     'http://10.3.0.70:9040/api/Flutter/GetEmpDetails?empNo=${widget.userData.empNo}');

    final url = Uri.parse(
        'http://10.3.0.70:9042/api/HR/GetEmpDetails?empNo=${widget.userData.empNo}');

    print('URL ${url}');
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
            // print(
            //     'Emp Detail: ${detail.empNo}, ${detail.empName}, ${detail.deptName}, ${detail.position}');
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

  Future<void> changePassword(String empNo, String oldPassword,
      String newPassword, BuildContext context) async {
    // final url = Uri.parse(
    //     'http://10.3.0.70:9040/api/Flutter/UpdatePassword?empNo=$empNo&oldPassword=$oldPassword&newPassword=$newPassword');

    final url = Uri.parse(
        'http://10.3.0.70:9042/api/HR/UpdatePassword?empNo=$empNo&oldPassword=$oldPassword&newPassword=$newPassword');
    print('Change passwor $url');
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        final passwordResponse = ChangePasswordApi.fromJson(responseJson);

        if (passwordResponse.status) {
          // Password updated successfully
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Password Change'),
              content: Text(passwordResponse.message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Check if the error message indicates old password is incorrect
          if (passwordResponse.message.toLowerCase().contains('old password')) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Password Change Failed'),
                content: Text(passwordResponse.message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            // Handle other error messages if needed
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Error'),
                content: Text('An error occurred. Please try again.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error changing password: $e');
    }
  }

  // Future<void> logout(String? empNo, String? token) async {
  //   if (empNo == null || token == null) {
  //     print('EmpNo or Token is null. Cannot perform logout.');
  //     return;
  //   }

  //   final url = Uri.parse(
  //       'http://10.3.0.70:9040/api/Flutter/LogoutApi?empNo=$empNo&token=$token');

  //   try {
  //     final response = await http.post(url);

  //     if (response.statusCode == 200) {
  //       // Assuming the logout API returns success
  //       final jsonResponse = json.decode(response.body);
  //       print('${jsonResponse}');
  //       // Handle any additional logic after successful logout if needed

  //       // Navigate to the login screen and remove all other routes from the stack
  //       Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(
  //           builder: (context) => const LoginPage(),
  //         ),
  //         (Route<dynamic> route) => false,
  //       );
  //     } else {
  //       print('Logout request failed with status: ${response.statusCode}');
  //       // Handle logout request failure if needed
  //     }
  //   } catch (e) {
  //     print('Error logging out: $e');
  //     // Handle logout error if needed
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = widget.userData;

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Details'),
        backgroundColor: Colors.lightGreen,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Show a confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.white,
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          'No',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },

                        // onPressed: () {
                        //   // Perform logout action here
                        //   logout(user.empNo, user.token);
                        // },
                      ),
                      TextButton(
                        child: Text(
                          'Yes',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          // Perform logout action here
                          Provider.of<AuthProvider>(context, listen: false)
                              .logout();

                          // Navigate to the login screen and remove all other routes from the stack
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },

                        // onPressed: () {
                        //   // Perform logout action here
                        //   logout(user.empNo, user.token);
                        // },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: UiConstants.backgroundGradient.gradient,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              // Display fetched data here
              if (empDetailsList.isNotEmpty)
                Column(
                  children: [
                    buildAccountInfo(
                        label: 'Barcode', value: empDetailsList.first.emPNo),
                    buildAccountInfo(
                        label: 'Name', value: empDetailsList.first.emPName),
                    buildAccountInfo(
                        label: 'Department',
                        value: empDetailsList.first.depTName),
                    buildAccountInfo(
                        label: 'Position',
                        value: empDetailsList.first.position),
                    buildAccountInfo(
                        label: 'App Version',
                        value: _currentVersion.isNotEmpty
                            ? _currentVersion
                            : "Loading..."),

                    // Add other fields as needed
                  ],
                ),
              SizedBox(height: 20),
              Text(
                'Account Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              buildAccountSetting(
                icon: Icons.lock,
                label: 'Change Password',
              ),
              // buildAccountSetting(
              //   icon: Icons.notifications,
              //   label: 'Notification Settings',
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAccountInfo({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '$label',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget buildAccountSetting({required IconData icon, required String label}) {
  //   return ListTile(
  //     leading: Icon(
  //       icon,
  //       color: Colors.white,
  //       size: 24,
  //     ),
  //     title: Text(
  //       label,
  //       style: TextStyle(
  //         color: Colors.white,
  //         fontSize: 16,
  //       ),
  //     ),
  //     onTap: () {
  //       if (label == 'Change Password') {
  //         showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             String oldPassword = '';
  //             String newPassword = '';

  //             return Builder(
  //               builder: (context) {
  //                 return AlertDialog(
  //                   title: Text('Change Password'),
  //                   content: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       TextField(

  //                         controller: oldPasswordController, // Add controller here
  //                         decoration: InputDecoration(
  //                           suffixIcon: IconButton(
  //                             icon: Icon(_obscureOldPassword ? Icons.visibility : Icons.visibility_off),
  //                             onPressed: () {
  //                               setState(() {
  //                                 _obscureOldPassword = !_obscureOldPassword;
  //                               });
  //                             },
  //                           ),
  //                           labelText: 'Old Password'),
  //                         onChanged: (value) {
  //                           oldPassword = value;
  //                         },

  //                         // obscureText: true,
  //                         obscureText: _obscureOldPassword,
  //                       ),
  //                       TextField(
  //                         controller: newPasswordController, // Add controller here
  //                         decoration: InputDecoration(
  //                           labelText: 'New Password',
  //                           suffixIcon: IconButton(
  //                             icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
  //                             onPressed: () {
  //                               setState(() {
  //                                 _obscureNewPassword = !_obscureNewPassword;
  //                               });
  //                             },
  //                           ),
  //                           ),
  //                         onChanged: (value) {
  //                           newPassword = value;
  //                         },
  //                         // obscureText: true,
  //                         obscureText: _obscureNewPassword,
  //                       ),
  //                     ],
  //                   ),
  //                   actions: [
  //                     TextButton(
  //                       onPressed: () {
  //                         Navigator.of(context).pop();
  //                       },
  //                       child: Text('Cancel'),
  //                     ),
  //                     TextButton(
  //                       onPressed: () {
  //                         if (oldPassword.isNotEmpty && newPassword.isNotEmpty) {
  //                           if (oldPassword != newPassword) {
  //                             Navigator.of(context).pop();
  //                             changePassword(widget.userData.empNo, oldPassword,
  //                                 newPassword, context);
  //                           } else {
  //                             // Show a snackbar or alert indicating passwords are the same
  //                             ScaffoldMessenger.of(context).showSnackBar(
  //                               SnackBar(
  //                                 content: Text(
  //                                     'Old and new passwords cannot be the same.'),
  //                               ),
  //                             );
  //                           }
  //                         } else {
  //                           // Show a snackbar or alert indicating fields are empty
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             SnackBar(
  //                               content: Text('Please fill out all fields.'),
  //                             ),
  //                           );
  //                         }
  //                       },
  //                       child: Text('Change'),
  //                     ),
  //                   ],
  //                 );
  //               }
  //             );
  //           },
  //         );
  //       }
  //     },
  //   );
  // }

  Widget buildAccountSetting({required IconData icon, required String label}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: () {
        if (label == 'Change Password') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String oldPassword = '';
              String newPassword = '';

              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    title: Text('Change Password'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: oldPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Old Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isOldPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isOldPasswordVisible =
                                      !_isOldPasswordVisible;
                                });
                              },
                            ),
                          ),
                          onChanged: (value) {
                            oldPassword = value;
                          },
                          obscureText: !_isOldPasswordVisible,
                          style: const TextStyle(color: Colors.red),
                        ),
                        TextField(
                          controller: newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isNewPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isNewPasswordVisible =
                                      !_isNewPasswordVisible;
                                });
                              },
                            ),
                          ),
                          onChanged: (value) {
                            newPassword = value;
                          },
                          obscureText: !_isNewPasswordVisible,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (oldPassword.isNotEmpty &&
                              newPassword.isNotEmpty) {
                            if (oldPassword != newPassword) {
                              Navigator.of(context).pop();
                              changePassword(widget.userData.empNo, oldPassword,
                                  newPassword, context);
                              oldPasswordController.clear();
                              newPasswordController.clear();
                            } else {
                              // oldPasswordController.clear();
                              // newPasswordController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Old and new passwords cannot be the same.'),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill out all fields.'),
                              ),
                            );
                          }
                        },
                        child: Text('Change'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
