import 'package:animated_movies_app/auth_provider.dart';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/screens/home_screen/home_screen.dart';

import 'package:animated_movies_app/screens/onboarding_screen/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _empNoController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> loginApiBarcode() async {
    final barcode = _barcodeController.text;
    final password = _passwordController.text;
    // Check if barcode or password is empty
    if (barcode.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barcode and password cannot be empty.'),
        ),
      );
      return; // Exit the function early if barcode or password is empty
    }

    // final url = Uri.parse(
    //     'http://10.3.0.70:9040/api/Flutter/LoginApi?empNo=$barcode&password=$password');

    final url = Uri.parse(
        'http://10.3.0.70:9042/api/HR/LoginApi?empNo=$barcode&password=$password');

    print('URL $url');

    try {
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
        final List<dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.isNotEmpty) {
          final data = jsonResponse[0];
          final loginData = LoginModelApi.fromJson(data);
          print('Login Data: $loginData');

          // Use Provider to update login state
          Provider.of<AuthProvider>(context, listen: false).login(loginData);
          // Navigate to HomeScreen with loginData
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(userData: loginData)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid barcode or password.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid barcode or password.'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Barcode and Password is not correct or Invalid Credientials'),
        ),
      );
    }
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
                    keyboardType:
                        TextInputType.number, // This sets the keyboard type
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
                    onPressed: () async {
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
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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

class LoginModelApi {
  String empNo;
  String password;
  String message;
  bool success;

  String? token;

  LoginModelApi({
    required this.empNo,
    required this.password,
    required this.message,
    required this.success,
    this.token,
  });

  factory LoginModelApi.fromJson(Map<String, dynamic> json) => LoginModelApi(
        empNo: json["emP_NO"],
        password: json["password"],
        message: json["message"],
        success: json["success"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "emP_NO": empNo,
        "password": password,
        "message": message,
        "success": success,
        "token": token,
      };
}
