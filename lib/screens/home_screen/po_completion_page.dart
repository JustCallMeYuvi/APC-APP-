

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PoCompletionReport extends StatefulWidget {
  const PoCompletionReport({super.key});

  @override
  _PoCompletionReportState createState() => _PoCompletionReportState();
}

class _PoCompletionReportState extends State<PoCompletionReport> {
  List<_ChartData> _outputData = [];
  bool _isLoading = true;
  DateTimeRange? _dateRange;
  ZoomPanBehavior? _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(enablePinching: true, zoomMode: ZoomMode.x);
    _fetchData(); // Initial data fetch with default values
  }

  Future<void> _fetchData({DateTimeRange? dateRange}) async {
    setState(() {
      _isLoading = true;
    });

    String? formattedFromDate = dateRange?.start.toIso8601String().substring(0, 10);
    String? formattedToDate = dateRange?.end.toIso8601String().substring(0, 10);

    String url = 'http://10.3.0.70:9042/api/HR/GetSeOrderDetails';
    if (dateRange != null) {
      url += '?fromDate=$formattedFromDate&toDate=$formattedToDate';
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        print("API Response: ${response.body}");

        if (jsonData.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data found for the selected date range')),
          );
        }

        setState(() {
          _outputData = jsonData.map((item) {
            final date = item['crReqDate'] ?? 'Unknown Date';
            final output = item['output'] != null
                ? double.tryParse(item['output'].toString()) ?? 0.0
                : 0.0;
            return _ChartData(date, output);
          }).toList();

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load PO Completion report');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching data: $error");
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      _fetchData(dateRange: _dateRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PO Completion Report'),
        backgroundColor: Colors.lightGreen,
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.calendarAlt),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Charts",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    _buildAreaChart(),
                    SizedBox(height: 16),
                    _buildBarChart(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAreaChart() {
    return Container(
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        title: ChartTitle(text: 'Stacked Area Chart'),
        zoomPanBehavior: _zoomPanBehavior, // Added zoom and pan behavior
        series: <CartesianSeries<dynamic, dynamic>>[
          StackedAreaSeries<_ChartData, String>(
            dataSource: _outputData,
            xValueMapper: (_ChartData data, _) => data.category,
            yValueMapper: (_ChartData data, _) => data.value,
            color: Colors.blue.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        title: ChartTitle(text: 'Bar Chart'),
        zoomPanBehavior: _zoomPanBehavior, // Added zoom and pan behavior
        series: <CartesianSeries<dynamic, dynamic>>[
          BarSeries<_ChartData, String>(
            dataSource: _outputData,
            xValueMapper: (_ChartData data, _) => data.category,
            yValueMapper: (_ChartData data, _) => data.value,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.category, this.value);

  final String category;
  final double value;
}
