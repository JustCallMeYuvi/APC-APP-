// import 'package:animated_movies_app/constants/route_animation.dart';
// import 'package:animated_movies_app/constants/ui_constant.dart';
// import 'package:animated_movies_app/data/movies_data.dart';
// import 'package:animated_movies_app/screens/detail_screen/detail_screen.dart';
// import 'package:animated_movies_app/screens/home_screen/widgets/animated_stack.dart';
// import 'package:animated_movies_app/screens/home_screen/widgets/filters_widget.dart';
// import 'package:animated_movies_app/screens/home_screen/widgets/header_widget.dart';
// import 'package:animated_movies_app/screens/home_screen/widgets/movies_cover_widget.dart';
// import 'package:animated_movies_app/screens/home_screen/widgets/search_field_widget.dart';
// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
// import 'package:flutter/material.dart';

// class HomeContent extends StatefulWidget {
//   final LoginModelApi userData;
//   const HomeContent({super.key, required this.userData});

//   @override
//   State<HomeContent> createState() => _HomeContentState();
// }

// class _HomeContentState extends State<HomeContent> {
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.sizeOf(context);
//     return Container(
//       height: size.height,
//       width: size.width,
//       decoration: UiConstants.backgroundGradient,
//       child: SingleChildScrollView(
//         child: Stack(
//           children: [
//             SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.only(
//                       top: size.height * 0.09,
//                       left: 24,
//                       right: 24,
//                     ),
//                     // child: HeaderWidget(size: size, userData: null,),
//                     child: HeaderWidget(
//                       size: size,
//                       userData: widget.userData,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       top: 28,
//                     ),
//                     child: SearchField(
//                       size: size,
//                     ),
//                   ),
//                   const Padding(
//                     padding: EdgeInsets.only(top: 20),
//                     child: FiltersWidget(),
//                   ),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 32, top: 14),
//                       child: RichText(
//                         text: const TextSpan(
//                           text: "Apache ",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 24,
//                             color: Colors.white,
//                           ),
//                           children: [
//                             TextSpan(
//                               text: "Teams",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.normal,
//                                 fontSize: 24,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: size.height * 0.4,
//                     padding: const EdgeInsets.all(38),
//                     child: AnimatedStackWidget(
//                       itemCount: MoviesData.movies.length,
//                       itemBuilder: (context, index) => GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).push(
//                             zoomNavigation(
//                               DetailScreen(
//                                 movieName: MoviesData.movies[index].name,
//                                 movieTypeAndEpisode: MoviesData
//                                     .movies[index].movieTypeAndEpisode,
//                                 plot: MoviesData.movies[index].plot,
//                                 movieImage: MoviesData.movies[index].coverImage,
//                                 rating: MoviesData.movies[index].rating,
//                               ),
//                             ),
//                           );
//                         },
//                         child: MagazineCoverImage(
//                             movies: MoviesData.movies[index]),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Positioned(
//             //   top: size.height * 0.04,
//             //   left: 16,
//             //   child: IconButton(
//             //     icon: Icon(Icons.arrow_back, color: Colors.white),
//             //     onPressed: () {
//             //       Navigator.pop(context);
//             //     },
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/constants/route_animation.dart';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/data/movies_data.dart';
import 'package:animated_movies_app/screens/detail_screen/detail_screen.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/animated_stack.dart';

import 'package:animated_movies_app/screens/home_screen/widgets/header_widget.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/movies_cover_widget.dart';

import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeContent extends StatefulWidget {
  final LoginModelApi userData;

  const HomeContent({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isLoading = false;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  @override
  void initState() {
    super.initState();
    // checkForUpdates(); // Call update check on initialization

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      // developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  // Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
  //   setState(() {
  //     _connectionStatus = result;
  //   });
  //   // ignore: avoid_print
  //   print('Connectivity changed: $_connectionStatus');
  //   // Show a Snackbar with the connection status
  //   String message;
  //   Color backgroundColor;
  //   // if (_connectionStatus ==ConnectivityResult.none) {
  //   //   message = 'No internet connection';
  //   //   backgroundColor = Colors.red;
  //   // } else {
  //   //   message = 'Connected: ${_connectionStatus.toString()}';
  //   //   backgroundColor = Colors.green;
  //   // }

  //   if (_connectionStatus.contains(ConnectivityResult.none)) {
  //     message = 'No internet connection';
  //     backgroundColor = Colors.red;
  //   } else if (_connectionStatus.contains(ConnectivityResult.wifi)) {
  //     message = 'Connected to Wi-Fi';
  //     backgroundColor = Colors.green;
  //   } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
  //     message = 'Connected to Mobile Network';
  //     backgroundColor = Colors.green;
  //   } else {
  //     message = 'Connected to another network type';
  //     backgroundColor = Colors.blue;
  //   }
  //   // Show the Snackbar
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: backgroundColor,
  //       duration: Duration(seconds: 3), // Adjust duration as needed
  //     ),
  //   );
  // }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });

    print('Connectivity changed: $_connectionStatus');

    String message;
    Color backgroundColor;
    String? wifiIpAddress;
    String? gmsUrlToShow;
    String? urlType; // Local or Public

    if (_connectionStatus.contains(ConnectivityResult.none)) {
      message = 'No internet connection';
      backgroundColor = Colors.red;
    } else if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      message = 'Connected to Wi-Fi';
      backgroundColor = Colors.green;
      if (await _requestLocationPermissionforWifiIP()) {
        wifiIpAddress = await _getWifiIPAddress();
        print('Wi-Fi IP Address: $wifiIpAddress'); // Print the IP address
      } else {
        print("Location permission denied.");
      }

      // Enable the function below when updating the app for live, as it determines whether to use local or global APIs based on Wi-Fi or mobile networks.
      // await ApiHelper.updateUrlsBasedOnNetwork(); // for wifi apache and apc IT
      gmsUrlToShow =
          ApiHelper.urlGlobalOrLocalCheck; // Fetch GMS URL after update
      // 👉 Check if it’s local or public
      // if (gmsUrlToShow != null && gmsUrlToShow.contains("10.3.")) {
      //   urlType = "Local URL";
      // } else {
      //   urlType = "Public URL";
      // }
      if (gmsUrlToShow.contains('10.3.')) {
        urlType = 'Local URL';
      } else {
        urlType = 'Public URL';
      }

      // 🟢 Now, build the message string with the updated URL
      message += ' (URL: $gmsUrlToShow\nURLType: $urlType';
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      message = 'Connected to Mobile Network';
      backgroundColor = Colors.green;
    } else {
      message = 'Connected to another network type';
      backgroundColor = Colors.blue;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

// Future<String?> _getWifiIPAddress() async {
//   try {
//     for (var interface in await NetworkInterface.list()) {
//       if (interface.name == 'wlan0' || interface.name == 'en0') {
//         // 'wlan0' for Android, 'en0' for iOS/macOS
//         for (var addr in interface.addresses) {
//           if (addr.type == InternetAddressType.IPv4) {
//             return addr.address; // Return the IPv4 address
//           }
//         }
//       }
//     }
//   } catch (e) {
//     print('Error getting IP address: $e');
//   }
//   return null;
// }

  Future<bool> _requestLocationPermissionforWifiIP() async {
    PermissionStatus status = await Permission.location.request();
    print("Location permission status: $status");
    return status.isGranted;
  }

  Future<String?> _getWifiIPAddress() async {
    try {
      final info = NetworkInfo();
      String? wifiIp = await info.getWifiIP();
      return wifiIp;
    } catch (e) {
      print('Error getting Wi-Fi IP address: $e');
      return null;
    }
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

  // void _showUpdateDialog(String latestVersion, String apkFileData) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Update Available"),
  //         content: Text(
  //             "A new version ($latestVersion) is available. Please update the app."),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text("Later"),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //           ),
  //           TextButton(
  //             child: Text("Update Now"),
  //             onPressed: () async {
  //               Navigator.of(context).pop(); // Close the dialog

  //               try {
  //                 // Start downloading the APK file
  //                 await _downloadAndInstallApk(apkFileData);
  //               } catch (e) {
  //                 print('Failed to download or install APK: $e');
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
    final size = MediaQuery.sizeOf(context);
    return Container(
      height: size.height,
      width: size.width,
      decoration: UiConstants.backgroundGradient,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            // _isLoading // Show loading indicator if loading
            //     ? Center(
            //         child: CircularProgressIndicator(),
            //       )
            //     :
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: size.height * 0.09,
                      left: 24,
                      right: 24,
                    ),
                    child: HeaderWidget(
                      size: size,
                      userData: widget.userData,
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 28),
                  //   child: SearchField(size: size),
                  // ),

                  // this is our products in apache filter buttons
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 50),
                  //   child: FiltersWidget(userData: widget.userData),
                  // ),
                  SizedBox(
                    height: 150,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32, top: 30),
                      child: RichText(
                        text: const TextSpan(
                          text: "Apache ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              text: "Teams",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // _isLoading // Show loading indicator if loading
                  //     ? Center(
                  //         child: CircularProgressIndicator(),
                  //       )
                  //     :
                  Container(
                    height: size.height * 0.4,
                    padding: const EdgeInsets.all(38),
                    child: AnimatedStackWidget(
                      itemCount: MoviesData.movies.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            zoomNavigation(
                              DetailScreen(
                                movieName: MoviesData.movies[index].name,
                                movieTypeAndEpisode: MoviesData
                                    .movies[index].movieTypeAndEpisode,
                                plot: MoviesData.movies[index].plot,
                                movieImage: MoviesData.movies[index].coverImage,
                                rating: MoviesData.movies[index].rating,
                              ),
                            ),
                          );
                        },
                        child: MagazineCoverImage(
                            movies: MoviesData.movies[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Center the loading indicator over the content
            // if (_isLoading) // Show loading indicator if loading
            //   Center(
            //     child: CircularProgressIndicator(),
            //   ),
          ],
        ),
      ),
    );
  }
}
