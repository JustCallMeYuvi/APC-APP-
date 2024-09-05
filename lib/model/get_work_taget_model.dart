// // To parse this JSON data, do
// //
// //     final getWorkTarget = getWorkTargetFromJson(jsonString);

// import 'dart:convert';

// List<GetWorkTarget> getWorkTargetFromJson(String str) => List<GetWorkTarget>.from(json.decode(str).map((x) => GetWorkTarget.fromJson(x)));

// String getWorkTargetToJson(List<GetWorkTarget> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class GetWorkTarget {
//     String grTDept;
//     String line;
//     DateTime? worKDay;
//     int outputQuantity;
//     int workQuantitySum;
//     ProcessNo processNo;

//     GetWorkTarget({
//         required this.grTDept,
//         required this.line,
//         required this.worKDay,
//         required this.outputQuantity,
//         required this.workQuantitySum,
//         required this.processNo,
//     });

//     factory GetWorkTarget.fromJson(Map<String, dynamic> json) => GetWorkTarget(
//         grTDept: json["grT_DEPT"],
//         line: json["line"],
//         worKDay: json["worK_DAY"] == null ? null : DateTime.parse(json["worK_DAY"]),
//         outputQuantity: json["output_Quantity"],
//         workQuantitySum: json["work_quantity_sum"],
//         processNo: processNoValues.map[json["process_No"]]!,
//     );

//     Map<String, dynamic> toJson() => {
//         "grT_DEPT": grTDept,
//         "line": line,
//         "worK_DAY": worKDay?.toIso8601String(),
//         "output_Quantity": outputQuantity,
//         "work_quantity_sum": workQuantitySum,
//         "process_No": processNoValues.reverse[processNo],
//     };
// }

// enum ProcessNo {
//     A,
//     AC,
//     C,
//     CMD,
//     CS,
//     DCD,
//     EMPTY,
//     FI,
//     IMD,
//     L,
//     LM,
//     S,
//     SPD,
//     T
// }

// final processNoValues = EnumValues({
//     "A": ProcessNo.A,
//     "AC": ProcessNo.AC,
//     "C": ProcessNo.C,
//     "CMD": ProcessNo.CMD,
//     "CS": ProcessNo.CS,
//     "DCD": ProcessNo.DCD,
//     "": ProcessNo.EMPTY,
//     "FI": ProcessNo.FI,
//     "IMD": ProcessNo.IMD,
//     "L": ProcessNo.L,
//     "LM": ProcessNo.LM,
//     "S": ProcessNo.S,
//     "SPD": ProcessNo.SPD,
//     "T": ProcessNo.T
// });

// class EnumValues<T> {
//     Map<String, T> map;
//     late Map<T, String> reverseMap;

//     EnumValues(this.map);

//     Map<T, String> get reverse {
//             reverseMap = map.map((k, v) => MapEntry(v, k));
//             return reverseMap;
//     }
// }
