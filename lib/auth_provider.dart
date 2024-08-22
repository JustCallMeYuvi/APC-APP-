// import 'dart:convert';

// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthProvider with ChangeNotifier {
//   bool _isLoggedIn = false;
//   LoginModelApi? _userData;

//   bool get isLoggedIn => _isLoggedIn;
//   LoginModelApi? get userData => _userData;

//   AuthProvider() {
//     // Initialize login state from SharedPreferences
//     _loadLoginState();
//   }

//   Future<void> _loadLoginState() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
//     if (loggedIn) {
//       // Load user data if logged in
//       String userDataJson = prefs.getString('userData') ?? '{}';
//       _userData = LoginModelApi.fromJson(json.decode(userDataJson));
//       _isLoggedIn = true;
//       notifyListeners();
//     }
//   }

//   Future<void> login(LoginModelApi userData) async {
//     // Update local state
//     _isLoggedIn = true;
//     _userData = userData;
//     notifyListeners();

//     // Save to SharedPreferences
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool('isLoggedIn', true);
//     prefs.setString('userData', json.encode(userData.toJson()));
//   }

//   Future<void> logout() async {
//     // Update local state
//     _isLoggedIn = false;
//     _userData = null;
//     notifyListeners();

//     // Clear SharedPreferences
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.remove('isLoggedIn');
//     prefs.remove('userData');
//   }
// }

import 'dart:convert';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  LoginModelApi? _userData;

  bool get isLoggedIn => _isLoggedIn;
  LoginModelApi? get userData => _userData;

  AuthProvider() {
    // Initialize login state from SharedPreferences
    _loadLoginState();
  }

  Future<void> _loadLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (loggedIn) {
      // Load user data if logged in
      String userDataJson = prefs.getString('userData') ?? '{}';
      _userData = LoginModelApi.fromJson(json.decode(userDataJson));
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> login(LoginModelApi userData) async {
    // Update local state
    _isLoggedIn = true;
    _userData = userData;
    notifyListeners();

    // Save to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    prefs.setString('userData', json.encode(userData.toJson()));

    // Obtain a new FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print('New FCM Token: $fcmToken');

    // Send the barcode (empNo) and FCM token to your API
    await _sendBarcodeAndFcmToken(userData.empNo, fcmToken);
  }

// based uplon login empNo and fcm token stored in below method
  Future<void> _sendBarcodeAndFcmToken(String empNo, String? fcmToken) async {
    final url =
        Uri.parse('http://10.3.0.70:9042/api/HR/InsertOrUpdateItemAsync');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'barcode': empNo, // Send employee number
        'Token': fcmToken, // Change the key to 'Token'
      }),
    );

    if (response.statusCode == 200) {
      print('Data sent successfully');
    } else {
      print('Failed to send data: ${response.body}');
    }
  }

  Future<void> logout() async {
    // Update local state
    _isLoggedIn = false;
    _userData = null;
    notifyListeners();

    // Clear SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn');
    prefs.remove('userData');

    // Delete the FCM token
    await FirebaseMessaging.instance.deleteToken();

    print('FCM Token deleted.');
  }
}
