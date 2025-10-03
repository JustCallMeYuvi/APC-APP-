// import 'dart:convert';

import 'package:animated_movies_app/auth_provider.dart';
import 'package:animated_movies_app/methods/update_helper.dart';
import 'package:animated_movies_app/screens/home_screen/home_screen.dart';
import 'package:animated_movies_app/screens/onboarding_screen/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// class App extends StatefulWidget {
//   const App({Key? key});

//   @override
//   State<App> createState() => _AppState();
// }

// class _AppState extends State<App> {
// @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//      WidgetsBinding.instance.addPostFrameCallback((_) {
//       UpdateHelper.checkForUpdates(context);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   // Perform the update check after the widget tree is built
//     //   checkForUpdates(context);
//     // });

//     return MaterialApp(
//       title: 'Apache App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.purple,
//         // Your theme settings
//       ),
//       home: Consumer<AuthProvider>(
//         builder: (context, authProvider, _) {
//           if (authProvider.isLoggedIn) {
//             return HomeScreen(userData: authProvider.userData!);
//           } else {
//             return const OnboardingScreen(); // Replace with your login or onboarding screen
//           }
//         },
//       ),
//     );
//   }
// }

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apache App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home:
          const SplashScreenWithCheckAppUpdates(), // 👈 New wrapper for update check
    );
  }
}

class SplashScreenWithCheckAppUpdates extends StatefulWidget {
  const SplashScreenWithCheckAppUpdates({Key? key}) : super(key: key);

  @override
  State<SplashScreenWithCheckAppUpdates> createState() =>
      _SplashScreenWithCheckAppUpdatesState();
}

class _SplashScreenWithCheckAppUpdatesState
    extends State<SplashScreenWithCheckAppUpdates> {
  bool _isCheckingUpdate = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkUpdateFlow();
    });
  }

  Future<void> _checkUpdateFlow() async {
    try {
      await UpdateHelper.checkForUpdates(context);
    } catch (e) {
      print("Update check failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingUpdate) {
      return const Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Checking for latest APK version...",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        )),
      );
    }

    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isLoggedIn) {
      return HomeScreen(userData: authProvider.userData!);
    } else {
      return const OnboardingScreen();
    }
  }
}
