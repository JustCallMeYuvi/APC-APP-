import 'package:animated_movies_app/screens/home_screen/widgets/notification.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailsScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final isRead = notification.readStatus == 1;

    return Scaffold(
      backgroundColor: const Color(0xfff2f4f8),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Notification Details"),
        backgroundColor: Colors.lightGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// Main Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title
                    Text(
                      notification.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isRead
                            ? Colors.grey.shade200
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isRead ? "Read" : "Unread",
                        style: TextStyle(
                          color: isRead ? Colors.grey.shade700 : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Divider
                    const Divider(),

                    const SizedBox(height: 10),

                    /// Message Section
                    const Text(
                      "Message",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// Info Section
                    // const Divider(),

                    // const SizedBox(height: 15),

                    // Row(
                    //   children: [
                    //     const Icon(Icons.qr_code, color: Colors.grey),
                    //     const SizedBox(width: 10),
                    //     Text(
                    //       "Barcode : ${notification.barcode}",
                    //       style: const TextStyle(fontSize: 15),
                    //     ),
                    //   ],
                    // ),

                    const SizedBox(height: 15),

                    // Row(
                    //   children: [
                    //     const Icon(Icons.access_time, color: Colors.grey),
                    //     const SizedBox(width: 10),
                    //     Text(
                    //       notification.createdDate != null
                    //           ? DateFormat('dd MMM yyyy  •  hh:mm a')
                    //               .format(notification.createdDate!)
                    //           : "No time available",
                    //       style: const TextStyle(fontSize: 15),
                    //     ),
                    //   ],
                    // )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
