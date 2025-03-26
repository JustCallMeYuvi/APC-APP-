// below is filter data
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

List<dynamic> globalRawData = []; // Global storage for response data
Future<List<StatusReport>> fetchVehicleTracking() async {
  // const String apiUrl = 'http://10.3.0.208:8084/api/GMS/status-report';
  var apiUrl = '${ApiHelper.maxkingGMSUrl}status-report';
  print(apiUrl);
  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Parse the response body and group by status
      // final List<dynamic> rawData = json.decode(response.body);
      globalRawData = json.decode(response.body); // Store raw data globally
      final Map<int, int> groupedData = {};

      // Group data by status and sum the totalStatusCount
      // for (var entry in rawData) {
      // Group data by status and sum the totalStatusCount
      for (var entry in globalRawData) {
        final int status = int.tryParse(entry['status'].toString()) ??
            0; // Safely parse status
        final int totalStatusCount =
            int.tryParse(entry['totalStatusCount'].toString()) ??
                0; // Safely parse totalStatusCount

        groupedData[status] = totalStatusCount;
      }

      // Convert the grouped data into a list of StatusReport objects
      return groupedData.entries
          .map((entry) => StatusReport(
                status: entry.key,
                totalStatusCount: entry.value,
              ))
          .toList();
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching vehicle tracking data: $e');
    throw Exception('Error fetching vehicle tracking data: $e');
  }
}

class MaxkingGmsCharts extends StatefulWidget {
  const MaxkingGmsCharts({Key? key}) : super(key: key);

  @override
  _MaxkingGmsChartsState createState() => _MaxkingGmsChartsState();
}

class _MaxkingGmsChartsState extends State<MaxkingGmsCharts> {
  late Future<List<StatusReport>> _statusReports;

  final Map<int, String> _statusLabels = {
    // 1: "Main Gate Waiting",
    1: "Fire Gate Waiting",
    2: "FG Entry Waiting",
    3: "FG Out Waiting",
    4: "Fire Gate Out Waiting",
    // 6: "Main Gate Out Waiting",
  };

  final Map<int, Color> _statusColors = {
    1: Colors.blue,
    2: Colors.red,
    3: Colors.green,
    4: Colors.orange,
    5: Colors.purple,
    6: Colors.cyan,
  };

  @override
  void initState() {
    super.initState();
    _statusReports = fetchVehicleTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<StatusReport>>(
        future: _statusReports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          final pieData = _preparePieData(data);

          return SfCircularChart(
            margin: const EdgeInsets.only(top: 50), // Adjusts outer padding
            // title: ChartTitle(text: 'Vehicle Tracking Status'),
            legend: Legend(
                isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: pieData,
                xValueMapper: (ChartData data, _) => data.label,
                yValueMapper: (ChartData data, _) => data.totalStatusCount,
                pointColorMapper: (ChartData data, _) => data.color,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
                explode: true,
                explodeIndex: 0,
                // onPointTap: (ChartPointDetails details) {
                //   final clickedData = pieData[details.pointIndex!];
                //   showDialog(
                //     context: context,
                //     builder: (ctx) => AlertDialog(
                //       title: Text(clickedData.label),
                //       content: Text(
                //           'Total Status Count: ${clickedData.totalStatusCount}'),
                //       actions: [
                //         TextButton(
                //           onPressed: () => Navigator.of(ctx).pop(),
                //           child: const Text('Close'),
                //         ),
                //       ],
                //     ),
                //   );
                // },

                onPointTap: (ChartPointDetails details) {
                  final clickedData = pieData[details.pointIndex!];
                  final matchedVehicles = globalRawData
                      .where((entry) =>
                          int.tryParse(entry['status'].toString()) ==
                          clickedData.status)
                      .map((entry) => entry['vehicleNumber'])
                      .toList();

                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      //title: Text(clickedData.label),
                      title: Text(
                        clickedData.label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Makes the text bold
                        ),
                      ),

                      content: Text(
                        'Count: ${clickedData.totalStatusCount}\nVehicles: ${matchedVehicles.join(', ')}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<ChartData> _preparePieData(List<StatusReport> data) {
    return data
        .where((report) =>
            _statusLabels.containsKey(report.status)) // Filter known statuses
        .map((report) {
      final label = _statusLabels[report.status]!;
      final color = _statusColors[report.status]!;
      return ChartData(label, report.totalStatusCount, color, report.status);
    }).toList();
  }
}

class ChartData {
  final String label;
  final int totalStatusCount;
  final Color color;
  final int status;

  ChartData(this.label, this.totalStatusCount, this.color, this.status);
}

class StatusReport {
  final int status;
  final int totalStatusCount;

  StatusReport({
    required this.status,
    required this.totalStatusCount,
  });

  // factory StatusReport.fromJson(Map<String, dynamic> json) => StatusReport(
  //       status: json['status'],
  //       totalStatusCount: json['totalStatusCount'],
  //     );

  factory StatusReport.fromJson(Map<String, dynamic> json) => StatusReport(
        status: int.tryParse(json['status'].toString()) ??
            0, // Safely parse status to int
        totalStatusCount: int.tryParse(json['totalStatusCount'].toString()) ??
            0, // Safely parse totalStatusCount
      );
}
