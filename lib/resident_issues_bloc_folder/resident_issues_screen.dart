import 'package:animated_movies_app/resident_issues_bloc_folder/chart_data_complaints_model.dart';
import 'package:animated_movies_app/resident_issues_bloc_folder/complaint_bloc.dart';
import 'package:animated_movies_app/resident_issues_bloc_folder/complaint_event.dart';
import 'package:animated_movies_app/resident_issues_bloc_folder/complaint_fetch_api_model.dart';
import 'package:animated_movies_app/resident_issues_bloc_folder/complaint_state.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ResidentIssuesScreen extends StatefulWidget {
  final LoginModelApi userData;

  const ResidentIssuesScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<ResidentIssuesScreen> createState() => _ResidentIssuesScreenState();
}

class _ResidentIssuesScreenState extends State<ResidentIssuesScreen> {
  late ComplaintResidentBloc _complaintBloc;

  @override
  void initState() {
    super.initState();
    _complaintBloc = ComplaintResidentBloc();
    _complaintBloc.add(
      FetchComplaints(widget.userData.empNo.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _complaintBloc,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: BlocConsumer<ComplaintResidentBloc, ComplaintResidentState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.complaints.isEmpty) {
              return const Center(
                child: Text(
                  'No complaints found',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _complaintGraph(state.complaints),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = state.complaints[index];
                      final isOpen = complaint.status == 'Open';

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// LEFT AVATAR
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isOpen
                                    ? Colors.orange.shade100
                                    : Colors.green.shade100,
                                child: Text(
                                  complaint.issueType.isNotEmpty
                                      ? complaint.issueType[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isOpen ? Colors.orange : Colors.green,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// RIGHT CONTENT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// ISSUE TYPE
                                    Text(
                                      complaint.issueType,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    /// DESCRIPTION
                                    Text(
                                      complaint.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    /// STATUS + DATE
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Chip(
                                          label: Text(
                                            complaint.status,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          backgroundColor: isOpen
                                              ? Colors.orange.shade100
                                              : Colors.green.shade100,
                                          labelStyle: TextStyle(
                                            color: isOpen
                                                ? Colors.orange
                                                : Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          complaint.createdDate,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getCategoryColor(String type) {
    switch (type.toUpperCase()) {
      case 'IT':
        return const Color(0xFFB388FF);
      case 'MNT':
        return const Color(0xFF00E5C3);
      case 'ELE':
        return const Color(0xFFFF8A65);
      default:
        return Colors.grey;
    }
  }

  Widget _complaintGraph(List<ComplaintFetchAPIModel> complaints) {
    final Map<String, int> categoryCount = {};

    for (var c in complaints) {
      categoryCount[c.issueType] = (categoryCount[c.issueType] ?? 0) + 1;
    }

    final chartData = categoryCount.entries.map((e) {
      return ComplaintChartData(
        category: e.key,
        count: e.value,
        color: _getCategoryColor(e.key),
      );
    }).toList();

    final total = complaints.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Complaint Boxes',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SfCircularChart(
                  series: <CircularSeries>[
                    DoughnutSeries<ComplaintChartData, String>(
                      dataSource: chartData,
                      xValueMapper: (d, _) => d.category,
                      yValueMapper: (d, _) => d.count,
                      pointColorMapper: (d, _) => d.color,
                      innerRadius: '70%',
                      radius: '90%',
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      total.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Total Complaints',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class _ChartData {
//   final String category;
//   final int count;
//   final Color color;

//   _ChartData({
//     required this.category,
//     required this.count,
//     required this.color,
//   });
// }
