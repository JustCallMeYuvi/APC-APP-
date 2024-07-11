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
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }
  
}
