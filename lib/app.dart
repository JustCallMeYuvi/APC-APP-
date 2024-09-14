import 'dart:convert';

import 'package:animated_movies_app/auth_provider.dart';
import 'package:animated_movies_app/screens/home_screen/home_screen.dart';
import 'package:animated_movies_app/screens/onboarding_screen/onboarding_screen.dart';
import 'package:animated_movies_app/screens/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class App extends StatelessWidget {
  const App({Key? key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Perform the update check after the widget tree is built
    //   checkForUpdates(context);
    // });

    return MaterialApp(
      title: 'Apache App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        // Your theme settings
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoggedIn) {
            return HomeScreen(userData: authProvider.userData!);
          } else {
            return const OnboardingScreen(); // Replace with your login or onboarding screen
          }
        },
      ),
    );
  }

// // Function to check for app updates
//   Future<void> checkForUpdates(BuildContext context) async {
//     // Get package info for the current app version
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     String currentVersion = packageInfo.version;

//     // API endpoint to check for updates
//     final url = Uri.parse(
//         'http://10.3.0.70:9042/api/HR/check-update?appVersion=$currentVersion');
//     print('$url');
//     final response = await http.get(url);

//     // if (response.statusCode == 200) {
//     //   final data = json.decode(response.body);
//     //   print('API Response: $data'); // To debug and see the full response

//     //   if (data != null && data.containsKey('latestVersion')) {
//     //     String latestVersion =
//     //         data['latestVersion']; // Correct key is 'latestVersion'

//     //     if (currentVersion != latestVersion) {
//     //       // Logic to show update dialog
//     //       _showUpdateDialog(latestVersion);
//     //     }
//     //   } else {
//     //     print('Invalid response: latestVersion key not found.');
//     //   }
//     // }

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       print('API Response: $data'); // To debug and see the full response

//       if (data != null && data.containsKey('latestVersion')) {
//         String latestVersion = data['latestVersion'];

//         // Compare the current app version with the latest version from the server
//         if (currentVersion != latestVersion) {
//           // Show dialog if update is available
//           _showUpdateDialog(context, latestVersion);
//         } else {
//           // Show dialog if app is up-to-date
//           _showNoUpdateDialog(context);
//         }
//       } else {
//         print('Invalid response: latestVersion key not found.');
//       }
//     } else {
//       print('Failed to check for updates');
//     }
//   }

// // // Function to show an update dialog
// // void _showUpdateDialog(String latestVersion) {
// //   // This method can be used to show a dialog asking the user to update the app.
// //   // In the real app, replace this with actual UI dialog handling.
// //   print('A new version ($latestVersion) is available. Please update the app.');
// // }

// // Function to show a dialog when an update is available
//   void _showUpdateDialog(BuildContext context, String latestVersion) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Update Available"),
//           content: Text(
//               "A new version ($latestVersion) is available. Please update the app."),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Later"),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//             ),
//             TextButton(
//               child: Text("Update Now"),
//               onPressed: () {
//                 // Logic to redirect user to the app store or download page
//                 Navigator.of(context).pop(); // Close the dialog
//                 // Open the app store link here, for example.
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

// // Function to show a dialog when the app is up-to-date
//   void _showNoUpdateDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("No Update Available"),
//           content: Text("Your app is up-to-date!"),
//           actions: <Widget>[
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
}
