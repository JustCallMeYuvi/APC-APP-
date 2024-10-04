import 'dart:convert';
import 'dart:io';

import 'package:animated_movies_app/screens/home_screen/about_screen.dart';
import 'package:animated_movies_app/screens/home_screen/account_screen.dart';

import 'package:animated_movies_app/screens/home_screen/contacts_screen.dart';
import 'package:animated_movies_app/screens/home_screen/home_content_screen.dart';
import 'package:animated_movies_app/screens/home_screen/multiple_forms.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/bottom_nav_bar.dart';

import 'package:animated_movies_app/screens/home_screen/widgets/notification.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final LoginModelApi userData; // Add this line
  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final NotificationService _notificationService = NotificationService();
  int _selectedIndex = 0;
  bool _isLoading = false;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // _notificationService.initNotification((payload) {
    //   _onItemTapped(1); // Navigate to notifications screen
    // });
    checkForUpdates(); // Call update check on initialization
    _widgetOptions = <Widget>[
      HomeContent(
        userData: widget.userData,
      ),

      NotificationsScreen(
        userData: widget.userData,
      ),
      // ChatScreen(),
      ContactsPage(
        userData: widget.userData,
      ),
      MultipleForms(
        userData: widget.userData,
      ),
      AboutScreen(),
      AccountDetailsScreen(userData: widget.userData), // Pass userData here
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> checkForUpdates() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    final url = Uri.parse(
        'http://10.3.0.70:9042/api/HR/check-update?appVersion=$currentVersion');

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
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update Available"),
          content: Text(
              "A new version ($latestVersion) is available. Please update the app."),
          actions: <Widget>[
            TextButton(
              child: Text("Later"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
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

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Restart Required"),
          content: Text("The app needs to be restarted to apply the updates."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                // Restart the app (this could also be done by closing the app)
                SystemNavigator.pop(); // or use your method to restart the app
              },
            ),
          ],
        );
      },
    );
  }

  // void _showNoUpdateDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("No Update Available"),
  //         content: Text("Your app is up-to-date!"),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text("OK"),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading // Show loading indicator if loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : IndexedStack(
              index: _selectedIndex,
              children: _widgetOptions,
            ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        // notificationService: _notificationService,
        userData: widget.userData,
      ),
    );
  }
}
