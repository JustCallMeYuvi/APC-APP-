// // // To parse the JSON data into a List of Maps
// // List<Map<String, String>> tCodesFromJson(String str) =>
// //     List<Map<String, String>>.from(
// //       json.decode(str).map((x) => Map<String, String>.from(x)),
// //     );

// // String tCodesToJson(List<Map<String, String>> data) =>
// //     json.encode(List<dynamic>.from(
// //       data.map((x) => Map.from(x).map(
// //             (k, v) => MapEntry<String, dynamic>(k, v),
// //           )),
// //     ));

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:syncfusion_flutter_charts/charts.dart';

// class TCodesScreen extends StatefulWidget {
//   const TCodesScreen({Key? key}) : super(key: key);

//   @override
//   _TCodesScreenState createState() => _TCodesScreenState();
// }

// class _TCodesScreenState extends State<TCodesScreen> {
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _tCodes = [];
//   String _errorMessage = '';
//   List<ChartData> _chartData = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchTCodes();
//   }

//   Future<void> _fetchTCodes() async {
//     const baseUrl =
//         'http://acqy-bwapp2.apachefootwear.com:8000/sap/zcl_sap_zsd065p?sap-client=800';

//     final requestBody = [
//       {
//         "S_AUART": "ZOR1",
//         "S_VKORG": "5000",
//         "S_BSTNK": "",
//         "S_ZPONO": "",
//         "S_VBELN": "1000194844",
//         "S_ZZLH": "",
//         "S_ZKUUNR": "",
//         "S_ZPLCO": "",
//         "S_KUNNR": "",
//         "S_ERDAT": "",
//         "S_ERNAM": "",
//         "S_MATNR": "",
//         "S_ZPSDD": "",
//         "S_ZPODD": "",
//         "S_ZLPD": "",
//         "S_ZPLD": "",
//         "S_ZPPD": "",
//         "S_CRD": "",
//         "S_ZORDER": "",
//         "S_ZCLASS": "",
//         "S_ZSHIPM": "",
//         "S_ZFND": "",
//         "S_ZFACT": "",
//         "S_ABGRU": "",
//         "S_ZCSID": "",
//         "S_ZMARPO": "",
//         "S_MATNR2": "",
//         "S_ZDD_MS": "",
//         "S_ZXL": "",
//         "S_ZMATNR": "",
//         "S_ZUT_MS": "",
//         "S_ZXT_MS": "",
//         "S_ZXB": "",
//         "S_ZDQ": ""
//       }
//     ];

//     try {
//       final response = await http.post(
//         Uri.parse(baseUrl),
//         headers: {
//           'Authorization':
//               'Basic ${base64Encode(utf8.encode('APC_IT_TEAM:123456789'))}',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);

//         // setState(() {
//         //   _tCodes =
//         //       data.map((item) => Map<String, dynamic>.from(item)).toList();
//         //   _isLoading = false;
//         // });

//         setState(() {
//           _tCodes =
//               data.map((item) => Map<String, dynamic>.from(item)).toList();
//           _chartData = _tCodes.map((item) {
//             return ChartData(
//               xValue: item['maktx'] ?? 'No Material',
//               yValue: double.tryParse(item['kwmeng']?.toString() ?? '0') ?? 0,
//               companyName: item['zfname'] ?? 'Unknown', // Company Name
//               salesOrder: item['vbeln'] ?? 'Unknown', // Sales Order Number
//               planDate: item['zpld'] ?? 'Unknown', // Plan Date
//               crd: item['zcrd'] ?? 'Unknown', // CRD
//               destination: item['landxEn'] ?? 'Unknown', // Destination
//             );
//           }).toList();
//           _isLoading = false;
//         });
//         // Print the transformed chart data for debugging
//         print('Chart Data: $_chartData');
//       } else {
//         setState(() {
//           _errorMessage =
//               'Error: ${response.statusCode} ${response.reasonPhrase}';
//           _isLoading = false;
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _errorMessage = 'Error fetching data: $error';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('T-Codes Screen'),
//       ),
//       // body: _isLoading
//       //     ? Center(child: CircularProgressIndicator())
//       //     : _errorMessage.isNotEmpty
//       //         ? Center(child: Text(_errorMessage))
//       //         : ListView.builder(
//       //             itemCount: _tCodes.length,
//       //             itemBuilder: (context, index) {
//       //               final item = _tCodes[index];
//       //               // Extracting only the required fields
//       //               final Map<String, dynamic> filteredData = {
//       //                 'Company Name': item['zfname'],
//       //                 'Sales Order No.': item['vbeln'],
//       //                 'Material Description': item['maktx'],
//       //                 'Plan Date': item['zpld'],
//       //                 'CRD': item['zcrd'],
//       //                 'Destination': item['landxEn'],
//       //                 'Order Quantity': item['kwmeng'],
//       //               };
//       //               return Card(
//       //                 child: ListTile(
//       //                   title: Text(
//       //                     'Details for VBELN: ${item['vbeln'] ?? 'No Data'}',
//       //                     style: TextStyle(color: Colors.red),
//       //                   ),
//       //                   // subtitle: Column(
//       //                   //   crossAxisAlignment: CrossAxisAlignment.start,
//       //                   //   children: item.entries.map((entry) {
//       //                   //     return Text(
//       //                   //       '${entry.key}: ${entry.value ?? 'No Data'}',
//       //                   //       style: TextStyle(fontSize: 14),
//       //                   //     );
//       //                   //   }).toList(),
//       //                   // ),
//       //                   subtitle: Column(
//       //                     crossAxisAlignment: CrossAxisAlignment.start,
//       //                     children: filteredData.entries.map((entry) {
//       //                       return Text(
//       //                         '${entry.key}: ${entry.value ?? 'No Data'}',
//       //                         style: TextStyle(fontSize: 14),
//       //                       );
//       //                     }).toList(),
//       //                   ),
//       //                 ),
//       //               );
//       //             },
//       //           ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _errorMessage.isNotEmpty
//               ? Center(child: Text(_errorMessage))
//               : _chartData.isNotEmpty
//                   ? Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child:
//                           //  SfCircularChart(
//                           //   title: ChartTitle(text: 'Material vs Order Quantity'),
//                           //   legend: Legend(isVisible: true),
//                           //   tooltipBehavior: TooltipBehavior(
//                           //     enable: true,
//                           //     header: 'Order Details',
//                           //     format:
//                           //         'point.x: point.y\nCompany: {point.companyName}\nSales Order: {point.salesOrder}\nPlan Date: {point.planDate}\nCRD: {point.crd}\nDestination: {point.destination}',
//                           //   ),
//                           //   series: <CircularSeries>[
//                           //     PieSeries<ChartData, String>(
//                           //       dataSource: _chartData,
//                           //       xValueMapper: (ChartData data, _) => data.xValue,
//                           //       yValueMapper: (ChartData data, _) => data.yValue,
//                           //       dataLabelSettings:
//                           //           DataLabelSettings(isVisible: true),
//                           //     ),
//                           //   ],
//                           // ),
//                           SfCircularChart(
//                         title: ChartTitle(text: 'Material vs Order Quantity'),
//                         legend: Legend(isVisible: true),
//                         tooltipBehavior: TooltipBehavior(
//                           enable: true,
//                           builder: (dynamic data,
//                               ChartPoint<dynamic> point,
//                               ChartSeries<dynamic, dynamic> series,
//                               int pointIndex,
//                               int seriesIndex) {
//                             final chartData =
//                                 data as ChartData; // Access ChartData directly
//                             return Container(
//                               height: 170,
//                               color: Colors.white,
//                               padding: EdgeInsets.all(8),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: <Widget>[
//                                   Text('Material: ${chartData.xValue}',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold)),
//                                   Text('Order Quantity: ${chartData.yValue}'),
//                                   Text('Company: ${chartData.companyName}'),
//                                   Text('Sales Order: ${chartData.salesOrder}'),
//                                   Text('Plan Date: ${chartData.planDate}'),
//                                   Text('CRD: ${chartData.crd}'),
//                                   Text('Destination: ${chartData.destination}'),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                         series: <CircularSeries>[
//                           PieSeries<ChartData, String>(
//                             dataSource: _chartData,
//                             xValueMapper: (ChartData data, _) => data.xValue,
//                             yValueMapper: (ChartData data, _) => data.yValue,
//                             dataLabelSettings:
//                                 DataLabelSettings(isVisible: true),
//                           ),
//                         ],
//                       ))
//                   : Center(
//                       child: Text('No data available for charting.'),
//                     ),
//     );
//   }
// }

// class ChartData {
//   final String xValue; // Material Description
//   final double yValue; // Order Quantity
//   final String companyName; // Company Name
//   final String salesOrder; // Sales Order Number
//   final String planDate; // Plan Date
//   final String crd; // CRD
//   final String destination; // Destination

//   ChartData({
//     required this.xValue,
//     required this.yValue,
//     required this.companyName,
//     required this.salesOrder,
//     required this.planDate,
//     required this.crd,
//     required this.destination,
//   });
//   // Override toString() to print the actual values of ChartData
//   @override
//   String toString() {
//     return 'ChartData(xValue: $xValue, yValue: $yValue, companyName: $companyName, salesOrder: $salesOrder, planDate: $planDate, crd: $crd, destination: $destination)';
//   }
// }

// here using plan date base code
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class TCodesScreen extends StatefulWidget {
//   const TCodesScreen({Key? key}) : super(key: key);

//   @override
//   _TCodesScreenState createState() => _TCodesScreenState();
// }

// class _TCodesScreenState extends State<TCodesScreen> {
//   final TextEditingController _tcodeController = TextEditingController();
//   final TextEditingController _salesOrderController = TextEditingController();
//   DateTime? _selectedPlanDate;
//   bool _isLoading = false;
//   List<ChartData> _chartData = [];
//   String _errorMessage = '';

//   // Future<void> _fetchTCodes(
//   //     String tcode, String salesOrder, DateTime planDate) async {
//   //   setState(() {
//   //     _isLoading = true;
//   //     _errorMessage = '';
//   //     _chartData = [];
//   //   });

//   //   final String baseUrl =
//   //       'http://acqy-bwapp2.apachefootwear.com:8000/sap/zcl_sap_${tcode}?sap-client=800';

//   //   final requestBody = [
//   //     {
//   //       "S_AUART": "ZOR1",
//   //       "S_VKORG": "5000",
//   //       "S_BSTNK": "",
//   //       "S_ZPONO": "",
//   //       "S_VBELN": salesOrder,
//   //       "S_ZPLD": planDate.toIso8601String().split('T')[0],
//   //       // Additional fields omitted for brevity
//   //     }
//   //   ];

//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse(baseUrl),
//   //       headers: {
//   //         'Authorization':
//   //             'Basic ${base64Encode(utf8.encode('APC_IT_TEAM:123456789'))}',
//   //         'Content-Type': 'application/json',
//   //       },
//   //       body: jsonEncode(requestBody),
//   //     );

//   //     if (response.statusCode == 200) {
//   //       final List<dynamic> data = json.decode(response.body);
//   //       setState(() {
//   //         _chartData = data.map((item) {
//   //           return ChartData(
//   //             xValue: item['maktx'] ?? 'No Material',
//   //             yValue: double.tryParse(item['kwmeng']?.toString() ?? '0') ?? 0,
//   //             companyName: item['zfname'] ?? 'Unknown',
//   //             salesOrder: item['vbeln'] ?? 'Unknown',
//   //             planDate: item['zpld'] ?? 'Unknown',
//   //             crd: item['zcrd'] ?? 'Unknown',
//   //             destination: item['landxEn'] ?? 'Unknown',
//   //           );
//   //         }).toList();
//   //       });
//   //     } else {
//   //       setState(() {
//   //         _errorMessage =
//   //             'Error: ${response.statusCode} ${response.reasonPhrase}';
//   //       });
//   //     }
//   //   } catch (error) {
//   //     setState(() {
//   //       _errorMessage = 'Error fetching data: $error';
//   //     });
//   //   } finally {
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }
//   Future<void> _fetchTCodes(
//       String tcode, String salesOrder, DateTime planDate) async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//       _chartData = [];
//     });

//     final String baseUrl =
//         'http://acqy-bwapp2.apachefootwear.com:8000/sap/zcl_sap_${tcode}?sap-client=800';

//     final requestBody = [
//       {
//         "S_AUART": "ZOR1", // Sales Document Type
//         "S_VKORG": "5000", // Sales Organization
//         "S_BSTNK":
//             "", // Customer Purchase Order Number (can be left empty if not required)
//         "S_ZPONO":
//             "", // Reference Purchase Order Number (can be left empty if not required)
//         "S_VBELN": salesOrder, // Sales Order Number (from input)
//         "S_ZPLCO":
//             "", // Sales Order Currency (can be left empty if not required)
//         "S_KUNNR": "", // Customer Number (can be left empty if not required)
//         "S_ERDAT": "", // Document Date (can be left empty if not required)
//         "S_ERNAM":
//             "", // Name of the person who created the document (can be left empty if not required)
//         "S_MATNR": "", // Material Number (can be left empty if not required)
//         "S_ZPSDD":
//             "", // Planned Delivery Date (can be left empty if not required)
//         "S_ZPODD": "", // Delivery Date (can be left empty if not required)
//         "S_ZLPD":
//             "", // Planned Shipping Date (can be left empty if not required)
//         "S_ZPLD":
//             planDate.toIso8601String().split('T')[0], // Plan Date (from input)
//         "S_ZPPD":
//             "", // Planned Posting Date (can be left empty if not required)
//         "S_CRD": "", // Credit Control (can be left empty if not required)
//         "S_ZORDER": "", // Order Type (can be left empty if not required)
//         "S_ZCLASS": "", // Classification (can be left empty if not required)
//         "S_ZSHIPM": "", // Shipping Method (can be left empty if not required)
//         "S_ZFND": "", // Foundry (can be left empty if not required)
//         "S_ZFACT": "", // Factoring (can be left empty if not required)
//         "S_ABGRU":
//             "", // Goods Movement Reason (can be left empty if not required)
//         "S_ZCSID":
//             "", // Customer Service ID (can be left empty if not required)
//         "S_ZMARPO":
//             "", // Material Purchase Order (can be left empty if not required)
//         "S_MATNR2":
//             "", // Secondary Material (can be left empty if not required)
//         "S_ZDD_MS": "", // Delivery Date (can be left empty if not required)
//         "S_ZXL": "", // Delivery Instruction (can be left empty if not required)
//         "S_ZMATNR": "", // Material Number 2 (can be left empty if not required)
//         "S_ZUT_MS": "", // Material Status (can be left empty if not required)
//         "S_ZXT_MS": "", // Material Type (can be left empty if not required)
//         "S_ZXB": "", // Ship-to party (can be left empty if not required)
//         "S_ZDQ": "", // Additional info (can be left empty if not required)
//       }
//     ];

//     // Print the URL and request body
//     print('URL: $baseUrl');
//     print('Request Body: ${jsonEncode(requestBody)}');

//     try {
//       final response = await http.post(
//         Uri.parse(baseUrl),
//         headers: {
//           'Authorization':
//               'Basic ${base64Encode(utf8.encode('APC_IT_TEAM:123456789'))}',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           _chartData = data.map((item) {
//             return ChartData(
//               xValue: item['maktx'] ?? 'No Material',
//               yValue: double.tryParse(item['kwmeng']?.toString() ?? '0') ?? 0,
//               companyName: item['zfname'] ?? 'Unknown',
//               salesOrder: item['vbeln'] ?? 'Unknown',
//               planDate: item['zpld'] ?? 'Unknown',
//               crd: item['zcrd'] ?? 'Unknown',
//               destination: item['landxEn'] ?? 'Unknown',
//             );
//           }).toList();
//         });
//       } else {
//         // Print the error status and response body
//         print('Response Body: ${response.body}');
//         setState(() {
//           _errorMessage =
//               'Error: ${response.statusCode} ${response.reasonPhrase}';
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _errorMessage = 'Error fetching data: $error';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _selectDate(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedPlanDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (pickedDate != null && pickedDate != _selectedPlanDate) {
//       setState(() {
//         _selectedPlanDate = pickedDate;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('T-Codes Screen'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _tcodeController,
//               decoration: const InputDecoration(labelText: 'Enter T-Code'),
//             ),
//             TextField(
//               controller: _salesOrderController,
//               decoration:
//                   const InputDecoration(labelText: 'Enter Sales Order Number'),
//               keyboardType: TextInputType.number,
//             ),
//             Row(
//               children: [
//                 Text(
//                   _selectedPlanDate == null
//                       ? 'Select Plan Date'
//                       : 'Plan Date: ${DateFormat.yMd().format(_selectedPlanDate!)}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const Spacer(),
//                 ElevatedButton(
//                   onPressed: () => _selectDate(context),
//                   child: const Text('Pick Date'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 if (_tcodeController.text.isNotEmpty &&
//                     _salesOrderController.text.isNotEmpty &&
//                     _selectedPlanDate != null) {
//                   _fetchTCodes(_tcodeController.text.trim(),
//                       _salesOrderController.text.trim(), _selectedPlanDate!);
//                 }
//               },
//               child: const Text('Submit'),
//             ),
//             if (_isLoading)
//               const Center(child: CircularProgressIndicator())
//             else if (_errorMessage.isNotEmpty)
//               Center(child: Text(_errorMessage))
//             else if (_chartData.isNotEmpty)
//               Expanded(
//                 child: SfCircularChart(
//                   title: ChartTitle(text: 'Material vs Order Quantity'),
//                   legend: Legend(isVisible: true),
//                   series: <CircularSeries>[
//                     PieSeries<ChartData, String>(
//                       dataSource: _chartData,
//                       xValueMapper: (ChartData data, _) => data.xValue,
//                       yValueMapper: (ChartData data, _) => data.yValue,
//                       dataLabelSettings:
//                           const DataLabelSettings(isVisible: true),
//                     ),
//                   ],
//                 ),
//               )
//             else
//               const Center(child: Text('No data available')),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ChartData {
//   final String xValue;
//   final double yValue;
//   final String companyName;
//   final String salesOrder;
//   final String planDate;
//   final String crd;
//   final String destination;

//   ChartData({
//     required this.xValue,
//     required this.yValue,
//     required this.companyName,
//     required this.salesOrder,
//     required this.planDate,
//     required this.crd,
//     required this.destination,
//   });
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class TCodesScreen extends StatefulWidget {
  @override
  _TCodesScreenState createState() => _TCodesScreenState();
}

class _TCodesScreenState extends State<TCodesScreen> {
  final TextEditingController _tcodeController = TextEditingController();
  final TextEditingController _salesOrderController = TextEditingController();
  final TextEditingController _dnNumberController = TextEditingController();

  bool _isLoading = false;
  List<ChartData> _chartData = [];
  String _errorMessage = '';

  Future<void> _fetchTCodes(
      String tcode, String salesOrder, String dnNumber) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _chartData = [];
    });

    final String baseUrl =
        'http://acqy-bwapp2.apachefootwear.com:8000/sap/zcl_sap_${tcode}?sap-client=800';
    print(baseUrl);
    final requestBody = [
      {
        "S_VKORG": "5000",
        "S_DVBELN": dnNumber,
        // "S_DNNMBER": dnNumber,
        // "S_VKORG": "5000",
        "S_AUART": "",
        "S_KUNNR2": "",
        // "S_DVBELN": "8001722102",
        "S_BSTNK": "",
        "S_VBELN": "",
        "S_ERNAM": "",
        "S_ERDAT": "",
        "S_ZPODD": "",
        "S_ZPSDD": "",
        "S_ZPLANT": "",
        "S_CLIENT": "",
        "S_ZFP": "",
        "S_ZPONO": "",
        "S_KUNNR": "",
        "S_MATNR": "",
        "S_MDATE": "",
        "S_WADAT": "",
        "S_AENAM": "",
        "S_AEDAT": "",
        "S_ZDZDH": ""
        // Add more fields here if necessary.
      }
    ];

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('APC_IT_TEAM:123456789'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _chartData = data.map((item) {
            return ChartData(
              xValue: item['maktx'] ?? 'No Model',
              yValue:
                  double.tryParse(item['rfmng']?.toString()?.trim() ?? '0') ??
                      0,
              dnNumber: item['vbeln'] ?? 'Unknown',
              size: item['wrfCharstc2'] ?? 'Unknown',
              outboundQty:
                  double.tryParse(item['rfmng']?.toString()?.trim() ?? '0') ??
                      0,
              materialCode: item['matnr'] ?? 'Unknown',
              description: item['maktx2'] ?? 'Unknown',
              currency: item['waerk'] ?? 'Unknown',
              deliveryAmount:
                  double.tryParse(item['kzwi1']?.toString()?.trim() ?? '0') ??
                      0,
              country: item['landxe'] ?? 'Unknown',
              orderQty:
                  double.tryParse(item['kwmeng']?.toString()?.trim() ?? '0') ??
                      0,
              deliveryQty:
                  double.tryParse(item['lfimg']?.toString()?.trim() ?? '0') ??
                      0,
            );
          }).toList();
        });
      } else {
        setState(() {
          _errorMessage =
              'Error: ${response.statusCode} ${response.reasonPhrase}';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching data: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('T-Codes Screen'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _customInputField(
                controller: _tcodeController,
                label: 'Enter T-Code',
                icon: Icons.code,
              ),
              const SizedBox(height: 10),
              _customInputField(
                controller: _salesOrderController,
                label: 'Enter Sales Order Number',
                icon: Icons.receipt,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _customInputField(
                controller: _dnNumberController,
                label: 'Enter DN Number',
                icon: Icons.confirmation_number,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_tcodeController.text.isNotEmpty &&
                      (_salesOrderController.text.isNotEmpty ||
                          _dnNumberController.text.isNotEmpty)) {
                    _fetchTCodes(
                      _tcodeController.text.trim(),
                      _salesOrderController.text.trim(),
                      _dnNumberController.text.trim(),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please enter TCode and at least one of Sales Order or DN Number'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Submit',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage.isNotEmpty)
                Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              else
                _buildDataDisplay(),
            ],
          ),
        )

        //  Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Column(
        //     children: [
        //       // TextField(
        //       //   controller: _tcodeController,
        //       //   decoration: const InputDecoration(labelText: 'Enter T-Code'),
        //       // ),
        //       // TextField(
        //       //   controller: _salesOrderController,
        //       //   decoration:
        //       //       const InputDecoration(labelText: 'Enter Sales Order Number'),
        //       //   keyboardType: TextInputType.number,
        //       // ),
        //       // TextField(
        //       //   controller: _dnNumberController,
        //       //   decoration: const InputDecoration(labelText: 'Enter DN Number'),
        //       //   keyboardType: TextInputType.number,
        //       // ),

        //        _buildInputField(
        //         controller: _tcodeController,
        //         label: 'Enter T-Code',
        //         icon: Icons.code,
        //       ),
        //       const SizedBox(height: 10),
        //       _buildInputField(
        //         controller: _salesOrderController,
        //         label: 'Enter Sales Order Number',
        //         icon: Icons.receipt,
        //         inputType: TextInputType.number,
        //       ),
        //       const SizedBox(height: 10),
        //       _buildInputField(
        //         controller: _dnNumberController,
        //         label: 'Enter DN Number',
        //         icon: Icons.confirmation_number,
        //         inputType: TextInputType.number,
        //       ),
        //       const SizedBox(height: 16),
        //       // ElevatedButton(
        //       //   onPressed: () {
        //       //     if (_tcodeController.text.isNotEmpty &&
        //       //         _salesOrderController.text.isNotEmpty &&
        //       //         _dnNumberController.text.isNotEmpty) {
        //       //       _fetchTCodes(
        //       //         _tcodeController.text.trim(),
        //       //         _salesOrderController.text.trim(),
        //       //         _dnNumberController.text.trim(),
        //       //       );
        //       //     }
        //       //   },
        //       //   child: const Text('Submit'),
        //       // ),

        //       ElevatedButton(
        //         onPressed: () {
        //           // Check if TCode is not empty and at least one of Sales Order or DN Number is filled
        //           if (_tcodeController.text.isNotEmpty &&
        //               (_salesOrderController.text.isNotEmpty ||
        //                   _dnNumberController.text.isNotEmpty)) {
        //             _fetchTCodes(
        //               _tcodeController.text.trim(),
        //               _salesOrderController.text.trim(),
        //               _dnNumberController.text.trim(),
        //             );
        //           } else {
        //             // Show an error message if conditions are not met
        //             ScaffoldMessenger.of(context).showSnackBar(
        //               SnackBar(
        //                 content: const Text(
        //                     'Please enter TCode and at least one of Sales Order or DN Number'),
        //               ),
        //             );
        //           }
        //         },
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Colors.teal,
        //           padding: const EdgeInsets.symmetric(vertical: 12.0),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(8.0),
        //           ),
        //         ),
        //         child: const Text('Submit'),
        //       ),

        //       // if (_isLoading)
        //       //   const Center(child: CircularProgressIndicator())
        //       // else if (_errorMessage.isNotEmpty)
        //       //   Center(child: Text(_errorMessage))
        //       // else if (_chartData.isNotEmpty)
        //       //   Expanded(
        //       //     child: SfCircularChart(
        //       //       title: ChartTitle(text: 'Material vs Outbound Quantity'),
        //       //       legend: Legend(isVisible: true),
        //       //       series: <CircularSeries>[
        //       //         PieSeries<ChartData, String>(
        //       //           dataSource: _chartData,
        //       //           xValueMapper: (ChartData data, _) => data.xValue,
        //       //           yValueMapper: (ChartData data, _) => data.yValue,
        //       //           dataLabelSettings:
        //       //               const DataLabelSettings(isVisible: true),
        //       //         ),
        //       //       ],
        //       //     ),
        //       //   )
        //       // else
        //       //   const Center(child: Text('No data available')),

        //       _isLoading
        //           ? const CircularProgressIndicator()
        //           : Expanded(child: _buildDataDisplay()),
        //       if (_errorMessage.isNotEmpty)
        //         Text(_errorMessage, style: const TextStyle(color: Colors.red))
        //     ],
        //   ),
        // ),
        );
  }

  Widget _customInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }

  Widget _buildDataDisplay() {
    if (_chartData.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    final totalOrderQty =
        _chartData.fold(0.0, (sum, item) => sum + item.orderQty);
    final totalDeliveryQty =
        _chartData.fold(0.0, (sum, item) => sum + item.deliveryQty);

    // Create a list with just two entries: Order Quantity and Delivery Quantity
    List<ChartData> pieData = [
      ChartData(
        xValue: "Order Quantity",
        yValue: totalOrderQty, // Use the aggregated orderQty
        dnNumber: '',
        size: '',
        outboundQty: 0.0,
        materialCode: '',
        description: '',
        currency: '',
        deliveryAmount: 0.0,
        country: '',
        orderQty: totalOrderQty, // Set the total orderQty
        deliveryQty: 0.0, // No deliveryQty for this slice
      ),
      ChartData(
        xValue: "Delivery Quantity",
        yValue: totalDeliveryQty, // Use the aggregated deliveryQty
        dnNumber: '',
        size: '',
        outboundQty: 0.0,
        materialCode: '',
        description: '',
        currency: '',
        deliveryAmount: 0.0,
        country: '',
        orderQty: 0.0, // No orderQty for this slice
        deliveryQty: totalDeliveryQty, // Set the total deliveryQty
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          // SfCircularChart(
          //   series: <CircularSeries>[
          //     // PieSeries<ChartData, String>(
          //     //   dataSource: _chartData,
          //     //   xValueMapper: (data, _) => data.xValue,
          //     //   yValueMapper: (data, _) => data.yValue,
          //     // ),
          //     // Order Quantity pie chart
          //     PieSeries<ChartData, String>(
          //       dataSource: _chartData,
          //       xValueMapper: (ChartData data, _) =>
          //           data.xValue, // Material (or x-axis value)
          //       yValueMapper: (ChartData data, _) =>
          //           data.orderQty, // Order Quantity (y-axis value)
          //       name: 'Order Qty',
          //       dataLabelSettings:
          //           const DataLabelSettings(isVisible: true), // Show data labels
          //     ),
          //     // Delivery Quantity pie chart
          //     PieSeries<ChartData, String>(
          //       dataSource: _chartData,
          //       xValueMapper: (ChartData data, _) =>
          //           data.xValue, // Material (or x-axis value)
          //       yValueMapper: (ChartData data, _) =>
          //           data.deliveryQty, // Delivery Quantity (y-axis value)
          //       name: 'Delivery Qty',
          //       dataLabelSettings:
          //           const DataLabelSettings(isVisible: true), // Show data labels
          //     ),
          //   ],
          // ),
          SfCircularChart(
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: pieData, // Use the pieData for only two entries
                xValueMapper: (ChartData data, _) =>
                    data.xValue, // Labels for slices
                yValueMapper: (ChartData data, _) =>
                    data.yValue, // Values for slices
                name: 'Order & Delivery Qty',
                dataLabelSettings: const DataLabelSettings(
                    isVisible: true), // Show data labels
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text('Total Order Quantity',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(totalOrderQty.toStringAsFixed(2)),
                ],
              ),
              Column(
                children: [
                  const Text('Total Delivery Quantity',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(totalDeliveryQty.toStringAsFixed(2)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Below this, add the fetched API data (below the Row)
          if (_chartData.isNotEmpty) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('T Codes Details: ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                SizedBox(
                  height: 10,
                ),
                ..._chartData.map((data) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('Material Code: ${data.materialCode}'),
                      _tcodes_Details('Material Code:', data.materialCode),
                      _tcodes_Details('Description:', data.description),

                      _tcodes_Details('Size:', data.size),

                      // Text('Delivery Amount: ${data.deliveryAmount}'),
                      _tcodes_Details('Delivery Amount:', data.deliveryAmount),
                      _tcodes_Details('Country:', data.country),
                      _tcodes_Details('Currency:', data.currency),
                      Divider(
                        thickness: 2,
                        color: Colors.red,
                      ),
                      // const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _tcodes_Details(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value
                  .toString(), // Converts the value to string, no matter if it's int, double, or String
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String xValue;
  final double yValue;
  final String dnNumber;
  final String size;
  final double outboundQty;
  final String materialCode;
  final String description;
  final String currency;
  final double deliveryAmount;
  final String country;
  final double orderQty;
  final double deliveryQty;

  ChartData({
    required this.xValue,
    required this.yValue,
    required this.dnNumber,
    required this.size,
    required this.outboundQty,
    required this.materialCode,
    required this.description,
    required this.currency,
    required this.deliveryAmount,
    required this.country,
    required this.orderQty,
    required this.deliveryQty,
  });
}
