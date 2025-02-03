import 'package:animated_movies_app/api/apis_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EfficiencyReportPage extends StatefulWidget {
  const EfficiencyReportPage({super.key});

  @override
  _EfficiencyReportPageState createState() => _EfficiencyReportPageState();
}

class _EfficiencyReportPageState extends State<EfficiencyReportPage> {
  List<_ChartData> _achievementData = [];
  List<_ChartData> _bonusData = [];
  List<_ChartData> _achieveRateData = [];
  bool _isLoading = true;

  DateTimeRange? _dateRange;

  bool _isMaximized = false;
  String? _maximizedChartTitle;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Initial data fetch with default values
  }

  Future<void> _fetchData({DateTimeRange? dateRange}) async {
    setState(() {
      _isLoading = true;
    });

    // String? formattedFromDate =
    //     dateRange?.start.toIso8601String().substring(0, 10);
    // String? formattedToDate = dateRange?.end.toIso8601String().substring(0, 10);

    // String url = 'http://10.3.0.70:9042/api/HR/efficiency-report';
    // if (dateRange != null) {
    //   url += '?fromDate=$formattedFromDate&toDate=$formattedToDate';
    // }

    // Use the ApiHelper to get the URL
  String url = ApiHelper.getEfficiencyReport(dateRange);

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        print("API Response: ${response.body}");

        if (jsonData.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No data found for the selected date range')),
          );
        }

        setState(() {
          _achievementData = jsonData.map((item) {
            final date = item['OutputDate'] ?? 'Unknown Date';
            final achievement = item['IE_Achievement'] != null
                ? double.tryParse(item['IE_Achievement'].toString()) ?? 0.0
                : 0.0;
            return _ChartData(date, achievement);
          }).toList();

          _bonusData = jsonData.map((item) {
            final date = item['OutputDate'] ?? 'Unknown Date';
            final bonus = item['IE_Bonus'] != null
                ? double.tryParse(item['IE_Bonus'].toString()) ?? 0.0
                : 0.0;
            return _ChartData(date, bonus);
          }).toList();

          _achieveRateData = jsonData.map((item) {
            final date = item['OutputDate'] ?? 'Unknown Date';
            final achieveRate = item['Achieve_Rate'] != null
                ? double.tryParse(item['Achieve_Rate'].toString()) ?? 0.0
                : 0.0;
            return _ChartData(date, achieveRate);
          }).toList();

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load efficiency report');
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

  void _onChartTap(String chartTitle) {
    setState(() {
      if (_isMaximized && _maximizedChartTitle == chartTitle) {
        _isMaximized = false;
        _maximizedChartTitle = null;
      } else {
        _isMaximized = true;
        _maximizedChartTitle = chartTitle;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Efficiency Report'),
      //   backgroundColor: Colors.lightGreen, // Set header color to light green
      //   actions: [
      //     IconButton(
      //       icon: FaIcon(FontAwesomeIcons.calendarAlt), // Use Font Awesome calendar icon
      //       onPressed: () => _selectDateRange(context),
      //     ),
      //   ],
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the text
                children: [
                  GestureDetector(
                    onTap: () => _selectDateRange(context), // Action on tap
                    child: Text(
                      "Select Date",
                      style: TextStyle(
                        color: Colors.greenAccent, // Text color
                        fontSize: 16, // Font size
                        fontWeight: FontWeight.bold, // Make it bold (optional)
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_isMaximized)
                            _buildMaximizedChart()
                          else ...[
                            _buildChart(
                              title: 'IE Achievement',
                              dataSource: _achievementData,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 16.0),
                            _buildChart(
                              title: 'IE Bonus',
                              dataSource: _bonusData,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 16.0),
                            _buildChart(
                              title: 'Achieve Rate',
                              dataSource: _achieveRateData,
                              color: Colors.orange,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart({
    required String title,
    required List<_ChartData> dataSource,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _onChartTap(title),
      child: Container(
        height: 300,
        child: SfCartesianChart(
          primaryXAxis: const CategoryAxis(),
          title: ChartTitle(text: title),
          backgroundColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true, // Enable pinch to zoom
            enablePanning: true, // Enable panning
            zoomMode: ZoomMode.xy, // Allow zooming in both X and Y directions
          ),
          series: <CartesianSeries<_ChartData, String>>[
            AreaSeries<_ChartData, String>(
              dataSource: dataSource,
              xValueMapper: (_ChartData data, _) => data.category,
              yValueMapper: (_ChartData data, _) => data.value,
              color: color.withOpacity(0.3),
              borderColor: color,
              borderWidth: 2,
              name: title,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.auto,
                textStyle: const TextStyle(color: Colors.black),
                builder: (dynamic data,
                    ChartPoint<dynamic> point,
                    ChartSeries<dynamic, dynamic> series,
                    int index,
                    int seriesIndex) {
                  final chartData = data as _ChartData;
                  return Text(
                    chartData.value.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.black),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaximizedChart() {
    List<_ChartData> dataSource = [];
    Color color = Colors.blue;
    String title = '';

    if (_maximizedChartTitle == 'IE Achievement') {
      dataSource = _achievementData;
      color = Colors.blue;
      title = 'IE Achievement';
    } else if (_maximizedChartTitle == 'IE Bonus') {
      dataSource = _bonusData;
      color = Colors.green;
      title = 'IE Bonus';
    } else if (_maximizedChartTitle == 'Achieve Rate') {
      dataSource = _achieveRateData;
      color = Colors.orange;
      title = 'Achieve Rate';
    }

    return GestureDetector(
      onTap: () => _onChartTap(title),
      child: Container(
        height: MediaQuery.of(context).size.height - kToolbarHeight - 32.0,
        child: SfCartesianChart(
          primaryXAxis: const CategoryAxis(),
          title: ChartTitle(text: title),
          backgroundColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true, // Enable pinch to zoom
            enablePanning: true, // Enable panning
            zoomMode: ZoomMode.xy, // Allow zooming in both X and Y directions
          ),
          series: <CartesianSeries<_ChartData, String>>[
            AreaSeries<_ChartData, String>(
              dataSource: dataSource,
              xValueMapper: (_ChartData data, _) => data.category,
              yValueMapper: (_ChartData data, _) => data.value,
              color: color.withOpacity(0.3),
              borderColor: color,
              borderWidth: 2,
              name: title,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.auto,
                textStyle: const TextStyle(color: Colors.black),
                builder: (dynamic data,
                    ChartPoint<dynamic> point,
                    ChartSeries<dynamic, dynamic> series,
                    int index,
                    int seriesIndex) {
                  final chartData = data as _ChartData;
                  return Text(
                    chartData.value.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.black),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.category, this.value);

  final String category;
  final double value;
}
