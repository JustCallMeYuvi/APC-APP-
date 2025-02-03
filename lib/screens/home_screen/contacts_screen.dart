import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'chat_screen.dart';
import 'package:anim_search_bar/anim_search_bar.dart';

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
  List<Map<String, dynamic>> filteredContacts = [];
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    // final url =
    //     'http://10.3.0.70:9040/api/Flutter/GetUserDetails?empNo=${widget.userData.empNo}';

    // final url =
    //     'http://10.3.0.70:9042/api/HR/GetUserDetails?empNo=${widget.userData.empNo}';
    final url = ApiHelper.getUserDetailsApi(widget.userData.empNo);
    print('Fetching contacts from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // Print the response data
        // print('Response data contacts: $data');
        setState(() {
          contacts = data
              .map((contact) => {
                    // below is 9040 api
                    // 'name': contact['EMP_NAME'],
                    // 'id': contact['ID'],
                    // 'empNo': contact['EMP_NO'], // Include EMP_NO for chat data

                    // below is 9042 api
                    'name': contact['emP_NAME'],
                    'id': contact['id'],
                    'empNo': contact['emP_NO'],
                  })
              .toList();
          filteredContacts = contacts; // Initialize filteredContacts
        });
      } else {
        print('Failed to load contacts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching contacts: $e');
    }
  }

  void filterContacts(String query) {
    List<Map<String, dynamic>> tempContacts = contacts.where((contact) {
      String contactName = contact['name'].toLowerCase();
      String empNo = contact['empNo'].toLowerCase();
      return contactName.contains(query.toLowerCase()) ||
          empNo.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredContacts = tempContacts;
    });
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0.0, right: 10, left: 10),
              child: AnimSearchBar(
                width: MediaQuery.of(context).size.width * 0.8,
                textController: searchController,
                onSuffixTap: () {
                  setState(() {
                    searchController.clear();
                    filterContacts(
                        ''); // Clear filter when suffix icon is tapped
                  });
                },
                onSubmitted: (query) {
                  filterContacts(
                      query); // Apply filter when search is submitted
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                // itemCount: contacts.length,
                itemCount: filteredContacts.length,

                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 16.0), // Adjusted vertical padding
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
                            // contacts[index]['name'],
                            filteredContacts[index]['name'],

                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            // contacts[index]['empNo'],
                            filteredContacts[index]['empNo'],

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
                                  // contactName: contacts[index]['name'],
                                  contactName: filteredContacts[index]['name'],

                                  // senderId: 1, // Replace with actual sender ID
                                  senderId: int.parse(widget.userData
                                      .empNo), // Ensure empNo is parsed as int
                                  // receiverId: contacts[index]['id'], // Use contact's ID
                                  // receiverId: int.parse(contacts[index]['empNo']), // Parse empNo to int before assigning
                                  receiverId: int.parse(filteredContacts[index][
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
          ],
        ),
      ),
    );
  }
}
