import 'dart:convert';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/model/emp_leave_details_model.dart';

import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add HTTP package

class NotificationsScreen extends StatefulWidget {
  final LoginModelApi userData; // Add this line
  const NotificationsScreen({super.key, required this.userData});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // final NotificationService _notificationService = NotificationService();
  List<EmpLeaveDetails> empLeaveDetails = [];
  @override
  void initState() {
    super.initState();
    // _notificationService.initNotification((payload) {
    fetchDataLeaves(widget.userData.empNo);
    // fetchDataLeaves();
    // });
  }

  //  @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Fetch data whenever dependencies change (screen is navigated to or refreshed)
  //   fetchDataLeaves(widget.userData.empNo);
  // }

  Future<void> fetchDataLeaves(String empNo) async {
    // final url = Uri.parse('http://10.3.0.70:9040/api/Flutter/GetEmpDetails?empNo=$empNo');
    // final url = Uri.parse(
    //     'http://10.3.0.70:9040/api/Flutter/GetAH_HOLIDAYDetails?empNo=${widget.userData.empNo}');
    final url = Uri.parse(
        'http://10.3.0.70:9042/api/HR/GetAH_HOLIDAYDetails?empNo=${widget.userData.empNo}');

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
            // print(
            //     'Emp Detail: ${detail.empNo}, ${detail.deptNo}, ${detail.startDate}, ${detail.endDate}');
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
        child: empLeaveDetails.isEmpty
            ? Center(
                child: Text(
                  'No Notifications',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                itemCount: empLeaveDetails.length,
                itemBuilder: (context, index) {
                  final empLeave = empLeaveDetails[index];
                  return Dismissible(
                    // key: Key(empLeave.empNo.toString()), // Use a unique key
                    key:
                        UniqueKey(), // Ensure each Dismissible has a unique key
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: Text(
                                'Are you sure you want to delete this notification?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },

                    onDismissed: (direction) {
                      // Call deleteNotification method
                      deleteNotification(empLeave.holidaYId);
                      setState(() {
                        empLeaveDetails.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Notification dismissed'),
                      ));
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: buildNotificationCard(
                      icon: Icons.notifications_active,
                      title: 'Leave Hours : ${empLeave.holidaYQty}',
                      subtitle:
                          'Start Date: ${_formatDate(empLeave.starTDate)}, \nEnd Date: ${_formatDate(empLeave.enDDate)}',
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
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

  Future<void> deleteNotification(String holidayId) async {
    final url = Uri.parse(
        'http://10.3.0.70:9040/api/Flutter/DeleteNotifications?holidayId=$holidayId');

    // final url = Uri.parse(
    //       'http://10.3.0.70:9042/api/HR/DeleteNotifications?holidayId=$holidayId');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        // Decode the response if needed, e.g., for error checking or messages
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['Status']) {
          print('Delete successful: ${responseData['Message']}');
        } else {
          print('Delete failed: ${responseData['Message']}');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
