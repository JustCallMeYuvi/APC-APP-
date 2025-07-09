import 'package:animated_movies_app/screens/gms_screens/assembly_output_page.dart';
import 'package:animated_movies_app/screens/gms_screens/order_info_page.dart';
import 'package:animated_movies_app/screens/gms_screens/production_output_module.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';

class BussinessInfoPage extends StatefulWidget {
  final LoginModelApi userData;

  const BussinessInfoPage({Key? key, required this.userData}) : super(key: key);

  @override
  _BussinessInfoPageState createState() => _BussinessInfoPageState();
}

class _BussinessInfoPageState extends State<BussinessInfoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Order Info'),
    Tab(text: 'Production Reports'),
    Tab(text: 'Assembly Output'),
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
    return DefaultTabController(
      length: myTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 15), // Optional top spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors
                    .lightGreen.shade200, // Background color of the tab bar
                child: TabBar(
                  tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: _tabController,
                  tabs: myTabs,
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicator: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OrderInfoPage(userData: widget.userData),
                ProductionReportsModule(userData: widget.userData),
                AssemblyOutputPage(userData: widget.userData),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
