import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:intl/intl.dart';

class BGradeData {
  DateTime date;
  String department;
  int bGrade;
  int output;
  int repairs;
  String process;
  String bGradePercent;

  BGradeData({
    required this.date,
    required this.department,
    required this.bGrade,
    required this.output,
    required this.repairs,
    required this.process,
    required this.bGradePercent,
  });

  factory BGradeData.fromJson(Map<String, dynamic> json) => BGradeData(
        date: DateTime.parse(json["date"]),
        department: json["department"],
        bGrade: json["b_Grade"],
        output: json["output"],
        repairs: json["repairs"],
        process: json["process"],
        bGradePercent: json["bGradePercent"],
      );
}

class IEEfficiencyData {
  final String prodDate;
  final String prodLine;
  final double standardManhours;
  final double actualManhours;
  final double ie;
  final String process;

  IEEfficiencyData({
    required this.prodDate,
    required this.prodLine,
    required this.standardManhours,
    required this.actualManhours,
    required this.ie,
    required this.process,
  });

  factory IEEfficiencyData.fromJson(Map<String, dynamic> json) {
    return IEEfficiencyData(
      prodDate: json['proD_DATE'],
      prodLine: json['proD_LINE'],
      standardManhours:
          double.tryParse(json['standarD_MANHOURS'].toString()) ?? 0.0,
      actualManhours:
          double.tryParse(json['actuaL_MANHOURS'].toString()) ?? 0.0,
      ie: double.tryParse(json['ie'].toString()) ?? 0.0,
      process: json['process'],
    );
  }
}

List<RftReport> rftReportFromJson(String str) {
  final List<dynamic> jsonData = json.decode(str);
  return jsonData.map((item) => RftReport.fromJson(item)).toList();
}

class RftReport {
  final String? createdate;
  final String? productionLineCode;
  final String? totalQty;
  final String? qualifiedQty;
  final String? rft;
  final String? udf01;

  RftReport({
    this.createdate,
    this.productionLineCode,
    this.totalQty,
    this.qualifiedQty,
    this.rft,
    this.udf01,
  });

  factory RftReport.fromJson(Map<String, dynamic> json) {
    return RftReport(
      createdate: json['createdate']?.toString(),
      productionLineCode: json['productioN_LINE_CODE']?.toString(),
      totalQty: json['totaL_QTY']?.toString(),
      qualifiedQty: json['qualifieD_QTY']?.toString(),
      rft: json['rft']?.toString(),
      udf01: json['udF01']?.toString(),
    );
  }
}

class ProductionReportsModule extends StatefulWidget {
  final LoginModelApi userData;
  const ProductionReportsModule({Key? key, required this.userData})
      : super(key: key);

  @override
  State<ProductionReportsModule> createState() =>
      _ProductionReportsModuleState();
}

class _ProductionReportsModuleState extends State<ProductionReportsModule> {
  final List<String> reportOptions = ['RFT Report', 'IE Efficiency', 'B-Grade'];
  // final List<String> plants = ['AP1', 'AP2', 'AP3', 'AP4'];
  List<String> plants = [];
  final List<String> processsType = ['ALL', 'Stitching', 'Assembly', 'Cutting'];

  String? selectedReport;
  String? selectedPlants;
  String? selectedProcess;
  DateTime selectedDate = DateTime.now();

  final TextEditingController _reportSearchController = TextEditingController();
  final TextEditingController _plantController = TextEditingController();
  final TextEditingController _processTypeController = TextEditingController();

  List<BGradeData> bGradeList = [];
  List<RftReport> rftReportList = [];
  @override
  void initState() {
    super.initState();
    fetchPlants();
  }

  Future<void> fetchPlants() async {
    final url = Uri.parse('${ApiHelper.productionUrl}get-Plants');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          plants = data.map((item) => item.toString()).toList();
        });
      } else {
        print("❌ Failed to load plants: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching plants: $e");
    }
  }

  Future<void> fetchBGradeData() async {
    if (selectedPlants == null || selectedProcess == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Plant and Process')),
      );
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String process = selectedProcess == "Cutting"
        ? "C"
        : selectedProcess == "Stitching"
            ? "S"
            : selectedProcess == "Assembly"
                ? "L"
                : "ALL";

    var url =
        '${ApiHelper.productionUrl}get-B-Grade-data?inputDate=$formattedDate&line=$selectedPlants&process=$process';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        bGradeList = data.map((json) => BGradeData.fromJson(json)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch data')),
      );
    }
  }

  String getFullProcessName(String code) {
    switch (code) {
      case 'S':
        return 'Stitching';
      case 'L':
        return 'Assembly';
      case 'C':
        return 'Cutting';
      default:
        return code;
    }
  }

  List<IEEfficiencyData> ieEfficiencyList = [];

  Future<void> fetchIEEfficiencyData() async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String ieefficencyProcess = selectedProcess == "Cutting"
        ? "C"
        : selectedProcess == "Stitching"
            ? "S"
            : selectedProcess == "Assembly"
                ? "L"
                : "ALL";
    var apiUrl =
        '${ApiHelper.productionUrl}get-IEEfficiency-data?inputDate=$formattedDate&line=$selectedPlants&process=$ieefficencyProcess';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          ieEfficiencyList =
              data.map((json) => IEEfficiencyData.fromJson(json)).toList();
        });
      } else {
        throw Exception("Failed to load IE Efficiency data");
      }
    } catch (e) {
      print("Error fetching IE Efficiency data: $e");
    }
  }

  // Future<void> fetchRFTReportData() async {
  //   final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

  //   // Use a map for better clarity and flexibility
  //   const processCodeMap = {
  //     "Cutting": "C",
  //     "Stitching": "S",
  //     "Assembly": "L",
  //   };

  //   // Get the code or fallback to "ALL"
  //   final rftReportprocess = processCodeMap[selectedProcess] ?? "ALL";

  //   final url = Uri.parse(
  //     "http://10.3.0.70:9042/api/Production/get-RFT-data?inputDate=$formattedDate&line=$selectedPlants&process=$rftReportprocess",
  //   );
  //   print('RFT Report URL ${url}');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       final List<RftReport> data = rftReportFromJson(response.body);
  //       setState(() {
  //         rftReportList = data;
  //       });
  //     } else {
  //       print("❌ Failed to fetch RFT data: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("❌ Error: $e");
  //   }
  // }

  Future<void> fetchRFTReportData() async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Use a map for better clarity and flexibility
    const processCodeMap = {
      "Cutting": "C",
      "Stitching": "S",
      "Assembly": "L",
    };

    // Get the code or fallback to "ALL"
    final rftReportprocess = processCodeMap[selectedProcess] ?? "ALL";

    // Construct the URL string
    final rftURL =
        '${ApiHelper.productionUrl}get-RFT-data?inputDate=$formattedDate&line=$selectedPlants&process=$rftReportprocess';

    print('RFT Report URL: $rftURL');

    // Convert to Uri
    final url = Uri.parse(rftURL);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<RftReport> data = rftReportFromJson(response.body);
        setState(() {
          rftReportList = data;
        });
      } else {
        print("❌ Failed to fetch RFT data: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('yyyy-MM-dd').format(selectedDate);
    final groupedData =
        groupBy(bGradeList, (item) => item.process); // Move here

    // final groupedIEData = groupBy(
    //   ieEfficiencyList,
    //   (IEEfficiencyData item) => item.prodLine.contains('S')
    //       ? 'S'
    //       : item.prodLine.contains('L')
    //           ? 'L'
    //           : item.prodLine.contains('C')
    //               ? 'C'
    //               : 'ALL',
    // );

    final groupedIEData =
        groupBy(ieEfficiencyList, (item) => item.process); // Move here

    // final Map<String, List<RftReport>> groupedRFTData = groupBy(
    //   rftReportList,
    //   (item) => item.udf01 ?? 'Unknown', // or 'ALL', or ''
    // );
    final groupedRFTData = groupBy(
      rftReportList,
      (RftReport item) => item.udf01 ?? 'ALL', // Ensure non-null grouping key
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date Picker
            Row(
              children: [
                // const Icon(Icons.calendar_today),
                // const SizedBox(width: 10),
                Text(
                  dateFormatted,
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text("Change"),
                  onPressed: () => _pickDate(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _reportSearchController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Search Report",
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return reportOptions
                    .where((option) =>
                        option.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(title: Text(suggestion));
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  selectedReport = suggestion;
                  _reportSearchController.text = suggestion;
                  // Set date based on report
                  if (selectedReport == 'IE Efficiency') {
                    selectedDate =
                        DateTime.now().subtract(const Duration(days: 7));
                  } else {
                    selectedDate = DateTime.now();
                  }
                });
              },
              displayAllSuggestionWhenTap: true,
              isMultiSelectDropdown: false,
            ),
            const SizedBox(height: 16),
            DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _plantController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Search Plant",
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return plants
                    .where((option) =>
                        option.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(title: Text(suggestion));
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  selectedPlants = suggestion;
                  _plantController.text = suggestion;
                });
              },
              displayAllSuggestionWhenTap: true,
              isMultiSelectDropdown: false,
            ),
            const SizedBox(height: 16),
            DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _processTypeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Search Process",
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return processsType
                    .where((option) =>
                        option.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(title: Text(suggestion));
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  selectedProcess = suggestion;
                  _processTypeController.text = suggestion;
                });
              },
              displayAllSuggestionWhenTap: true,
              isMultiSelectDropdown: false,
            ),
            const SizedBox(height: 16),

            // ElevatedButton(
            //   onPressed: () {
            //     if (selectedReport == 'B-Grade') {
            //       fetchBGradeData();
            //     } else if (selectedReport == 'IE Efficiency') {
            //       fetchIEEfficiencyData();
            //     } else if (selectedReport == 'RFT Report') {
            //       fetchRFTReportData(); // ✅ call RFT report function
            //     } else {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //             content: Text('Please select a report to fetch data.')),
            //       );
            //     }
            //   },
            //   child: const Text("Search"),
            // ),
            ElevatedButton(
              onPressed: () async {
                if (selectedReport == 'B-Grade') {
                  await fetchBGradeData();
                  if (bGradeList.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("No B-Grade report found for selection")),
                    );
                  }
                }
                // else if (selectedReport == 'IE Efficiency') {
                //   await fetchIEEfficiencyData();
                //   if (ieEfficiencyList.isEmpty) {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //           content: Text(
                //               "No IE Efficiency report found for selection")),
                //     );
                //   }
                // }
                else if (selectedReport == 'IE Efficiency') {
                  await fetchIEEfficiencyData();

                  if (ieEfficiencyList.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "No IE Efficiency data found. Please select a date within the last 7 days.",
                        ),
                      ),
                    );
                  }
                } else if (selectedReport == 'RFT Report') {
                  await fetchRFTReportData();
                  if (rftReportList.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("No RFT report found for selection")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select a report to fetch data.')),
                  );
                }
              },
              child: const Text("Search"),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: selectedReport == 'IE Efficiency'
                  ? (groupedIEData.isEmpty
                      ? const Center(child: Text("No data found"))
                      : ListView.builder(
                          itemCount: groupedIEData.length,
                          itemBuilder: (context, index) {
                            final process = groupedIEData.keys.elementAt(index);
                            final items = groupedIEData[process]!;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  getFullProcessName(process),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                childrenPadding: const EdgeInsets.all(16),
                                expandedCrossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: items.map((data) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        reportsDataTextWidget(
                                            'Line', data.prodLine.toString()),
                                        reportsDataTextWidget(
                                            'Date', data.prodDate.toString()),
                                        reportsDataTextWidget(
                                            'Standard Manhours',
                                            data.standardManhours
                                                .toStringAsFixed(2)),
                                        reportsDataTextWidget(
                                            'Actual Manhours',
                                            data.actualManhours
                                                .toStringAsFixed(2)),
                                        reportsDataTextWidget('IE',
                                            "${data.ie.toStringAsFixed(2)}%"),
                                        const Divider(),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ))
                  : selectedReport == 'B-Grade'
                      ? (groupedData.isEmpty
                          ? const Center(child: Text("No data found"))
                          : ListView.builder(
                              itemCount: groupedData.length,
                              itemBuilder: (context, index) {
                                final process =
                                    groupedData.keys.elementAt(index);
                                final items = groupedData[process]!;

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ExpansionTile(
                                    title: Text(
                                      getFullProcessName(process),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    childrenPadding: const EdgeInsets.all(16),
                                    expandedCrossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: items.map((data) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            reportsDataTextWidget('Line',
                                                data.department.toString()),
                                            reportsDataTextWidget(
                                              'Date',
                                              DateFormat('yyyy-MM-dd')
                                                  .format(data.date),
                                            ),
                                            reportsDataTextWidget('Output',
                                                data.output.toString()),
                                            reportsDataTextWidget('B Grade',
                                                data.bGrade.toString()),
                                            reportsDataTextWidget('Repairs',
                                                data.repairs.toString()),
                                            reportsDataTextWidget('B Grade %',
                                                data.bGradePercent.toString()),
                                            const Divider(),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ))
                      : selectedReport == 'RFT Report'
                          ? (groupedRFTData.isEmpty
                              ? const Center(child: Text("No data found"))
                              : ListView.builder(
                                  itemCount: groupedRFTData.length,
                                  itemBuilder: (context, index) {
                                    final processCode =
                                        groupedRFTData.keys.elementAt(index);
                                    final items = groupedRFTData[processCode]!;

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 4),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ExpansionTile(
                                        title: Text(
                                          getFullProcessName(processCode),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        childrenPadding:
                                            const EdgeInsets.all(16),
                                        expandedCrossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: items.map((data) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                reportsDataTextWidget(
                                                    'Line',
                                                    data.productionLineCode ??
                                                        ''),
                                                reportsDataTextWidget('Date',
                                                    data.createdate ?? ''),
                                                reportsDataTextWidget(
                                                    'Total Qty',
                                                    data.totalQty ?? ''),
                                                reportsDataTextWidget(
                                                    'Qualified Qty',
                                                    data.qualifiedQty ?? ''),
                                                reportsDataTextWidget('RFT',
                                                    '${data.rft ?? '0'}%'),
                                                const Divider(),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ))
                          : const Center(child: Text("Please select a report")),
            ),
          ],
        ),
      ),
    );
  }

  Widget reportsDataTextWidget(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
