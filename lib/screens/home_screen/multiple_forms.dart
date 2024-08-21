import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/screens/home_screen/OTScreenPage.dart';
import 'package:animated_movies_app/screens/home_screen/miss_punches_screen.dart';
import 'package:animated_movies_app/screens/home_screen/token_screen.dart';
import 'package:animated_movies_app/screens/home_screen/warnings_screen.dart';
import 'package:flutter/material.dart';
import 'leaves_details.dart'; // Ensure this path is correct
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';

class MultipleForms extends StatefulWidget {
  final LoginModelApi userData;
  MultipleForms({Key? key, required this.userData}) : super(key: key);

  @override
  _MultipleFormsState createState() => _MultipleFormsState();
}

class _MultipleFormsState extends State<MultipleForms> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forms Page'),
        backgroundColor: Colors.lightGreen,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient:
              UiConstants.backgroundGradient.gradient, // Add your gradient here
        ),
        child: SafeArea(
          child: DefaultTabController(
            length: 3, // Number of tabs
            child: Column(
              children: [
                // TabBar placed below AppBar
                PreferredSize(
                  preferredSize:
                      Size.fromHeight(50.0), // Adjust height as needed
                  child: Container(
                    child: TabBar(
                      isScrollable: true, // Allow scrolling for wider tabs
                      tabs: [
                        Tab(text: "HR"),
                        Tab(text: "Test 1"),
                        Tab(text: "Test 2"),
                        // Tab(text: "Test 3"),
                        // Tab(text: "Test 4"),
                        // Tab(text: "Test 5"),
                      ],
                      indicatorColor: Colors.blue,
                      labelColor: Colors.red,
                      unselectedLabelColor: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      // HR Tab with buttons
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.count(
                          crossAxisCount: 3, // Number of columns
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          shrinkWrap: true,
                          children: [
                            _buildGridButton(
                              context,
                              icon: Icons.calendar_today,
                              label: 'Leaves',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LeavesDetails(
                                      userData: widget.userData,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildGridButton(
                              context,
                              icon: Icons.access_time,
                              label: 'Miss Punch',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MissPunchesScreen(
                                        userData: widget.userData),
                                  ),
                                );
                              },
                            ),
                            _buildGridButton(
                              context,
                              icon: Icons.access_alarm,
                              label: 'OT',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OTScreenPage(
                                      userData: widget.userData,
                                    ),
                                  ),
                                ); // Navigate to OT Page
                              },
                            ),
                            _buildGridButton(
                              context,
                              icon: Icons.schedule,
                              label: 'Notify Token',
                              onPressed: () {
                                // Navigate to Current Shift Page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TokenScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildGridButton(
                              context,
                              icon: Icons.warning,
                              label: 'Warnings',
                              onPressed: () {
                                // Navigate to Warnings Page
                               Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WarningsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Content for Test 1
                      Center(
                        child: Text('Test 1 Content',
                            style: TextStyle(fontSize: 24)),
                      ),
                      // Content for Test 2
                      Center(
                        child: Text('Test 2 Content',
                            style: TextStyle(fontSize: 24)),
                      ),
                      // Content for Test 3
                      // Center(
                      //   child: Text('Test 3 Content',
                      //       style: TextStyle(fontSize: 24)),
                      // ),
                      // // Content for Test 4
                      // Center(
                      //   child: Text('Test 4 Content',
                      //       style: TextStyle(fontSize: 24)),
                      // ),
                      // // Content for Test 5
                      // Center(
                      //   child: Text('Test 5 Content',
                      //       style: TextStyle(fontSize: 24)),
                      // ),
                    ],
                  ),
                ),
              ],
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
          // color: Colors.lightGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
