// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
// import 'package:animated_movies_app/screens/ui_local_and_global_api_screens/local_api_screen.dart';
// import 'package:animated_movies_app/screens/ui_local_and_global_api_screens/realtime_api_screen.dart';
// import 'package:flutter/material.dart';

// class ApiMainScreen extends StatefulWidget {
//   final LoginModelApi userData;

//   const ApiMainScreen({Key? key, required this.userData}) : super(key: key);

//   @override
//   State<ApiMainScreen> createState() => _ApiMainScreenState();
// }

// class _ApiMainScreenState extends State<ApiMainScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         body: SafeArea(
//           child: Column(
//             children: [
//               // 🔹 Custom TabBar (NO AppBar)
//               Container(
//                 margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 6,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: TabBar(
//                   indicatorSize: TabBarIndicatorSize.tab, // 👈 EVEN WIDTH
//                   labelPadding: EdgeInsets.zero, // 👈 NO EXTRA SPACE
//                   labelColor: Colors.white,
//                   unselectedLabelColor: Colors.black87,
//                   indicator: BoxDecoration(
//                     color: Colors.blue,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   tabs: const [
//                     SizedBox(
//                       height: 44,
//                       child: Center(
//                         child: Text(
//                           "Realtime API",
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 44,
//                       child: Center(
//                         child: Text(
//                           "Local API",
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // 🔹 Tab View
//               const Expanded(
//                 child: TabBarView(
//                   children: [
//                     RealtimeApiScreen(),
//                     LocalApiScreen(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:animated_movies_app/screens/ui_local_and_global_api_screens/add_api_screen.dart';
import 'package:animated_movies_app/screens/ui_local_and_global_api_screens/realtime_api_screen.dart';
import 'package:animated_movies_app/screens/ui_local_and_global_api_screens/local_api_screen.dart';

class ApiMainScreen extends StatefulWidget {
  final LoginModelApi userData;

  const ApiMainScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<ApiMainScreen> createState() => _ApiMainScreenState();
}

class _ApiMainScreenState extends State<ApiMainScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // 👇 GLOBAL KEYS
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

  /// ➕ Add API based on selected tab and refresh list
  void _addApi() async {
    if (_tabController == null) return;

    final String server = _tabController!.index == 0 ? "RealTime" : "Test";

    // 👇 WAIT for Add API screen result
    final bool? added = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddApiScreen(server: server),
      ),
    );

    // 👇 REFRESH CURRENT TAB IMMEDIATELY
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
    // Safety guard (prevents LateInitializationError)
    if (_tabController == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      // ➕ ADD API BUTTON (COMMON FOR BOTH TABS)
      floatingActionButton: AnimatedBuilder(
        animation: _tabController!,
        builder: (context, _) {
          return FloatingActionButton(
            backgroundColor:
                _tabController!.index == 0 ? Colors.green : Colors.blue,
            onPressed: _addApi,
            child: const Icon(Icons.add),
          );
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Custom TabBar (NO AppBar)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                tabs: const [
                  SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        "Realtime API",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        "Local API",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  RealtimeApiScreen(key: realtimeKey), // server = RealTime
                  LocalApiScreen(key: localKey), // server = Test
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
