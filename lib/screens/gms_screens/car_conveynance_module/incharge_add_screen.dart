import 'package:animated_movies_app/screens/gms_screens/car_conveynance_module/add_incharge_screen.dart';
import 'package:animated_movies_app/screens/gms_screens/car_conveynance_module/delete_incharge_screen.dart';
import 'package:animated_movies_app/screens/gms_screens/car_conveynance_module/edit_incharge_screen.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';

class InchargeAddScreen extends StatefulWidget {
  final LoginModelApi userData;
  const InchargeAddScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _InchargeAddScreenState createState() => _InchargeAddScreenState();
}

class _InchargeAddScreenState extends State<InchargeAddScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Add'),
    Tab(text: 'Update'),
    Tab(text: 'Delete'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10), // Top spacing if needed
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors
                    .lightBlue.shade100, // Background color for the tab bar
                child: TabBar(
                  // tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: _tabController,
                  tabs: myTabs,
                  isScrollable: false,
                  indicator: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AddInchargeScreen(userData: widget.userData),
                EditInchargeScreen(userData: widget.userData),
                DeleteInchargeScreen(userData: widget.userData),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
