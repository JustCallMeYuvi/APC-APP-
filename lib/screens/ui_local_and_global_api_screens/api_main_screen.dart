import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:animated_movies_app/screens/ui_local_and_global_api_screens/add_api_screen.dart';
import 'package:animated_movies_app/screens/ui_local_and_global_api_screens/realtime_api_screen.dart';
import 'package:animated_movies_app/screens/ui_local_and_global_api_screens/local_api_screen.dart';
import 'package:flutter/material.dart';

class ApiMainScreen extends StatefulWidget {
  final LoginModelApi userData;

  const ApiMainScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<ApiMainScreen> createState() => _ApiMainScreenState();
}

class _ApiMainScreenState extends State<ApiMainScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final realtimeKey = GlobalKey<RealtimeApiScreenState>();
  final localKey = GlobalKey<LocalApiScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _addApi() async {
    if (_tabController == null) return;

    final String server = _tabController!.index == 0 ? "RealTime" : "Test";

    final bool? added = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddApiScreen(server: server),
      ),
    );

    if (added == true) {
      if (_tabController!.index == 0) {
        realtimeKey.currentState?.refresh();
      } else {
        localKey.currentState?.refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: AnimatedBuilder(
        animation: _tabController!,
        builder: (context, _) {
          return FloatingActionButton.extended(
            elevation: 6,
            backgroundColor:
                _tabController!.index == 0 ? Colors.green : Colors.blue,
            onPressed: _addApi,
            icon: const Icon(Icons.add),
            label: const Text("Add API"),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔷 HEADER
            // Container(
            //   padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            //   width: double.infinity,
            //   decoration: const BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [
            //         Color(0xff0f2027),
            //         Color(0xff203a43),
            //         Color(0xff2c5364),
            //       ],
            //     ),
            //   ),
            //   child: const Column(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Text(
            //         "API Manager",
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 22,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       SizedBox(height: 4),
            //       Text(
            //         "Manage Local & Realtime APIs",
            //         style: TextStyle(color: Colors.white70),
            //       )
            //     ],
            //   ),
            // ),

            const SizedBox(height: 16),

            /// 🔷 MODERN TABBAR
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                labelPadding: EdgeInsets.zero,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                indicator: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                tabs: const [
                  SizedBox(
                    height: 46,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_done, size: 18),
                          SizedBox(width: 6),
                          Text("Realtime API"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 46,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lan, size: 18),
                          SizedBox(width: 6),
                          Text("Local API"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// 🔷 TAB CONTENT
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  RealtimeApiScreen(key: realtimeKey),
                  LocalApiScreen(key: localKey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
