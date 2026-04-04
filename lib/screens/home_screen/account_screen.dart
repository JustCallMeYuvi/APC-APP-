import 'dart:convert';

import 'package:animated_movies_app/api/apis_page.dart';
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
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  String _currentVersion = "";
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    // fetchData(widget.userData.empNo);
    fetchData(widget.userData.username);

    _fetchAppVersion();
  }

  Future<void> _fetchAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = packageInfo.version;
    });
  }

  Future<void> fetchData(String username) async {
    // final url = Uri.parse(
    //     'http://10.3.0.70:9040/api/Flutter/GetEmpDetails?empNo=${widget.userData.empNo}');

    // final url = Uri.parse(
    //     'http://10.3.0.70:9042/api/HR/GetEmpDetails?empNo=${widget.userData.empNo}');
    // Get the URL dynamically using ApiHelper
    // final String urlString = ApiHelper.getEmpDetails(empNo);

    final String urlString = ApiHelper.getEmpDetailsUserNameBased(username);

    final Uri url = Uri.parse(urlString); // Convert the URL to Uri
// print(object)
    print('URL ${url}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        // Debug: Print the raw response body
        // print('Response body: ${response.body}');

        // Debug: Print the parsed JSON data
        jsonResponse.forEach((data) {
          // print('Parsed JSON item: $data');
        });

        setState(() {
          empDetailsList =
              jsonResponse.map((data) => GetEmpDetails.fromJson(data)).toList();

          // Debug: Print the list of empDetailsList
          empDetailsList.forEach((detail) {
            // print(
            //     'Emp Detail: ${detail.empNo}, ${detail.empName}, ${detail.deptName}, ${detail.position}');
            // print(
            //     'Emp Detail: ${detail.emPNo}, ${detail.emPName}, ${detail.depTName}, ${detail.position}');
          });
        });
      } else {
        // print('Request failed with status: ${response.statusCode}');
        // Handle error case, show error message or retry logic
      }
    } catch (e) {
      // print('Error fetching data: $e');
      // Handle error case, show error message or retry logic
    }
  }

  // Future<void> changePassword(
  //   String username,
  //   String oldPassword,
  //   String newPassword,
  //   BuildContext context,
  // ) async {
  //   final url = Uri.parse('${ApiHelper.baseUrl}UpdateUserPassword');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         "username": username,
  //         "oldPassword": oldPassword,
  //         "newPassword": newPassword,
  //       }),
  //     );

  //     if (!context.mounted) return;

  //     final responseJson = json.decode(response.body);

  //     if (response.statusCode == 200) {
  //       bool success = responseJson["success"];
  //       String message = responseJson["message"];

  //       // 🔥 CLEAR fields always
  //       oldPasswordController.clear();
  //       newPasswordController.clear();

  //       // ✅ SHOW ALERT FOR ALL CASES
  //       showDialog(
  //         context: context,
  //         barrierDismissible: false, // user must click OK
  //         builder: (context) => AlertDialog(
  //           title: Text(success ? "Success" : "Failed"),
  //           content: Text(message),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);

  //                 // ✅ AUTO LOGOUT ONLY ON SUCCESS
  //                 if (success) {
  //                   _logoutUser(context);
  //                 }
  //               },
  //               child: const Text("OK"),
  //             )
  //           ],
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (!context.mounted) return;

  //     oldPasswordController.clear();
  //     newPasswordController.clear();

  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text("Error"),
  //         content: const Text("Something went wrong"),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("OK"),
  //           )
  //         ],
  //       ),
  //     );
  //   }
  // }

  Future<Map<String, dynamic>> changePassword(
    String username,
    String oldPassword,
    String newPassword,
  ) async {
    final url = Uri.parse('${ApiHelper.baseUrl}UpdateUserPassword');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      final responseJson = json.decode(response.body);

      return {
        "success": responseJson["success"] ?? false,
        "message": responseJson["message"] ?? "Something went wrong",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Something went wrong",
      };
    }
  }

  void _logoutUser(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
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
        title: const Text('Account Details'),
        backgroundColor: Colors.lightGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Column(
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
                        child: const Text(
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
                        child: const Text(
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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Display fetched data here
              if (empDetailsList.isNotEmpty)
                Column(
                  children: [
                    buildAccountInfo(
                        label: 'User Name',
                        value: empDetailsList.first.username),
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
              const SizedBox(height: 20),
              const Text(
                'Account Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
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
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAccountSetting({required IconData icon, required String label}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: () {
        if (label == 'Change Password') {
          _showChangePasswordDialog();
        }
      },
    );
  }

  void _showChangePasswordDialog() {
    final confirmController = TextEditingController();
    bool showOld = false, showNew = false, showConfirm = false;
    String errorText = "";
    double strength = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.shade50,
                  child:
                      Icon(Icons.lock, size: 16, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Change password",
                        style: TextStyle(fontSize: 15)),
                    Text(
                      "You'll be signed out after update",
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Current password ──
                  _fieldLabel("CURRENT PASSWORD"),
                  _passwordField(
                    controller: oldPasswordController,
                    hint: "Enter current password",
                    visible: showOld,
                    icon: Icons.person_outline,
                    onToggle: () => setState(() => showOld = !showOld),
                  ),
                  const SizedBox(height: 12),

                  // ── New password + strength ──
                  _fieldLabel("NEW PASSWORD"),
                  _passwordField(
                    controller: newPasswordController,
                    hint: "Enter new password",
                    visible: showNew,
                    icon: Icons.lock_outline,
                    onToggle: () => setState(() => showNew = !showNew),
                    // onChanged: (v) {
                    //   setState(() => strength = _calcStrength(v));
                    // },
                    onChanged: (v) {
                      final s = _calcStrength(v);
                      print("Password: $v Strength: $s"); // 👈 debug
                      setState(() => strength = s);
                    },
                  ),
                  const SizedBox(height: 6),
                  _strengthBar(strength),
                  const SizedBox(height: 12),

                  // ── Confirm password ──
                  _fieldLabel("CONFIRM NEW PASSWORD"),
                  _passwordField(
                    controller: confirmController,
                    hint: "Re-enter new password",
                    visible: showConfirm,
                    icon: Icons.check_circle_outline,
                    onToggle: () => setState(() => showConfirm = !showConfirm),
                    borderColor: confirmController.text.isEmpty
                        ? null
                        : (confirmController.text == newPasswordController.text
                            ? Colors.green
                            : Colors.red),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (confirmController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        confirmController.text == newPasswordController.text
                            ? "Passwords match"
                            : "Passwords do not match",
                        style: TextStyle(
                          fontSize: 11,
                          color: confirmController.text ==
                                  newPasswordController.text
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),

                  // ── Error banner ──
                  if (errorText.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(errorText,
                          style: TextStyle(
                              fontSize: 12, color: Colors.red.shade700)),
                    ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  oldPasswordController.clear();
                  newPasswordController.clear();
                  confirmController.clear();
                  Navigator.pop(context);
                },
                child: const Text("CANCEL"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        final old = oldPasswordController.text.trim();
                        final nw = newPasswordController.text.trim();
                        final conf = confirmController.text.trim();

                        if (old.isEmpty || nw.isEmpty || conf.isEmpty) {
                          setState(
                              () => errorText = "Please fill in all fields.");
                          return;
                        }
                        if (nw != conf) {
                          setState(
                              () => errorText = "New passwords do not match.");
                          return;
                        }
                        if (old == nw) {
                          setState(() => errorText =
                              "New password must differ from current.");
                          return;
                        }

                        // 🔥 ADD THIS BLOCK
                        double currentStrength = _calcStrength(nw);

                        if (currentStrength < 0.5) {
                          setState(() => errorText =
                              "Use uppercase, number & special character");
                          return;
                        }
                        setState(() {
                          isLoading = true;
                          errorText = "";
                        });

                        final result = await changePassword(
                            widget.userData.username, old, nw);

                        // ✅ Always reset loading BEFORE popping
                        setState(() => isLoading = false);

                        // ✅ Guard against dialog being disposed
                        if (!context.mounted) return;

                        if (result["success"] == true) {
                          oldPasswordController.clear();
                          newPasswordController.clear();
                          confirmController.clear();

                          Navigator.pop(context); // close dialog first

                          // ✅ Use the outer widget's context, not the dialog's
                          if (!mounted) return;

                          showDialog(
                            context: this
                                .context, // 👈 use widget context, not dialog context
                            barrierDismissible: false,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              title: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green.shade600),
                                  const SizedBox(width: 8),
                                  const Text("Success"),
                                ],
                              ),
                              content: Text(
                                  result["message"] ?? "Password updated."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(this.context);
                                    _logoutUser(this.context);
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        } else {
                          setState(() => errorText =
                              result["message"] ?? "Something went wrong.");
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text("UPDATE PASSWORD"),
              ),
            ],
          );
        },
      ),
    );
  }

// ── Helpers ──────────────────────────────────────────

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(text,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 0.8)),
      );

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required IconData icon,
    required VoidCallback onToggle,
    Color? borderColor,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, size: 16),
        suffixIcon: IconButton(
          iconSize: 16,
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: borderColor ?? Colors.lightGreen, width: 1.5),
        ),
      ),
    );
  }

  // double _calcStrength(String v) {
  //   double s = 0;
  //   if (v.length >= 8) s += 0.25;
  //   if (RegExp(r'[A-Z]').hasMatch(v)) s += 0.25;
  //   if (RegExp(r'[0-9]').hasMatch(v)) s += 0.25;
  //   if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) s += 0.25;
  //   return s;
  // }
  double _calcStrength(String v) {
    if (v.isEmpty) return 0;

    double s = 0;

    if (v.length >= 6) s += 0.2;
    if (v.length >= 10) s += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(v)) s += 0.2;
    if (RegExp(r'[0-9]').hasMatch(v)) s += 0.2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) s += 0.2;

    return s.clamp(0, 1);
  }

  Widget _strengthBar(double strength) {
    Color color = strength <= 0.25
        ? Colors.red
        : strength <= 0.5
            ? Colors.orange
            : strength <= 0.75
                ? Colors.lightGreen
                : Colors.green;
    String label = strength <= 0
        ? ""
        : strength <= 0.25
            ? "Weak"
            : strength <= 0.5
                ? "Fair"
                : strength <= 0.75
                    ? "Good"
                    : "Strong";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: strength,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(label, style: TextStyle(fontSize: 11, color: color)),
          ),
      ],
    );
  }
}
