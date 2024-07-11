import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({Key? key}) : super(key: key);

  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  // Example data for demonstration
  List<ChartSampleData> _chartData = [
    ChartSampleData(x: 'Jan', y: 1),
    ChartSampleData(x: 'Feb', y: 3),
    ChartSampleData(x: 'Mar', y: 2),
    ChartSampleData(x: 'Apr', y: 4),
    ChartSampleData(x: 'May', y: 3),
    ChartSampleData(x: 'Jun', y: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adidas Shoes Sales Graph'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  // Line series
                  LineSeries<ChartSampleData, String>(
                    dataSource: _chartData,
                    xValueMapper: (ChartSampleData sales, _) => sales.x,
                    yValueMapper: (ChartSampleData sales, _) => sales.y,
                    // Data label settings
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                  // Stacked column series
                ],
                // Chart title
                title: ChartTitle(text: 'Sales Graph'),
              ),
            ),
            SizedBox(height: 20), // Space between charts
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                // Stacked column series
                series: <CartesianSeries>[
                  StackedColumnSeries<ChartSampleData, String>(
                    dataSource: _chartData,
                    xValueMapper: (ChartSampleData sales, _) => sales.x,
                    yValueMapper: (ChartSampleData sales, _) => sales.y,
                  ),
                ],
                // Chart title
                title: ChartTitle(text: 'Stacked Column Series'),
              ),
            ),
            SizedBox(height: 20), // Space between charts
            Expanded(
              child: SfCircularChart(
                // Pie series
                series: <CircularSeries>[
                  PieSeries<ChartSampleData, String>(
                    dataSource: _chartData,
                    xValueMapper: (ChartSampleData sales, _) => sales.x,
                    yValueMapper: (ChartSampleData sales, _) => sales.y,
                    // Data label settings
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
                // Chart title
                title: ChartTitle(text: 'Pie Charts'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sample data class
class ChartSampleData {
  final String x;
  final double y;

  ChartSampleData({
    required this.x,
    required this.y,
  });
}
