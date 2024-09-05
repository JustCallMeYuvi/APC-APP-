// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:intl/intl.dart';

// // Define the GetWorkTarget class
// class GetWorkTarget {
//   String grTDept;
//   String line;
//   DateTime? worKDay;
//   int outputQuantity;
//   int workQuantitySum;
//   ProcessNo processNo;

//   GetWorkTarget({
//     required this.grTDept,
//     required this.line,
//     this.worKDay,
//     required this.outputQuantity,
//     required this.workQuantitySum,
//     required this.processNo,
//   });

//   factory GetWorkTarget.fromJson(Map<String, dynamic> json) => GetWorkTarget(
//         grTDept: json["grT_DEPT"] ?? '',
//         line: json["line"] ?? '',
//         worKDay: json["worK_DAY"] == null ? null : DateTime.parse(json["worK_DAY"]),
//         outputQuantity: json["output_Quantity"] ?? 0,
//         workQuantitySum: json["work_quantity_sum"] ?? 0,
//         processNo: processNoValues.map[json["process_No"]] ?? ProcessNo.EMPTY,
//       );

//   Map<String, dynamic> toJson() => {
//         "grT_DEPT": grTDept,
//         "line": line,
//         "worK_DAY": worKDay?.toIso8601String(),
//         "output_Quantity": outputQuantity,
//         "work_quantity_sum": workQuantitySum,
//         "process_No": processNoValues.reverse[processNo] ?? '',
//       };
// }

// // Define the ProcessNo enum
// enum ProcessNo { A, AC, C, CMD, CS, DCD, EMPTY, FI, IMD, L, LM, S, SPD, T }

// // Define the processNoValues mapping
// final processNoValues = EnumValues({
//   "A": ProcessNo.A,
//   "AC": ProcessNo.AC,
//   "C": ProcessNo.C,
//   "CMD": ProcessNo.CMD,
//   "CS": ProcessNo.CS,
//   "DCD": ProcessNo.DCD,
//   "": ProcessNo.EMPTY,
//   "FI": ProcessNo.FI,
//   "IMD": ProcessNo.IMD,
//   "L": ProcessNo.L,
//   "LM": ProcessNo.LM,
//   "S": ProcessNo.S,
//   "SPD": ProcessNo.SPD,
//   "T": ProcessNo.T
// });

// // Define the EnumValues class
// class EnumValues<T> {
//   Map<String, T> map;
//   late Map<T, String> reverseMap;

//   EnumValues(this.map);

//   Map<T, String> get reverse {
//     reverseMap = map.map((k, v) => MapEntry(v, k));
//     return reverseMap;
//   }
// }

// // // Define the TargetOutputReportPage widget
// // class TargetOutputReportPage extends StatefulWidget {
// //   @override
// //   _TargetOutputReportPageState createState() => _TargetOutputReportPageState();
// // }

// // // Define the _TargetOutputReportPageState class
// // class _TargetOutputReportPageState extends State<TargetOutputReportPage> {
// //   List<GetWorkTarget> _workTargets = [];
// //   bool _isLoading = false;
// //   bool _isDataAvailable = false;
// //   DateTime? _startDate;
// //   DateTime? _endDate;
// //   int _totalWorkQuantitySum = 0;
// //   int _totalOutputQuantity = 0;
// //   double _totalPercentage = 0.0;

// //   // Fetch data from the API
// //   Future<void> _fetchData() async {
// //     if (_startDate == null || _endDate == null) {
// //       print('Start Date and End Date must be selected.');
// //       return;
// //     }

// //     final url = 'http://10.3.0.70:9042/api/HR/GetWorkTargets'
// //         '?fromDate=${_startDate!.toIso8601String().split('T')[0]}'
// //         '&toDate=${_endDate!.toIso8601String().split('T')[0]}';
// //     print('Fetching data from URL: $url');

// //     setState(() {
// //       _isLoading = true;
// //     });

// //     try {
// //       final response = await http.get(Uri.parse(url));
// //       print('Response status code: ${response.statusCode}');

// //       if (response.statusCode == 200) {
// //         List<GetWorkTarget> fetchedData = getWorkTargetFromJson(response.body);
// //         setState(() {
// //           _workTargets = fetchedData;
// //           _isDataAvailable = _workTargets.isNotEmpty;

// //           // Calculate totals
// //           _totalWorkQuantitySum = _workTargets
// //               .fold(0, (sum, item) => sum + item.workQuantitySum);

// //           // Calculate total output quantity
// //           _totalOutputQuantity = _workTargets
// //               .fold(0, (sum, item) => sum + item.outputQuantity);

// //           // Calculate percentage
// //           _totalPercentage = _totalWorkQuantitySum == 0
// //               ? 0
// //               : (_totalOutputQuantity / _totalWorkQuantitySum) * 100;
// //         });
// //       } else {
// //         throw Exception('Failed to load data');
// //       }
// //     } catch (e) {
// //       print('Error fetching data: $e');
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   // Select start date
// //   Future<void> _selectStartDate(BuildContext context) async {
// //     DateTime? selectedDate = await showDatePicker(
// //       context: context,
// //       initialDate: _startDate ?? DateTime.now().subtract(Duration(days: 30)),
// //       firstDate: DateTime(2000),
// //       lastDate: DateTime(2100),
// //     );

// //     if (selectedDate != null && selectedDate != _startDate) {
// //       setState(() {
// //         _startDate = selectedDate;
// //       });
// //     }
// //   }

// //   // Select end date
// //   Future<void> _selectEndDate(BuildContext context) async {
// //     DateTime? selectedDate = await showDatePicker(
// //       context: context,
// //       initialDate: _endDate ?? DateTime.now(),
// //       firstDate: _startDate ?? DateTime(2000),
// //       lastDate: DateTime(2100),
// //     );

// //     if (selectedDate != null && selectedDate != _endDate) {
// //       setState(() {
// //         _endDate = selectedDate;
// //       });
// //     }
// //   }

// //   // Handle fetch data button click
// //   void _onFetchData() {
// //     _fetchData();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     List<GetWorkTarget> validTargets = _workTargets
// //         .where((data) =>
// //             data.outputQuantity != null &&
// //             data.workQuantitySum != null &&
// //             data.workQuantitySum != 0)
// //         .toList();

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Target Output Report'),
// //       ),
// //       body: Column(
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Column(
// //                   children: [
// //                     ElevatedButton(
// //                       onPressed: () => _selectStartDate(context),
// //                       child: Text(
// //                         _startDate == null
// //                             ? 'Select Start Date'
// //                             : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
// //                         style: TextStyle(fontSize: 16),
// //                       ),
// //                     ),
// //                     SizedBox(width: 10),
// //                     ElevatedButton(
// //                       onPressed: () => _selectEndDate(context),
// //                       child: Text(
// //                         _endDate == null
// //                             ? 'Select End Date'
// //                             : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
// //                         style: TextStyle(fontSize: 16),
// //                       ),
// //                     ),
// //                     SizedBox(height: 10),
// //                     ElevatedButton(
// //                       onPressed: _onFetchData,
// //                       child: Text('Fetch Data'),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //           _isLoading
// //               ? Center(child: CircularProgressIndicator())
// //               : _isDataAvailable
// //                   ? Padding(
// //                       padding: const EdgeInsets.all(8.0),
// //                       child: Column(
// //                         children: [
// //                           Text(
// //                             'Total Work Quantity Sum: $_totalWorkQuantitySum',
// //                             style: TextStyle(
// //                                 fontSize: 16, fontWeight: FontWeight.bold),
// //                           ),
// //                           Text(
// //                             'Total Output Quantity: $_totalOutputQuantity',
// //                             style: TextStyle(
// //                                 fontSize: 16, fontWeight: FontWeight.bold),
// //                           ),
// //                           Text(
// //                             'Percentage: ${_totalPercentage.toStringAsFixed(2)}%',
// //                             style: TextStyle(
// //                                 fontSize: 16, fontWeight: FontWeight.bold),
// //                           ),
// //                           SizedBox(height: 20),
// //                           Container(
// //                             height: MediaQuery.of(context).size.height * 0.5,
// //                             child: SfCartesianChart(
// //                               title: ChartTitle(text: 'Target Output (%)'),
// //                               legend: Legend(isVisible: true),
// //                               tooltipBehavior: TooltipBehavior(enable: true),
// //                               primaryXAxis: CategoryAxis(),
// //                               primaryYAxis: NumericAxis(
// //                                 title: AxisTitle(text: 'Output (%)'),
// //                               ),
// //                               series: <CartesianSeries>[
// //                                 ColumnSeries<GetWorkTarget, String>(
// //                                   dataSource: validTargets,
// //                                   xValueMapper: (GetWorkTarget target, _) =>
// //                                       target.processNo.toString(),
// //                                   yValueMapper: (GetWorkTarget target, _) =>
// //                                       target.outputQuantity / target.workQuantitySum * 100,
// //                                   name: 'Output Percentage',
// //                                   color: Colors.blue,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     )
// //                   : Center(child: Text('No data available')),
// //         ],
// //       ),
// //     );
// //   }
// // }
// // // Converts JSON string to a list of GetWorkTarget objects
// // List<GetWorkTarget> getWorkTargetFromJson(String str) {
// //   final jsonData = json.decode(str) as List;
// //   return jsonData.map((item) => GetWorkTarget.fromJson(item)).toList();
// // }

// // Define the TargetOutputReportPage widget
// class TargetOutputReportPage extends StatefulWidget {
//   @override
//   _TargetOutputReportPageState createState() => _TargetOutputReportPageState();
// }

// // Define the _TargetOutputReportPageState class
// class _TargetOutputReportPageState extends State<TargetOutputReportPage> {
//   List<GetWorkTarget> _workTargets = [];
//   bool _isLoading = false;
//   bool _isDataAvailable = false;
//   DateTime? _startDate;
//   DateTime? _endDate;
//   int _totalWorkQuantitySum = 0;
//   int _totalOutputQuantity = 0;
//   double _totalPercentage = 0.0;

//   // Fetch data from the API
//   Future<void> _fetchData() async {
//     if (_startDate == null || _endDate == null) {
//       print('Start Date and End Date must be selected.');
//       return;
//     }

//     final url = 'http://10.3.0.70:9042/api/HR/GetWorkTargets'
//         '?fromDate=${_startDate!.toIso8601String().split('T')[0]}'
//         '&toDate=${_endDate!.toIso8601String().split('T')[0]}';
//     print('Fetching data from URL: $url');

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.get(Uri.parse(url));
//       print('Response status code: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         List<GetWorkTarget> fetchedData = getWorkTargetFromJson(response.body);
//         setState(() {
//           _workTargets = fetchedData;
//           _isDataAvailable = _workTargets.isNotEmpty;

//           // Calculate totals
//           _totalWorkQuantitySum = _workTargets
//               .fold(0, (sum, item) => sum + item.workQuantitySum);

//           // Calculate total output quantity
//           _totalOutputQuantity = _workTargets
//               .fold(0, (sum, item) => sum + item.outputQuantity);

//           // Calculate percentage
//           _totalPercentage = _totalWorkQuantitySum == 0
//               ? 0
//               : (_totalOutputQuantity / _totalWorkQuantitySum) * 100;
//         });
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       print('Error fetching data: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Select start date
//   Future<void> _selectStartDate(BuildContext context) async {
//     DateTime? selectedDate = await showDatePicker(
//       context: context,
//       initialDate: _startDate ?? DateTime.now().subtract(Duration(days: 30)),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (selectedDate != null && selectedDate != _startDate) {
//       setState(() {
//         _startDate = selectedDate;
//       });
//     }
//   }

//   // Select end date
//   Future<void> _selectEndDate(BuildContext context) async {
//     DateTime? selectedDate = await showDatePicker(
//       context: context,
//       initialDate: _endDate ?? DateTime.now(),
//       firstDate: _startDate ?? DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (selectedDate != null && selectedDate != _endDate) {
//       setState(() {
//         _endDate = selectedDate;
//       });
//     }
//   }

//   // Handle fetch data button click
//   void _onFetchData() {
//     _fetchData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<GetWorkTarget> validTargets = _workTargets
//         .where((data) =>
//             data.outputQuantity != null &&
//             data.workQuantitySum != null &&
//             data.workQuantitySum != 0)
//         .toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Target Output Report'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Column(
//                   children: [
//                     ElevatedButton(
//                       onPressed: () => _selectStartDate(context),
//                       child: Text(
//                         _startDate == null
//                             ? 'Select Start Date'
//                             : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     ElevatedButton(
//                       onPressed: () => _selectEndDate(context),
//                       child: Text(
//                         _endDate == null
//                             ? 'Select End Date'
//                             : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: _onFetchData,
//                       child: Text('Fetch Data'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           _isLoading
//               ? Center(child: CircularProgressIndicator())
//               : _isDataAvailable
//                   ? Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         children: [
//                           Text(
//                             'Total Work Quantity Sum: $_totalWorkQuantitySum',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Total Output Quantity: $_totalOutputQuantity',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Percentage: ${_totalPercentage.toStringAsFixed(2)}%',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(height: 20),
//                           Container(
//                             height: MediaQuery.of(context).size.height * 0.5,
//                             child: SfCartesianChart(
//                               title: ChartTitle(text: 'Work vs Output'),
//                               legend: Legend(isVisible: true),
//                               tooltipBehavior: TooltipBehavior(enable: true),
//                               primaryXAxis: CategoryAxis(),
//                               primaryYAxis: NumericAxis(
//                                 title: AxisTitle(text: 'Quantity'),
//                               ),
//                               series: <CartesianSeries>[
//                                 ColumnSeries<GetWorkTarget, String>(
//                                   dataSource: validTargets,
//                                   xValueMapper: (GetWorkTarget target, _) =>
//                                       target.processNo.toString(),
//                                   yValueMapper: (GetWorkTarget target, _) =>
//                                       target.workQuantitySum.toDouble(),
//                                   name: 'Work Quantity Sum',
//                                   color: Colors.red,
//                                 ),
//                                 ColumnSeries<GetWorkTarget, String>(
//                                   dataSource: validTargets,
//                                   xValueMapper: (GetWorkTarget target, _) =>
//                                       target.processNo.toString(),
//                                   yValueMapper: (GetWorkTarget target, _) =>
//                                       target.outputQuantity.toDouble(),
//                                   name: 'Output Quantity',
//                                   color: Colors.green,
//                                 ),
//                                 LineSeries<GetWorkTarget, String>(
//                                   dataSource: validTargets,
//                                   xValueMapper: (GetWorkTarget target, _) =>
//                                       target.processNo.toString(),
//                                   yValueMapper: (GetWorkTarget target, _) =>
//                                       target.workQuantitySum == 0
//                                           ? 0
//                                           : (target.outputQuantity / target.workQuantitySum) * 100,
//                                   name: 'Output Percentage',
//                                   color: Colors.blue,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : Center(child: Text('No data available')),
//         ],
//       ),
//     );
//   }
// }

// // Converts JSON string to a list of GetWorkTarget objects
// List<GetWorkTarget> getWorkTargetFromJson(String str) {
//   final jsonData = json.decode(str) as List;
//   return jsonData.map((item) => GetWorkTarget.fromJson(item)).toList();
// }

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

// Future<void> _fetchData() async {
//     if (_startDate == null || _endDate == null) {
//         print('Start Date and End Date must be selected.');
//         return;
//     }

//     final url = 'http://10.3.0.70:9042/api/HR/GetWorkTargets'
//         '?fromDate=${_startDate!.toIso8601String().split('T')[0]}'
//         '&toDate=${_endDate!.toIso8601String().split('T')[0]}';
//     print('Fetching data from URL: $url');

//     setState(() {
//         _isLoading = true;
//     });

//     try {
//         final response = await http.get(Uri.parse(url));
//         print('Response status code: ${response.statusCode}');

//         if (response.statusCode == 200) {
//             List<GetWorkTarget> fetchedData = getWorkTargetFromJson(response.body);

//             // Filter the data based on the selected date range
//             List<GetWorkTarget> filteredData = fetchedData.where((data) {
//                 return data.worKDay != null &&
//                     data.worKDay!.isAfter(_startDate!.subtract(Duration(days: 1))) &&
//                     data.worKDay!.isBefore(_endDate!.add(Duration(days: 1)));
//             }).toList();

//             setState(() {
//                 _workTargets = filteredData;
//                 _isDataAvailable = _workTargets.isNotEmpty;

//                 // Calculate totals
//                 _totalWorkQuantitySum = _workTargets
//                     .fold(0, (sum, item) => sum + item.workQuantitySum);

//                 _totalOutputQuantity = _workTargets
//                     .fold(0, (sum, item) => sum + item.outputQuantity);

//                 _totalPercentage = _totalWorkQuantitySum == 0
//                     ? 0
//                     : (_totalOutputQuantity / _totalWorkQuantitySum) * 100;
//             });
//         } else {
//             throw Exception('Failed to load data');
//         }
//     } catch (e) {
//         print('Error fetching data: $e');
//     } finally {
//         setState(() {
//             _isLoading = false;
//         });
//     }
// }

  // Select start date
  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(Duration(days: 30)),
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
        title: Text('Target Output Report'),
        backgroundColor: Colors.lightGreen,
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => _selectStartDate(context),
                          child: Text(
                            _startDate == null
                                ? 'Select Start Date'
                                : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        // _buildDateButton(
                        //   label: _startDate == null
                        //       ? 'Select Start Date'
                        //       : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
                        //   onPressed: () => _selectStartDate(context),
                        // ),
                        // SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => _selectEndDate(context),
                          child: Text(
                            _endDate == null
                                ? 'Select End Date'
                                : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                        // _buildDateButton(
                        //   label: _endDate == null
                        //       ? 'Select End Date'
                        //       : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                        //   onPressed: () => _selectEndDate(context),
                        // ),

                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _onFetchData,
                          child: Text('Fetch Data'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _isDataAvailable
                      ? Card(
                          elevation: 5,
                          margin: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                // Text(
                                //   'Total Work Quantity Sum: $_totalWorkQuantitySum',
                                //   style: TextStyle(
                                //       fontSize: 16, fontWeight: FontWeight.bold),
                                // ),
                                // Text(
                                //   'Total Work Quantity Sum: $_totalWorkQuantitySum',
                                //   style: TextStyle(
                                //     fontSize: 18,
                                //     fontWeight: FontWeight.bold,
                                //     color: Colors.teal,
                                //   ),
                                // ),
                                // Text(
                                //   'Total Output Quantity: $_totalOutputQuantity',
                                //   style: TextStyle(
                                //       fontSize: 16, fontWeight: FontWeight.bold),
                                // ),
                                // Text(
                                //   'Percentage: ${_totalPercentage.toStringAsFixed(2)}%',
                                //   style: TextStyle(
                                //       fontSize: 16, fontWeight: FontWeight.bold),
                                // ),

                                _buildTotalCard('Total Work Quantity Sum',
                                    _totalWorkQuantitySum),
                                _buildTotalCard('Total Output Quantity',
                                    _totalOutputQuantity),
                                _buildTotalCard('Percentage',
                                    '${_totalPercentage.toStringAsFixed(2)}%'),
                                SizedBox(height: 20),
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
                                    title: ChartTitle(
                                      text: 'Work vs Output Quantity',
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    legend: Legend(
                                      isVisible: true,
                                      position: LegendPosition.bottom,
                                    ),
                                    primaryXAxis: CategoryAxis(
                                      majorGridLines: MajorGridLines(width: 0),
                                    ),
                                    primaryYAxis: NumericAxis(
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
                                            DataLabelSettings(isVisible: true),
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
                                            DataLabelSettings(isVisible: true),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Center(child: Text('No data available')),
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

Widget _buildDateButton(
    {required String label, required VoidCallback onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal[400],
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}

Widget _buildTotalCard(String title, dynamic value) {
  return Card(
    color: Colors.white.withOpacity(0.9),
    elevation: 5,
    margin: EdgeInsets.symmetric(vertical: 8),
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
            style: TextStyle(
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
