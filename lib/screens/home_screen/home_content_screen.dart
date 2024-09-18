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





import 'dart:convert';
import 'dart:io';

import 'package:animated_movies_app/constants/route_animation.dart';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/data/movies_data.dart';
import 'package:animated_movies_app/screens/detail_screen/detail_screen.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/animated_stack.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/filters_widget.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/header_widget.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/movies_cover_widget.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/search_field_widget.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeContent extends StatefulWidget {
  final LoginModelApi userData;

  const HomeContent({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {

  @override
  void initState() {
    super.initState();
    // checkForUpdates(); // Call update check on initialization
  }

  //   Future<void> checkForUpdates() async {
  //   // Get package info for the current app version
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   String currentVersion = packageInfo.version;

  //   // API endpoint to check for updates
  //   final url = Uri.parse(
  //       'http://10.3.0.70:9042/api/HR/check-update?appVersion=$currentVersion');
  //   print('$url');
  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     print('API Response: $data'); // To debug and see the full response

  //     if (data != null && data.containsKey('latestVersion')) {
  //       String latestVersion = data['latestVersion'];

  //       // Compare the current app version with the latest version from the server
  //       if (currentVersion != latestVersion) {
  //         // Show dialog if update is available
  //         _showUpdateDialog(latestVersion);
  //       } else {
  //         // Show dialog if app is up-to-date
  //         _showNoUpdateDialog();
  //       }
  //     } else {
  //       print('Invalid response: latestVersion key not found.');
  //     }
  //   } else {
  //     print('Failed to check for updates');
  //   }
  // }

  // void _showUpdateDialog(String latestVersion) {
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
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //               // Open the app store link here, for example.
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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

   Future<void> checkForUpdates() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    final url = Uri.parse('http://10.3.0.70:9042/api/HR/check-update?appVersion=$currentVersion');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null && data.containsKey('latestVersion') && data.containsKey('apkFileData')) {
        String latestVersion = data['latestVersion'];
        String apkFileData = data['apkFileData']; // Base64 encoded APK file data

        if (currentVersion != latestVersion) {
          _showUpdateDialog(latestVersion, apkFileData);
        } else {
          _showNoUpdateDialog();
        }
      } else {
        print('Invalid response: latestVersion or apkFileData key not found.');
      }
    } else {
      print('Failed to check for updates');
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

  void _showNoUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No Update Available"),
          content: Text("Your app is up-to-date!"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Future<void> _downloadAndInstallApk(String apkFileData) async {
  //   try {
  //     // Decode Base64 APK data
  //     final apkBytes = base64Decode(apkFileData);

  //     // Get temporary directory
  //     final directory = await getTemporaryDirectory();
  //     final path = '${directory.path}/update.apk';

  //     // Save the APK file
  //     final file = File(path);
  //     await file.writeAsBytes(apkBytes);

  //     // Trigger APK installation
  //     await _installApk(path);
  //   } catch (e) {
  //     print('Error downloading or installing APK: $e');
  //   }
  // }

  // Future<void> _installApk(String path) async {
  //   final file = File(path);

  //   if (await file.exists()) {
  //     // Launch APK installation
  //     final uri = Uri.file(path);
  //     await launch(uri.toString(), forceSafariVC: false);
  //   } else {
  //     print('APK file not found at $path');
  //   }
  // }


Future<void> _downloadAndInstallApk(String apkFileData) async {
  try {
    // Step 1: Request storage permission
    if (await Permission.storage.request().isGranted) {
      // Step 2: Decode the base64 string to binary
      List<int> apkBytes = base64Decode(apkFileData);

      // Step 3: Get the application's cache directory
      Directory cacheDir = await getTemporaryDirectory();

      // Step 4: Create an APK file in the cache directory
      File apkFile = File('${cacheDir.path}/update.apk');
      await apkFile.writeAsBytes(apkBytes);

      // Step 5: Use FileProvider or a direct method to install the APK
      await _installApk(apkFile.path);
    } else {
      print("Storage permission denied");
    }
  } catch (e) {
    print("Error downloading or installing APK: $e");
  }
}

Future<void> _installApk(String apkFilePath) async {
  try {
    final platform = MethodChannel('com.example.animated_movies_app/install_apk');
    final apkUri = await platform.invokeMethod('getApkUri', {'apkPath': apkFilePath});

    // Call the platform method to install the APK
    await platform.invokeMethod('installApk', {'apkUri': apkUri});
  } catch (e) {
    print("Error installing APK: $e");
  }
}

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
                  Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: SearchField(size: size),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: FiltersWidget(userData: widget.userData),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32, top: 14),
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
                                movieTypeAndEpisode: MoviesData.movies[index].movieTypeAndEpisode,
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
          ],
        ),
      ),
    );
  }
}
