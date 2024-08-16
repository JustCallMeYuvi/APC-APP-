// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class WebSocketManager {
//   WebSocketManager._privateConstructor();

//   static final WebSocketManager instance =
//       WebSocketManager._privateConstructor();

//   WebSocket? _webSocket;
//   bool _isConnected = false;
//   final String _socketUrl =
//       'ws://10.3.0.70:9042/api/HR'; // Update with your WebSocket URL

//   late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

//   Future<void> init() async {
//     _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

//     await _connectToSocket();
//   }

//   Future<void> _connectToSocket() async {
//     try {
//       if (_webSocket == null || _webSocket?.readyState != WebSocket.open) {
//         _webSocket = await WebSocket.connect(_socketUrl);
//         _isConnected = true;
//         _showNotification(
//             'WebSocket Connected', 'Successfully connected to $_socketUrl');
//         _webSocket?.listen(
//           (data) {
//             _showNotification('New Data Received', data.toString());
//           },
//           onDone: () {
//             _isConnected = false;
//           },
//           onError: (error) {
//             _isConnected = false;
//             print('WebSocket error: $error');
//           },
//         );
//       }
//     } catch (e) {
//       _isConnected = false;
//       print('Error connecting to WebSocket: $e');
//     }
//   }

//   Future<void> _showNotification(String title, String body) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'your_channel_id',
//       'your_channel_name',
//       channelDescription: 'Your channel description',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );

//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: 'item x',
//     );
//   }

//   void dispose() {
//     _webSocket?.close();
//   }
// }


import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WebSocketManager {
  WebSocketManager._privateConstructor();

  static final WebSocketManager instance = WebSocketManager._privateConstructor();

  WebSocket? _webSocket;
  bool _isConnected = false;
  final String _socketUrl = 'ws://10.3.0.70:9042/api/HR'; // Update with your WebSocket URL

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  Future<void> init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _connectToSocket();
  }

  Future<void> _connectToSocket() async {
    try {
      if (_webSocket == null || _webSocket?.readyState != WebSocket.open) {
        _webSocket = await WebSocket.connect(_socketUrl);
        _isConnected = true;
        _showNotification(
            'WebSocket Connected', 'Successfully connected to $_socketUrl');
        _webSocket?.listen(
          (data) {
            _showNotification('New Data Received', data.toString());
          },
          onDone: () {
            _isConnected = false;
          },
          onError: (error) {
            _isConnected = false;
            print('WebSocket error: $error');
          },
        );
      }
    } catch (e) {
      _isConnected = false;
      print('Error connecting to WebSocket: $e');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'Your channel description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void dispose() {
    _webSocket?.close();
  }
}
