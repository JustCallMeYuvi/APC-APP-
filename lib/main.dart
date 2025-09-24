// import 'dart:async';

// import 'package:animated_movies_app/app.dart';
// import 'package:animated_movies_app/auth_provider.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/widgets.dart';

// import 'package:provider/provider.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// // Background message handler (must be a top-level function)
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message: ${message.messageId}');
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase with options for the current platform
//   await Firebase.initializeApp();
//   final fcmToken = await FirebaseMessaging.instance.getToken();

//   print('fcm Token $fcmToken');
//   // Listen for foreground messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Received a message in the foreground!');
//     print('Message data: ${message.data}');

//     if (message.notification != null) {
//       print('Notification Title: ${message.notification!.title}');
//       print('Notification Body: ${message.notification!.body}');
//     }
//   });

//   // Set up background message handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => AuthProvider(), // Create AuthProvider instance
//       child: const App(),
//     ),
//   );
// }

// below  fcm token inside debug console

import 'dart:async';
import 'package:animated_movies_app/services/feedback_provider.dart';
import 'package:animated_movies_app/services/provider_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:animated_movies_app/app.dart';
import 'package:animated_movies_app/auth_provider.dart';

// Global instance for FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.notification != null) {
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title, // Notification title
      message.notification?.body, // Notification body
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel', // Channel ID
          'High Importance Notifications', // Channel title
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        ),
      ),
    );
  }
}

Future<void> _setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // Unique ID for the channel
    'High Importance Notifications', // Channel title
    // 'This channel is used for important notifications.', // Channel description
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await _setupNotificationChannel();

  // Call the update check function before running the app
  // await checkForUpdates(); // Call this to check for updates

  // Request notification permissions (necessary for Android 13+)
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Check and print the permission status
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // print('FCM Token: $fcmToken');

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Notification Title: ${message.notification!.title}');
      print('Notification Body: ${message.notification!.body}');

      // Show notification using flutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        message.notification?.title, // Notification title
        message.notification?.body, // Notification body
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // Channel ID
            'High Importance Notifications', // Channel title
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
            icon:
                'drawable/ic_notification', // Correctly reference the icon here
          ),
        ),
      );
    }
  });

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    // ChangeNotifierProvider(
    //   create: (_) => AuthProvider(),
    //   child: const App(),
    // ),
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatrollingProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
      ],
      //     child: BlocProvider(
      //     create: (_) => AssetBloc(),
      //   child: const App(),
      // ),
      child: const App(),
    ),
  );
}
