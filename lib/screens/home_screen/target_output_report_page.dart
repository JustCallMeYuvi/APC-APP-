import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

// Define the GetWorkTarget class
class GetWorkTarget {
  String grTDept;
  String line;
  DateTime? worKDay;
  int outputQuantity;
  int workQuantitySum;
  ProcessNo processNo;

  GetWorkTarget({
    required this.grTDept,
    required this.line,
    this.worKDay,
    required this.outputQuantity,
    required this.workQuantitySum,
    required this.processNo,
  });

  factory GetWorkTarget.fromJson(Map<String, dynamic> json) => GetWorkTarget(
        grTDept: json["grT_DEPT"] ?? '',
        line: json["line"] ?? '',
        worKDay:
            json["worK_DAY"] == null ? null : DateTime.parse(json["worK_DAY"]),
        outputQuantity: json["output_Quantity"] ?? 0,
        workQuantitySum: json["work_quantity_sum"] ?? 0,
        processNo: processNoValues.map[json["process_No"]] ?? ProcessNo.EMPTY,
      );

  Map<String, dynamic> toJson() => {
        "grT_DEPT": grTDept,
        "line": line,
        "worK_DAY": worKDay?.toIso8601String(),
        "output_Quantity": outputQuantity,
        "work_quantity_sum": workQuantitySum,
        "process_No": processNoValues.reverse[processNo] ?? '',
      };
}

// Define the ProcessNo enum
enum ProcessNo { A, AC, C, CMD, CS, DCD, EMPTY, FI, IMD, L, LM, S, SPD, T }

// Define the processNoValues mapping
final processNoValues = EnumValues({
  "A": ProcessNo.A,
  "AC": ProcessNo.AC,
  "C": ProcessNo.C,
  "CMD": ProcessNo.CMD,
  "CS": ProcessNo.CS,
  "DCD": ProcessNo.DCD,
  "": ProcessNo.EMPTY,
  "FI": ProcessNo.FI,
  "IMD": ProcessNo.IMD,
  "L": ProcessNo.L,
  "LM": ProcessNo.LM,
  "S": ProcessNo.S,
  "SPD": ProcessNo.SPD,
  "T": ProcessNo.T
});

// Define the EnumValues class
class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

// Define the TargetOutputReportPage widget
class TargetOutputReportPage extends StatefulWidget {
  @override
  _TargetOutputReportPageState createState() => _TargetOutputReportPageState();
}

// Define the _TargetOutputReportPageState class
class _TargetOutputReportPageState extends State<TargetOutputReportPage> {
  List<GetWorkTarget> _workTargets = [];
  bool _isLoading = false;
  bool _isDataAvailable = false;
  DateTime? _startDate;
  DateTime? _endDate;
  int _totalWorkQuantitySum = 0;
  int _totalOutputQuantity = 0;
  double _totalPercentage = 0.0;

  // Fetch data from the API
  Future<void> _fetchData() async {
    if (_startDate == null || _endDate == null) {
      print('Start Date and End Date must be selected.');
      return;
    }

    final url = 'http://10.3.0.70:9042/api/HR/GetWorkTargets'
        '?fromDate=${_startDate!.toIso8601String().split('T')[0]}'
        '&toDate=${_endDate!.toIso8601String().split('T')[0]}';
    print('Fetching data from URL: $url');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<GetWorkTarget> fetchedData = getWorkTargetFromJson(response.body);
        setState(() {
          _workTargets = fetchedData;
          _isDataAvailable = _workTargets.isNotEmpty;

          // Calculate totals
          _totalWorkQuantitySum =
              _workTargets.fold(0, (sum, item) => sum + item.workQuantitySum);

          _totalOutputQuantity =
              _workTargets.fold(0, (sum, item) => sum + item.outputQuantity);

          _totalPercentage = _totalWorkQuantitySum == 0
              ? 0
              : (_totalOutputQuantity / _totalWorkQuantitySum) * 100;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Select start and end date range
  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? selectedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _endDate ?? DateTime.now(),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedRange != null) {
      setState(() {
        _startDate = selectedRange.start;
        _endDate = selectedRange.end;
      });
      _fetchData();
    }
  }

  // Select start date
  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && selectedDate != _startDate) {
      setState(() {
        _startDate = selectedDate;
      });
    }
  }

  // Select end date
  Future<void> _selectEndDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && selectedDate != _endDate) {
      setState(() {
        _endDate = selectedDate;
      });
    }
  }

  // Handle fetch data button click
  void _onFetchData() {
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    List<GetWorkTarget> validTargets = _workTargets
        .where((data) =>
            data.outputQuantity != null &&
            data.workQuantitySum != null &&
            data.workQuantitySum != 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Output Report'),
        backgroundColor: Colors.lightGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[200]!, Colors.blueGrey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        // ElevatedButton(
                        //   onPressed: () => _selectStartDate(context),
                        //   child: Text(
                        //     _startDate == null
                        //         ? 'Select Start Date'
                        //         : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
                        //     style: TextStyle(fontSize: 16),
                        //   ),
                        // ),
                        // // _buildDateButton(
                        // //   label: _startDate == null
                        // //       ? 'Select Start Date'
                        // //       : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
                        // //   onPressed: () => _selectStartDate(context),
                        // // ),
                        // // SizedBox(width: 20),
                        // ElevatedButton(
                        //   onPressed: () => _selectEndDate(context),
                        //   child: Text(
                        //     _endDate == null
                        //         ? 'Select End Date'
                        //         : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                        //     style: TextStyle(fontSize: 16),
                        //   ),
                        // ),

                        // // _buildDateButton(
                        // //   label: _endDate == null
                        // //       ? 'Select End Date'
                        // //       : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                        // //   onPressed: () => _selectEndDate(context),
                        // // ),

                        // SizedBox(height: 10),
                        // ElevatedButton(
                        //   onPressed: _onFetchData,
                        //   child: Text('Fetch Data'),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _isDataAvailable
                      ? Card(
                          elevation: 5,
                          margin: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                _buildTotalCard('Total Work Quantity Sum',
                                    _totalWorkQuantitySum),
                                _buildTotalCard('Total Output Quantity',
                                    _totalOutputQuantity),
                                _buildTotalCard('Percentage',
                                    '${_totalPercentage.toStringAsFixed(2)}%'),
                                const SizedBox(height: 20),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child:
                                      // SfCartesianChart(
                                      //   title:
                                      //       ChartTitle(text: 'Work vs Output Quantity'),
                                      //   legend: Legend(isVisible: true),
                                      //   tooltipBehavior: TooltipBehavior(enable: true),
                                      //   primaryXAxis: CategoryAxis(),
                                      //   primaryYAxis: NumericAxis(
                                      //     title: AxisTitle(text: 'Quantity'),
                                      //   ),
                                      //   series: <CartesianSeries<GetWorkTarget,
                                      //       String>>[
                                      //     ColumnSeries<GetWorkTarget, String>(
                                      //       dataSource: validTargets,
                                      //       xValueMapper: (GetWorkTarget data, _) =>
                                      //           DateFormat('yyyy-MM-dd')
                                      //               .format(data.worKDay!),
                                      //       yValueMapper: (GetWorkTarget data, _) =>
                                      //           data.workQuantitySum,
                                      //       name: 'Work Quantity',
                                      //       color: Colors.blue,
                                      //     ),
                                      //     ColumnSeries<GetWorkTarget, String>(
                                      //       dataSource: validTargets,
                                      //       xValueMapper: (GetWorkTarget data, _) =>
                                      //           DateFormat('yyyy-MM-dd')
                                      //               .format(data.worKDay!),
                                      //       yValueMapper: (GetWorkTarget data, _) =>
                                      //           data.outputQuantity,
                                      //       name: 'Output Quantity',
                                      //       color: Colors.green,
                                      //     ),
                                      //   ],
                                      // ),
                                      SfCartesianChart(
                                    title: const ChartTitle(
                                      text: 'Work vs Output Quantity',
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    legend: const Legend(
                                      isVisible: true,
                                      position: LegendPosition.bottom,
                                    ),
                                    primaryXAxis: const CategoryAxis(
                                      majorGridLines: MajorGridLines(width: 0),
                                    ),
                                    primaryYAxis: const NumericAxis(
                                      axisLine: AxisLine(width: 0),
                                      majorTickLines: MajorTickLines(size: 0),
                                      title: AxisTitle(
                                        text: 'Quantity',
                                        textStyle:
                                            TextStyle(color: Colors.blueGrey),
                                      ),
                                    ),
                                    series: <CartesianSeries>[
                                      ColumnSeries<GetWorkTarget, String>(
                                        dataSource: validTargets,
                                        xValueMapper: (GetWorkTarget data, _) =>
                                            DateFormat('yyyy-MM-dd')
                                                .format(data.worKDay!),
                                        yValueMapper: (GetWorkTarget data, _) =>
                                            data.workQuantitySum,
                                        name: 'Work Quantity',
                                        color: Colors.blue,
                                        dataLabelSettings:
                                            const DataLabelSettings(
                                                isVisible: true),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      ColumnSeries<GetWorkTarget, String>(
                                        dataSource: validTargets,
                                        xValueMapper: (GetWorkTarget data, _) =>
                                            DateFormat('yyyy-MM-dd')
                                                .format(data.worKDay!),
                                        yValueMapper: (GetWorkTarget data, _) =>
                                            data.outputQuantity,
                                        name: 'Output Quantity',
                                        color: Colors.green,
                                        dataLabelSettings:
                                            const DataLabelSettings(
                                                isVisible: true),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const Center(
                          child:
                              Text('No data available or Please select dates')),
            ],
          ),
        ),
      ),
    );
  }
}

// Converts JSON string to a list of GetWorkTarget objects
List<GetWorkTarget> getWorkTargetFromJson(String str) {
  final jsonData = json.decode(str) as List;
  return jsonData.map((item) => GetWorkTarget.fromJson(item)).toList();
}

Widget _buildTotalCard(String title, dynamic value) {
  return Card(
    color: Colors.white.withOpacity(0.9),
    elevation: 5,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal[900],
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}
