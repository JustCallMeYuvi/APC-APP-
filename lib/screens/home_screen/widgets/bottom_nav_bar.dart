import 'dart:async';

import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  // final NotificationService notificationService;
  final LoginModelApi
      userData; // Assuming LoginModelApi is your user data model
  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    // required this.notificationService,
    required this.userData,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  // late Timer _timer;
  bool _showNotificationIndicator = false; // Indicator visibility flag

  @override
  void initState() {
    super.initState();
    
  }

  // Future<void> _fetchUserAccess(String empNo) async {
  //   try {
  //     // Construct API URL
  //     String apiUrl = 'http://10.3.0.70:9042/api/HR/useraccess?empNo=$empNo';
  //     print(apiUrl);
  //     // Make GET request
  //     var response = await http.get(Uri.parse(apiUrl));

  //     // Check if request was successful
  //     if (response.statusCode == 200) {
  //       print('User access fetched successfully');
  //     } else {
  //       print('Failed to fetch user access: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Handle potential errors such as network errors
  //     print('Error fetching user access: $e');
  //   }
  // }
  

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BottomNavigationBar(
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.chat),
            //   label: 'Chats',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apps),
              label: 'Apps',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.account_box_outlined),
            //   label: 'About',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Accounts',
            ),
          ],
          currentIndex: widget.selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              widget.onItemTapped(index); // Call the original callback
              if (index == 1) {
                _showNotificationIndicator = false; // Dismiss indicator on tap
              }
              // Call the API whenever an item is tapped
              // _fetchUserAccess(widget.userData.empNo);
            });
          },
        ),
        if (_showNotificationIndicator)
          Positioned(
            top: 8,
            right: 8,
            left: -148,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red, // Indicator color
              ),
              child: Icon(
                Icons.circle,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
