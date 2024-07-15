import 'dart:io';
import 'dart:typed_data';

import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
    longPolling(); // Start long polling for new messages
    // _initializeWebSocket();
  }

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

  Future<void> _sendMessageOrFile({String? text, File? file}) async {
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
        // setState(() {
        //   _messages.insert(
        //     0,
        //     ChatMessage(
        //       messageId: _messages.length + 1,
        //       senderId: widget.senderId,
        //       receiverId: widget.receiverId,
        //       messageText: file != null
        //           ? 'Sent a file: ${file.path.split('/').last}'
        //           : text!,
        //       messageTimestamp: DateTime.now(),
        //       isUserMessage: true,
        //       isFile: file != null,
        //       fileType: fileType,
        //       fileUrl: file?.path,
        //       fileBytesBase64: fileBytesBase64 ?? '', // Store Base64 string
        //     ),
        //   );
        //   if (file != null) {
        //     buttonVisibility[0] = false; // Hide button after sending file
        //   }
        // });

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
              fileBytesBase64: fileBytesBase64 ?? '', // Store Base64 string
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
      fileUrl: null, // Received messages are not user messages
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

  // Widget _buildMessage(ChatMessage message) {
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
  //             if (message.isFile && message.fileType != null) ...[
  //               if (['jpg', 'jpeg', 'png'].contains(message.fileType) &&
  //                   message.fileBytesBase64 != null &&
  //                   message.fileBytesBase64!.isNotEmpty)
  //                 Image.memory(
  //                   base64Decode(message.fileBytesBase64!),
  //                   height: 100,
  //                   width: 100,
  //                   fit: BoxFit.cover,
  //                 )
  //               else
  //                 const SizedBox
  //                     .shrink(), // Hide if not an image or base64 is null
  //             ],
  //             if (!message.isFile)
  //               Text(
  //                 message.messageText ?? '', // Default to empty string if null
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                 ),
  //               ),
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

//here we show only image and text inside chat screen

  Widget _buildMessage(ChatMessage message) {
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
              // Display image if it exists
              if (message.fileBytesBase64 != null &&
                  message.fileBytesBase64!.isNotEmpty)
                Image.memory(
                  base64Decode(message.fileBytesBase64!),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
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

// class ChatMessage {
//   final int messageId;
//   final int senderId;
//   final int receiverId;
//   final String messageText;
//   final DateTime messageTimestamp;
//   final bool isUserMessage;
//   final bool isFile;
//   final String? fileType;
//   final String? fileUrl;
//   final String? fileBytesBase64; // Expect Base64 string

//   ChatMessage({
//     required this.messageId,
//     required this.senderId,
//     required this.receiverId,
//     required this.messageText,
//     required this.messageTimestamp,
//     required this.isUserMessage,
//     this.isFile = false,
//     this.fileType,
//     this.fileUrl,
//     this.fileBytesBase64,
//   });

//   factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
//         messageId: json['MessageId'],
//         senderId: json['SenderId'],
//         receiverId: json['ReceiverId'],
//         messageText: json['MessageText'],
//         messageTimestamp: DateTime.parse(json['MessageTimestamp']),
//         isUserMessage: json['IsUserMessage'],
//         fileUrl: json['FileUrl'],
//         fileBytesBase64: json['FileBytesBase64'],
//       );

//   // factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
//   //       messageId: json['MessageId'],
//   //       senderId: json['SenderId'],
//   //       receiverId: json['ReceiverId'],
//   //       messageText:
//   //           json['MessageText'] ?? '', // Default to empty string if null
//   //       messageTimestamp: DateTime.parse(json['MessageTimestamp']),
//   //       isUserMessage: json['IsUserMessage'],
//   //       fileUrl: json['FileUrl'],
//   //       fileBytesBase64: json['FileBytesBase64'],
//   //     );
// }

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

  bool isFile; // Add this property
  String? fileType; // Add this property

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
      };
}
