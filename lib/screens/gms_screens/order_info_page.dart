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
  int totalApiQuantity = 0; // <- holds the API's totalQuantity
  bool isModelandArticleLoading = false;
  bool isClearFilterLoading = false;

  final List<Map<String, dynamic>> companies = [
    {'name': 'ALL', 'id': 'ALL'},
    {'name': 'APC', 'id': '5000'},
    {'name': 'Maxking', 'id': '5010'},
  ];

  final List<String> seasons = [
    // 'ALL',
    'Spring Summer',
    'Falling Winter',
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
    // years = [currentYear.toString(), (currentYear - 1).toString()];

    // From currentYear - 2 to currentYear + 2 (i.e., 5 years total)
    years = List.generate(5, (index) => (currentYear - 2 + index).toString());
    _yearController.text = years.first;

    // Create map like {'Jan': 1, 'Feb': 2, ...}
    monthNameToNumber = {
      for (var i = 01; i <= 12; i++) DateFormat.MMM().format(DateTime(0, i)): i,
    };

    months = monthNameToNumber.keys.toList();

    // ✅ Call it here so models will be ready for the dropdown
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   fetchedOrders = await fetchOrderInfo();
    //   setState(() {});
    // });
  }

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
        // ✅ Safely extract totalQuantity from first item (as all have same)
        if (resultList.isNotEmpty && resultList[0]['totalQuantity'] != null) {
          totalApiQuantity =
              int.tryParse(resultList[0]['totalQuantity'].toString()) ?? 0;
        }
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

  Widget buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInfoRow("Model", order['model']),
            buildInfoRow("Article", order['artile']),
            // buildInfoRow("Company Code", order['plant']),
            buildInfoRow("Quantity", order['quantity']),
            buildInfoRow("Month", order['month']),
            buildInfoRow("Shipped Qty", "${order['shippeD_QTY']}"),
            buildInfoRow(
                "Shipped Percentage", "${order['shipmenT_PERCENTAGE']}%"),
            buildInfoRow("Overall Percentage", "${order['percentage']}%"),
            buildInfoRow("Total Quantity", order['totalQuantity']),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, dynamic value) {
    // Hide row if label is Percentage and value is "0%"
    if (label == "Percentage" && (value == "0%" || value == "0.0%")) {
      return const SizedBox.shrink();
    }

    // Hide row if label is Total Quantity and value is 0 or "0"
    if (label == "Total Quantity" && (value == 0 || value == "0")) {
      return const SizedBox.shrink();
    }

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
                  fontWeight: (label == "Model" || label == "Article")
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

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
    // // ✅ Filtering logic based on selected model/article
    // final List<Map<String, dynamic>> filteredOrders =
    //     selectedModelValue == null || selectedModelValue == "ALL"
    //         ? fetchedOrders
    //         : selectedModelValue == "Top3"
    //             ? top3Orders
    //             : fetchedOrders
    //                 .where((order) =>
    //                     order['artile']?.toString().toLowerCase() ==
    //                     selectedModelValue?.toLowerCase())
    //                 .toList();
    // // final int totalQty = filteredOrders.fold(
    // //   0,
    // //   (sum, order) =>
    // //       sum + (int.tryParse(order['quantity']?.toString() ?? '0') ?? 0),
    // // );

// using filter total quantity is based upon order fetch info api bases
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
                    // selectedSeason = null;
                    // selectedMonth = null;
                    // _seasonController.clear();
                    // _monthController.clear();
                    if (suggestion == 'Season') {
                      // Clear month and year fields
                      selectedMonth = null;
                      selectedYear = null;
                      _monthController.clear();

                      // Also clear season (optional, in case of previous leftover)
                      selectedSeason = null;
                      _seasonController.clear();
                    } else if (suggestion == 'Month') {
                      // Clear season field
                      selectedSeason = null;
                      _seasonController.clear();

                      // Also clear month and year just in case
                      selectedMonth = null;
                      selectedYear = null;
                      _monthController.clear();
                    }
                  });
                },
                displayAllSuggestionWhenTap: true,
                isMultiSelectDropdown: false,
              ),
              const SizedBox(height: 16),
              // if (_dateSelectionMode == 'Month') // for when month onwords select year shows logic
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
              // ElevatedButton(
              //   onPressed: () async {
              //     setState(() {
              //       isLoading = true;
              //     });
              //     try {
              //       final data = await fetchOrderInfo();
              //       setState(() {
              //         fetchedOrders = data;
              //         isLoading = false;
              //       });
              //     } catch (e) {
              //       setState(() {
              //         isLoading = false;
              //       });
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(content: Text('Error fetching data: $e')),
              //       );
              //     }
              //   },
              //   child: const Text("Submit"),
              // ),
              isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show only one loader
                  : ElevatedButton(
                      onPressed: () async {
                        // Validation logic
                        if (selectedCompanyId == null ||
                            _companyController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please select a company.')),
                          );
                          return;
                        }

                        if (_typeController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please select a type.')),
                          );
                          return;
                        }

                        if (_dateSelectionMode == 'Season' &&
                            (selectedSeason == null ||
                                _seasonController.text.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please select a season.')),
                          );
                          return;
                        }

                        if (_dateSelectionMode == 'Month' &&
                            (selectedMonth == null ||
                                _monthController.text.isEmpty ||
                                selectedYear == null)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please select year and month.')),
                          );
                          return;
                        }

                        // Proceed to fetch data
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final data = await fetchOrderInfo();
                          setState(() {
                            fetchedOrders = data;
                            isLoading = false;

                            // Reset all fields after success
                            // _companyController.clear();
                            // _typeController.clear();
                            // _seasonController.clear();
                            // _monthController.clear();

                            // selectedCompanyId = null;
                            // selectedCompany = null;
                            // // _dateSelectionMode = null;
                            // selectedSeason = null;
                            // selectedMonth = null;
                            // selectedYear = null;
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

              // isLoading
              //     ? const Center(child: CircularProgressIndicator())
              //     :

              //  fetchedOrders.isNotEmpty
              //     ?
              if (fetchedOrders.isNotEmpty) ...[
                Text(
                  'Total Quantity: $totalApiQuantity',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24),
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
                //     tooltipBehavior: TooltipBehavior(enable: true),
                //     series: <CircularSeries>[
                //       PieSeries<ChartData, String>(
                //         dataSource:
                //             prepareChartData(top3Orders), // <- use top3Orders
                //         xValueMapper: (ChartData data, _) => data.label,
                //         yValueMapper: (ChartData data, _) => data.percentage,
                //         dataLabelMapper: (ChartData data, _) =>
                //             '${data.label}\nQty: ${data.totalQuantity}',
                //         dataLabelSettings:
                //             const DataLabelSettings(isVisible: true),
                //       ),
                //     ],
                //   ),
                // ),

                SizedBox(
                  height: 400,
                  child: SfCartesianChart(
                    title: const ChartTitle(text: 'Top 3 Orders'),
                    primaryXAxis: const CategoryAxis(
                      labelIntersectAction: AxisLabelIntersectAction.rotate45,
                    ),
                    primaryYAxis:
                        const NumericAxis(title: AxisTitle(text: 'Quantity')),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    legend: const Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      overflowMode: LegendItemOverflowMode.wrap,
                    ),
                    onTooltipRender: (TooltipArgs args) {
                      final ChartData data = prepareChartData(
                          top3Orders)[args.pointIndex!.toInt()];
                      args.text =
                          '${data.label}\nQty: ${data.totalQuantity}\nPercentage: (${data.percentage.toStringAsFixed(1)}%)';
                    },
                    series: <CartesianSeries>[
                      ColumnSeries<ChartData, String>(
                        dataSource: prepareChartData(top3Orders),
                        xValueMapper: (ChartData data, _) => data.label,
                        yValueMapper: (ChartData data, _) =>
                            data.totalQuantity.toDouble(),
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                        name: 'Qty',
                        enableTooltip: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                // TextButton(
                //   onPressed: () async {
                //     setState(() {
                //       // isLoading = true; // Show loading spinner
                //       isModelandArticleLoading =
                //           true; // Show loading spinner
                //     });
                //     await Future.delayed(const Duration(
                //         milliseconds: 300)); // Optional delay
                //     setState(() {
                //       isLoading = true; // Show loading
                //       _modelController.clear();
                //       selectedModelValue = null;
                //       // isLoading = false; // Hide loading spinner
                //       isModelandArticleLoading =
                //           false; // Hide loading spinner
                //     });
                //   },
                //   child: const Text("Clear Filter"),
                // ),

                // 🧹 Clear Filter Button with its own loader
                SizedBox(
                  width: 150,
                  child: TextButton.icon(
                    icon: isClearFilterLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.clear),
                    label: const Text("Clear Filter"),
                    onPressed: isClearFilterLoading
                        ? null
                        : () async {
                            setState(() {
                              isClearFilterLoading = true;
                            });

                            await Future.delayed(
                                const Duration(milliseconds: 500));

                            setState(() {
                              _modelController.clear();
                              selectedModelValue = null;
                              isClearFilterLoading = false;
                            });
                          },
                  ),
                ),
                // ✅ Your model & article dropdown
                Stack(
                  children: [
                    DropDownSearchField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _modelController,
                        decoration: const InputDecoration(
                          labelText: "Search Model Or Article",
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
                      onSuggestionSelected: (suggestion) async {
                        setState(() {
                          // isLoading = true; // Show loading

                          isModelandArticleLoading = true;
                        });

                        await Future.delayed(const Duration(
                            milliseconds:
                                300)); // Optional small delay for UI feedback

                        setState(() {
                          _modelController.text = suggestion['label'];
                          selectedModelValue =
                              suggestion['value']; // E.g., "GZ5922"
                          // isLoading = false; // Hide loading
                          isModelandArticleLoading = false;
                        });
                      },
                      displayAllSuggestionWhenTap: true,
                      isMultiSelectDropdown: false,
                    ),

                    // 👇 Circular Progress Indicator overlay
                    if (isModelandArticleLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white.withOpacity(0.5),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
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
                )
              ]

              // :
              else
                const Text("No data fetched yet."),
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
