import 'dart:async';
import 'dart:convert';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/local_notifications_service.dart';
import 'package:http/http.dart' as http;

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final NotificationService notificationService;
  final LoginModelApi
      userData; // Assuming LoginModelApi is your user data model
  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.notificationService,
    required this.userData,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late Timer _timer;
  bool _showNotificationIndicator = false; // Indicator visibility flag

  @override
  void initState() {
    super.initState();
    // Start a timer to show notifications every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      // Call API to fetch holiday details
      _fetchHolidayDetails(widget.userData.empNo);
    });

    // Initialize notification service with a callback to navigate to notifications screen
    widget.notificationService.initNotification((payload) {
      _navigateToNotifications();
    });
  }

  void _navigateToNotifications() {
    setState(() {
      widget.onItemTapped(1); // Set the selected index to the notifications tab
      _showNotificationIndicator = true; // Show the indicator
    });
  }

  Future<void> _fetchHolidayDetails(String empNo) async {
    try {
      // Construct API URL
      String apiUrl =
          'http://10.3.0.70:9040/api/Flutter/GetAH_HOLIDAYDetailsss?empNo=$empNo';

      // String apiUrl =
      //         'http://10.3.0.70:9042/api/HR/GetAH_HOLIDAYDetailsss?empNo=$empNo';

      // Make GET request
      var response = await http.get(Uri.parse(apiUrl));
      print('${apiUrl}');

      // Check if request was successful
      if (response.statusCode == 200) {
        // Parse JSON response
        String responseBody = response.body;

        // Check if responseBody is empty or contains only '[]'
        if (responseBody.trim().isNotEmpty && responseBody.trim() != '[]') {
          // Decode the JSON response
          var responseJson = jsonDecode(responseBody);

          // Check if responseJson is a list and has elements
          if (responseJson is List && responseJson.isNotEmpty) {
            // Extract required fields from the first object in the array
            var startDate = responseJson[0]['START_DATE'];
            var endDate = responseJson[0]['END_DATE'];
            var holidayQty = responseJson[0]['HOLIDAY_QTY'];

            // Create a formatted string with the extracted details
            String notificationBody =
                'Start Date: $startDate\nEnd Date: $endDate\nHoliday Qty: $holidayQty';

            // Show notification with fetched holiday details
            widget.notificationService.showNotification(
              title: 'Employee Leave Notification',
              body: notificationBody, // Display fetched details in notification
            );
            setState(() {
              _showNotificationIndicator = true;
            });
            print('Holiday details fetched successfully: $notificationBody');
          } else {
            print('Holiday details empty or not available.');
          }
        } else {
          print('Holiday details empty or not available.');
        }
      } else {
        // Handle other status codes (e.g., 404, 500)
        print('Failed to fetch holiday details: ${response.statusCode}');
      }
    } catch (e) {
      // Handle potential errors such as network errors
      print('Error fetching holiday details: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

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
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apps),
              label: 'Apps',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box_outlined),
              label: 'About',
            ),
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
