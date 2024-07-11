import 'package:animated_movies_app/constants/ui_constant.dart';
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
      print('Response: ${response.body}');

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

  Future<void> sendMessage(String text, int index) async {
    try {
      if (text.isNotEmpty) {
        final String url = 'http://10.3.0.70:9040/api/Flutter/AddMessageAsync';
        final Map<String, dynamic> requestBody = {
          'SenderId': widget.senderId,
          'ReceiverId': widget.receiverId,
          'MessageText': text,
          'IsUserMessage': true,
          'MessageTimestamp': DateTime.now().toIso8601String(),
        };

        print('Request URL: $url');
        print('Request Body: ${jsonEncode(requestBody)}');

        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody),
        );

        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          // Message sent successfully

          _controller.clear();
          setState(() {
            _messages.insert(
              0,
              ChatMessage(
                messageId: _messages.length + 1,
                senderId: widget.senderId,
                receiverId: widget.receiverId,
                messageText: text,
                messageTimestamp: DateTime.now(),
                isUserMessage: true,
              ),
            );
            buttonVisibility[index] = false; // Hide button after sending
          });
        } else {
          // Handle HTTP error
          final responseBody = jsonDecode(response.body);
          print('Failed to send message: ${response.statusCode}');
          print('Error: ${responseBody['Message']}');
          if (responseBody.containsKey('Error')) {
            print('Detailed Error: ${responseBody['Error']}');
          }
        }
      }
    } catch (e) {
      print('Error sending message: $e');
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
      isUserMessage: false, // Received messages are not user messages
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
                      sendMessage('How are you?', 0);
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
                      sendMessage('Hi!', 1);
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
                      sendMessage('What\'s up?', 2);
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
              Text(
                message.messageText,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic),
              ),
              // const SizedBox(height: 12), // Adjust spacing as needed
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '${DateFormat('hh:mm a').format(message.messageTimestamp)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
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
            Expanded(
              child: TextField(
                controller: _controller,
                // onSubmitted: sendMessage,

                onSubmitted: (text) {
                  sendMessage(text, -1); // Use -1 for custom message
                },
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              // onPressed: () => sendMessage(_controller.text),
              onPressed: () => sendMessage(_controller.text, -1),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final int messageId;
  final int senderId;
  final int receiverId;
  final String messageText;
  final DateTime messageTimestamp;
  final bool isUserMessage;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    required this.messageTimestamp,
    required this.isUserMessage,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        messageId: json['MessageId'],
        senderId: json['SenderId'],
        receiverId: json['ReceiverId'],
        messageText: json['MessageText'],
        messageTimestamp: DateTime.parse(json['MessageTimestamp']),
        isUserMessage: json['IsUserMessage'],
      );
}
