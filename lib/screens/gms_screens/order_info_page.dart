import 'dart:convert';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class OrderInfoPage extends StatefulWidget {
  final LoginModelApi userData;
  const OrderInfoPage({Key? key, required this.userData}) : super(key: key);

  @override
  _OrderInfoPageState createState() => _OrderInfoPageState();
}

class _OrderInfoPageState extends State<OrderInfoPage> {
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _seasonController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();

  final TextEditingController _modelController = TextEditingController();

  final TextEditingController _typeController = TextEditingController();

  String? selectedCompany;
  // int? selectedCompanyId;
  Object?
      selectedCompanyId; // or dynamic This way you can store both int and String values.
  String? selectedYear;
  String? selectedSeason;
  String? selectedMonth;
  String _dateSelectionMode = 'Season'; // or 'Month'
  late Map<String, int> monthNameToNumber;
  late List<String> months;

  List<Map<String, dynamic>> fetchedOrders = [];
  bool isLoading = false;
  List<Map<String, dynamic>> allModels = [];
  String? selectedModelValue; // <- to store "GZ5922", "IE4034", etc.
  List<Map<String, dynamic>> top3Orders = []; // <- Declare globally

  final List<Map<String, dynamic>> companies = [
    {'name': 'ALL', 'id': 'ALL'},
    {'name': 'APC', 'id': '5000'},
    {'name': 'Maxking', 'id': '5010'},
  ];

  final List<String> seasons = [
    // 'ALL',
    'Spring Summer',
    'Flowing Winter',
  ];

  late final List<String> years;

  // final List<String> months = List.generate(
  //   12,
  //   (index) => DateFormat.MMMM().format(DateTime(0, index + 1)),
  // );

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    years = [currentYear.toString(), (currentYear - 1).toString()];
    _yearController.text = years.first;

    // Create map like {'Jan': 1, 'Feb': 2, ...}
    monthNameToNumber = {
      for (var i = 01; i <= 12; i++) DateFormat.MMM().format(DateTime(0, i)): i,
    };

    months = monthNameToNumber.keys.toList();

    // ✅ Call it here so models will be ready for the dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      fetchedOrders = await fetchOrderInfo();
      setState(() {});
    });
  }

  // Future<List<Map<String, dynamic>>> fetchOrderInfo() async {
  //   String baseUrl = 'http://10.3.0.70:9042/api/Production/get-Order-Info';
  //   String company = selectedCompanyId.toString(); // handle int or string
  //   String year = selectedYear ?? DateTime.now().year.toString();
  //   String type = _typeController.text;
  //   String season = type == 'Season' ? selectedSeason ?? 'null' : 'null';
  //   String month = 'null';

  //   if (type == 'Month' && selectedMonth != null) {
  //     int? numericMonth = monthNameToNumber[selectedMonth!];
  //     if (numericMonth != null) {
  //       month = numericMonth.toString().padLeft(2, '0'); // e.g., 05
  //     }
  //   }

  //   final Uri uri = Uri.parse(
  //     '$baseUrl?company=$company&year=$year&season=$season&month=$month&type=$type',
  //   );

  //   final response = await http.get(uri);
  //   print('Order INfo Url $uri');
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = jsonDecode(response.body);
  //     print(response.body);
  //     return data.cast<Map<String, dynamic>>();
  //   } else {
  //     throw Exception('Failed to fetch order info');
  //   }
  // }

  // Future<List<Map<String, dynamic>>> fetchOrderInfo() async {
  //   try {
  //     String baseUrl = 'http://10.3.0.70:9042/api/Production/get-Order-Info';
  //     String company = selectedCompanyId.toString();
  //     String year = selectedYear ?? DateTime.now().year.toString();
  //     String type = _typeController.text;
  //     String season = type == 'Season' ? selectedSeason ?? 'null' : 'null';
  //     String month = 'null';

  //     if (type == 'Month' && selectedMonth != null) {
  //       int? numericMonth = monthNameToNumber[selectedMonth!];
  //       if (numericMonth != null) {
  //         month = numericMonth.toString().padLeft(2, '0');
  //       }
  //     }

  //     final Uri uri = Uri.parse(
  //       '$baseUrl?company=$company&year=$year&season=$season&month=$month&type=$type',
  //     );

  //     final response = await http.get(uri);
  //     print('Order Info URL: $uri');

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonBody = jsonDecode(response.body);

  //       // ✅ Assign allModels here
  //       if (jsonBody.containsKey('allModels')) {
  //         allModels = List<Map<String, dynamic>>.from(jsonBody['allModels']);
  //         print('Fetched models: ${allModels.length}');
  //       }

  //       else {
  //         print('No allModels found in response');
  //       }

  //       final List<dynamic> resultList = jsonBody['result'] ?? [];

  //       return resultList.cast<Map<String, dynamic>>();
  //     } else {
  //       throw Exception(
  //           'Failed to fetch order info. Status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching order info: $e');
  //     return [];
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchOrderInfo() async {
    try {
      var baseUrl = '${ApiHelper.productionUrl}get-Order-Info';
      // String baseUrl = 'http://10.3.0.70:9042/api/Production/get-Order-Info';
      String company = selectedCompanyId.toString();
      String year = selectedYear ?? DateTime.now().year.toString();
      String type = _typeController.text;
      String season = type == 'Season' ? selectedSeason ?? 'null' : 'null';
      String month = 'null';

      if (type == 'Month' && selectedMonth != null) {
        int? numericMonth = monthNameToNumber[selectedMonth!];
        if (numericMonth != null) {
          month = numericMonth.toString().padLeft(2, '0');
        }
      }

      final Uri uri = Uri.parse(
        '$baseUrl?company=$company&year=$year&season=$season&month=$month&type=$type',
      );

      final response = await http.get(uri);
      print('Order Info URL: $uri');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = jsonDecode(response.body);

        // ✅ Parse allModels
        if (jsonBody.containsKey('allModels')) {
          allModels = List<Map<String, dynamic>>.from(jsonBody['allModels']);
          print('Fetched allModels count: ${allModels.length}');
        } else {
          allModels = [];
          print('No allModels found in response');
        }

        // ✅ Parse top3Models
        if (jsonBody.containsKey('top3Models')) {
          top3Orders = List<Map<String, dynamic>>.from(jsonBody['top3Models']);
          print('Fetched top3Orders count: ${top3Orders.length}');
        } else {
          top3Orders = [];
          print('No top3Models found in response');
        }

        final List<dynamic> resultList = jsonBody['result'] ?? [];
        return resultList.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to fetch order info. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order info: $e');
      return [];
    }
  }

  // Widget buildOrderCard(Map<String, dynamic> order) {
  //   return Card(
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text("Model: ${order['model']}",
  //               style: const TextStyle(fontWeight: FontWeight.bold)),
  //           Text("Plant: ${order['plant']}"),
  //           Text("Quantity: ${order['quantity']}"),
  //           Text("Month: ${order['month']}"),
  //           Text("Article: ${order['artile']}"),
  //           Text("Percentage: ${order['percentage']}%"),
  //           Text("Total Quantity: ${order['totalQuantity']}"),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInfoRow("Model", order['model']),
            buildInfoRow("Plant", order['plant']),
            buildInfoRow("Quantity", order['quantity']),
            buildInfoRow("Month", order['month']),
            buildInfoRow("Article", order['artile']),
            buildInfoRow("Percentage", "${order['percentage']}%"),
            buildInfoRow("Total Quantity", order['totalQuantity']),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 130, // Fixed width to align labels
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(
                  fontWeight:
                      label == "Model" ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  // List<ChartData> prepareChartData(List<Map<String, dynamic>> orders) {
  //   List<ChartData> chartData = [];

  //   // Sort orders by percentage descending
  //   List<Map<String, dynamic>> sorted = [...orders];
  //   sorted.sort(
  //       (a, b) => (b['percentage'] as num).compareTo(a['percentage'] as num));

  //   // Get top 3 with model + artile
  //   List<Map<String, dynamic>> top3 = sorted.take(3).toList();
  //   List<Map<String, dynamic>> others = sorted.skip(3).toList();

  //   for (var item in top3) {
  //     String label = "${item['model']} (${item['artile']})";
  //     double perc = (item['percentage'] as num).toDouble();
  //     chartData.add(ChartData(label, perc));
  //   }

  //   // Sum percentage of others
  //   double otherPerc = others.fold(
  //       0.0, (sum, item) => sum + (item['percentage'] as num).toDouble());

  //   if (otherPerc > 0) {
  //     chartData.add(ChartData("Others", otherPerc));
  //   }

  //   return chartData;
  // }

  // List<ChartData> prepareChartData(List<Map<String, dynamic>> orders) {
  //   List<ChartData> chartData = [];

  //   // Sort orders by percentage descending
  //   List<Map<String, dynamic>> sorted = [...orders];
  //   sorted.sort(
  //     (a, b) => (b['percentage'] as num).compareTo(a['percentage'] as num),
  //   );

  //   // Get top 3 items
  //   List<Map<String, dynamic>> top3 = sorted.take(3).toList();

  //   double top3Sum = 0;

  //   for (var item in top3) {
  //     String label = "${item['model']} (${item['artile']})";
  //     double perc = (item['percentage'] as num).toDouble();
  //     top3Sum += perc;
  //     chartData.add(ChartData(label, perc));
  //   }

  //   // Calculate balance out of 100%
  //   double othersPerc = 100.0 - top3Sum;

  //   if (othersPerc > 0) {
  //     chartData.add(ChartData("Others", othersPerc));
  //   }

  //   return chartData;
  // }
  List<ChartData> prepareChartData(List<Map<String, dynamic>> top3Orders) {
    List<ChartData> chartData = [];

    for (var item in top3Orders) {
      String label = "${item['model']} (${item['artile']})";
      double perc = (item['percentage'] as num).toDouble();
      int qty = int.tryParse(item['quantity'].toString()) ?? 0;

      chartData.add(ChartData(label, perc, qty));
    }

    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Filtering logic based on selected model/article
    final List<Map<String, dynamic>> filteredOrders =
        selectedModelValue == null || selectedModelValue == "ALL"
            ? fetchedOrders
            : selectedModelValue == "Top3"
                ? top3Orders
                : fetchedOrders
                    .where((order) =>
                        order['artile']?.toString().toLowerCase() ==
                        selectedModelValue?.toLowerCase())
                    .toList();
    final int totalQty = filteredOrders.fold(
      0,
      (sum, order) =>
          sum + (int.tryParse(order['quantity']?.toString() ?? '0') ?? 0),
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),

              /// Company DropdownSearch
              DropDownSearchField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: "Select Company",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return companies
                      .map((e) => e['name'] as String)
                      .where((name) =>
                          name.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSuggestionSelected: (suggestion) {
                  final selected =
                      companies.firstWhere((e) => e['name'] == suggestion);
                  setState(() {
                    selectedCompany = suggestion;
                    selectedCompanyId = selected['id'];
                    _companyController.text = suggestion;
                  });
                },
                displayAllSuggestionWhenTap: true,
                isMultiSelectDropdown: false,
              ),

              const SizedBox(height: 16),

              DropDownSearchField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: "Select Type",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.category),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return ['Season', 'Month']
                      .where((type) =>
                          type.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _dateSelectionMode = suggestion;
                    _typeController.text = suggestion;
                    selectedSeason = null;
                    selectedMonth = null;
                    _seasonController.clear();
                    _monthController.clear();
                  });
                },
                displayAllSuggestionWhenTap: true,
                isMultiSelectDropdown: false,
              ),
              const SizedBox(height: 16),
              if (_dateSelectionMode == 'Month')
                DropdownSearch<String>(
                  items: years,
                  selectedItem: selectedYear,
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Select Year",
                      border: OutlineInputBorder(),
                      // suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                ),
              const SizedBox(height: 16),

              if (_dateSelectionMode == 'Season')
                DropDownSearchField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _seasonController,
                    decoration: const InputDecoration(
                      labelText: "Select Season",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.wb_sunny),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return seasons
                        .where((s) =>
                            s.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(title: Text(suggestion));
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      selectedSeason = suggestion;
                      _seasonController.text = suggestion;
                    });
                  },
                  displayAllSuggestionWhenTap: true,
                  isMultiSelectDropdown: false,
                )
              else
                DropDownSearchField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _monthController,
                    decoration: const InputDecoration(
                      labelText: "Select Month",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return months
                        .where((m) =>
                            m.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(title: Text(suggestion));
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      selectedMonth = suggestion;
                      _monthController.text = suggestion;
                    });
                  },
                  displayAllSuggestionWhenTap: true,
                  isMultiSelectDropdown: false,
                ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    final data = await fetchOrderInfo();
                    setState(() {
                      fetchedOrders = data;
                      isLoading = false;
                    });
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error fetching data: $e')),
                    );
                  }
                },
                child: const Text("Submit"),
              ),
              const SizedBox(height: 10),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : fetchedOrders.isNotEmpty
                      ? Column(
                          children: [
                            Text(
                              'Total Quantity: $totalQty',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),

                            // SizedBox(
                            //   height: 400,
                            //   child: SfCircularChart(
                            //     title: const ChartTitle(text: 'Top 3 Orders'),
                            //     legend: const Legend(
                            //       isVisible: true,
                            //       position: LegendPosition.bottom,
                            //       overflowMode: LegendItemOverflowMode.wrap,
                            //     ),
                            //     series: <CircularSeries>[
                            //       PieSeries<ChartData, String>(
                            //         dataSource: prepareChartData(fetchedOrders),
                            //         xValueMapper: (ChartData data, _) =>
                            //             data.label,
                            //         yValueMapper: (ChartData data, _) =>
                            //             data.percentage,
                            //         dataLabelSettings: const DataLabelSettings(
                            //             isVisible: true),
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            SizedBox(
                              height: 400,
                              child: SfCircularChart(
                                title: const ChartTitle(text: 'Top 3 Orders'),
                                legend: const Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom,
                                  overflowMode: LegendItemOverflowMode.wrap,
                                ),
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: <CircularSeries>[
                                  PieSeries<ChartData, String>(
                                    dataSource: prepareChartData(
                                        top3Orders), // <- use top3Orders
                                    xValueMapper: (ChartData data, _) =>
                                        data.label,
                                    yValueMapper: (ChartData data, _) =>
                                        data.percentage,
                                    dataLabelMapper: (ChartData data, _) =>
                                        '${data.label}\nQty: ${data.totalQuantity}',
                                    dataLabelSettings: const DataLabelSettings(
                                        isVisible: true),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _modelController.clear();
                                  selectedModelValue = null;
                                });
                              },
                              child: const Text("Clear Filter"),
                            ),
                            // ✅ Your model & article dropdown
                            DropDownSearchField(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _modelController,
                                decoration: const InputDecoration(
                                  labelText: "Search Model and Article",
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.search),
                                ),
                              ),
                              suggestionsCallback: (pattern) async {
                                return allModels
                                    .where((m) => m['label']
                                        .toLowerCase()
                                        .contains(pattern.toLowerCase()))
                                    .toList();
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(suggestion['label']),
                                );
                              },
                              // onSuggestionSelected: (suggestion) async {
                              //   setState(() {
                              //     _modelController.text = suggestion['label'];
                              //     selectedModelValue = suggestion['value'];
                              //   });

                              //   // Optional: re-fetch order info after selecting model
                              //   fetchedOrders = await fetchOrderInfo();
                              //   setState(() {});
                              // },
                              onSuggestionSelected: (suggestion) {
                                setState(() {
                                  _modelController.text = suggestion['label'];
                                  selectedModelValue =
                                      suggestion['value']; // E.g., "GZ5922"
                                });
                              },
                              displayAllSuggestionWhenTap: true,
                              isMultiSelectDropdown: false,
                            ),

                            // ListView.builder(
                            //   shrinkWrap: true,
                            //   physics: const NeverScrollableScrollPhysics(),
                            //   itemCount: fetchedOrders.length,
                            //   itemBuilder: (context, index) {
                            //     return buildOrderCard(fetchedOrders[index]);
                            //   },
                            // ),
                            // ✅ Use filteredOrders here instead of fetchedOrders
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                return buildOrderCard(filteredOrders[index]);
                              },
                            ),
                          ],
                        )
                      : const Text("No data fetched yet."),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String label;
  final double percentage;
  final int totalQuantity;

  ChartData(this.label, this.percentage, this.totalQuantity);
}
