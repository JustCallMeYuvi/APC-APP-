// import 'dart:convert';
// import 'package:drop_down_search_field/drop_down_search_field.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:syncfusion_flutter_charts/charts.dart';

// class CarChartsScreen extends StatefulWidget {
//   const CarChartsScreen({Key? key}) : super(key: key);

//   @override
//   _CarChartsScreenState createState() => _CarChartsScreenState();
// }

// class _CarChartsScreenState extends State<CarChartsScreen> {
//   bool _isLoading = false;
//   String? _selectedCarType = "All";
//   final TextEditingController _carTypeController = TextEditingController();

//   final List<String> carTypes = ["All", "In", "Out"];

//   List<_CarChartData> _chartData = [];

//   _CarChartData? _selectedData; // Holds the tapped data

//   @override
//   void initState() {
//     super.initState();
//     fetchChartData();
//   }

//   Future<void> fetchChartData() async {
//     if (_selectedCarType == null) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final String url =
//           "http://10.3.0.70:9042/api/Car_Conveyance_/Cars_Charts?selectedtype=$_selectedCarType";

//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);

//         final List<dynamic> data = jsonData['data'];

//         // Group by selectedBookingType or currentState
//         Map<String, int> groupedData = {};

//         for (var item in data) {
//           String key = item['selectedBookingType'] ?? 'Unknown';
//           groupedData[key] = (groupedData[key] ?? 0) + 1;
//         }

//         setState(() {
//           _chartData = groupedData.entries
//               .map((entry) => _CarChartData(
//                     carName: entry.key,
//                     value: entry.value,
//                   ))
//               .toList();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to load chart data")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   DropDownSearchField(
//                     textFieldConfiguration: TextFieldConfiguration(
//                       controller: _carTypeController,
//                       decoration: const InputDecoration(
//                         labelText: "Car Type",
//                         border: OutlineInputBorder(),
//                         suffixIcon: Icon(Icons.arrow_drop_down),
//                       ),
//                     ),
//                     suggestionsCallback: (pattern) async {
//                       return carTypes
//                           .where((type) => type
//                               .toLowerCase()
//                               .contains(pattern.toLowerCase()))
//                           .toList();
//                     },
//                     itemBuilder: (context, suggestion) {
//                       return ListTile(title: Text(suggestion));
//                     },
//                     onSuggestionSelected: (suggestion) {
//                       setState(() {
//                         _selectedCarType = suggestion;
//                         _carTypeController.text = suggestion;
//                       });
//                       fetchChartData();
//                     },
//                     displayAllSuggestionWhenTap: true,
//                     isMultiSelectDropdown: false,
//                   ),
//                   const SizedBox(height: 20),
//                   // // Show tapped data details
//                   // if (_selectedData != null)
//                   //   Card(
//                   //     margin: const EdgeInsets.symmetric(vertical: 8),
//                   //     child: ListTile(
//                   //       title: Text(_selectedData!.carName,
//                   //           style:
//                   //               const TextStyle(fontWeight: FontWeight.bold)),
//                   //       subtitle: Text("Total: ${_selectedData!.value}"),
//                   //     ),
//                   //   ),
//                   Expanded(
//                     child: _chartData.isEmpty
//                         ? const Center(child: Text("No data available"))
//                         : SfCircularChart(
//                             title: ChartTitle(
//                                 text: "Car Availability ($_selectedCarType)"),
//                             legend: Legend(isVisible: true),
//                             series: <CircularSeries>[
//                               PieSeries<_CarChartData, String>(
//                                   dataSource: _chartData,
//                                   xValueMapper: (_CarChartData data, _) =>
//                                       data.carName,
//                                   yValueMapper: (_CarChartData data, _) =>
//                                       data.value,
//                                   dataLabelSettings: const DataLabelSettings(
//                                     isVisible: true,
//                                     labelPosition:
//                                         ChartDataLabelPosition.outside,
//                                   ),
//                                   // onPointTap: (ChartPointDetails details) {
//                                   //   setState(() {
//                                   //     _selectedData =
//                                   //         _chartData[details.pointIndex!];
//                                   //   });
//                                   // },

//                                   onPointTap: (ChartPointDetails details) {
//                                     final tappedData =
//                                         _chartData[details.pointIndex!];

//                                     // Show alert dialog with details
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) {
//                                         return AlertDialog(
//                                           title: Text("Car Details"),
//                                           content: Column(
//                                             mainAxisSize: MainAxisSize.min,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                   "Car Name: ${tappedData.carName}"),
//                                               Text(
//                                                   "Total: ${tappedData.value}"),
//                                             ],
//                                           ),
//                                           actions: [
//                                             TextButton(
//                                               onPressed: () {
//                                                 Navigator.of(context)
//                                                     .pop(); // Close the dialog
//                                               },
//                                               child: const Text("Close"),
//                                             ),
//                                           ],
//                                         );
//                                       },
//                                     );
//                                   })
//                             ],
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// class _CarChartData {
//   final String carName;
//   final int value;

//   _CarChartData({required this.carName, required this.value});
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:drop_down_search_field/drop_down_search_field.dart';

// Your API models
class CarChartData {
  String message;
  List<Datum> data;

  CarChartData({required this.message, required this.data});

  factory CarChartData.fromJson(Map<String, dynamic> json) => CarChartData(
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  int carBookingId;
  String selectedBookingType;
  DateTime travelfrom;
  DateTime destinationto;
  String designation;
  String cardetails;
  String carIntime;
  DateTime carOuttime;
  String currentState;
  DateTime startDate;
  String carno;

  Datum({
    required this.carBookingId,
    required this.selectedBookingType,
    required this.travelfrom,
    required this.destinationto,
    required this.designation,
    required this.cardetails,
    required this.carIntime,
    required this.carOuttime,
    required this.currentState,
    required this.startDate,
    required this.carno,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        carBookingId: json["carBookingId"],
        selectedBookingType: json["selectedBookingType"],
        travelfrom: DateTime.parse(json["travelfrom"]),
        destinationto: DateTime.parse(json["destinationto"]),
        designation: json["designation"],
        cardetails: json["cardetails"],
        carIntime: json["carIntime"],
        carOuttime: DateTime.parse(json["carOuttime"]),
        currentState: json["currentState"],
        startDate: DateTime.parse(json["startDate"]),
        carno: json["carno"],
      );

  Map<String, dynamic> toJson() => {
        "carBookingId": carBookingId,
        "selectedBookingType": selectedBookingType,
        "travelfrom": travelfrom.toIso8601String(),
        "destinationto": destinationto.toIso8601String(),
        "designation": designation,
        "cardetails": cardetails,
        "carIntime": carIntime,
        "carOuttime": carOuttime.toIso8601String(),
        "currentState": currentState,
        "startDate": startDate.toIso8601String(),
        "carno": carno,
      };
}

// Lightweight chart data class
class PieChartData {
  final String label;
  final int value;

  PieChartData({required this.label, required this.value});
}

// Convert API JSON string to CarChartData
CarChartData carChartDataFromJson(String str) =>
    CarChartData.fromJson(json.decode(str));

String carChartDataToJson(CarChartData data) => json.encode(data.toJson());

class CarChartsScreen extends StatefulWidget {
  const CarChartsScreen({Key? key}) : super(key: key);

  @override
  _CarChartsScreenState createState() => _CarChartsScreenState();
}

class _CarChartsScreenState extends State<CarChartsScreen> {
  bool _isLoading = false;
  String? _selectedCarType = "All";
  final TextEditingController _carTypeController = TextEditingController();

  final List<String> carTypes = ["All", "In", "Out"];
  List<PieChartData> _chartData = [];

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String url =
          "http://10.3.0.70:9042/api/Car_Conveyance_/Cars_Charts?selectedtype=$_selectedCarType";
      final response = await http.get(Uri.parse(url));
      print('Car charts URL: $url');

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        final CarChartData carChartData = carChartDataFromJson(response.body);

        // Directly map all returned data to chart
        List<PieChartData> chartData = carChartData.data.map((datum) {
          String label =
              "ID: ${datum.carBookingId}\nType: ${datum.selectedBookingType},\nCarNo: ${datum.cardetails}\nFrom: ${datum.travelfrom.toLocal().toString().split(' ')[0]}\nTo: ${datum.destinationto.toLocal().toString().split(' ')[0]}";
          return PieChartData(label: label, value: 1);
        }).toList();

        setState(() {
          _chartData = chartData;
        });
      } else {
        print("Failed to load chart data");
      }
    } catch (e) {
      print("Error fetching chart data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DropDownSearchField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _carTypeController,
                      decoration: const InputDecoration(
                        labelText: "Car Type",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return carTypes
                          .where((type) => type
                              .toLowerCase()
                              .contains(pattern.toLowerCase()))
                          .toList();
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(title: Text(suggestion));
                    },
                    onSuggestionSelected: (suggestion) {
                      setState(() {
                        _selectedCarType = suggestion;
                        _carTypeController.text = suggestion;
                      });
                      fetchChartData();
                    },
                    displayAllSuggestionWhenTap: true,
                    isMultiSelectDropdown: false,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _chartData.isEmpty
                        ? const Center(child: Text("No data available"))
                        : SfCircularChart(
                            title: ChartTitle(
                                text: "Car Bookings ($_selectedCarType)"),
                            legend: Legend(isVisible: false),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CircularSeries>[
                              PieSeries<PieChartData, String>(
                                dataSource: _chartData,
                                xValueMapper: (PieChartData data, _) =>
                                    data.label,
                                yValueMapper: (PieChartData data, _) =>
                                    data.value,
                                dataLabelMapper: (PieChartData data, _) =>
                                    data.label,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                ),
                                enableTooltip: true,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
