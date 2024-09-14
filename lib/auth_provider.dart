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
import 'package:package_info_plus/package_info_plus.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  LoginModelApi? _userData;
  String? _fcmToken; // Add this line to store the FCM token

  bool get isLoggedIn => _isLoggedIn;
  LoginModelApi? get userData => _userData;
  String? get fcmToken => _fcmToken; // Add this getter


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
      _fcmToken = prefs.getString('fcmToken'); // Load FCM token


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

    // Save the FCM token to SharedPreferences
    _fcmToken = fcmToken;
    prefs.setString('fcmToken', fcmToken ?? '');

 

    // Send the barcode (empNo) and FCM token to your API
    // Send the barcode (empNo), FCM token, and app version to your API
    await _sendBarcodeAndFcmToken(userData.empNo, fcmToken, );

    // Send queued notifications
    await _sendQueuedNotifications(userData.empNo);
    // Send APK version to backend

  }

// based upon login empNo and fcm token stored in below method
  Future<void> _sendBarcodeAndFcmToken(
      String empNo, String? fcmToken, ) async {
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

  // Future<void> _sendQueuedNotifications(String empNo) async {
  //   final url =
  //       Uri.parse('http://10.3.0.70:9042/api/HR/send-queued-notifications');

  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({'empNo': empNo}),
  //   );

  //   if (response.statusCode == 200) {
  //     print('Queued notifications sent successfully');
  //   } else {
  //     print('Failed to send queued notifications: ${response.body}');
  //   }
  // }

  Future<void> _sendQueuedNotifications(String empNo) async {
    final url =
        Uri.parse('http://10.3.0.70:9042/api/HR/send-queued-notifications');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'barcode': empNo
      }), // Ensure 'barcode' field is present and correctly named
    );
    final body = json.encode({'barcode': empNo});
    print('Request body: $body'); // Debugging line

    if (response.statusCode == 200) {
      print('Queued notifications sent successfully');
    } else {
      print('Failed to send queued notifications: ${response.body}');
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
