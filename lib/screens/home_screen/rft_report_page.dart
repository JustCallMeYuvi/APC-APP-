

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RftReportPage extends StatefulWidget {
  const RftReportPage({super.key});

  @override
  _RftReportPageState createState() => _RftReportPageState();
}

class _RftReportPageState extends State<RftReportPage> {
  List<_ChartData> _totalQuantityData = [];
  List<_ChartData> _passQuantityData = [];
  List<_ChartData> _rftPercentageData = [];
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
  if (!mounted) return; // Exit early if the widget is no longer mounted

  setState(() {
    _isLoading = true;
  });

  String? formattedFromDate = dateRange?.start.toIso8601String().substring(0, 10);
  String? formattedToDate = dateRange?.end.toIso8601String().substring(0, 10);

  String url = 'http://10.3.0.70:9042/api/HR/GetProductionData';
  if (dateRange != null) {
    url += '?startDate=$formattedFromDate&endDate=$formattedToDate';
  }

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      if (jsonData.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data found for the selected date range')),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          try {
            _totalQuantityData = jsonData.map((item) {
              final productionLine = item['productionLineCode'] ?? 'Unknown';
              final totalQuantity = item['totalQuantity'] != null
                  ? double.tryParse(item['totalQuantity'].toString()) ?? 0.0
                  : 0.0;
              return _ChartData(productionLine, totalQuantity);
            }).toList();

            _passQuantityData = jsonData.map((item) {
              final productionLine = item['productionLineCode'] ?? 'Unknown';
              final passQuantity = item['passQuantity'] != null
                  ? double.tryParse(item['passQuantity'].toString()) ?? 0.0
                  : 0.0;
              return _ChartData(productionLine, passQuantity);
            }).toList();

            _rftPercentageData = jsonData.map((item) {
              final productionLine = item['productionLineCode'] ?? 'Unknown';
              final rftPercentage = item['rftPercentage'] != null
                  ? double.tryParse(item['rftPercentage'].toString()) ?? 0.0
                  : 0.0;
              return _ChartData(productionLine, rftPercentage);
            }).toList();
          } catch (e) {
            print("Error processing data: $e");
          }
          _isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load efficiency report');
    }
  } catch (error) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $error')),
      );
    }
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
      appBar: AppBar(
        title: const Text('RFT Report'),
        backgroundColor: Colors.lightGreen, // Set header color to light green
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.calendarAlt), // Use Font Awesome calendar icon
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
                  children: [
                    if (_isMaximized)
                      _buildMaximizedChart()
                    else ...[
                      _buildChart(
                        title: 'Total Quantity',
                        dataSource: _totalQuantityData,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16.0),
                      _buildChart(
                        title: 'Pass Quantity',
                        dataSource: _passQuantityData,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16.0),
                      _buildChart(
                        title: 'RFT Percentage',
                        dataSource: _rftPercentageData,
                        color: Colors.orange,
                      ),
                    ],
                  ],
                ),
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
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        height: 300,
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(
            labelRotation: 45, // Rotate X-axis labels to avoid overlapping
          ),
          primaryYAxis: NumericAxis(
            labelFormat: '{value}',
            axisLine: AxisLine(width: 0),
            majorGridLines: MajorGridLines(width: 0),
          ),
          title: ChartTitle(text: title),
          backgroundColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true, // Enable pinch to zoom
            enablePanning: true, // Enable panning
            zoomMode: ZoomMode.xy, // Allow zooming in both X and Y directions
          ),
          series: <CartesianSeries<_ChartData, String>>[
            BarSeries<_ChartData, String>(
              dataSource: dataSource,
              xValueMapper: (_ChartData data, _) => data.category,
              yValueMapper: (_ChartData data, _) => data.value,
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(4)),
              name: title,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.auto,
                textStyle: const TextStyle(color: Colors.black),
                builder: (dynamic data, ChartPoint<dynamic> point, ChartSeries<dynamic, dynamic> series, int index, int seriesIndex) {
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

    switch (_maximizedChartTitle) {
      case 'Total Quantity':
        dataSource = _totalQuantityData;
        color = Colors.blue;
        title = 'Total Quantity';
        break;
      case 'Pass Quantity':
        dataSource = _passQuantityData;
        color = Colors.green;
        title = 'Pass Quantity';
        break;
      case 'RFT Percentage':
        dataSource = _rftPercentageData;
        color = Colors.orange;
        title = 'RFT Percentage';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      height: MediaQuery.of(context).size.height - 150, // Adjust height for maximized state
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelRotation: 45, // Rotate X-axis labels to avoid overlapping
        ),
        primaryYAxis: NumericAxis(
          labelFormat: '{value}',
          axisLine: AxisLine(width: 0),
          majorGridLines: MajorGridLines(width: 0),
        ),
        title: ChartTitle(text: title),
        backgroundColor: Colors.transparent,
        plotAreaBorderWidth: 0,
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true, // Enable pinch to zoom
          enablePanning: true, // Enable panning
          zoomMode: ZoomMode.xy, // Allow zooming in both X and Y directions
        ),
        series: <CartesianSeries<_ChartData, String>>[
          BarSeries<_ChartData, String>(
            dataSource: dataSource,
            xValueMapper: (_ChartData data, _) => data.category,
            yValueMapper: (_ChartData data, _) => data.value,
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(4)),
            name: title,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.auto,
              textStyle: const TextStyle(color: Colors.black),
              builder: (dynamic data, ChartPoint<dynamic> point, ChartSeries<dynamic, dynamic> series, int index, int seriesIndex) {
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
    );
  }
}

class _ChartData {
  _ChartData(this.category, this.value);
  final String category;
  final double value;
}
