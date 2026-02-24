import 'package:animated_movies_app/MNT_Modules/Panels_Screen/panels_due_bloc.dart';
import 'package:animated_movies_app/MNT_Modules/Panels_Screen/panels_due_event.dart';
import 'package:animated_movies_app/MNT_Modules/Panels_Screen/panels_due_state.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PanelsDueScreen extends StatefulWidget {
  final LoginModelApi userData;
  const PanelsDueScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<PanelsDueScreen> createState() => _PanelsDueScreenState();
}

class _PanelsDueScreenState extends State<PanelsDueScreen> {
  late PanelsDueBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = PanelsDueBloc()..add(FetchPanelsDue());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _bloc,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: BlocBuilder<PanelsDueBloc, PanelsDueState>(
          builder: (context, state) {
            if (state is PanelsDueLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PanelsDueError) {
              return Center(child: Text(state.message));
            }

            if (state is PanelsDueLoaded) {
              final summary = state.data.summary;
              final panels = state.data.duePanels;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 SUMMARY CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _summaryItem(
                            icon: Icons.dashboard,
                            title: 'Total',
                            value: summary.totalPanels,
                          ),
                          _summaryItem(
                            icon: Icons.today,
                            title: 'Due',
                            value: summary.dueToday,
                          ),
                          _summaryItem(
                            icon: Icons.schedule,
                            title: 'Upcoming',
                            value: summary.upcoming,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Due Panels',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),

                    const SizedBox(height: 12),

                    /// 🔹 DUE PANELS LIST
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: panels.length,
                      itemBuilder: (context, index) {
                        final panel = panels[index];

                        final bool isOverdue =
                            panel.daysCompleted > panel.intervalDays;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    panel.dBName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isOverdue
                                          ? Colors.red.shade100
                                          : Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isOverdue ? 'Overdue' : 'Due',
                                      style: TextStyle(
                                        color: isOverdue
                                            ? Colors.red
                                            : Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              _infoRow('Panel ID', panel.powerPanelId),
                              _infoRow('Plant', panel.plant),
                              _infoRow(
                                  'Interval', '${panel.intervalDays} days'),
                              _infoRow(
                                  'Completed', '${panel.daysCompleted} days'),
                              // _infoRow('Last Scan', panel.lastCreatedDate),
                              _infoRow(
                                'Last Scan',
                                panel.lastCreatedDate.replaceAll('T', ' '),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _summaryItem(
      {required IconData icon, required String title, required int value}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 FIXED WIDTH TITLE
          SizedBox(
            width: 120, // adjust based on longest title
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),

          /// 🔹 COLON
          const Text(
            ":",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),

          const SizedBox(width: 8),

          /// 🔹 VALUE (aligned properly)
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
