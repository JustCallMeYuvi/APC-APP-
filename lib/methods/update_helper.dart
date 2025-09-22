// update_helper.dart
import 'dart:convert';
import 'dart:io';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:install_plugin/install_plugin.dart';

// class UpdateHelper {
//   static Future<void> checkForUpdates(BuildContext context) async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     String currentVersion = packageInfo.version;

//     final Uri url = ApiHelper.checkUpdateApi(currentVersion);
//     try {
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data != null &&
//             data.containsKey('latestVersion') &&
//             data.containsKey('apkFileData')) {
//           String latestVersion = data['latestVersion'];
//           String apkFileData = data['apkFileData'];

//           if (currentVersion != latestVersion) {
//             _showUpdateDialog(context, latestVersion, apkFileData);
//           }
//         }
//       }
//     } catch (e) {
//       print("Error checking updates: $e");
//     }
//   }

//   static void _showUpdateDialog(
//       BuildContext context, String latestVersion, String apkFileData) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: const Text("Update Available"),
//         content: Text(
//             "A new version ($latestVersion) is available. Please update the app."),
//         actions: [
//           TextButton(
//             child: const Text("Update Now"),
//             onPressed: () async {
//               Navigator.of(context).pop();
//               await _downloadAndInstallApk(apkFileData);
//             },
//           ),
//         ],
//       ),
//     );
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


class UpdateHelper {
  static Future<bool> checkForUpdates(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    final Uri url = ApiHelper.checkUpdateApi(currentVersion);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null &&
            data.containsKey('latestVersion') &&
            data.containsKey('apkFileData')) {
          String latestVersion = data['latestVersion'];
          String apkFileData = data['apkFileData'];

          if (currentVersion != latestVersion) {
            // 👇 show update dialog
            _showUpdateDialog(context, latestVersion, apkFileData);
            return true; // update found
          }
        }
      }
    } catch (e) {
      print("Error checking updates: $e");
    }

    return false; // no update
  }

  static void _showUpdateDialog(
      BuildContext context, String latestVersion, String apkFileData) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Update Available"),
          content: Text(
              "A new version ($latestVersion) is available. Please update the app."),
          actions: [
            TextButton(
              child: const Text("Update Now"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _downloadAndInstallApk(apkFileData);
              },
            ),
          ],
        ),
      );
    });
  }

  static Future<void> _downloadAndInstallApk(String apkFileData) async {
    try {
      final bytes = base64Decode(apkFileData);
      final directory = await getExternalStorageDirectory();
      if (directory == null) throw Exception("Storage dir null");

      final filePath = "${directory.path}/update.apk";
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await InstallPlugin.installApk(filePath,
          appId: 'com.example.animated_movies_app');
    } catch (e) {
      print("Install failed: $e");
    }
  }
}
