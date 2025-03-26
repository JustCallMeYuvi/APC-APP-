// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:animated_movies_app/api/apis_page.dart';
// import 'package:animated_movies_app/screens/gms_screens/custom_video_player_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';
// import 'dart:typed_data';

// class GmsFilesPage extends StatefulWidget {
//   final String vehicleId;

//   const GmsFilesPage({Key? key, required this.vehicleId}) : super(key: key);

//   @override
//   _GmsFilesPageState createState() => _GmsFilesPageState();
// }

// class _GmsFilesPageState extends State<GmsFilesPage> {
//   Future<List<Map<String, dynamic>>>? _fetchData;
//   late VideoPlayerController _videoController;
//   bool _isVideoInitialized = false;
//   int?
//       _currentlyPlayingVideoIndex; // To track the index of the currently playing video

//   @override
//   void initState() {
//     super.initState();
//     // Fetch data when the page loads
//     _fetchData = fetchGmsFiles(widget.vehicleId);
//     if (_isVideoInitialized) {
//       _videoController.dispose();
//     }
//   }

// // @override
// // void dispose() {
// //   if (_videoController.value.isInitialized) {
// //     _videoController.dispose();
// //   }
// //   super.dispose();
// // }
//   // Fetch files from the API
//   Future<List<Map<String, dynamic>>> fetchGmsFiles(String vehicleId) async {
//     try {
//       // Construct the URL
//       final url = '${ApiHelper.gmsUrl}GMS_SignOff?TRACKINGID=$vehicleId';
//       // final url =
//       //     'http://10.3.0.208:8084/api/GMS/GMS_SignOff?TRACKINGID=$vehicleId';

//       // Print the URL to the console
//       print("Requesting URL: $url");
//       // final response = await http.get(
//       //   Uri.parse(
//       //       'http://10.3.0.208:8084/api/GMS/GMS_SignOff?TRACKINGID=$vehicleId'),
//       // );
//       // Make the API request
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final dynamic responseData = json.decode(response.body);

//         // Print the response data
//         print("Response Data: $responseData");

//         // If the responseData is a list, directly return it
//         if (responseData is List) {
//           return List<Map<String, dynamic>>.from(responseData);
//         } else {
//           // Handle error or structure mismatch
//           throw Exception('Unexpected response structure');
//         }
//       } else {
//         print("Error response: ${response.body}");
//         throw Exception('Failed to load files');
//       }
//     } catch (e) {
//       print("Error: $e");
//       // Handle the error here
//     }
//     return []; // Return empty list if no data or error
//   }

// // Decode base64 string and convert it to Image widget
//   // Widget _getImageorVideoFromBase64(String base64String) {
//   //   try {
//   //     // Check if the string is a valid base64 string
//   //     if (base64String.isEmpty) {
//   //       return const Text("No image data");
//   //     }

//   //     // Try decoding the base64 string
//   //     var decodedBytes = base64Decode(base64String);

//   //     // If decoding is successful, display the image
//   //     return Image.memory(Uint8List.fromList(decodedBytes));
//   //   } catch (e) {
//   //     // Handle decoding failure
//   //     return const Icon(Icons.error, color: Colors.red);
//   //   }
//   // }

//   Widget _getImageorVideoFromBase64(
//       String fileContent, String fileType, int index) {
//     if (fileType.toLowerCase() == 'mp4') {
//       // If it's an MP4 file, we handle it as a video
//       return GestureDetector(
//         onTap: () async {
//           // Decode the base64 string and save it as a temporary file
//           Uint8List videoBytes = base64Decode(fileContent);
//           Directory tempDir = await getTemporaryDirectory();
//           String tempPath = '${tempDir.path}/temp_video_$index.mp4';
//           File tempFile = File(tempPath);
//           await tempFile.writeAsBytes(videoBytes);

//           // Initialize the VideoPlayerController with the temporary file
//           setState(() {
//             if (_currentlyPlayingVideoIndex == index) {
//               if (_videoController.value.isPlaying) {
//                 _videoController.pause();
//               } else {
//                 _videoController.play();
//               }
//             } else {
//               if (_isVideoInitialized) {
//                 _videoController.dispose();
//               }
//               _currentlyPlayingVideoIndex = index;
//               _videoController = VideoPlayerController.file(tempFile)
//                 ..initialize().then((_) {
//                   setState(() {
//                     _isVideoInitialized = true;
//                     _videoController.play();
//                   });
//                 });
//             }
//           });
//         },
//         child: Stack(alignment: Alignment.center, children: [
//           // Display the video
//           _isVideoInitialized && _currentlyPlayingVideoIndex == index
//               ? AspectRatio(
//                   aspectRatio: _videoController.value.aspectRatio,
//                   child: VideoPlayer(_videoController),
//                 )
//               : const Icon(Icons.play_circle_outline, size: 50),
//           // Display Play/Pause button over the video
//           if (_isVideoInitialized && _currentlyPlayingVideoIndex == index)
//             Positioned(
//               child: IconButton(
//                 icon: Icon(
//                   _videoController.value.isPlaying
//                       ? Icons.pause_circle_filled
//                       : Icons.play_circle_filled,
//                   size: 50,
//                   color: Colors.white,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     if (_videoController.value.isPlaying) {
//                       _videoController.pause();
//                     } else {
//                       _videoController.play();
//                     }
//                   });
//                 },
//               ),
//             ),
//         ]),
//       );
//     } else {
//       // If it's not a video, display the image
//       return Image.memory(base64Decode(fileContent)); // Display as an image
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("GMS Files Page"),
//         backgroundColor: Colors.greenAccent,
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _fetchData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No files available"));
//           } else {
//             // final files = snapshot.data!;
//             final data = snapshot.data!;
//             return ListView.builder(
//               // itemCount: files.length,
//               itemCount: data.length,
//               itemBuilder: (context, index) {
//                 // final file = files[index];
//                 final gate = data[index];
//                 final title = gate['title'] ?? 'Unknown Title';
//                 final time = gate['time'] ?? 'Unknown Time';
//                 final files = gate['files'] as List;

//                 return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 8.0),
//                     elevation: 4,
//                     child: ExpansionTile(
//                         title: Text(
//                           title,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         subtitle: Text("Time: $time"),
//                         // minTileHeight: 200.0, // Custom minimum height
//                         children: [
//                           files.isEmpty
//                               ? const Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Text("No files available"),
//                                 )
//                               : SizedBox(
//                                   height: 400,
//                                   child: ListView.builder(
//                                     scrollDirection: Axis.horizontal,
//                                     itemCount: files.length,
//                                     itemBuilder: (context, fileIndex) {
//                                       final file = files[fileIndex];
//                                       final fileName =
//                                           file['fileName'] ?? 'Unnamed';
//                                       final fileContent =
//                                           file['fileContent'] ?? '';
//                                       final fileType = file['fileType'] ?? '';
//                                       final uploadDate =
//                                           file['uploadDate'] ?? 'Unknown Date';
//                                       final fgLocation = file['fgLocation'] ??
//                                           'Unknown Location';

//                                       return Container(
//                                         width: 250,
//                                         margin: const EdgeInsets.symmetric(
//                                             horizontal: 8.0),
//                                         padding: const EdgeInsets.all(8.0),
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey[200],
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             fileContent.isNotEmpty
//                                                 ? Expanded(
//                                                     child:
//                                                         _getImageorVideoFromBase64(
//                                                             fileContent,
//                                                             fileType,
//                                                             index),
//                                                   )
//                                                 : const Icon(
//                                                     Icons.insert_drive_file,
//                                                     size: 50),
//                                             const SizedBox(height: 8),
//                                             Text(
//                                               " $fileName",
//                                               textAlign: TextAlign.center,
//                                               style:
//                                                   const TextStyle(fontSize: 14),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Text(
//                                               "$uploadDate",
//                                               textAlign: TextAlign.center,
//                                               style: const TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             if (fgLocation != null &&
//                                                 fgLocation
//                                                     .isNotEmpty) // Check if fgLocation has dat
//                                               Text(
//                                                 "Location: $fgLocation",
//                                                 textAlign: TextAlign.center,
//                                                 style: const TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black),
//                                               ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 )
//                         ]));
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// here below to play individually videos

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class GmsFilesPage extends StatefulWidget {
  final String vehicleId;

  const GmsFilesPage({Key? key, required this.vehicleId}) : super(key: key);

  @override
  _GmsFilesPageState createState() => _GmsFilesPageState();
}

class _GmsFilesPageState extends State<GmsFilesPage> {
  bool _isLoadingFetchDetails = false;
  Future<List<Map<String, dynamic>>>? _fetchData;
  late Map<int, VideoPlayerController>
      _videoControllers; // Store controllers for each video
  int? _currentlyPlayingVideoIndex; // Track which video is currently playing

  @override
  void initState() {
    super.initState();
    _fetchData = fetchGmsFiles(widget.vehicleId);
    _videoControllers = {}; // Initialize the map to hold video controllers
  }

  @override
  void dispose() {
    // Dispose of all video controllers when the page is disposed
    _videoControllers.forEach((_, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  // Fetch files from the API
  Future<List<Map<String, dynamic>>> fetchGmsFiles(String vehicleId) async {
    setState(() {
      _isLoadingFetchDetails =
          true; // Show the loading indicator when starting the API call
    });
    try {
      final url = '${ApiHelper.gmsUrl}GMS_SignOff?TRACKINGID=$vehicleId';
      final response = await http.get(Uri.parse(url));
      print(url);
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        } else {
          throw Exception('Unexpected response structure');
        }
      } else {
        throw Exception('Failed to load files');
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoadingFetchDetails =
            false; // Hide the loading indicator after the API call is done
      });
    }
    return [];
  }

  // Decode base64 string and convert it to Image or Video widget
  Widget _getImageorVideoFromBase64(
      String fileContent, String fileType, int index) {
    if (fileType.toLowerCase() == 'mp4') {
      // Handle MP4 videos
      return GestureDetector(
        onTap: () async {
          // Decode the base64 string and save it as a temporary file
          Uint8List videoBytes = base64Decode(fileContent);
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = '${tempDir.path}/temp_video_$index.mp4';
          File tempFile = File(tempPath);
          await tempFile.writeAsBytes(videoBytes);

          // Initialize the VideoPlayerController for this specific video
          setState(() {
            if (_currentlyPlayingVideoIndex != index) {
              // Dispose of the previous video controller if necessary
              if (_currentlyPlayingVideoIndex != null) {
                _videoControllers[_currentlyPlayingVideoIndex!]?.pause();
              }
              _currentlyPlayingVideoIndex = index;

              // Check if controller exists for the current video, otherwise initialize it
              if (!_videoControllers.containsKey(index)) {
                _videoControllers[index] = VideoPlayerController.file(tempFile)
                  ..initialize().then((_) {
                    setState(() {
                      _videoControllers[index]!.play();
                    });
                  });
              } else {
                _videoControllers[index]!.play();
              }
            } else {
              // Pause the video if it's already playing
              if (_videoControllers[index]!.value.isPlaying) {
                _videoControllers[index]!.pause();
              } else {
                _videoControllers[index]!.play();
              }
            }
          });
        },
        child: Stack(alignment: Alignment.center, children: [
          // Display video or play icon
          _videoControllers.containsKey(index) &&
                  _videoControllers[index]!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoControllers[index]!.value.aspectRatio,
                  child: VideoPlayer(_videoControllers[index]!),
                )
              : const Icon(Icons.play_circle_outline, size: 50),
          // Play/Pause button overlay
          if (_videoControllers.containsKey(index) &&
              _videoControllers[index]!.value.isInitialized)
            Positioned(
              child: IconButton(
                icon: Icon(
                  _videoControllers[index]!.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 50,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (_videoControllers[index]!.value.isPlaying) {
                      _videoControllers[index]!.pause();
                    } else {
                      _videoControllers[index]!.play();
                    }
                  });
                },
              ),
            ),
        ]),
      );
    } else {
      // Handle image content (non-video files)
      return Image.memory(base64Decode(fileContent));
    }
  }

// below code is when user tap long press in image it will be download

//   Widget _getImageorVideoFromBase64(
//     String fileContent, String fileType, int index) {
//   Uint8List fileBytes = base64Decode(fileContent);

//   Future<void> _downloadFile() async {
//     try {
//       final result = await Permission.storage.request();
//       if (result.isGranted) {
//         final directory = await getExternalStorageDirectory();
//         final downloadsPath = directory!.path;

//         String fileName =
//             fileType.toLowerCase() == 'mp4' ? 'video_$index.mp4' : 'image_$index.png';

//         final filePath = '$downloadsPath/$fileName';
//         final file = File(filePath);
//         await file.writeAsBytes(fileBytes);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('File saved to $filePath')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Permission denied')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving file: $e')),
//       );
//     }
//   }

//   if (fileType.toLowerCase() == 'mp4') {
//     // Handle MP4 videos
//     return GestureDetector(
//       onTap: () async {
//         Uint8List videoBytes = fileBytes;
//         Directory tempDir = await getTemporaryDirectory();
//         String tempPath = '${tempDir.path}/temp_video_$index.mp4';
//         File tempFile = File(tempPath);
//         await tempFile.writeAsBytes(videoBytes);

//         setState(() {
//           if (_currentlyPlayingVideoIndex != index) {
//             if (_currentlyPlayingVideoIndex != null) {
//               _videoControllers[_currentlyPlayingVideoIndex!]?.pause();
//             }
//             _currentlyPlayingVideoIndex = index;

//             if (!_videoControllers.containsKey(index)) {
//               _videoControllers[index] = VideoPlayerController.file(tempFile)
//                 ..initialize().then((_) {
//                   setState(() {
//                     _videoControllers[index]!.play();
//                   });
//                 });
//             } else {
//               _videoControllers[index]!.play();
//             }
//           } else {
//             if (_videoControllers[index]!.value.isPlaying) {
//               _videoControllers[index]!.pause();
//             } else {
//               _videoControllers[index]!.play();
//             }
//           }
//         });
//       },
//       onLongPress: _downloadFile,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           _videoControllers.containsKey(index) &&
//                   _videoControllers[index]!.value.isInitialized
//               ? AspectRatio(
//                   aspectRatio: _videoControllers[index]!.value.aspectRatio,
//                   child: VideoPlayer(_videoControllers[index]!),
//                 )
//               : const Icon(Icons.play_circle_outline, size: 50),
//           if (_videoControllers.containsKey(index) &&
//               _videoControllers[index]!.value.isInitialized)
//             Positioned(
//               child: IconButton(
//                 icon: Icon(
//                   _videoControllers[index]!.value.isPlaying
//                       ? Icons.pause_circle_filled
//                       : Icons.play_circle_filled,
//                   size: 50,
//                   color: Colors.white,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     if (_videoControllers[index]!.value.isPlaying) {
//                       _videoControllers[index]!.pause();
//                     } else {
//                       _videoControllers[index]!.play();
//                     }
//                   });
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   } else {
//     // Handle images
//     return GestureDetector(
//       onLongPress: _downloadFile,
//       child: Image.memory(fileBytes),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GMS Files Page"),
        backgroundColor: Colors.greenAccent,
      ),
      body:
          // _isLoadingFetchDetails? CircularProgressIndicator() // Show the loading indicator
          //     :
          FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No files available"));
          } else {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final gate = data[index];
                final title = gate['title'] ?? 'Unknown Title';
                // final files = gate['files'] as List;
                final files = gate['files'];
                if (files is! List) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    // child: Text("Invalid files format"),
                  );
                }
                // final files = gate['files'];

                // // Validate files field
                // if (files is! List) {
                //   return Center(child: Text("Invalid files format for $title"));
                // }
                final time = gate['time'] ?? 'Unknown Time';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  child: ExpansionTile(
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text("Time: $time"),
                    children: [
                      files.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("No files available"),
                            )
                          : SizedBox(
                              height: 400,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: files.length,
                                itemBuilder: (context, fileIndex) {
                                  final file = files[fileIndex];
                                  final fileContent = file['fileContent'] ?? '';
                                  final fileType = file['fileType'] ?? '';
                                  final uploadDate =
                                      file['uploadDate'] ?? 'Unknown Date';
                                  final uploadedBy = file['uploadedBy'] ?? '';
                                  final fgLocation =
                                      file['fgLocation'] ?? 'Unknown Location';

                                  return Container(
                                    width: 250,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        fileContent.isNotEmpty
                                            ? Expanded(
                                                child:
                                                    _getImageorVideoFromBase64(
                                                        fileContent,
                                                        fileType,
                                                        fileIndex),
                                              )
                                            : const Icon(
                                                Icons.insert_drive_file,
                                                size: 50),
                                        const SizedBox(height: 8),
                                        // Text(
                                        //   file['fileName'] ?? 'Unnamed',
                                        //   textAlign: TextAlign.center,
                                        //   style: const TextStyle(fontSize: 14),
                                        // ),

                                        // Visibility(
                                        //   visible: uploadedBy !=
                                        //       "0", // Hide when uploadedBy is "0"
                                        //   child: Text(
                                        //     "Uploaded By: $uploadedBy",
                                        //     textAlign: TextAlign.center,
                                        //     style: const TextStyle(
                                        //       fontSize: 14,
                                        //       fontWeight: FontWeight.bold,
                                        //     ),
                                        //   ),
                                        // ),

                                        uploadedBy != "0"
                                            ? Text(
                                                "Uploaded By: $uploadedBy",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : const SizedBox
                                                .shrink(), // Returns an empty widget if uploadedBy is "0"
                                        Text(
                                          "Uploaded Date: $uploadDate",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),

                                        const SizedBox(height: 4),
                                        if (fgLocation != null &&
                                            fgLocation
                                                .isNotEmpty) // Check if fgLocation has dat
                                          Text(
                                            "Location: $fgLocation",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
