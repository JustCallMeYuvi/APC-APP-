import 'package:animated_movies_app/overtime/overtime_bloc/overtime_event.dart';
import 'package:animated_movies_app/overtime/overtime_services/overtime_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_movies_app/screens/home_screen/emp_count_screen.dart';
import 'package:animated_movies_app/screens/home_screen/over_time_screen.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';

import '../../overtime/overtime_bloc/overtime_bloc.dart';

class InformationOfEmployeesScreen extends StatefulWidget {
  final LoginModelApi userData;

  const InformationOfEmployeesScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<InformationOfEmployeesScreen> createState() =>
      _InformationOfEmployeesScreenState();
}

class _InformationOfEmployeesScreenState
    extends State<InformationOfEmployeesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    // Tab(text: 'Emp Punch'),
    Tab(text: 'Over Time'),
    Tab(text: 'Emp Count'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        /// ---------------- TAB BAR ----------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.lightGreen.shade200,
              child: TabBar(
                tabAlignment: TabAlignment.start,
                controller: _tabController,
                tabs: _tabs,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        /// ---------------- TAB VIEW ----------------
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              /// Emp Punch
              // EmpPunch(userData: widget.userData),

              /// ✅ Over Time WITH Bloc + Service + Correct Event
              BlocProvider(
                create: (_) => OverTimeBloc(
                  OverTimeService(),
                )..add(
                    FetchOverTime(
                      type: OtType.overall, // ✅ enum
                      fromDate: DateTime.now()
                          .subtract(const Duration(days: 7)), // ✅ valid date
                      toDate: DateTime.now(), // ✅ valid date
                    ),
                  ),
                child: OverTimeScreen(userData: widget.userData),
              ),

              /// Emp Count
              EmpCountScreen(userData: widget.userData),
            ],
          ),
        ),
      ],
    );
  }
}
