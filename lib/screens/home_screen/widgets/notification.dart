import 'dart:convert';

import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/model/emp_leave_details_model.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Add HTTP package

class NotificationsScreen extends StatefulWidget {
  final LoginModelApi userData; // Add this line
  NotificationsScreen({super.key, required this.userData});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<EmpLeaveDetails> empLeaveDetails = [];
  @override
  void initState() {
    super.initState();
    fetchDataLeaves(widget.userData.empNo);
    // fetchDataLeaves();
  }

  Future<void> fetchDataLeaves(String empNo) async {
    // final url = Uri.parse('http://10.3.0.70:9040/api/Flutter/GetEmpDetails?empNo=$empNo');
    final url = Uri.parse(
        'http://10.3.0.70:9040/api/Flutter/GetAH_HOLIDAYDetails?empNo=${widget.userData.empNo}');

    print('Leave url $url');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        // Debug: Print the raw response body
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        // Debug: Print the parsed JSON data
        jsonResponse.forEach((data) {
          print('Parsed JSON item: $data');
        });

        setState(() {
          empLeaveDetails = jsonResponse
              .map((data) => EmpLeaveDetails.fromJson(data))
              .toList();

          // Debug: Print the list of empDetailsList
          empLeaveDetails.forEach((detail) {
            print(
                'Emp Detail: ${detail.empNo}, ${detail.deptNo}, ${detail.startDate}, ${detail.endDate}');
          });
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
        // Handle error case, show error message or retry logic
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error case, show error message or retry logic
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: UiConstants.backgroundGradient.gradient,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 10),
                  child: Text(
                    'Recent Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // buildNotificationCard(
                //   icon: Icons.notifications_active,
                //   title: 'New Update Available',
                //   subtitle: 'Tap to update the app to the latest version.',
                // ),
                if (empLeaveDetails != null)
                  for (var empLeave in empLeaveDetails)
                    buildNotificationCard(
                      icon: Icons.notifications_active,
                      title: 'Leave Hours : ${empLeave.holidayKind}',
                      subtitle:
                          'Start Date: ${empLeave.startDate}, End Date: ${empLeave.endDate}',
                    ),
                // buildNotificationCard(
                //   icon: Icons.notifications,
                //   title: 'Reminder',
                //   subtitle: 'You have an upcoming event tomorrow.',
                // ),
                // buildNotificationCard(
                //   icon: Icons.notifications_off,
                //   title: 'Notification Settings',
                //   subtitle: 'Modify your notification preferences.',
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNotificationCard(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Card(
      color: Colors.grey[800],
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      elevation: 5,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        onTap: () {
          // Handle notification tap
        },
      ),
    );
  }
}
