// // update_helper.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:animated_movies_app/api/apis_page.dart';
// import 'package:flutter/material.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:install_plugin/install_plugin.dart';
// import 'package:url_launcher/url_launcher.dart';

// // class UpdateHelper {
// //   static Future<void> checkForUpdates(BuildContext context) async {
// //     PackageInfo packageInfo = await PackageInfo.fromPlatform();
// //     String currentVersion = packageInfo.version;

// //     final Uri url = ApiHelper.checkUpdateApi(currentVersion);
// //     try {
// //       final response = await http.get(url);

// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);

// //         if (data != null &&
// //             data.containsKey('latestVersion') &&
// //             data.containsKey('apkFileData')) {
// //           String latestVersion = data['latestVersion'];
// //           String apkFileData = data['apkFileData'];

// //           if (currentVersion != latestVersion) {
// //             _showUpdateDialog(context, latestVersion, apkFileData);
// //           }
// //         }
// //       }
// //     } catch (e) {
// //       print("Error checking updates: $e");
// //     }
// //   }

// //   static void _showUpdateDialog(
// //       BuildContext context, String latestVersion, String apkFileData) {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (_) => AlertDialog(
// //         title: const Text("Update Available"),
// //         content: Text(
// //             "A new version ($latestVersion) is available. Please update the app."),
// //         actions: [
// //           TextButton(
// //             child: const Text("Update Now"),
// //             onPressed: () async {
// //               Navigator.of(context).pop();
// //               await _downloadAndInstallApk(apkFileData);
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   static Future<void> _downloadAndInstallApk(String apkFileData) async {
// //     try {
// //       final bytes = base64Decode(apkFileData);
// //       final directory = await getExternalStorageDirectory();
// //       if (directory == null) throw Exception("Storage dir null");

// //       final filePath = "${directory.path}/update.apk";
// //       final file = File(filePath);
// //       await file.writeAsBytes(bytes);

// //       await InstallPlugin.installApk(filePath,
// //           appId: 'com.example.animated_movies_app');
// //     } catch (e) {
// //       print("Install failed: $e");
// //     }
// //   }
// // }

// class UpdateHelper {
//   // static Future<bool> checkForUpdates(BuildContext context) async {
//   //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
//   //   String currentVersion = packageInfo.version;

//   //   final Uri url = ApiHelper.checkUpdateApi(currentVersion);
//   //   print('Apk Update URL $url');
//   //   try {
//   //     final response = await http.get(url);

//   //     // if (response.statusCode == 200) {
//   //     //   final data = json.decode(response.body);

//   //     //   if (data != null &&
//   //     //       data.containsKey('latestVersion') &&
//   //     //       data.containsKey('apkFileData')) {
//   //     //     String latestVersion = data['latestVersion'];
//   //     //     String apkFileData = data['apkFileData'];

//   //     //     if (currentVersion != latestVersion) {
//   //     //       // 👇 show update dialog
//   //     //       _showUpdateDialog(context, latestVersion, apkFileData);
//   //     //       return true; // update found
//   //     //     }
//   //     //   }
//   //     // }

//   //     if (response.statusCode == 200) {
//   //       final data = jsonDecode(response.body);

//   //       final latestVersion = data['latestVersion'];
//   //       final downloadUrl = data['test70Url'];

//   //       if (latestVersion != currentVersion) {
//   //         // ✅ Now simply open the download URL
//   //         await launchUrl(Uri.parse(downloadUrl),
//   //             mode: LaunchMode.externalApplication);
//   //       }
//   //     }
//   //   } catch (e) {
//   //     print("Error checking updates: $e");
//   //   }

//   //   return false; // no update
//   // }

//   static Future<bool> checkForUpdates(BuildContext context) async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     String currentVersion = packageInfo.version;

//     final Uri url = ApiHelper.checkUpdateApi(currentVersion);
//     print('Apk Update API URL: $url');

//     try {
//       final response = await http
//           .get(url)
//           .timeout(const Duration(seconds: 60)); // ✅ important for mobile data

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         final latestVersion = data['latestVersion'];
//         final test70Url = data['test70Url'];
//         final realtime208Url = data['realtime208Url'];
//         final publicUrl = data['publicUrl'];

//         print('Latest Version: $latestVersion');
//         print('Download URL: $test70Url');

//         if (latestVersion != currentVersion) {
//           await launchUrl(
//             Uri.parse(test70Url),
//             mode: LaunchMode.externalApplication,
//           );

//           return true; // ✅ update found
//         }
//       } else if (response.statusCode == 404) {
//         print('No update available');
//       } else {
//         print('Server error: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("Error checking updates: $e");
//     }

//     return false; // ✅ no update
//   }

//   static void _showUpdateDialog(
//       BuildContext context, String latestVersion, String apkFileData) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => AlertDialog(
//           title: const Text("Update Available"),
//           content: Text(
//               "A new version ($latestVersion) is available. Please update the app."),
//           actions: [
//             TextButton(
//               child: const Text("Update Now"),
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 await _downloadAndInstallApk(apkFileData);
//               },
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   static Future<void> _downloadAndInstallApk(String apkFileData) async {
//     try {
//       final bytes = base64Decode(apkFileData);
//       final directory = await getExternalStorageDirectory();
//       if (directory == null) throw Exception("Storage dir null");

//       final filePath = "${directory.path}/update.apk";
//       final file = File(filePath);
//       await file.writeAsBytes(bytes);

//       await InstallPlugin.installApk(filePath,
//           appId: 'com.example.animated_movies_app');
//     } catch (e) {
//       print("Install failed: $e");
//     }
//   }
// }


import 'dart:convert';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateHelper {
  // 🔗 URL where user can download / see update
  static const String _updatePageUrl = 'http://10.3.0.70:8075/';

  static Future<bool> checkForUpdates(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version; // e.g. 1.1.5

    final Uri url = ApiHelper.checkUpdateApi(currentVersion);
    print('Apk Update API URL: $url');

    try {
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 60));

      print('Check version status code: ${response.statusCode}');
      print('Check version body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final bool isUpdateAvailable = data['isUpdateAvailable'] == true;
        final String latestVersion = data['latestVersion'] ?? currentVersion;

        print('Is update available: $isUpdateAvailable');
        print('Latest version from server: $latestVersion');
        print('Current version: $currentVersion');

        if (isUpdateAvailable && latestVersion != currentVersion) {
          // 👉 Show alert box with "Download update" button
          await _showUpdateDialog(context, latestVersion);
          return true; // update available
        } else {
          print('No update needed.');
        }
      } else if (response.statusCode == 404) {
        print('No update available (404).');
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error checking updates: $e");
    }

    return false; // no update
  }

  static Future<void> _showUpdateDialog(
    BuildContext context,
    String latestVersion,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must choose Later / Download
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Update Available'),
          content: Text(
            'A new version ($latestVersion) of the app is available.\n\n'
            'Please download and install the latest update.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // close dialog
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                final Uri uri = Uri.parse(_updatePageUrl);

                // Open URL in external browser
                final canLaunch = await canLaunchUrl(uri);
                if (canLaunch) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  // Optional: show error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open update page'),
                    ),
                  );
                }

                Navigator.of(ctx).pop(); // close dialog after click
              },
              child: const Text('Download Update'),
            ),
          ],
        );
      },
    );
  }
}
