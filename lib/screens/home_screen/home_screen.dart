import 'package:animated_movies_app/screens/home_screen/about_screen.dart';
import 'package:animated_movies_app/screens/home_screen/account_screen.dart';

import 'package:animated_movies_app/screens/home_screen/contacts_screen.dart';
import 'package:animated_movies_app/screens/home_screen/home_content_screen.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/bottom_nav_bar.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/local_notifications_service.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/notification.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final LoginModelApi userData; // Add this line
  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService _notificationService = NotificationService();
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification((payload) {
      _onItemTapped(1); // Navigate to notifications screen
    });
    _widgetOptions = <Widget>[
      HomeContent(
        userData: widget.userData,
      ),

      NotificationsScreen(
        userData: widget.userData,
      ),
      // ChatScreen(),
      ContactsPage(
        userData: widget.userData,
      ),
      AboutScreen(),
      AccountDetailsScreen(userData: widget.userData), // Pass userData here
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        notificationService: _notificationService,
        userData: widget.userData,
      ),
    );
  }
}
