import 'dart:io';
import 'dart:typed_data';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/screens/home_screen/file_preview_view.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class ChatScreen extends StatefulWidget {
  final String contactName;
  final int senderId;
  final int receiverId;

  const ChatScreen({
    Key? key,
    required this.contactName,
    required this.senderId,
    required this.receiverId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  late IOWebSocketChannel _channel;
  List<bool> buttonVisibility = [
    true,
    true,
    true
  ]; // Track visibility of buttons

  @override
  void initState() {
    super.initState();
    fetchMessages();
// fetchReceiveMessages();
    // longPolling(); // Start long polling for new messages
    // _initializeWebSocket();
  }

  // void _initializeWebSocket() {
  //   _channel = IOWebSocketChannel.connect(
  //       'ws://10.3.0.70:9040/api/Flutter/GetWebSocket');

  //   _channel.stream.listen((message) {
  //     print('New message: $message');
  //     final newMessage = ChatMessage.fromJson(jsonDecode(message));
  //     setState(() {
  //       _messages.insert(0, newMessage);
  //     });
  //   }, onError: (error) {
  //     print('WebSocket error: $error');
  //   }, onDone: () {
  //     print('WebSocket closed');
  //   });
  // }
  void _initializeWebSocket() {
    _channel = IOWebSocketChannel.connect(
        'ws://10.3.0.70:9040/api/Flutter/GetWebSocket');

    _channel.stream.listen((message) {
      print('New message: $message');
      final newMessage = ChatMessage.fromJson(jsonDecode(message));
      setState(() {
        _messages.insert(0, newMessage);
      });
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket closed');
    });
  }

  Future<void> fetchMessages() async {
    try {
      final String url =
          'http://10.3.0.70:9040/api/Flutter/GetMessagesAsync?senderId=${widget.senderId}&receiverId=${widget.receiverId}';
      final response = await http.get(Uri.parse(url));

      print('Request URL: $url');
      // print('Response: ${response.body}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Check if response body is not null
        if (response.body != null) {
          List<dynamic> messagesJson = jsonDecode(response.body);

          setState(() {
            _messages.clear();
            _messages.addAll(messagesJson
                .map((message) => ChatMessage.fromJson(message))
                .toList());
            // print(_messages);
            // _messages.forEach((element) {
            //   Uint8List? _bytesImages =
            //       Base64Decoder().convert(element.fileBytesBase64);
            //   element.fileBytesBase64 = _bytesImages;
            // });
            // Update button visibility based on messages list

            if (_messages.isNotEmpty) {
              buttonVisibility = [false, false, false]; // Hide buttons
            } else {
              buttonVisibility = [true, true, true]; // Show buttons
            }
          });
        } else {
          print('Response body is null');
        }
      } else {
        print('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors
      print('Error fetching messages: $e');
    }
  }

  Future<void> _sendMessageOrFile(
      {String? text, File? file, String? fileExtension}) async {
    try {
      final String url = 'http://10.3.0.70:9040/api/Flutter/AddMessageAsync';
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['SenderId'] = widget.senderId.toString()
        ..fields['ReceiverId'] = widget.receiverId.toString()
        ..fields['MessageText'] =
            text ?? '' // Use provided text or empty string
        ..fields['IsUserMessage'] = 'true'
        ..fields['MessageTimestamp'] = DateTime.now().toIso8601String();

      String? fileType;
      String? fileBytesBase64;
      if (file != null) {
        final fileName = file.path.split('/').last;
        fileType = fileName.split('.').last.toLowerCase();

        // Read the file bytes and convert to Base64
        final Uint8List bytes = await file.readAsBytes();
        fileBytesBase64 = base64.encode(bytes);
        print('base 64 : ${fileBytesBase64}');

        request.fields['FileBytesBase64'] =
            fileBytesBase64; // Include Base64 in the request

        request.files.add(await http.MultipartFile.fromPath('file', file.path,
            filename: fileName));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print(file != null
            ? 'File sent successfully'
            : 'Message sent successfully');
        _controller.clear();

        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              messageId: _messages.length + 1,
              senderId: widget.senderId,
              receiverId: widget.receiverId,
              messageText: file != null
                  ? 'Sent a file: ${file.path.split('/').last}'
                  : text!,
              messageTimestamp: DateTime.now(),
              isUserMessage: true,
              isFile: file != null, // Set isFile
              fileType: fileType, // Set fileType
              fileUrl: file?.path,
              fileBytesBase64: fileBytesBase64 ?? '',
              format: '',
              // format: fileExtension,
              filename: '', // Store Base64 string
            ),
          );
          if (file != null) {
            buttonVisibility[0] = false; // Hide button after sending file
          }
        });
      } else {
        print(
            'Failed to send ${file != null ? 'file' : 'message'}: ${response.statusCode}');
        print('Response Body: $responseBody');
      }
    } catch (e) {
      print('Error sending ${file != null ? 'file' : 'message'}: $e');
    }
  }

  Future<void> _pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final PlatformFile file = result.files.first;
      final selectedFile = File(file.path!);

      // Call the unified method to handle file sending
      await _sendMessageOrFile(file: selectedFile);
    }
  }
  // Future<void> _pickAndSendFile() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: [
  //       'jpg', 'jpeg', 'png', // Image formats
  //       'mp4', 'avi', 'mov', // Video formats
  //       'pdf', 'doc', 'docx', // Document formats
  //       'xls', 'xlsx', // Excel formats
  //     ],
  //   );

  //   if (result != null) {
  //     final selectedFile = File(result.files.single.path!);
  //     await _sendMessageOrFile(
  //       file: selectedFile,
  //       fileExtension: result.files.single.extension ?? '',
  //     );
  //   }
  // }

//   Future<void> _sendMessageOrFile({String? text, File? file}) async {
//   try {
//     final String url = 'http://10.3.0.70:9040/api/Flutter/AddMessageAsync';
//     final request = http.MultipartRequest('POST', Uri.parse(url))
//       ..fields['SenderId'] = widget.senderId.toString()
//       ..fields['ReceiverId'] = widget.receiverId.toString()
//       ..fields['MessageText'] = text ?? '' // Use provided text or empty string
//       ..fields['IsUserMessage'] = 'true'
//       ..fields['MessageTimestamp'] = DateTime.now().toIso8601String();

//     String? fileType;
//     String? fileBytesBase64;
//     if (file != null) {
//       final fileName = file.path.split('/').last;
//       fileType = fileName.split('.').last.toLowerCase();

//       // Read the file bytes and convert to Base64
//       final Uint8List bytes = await file.readAsBytes();
//       fileBytesBase64 = base64.encode(bytes);
//       print('base64: $fileBytesBase64');

//       request.fields['FileBytesBase64'] = fileBytesBase64; // Include Base64 in the request

//       request.files.add(await http.MultipartFile.fromPath('file', file.path, filename: fileName));
//     }

//     final response = await request.send();
//     final responseBody = await response.stream.bytesToString();

//     if (response.statusCode == 200) {
//       print(file != null ? 'File sent successfully' : 'Message sent successfully');
//       _controller.clear();

//       setState(() {
//         _messages.insert(
//           0,
//           ChatMessage(
//             messageId: _messages.length + 1,
//             senderId: widget.senderId,
//             receiverId: widget.receiverId,
//             messageText: file != null ? 'Sent a file: ${file.path.split('/').last}' : text!,
//             messageTimestamp: DateTime.now(),
//             isUserMessage: true,
//             isFile: file != null, // Set isFile
//             fileType: fileType, // Set fileType
//             fileUrl: file?.path,
//             fileBytesBase64: fileBytesBase64 ?? '', // Store Base64 string
//           ),
//         );
//         if (file != null) {
//           buttonVisibility[0] = false; // Hide button after sending file
//         }
//       });
//     } else {
//       print('Failed to send ${file != null ? 'file' : 'message'}: ${response.statusCode}');
//       print('Response Body: $responseBody');
//     }
//   } catch (e) {
//     print('Error sending ${file != null ? 'file' : 'message'}: $e');
//   }
// }

// Future<void> _pickAndSendFile() async {
//   final result = await FilePicker.platform.pickFiles();
//   if (result != null) {
//     final PlatformFile file = result.files.first;
//     final selectedFile = File(file.path!);

//     // Call the unified method to handle file sending
//     await _sendMessageOrFile(file: selectedFile);
//   }
// }

  Future<void> longPolling() async {
    try {
      final String url =
          'http://10.3.0.70:9040/api/Flutter/GetMessagesAsync?senderId=${widget.senderId}&receiverId=${widget.receiverId}';
      final response = await http.get(Uri.parse(url));

      // print('Request URL: $url');
      // print('Response: ${response.body}');

      if (response.statusCode == 200) {
        // Check if response body is not null
        if (response.body != null) {
          List<dynamic> messagesJson = jsonDecode(response.body);
          setState(() {
            _messages.clear();
            _messages.addAll(messagesJson
                .map((message) => ChatMessage.fromJson(message))
                .toList());

            // Update button visibility based on messages list
            if (_messages.isNotEmpty) {
              buttonVisibility = [false, false, false]; // Hide buttons
            } else {
              buttonVisibility = [true, true, true]; // Show buttons
            }
          });
        } else {
          // print('Response body is null');
        }
      } else {
        // print('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors

      // print('Error fetching messages: $e');
    } finally {
      //     // Immediately start another long polling request
      Future.delayed(const Duration(seconds: 1), longPolling);
    }
  }

  // Future<void> _downloadAndSaveImage(
  //     BuildContext context, String base64String, String fileName) async {
  //   try {
  //     // Decode the Base64 string
  //     Uint8List fileBytes = base64Decode(base64String);

  //     // Request permission
  //     if (await _requestPermission(Permission.storage)) {
  //       // Save to gallery
  //       final result = await ImageGallerySaver.saveImage(
  //         Uint8List.fromList(fileBytes),
  //         quality: 60,
  //         name: fileName,
  //       );
  //       print('Image saved to gallery: $result');

  //       // Show a confirmation message
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Image saved to gallery'),
  //         ),
  //       );
  //     } else {
  //       // Permission denied
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Permission denied to save file'),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error downloading/saving image: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error saving image'),
  //       ),
  //     );
  //   }
  // }

  // Future<void> _downloadAndSaveFile(
  //     BuildContext context, String base64String, String fileName) async {
  //   try {
  //     // Decode the base64 string
  //     Uint8List bytes = base64Decode(base64String);

  //     // Request permission
  //     if (await _requestPermission(Permission.storage)) {
  //       // Get the directory to save the file
  //       Directory? directory;
  //       if (Platform.isAndroid) {
  //         directory = await getExternalStorageDirectory();
  //         if (directory == null) {
  //           directory = Directory('/storage/emulated/0/Download');
  //         }
  //       } else if (Platform.isIOS) {
  //         directory = await getApplicationDocumentsDirectory();
  //       }

  //       if (directory != null) {
  //         // Create the file with the provided fileName
  //         File file = File('${directory.path}/$fileName');

  //         // Write the bytes to the file
  //         await file.writeAsBytes(bytes);

  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('File saved to ${file.path}'),
  //           ),
  //         );

  //         // Open the file using open_file package
  //         await OpenFile.open(file.path);
  //       } else {
  //         throw Exception('Could not get the storage directory');
  //       }
  //     } else {
  //       // Permission denied
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Permission denied to save file'),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to save file: $e'),
  //       ),
  //     );
  //   }
  // }

  // Future<bool> _requestPermission(Permission permission) async {
  //   if (await permission.isGranted) {
  //     return true;
  //   } else {
  //     final status = await permission.request();
  //     return status == PermissionStatus.granted;
  //   }
  // }

// this below code is working on android 14 perfectly also below versions also
  Future<void> _downloadAndSaveImage(
      BuildContext context, String base64String, String fileName) async {
    try {
      // Decode the Base64 string
      Uint8List fileBytes = base64Decode(base64String);

      // Get Android version
      final plugin = DeviceInfoPlugin();
      final androidInfo = await plugin.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Check and request permission status based on SDK version
      PermissionStatus permissionStatus;
      if (sdkInt < 33) {
        permissionStatus = await Permission.storage.request();
      } else {
        permissionStatus = PermissionStatus.granted;
      }

      // Handle permission statuses
      if (permissionStatus == PermissionStatus.granted) {
        // Permission is granted, proceed to save image
        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(fileBytes),
          quality: 60,
          name: fileName,
        );
        print('Image saved to gallery: $result');

        // Show a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved to gallery'),
          ),
        );
      } else if (permissionStatus == PermissionStatus.denied) {
        print("Permission denied");
        // Optionally handle denied state if needed
      } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
        print("Permission permanently denied");
        // Open app settings if permission is permanently denied
        await openAppSettings();
      }
    } catch (e) {
      print('Error downloading/saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving image'),
        ),
      );
    }
  }

  Future<PermissionStatus> _requestPermission(Permission permission) async {
    // Check if the permission is already granted
    if (await permission.isGranted) {
      return PermissionStatus.granted;
    } else {
      // Request permission
      final status = await permission.request();
      return status;
    }
  }

  // Future<void> _downloadAndSaveFile(
  //     BuildContext context, String base64String, String fileName) async {
  //   try {
  //     // Decode the base64 string
  //     Uint8List bytes = base64Decode(base64String);
  //     final permissionStatus = await _requestPermission(Permission.storage);
  //     // Request permission
  //     // if (await _requestPermission(Permission.storage)) {
  //     if (permissionStatus == PermissionStatus.granted) {
  //       // Get the directory to save the file
  //       Directory? directory;
  //       if (Platform.isAndroid) {
  //         directory = await getExternalStorageDirectory();
  //         if (directory == null) {
  //           directory = Directory('/storage/emulated/0/Download');
  //         }
  //       } else if (Platform.isIOS) {
  //         directory = await getApplicationDocumentsDirectory();
  //       }

  //       if (directory != null) {
  //         // Create the file with the provided fileName
  //         File file = File('${directory.path}/$fileName');

  //         // Write the bytes to the file
  //         await file.writeAsBytes(bytes);

  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('File saved to ${file.path}'),
  //           ),
  //         );

  //         // Open the file using open_file package
  //         await OpenFile.open(file.path);
  //       } else {
  //         throw Exception('Could not get the storage directory');
  //       }
  //     } else {
  //       // Permission denied
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Permission denied to save file'),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to save file: $e'),
  //       ),
  //     );
  //   }
  // }

  Future<void> _downloadAndSaveFile(
      BuildContext context, String base64String, String fileName) async {
    try {
      // Decode the Base64 string
      Uint8List bytes = base64Decode(base64String);

      // Get Android version
      final plugin = DeviceInfoPlugin();
      final androidInfo = await plugin.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Check and request permission status based on SDK version
      PermissionStatus permissionStatus;
      if (sdkInt < 33) {
        permissionStatus = await Permission.storage.request();
      } else {
        permissionStatus = PermissionStatus.granted;
      }

      // Handle permission statuses
      if (permissionStatus == PermissionStatus.granted) {
        // Get the directory to save the file
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
          if (directory == null) {
            directory = Directory('/storage/emulated/0/Download');
          }
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          // Create the file with the provided fileName
          File file = File('${directory.path}/$fileName');

          // Write the bytes to the file
          await file.writeAsBytes(bytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File saved to ${file.path}'),
            ),
          );

          // Open the file using open_file package
          await OpenFile.open(file.path);
        } else {
          throw Exception('Could not get the storage directory');
        }
      } else if (permissionStatus == PermissionStatus.denied) {
        // Optionally handle denied state if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission denied to save file'),
          ),
        );
      } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
        // Open app settings if permission is permanently denied
        await openAppSettings();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save file: $e'),
        ),
      );
    }
  }

  // Future<bool> _requestPermission(Permission permission) async {
  //   if (await permission.isGranted) {
  //     return true;
  //   } else {
  //     final status = await permission.request();
  //     return status == PermissionStatus.granted;
  //   }
  // }

  void _receiveMessage(String text) {
    // Simulate receiving a message (if needed)
    ChatMessage receivedMessage = ChatMessage(
      messageId: _messages.length + 1, // Generate a unique ID as per your logic
      senderId: widget.receiverId, // Sender is the receiver in this context
      receiverId: widget.senderId, // Receiver is the sender in this context
      messageText: text,
      messageTimestamp: DateTime.now(), // Use appropriate timestamp
      isUserMessage: false,
      // fileUrl: null,
      fileBytesBase64: '',
      fileUrl: null, format: '',
      filename: '', // Received messages are not user messages
    );

    setState(() {
      _messages.insert(0, receivedMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactName),
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [Colors.lightGreen, Colors.redAccent],
        //   ),
        // ),
        decoration: UiConstants.backgroundGradient,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                // reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (buttonVisibility[0])
                  GestureDetector(
                    onTap: () {
                      // sendMessage('How are you?', 0);
                      _sendMessageOrFile(
                          text:
                              'How are you?'); // Send predefined message 'Hi!'
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: const Text(
                        'How are you?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (buttonVisibility[1])
                  GestureDetector(
                    onTap: () {
                      // sendMessage('Hi!', 1);
                      _sendMessageOrFile(text: 'Hi!');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: const Text(
                        'Hi!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (buttonVisibility[2])
                  GestureDetector(
                    onTap: () {
                      // sendMessage('What\'s up?', 2);
                      _sendMessageOrFile(text: 'What\'s up?');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: const Text(
                        'What\'s up?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }

//here we show only image and text inside chat screen

  // Widget _buildMessage(ChatMessage message) {
  //   // Get the width of the screen
  //   double screenWidth = MediaQuery.of(context).size.width;

  //   // Set a responsive width for the image
  //   double imageWidth = screenWidth * 0.6; // 40% of the screen width
  //   double imageHeight = 300;
  //   return Align(
  //     alignment: message.senderId == widget.senderId
  //         ? Alignment.centerRight
  //         : Alignment.centerLeft,
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
  //       padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
  //       decoration: BoxDecoration(
  //         color: message.senderId == widget.senderId
  //             ? Colors.lightGreen
  //             : Colors.grey,
  //         borderRadius: BorderRadius.circular(10.0),
  //       ),
  //       child: IntrinsicWidth(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Display image if it exists
  //             if (message.fileBytesBase64 != null &&
  //                 message.fileBytesBase64!.isNotEmpty)
  //               Image.memory(
  //                 base64Decode(message.fileBytesBase64!),
  //                 // height: 250,
  //                 // width: 150,
  //                 height: imageHeight,
  //                 width: imageWidth,
  //                 fit: BoxFit.cover,
  //               ),

  //             // Display text message if it exists
  //             if (message.messageText != null &&
  //                 message.messageText!.isNotEmpty)
  //               Text(
  //                 message.messageText!,
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             // Display timestamp
  //             Text(
  //               DateFormat('hh:mm a').format(message.messageTimestamp),
  //               style: const TextStyle(
  //                 color: Colors.white60,
  //                 fontSize: 12.0,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildMessage(ChatMessage message) {
  //   // Get the width of the screen
  //   double screenWidth = MediaQuery.of(context).size.width;

  //   // Set a responsive width for the image
  //   double imageWidth = screenWidth * 0.6; // 60% of the screen width
  //   double imageHeight = 300;

  //   return Align(
  //     alignment: message.senderId == widget.senderId
  //         ? Alignment.centerRight
  //         : Alignment.centerLeft,
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
  //       padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
  //       decoration: BoxDecoration(
  //         color: message.senderId == widget.senderId
  //             ? Colors.lightGreen
  //             : Colors.grey,
  //         borderRadius: BorderRadius.circular(10.0),
  //       ),
  //       child: IntrinsicWidth(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Display image if it exists
  //             if (message.fileBytesBase64 != null &&
  //                 message.fileBytesBase64!.isNotEmpty)
  //               GestureDetector(
  //                 onLongPress: () async {
  //                   if (await Permission.storage.request().isGranted) {
  //                     _downloadAndSaveImage(
  //                       context,
  //                       message.fileBytesBase64!,
  //                       'image_${message.messageId}',
  //                     );
  //                   } else {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(
  //                         content: Text('Permission denied to save file'),
  //                       ),
  //                     );
  //                   }
  //                 },
  //                 child: Image.memory(
  //                   base64Decode(message.fileBytesBase64!),
  //                   height: imageHeight,
  //                   width: imageWidth,
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //             // Display text message if it exists
  //             if (message.messageText != null &&
  //                 message.messageText!.isNotEmpty)
  //               Text(
  //                 message.messageText!,
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             // Display timestamp
  //             Text(
  //               DateFormat('hh:mm a').format(message.messageTimestamp),
  //               style: const TextStyle(
  //                 color: Colors.white60,
  //                 fontSize: 12.0,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Method to build the message widget
  // Widget _buildMessage(ChatMessage message) {
  //   // Get the width of the screen
  //   double screenWidth = MediaQuery.of(context).size.width;

  //   // Set a responsive width for the image
  //   double imageWidth = screenWidth * 0.6; // 60% of the screen width
  //   double imageHeight = 300;

  //   // Function to check if a file is an image based on its MIME type
  //   bool isImage(String base64String) {
  //     try {
  //       Uint8List bytes = base64Decode(base64String);
  //       String mimeType = lookupMimeType('', headerBytes: bytes) ?? '';
  //       return mimeType.startsWith('image/');
  //     } catch (e) {
  //       return false;
  //     }
  //   }

  //   return Align(
  //     alignment: message.senderId == widget.senderId
  //         ? Alignment.centerRight
  //         : Alignment.centerLeft,
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
  //       padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
  //       decoration: BoxDecoration(
  //         color: message.senderId == widget.senderId
  //             ? Colors.lightGreen
  //             : Colors.grey,
  //         borderRadius: BorderRadius.circular(10.0),
  //       ),
  //       child: IntrinsicWidth(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Display image if it exists and is an image
  //             if (message.fileBytesBase64 != null &&
  //                 message.fileBytesBase64!.isNotEmpty &&
  //                 isImage(message.fileBytesBase64!))
  //               GestureDetector(
  //                 onLongPress: () async {
  //                   if (await Permission.storage.request().isGranted) {
  //                     _downloadAndSaveImage(
  //                       context,
  //                       message.fileBytesBase64!,
  //                       'image_${message.messageId}',
  //                     );
  //                   } else {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(
  //                         content: Text('Permission denied to save file'),
  //                       ),
  //                     );
  //                   }
  //                 },
  //                 child: Image.memory(
  //                   base64Decode(message.fileBytesBase64!),
  //                   height: imageHeight,
  //                   width: imageWidth,
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //             // Display a file icon and filename for non-image files
  //             if (message.fileBytesBase64 != null &&
  //                 message.fileBytesBase64!.isNotEmpty &&
  //                 !isImage(message.fileBytesBase64!))
  //               GestureDetector(
  //                 onLongPress: () async {
  //                   if (await Permission.storage.request().isGranted) {
  //                     _downloadAndSaveFile(
  //                       context,
  //                       message.fileBytesBase64!,
  //                       'file_${message.messageId}',
  //                     );
  //                   } else {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(
  //                         content: Text('Permission denied to save file'),
  //                       ),
  //                     );
  //                   }
  //                 },
  //                 child: Row(
  //                   children: [
  //                     Icon(Icons.insert_drive_file, color: Colors.white),
  //                     SizedBox(width: 10),
  //                     Text(
  //                       'File_${message.messageId}',
  //                       style: TextStyle(color: Colors.white),
  //                     ),
  //                     // Text(
  //                     //   'File_${message.messageText}',
  //                     //   style: TextStyle(color: Colors.white),
  //                     // ),
  //                   ],
  //                 ),
  //               ),
  //             // Display text message if it exists
  //             if (message.messageText != null &&
  //                 message.messageText!.isNotEmpty)
  //               Text(
  //                 message.messageText!,
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             // Display timestamp
  //             Text(
  //               DateFormat('hh:mm a').format(message.messageTimestamp),
  //               style: const TextStyle(
  //                 color: Colors.white60,
  //                 fontSize: 12.0,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMessage(ChatMessage message) {
    // Get the width of the screen
    double screenWidth = MediaQuery.of(context).size.width;

    // Set a responsive width for the image
    double imageWidth = screenWidth * 0.6; // 60% of the screen width
    double imageHeight = 300;

    // Function to check if a file is an image based on its MIME type
    bool isImage(String base64String) {
      try {
        Uint8List bytes = base64Decode(base64String);
        String mimeType = lookupMimeType('', headerBytes: bytes) ?? '';
        return mimeType.startsWith('image/');
      } catch (e) {
        return false;
      }
    }

    // Function to check if a file is a video based on its MIME type
    bool isVideo(String base64String) {
      try {
        Uint8List bytes = base64Decode(base64String);
        String mimeType = lookupMimeType('', headerBytes: bytes) ?? '';
        return mimeType.startsWith('video/');
      } catch (e) {
        return false;
      }
    }

    return Align(
      alignment: message.senderId == widget.senderId
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        decoration: BoxDecoration(
          color: message.senderId == widget.senderId
              ? Colors.lightGreen
              : Colors.grey,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display image if it exists and is an image
              if (message.fileBytesBase64 != null &&
                  message.fileBytesBase64!.isNotEmpty &&
                  isImage(message.fileBytesBase64!))
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageView(
                          imageBytes: base64Decode(message.fileBytesBase64!),
                        ),
                      ),
                    );
                  },
                  onLongPress: () async {
                    print('Long press detected'); // For debugging
                    // if (await Permission.storage.request().isGranted) {

                    _downloadAndSaveImage(
                      context,
                      message.fileBytesBase64!,
                      message.filename ?? 'image_${message.messageId}.png',
                    );
                    // } else {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Text('Permission denied to save file'),
                    //     ),
                    //   );
                    // }
                  },
                  child: Image.memory(
                    base64Decode(message.fileBytesBase64!),
                    height: imageHeight,
                    width: imageWidth,
                    fit: BoxFit.cover,
                  ),
                ),
              // // Display video icon if it is a video file
              // if (message.fileBytesBase64 != null &&
              //     message.fileBytesBase64!.isNotEmpty &&
              //     isVideo(message.fileBytesBase64!))
              //   GestureDetector(
              //     onTap: () {
              //       // Navigator.push(
              //       //   context,
              //       //   MaterialPageRoute(
              //       //     builder: (_) => VideoPlayerScreen(
              //       //       videoBytes: base64Decode(message.fileBytesBase64!),
              //       //     ),
              //       //   ),
              //       // );
              //     },
              //     onLongPress: () async {
              //       if (await Permission.storage.request().isGranted) {
              //         _downloadAndSaveFile(
              //           context,
              //           message.fileBytesBase64!,
              //           message.filename ??
              //               'video_${message.messageId}.${message.format}',
              //         );
              //       } else {
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           SnackBar(
              //             content: Text('Permission denied to save file'),
              //           ),
              //         );
              //       }
              //     },
              //     child: Row(
              //       children: [
              //         Icon(Icons.video_collection, color: Colors.white),
              //         SizedBox(width: 10),
              //         Text(
              //           message.filename != null
              //               ? (message.filename!.length > 15
              //                   ? '${message.filename!.substring(0, 15)}.${message.format}'
              //                   : '${message.filename!}.${message.format}') // Show the truncated file name with format
              //               : 'video_${message.messageId}.${message.format}', // Default text
              //           style: TextStyle(color: Colors.white),
              //         ),
              //       ],
              //     ),
              //   ),
              // Display a file icon and filename for non-image files
              if (message.fileBytesBase64 != null &&
                  message.fileBytesBase64!.isNotEmpty &&
                  !isImage(message.fileBytesBase64!))
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FilePreviewView(
                          fileBytes: base64Decode(message.fileBytesBase64!),
                          filename: message.filename ??
                              'file_${message.messageId}.${message.format}',
                        ),
                      ),
                    );
                  },
                  onLongPress: () async {
                    // if (await Permission.storage.request().isGranted) {
                    _downloadAndSaveFile(
                      context,
                      message.fileBytesBase64!,
                      message.filename ?? 'file_${message.messageId}',
                    );
                    // } else {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Text('Permission denied to save file'),
                    //     ),
                    //   );
                    // }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file, color: Colors.white),
                      SizedBox(width: 10),
                      // Text(
                      //   message.fileName ?? 'file_${message.messageId}',
                      //   style: TextStyle(color: Colors.white),
                      // ),

                      // Text(
                      //   message.filename ??
                      //       'file_${message.messageId}.${message.format}',
                      //   style: TextStyle(color: Colors.white),
                      // ),
                      Text(
                        message.filename != null
                            ? (message.filename!.length > 15
                                ? '${message.filename!.substring(0, 15)}.${message.format}'
                                : '${message.filename!}.${message.format}') // Show the truncated file name with format
                            : 'file_${message.messageId}.${message.format}', // Default text
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              // Display text message if it exists
              if (message.messageText != null &&
                  message.messageText!.isNotEmpty)
                Text(
                  message.messageText!,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              // Display timestamp
              Text(
                DateFormat('hh:mm a').format(message.messageTimestamp),
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: const IconThemeData(color: Colors.lightGreen),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.attach_file), // Add a file icon
              onPressed: _pickAndSendFile, // Call file picker method
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                // onSubmitted: sendMessage,

                onSubmitted: (text) {
                  // sendMessage(text, -1); // Use -1 for custom message
                  _sendMessageOrFile(text: text); // Use unified method for text
                },
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              // onPressed: () => sendMessage(_controller.text),
              // onPressed: () => sendMessage(_controller.text, -1),
              onPressed: () {
                _sendMessageOrFile(
                    text: _controller.text); // Use unified method for text
              },
            ),
          ],
        ),
      ),
    );
  }
}

// To parse this JSON data, do
//
//     final chatMessage = chatMessageFromJson(jsonString);

List<ChatMessage> chatMessageFromJson(String str) => List<ChatMessage>.from(
    json.decode(str).map((x) => ChatMessage.fromJson(x)));

String chatMessageToJson(List<ChatMessage> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatMessage {
  int messageId;
  int senderId;
  int receiverId;
  dynamic messageText;
  DateTime messageTimestamp;
  bool isUserMessage;
  dynamic fileUrl;
  String? fileBytesBase64;
  // dynamic fileBytesBase64;
  // final String? fileName; // Add this line
  bool isFile; // Add this property
  String? fileType; // Add this property
  String? format;
  dynamic filename;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    required this.messageTimestamp,
    required this.isUserMessage,
    this.fileUrl,
    this.fileBytesBase64,
    this.isFile = false, // Default to false
    this.fileType,
    // this.fileName, // Add this line
    required this.format,
    required this.filename,
  });

  // factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
  //       messageId: json["MessageId"],
  //       senderId: json["SenderId"],
  //       receiverId: json["ReceiverId"],
  //       messageText: json["MessageText"],
  //       messageTimestamp: DateTime.parse(json["MessageTimestamp"]),
  //       isUserMessage: json["IsUserMessage"],
  //       fileUrl: json["FileUrl"],
  //       fileBytesBase64: json["FileBytesBase64"],
  //       isFile: json["IsFile"] ?? false, // Deserialize the isFile property
  //       fileType: json["FileType"], // Deserialize the fileType property
  //     );

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        messageId: json['MessageId'],
        senderId: json['SenderId'],
        receiverId: json['ReceiverId'],
        messageText: json['MessageText'],
        messageTimestamp: DateTime.parse(json['MessageTimestamp']),
        isUserMessage: json['IsUserMessage'],
        isFile: json['IsFile'] ?? false,
        fileType: json['FileType'],
        fileBytesBase64:
            json['FileBytesBase64'], // Ensure this is correctly mapped
        format: json["FORMAT"],
        filename: json["FILENAME"],
      );

  Map<String, dynamic> toJson() => {
        "MessageId": messageId,
        "SenderId": senderId,
        "ReceiverId": receiverId,
        "MessageText": messageText,
        "MessageTimestamp": messageTimestamp.toIso8601String(),
        "IsUserMessage": isUserMessage,
        "FileUrl": fileUrl,
        "FileBytesBase64": fileBytesBase64,
        "IsFile": isFile, // Serialize the isFile property
        "FileType": fileType, // Serialize the fileType property
        "FORMAT": format,
        "FILENAME": filename,
      };
}


//below is chat view text send crctly working on image send

// import 'dart:io';
// import 'dart:typed_data';

// import 'package:chatview/chatview.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'dart:convert';

// import 'package:web_socket_channel/io.dart';

// class ChatScreen extends StatefulWidget {
//   final String contactName;
//   final int senderId;
//   final int receiverId;

//   const ChatScreen({
//     Key? key,
//     required this.contactName,
//     required this.senderId,
//     required this.receiverId,
//   }) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final List<ChatMessage> _messages = [];
//   final TextEditingController _controller = TextEditingController();
//   late IOWebSocketChannel _channel;
//   List<bool> buttonVisibility = [
//     true,
//     true,
//     true
//   ]; // Track visibility of buttons
//   late ChatController _chatController;

//   @override
//   void initState() {
//     super.initState();
//     _chatController = ChatController(
//       initialMessageList: _messages
//           .map((e) => Message(
//                 id: e.messageId.toString(),
//                 message: e.messageText,
//                 createdAt: e.messageTimestamp,
//                 sentBy: e.senderId.toString(),
//                 reaction: null,
//               ))
//           .toList(),
//       scrollController: ScrollController(),
//       otherUsers: [],
//       currentUser: ChatUser(id: widget.senderId.toString(), name: 'name'),
//     );
//     fetchMessages();
//     // _initializeWebSocket();
//   }

//   void _initializeWebSocket() {
//     _channel = IOWebSocketChannel.connect(
//         'ws://10.3.0.70:9040/api/Flutter/GetWebSocket');

//     _channel.stream.listen((message) {
//       print('New message: $message');
//       final newMessage = ChatMessage.fromJson(jsonDecode(message));
//       setState(() {
//         _messages.insert(0, newMessage);
//         _chatController.addMessage(
//           Message(
//             id: newMessage.messageId.toString(),
//             message: newMessage.messageText,
//             createdAt: newMessage.messageTimestamp,
//             sentBy: newMessage.senderId.toString(),
//             reaction: null,
//           ),
//         );
//       });
//     }, onError: (error) {
//       print('WebSocket error: $error');
//     }, onDone: () {
//       print('WebSocket closed');
//     });
//   }

//   Future<void> fetchMessages() async {
//     try {
//       final String url =
//           'http://10.3.0.70:9040/api/Flutter/GetMessagesAsync?senderId=${widget.senderId}&receiverId=${widget.receiverId}';
//       final response = await http.get(Uri.parse(url));

//       print('Request URL: $url');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         if (response.body != null) {
//           List<dynamic> messagesJson = jsonDecode(response.body);

//           setState(() {
//             _messages.clear();
//             _messages.addAll(messagesJson
//                 .map((message) => ChatMessage.fromJson(message))
//                 .toList());

//             _chatController = ChatController(
//               initialMessageList: _messages
//                   .map((e) => Message(
//                         id: e.messageId.toString(),
//                         message: e.messageText,
//                         createdAt: e.messageTimestamp,
//                         sentBy: e.senderId.toString(),
//                         reaction: null,
//                       ))
//                   .toList(),
//               scrollController: ScrollController(),
//               otherUsers: [],
//               currentUser:
//                   ChatUser(id: widget.senderId.toString(), name: 'name'),
//             );

//             buttonVisibility = _messages.isNotEmpty
//                 ? [false, false, false]
//                 : [true, true, true];
//           });
//         } else {
//           print('Response body is null');
//         }
//       } else {
//         print('Failed to load messages: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching messages: $e');
//     }
//   }

//   Future<void> _sendMessageOrFile({String? text, File? file}) async {
//     try {
//       final String url = 'http://10.3.0.70:9040/api/Flutter/AddMessageAsync';
//       final request = http.MultipartRequest('POST', Uri.parse(url))
//         ..fields['SenderId'] = widget.senderId.toString()
//         ..fields['ReceiverId'] = widget.receiverId.toString()
//         ..fields['MessageText'] = text ?? ''
//         ..fields['IsUserMessage'] = 'true'
//         ..fields['MessageTimestamp'] = DateTime.now().toIso8601String();

//       String? fileType;
//       String? fileBytesBase64;
//       if (file != null) {
//         final fileName = file.path.split('/').last;
//         fileType = fileName.split('.').last.toLowerCase();

//         final Uint8List bytes = await file.readAsBytes();
//         fileBytesBase64 = base64.encode(bytes);
//         print('base 64 : ${fileBytesBase64}');

//         request.fields['FileBytesBase64'] = fileBytesBase64;
//         request.files.add(await http.MultipartFile.fromPath('file', file.path,
//             filename: fileName));
//       }

//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         print(file != null
//             ? 'File sent successfully'
//             : 'Message sent successfully');
//         _controller.clear();

//         final newMessage = ChatMessage(
//           messageId: _messages.length + 1,
//           senderId: widget.senderId,
//           receiverId: widget.receiverId,
//           messageText: file != null
//               ? 'Sent a file: ${file.path.split('/').last}'
//               : text!,
//           // messageText: file != null ? null : text,
//           messageTimestamp: DateTime.now(),
//           isUserMessage: true,
//           isFile: file != null,
//           fileType: fileType,
//           fileUrl: file?.path,
//           fileBytesBase64: fileBytesBase64 ?? '', format: '', filename: null,
//         );

//         setState(() {
//           _messages.insert(0, newMessage);
//           _chatController.addMessage(
//             Message(
//               id: newMessage.messageId.toString(),
//               message: newMessage.messageText,
//               createdAt: newMessage.messageTimestamp,
//               sentBy: newMessage.senderId.toString(),
//               reaction: null,
//             ),
//           );

//           if (file != null) {
//             buttonVisibility[0] = false;
//           }
//         });
//       } else {
//         print(
//             'Failed to send ${file != null ? 'file' : 'message'}: ${response.statusCode}');
//         print('Response Body: $responseBody');
//       }
//     } catch (e) {
//       print('Error sending ${file != null ? 'file' : 'message'}: $e');
//     }
//   }

//   Future<void> _pickAndSendFile() async {
//     final result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       final PlatformFile file = result.files.first;
//       final selectedFile = File(file.path!);

//       await _sendMessageOrFile(file: selectedFile);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final StringMessageCallBack? onSendTap;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.contactName),
//         backgroundColor: Colors.lightGreen,
//       ),
//       body: ChatView(
//         chatController: _chatController,

//         onSendTap: (message, replyMessage, messageType) {
//           _onSendTap(message, replyMessage, messageType);
//         },
//         chatViewState: _messages.isNotEmpty
//             ? ChatViewState.hasMessages
//             : ChatViewState.noData, // Adjusted constant
//       ),
//     );
//   }

//   void _onSendTap(
//     String message,
//     ReplyMessage replyMessage,
//     MessageType messageType,
//   ) async {
//     if (message.isNotEmpty) {
//       await _sendMessageOrFile(text: message);
//     }
//     _chatController.scrollToLastMessage();
//   }
// }

// List<ChatMessage> chatMessageFromJson(String str) => List<ChatMessage>.from(
//     json.decode(str).map((x) => ChatMessage.fromJson(x)));

// String chatMessageToJson(List<ChatMessage> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class ChatMessage {
//   int messageId;
//   int senderId;
//   int receiverId;
//   dynamic messageText;
//   DateTime messageTimestamp;
//   bool isUserMessage;
//   dynamic fileUrl;
//   String? fileBytesBase64;
//   bool isFile;
//   String? fileType;
//   String? format;
//   dynamic filename;

//   ChatMessage({
//     required this.messageId,
//     required this.senderId,
//     required this.receiverId,
//     required this.messageText,
//     required this.messageTimestamp,
//     required this.isUserMessage,
//     this.fileUrl,
//     this.fileBytesBase64,
//     this.isFile = false,
//     this.fileType,
//     // this.fileName, // Add this line
//     required this.format,
//     required this.filename,
//   });

//   factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
//       messageId: json["MessageId"],
//       senderId: json["SenderId"],
//       receiverId: json["ReceiverId"],
//       messageText: json["MessageText"],
//       messageTimestamp: DateTime.parse(json["MessageTimestamp"]),
//       isUserMessage: json["IsUserMessage"],
//       fileUrl: json["FileUrl"],
//       fileBytesBase64: json["FileBytesBase64"],
//       isFile: json["IsFile"] ?? false,
//       fileType: json["FileType"],
//       format: json["FORMAT"],
//       filename: json["FILENAME"]);

//   Map<String, dynamic> toJson() => {
//         "MessageId": messageId,
//         "SenderId": senderId,
//         "ReceiverId": receiverId,
//         "MessageText": messageText,
//         "MessageTimestamp": messageTimestamp.toIso8601String(),
//         "IsUserMessage": isUserMessage,
//         "FileUrl": fileUrl,
//         "FileBytesBase64": fileBytesBase64,
//         "IsFile": isFile,
//         "FileType": fileType,
//         "FORMAT": format,
//         "FILENAME": filename,
//       };
// }
