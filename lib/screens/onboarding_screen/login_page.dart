import 'dart:async';
import 'dart:io';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/auth_provider.dart';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/screens/home_screen/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoginLoading = false;
  Timer? _loadingTimer;

  final TextEditingController _empNoController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkForUpdates(); // Call update check on initialization
  }

  Future<void> checkForUpdates() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    // final url = Uri.parse(
    //     'http://10.3.0.70:9042/api/HR/check-update?appVersion=$currentVersion');
    final Uri url = ApiHelper.checkUpdateApi(currentVersion);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null &&
            data.containsKey('latestVersion') &&
            data.containsKey('apkFileData')) {
          String latestVersion = data['latestVersion'];
          String apkFileData =
              data['apkFileData']; // Base64 encoded APK file data

          if (currentVersion != latestVersion) {
            _showUpdateDialog(latestVersion, apkFileData);
          } else {
            // _showNoUpdateDialog();
          }
        } else {
          print(
              'Invalid response: latestVersion or apkFileData key not found.');
        }
      } else if (response.statusCode == 404) {
        // Handle the case when no update is available
        if (response.body == "No update available") {
          // _showNoUpdateDialog();
        } else {
          print('Unexpected response body: ${response.body}');
        }
      } else {
        print(
            'Failed to check for updates: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error while checking for updates: $e');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void _showUpdateDialog(String latestVersion, String apkFileData) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          // Prevent the dialog from closing using the back button
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text("Update Available"),
            content: Text(
                "A new version ($latestVersion) is available. Please update the app."),
            actions: <Widget>[
              // TextButton(
              //   child: Text("Later"),
              //   onPressed: () {
              //     Navigator.of(context).pop(); // Close the dialog
              //   },
              // ),
              TextButton(
                child: Text("Update Now"),
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog

                  try {
                    // Start downloading the APK file
                    await _downloadAndInstallApk(apkFileData);
                  } catch (e) {
                    print('Failed to download or install APK: $e');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadAndInstallApk(String apkFileData) async {
    try {
      // Decode the base64 APK data and save to a local file
      final bytes = base64Decode(apkFileData);
      final directory =
          await getExternalStorageDirectory(); // Use external storage
      if (directory == null) {
        throw Exception("External storage directory is null");
      }
      final filePath = '${directory.path}/update.apk';
      final file = File(filePath);
      print('File Path: $filePath');

      await file.writeAsBytes(bytes);
      print('APK file written successfully.');

      // Install the APK using install_plugin
      final result = await InstallPlugin.installApk(filePath,
          appId: 'com.example.animated_movies_app');
      print('Install result: $result');

      // if (result == true) {
      //   // Assuming the result indicates success
      //   _showRestartDialog();
      // }
    } catch (e) {
      print('Failed to download or install APK: $e');
    }
  }

  // Future<void> loginApiBarcode() async {
  //   final barcode = _barcodeController.text;
  //   final password = _passwordController.text;
  //   // Check if barcode or password is empty
  //   if (barcode.isEmpty || password.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Barcode and password cannot be empty.'),
  //       ),
  //     );
  //     return; // Exit the function early if barcode or password is empty
  //   }

  //   // final url = Uri.parse(
  //   //     'http://10.3.0.70:9040/api/Flutter/LoginApi?empNo=$barcode&password=$password');

  //   final url = Uri.parse(
  //       'http://10.3.0.70:9042/api/HR/LoginApi?empNo=$barcode&password=$password');

  //   print('URL $url');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'barcode': barcode,
  //         'password': password,
  //       }),
  //     );

  //     print('Response status: ${response.statusCode}');
  //     // print('Response body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonResponse = json.decode(response.body);

  //       if (jsonResponse.isNotEmpty) {
  //         final data = jsonResponse[0];
  //         final loginData = LoginModelApi.fromJson(data);
  //         // print('Login Data: $loginData');

  //         // Use Provider to update login state
  //         Provider.of<AuthProvider>(context, listen: false).login(loginData);
  //         // Navigate to HomeScreen with loginData
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => HomeScreen(userData: loginData)),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Invalid barcode or password.'),
  //           ),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Invalid barcode or password.'),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(
  //             'Barcode and Password is not correct or Invalid Credientials'),
  //       ),
  //     );
  //   }
  // }

  void _showLoadingAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Contact Support"),
          content: const Text(
            "The operation is taking longer than expected. Please contact IT support.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Future<void> loginApiBarcode() async {
  //   final barcode = _barcodeController.text;
  //   final password = _passwordController.text;

  //   setState(() {
  //     _isLoginLoading = true; // Show loading indicator
  //   });

  //   // await ApiHelper.initializeBaseUrl();

  //   // await ApiHelper.initializeUrls();

  //   if (barcode.isEmpty || password.isEmpty) {
  //     setState(() {
  //       _isLoginLoading = false; // Hide loading indicator if fields are empty
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Barcode and password cannot be empty.'),
  //       ),
  //     );
  //     return;
  //   }

  //   // final url = Uri.parse(
  //   //     'http://10.3.0.70:9042/api/HR/LoginApi?empNo=$barcode&password=$password');

  //   // Use the ApiHelper to get the URL
  //   final url = Uri.parse(ApiHelper.login(barcode, password));
  //   print('Login URL: $url');

  //   // Start a timer to show an alert if loading exceeds 1 minute
  //   Timer? _loadingTimer = Timer(const Duration(minutes: 1), () {
  //     if (_isLoginLoading) {
  //       _showLoadingAlert();
  //     }
  //   });
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'barcode': barcode,
  //         'password': password,
  //       }),
  //     );

  //     print('Response status: ${response.statusCode}');
  //     print('Response body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       // Parse the JSON response
  //       final List<LoginModelApi> loginResponse =
  //           loginModelApiFromJson(response.body);

  //       if (loginResponse.isNotEmpty) {
  //         final loginData = loginResponse.first;

  //         if (loginData.success) {
  //           // Display success message
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text(loginData.message)),
  //           );

  //           if (loginData.token != null && loginData.token!.isNotEmpty) {
  //             // Use Provider to update login state
  //             Provider.of<AuthProvider>(context, listen: false)
  //                 .login(loginData);

  //             // Call the method to update URLs based on network
  //             // await ApiHelper.updateUrlsBasedOnNetwork();

  //             // Navigate to HomeScreen with loginData
  //             Navigator.pushReplacement(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => HomeScreen(userData: loginData),
  //               ),
  //             );
  //           }
  //         } else {
  //           // Handle unsuccessful login
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text(loginData.message)),
  //           );
  //         }
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Invalid barcode or password.')),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('An error occurred. Please try again.')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(
  //             'Something went wrong, server issue detected Please Contact IT'),
  //       ),
  //     );
  //   } finally {
  //     _loadingTimer?.cancel();
  //     setState(() {
  //       _isLoginLoading = false; // Hide loading indicator
  //     });
  //   }
  // }

  Future<void> loginApiBarcode() async {
    final barcode = _barcodeController.text;
    final password = _passwordController.text;

    setState(() {
      _isLoginLoading = true; // Show loading indicator
    });

    if (barcode.isEmpty || password.isEmpty) {
      setState(() {
        _isLoginLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barcode and password cannot be empty.'),
        ),
      );
      return;
    }

    // Start a timer to show an alert if loading exceeds 1 minute
    Timer? _loadingTimer = Timer(const Duration(minutes: 1), () {
      if (_isLoginLoading) {
        _showLoadingAlert();
      }
    });

    try {
      // 👇 Ensure URLs are updated based on Wi-Fi network first
      await ApiHelper.updateUrlsBasedOnNetwork();

      // 👇 Now build login URL with the correct base URL
      final url = Uri.parse(ApiHelper.login(barcode, password));
      print('Login URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'barcode': barcode,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<LoginModelApi> loginResponse =
            loginModelApiFromJson(response.body);

        if (loginResponse.isNotEmpty) {
          final loginData = loginResponse.first;

          if (loginData.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loginData.message)),
            );

            if (loginData.token != null && loginData.token!.isNotEmpty) {
              Provider.of<AuthProvider>(context, listen: false)
                  .login(loginData);

              // ✅ At this point, API URLs are already updated based on network
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(userData: loginData),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loginData.message)),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid barcode or password.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Something went wrong, server issue detected. Please Contact IT'),
        ),
      );
    } finally {
      _loadingTimer?.cancel();
      setState(() {
        _isLoginLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: UiConstants.backgroundGradient,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header widget
            Padding(
              padding: EdgeInsets.only(
                top: size.height * 0.00,
                left: 24,
                right: 24,
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28, left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: _barcodeController,
                    // keyboardType:
                    //     TextInputType.number, // This sets the keyboard type
                    decoration: InputDecoration(
                      hintText: 'Barcode',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    // keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            // Password Field
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            // Login Button
            Padding(
              padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoginLoading // Disable button while loading
                        ? null
                        : () async {
                            // await login();
                            await loginApiBarcode();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Sign Up Text
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(top: 8),
                  //     child: TextButton(
                  //       onPressed: () {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => const SignUpPage()),
                  //         );
                  //       },
                  //       child: const Text(
                  //         'Sign Up',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            if (_isLoginLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Model class

// List<LoginModelApi> loginModelApiFromJson(String str) =>
//     List<LoginModelApi>.from(
//         json.decode(str).map((x) => LoginModelApi.fromJson(x)));

// String loginModelApiToJson(List<LoginModelApi> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class LoginModelApi {
//   int id;
//   dynamic username;
//   dynamic email;
//   String empNo;
//   String password;
//   String message;
//   bool success;
//   dynamic deptName;
//   dynamic empName;
//   dynamic position;
//   bool status;

//   LoginModelApi({
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.empNo,
//     required this.password,
//     required this.message,
//     required this.success,
//     required this.deptName,
//     required this.empName,
//     required this.position,
//     required this.status,
//   });

//   factory LoginModelApi.fromJson(Map<String, dynamic> json) => LoginModelApi(
//         id: json["ID"],
//         username: json["Username"],
//         email: json["Email"],
//         empNo: json["EMP_NO"],
//         password: json["Password"],
//         message: json["Message"],
//         success: json["Success"],
//         deptName: json["DEPT_NAME"],
//         empName: json["EMP_NAME"],
//         position: json["POSITION"],
//         status: json["Status"],
//       );

//   Map<String, dynamic> toJson() => {
//         "ID": id,
//         "Username": username,
//         "Email": email,
//         "EMP_NO": empNo,
//         "Password": password,
//         "Message": message,
//         "Success": success,
//         "DEPT_NAME": deptName,
//         "EMP_NAME": empName,
//         "POSITION": position,
//         "Status": status,
//       };
// }

// To parse this JSON data, do
//
//     final loginModelApi = loginModelApiFromJson(jsonString);

// List<LoginModelApi> loginModelApiFromJson(String str) =>
//     List<LoginModelApi>.from(
//         json.decode(str).map((x) => LoginModelApi.fromJson(x)));

// String loginModelApiToJson(List<LoginModelApi> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class LoginModelApi {
//   int id;
//   dynamic username;
//   dynamic email;
//   String empNo;
//   String password;
//   String message;
//   bool success;
//   dynamic deptName;
//   dynamic empName;
//   dynamic position;
//   bool status;
//   String? token;

//   LoginModelApi({
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.empNo,
//     required this.password,
//     required this.message,
//     required this.success,
//     required this.deptName,
//     required this.empName,
//     required this.position,
//     required this.status,
//     this.token,
//   });

//   factory LoginModelApi.fromJson(Map<String, dynamic> json) => LoginModelApi(
//         id: json["ID"],
//         username: json["Username"],
//         email: json["Email"],
//         empNo: json["EMP_NO"],
//         password: json["Password"],
//         message: json["Message"],
//         success: json["Success"],
//         deptName: json["DEPT_NAME"],
//         empName: json["EMP_NAME"],
//         position: json["POSITION"],
//         status: json["Status"],
//         token: json["Token"],
//       );

//   Map<String, dynamic> toJson() => {
//         "ID": id,
//         "Username": username,
//         "Email": email,
//         "EMP_NO": empNo,
//         "Password": password,
//         "Message": message,
//         "Success": success,
//         "DEPT_NAME": deptName,
//         "EMP_NAME": empName,
//         "POSITION": position,
//         "Status": status,
//         "Token": token,
//       };
// }

// below new

List<LoginModelApi> loginModelApiFromJson(String str) =>
    List<LoginModelApi>.from(
        json.decode(str).map((x) => LoginModelApi.fromJson(x)));

String loginModelApiToJson(List<LoginModelApi> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class LoginModelApi {
//   String empNo;
//   dynamic useRRole;
//   String password;
//   String message;
//   bool success;

//   String? token;

//   LoginModelApi({
//     required this.empNo,
//     required this.useRRole,
//     required this.password,
//     required this.message,
//     required this.success,
//     this.token,
//   });

//   factory LoginModelApi.fromJson(Map<String, dynamic> json) => LoginModelApi(
//         empNo: json["emP_NO"],
//         useRRole: json["useR_ROLE"],
//         password: json["password"],
//         message: json["message"],
//         success: json["success"],
//         token: json["token"],
//       );

//   Map<String, dynamic> toJson() => {
//         "emP_NO": empNo,
//         "useR_ROLE": useRRole,
//         "password": password,
//         "message": message,
//         "success": success,
//         "token": token,
//       };
// }

// added login model username
class LoginModelApi {
  String empNo;
  String username;
  dynamic useRRole;
  String password;
  String message;
  bool success;
  String? token;

  LoginModelApi({
    required this.empNo,
    required this.username,
    required this.useRRole,
    required this.password,
    required this.message,
    required this.success,
    this.token,
  });

  factory LoginModelApi.fromJson(Map<String, dynamic> json) => LoginModelApi(
        empNo: json["emP_NO"] ?? "", // Provide a default empty string
        username: json["username"],
        useRRole: json["useR_ROLE"], // Allow dynamic to remain as is
        password: json["password"] ?? "", // Provide a default empty string
        message: json["message"] ?? "No message", // Provide a default message
        success: json["success"] ?? false, // Provide a default false value
        token: json["token"], // Token is nullable, no default needed
      );

  Map<String, dynamic> toJson() => {
        "emP_NO": empNo,
        "username": username,
        "useR_ROLE": useRRole,
        "password": password,
        "message": message,
        "success": success,
        "token": token,
      };
}
