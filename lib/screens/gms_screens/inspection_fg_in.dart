// import 'package:flutter/material.dart';

// class InspectionSection extends StatefulWidget {
//   final String title;
//   final List<String> inspectionPoints;
//   final String passLabel;
//   final String failLabel;

//   const InspectionSection({
//     Key? key,
//     required this.title,
//     required this.inspectionPoints,
//     required this.passLabel,
//     required this.failLabel,
//   }) : super(key: key);

//   @override
//   InspectionSectionState createState() => InspectionSectionState();
// }

// class InspectionSectionState extends State<InspectionSection> {
//   final Map<String, String> _selectedValues = {}; // Tracks selected values
//   final List<String> _unselectedInspectionPoints =
//       []; // Tracks unselected points
//   // Getter for _selectedValues
//   Map<String, String> get selectedValues => _selectedValues;
//   // Validation logic to check if all options are selected
//   // Validation logic to check if all options are selected
//   bool validate() {
//     _unselectedInspectionPoints.clear(); // Reset the unselected list
//     widget.inspectionPoints.forEach((point) {
//       if (_selectedValues[point] == null) {
//         _unselectedInspectionPoints.add(point); // Add unselected points
//       }
//     });
//     return _unselectedInspectionPoints.isEmpty; // Pass if no unselected points
//   }

//   // Method to check the overall inspection result
//   String get inspectionResult {
//     bool isFail = false;
//     _selectedValues.forEach((key, value) {
//       if (value == widget.failLabel) {
//         isFail = true;
//       }
//     });
//     return isFail ? "Fail" : "Pass";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 10),
//         ExpansionTile(
//           title: Text(
//             widget.title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           children: widget.inspectionPoints
//               .map((point) => Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0, vertical: 4.0),
//                     child: _radioButtonRow(point),
//                   ))
//               .toList(),
//         ),
//         const SizedBox(height: 10),
//         // Display the overall inspection result
//         Text(
//           'Inspection Result: ${inspectionResult}',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: inspectionResult == "Fail" ? Colors.red : Colors.green,
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget _radioButtonRow(String label) {
//   //   // Check if the current inspection point is unselected
//   //   bool isUnselected = _unselectedInspectionPoints.contains(label);

//   //   return Row(
//   //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //     children: [
//   //       Expanded(
//   //         child: Text(
//   //           label,
//   //           style: TextStyle(
//   //             fontSize: 16,
//   //             color: isUnselected
//   //                 ? Colors.red
//   //                 : Colors.black, // Highlight unselected points in red
//   //           ),
//   //           softWrap: true,
//   //           maxLines: 2,
//   //           overflow: TextOverflow.ellipsis,
//   //         ),
//   //       ),
//   //       Row(
//   //         children: [
//   //           Row(
//   //             children: [
//   //               Radio(
//   //                 value: widget.passLabel,
//   //                 groupValue: _selectedValues[label],
//   //                 onChanged: (value) {
//   //                   setState(() {
//   //                     _selectedValues[label] = value.toString();
//   //                   });
//   //                 },
//   //               ),
//   //               Text(widget.passLabel),
//   //             ],
//   //           ),
//   //           Row(
//   //             children: [
//   //               Radio(
//   //                 value: widget.failLabel,
//   //                 groupValue: _selectedValues[label],
//   //                 onChanged: (value) {
//   //                   setState(() {
//   //                     _selectedValues[label] = value.toString();
//   //                   });
//   //                 },
//   //               ),
//   //               Text(widget.failLabel),
//   //             ],
//   //           ),
//   //         ],
//   //       ),
//   //     ],
//   //   );
//   // }

//   Widget _radioButtonRow(String label) {
//     // Check if the current inspection point is unselected
//     bool isUnselected = _unselectedInspectionPoints.contains(label);

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 16,
//               color: isUnselected
//                   ? Colors.red
//                   : Colors.black, // Highlight unselected points in red
//             ),
//             softWrap: true,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         Row(
//           children: [
//             Row(
//               children: [
//                 Radio<String>(
//                   value: widget.passLabel,
//                   groupValue: _selectedValues[label],
//                   onChanged: (String? value) {
//                     setState(() {
//                       _selectedValues[label] = value!;
//                     });
//                   },
//                 ),
//                 Text(widget.passLabel),
//               ],
//             ),
//             Row(
//               children: [
//                 Radio<String>(
//                   value: widget.failLabel,
//                   groupValue: _selectedValues[label],
//                   onChanged: (String? value) {
//                     setState(() {
//                       _selectedValues[label] = value!;
//                     });
//                   },
//                 ),
//                 Text(widget.failLabel),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
