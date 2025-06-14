// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
// import 'package:drop_down_search_field/drop_down_search_field.dart';
// import 'package:flutter/material.dart';

// class ProductionReportsModule extends StatefulWidget {
//   final LoginModelApi userData;
//   const ProductionReportsModule({Key? key, required this.userData})
//       : super(key: key);

//   @override
//   _ProductionReportsModuleState createState() =>
//       _ProductionReportsModuleState();
// }

// class _ProductionReportsModuleState extends State<ProductionReportsModule> {
//   final List<String> reportOptions = ['RFT Report', 'IE Efficiency', 'B-Grade'];
//   final List<String> plants = ['AP1', 'AP2', 'AP3','AP4'];
//   final List<String> processsType = ['ALL', 'Stiching', 'Assembly', 'Cutting'];

//   String? selectedReport;
//   String? selectedPlants;
//   String? selectedProcess;

//   final TextEditingController _reportSearchController = TextEditingController();
//   final TextEditingController _plantController = TextEditingController();
//   final TextEditingController _processTypeController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             DropDownSearchField(
//               textFieldConfiguration: TextFieldConfiguration(
//                 controller: _reportSearchController,
//                 autofocus: false,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(10)),
//                   ),
//                   labelText: "Search Report",
//                   suffixIcon: Icon(Icons.search),
//                 ),
//                 onChanged: (text) {
//                   setState(() {
//                     if (text.isEmpty) selectedReport = null;
//                   });
//                 },
//               ),
//               suggestionsCallback: (pattern) async {
//                 if (pattern.isEmpty) return reportOptions;
//                 return reportOptions
//                     .where((option) =>
//                         option.toLowerCase().contains(pattern.toLowerCase()))
//                     .toList();
//               },
//               itemBuilder: (context, suggestion) {
//                 return ListTile(
//                   leading: const Icon(Icons.assignment_outlined),
//                   title: Text(suggestion),
//                 );
//               },
//               onSuggestionSelected: (suggestion) {
//                 setState(() {
//                   selectedReport = suggestion;
//                   _reportSearchController.text = suggestion;
//                 });
//               },
//               displayAllSuggestionWhenTap: true,
//               isMultiSelectDropdown: false,
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             DropDownSearchField(
//               textFieldConfiguration: TextFieldConfiguration(
//                 controller: _plantController,
//                 autofocus: false,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(10)),
//                   ),
//                   labelText: "Search Plant",
//                   suffixIcon: Icon(Icons.search),
//                 ),
//                 onChanged: (text) {
//                   setState(() {
//                     if (text.isEmpty) selectedPlants = null;
//                   });
//                 },
//               ),
//               suggestionsCallback: (pattern) async {
//                 if (pattern.isEmpty) return plants;
//                 return plants
//                     .where((option) =>
//                         option.toLowerCase().contains(pattern.toLowerCase()))
//                     .toList();
//               },
//               itemBuilder: (context, suggestion) {
//                 return ListTile(
//                   leading: const Icon(Icons.assignment_outlined),
//                   title: Text(suggestion),
//                 );
//               },
//               onSuggestionSelected: (suggestion) {
//                 setState(() {
//                   selectedPlants = suggestion;
//                   _plantController.text = suggestion;
//                 });
//               },
//               displayAllSuggestionWhenTap: true,
//               isMultiSelectDropdown: false,
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             DropDownSearchField(
//               textFieldConfiguration: TextFieldConfiguration(
//                 controller: _processTypeController,
//                 autofocus: false,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(10)),
//                   ),
//                   labelText: "Search Process",
//                   suffixIcon: Icon(Icons.search),
//                 ),
//                 onChanged: (text) {
//                   setState(() {
//                     if (text.isEmpty) selectedProcess = null;
//                   });
//                 },
//               ),
//               suggestionsCallback: (pattern) async {
//                 if (pattern.isEmpty) return processsType;
//                 return processsType
//                     .where((option) =>
//                         option.toLowerCase().contains(pattern.toLowerCase()))
//                     .toList();
//               },
//               itemBuilder: (context, suggestion) {
//                 return ListTile(
//                   leading: const Icon(Icons.assignment_outlined),
//                   title: Text(suggestion),
//                 );
//               },
//               onSuggestionSelected: (suggestion) {
//                 setState(() {
//                   selectedProcess = suggestion;
//                   _processTypeController.text = suggestion;
//                 });
//               },
//               displayAllSuggestionWhenTap: true,
//               isMultiSelectDropdown: false,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
  final List<String> plants = ['AP1', 'AP2', 'AP3', 'AP4'];
  final List<String> processsType = ['ALL', 'Stiching', 'Assembly', 'Cutting'];

  String? selectedReport;
  String? selectedPlants;
  String? selectedProcess;
  DateTime selectedDate = DateTime.now();

  final TextEditingController _reportSearchController = TextEditingController();
  final TextEditingController _plantController = TextEditingController();
  final TextEditingController _processTypeController = TextEditingController();

  List<BGradeData> bGradeList = [];

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
        : selectedProcess == "Stiching"
            ? "L"
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
        : selectedProcess == "Stiching"
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
            //   onPressed: fetchBGradeData,
            //   child: const Text("Search"),
            // ),
            ElevatedButton(
              onPressed: () {
                if (selectedReport == 'B-Grade') {
                  fetchBGradeData();
                } else if (selectedReport == 'IE Efficiency') {
                  fetchIEEfficiencyData();
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
            // Expanded(
            //   child: bGradeList.isEmpty
            //       ? const Center(child: Text("No data found"))
            //       : ListView.builder(
            //           itemCount: bGradeList.length,
            //           itemBuilder: (context, index) {
            //             final data = bGradeList[index];
            //             return Card(
            //               margin: const EdgeInsets.symmetric(
            //                   vertical: 8, horizontal: 4),
            //               elevation: 4,
            //               shape: RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.circular(12),
            //               ),
            //               child: ExpansionTile(
            //                 title: Text(
            //                   "${data.department} | ${data.process}",
            //                   style: const TextStyle(
            //                     fontSize: 20,
            //                     color: Colors.blue,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //                 childrenPadding: const EdgeInsets.all(16),
            //                 expandedCrossAxisAlignment:
            //                     CrossAxisAlignment.start,
            //                 children: [
            //                   bGradeDataTextWidget(
            //                     'Date',
            //                     DateFormat('yyyy-MM-dd').format(data.date),
            //                   ),
            //                   bGradeDataTextWidget(
            //                       'Output', data.output.toString()),
            //                   bGradeDataTextWidget(
            //                       'B Grade', data.bGrade.toString()),
            //                   bGradeDataTextWidget(
            //                       'Repairs', data.repairs.toString()),
            //                   bGradeDataTextWidget(
            //                       'B Grade %', data.bGradePercent.toString()),
            //                 ],
            //               ),
            //             );
            //           },
            //         ),
            // ),

            // Expanded(
            //     child: groupedData.isEmpty
            //         ? const Center(child: Text("No data found"))
            //         : ListView.builder(
            //             itemCount: groupedData.length,
            //             itemBuilder: (context, index) {
            //               final process = groupedData.keys.elementAt(index);
            //               final items = groupedData[process]!;

            //               return Card(
            //                 margin: const EdgeInsets.symmetric(
            //                     vertical: 8, horizontal: 4),
            //                 elevation: 4,
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(12),
            //                 ),
            //                 child: ExpansionTile(
            //                   title: Text(
            //                     "${items.first.department} | $process",
            //                     style: const TextStyle(
            //                       fontSize: 20,
            //                       color: Colors.blue,
            //                       fontWeight: FontWeight.bold,
            //                     ),
            //                   ),
            //                   childrenPadding: const EdgeInsets.all(16),
            //                   expandedCrossAxisAlignment:
            //                       CrossAxisAlignment.start,
            //                   children: items.map((data) {
            //                     return Padding(
            //                       padding: const EdgeInsets.only(bottom: 12.0),
            //                       child: Column(
            //                         crossAxisAlignment:
            //                             CrossAxisAlignment.start,
            //                         children: [
            //                           bGradeDataTextWidget(
            //                             'Date',
            //                             DateFormat('yyyy-MM-dd')
            //                                 .format(data.date),
            //                           ),
            //                           bGradeDataTextWidget(
            //                               'Output', data.output.toString()),
            //                           bGradeDataTextWidget(
            //                               'B Grade', data.bGrade.toString()),
            //                           bGradeDataTextWidget(
            //                               'Repairs', data.repairs.toString()),
            //                           bGradeDataTextWidget('B Grade %',
            //                               data.bGradePercent.toString()),
            //                           const Divider(), // Optional visual separator
            //                         ],
            //                       ),
            //                     );
            //                   }).toList(),
            //                 ),
            //               );
            //             },
            //           )),

            Expanded(
              child: selectedReport == 'IE Efficiency'
                  // ? (ieEfficiencyList.isEmpty
                  //     ? const Center(child: Text("No data found"))
                  //     : ListView.builder(
                  //         itemCount: ieEfficiencyList.length,
                  //         itemBuilder: (context, index) {
                  //           final data = ieEfficiencyList[index];
                  //           return Card(
                  //             margin: const EdgeInsets.symmetric(
                  //                 vertical: 8, horizontal: 4),
                  //             elevation: 4,
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(12),
                  //             ),
                  //             child: Padding(
                  //               padding: const EdgeInsets.all(16.0),
                  //               child: Column(
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 children: [
                  //                   // Text(
                  //                   //   data.prodLine,
                  //                   //   style: const TextStyle(
                  //                   //     fontSize: 18,
                  //                   //     fontWeight: FontWeight.bold,
                  //                   //     color: Colors.blue,
                  //                   //   ),
                  //                   // ),

                  //                   const SizedBox(height: 8),
                  //                   // Text("Date: ${data.prodDate}"),
                  //                     reportsDataTextWidget(
                  //                       'Line', data.prodLine.toString()),
                  //                   reportsDataTextWidget(
                  //                       'Date', data.prodDate.toString()),
                  //                   reportsDataTextWidget('Standard Manhours',
                  //                       data.standardManhours.toString()),
                  //                   reportsDataTextWidget('Actual Manhours',
                  //                       data.actualManhours.toString()),
                  //                   reportsDataTextWidget(
                  //                       'IE', "${data.ie.toStringAsFixed(2)}%"),
                  //                 ],
                  //               ),
                  //             ),
                  //           );
                  //         },
                  //       ))

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
