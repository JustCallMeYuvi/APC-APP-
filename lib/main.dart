import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:animated_movies_app/app.dart';
import 'package:animated_movies_app/auth_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Global instance for FlutterLocalNotificationsPlugin
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> main() async {
  // runApp(
  //   const App(),
  // );
  //   WidgetsFlutterBinding.ensureInitialized();
  // await WebSocketManager.instance.init();
  //  WidgetsFlutterBinding.ensureInitialized();
  // WidgetsFlutterBinding.ensureInitialized();
  // // await Permission.notification.isDenied.then((value) {
  // //   if (value) {
  // //     Permission.notification.request();
  // //   }
  // // });
  // await initializeServices();

  // WidgetsFlutterBinding.ensureInitialized();
  // await initializeService();

  // WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: Defa);

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options for the current platform
  await Firebase.initializeApp();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('fcm Token $fcmToken');
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(), // Create AuthProvider instance
      child: const App(),
    ),
  );
}
