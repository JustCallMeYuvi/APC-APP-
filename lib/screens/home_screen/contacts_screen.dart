import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'chat_screen.dart';

class ContactsPage extends StatefulWidget {
  final LoginModelApi userData; // Add this line

  ContactsPage({
    required this.userData,
  });

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Map<String, dynamic>> contacts = [];

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    final url =
        'http://10.3.0.70:9040/api/Flutter/GetUserDetails?empNo=${widget.userData.empNo}';
    print('Fetching contacts from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          contacts = data
              .map((contact) => {
                    'name': contact['EMP_NAME'],
                    'id': contact['ID'],
                    'empNo': contact['EMP_NO'], // Include EMP_NO for chat data
                  })
              .toList();
        });
      } else {
        print('Failed to load contacts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching contacts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Contacts'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: UiConstants.backgroundGradient.gradient,
        ),
        child: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 5.0, horizontal: 16.0), // Adjusted vertical padding
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0), // Adjusted content padding
                    leading: ClipOval(
                      child: Image.network(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRB36jHMpxnpuXsJjEe9F5AzGtu45KsL87N9Q&s',
                        width: 50, // Adjust width as needed
                        height: 50, // Adjust height as needed
                        fit: BoxFit
                            .cover, // Ensure the image covers the oval shape
                      ),
                    ),
                    title: Text(
                      contacts[index]['name'],
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      contacts[index]['empNo'],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            contactName: contacts[index]['name'],
                            // senderId: 1, // Replace with actual sender ID
                            senderId: int.parse(widget.userData
                                .empNo), // Ensure empNo is parsed as int
                            // receiverId: contacts[index]['id'], // Use contact's ID
                            receiverId: int.parse(contacts[index][
                                'empNo']), // Parse empNo to int before assigning
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(
                    color: Colors.white, // Change the color as needed
                    thickness: 1, // Change the thickness as needed
                    indent: 1,
                    endIndent: 1,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
