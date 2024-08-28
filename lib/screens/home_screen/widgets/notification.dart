import 'dart:convert';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// class NotificationsScreen extends StatefulWidget {
//   final LoginModelApi userData;
//   const NotificationsScreen({super.key, required this.userData});

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   List<NotificationModel> notificationList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchNotifications(widget.userData.empNo);
//   }

//   // @override
//   // void didChangeDependencies() {
//   //   super.didChangeDependencies();
//   //   fetchNotifications(
//   //       widget.userData.empNo); // Fetch each time the screen becomes visible
//   // }

//   Future<void> fetchNotifications(String empNo) async {
//     final url = 'http://10.3.0.70:9042/api/HR/get-notifications/$empNo';

//     print('Fetching notifications from URL: $url');

//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       List<dynamic> jsonResponse = json.decode(response.body);

//       print('Fetched Notification data: $jsonResponse');

//       setState(() {
//         notificationList = jsonResponse
//             .map((data) => NotificationModel.fromJson(data))
//             .toList();
//       });
//     } else {
//       print(
//           'Failed to load notifications. Status code: ${response.statusCode}');
//       throw Exception('Failed to load notifications');
//     }
//   }

//  Future<void> markAsRead(int id) async {
//   final url = Uri.parse('http://10.3.0.70:9040/api/Flutter/mark-as-read');
//   print('MARK AS READ URL: $url');

//   try {
//     final response = await http.post(
//       url,
//       headers: <String, String>{
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({'id': id}), // Use 'id' instead of 'barcode'
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> responseData = json.decode(response.body);
//       if (responseData['Message'] == 'Notification marked as read successfully.') {
//         print('Marked as read successfully');
//         setState(() {
//           final index = notificationList
//               .indexWhere((notification) => notification.id == id); // Find by id
//           if (index != -1) {
//             notificationList[index].readStatus = 1; // Update read status
//           }
//         });
//       } else {
//         print('Failed to mark as read: ${responseData['Message']}');
//       }
//     } else {
//       print('Request failed with status: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error marking notification as read: $e');
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notifications'),
//         backgroundColor: Colors.lightGreen,
//       ),
//       body: Container(
//         height: size.height,
//         width: size.width,
//         decoration: BoxDecoration(
//           gradient: UiConstants.backgroundGradient.gradient,
//         ),
//         child: notificationList.isEmpty
//             ? Center(
//                 child: Text(
//                   'No Notifications',
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               )
//             : ListView.builder(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
//                 itemCount: notificationList.length,
//                 itemBuilder: (context, index) {
//                   final notifyDetails = notificationList[index];

//                   return Dismissible(
//                     key: UniqueKey(),
//                     direction: DismissDirection.endToStart,
//                     confirmDismiss: (direction) async {
//                       return await showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AlertDialog(
//                             title: Text('Confirm Deletion'),
//                             content: Text(
//                                 'Are you sure you want to delete this notification?'),
//                             actions: <Widget>[
//                               TextButton(
//                                 onPressed: () =>
//                                     Navigator.of(context).pop(false),
//                                 child: Text('Cancel'),
//                               ),
//                               TextButton(
//                                 onPressed: () =>
//                                     Navigator.of(context).pop(true),
//                                 child: Text('Delete'),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     },
//                     onDismissed: (direction) {
//                       deleteNotification(notifyDetails.barcode);
//                       setState(() {
//                         notificationList.removeAt(index);
//                       });
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text('Notification dismissed'),
//                       ));
//                     },
//                     background: Container(
//                       color: Colors.red,
//                       alignment: Alignment.centerRight,
//                       padding: EdgeInsets.symmetric(horizontal: 20),
//                       child: Icon(
//                         Icons.delete,
//                         color: Colors.white,
//                       ),
//                     ),
//                     child: buildNotificationCard(
//                       icon: Icons.notifications_active,
//                       title: notifyDetails.name,
//                       subtitle: notifyDetails.body,
//                       isRead: notifyDetails.readStatus == 1, // Check if read
//                       notifyDetails:
//                           notifyDetails, // Pass notifyDetails to the card builder
//                     ),
//                   );
//                 },
//               ),
//       ),
//     );
//   }

//   Widget buildNotificationCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required bool isRead,
//     required NotificationModel notifyDetails, // Add this parameter
//   }) {
//     return Card(
//       color: isRead
//           ? Colors.grey[700]
//           : Colors.grey[800], // Different colors for read/unread
//       margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
//       elevation: 5,
//       child: Stack(
//         children: [
//           ListTile(
//             leading: Icon(
//               icon,
//               color: Colors.white,
//               size: 30,
//             ),
//             title: Text(
//               title,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             subtitle: Text(
//               subtitle,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//               ),
//             ),
//             onTap: () {
//               // Handle notification tap
//               markAsRead(notifyDetails.id); // Call markAsRead when tapped
//             },
//           ),
//           if (!isRead) // Only show the icon if the notification is read
//             Positioned(
//               right: 8,
//               top: 8,
//               child: Icon(
//                 Icons.circle,
//                 color: Colors.green,
//                 size: 20,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Future<void> deleteNotification(String barcode) async {
//     final url = Uri.parse(
//         'http://10.3.0.70:9040/api/Flutter/DeleteNotifications?barcode=$barcode');

//     try {
//       final response = await http.delete(url);
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
//         if (responseData['Status']) {
//           print('Delete successful: ${responseData['Message']}');
//         } else {
//           print('Delete failed: ${responseData['Message']}');
//         }
//       } else {
//         print('Request failed with status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error deleting notification: $e');
//     }
//   }
// }

class NotificationsScreen extends StatefulWidget {
  final LoginModelApi userData;
  const NotificationsScreen({super.key, required this.userData});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Stream<List<NotificationModel>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _notificationsStream = _getNotificationsStream(widget.userData.empNo);
  }

  Stream<List<NotificationModel>> _getNotificationsStream(String empNo) async* {
    while (true) {
      final notifications = await _fetchNotifications(empNo);
      yield notifications;
      await Future.delayed(Duration(seconds: 5)); // Poll every 5 seconds
    }
  }

  // Future<List<NotificationModel>> _fetchNotifications(String empNo) async {
  //   final url = 'http://10.3.0.70:9042/api/HR/get-notifications/$empNo';
  //   final response = await http.get(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonResponse = json.decode(response.body);

  //     // Check if the response is empty and return an empty list
  //     if (jsonResponse.isEmpty) {
  //       return [];
  //     }

  //     return jsonResponse
  //         .map((data) => NotificationModel.fromJson(data))
  //         .toList();
  //   } else {
  //     throw Exception('Failed to load notifications');
  //   }
  // }

  Future<List<NotificationModel>> _fetchNotifications(String empNo) async {
    final url = 'http://10.3.0.70:9042/api/HR/get-notifications/$empNo';
    final response = await http.get(Uri.parse(url));
    print(url);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => NotificationModel.fromJson(data))
          .toList();
    } else if (response.statusCode == 404) {
      // Handle the case where no notifications are found
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['message'] == 'No notifications found.') {
        return []; // Return an empty list if no notifications are found
      } else {
        throw Exception('Failed to load notifications');
      }
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.lightGreen,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No Notifications',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final notificationList = snapshot.data!;

          return Container(
            height: size.height,
            width: size.width,
            decoration: UiConstants.backgroundGradient,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              itemCount: notificationList.length,
              itemBuilder: (context, index) {
                final notifyDetails = notificationList[index];

                return Dismissible(
                  key: UniqueKey(),
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
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    _deleteNotification(notifyDetails.id);
                    setState(() {
                      notificationList.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Notification Deleted'),
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
                    title: notifyDetails.name,
                    subtitle: notifyDetails.body,
                    isRead: notifyDetails.readStatus == 1,
                    notifyDetails: notifyDetails,
                    notificationList:
                        notificationList, // Pass the notificationList
                    onMarkAsRead: () {
                      _markAsRead(notifyDetails.id,
                          notificationList); // Update this line
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Future<void> _deleteNotification(int id) async {
  //   // final url = Uri.parse(
  //   //     'http://10.3.0.70:9040/api/Flutter/DeleteNotifications?barcode=$barcode');
  //   final url = Uri.parse(
  //       'http://10.3.0.70:9042/api/HR/Notification_Delete/$id');
  //   try {
  //     final response = await http.delete(url);
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       if (responseData['Status']) {
  //         print('Delete successful: ${responseData['Message']}');
  //       } else {
  //         print('Delete failed: ${responseData['Message']}');
  //       }
  //     } else {
  //       print('Request failed with status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error deleting notification: $e');
  //   }
  // }

  Future<void> _deleteNotification(int id) async {
    final url =
        Uri.parse('http://10.3.0.70:9042/api/HR/Notification_Delete/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Log the entire response for debugging
        print('Response data: $responseData');

        final status = responseData['Status'];
        if (status is bool) {
          if (status) {
            print('Delete successful: ${responseData['Message']}');
          } else {
            print('Delete failed: ${responseData['Message']}');
          }
        } else {
          print('Unexpected response format: Status is not a boolean');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Widget buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isRead,
    required NotificationModel notifyDetails,
    required List<NotificationModel> notificationList, // Add this parameter
    required VoidCallback onMarkAsRead,
  }) {
    return Card(
      color: isRead ? Colors.grey[700] : Colors.grey[800],
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      elevation: 5,
      child: Stack(
        children: [
          ListTile(
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
            // onTap: () {
            //   _markAsRead();
            // },
            onTap: () {
              _markAsRead(
                  notifyDetails.id, notificationList); // Pass both parameters
            },
          ),
          if (!isRead)
            Positioned(
              right: 8,
              top: 8,
              child: Icon(
                Icons.circle,
                color: Colors.green,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _markAsRead(
      int id, List<NotificationModel> notificationList) async {
    final url = Uri.parse('http://10.3.0.70:9042/api/HR/markAsRead/$id');

    // Include the ID in the URL
    print(url);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}), // You can send an empty body if needed
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['message'] == 'Notification marked as read.') {
          setState(() {
            final index = notificationList
                .indexWhere((notification) => notification.id == id);
            if (index != -1) {
              notificationList[index].readStatus = 1;
            }
          });
        } else {
          print('Failed to mark as read: ${responseData['message']}');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}

class NotificationModel {
  int id; // Change to int
  String? title;
  String body;
  String? deviceToken;
  String barcode;
  String name;
  int readStatus;

  NotificationModel({
    required this.id, // Change to required
    this.title,
    required this.body,
    this.deviceToken,
    required this.barcode,
    required this.name,
    required this.readStatus,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'], // Change to id
      title: json['title'],
      body: json['body'],
      deviceToken: json['deviceToken'],
      barcode: json['barcode'],
      name: json['name'],
      readStatus: json['readStatus'],
    );
  }
}
