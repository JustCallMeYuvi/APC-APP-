import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EfficiencyReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Static data for the chart
    final List<_ChartData> data = [
      _ChartData('Product A', 75),
      _ChartData('Product B', 80),
      _ChartData('Product C', 70),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Target Output Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(text: 'Target Output (%)'),
          legend: Legend(isVisible: true),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries<dynamic, String>>[
            ColumnSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData data, _) => data.category,
              yValueMapper: (_ChartData data, _) => data.value,
              name: 'Output',
              color: Colors.blue,
              dataLabelSettings: DataLabelSettings(isVisible: true),
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
