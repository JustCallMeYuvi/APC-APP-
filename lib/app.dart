import 'package:animated_movies_app/auth_provider.dart';
import 'package:animated_movies_app/screens/home_screen/home_screen.dart';
import 'package:animated_movies_app/screens/onboarding_screen/onboarding_screen.dart';
import 'package:animated_movies_app/screens/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({Key? key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'Apache App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        // Your theme settings
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoggedIn) {
            return HomeScreen(userData: authProvider.userData!);
          } else {
            return const OnboardingScreen(); // Replace with your login or onboarding screen
          }
        },
      ),
    );
  }
}
