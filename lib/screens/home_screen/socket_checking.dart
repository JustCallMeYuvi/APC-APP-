import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SocketChecking extends StatefulWidget {
  const SocketChecking({Key? key}) : super(key: key);

  @override
  _SocketCheckingState createState() => _SocketCheckingState();
}

class _SocketCheckingState extends State<SocketChecking> {
  WebSocket? _webSocket;
  bool _isConnected = false;
  final String _socketUrl =
      'ws://10.3.0.70:9042/api/HR'; // Update with your WebSocket URL

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _connectToSocket();
  }

  Future<void> _initializeNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    bool? initializationSuccess = await _flutterLocalNotificationsPlugin
        .initialize(initializationSettings);
    if (initializationSuccess != null && initializationSuccess) {
      print('Notification plugin initialized successfully.');
    } else {
      print('Failed to initialize notification plugin.');
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

  Future<void> _connectToSocket() async {
    try {
      print('Attempting to connect to $_socketUrl');
      _webSocket = await WebSocket.connect(_socketUrl);
      setState(() {
        _isConnected = true;
      });
      _showNotification(
          'WebSocket Connected', 'Successfully connected to $_socketUrl');
      _webSocket?.listen(
        (data) {
          print('Received data: $data');
          _showNotification('New Data Received', data.toString());
        },
        onDone: () {
          setState(() {
            _isConnected = false;
          });
        },
        onError: (error) {
          setState(() {
            _isConnected = false;
          });
          print('WebSocket error: $error');
        },
      );
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
      print('Error connecting to WebSocket: $e');
    }
  }

  @override
  void dispose() {
    _webSocket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Connection'),
      ),
      body: Center(
        child: Text(
          _isConnected
              ? 'WebSocket is connected'
              : 'WebSocket is not connected',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
