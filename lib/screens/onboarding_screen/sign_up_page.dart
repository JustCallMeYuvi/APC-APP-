import 'dart:convert';

import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
            // Sign Up Header
            Padding(
              padding: EdgeInsets.only(
                top: size.height * 0.00,
                left: 24,
                right: 24,
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.white),
              ),
            ),

            // Barcode Field
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
              child: TextField(
                controller: _barcodeController,
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
                keyboardType:
                    TextInputType.number, // This sets the keyboard type
                style: const TextStyle(color: Colors.white),
              ),
            ),
            // Email Field
            // Padding(
            //   padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
            //   child: TextField(
            //     controller: _emailController,
            //     decoration: InputDecoration(
            //       hintText: 'Email',
            //       hintStyle: const TextStyle(color: Colors.white70),
            //       filled: true,
            //       fillColor: Colors.white.withOpacity(0.3),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(10),
            //         borderSide: BorderSide.none,
            //       ),
            //     ),
            //     keyboardType: TextInputType.emailAddress,
            //     style: const TextStyle(color: Colors.white),
            //   ),
            // ),
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
            // Confirm Password Field
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
              child: TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isConfirmPasswordVisible,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            // Sign Up Button
            // Sign Up Button
            Padding(
              padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
              child: ElevatedButton(
                onPressed: () {
                  if (_passwordController.text ==
                      _confirmPasswordController.text) {
                    // Call MobileRegistername function
                    MobileRegistername(context);
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Passwords do not match'),
                      ),
                    );
                  }
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
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 20),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    'Log In',
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
    );
  }

  // Future<void> MobileRegistername(BuildContext context) async {
  //   final username = _usernameController.text;
  //   final password = _passwordController.text;
  //   final empNo = _barcodeController.text;

  //   // final empNo = _empNoController.text;

  //   final url = Uri.parse(
  //       'http://10.3.0.70:9040/api/Flutter/RegisterInsertFlutterLogin?username=$username&password=$password&empNo=$empNo');

  //   print('URL $url');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     print('Response status: ${response.statusCode}');
  //     print('Response body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       // Parse the JSON response
  //       final jsonResponse = json.decode(response.body);

  //       // Handle the response as needed
  //       // Assuming the API returns a success message
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Registration successful'),
  //         ),
  //       );

  //       // Navigate to HomeScreen or perform further actions with the response data
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const HomeScreen()),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Registration failed. Please try again.'),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('An error occurred. Please try again.'),
  //       ),
  //     );
  //   }
  // }

  Future<void> MobileRegistername(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final empNo = _barcodeController.text;

    // Check if barcode or password is empty
    if (empNo.isEmpty || password.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name Barcode and password cannot be empty.'),
        ),
      );
      return; // Exit the function early if barcode or password is empty
    }

    final url = Uri.parse(
        'http://10.3.0.70:9040/api/Flutter/RegisterInsertFlutterLogin?username=$username&password=$password&empNo=$empNo');

    print('URL $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the JSON response
        final jsonResponse = json.decode(response.body);

        // Check if the response indicates success or failure
        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final firstItem = jsonResponse[0];
          bool success = firstItem['Success'];
          String message = firstItem['Message'];

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful'),
              ),
            );

            // Navigate to HomeScreen or perform further actions

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const HomeScreen()),
            // );
          } else {
            // Registration failed, show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration failed: $message'),
              ),
            );
          }
        } else {
          // Handle unexpected response format
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unexpected response format. Please try again.'),
            ),
          );
        }
      } else {
        // Handle HTTP error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Please try again.'),
          ),
        );
      }
    } catch (e) {
      // Handle network or other exceptions
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }
}
