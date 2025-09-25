// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:http/http.dart' as http;
// import 'package:drop_down_search_field/drop_down_search_field.dart';

// // Your API models
// class CarChartData {
//   String message;
//   List<Datum> data;

//   CarChartData({required this.message, required this.data});

//   factory CarChartData.fromJson(Map<String, dynamic> json) => CarChartData(
//         message: json["message"],
//         data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "message": message,
//         "data": List<dynamic>.from(data.map((x) => x.toJson())),
//       };
// }

// class Datum {
//   int carBookingId;
//   String selectedBookingType;
//   DateTime travelfrom;
//   DateTime destinationto;
//   String designation;
//   String cardetails;
//   String carIntime;
//   DateTime? carOuttime;
//   String currentState;
//   DateTime startDate;
//   String carno;

//   Datum({
//     required this.carBookingId,
//     required this.selectedBookingType,
//     required this.travelfrom,
//     required this.destinationto,
//     required this.designation,
//     required this.cardetails,
//     required this.carIntime,
//     this.carOuttime,
//     required this.currentState,
//     required this.startDate,
//     required this.carno,
//   });

//   // factory Datum.fromJson(Map<String, dynamic> json) => Datum(
//   //       carBookingId: json["carBookingId"],
//   //       selectedBookingType: json["selectedBookingType"],
//   //       travelfrom: DateTime.parse(json["travelfrom"]),
//   //       destinationto: DateTime.parse(json["destinationto"]),
//   //       designation: json["designation"],
//   //       cardetails: json["cardetails"],
//   //       carIntime: json["carIntime"],
//   //       carOuttime: DateTime.parse(json["carOuttime"]),
//   //       currentState: json["currentState"],
//   //       startDate: DateTime.parse(json["startDate"]),
//   //       carno: json["carno"],
//   //     );

//   factory Datum.fromJson(Map<String, dynamic> json) {
//     DateTime? parseNullableDate(String? dateStr) {
//       if (dateStr == null || dateStr.isEmpty) {
//         return null;
//       }
//       return DateTime.parse(dateStr);
//     }

//     return Datum(
//       carBookingId: json["carBookingId"],
//       selectedBookingType: json["selectedBookingType"],
//       travelfrom: DateTime.parse(json["travelfrom"]),
//       destinationto: DateTime.parse(json["destinationto"]),
//       designation: json["designation"],
//       cardetails: json["cardetails"],
//       carIntime: json["carIntime"],
//       carOuttime: parseNullableDate(json["carOuttime"]),
//       currentState: json["currentState"],
//       startDate: DateTime.parse(json["startDate"]),
//       carno: json["carno"],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "carBookingId": carBookingId,
//         "selectedBookingType": selectedBookingType,
//         "travelfrom": travelfrom.toIso8601String(),
//         "destinationto": destinationto.toIso8601String(),
//         "designation": designation,
//         "cardetails": cardetails,
//         "carIntime": carIntime,
//         "carOuttime": carOuttime?.toIso8601String(),
//         "currentState": currentState,
//         "startDate": startDate.toIso8601String(),
//         "carno": carno,
//       };
// }

// // Lightweight chart data class
// class PieChartData {
//   final String label;
//   final int value;

//   PieChartData({required this.label, required this.value});
// }

// // Convert API JSON string to CarChartData
// CarChartData carChartDataFromJson(String str) =>
//     CarChartData.fromJson(json.decode(str));

// String carChartDataToJson(CarChartData data) => json.encode(data.toJson());

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
//   List<PieChartData> _chartData = [];
//   List<Datum> _datumList = []; // Store the original data

//   @override
//   void initState() {
//     super.initState();
//     fetchChartData();
//   }

//   Future<void> fetchChartData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final String url =
//           "http://10.3.0.70:9042/api/Car_Conveyance_/Cars_Charts?selectedtype=$_selectedCarType";
//       final response = await http.get(Uri.parse(url));
//       print('Car charts URL: $url');

//       if (response.statusCode == 200) {
//         print('Response: ${response.body}');
//         final CarChartData carChartData = carChartDataFromJson(response.body);

//         // Directly map all returned data to chart
//         List<PieChartData> chartData = carChartData.data.map((datum) {
//           String label =
//               "ID: ${datum.carBookingId}\nType: ${datum.selectedBookingType},\nCarNo: ${datum.cardetails}\nFrom: ${datum.travelfrom.toLocal().toString().split(' ')[0]}\nTo: ${datum.destinationto.toLocal().toString().split(' ')[0]}\nCurrent State:${datum.currentState}";
//           return PieChartData(label: label, value: 1);
//         }).toList();

//         setState(() {
//           _chartData = chartData;
//           _datumList = carChartData.data;
//         });
//       } else {
//         print("Failed to load chart data");
//       }
//     } catch (e) {
//       print("Error fetching chart data: $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     String cardDetailsText = _datumList.isEmpty
//         ? "No cars"
//         : _datumList.map((datum) => datum.cardetails).join(", ");

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
//                   Expanded(
//                     child: _chartData.isEmpty
//                         ? const Center(child: Text("No data available"))
//                         : Column(
//                             children: [
//                               // Styled Card showing car details
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 10),
//                                 child: Card(
//                                   elevation: 4,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(16),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           "Car Bookings ($_selectedCarType)",
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.blueAccent,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           cardDetailsText,
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.black87,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: SfCircularChart(
//                                   // title: ChartTitle(
//                                   //   // text: "Car Bookings ($_selectedCarType)"),
//                                   //   text:
//                                   //       "Car Bookings ($_selectedCarType): $cardDetailsText",
//                                   // ),
//                                   legend: Legend(isVisible: false),
//                                   tooltipBehavior:
//                                       TooltipBehavior(enable: true),
//                                   series: <CircularSeries>[
//                                     PieSeries<PieChartData, String>(
//                                       dataSource: _chartData,
//                                       xValueMapper: (PieChartData data, _) =>
//                                           data.label,
//                                       yValueMapper: (PieChartData data, _) =>
//                                           data.value,
//                                       dataLabelMapper: (PieChartData data, _) =>
//                                           data.label,
//                                       dataLabelSettings:
//                                           const DataLabelSettings(
//                                         isVisible: true,
//                                         labelPosition:
//                                             ChartDataLabelPosition.outside,
//                                       ),
//                                       enableTooltip: true,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/model/get_car_in_out_data_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CarChartsScreen extends StatefulWidget {
  const CarChartsScreen({super.key});

  @override
  State<CarChartsScreen> createState() => _CarChartsScreenState();
}

class _CarChartsScreenState extends State<CarChartsScreen> {
  final TextEditingController _statusController = TextEditingController();
  String? _selectedStatus;
  List<Datum> _carData = [];
  List<String> statusOptions = [
    'In',
    'Out',
    // Add more statuses if needed
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Set default as OUT
    _selectedStatus = "Out";
    _statusController.text = "Out";

    // ✅ Fetch OUT cars initially
    _fetchCars("Out");
  }

  /// Fetch cars based on selected status
  // Future<void> _fetchCars(String status) async {
  //   final url =
  //       "http://10.3.0.70:9042/api/Car_Conveyance_/Ps_Cars?status=$status";
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       final dataModel = getCarInOutDataModelFromJson(response.body);
  //       setState(() {
  //         _carData = dataModel.data;
  //       });
  //     } else {
  //       throw Exception('Failed to load cars');
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> _fetchCars(String status) async {
    final url = Uri.parse('${ApiHelper.carConveynanceUrl}Ps_Cars?status=$status');
    
    // final url =
    //     "http://10.3.0.70:9042/api/Car_Conveyance_/Ps_Cars?status=$status";
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dataModel = getCarInOutDataModelFromJson(response.body);

        if (dataModel.data.isEmpty) {
          // ✅ No records found
          setState(() => _carData = []);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No cars found for selected status")),
          );
        } else {
          setState(() => _carData = dataModel.data);
        }
      } else {
        setState(() => _carData = []);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load cars")),
        );
      }
    } catch (e) {
      print(e);
      setState(() => _carData = []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No cars")),
      );
    }
  }

  /// Prepare pie chart data: each car becomes its own slice
  List<_PieData> _prepareChartData() {
    return _carData.map((car) {
      return _PieData(
        "${car.travellers} - ${car.cardetails}", // Label
        1, // Count per car
        car, // Store individual car
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Dropdown for status selection
            DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _statusController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Select Status",
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return statusOptions
                    .where((option) =>
                        option.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(title: Text(suggestion));
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  _selectedStatus = suggestion;
                  _statusController.text = suggestion;
                });
                _fetchCars(suggestion);
              },
              displayAllSuggestionWhenTap: true,
              isMultiSelectDropdown: false,
            ),

            const SizedBox(height: 20),

            /// Pie chart
            Expanded(
              child: chartData.isEmpty
                  ? const Center(child: Text("No data to display"))
                  : SfCircularChart(
                      title: ChartTitle(
                          text: 'Car Details for ${_selectedStatus ?? ""}'),
                      legend: Legend(isVisible: false),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        builder: (dynamic data, dynamic point, dynamic series,
                            int pointIndex, int seriesIndex) {
                          final _PieData pieData = data;
                          final car = pieData.car;
                          return Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.white,
                            child: Text(
                              "Travellers: ${car.travellers}\nCar: ${car.cardetails}\nStatus: ${car.currentState}\nFrom: ${car.travelfrom}\nTo: ${car.destinationto}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                      series: <PieSeries<_PieData, String>>[
                        PieSeries<_PieData, String>(
                          dataSource: chartData,
                          xValueMapper: (_PieData data, _) => data.label,
                          yValueMapper: (_PieData data, _) => data.count,
                          dataLabelMapper: (_PieData data, _) => data.label,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                          enableTooltip: true,
                        )
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}

/// Pie chart data model
class _PieData {
  final String label; // Label for slice
  final int count; // Always 1 per car
  final Datum car; // Store the car for tooltip
  _PieData(this.label, this.count, this.car);
}
