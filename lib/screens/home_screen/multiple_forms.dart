// import 'package:animated_movies_app/constants/ui_constant.dart';
// import 'package:animated_movies_app/screens/home_screen/OTScreenPage.dart';
// import 'package:animated_movies_app/screens/home_screen/efficiency_report_page.dart';
// import 'package:animated_movies_app/screens/home_screen/miss_punches_screen.dart';
// import 'package:animated_movies_app/screens/home_screen/po_completion_page.dart';
// import 'package:animated_movies_app/screens/home_screen/rft_report_page.dart';
// import 'package:animated_movies_app/screens/home_screen/target_output_report_page.dart';
// import 'package:animated_movies_app/screens/home_screen/token_screen.dart';
// import 'package:animated_movies_app/screens/home_screen/warnings_screen.dart';
// import 'package:flutter/material.dart';
// import 'leaves_details.dart'; // Ensure this path is correct
// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';

// class MultipleForms extends StatefulWidget {
//   final LoginModelApi userData;
//   MultipleForms({Key? key, required this.userData}) : super(key: key);

//   @override
//   _MultipleFormsState createState() => _MultipleFormsState();
// }

// class _MultipleFormsState extends State<MultipleForms> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Forms Page'),
//         backgroundColor: Colors.lightGreen,
//         elevation: 0,
//       ),
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient:
//               UiConstants.backgroundGradient.gradient, // Add your gradient here
//         ),
//         child: SafeArea(
//           child: DefaultTabController(
//             length: 3, // Number of tabs
//             child: Column(
//               children: [
//                 // TabBar placed below AppBar
//                 const PreferredSize(
//                   preferredSize:
//                       Size.fromHeight(50.0), // Adjust height as needed
//                   child: TabBar(
//                     isScrollable: true, // Allow scrolling for wider tabs
//                     tabs: [
//                       Tab(text: "Production"),
//                       Tab(text: "Quality"),
//                       Tab(text: "HR"),
//                       // Tab(text: "Test 3"),
//                       // Tab(text: "Test 4"),
//                       // Tab(text: "Test 5"),
//                     ],
//                     indicatorColor: Colors.blue,
//                     labelColor: Colors.red,
//                     unselectedLabelColor: Colors.white,
//                   ),
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     children: <Widget>[
//                       // Center(
//                       //   child:
//                       //       Text('Producation', style: TextStyle(fontSize: 24)),
//                       // ),

//                       // Production Tab with buttons
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: GridView.count(
//                           crossAxisCount: 3, // Number of columns
//                           crossAxisSpacing: 8.0,
//                           mainAxisSpacing: 8.0,
//                           shrinkWrap: true,
//                           children: [
//                             _buildGridButton(
//                               context,
//                               icon: Icons.auto_graph_sharp,
//                               label: 'Target Output',
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         const TargetOutputReportPage(),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _buildGridButton(
//                               context,
//                               icon: Icons.graphic_eq_sharp,
//                               label: 'Efficiency Report',
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         const EfficiencyReportPage(),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _buildGridButton(
//                               context,
//                               icon: Icons.graphic_eq_sharp,
//                               label: 'RFT Report',
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => const RftReportPage(),
//                                   ),
//                                 ); // Navigate to OT Page
//                               },
//                             ),
//                             _buildGridButton(
//                               context,
//                               icon: Icons.ac_unit,
//                               label: 'PO Report',
//                               onPressed: () {
//                                 // Navigate to Current Shift Page
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         const PoCompletionReport(),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                       // // Content for Test 1
//                       const Center(
//                         child: Text('Quality', style: TextStyle(fontSize: 24)),
//                       ),
//                       // Content for Test 2
//                       // HR Tab with buttons
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: GridView.count(
//                           crossAxisCount: 3, // Number of columns
//                           crossAxisSpacing: 8.0,
//                           mainAxisSpacing: 8.0,
//                           shrinkWrap: true,
//                           children: [
//                             _buildGridButton(
//                               context,
//                               icon: Icons.calendar_today,
//                               label: 'Leaves',
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => LeavesDetails(
//                                       userData: widget.userData,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _buildGridButton(
//                               context,
//                               icon: Icons.access_time,
//                               label: 'Punch Details',
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => PunchDetailsScreen(
//                                         userData: widget.userData),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _buildGridButton(
//                               context,
//                               icon: Icons.access_alarm,
//                               label: 'OT',
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => OTScreenPage(
//                                       userData: widget.userData,
//                                     ),
//                                   ),
//                                 ); // Navigate to OT Page
//                               },
//                             ),
//                             _buildGridButton(
//                               context,
//                               icon: Icons.schedule,
//                               label: 'Notify Token',
//                               onPressed: () {
//                                 // Navigate to Current Shift Page
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => TokenScreen(
//                                         userData: widget.userData,
//                                         empDetailsList: []),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _buildGridButton(
//                               context,
//                               icon: Icons.warning,
//                               label: 'Warnings',
//                               onPressed: () {
//                                 // Navigate to Warnings Page
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         const WarningsScreen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                       // Content for Test 3
//                       // Center(
//                       //   child: Text('Test 3 Content',
//                       //       style: TextStyle(fontSize: 24)),
//                       // ),
//                       // // Content for Test 4
//                       // Center(
//                       //   child: Text('Test 4 Content',
//                       //       style: TextStyle(fontSize: 24)),
//                       // ),
//                       // // Content for Test 5
//                       // Center(
//                       //   child: Text('Test 5 Content',
//                       //       style: TextStyle(fontSize: 24)),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGridButton(BuildContext context,
//       {required IconData icon,
//       required String label,
//       required VoidCallback onPressed}) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         decoration: BoxDecoration(
//           // color: Colors.lightGreen,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: Colors.white),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/model/get_emp_details.dart';
import 'package:animated_movies_app/model/user_access.dart';
import 'package:animated_movies_app/screens/home_screen/api_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:http/http.dart' as http; // Add this import for HTTP requests

class MultipleForms extends StatefulWidget {
  final LoginModelApi userData;

  MultipleForms({Key? key, required this.userData}) : super(key: key);

  @override
  _MultipleFormsState createState() => _MultipleFormsState();
}

class _MultipleFormsState extends State<MultipleForms> {
  List<UserAccess> userAccessList = [];

  List<GetEmpDetails> empDetailsList = [];
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    // fetchData(widget.userData.empNo);
    // fetchUserAccess();
    fetchData(widget.userData.empNo).then((_) {
      fetchUserAccess();
    });
  }

// Future<void> fetchUserAccess() async {
//   // Ensure empDetailsList is populated first
//   if (empDetailsList.isNotEmpty) {
//     try {
//       // Safely access the first element of empDetailsList
//       String roleIdStr = empDetailsList.first.useRRole.toString(); // Ensure it's a String first
//       int roleId = int.parse(roleIdStr); // Convert String to int

//       // Debugging: Print the role ID before making the API request
//       print('Role ID: $roleId');
//       print('Emp Role: ${empDetailsList.first.useRRole}');

//       String apiUrl = 'http://10.3.0.70:9042/api/HR/userpersmissions?roleid=$roleId';
//       // Debugging: Print the API URL
//       print('User Access API URL: $apiUrl');

//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         // Print the actual response body to check its structure
//         print('Response body: ${response.body}');

//         // Decode the response body as a List<dynamic>
//         final List<dynamic> responseData = json.decode(response.body);

//         // Check the response structure: we need to inspect what the API actually returns
//         if (responseData.isNotEmpty) {
//           // Debugging: print the response data
//           print('Response Data: $responseData');

//           // If there's a "success" field, check it
//           if (responseData[0].containsKey('success') && responseData[0]['success'] == true) {
//             setState(() {
//               userAccessList = userAccessFromJson(response.body); // Parse userAccess data
//               isLoading = false;
//             });
//             // Debugging: print success message
//             print('User Access Loaded Successfully');
//           } else {
//             setState(() {
//               isLoading = false;
//             });
//             // Handle unsuccessful response (non-successful API result)
//             print('Failed to load user access: ${responseData[0]['message']}');
//           }
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           // Handle the case when responseData is empty
//           print('Response is empty');
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         // Handle unsuccessful HTTP status
//         print('Failed with status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print('Error fetching user access: $e');
//     }
//   } else {
//     print('empDetailsList is empty');
//   }
// }

  Future<void> fetchData(String empNo) async {
    // final url = Uri.parse(
    //     'http://10.3.0.70:9042/api/HR/GetEmpDetails?empNo=${widget.userData.empNo}');

    final url = Uri.parse(
        '${ApiHelper.baseUrl}GetEmpDetails?empNo=${widget.userData.empNo}');

// ${ApiHelper.baseUrl}
    // Debugging: Print the URL
    print('URL: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        // Debugging: Print the raw response body
        print('Response body in multiple forms: ${response.body}');

        setState(() {
          empDetailsList =
              jsonResponse.map((data) => GetEmpDetails.fromJson(data)).toList();

          // Debugging: Print empDetailsList data
          empDetailsList.forEach((detail) {
            print(
                'Emp Detail: ${detail.emPNo}, ${detail.emPName}, ${detail.depTName}, ${detail.position}, ${detail.useRRole}');
          });
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchUserAccess() async {
    // String roleId = empDetailsList.first.useRRole;
    print(empDetailsList.first.useRRole);
    int roleId =
        int.parse(empDetailsList.first.useRRole); // convert String to int
    print(empDetailsList.first.useRRole);

    // String apiUrl =
    //     'http://10.3.0.70:9042/api/HR/userpersmissions?roleid=$roleId';

    String apiUrl = '${ApiHelper.baseUrl}userpersmissions?roleid=$roleId';
    // ${ApiHelper.baseUrl}

    print(apiUrl);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          userAccessList = userAccessFromJson(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load user access');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Forms Page'),
      //   backgroundColor: Colors.lightGreen,
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: UiConstants
                .backgroundGradient.gradient, // Add your gradient here
          ),
          child: SafeArea(
            child: DefaultTabController(
              // length:
              //     userAccessList.length, // Number of tabs based on userAccessList
              length: isLoading
                  ? 1
                  : userAccessList
                      .length, // Adjust length based on loading state
              child: Column(
                children: [
                  // TabBar placed below AppBar
                  PreferredSize(
                    preferredSize:
                        const Size.fromHeight(50.0), // Adjust height as needed
                    child: TabBar(
                      isScrollable: true, // Allow scrolling for wider tabs
                      tabs: isLoading
                          ? [const Tab(text: 'Loading...')] // Show loading tab
                          : userAccessList
                              .map((access) => Tab(text: access.tabName))
                              .toList(),
                      indicatorColor: Colors.blue,
                      labelColor: Colors.red,
                      unselectedLabelColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: isLoading
                          ? [
                              const Center(child: CircularProgressIndicator())
                            ] // Show loading indicator
                          : userAccessList.map((access) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.count(
                                  crossAxisCount: 3, // Number of columns
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  shrinkWrap: true,
                                  children: access.pages.map((page) {
                                    return _buildGridButton(
                                      context,
                                      // icon: Icons
                                      //     .ac_unit, // You can modify to use an appropriate icon
                                      icon: getIconForPage(
                                          page), // Dynamically assign the icon based on page
                                      // icon: iconMapping[page.icon] ?? Icons.help, // Map icon dynamically
                                      label: page.pageName,

                                      // onPressed: () {
                                      //   // Navigate to the corresponding page
                                      //   Navigator.pushNamed(context, page.pageRoute);
                                      // },

                                      // Inside your _buildGridButton method, modify the onPressed function
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ApiDataScreen(
                                              pageName: page.pageName,
                                              // userCode: '70068',
                                              userData: widget.userData,
                                              pageRoute: page
                                                  .pageRoute, // Pass userData
                                              // userName: '70068',
                                              // userCode: '',
                                              // userName: '',
                                            ), // Pass page name to the new screen
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // // JSON serialization methods
  // List<UserAccess> userAccessFromJson(String str) => List<UserAccess>.from(
  //     json.decode(str).map((x) => UserAccess.fromJson(x)));

  // String userAccessToJson(List<UserAccess> data) =>
  //     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}

// class UserAccess {
//   int tabId;
//   String tabName;
//   String tabRoute;
//   String icon;
//   List<Page> pages;

//   UserAccess({
//     required this.tabId,
//     required this.tabName,
//     required this.tabRoute,
//     required this.icon,
//     required this.pages,
//   });

//   factory UserAccess.fromJson(Map<String, dynamic> json) => UserAccess(
//         tabId: json["tabId"],
//         tabName: json["tabName"],
//         tabRoute: json["tabRoute"],
//         icon: json["icon"],
//         pages: List<Page>.from(json["pages"].map((x) => Page.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "tabId": tabId,
//         "tabName": tabName,
//         "tabRoute": tabRoute,
//         "icon": icon,
//         "pages": List<dynamic>.from(pages.map((x) => x.toJson())),
//       };
// }

// class Page {
//   int pageId;
//   String pageName;
//   String pageRoute;

//   Page({
//     required this.pageId,
//     required this.pageName,
//     required this.pageRoute,
//   });

//   factory Page.fromJson(Map<String, dynamic> json) => Page(
//         pageId: json["pageId"],
//         pageName: json["pageName"],
//         pageRoute: json["pageRoute"],
//       );

//   Map<String, dynamic> toJson() => {
//         "pageId": pageId,
//         "pageName": pageName,
//         "pageRoute": pageRoute,
//       };
// }
