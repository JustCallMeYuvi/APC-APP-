// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';

// import 'package:http/http.dart' as http;

// // ════════════════════════════════════════════════════════════
// //  DATA MODELS
// // ════════════════════════════════════════════════════════════

// /// Model for year-by-year API response (averageHeadCount is double)
// class TurnOverYearModel {
//   final int year;
//   final int beginHeadCount;
//   final int endHeadCount;
//   final double averageHeadCount;
//   final int employeesLeft;
//   final double turnoverRate;
//   final double turnoverPercentage;

//   const TurnOverYearModel({
//     required this.year,
//     required this.beginHeadCount,
//     required this.endHeadCount,
//     required this.averageHeadCount,
//     required this.employeesLeft,
//     required this.turnoverRate,
//     required this.turnoverPercentage,
//   });

//   factory TurnOverYearModel.fromJson(Map<String, dynamic> json) =>
//       TurnOverYearModel(
//         year: json['year'] as int,
//         beginHeadCount: json['beginHeadCount'] as int,
//         endHeadCount: json['endHeadCount'] as int,
//         averageHeadCount: (json['averageHeadCount'] ?? 0).toDouble(),
//         employeesLeft: json['employeesLeft'] as int,
//         turnoverRate: (json['turnoverRate'] ?? 0).toDouble(),
//         turnoverPercentage: (json['turnoverPercentage'] ?? 0).toDouble(),
//       );
// }

// /// Model for overall/aggregate API response (averageHeadCount is int)
// class TurnOverAllModel {
//   final int year;
//   final int beginHeadCount;
//   final int endHeadCount;
//   final int averageHeadCount;
//   final int employeesLeft;
//   final double turnoverRate;
//   final double turnoverPercentage;

//   const TurnOverAllModel({
//     required this.year,
//     required this.beginHeadCount,
//     required this.endHeadCount,
//     required this.averageHeadCount,
//     required this.employeesLeft,
//     required this.turnoverRate,
//     required this.turnoverPercentage,
//   });

//   factory TurnOverAllModel.fromJson(Map<String, dynamic> json) =>
//       TurnOverAllModel(
//         year: json['year'] as int,
//         beginHeadCount: json['beginHeadCount'] as int,
//         endHeadCount: json['endHeadCount'] as int,
//         averageHeadCount: (json['averageHeadCount'] ?? 0).toInt(),
//         employeesLeft: json['employeesLeft'] as int,
//         turnoverRate: (json['turnoverRate'] ?? 0).toDouble(),
//         turnoverPercentage: (json['turnoverPercentage'] ?? 0).toDouble(),
//       );
// }

// // ════════════════════════════════════════════════════════════
// //  INTERNAL VIEW MODEL
// // ════════════════════════════════════════════════════════════

// class TurnoverRecord {
//   final int year, beginHC, endHC, left;
//   final double avgHC, rate, pct;

//   const TurnoverRecord({
//     required this.year,
//     required this.beginHC,
//     required this.endHC,
//     required this.avgHC,
//     required this.left,
//     required this.rate,
//     required this.pct,
//     required String monthYear,
//   });

//   int get netChange => endHC - beginHC;
//   double get retentionPct => 100 - pct;

//   factory TurnoverRecord.fromYearModel(TurnOverYearModel m) => TurnoverRecord(
//         year: m.year,
//         beginHC: m.beginHeadCount,
//         endHC: m.endHeadCount,
//         avgHC: m.averageHeadCount,
//         left: m.employeesLeft,
//         rate: m.turnoverRate,
//         pct: m.turnoverPercentage,
//         monthYear: '',
//       );

//   factory TurnoverRecord.fromAllModel(TurnOverAllModel m) => TurnoverRecord(
//         year: m.year,
//         beginHC: m.beginHeadCount,
//         endHC: m.endHeadCount,
//         avgHC: m.averageHeadCount.toDouble(),
//         left: m.employeesLeft,
//         rate: m.turnoverRate,
//         pct: m.turnoverPercentage,
//         monthYear: '',
//       );
// }

// // ════════════════════════════════════════════════════════════
// //  FILTER STATE MODEL
// // ════════════════════════════════════════════════════════════

// /// Which sub-view is active under the "All" type toggle
// enum SubView { yearwise, monthwise }

// class FilterState {
//   final SubView subView;
//   // Yearwise params
//   final int fromYear;
//   final int toYear;
//   // Monthwise params
//   final int monthYear;
//   final int fromMonth;
//   final int toMonth;
//   // Overall toggle (Yearwise view only)
//   final String view; // 'Yearwise' | 'Overall'

//   const FilterState({
//     this.subView = SubView.yearwise,
//     this.fromYear = 2006,
//     this.toYear = 2026,
//     this.monthYear = 2026,
//     this.fromMonth = 1,
//     this.toMonth = 12,
//     this.view = 'Yearwise',
//   });

//   FilterState copyWith({
//     SubView? subView,
//     int? fromYear,
//     int? toYear,
//     int? monthYear,
//     int? fromMonth,
//     int? toMonth,
//     String? view,
//   }) =>
//       FilterState(
//         subView: subView ?? this.subView,
//         fromYear: fromYear ?? this.fromYear,
//         toYear: toYear ?? this.toYear,
//         monthYear: monthYear ?? this.monthYear,
//         fromMonth: fromMonth ?? this.fromMonth,
//         toMonth: toMonth ?? this.toMonth,
//         view: view ?? this.view,
//       );

//   /// Build the request body sent to the API
//   Map<String, dynamic> toRequestBody(String apiType) {
//     if (subView == SubView.monthwise) {
//       return {
//         'type': apiType, // 'year' or 'all'
//         'fromYear': monthYear,
//         'toYear': monthYear,
//         'year': monthYear,
//         'fromMonth': fromMonth,
//         'toMonth': toMonth,
//       };
//     } else {
//       return {
//         'type': apiType,
//         'fromYear': fromYear,
//         'toYear': toYear,
//         'year': fromYear,
//         'fromMonth': 1,
//         'toMonth': 12,
//       };
//     }
//   }
// }

// // ════════════════════════════════════════════════════════════
// //  API SERVICE
// // ════════════════════════════════════════════════════════════

// // class TurnoverApiService {
// //   static const String _baseUrl =
// //       'http://10.3.0.70:9042/api/HR/GetTurnOverReport';

// //   static Future<List<TurnoverRecord>> fetchYearwise(FilterState fs) async {
// //     final body = fs.toRequestBody('year');
// //     final response = await http
// //         .post(
// //           Uri.parse(_baseUrl),
// //           headers: {'accept': '*/*', 'Content-Type': 'application/json'},
// //           body: jsonEncode(body),
// //         )
// //         .timeout(const Duration(seconds: 15));

// //     if (response.statusCode == 200) {
// //       final List<dynamic> jsonList = json.decode(response.body);
// //       return jsonList
// //           .map((j) =>
// //               TurnoverRecord.fromYearModel(TurnOverYearModel.fromJson(j)))
// //           .toList();
// //     }
// //     throw Exception('Year API failed with status ${response.statusCode}');
// //   }

// //   static Future<TurnoverRecord> fetchOverall(FilterState fs) async {
// //     final body = fs.toRequestBody('all');
// //     final response = await http
// //         .post(
// //           Uri.parse(_baseUrl),
// //           headers: {'accept': '*/*', 'Content-Type': 'application/json'},
// //           body: jsonEncode(body),
// //         )
// //         .timeout(const Duration(seconds: 15));

// //     if (response.statusCode == 200) {
// //       final List<dynamic> jsonList = json.decode(response.body);
// //       if (jsonList.isEmpty) throw Exception('Overall API returned empty list');
// //       return TurnoverRecord.fromAllModel(
// //           TurnOverAllModel.fromJson(jsonList.first));
// //     }
// //     throw Exception('Overall API failed with status ${response.statusCode}');
// //   }
// // }

// class TurnoverApiService {
//   static const String _baseUrl =
//       'http://10.3.0.70:9042/api/HR/GetTurnOverReport';

//   /// YEARWISE
//   static Future<List<TurnoverRecord>> fetchYearwise(FilterState fs) async {
//     final response = await http
//         .post(
//           Uri.parse(_baseUrl),
//           headers: {
//             'accept': '*/*',
//             'Content-Type': 'application/json',
//           },
//           body: jsonEncode(fs.toRequestBody('year')),
//         )
//         .timeout(const Duration(seconds: 15));

//     if (response.statusCode != 200) {
//       throw Exception('Year API failed with status ${response.statusCode}');
//     }

//     final List<dynamic> jsonList = jsonDecode(response.body);

//     return jsonList
//         .map(
//           (e) => TurnoverRecord(
//             year: e['year'] ?? 0,
//             monthYear: '',
//             beginHC: e['beginHeadCount'] ?? 0,
//             endHC: e['endHeadCount'] ?? 0,
//             avgHC: (e['averageHeadCount'] ?? 0).toDouble(),
//             left: e['employeesLeft'] ?? 0,
//             rate: (e['turnoverRate'] ?? 0).toDouble(),
//             pct: (e['turnoverPercentage'] ?? 0).toDouble(),
//           ),
//         )
//         .toList();
//   }

//   /// MONTHWISE
//   static Future<List<TurnoverRecord>> fetchMonthwise(FilterState fs) async {
//     final response = await http
//         .post(
//           Uri.parse(_baseUrl),
//           headers: {
//             'accept': '*/*',
//             'Content-Type': 'application/json',
//           },
//           body: jsonEncode(fs.toRequestBody('month')),
//         )
//         .timeout(const Duration(seconds: 15));

//     if (response.statusCode != 200) {
//       throw Exception('Month API failed with status ${response.statusCode}');
//     }

//     final List<dynamic> jsonList = jsonDecode(response.body);

//     return jsonList
//         .map(
//           (e) => TurnoverRecord(
//             year: e['year'] ?? 0,
//             monthYear: e['monthYear'] ?? '',
//             beginHC: e['beginHeadCount'] ?? 0,
//             endHC: e['endHeadCount'] ?? 0,
//             avgHC: (e['averageHeadCount'] ?? 0).toDouble(),
//             left: e['employeesLeft'] ?? 0,
//             rate: (e['turnoverRate'] ?? 0).toDouble(),
//             pct: (e['turnoverPercentage'] ?? 0).toDouble(),
//           ),
//         )
//         .toList();
//   }
// }
// // ════════════════════════════════════════════════════════════
// //  HELPERS
// // ════════════════════════════════════════════════════════════

// const int _currentYear = 2026;

// String _monthName(int m) => const [
//       '',
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ][m];

// String _fmtK(double v) => v.abs() >= 1000
//     ? '${(v / 1000).toStringAsFixed(1)}K'
//     : v.round().toString();

// String _commas(int v) {
//   final s = v.toString();
//   final b = StringBuffer();
//   for (int i = 0; i < s.length; i++) {
//     if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
//     b.write(s[i]);
//   }
//   return b.toString();
// }

// // ════════════════════════════════════════════════════════════
// //  THEME TOKENS
// // ════════════════════════════════════════════════════════════

// const Color _c0 = Color(0xFF0F172A);
// const Color _c1 = Color(0xFF1E293B);
// const Color _c2 = Color(0xFF475569);
// const Color _c3 = Color(0xFF94A3B8);
// const Color _cBg = Color(0xFFF8FAFC);
// const Color _cCard = Colors.white;
// const Color _cBdr = Color(0xFFE2E8F0);

// const Color _cBlue = Color(0xFF2563EB);
// const Color _cIndi = Color(0xFF6366F1);
// const Color _cTeal = Color(0xFF0D9488);
// const Color _cAmber = Color(0xFFD97706);
// const Color _cRose = Color(0xFFE11D48);
// const Color _cPurp = Color(0xFF7C3AED);
// const Color _cSlate = Color(0xFF64748B);

// Color _tint(Color c, [double o = 0.10]) => c.withOpacity(o);

// String _riskLabel(double p) => p < 10
//     ? 'Healthy'
//     : p < 20
//         ? 'Moderate'
//         : p < 30
//             ? 'High'
//             : 'Critical';

// Color _riskColor(double p) => p < 10
//     ? _cTeal
//     : p < 20
//         ? _cAmber
//         : _cRose;

// // ════════════════════════════════════════════════════════════
// //  DASHBOARD – root widget
// // ════════════════════════════════════════════════════════════

// class TurnOverScreen extends StatefulWidget {
//   const TurnOverScreen({super.key});

//   @override
//   State<TurnOverScreen> createState() => _TurnOverScreenState();
// }

// class _TurnOverScreenState extends State<TurnOverScreen>
//     with SingleTickerProviderStateMixin {
//   FilterState _filter = const FilterState();
//   int _tab = 0;

//   List<TurnoverRecord> _yearData = [];
//   TurnoverRecord? _overallData;
//   bool _loading = false;
//   String? _error;

//   late AnimationController _ac;
//   late Animation<double> _fade;

//   @override
//   void initState() {
//     super.initState();
//     _ac = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 320));
//     _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _ac.dispose();
//     super.dispose();
//   }

//   // Future<void> _loadData() async {
//   //   setState(() {
//   //     _loading = true;
//   //     _error = null;
//   //   });
//   //   try {
//   //     final results = await Future.wait([
//   //       TurnoverApiService.fetchYearwise(_filter),
//   //       // TurnoverApiService.fetchOverall(_filter),

//   //     ]);
//   //     _yearData = results[0] as List<TurnoverRecord>;
//   //     _overallData = results[1] as TurnoverRecord;
//   //     _ac.reset();
//   //     _ac.forward();
//   //   } catch (e) {
//   //     _error = e.toString();
//   //   } finally {
//   //     if (mounted) setState(() => _loading = false);
//   //   }
//   // }
//   Future<void> _loadData() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       if (_filter.subView == SubView.yearwise) {
//         _yearData = await TurnoverApiService.fetchYearwise(_filter);
//       } else {
//         _yearData = await TurnoverApiService.fetchMonthwise(_filter);
//       }

//       // 👇 Add here
//       print('Records Count: ${_yearData.length}');
//       print('Current View: ${_filter.subView}');
//       _ac.reset();
//       _ac.forward();
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }

//   void _onFilterChanged(FilterState fs) {
//     setState(() => _filter = fs);
//     _loadData();
//   }

//   @override
//   Widget build(BuildContext ctx) {
//     final w = MediaQuery.of(ctx).size.width;
//     return w >= 900 ? _wideLayout() : _narrowLayout();
//   }

//   Widget _wideLayout() => Scaffold(
//         backgroundColor: _cBg,
//         body: Row(children: [
//           _SideNav(tab: _tab, onTab: (t) => setState(() => _tab = t)),
//           Expanded(
//               child: Column(children: [
//             _FilterBar(
//                 filter: _filter, onChanged: _onFilterChanged, isWide: true),
//             Expanded(
//                 child: _loading
//                     ? const _Loader()
//                     : _error != null
//                         ? _ErrorView(error: _error!, onRetry: _loadData)
//                         : FadeTransition(opacity: _fade, child: _tabContent())),
//           ])),
//         ]),
//       );

//   Widget _narrowLayout() => Scaffold(
//         backgroundColor: _cBg,
//         body: Column(children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               border: Border(bottom: BorderSide(color: _cBdr)),
//             ),
//             child: Row(children: [
//               _AppIcon(),
//               const SizedBox(width: 10),
//               const Expanded(
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('HR Analytics',
//                           style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w700,
//                               color: _c0)),
//                       Text('Turnover Dashboard',
//                           style: TextStyle(fontSize: 11, color: _c2)),
//                     ]),
//               ),
//               const _LiveBadge(),
//             ]),
//           ),
//           _FilterBar(
//               filter: _filter, onChanged: _onFilterChanged, isWide: false),
//           _TabStrip(tab: _tab, onTab: (t) => setState(() => _tab = t)),
//           Expanded(
//               child: _loading
//                   ? const _Loader()
//                   : _error != null
//                       ? _ErrorView(error: _error!, onRetry: _loadData)
//                       : FadeTransition(opacity: _fade, child: _tabContent())),
//         ]),
//       );

//   Widget _tabContent() {
//     if (_yearData.isEmpty && _overallData == null) return const _Empty();

//     // For "Overall" view (yearwise subview only) show aggregate as single item
//     final displayList = _filter.subView == SubView.yearwise &&
//             _filter.view == 'Overall' &&
//             _overallData != null
//         ? [_overallData!]
//         : _yearData;

//     final agg = _overallData ?? (_yearData.isNotEmpty ? _yearData.first : null);
//     if (agg == null) return const _Empty();

//     switch (_tab) {
//       case 0:
//         return _OverviewTab(
//             data: displayList, raw: _yearData, filter: _filter, agg: agg);
//       case 1:
//         return _ChartsTab(data: _yearData);
//       case 2:
//         return _TableTab(data: _yearData);
//       case 3:
//         return _InsightsTab(data: _yearData, agg: agg);
//       case 4:
//         return _SummaryTab(data: _yearData, agg: agg);
//       default:
//         return const SizedBox();
//     }
//   }
// }

// // ════════════════════════════════════════════════════════════
// //  LOADING & ERROR
// // ════════════════════════════════════════════════════════════

// class _Loader extends StatelessWidget {
//   const _Loader();

//   @override
//   Widget build(BuildContext ctx) => const Center(
//           child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//         CircularProgressIndicator(color: _cBlue, strokeWidth: 2.5),
//         SizedBox(height: 14),
//         Text('Loading turnover data…',
//             style: TextStyle(fontSize: 13, color: _c2)),
//       ]));
// }

// class _ErrorView extends StatelessWidget {
//   final String error;
//   final VoidCallback onRetry;
//   const _ErrorView({required this.error, required this.onRetry});

//   @override
//   Widget build(BuildContext ctx) => Center(
//           child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           const Icon(Icons.wifi_off_rounded, size: 48, color: _cRose),
//           const SizedBox(height: 12),
//           const Text('Failed to load data',
//               style: TextStyle(
//                   fontSize: 16, fontWeight: FontWeight.w700, color: _c0)),
//           const SizedBox(height: 6),
//           Text(error,
//               style: const TextStyle(fontSize: 11, color: _c3),
//               textAlign: TextAlign.center),
//           const SizedBox(height: 18),
//           ElevatedButton.icon(
//             onPressed: onRetry,
//             icon: const Icon(Icons.refresh_rounded, size: 16),
//             label: const Text('Retry'),
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: _cBlue, foregroundColor: Colors.white),
//           ),
//         ]),
//       ));
// }

// // ════════════════════════════════════════════════════════════
// //  FILTER BAR  ← FULLY REWRITTEN
// // ════════════════════════════════════════════════════════════

// class _FilterBar extends StatelessWidget {
//   final FilterState filter;
//   final void Function(FilterState) onChanged;
//   final bool isWide;

//   const _FilterBar({
//     required this.filter,
//     required this.onChanged,
//     required this.isWide,
//   });

//   static final List<int> _allYears =
//       List.generate(_currentYear - 2006 + 1, (i) => 2006 + i);

//   static const List<int> _months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

//   @override
//   Widget build(BuildContext ctx) {
//     return Container(
//       color: _cCard,
//       padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 14, vertical: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Row 1: SubView toggle + (yearwise) Overall toggle + quick chips ──
//           Wrap(
//             spacing: 10,
//             runSpacing: 10,
//             crossAxisAlignment: WrapCrossAlignment.end,
//             children: [
//               _SubViewToggle(
//                 value: filter.subView,
//                 onChanged: (sv) => onChanged(filter.copyWith(subView: sv)),
//               ),
//               // if (filter.subView == SubView.yearwise) ...[
//               //   _ViewToggle(
//               //     value: filter.view,
//               //     onChanged: (v) => onChanged(filter.copyWith(view: v)),
//               //   ),
//               //   _QuickChips(filter: filter, onChanged: onChanged),
//               // ],
//             ],
//           ),
//           const SizedBox(height: 10),
//           // ── Row 2: Date pickers depending on subView ──
//           if (filter.subView == SubView.yearwise)
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               crossAxisAlignment: WrapCrossAlignment.end,
//               children: [
//                 _YearAuto(
//                   label: 'From Year',
//                   value: filter.fromYear,
//                   allYears: _allYears,
//                   maxY: filter.toYear,
//                   onChanged: (y) => onChanged(filter.copyWith(fromYear: y)),
//                 ),
//                 _YearAuto(
//                   label: 'To Year',
//                   value: filter.toYear,
//                   allYears: _allYears,
//                   minY: filter.fromYear,
//                   onChanged: (y) => onChanged(filter.copyWith(toYear: y)),
//                 ),
//               ],
//             )
//           else
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               crossAxisAlignment: WrapCrossAlignment.end,
//               children: [
//                 _YearAuto(
//                   label: 'Year',
//                   value: filter.monthYear,
//                   allYears: _allYears,
//                   onChanged: (y) => onChanged(filter.copyWith(monthYear: y)),
//                 ),
//                 _MonthDropdown(
//                   label: 'From Month',
//                   value: filter.fromMonth,
//                   months: _months,
//                   maxMonth: filter.toMonth,
//                   onChanged: (m) => onChanged(filter.copyWith(fromMonth: m)),
//                   selectedYear: filter.monthYear,
//                 ),
//                 _MonthDropdown(
//                   label: 'To Month',
//                   value: filter.toMonth,
//                   months: _months,
//                   minMonth: filter.fromMonth,
//                   onChanged: (m) => onChanged(filter.copyWith(toMonth: m)),
//                   selectedYear: filter.monthYear,
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ── SubView toggle: Yearwise / Monthwise ──────────────────────

// class _SubViewToggle extends StatelessWidget {
//   final SubView value;
//   final void Function(SubView) onChanged;
//   const _SubViewToggle({required this.value, required this.onChanged});

//   @override
//   Widget build(BuildContext ctx) =>
//       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const Text('Type',
//             style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//                 color: _c2,
//                 letterSpacing: 0.3)),
//         const SizedBox(height: 4),
//         Container(
//           height: 38,
//           decoration: BoxDecoration(
//               color: _cBg,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: _cBdr)),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _svBtn('Yearwise', SubView.yearwise),
//               _svBtn('Monthwise', SubView.monthwise),
//             ],
//           ),
//         ),
//       ]);

//   Widget _svBtn(String label, SubView sv) {
//     final sel = value == sv;
//     return GestureDetector(
//       onTap: () => onChanged(sv),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//         decoration: BoxDecoration(
//             color: sel ? _cIndi : Colors.transparent,
//             borderRadius: BorderRadius.circular(9)),
//         child: Text(label,
//             style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: sel ? Colors.white : _c2)),
//       ),
//     );
//   }
// }

// // ════════════════════════════════════════════════════════════
// //  UNIFIED PICKER FIELD  (Year & Month — identical look)
// // ════════════════════════════════════════════════════════════

// /// A tappable field that opens a styled bottom-sheet list.
// /// Used for both year and month selection so both look identical.
// class _PickerField extends StatelessWidget {
//   final String label;
//   final String displayValue; // text shown on the field button
//   final List<int> items;
//   final int selectedItem;
//   final String Function(int) itemLabel; // how each item is displayed in sheet
//   final void Function(int) onChanged;

//   const _PickerField({
//     required this.label,
//     required this.displayValue,
//     required this.items,
//     required this.selectedItem,
//     required this.itemLabel,
//     required this.onChanged,
//   });

//   void _openSheet(BuildContext ctx) {
//     // scroll to selected item
//     final idx = items.indexOf(selectedItem);
//     final sc =
//         ScrollController(initialScrollOffset: idx > 3 ? (idx - 3) * 52.0 : 0);

//     showModalBottomSheet(
//       context: ctx,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => StatefulBuilder(
//         builder: (bCtx, setS) => Container(
//           constraints:
//               BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.55),
//           decoration: const BoxDecoration(
//             color: _cCard,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ── handle ──
//               const SizedBox(height: 10),
//               Container(
//                   width: 36,
//                   height: 4,
//                   decoration: BoxDecoration(
//                       color: _cBdr, borderRadius: BorderRadius.circular(2))),
//               const SizedBox(height: 12),
//               // ── title ──
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(children: [
//                   Text(label,
//                       style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           color: _c0)),
//                   const Spacer(),
//                   GestureDetector(
//                     onTap: () => Navigator.pop(bCtx),
//                     child: Container(
//                       width: 28,
//                       height: 28,
//                       decoration: BoxDecoration(
//                           color: _cBg, borderRadius: BorderRadius.circular(8)),
//                       child:
//                           const Icon(Icons.close_rounded, size: 16, color: _c2),
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: 8),
//               const Divider(height: 1, color: _cBdr),
//               // ── list ──
//               Flexible(
//                 child: ListView.builder(
//                   controller: sc,
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   itemCount: items.length,
//                   itemBuilder: (_, i) {
//                     final item = items[i];
//                     final sel = item == selectedItem;
//                     return GestureDetector(
//                       onTap: () {
//                         onChanged(item);
//                         Navigator.pop(bCtx);
//                       },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 150),
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 2),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 13),
//                         decoration: BoxDecoration(
//                           color: sel ? _tint(_cBlue, 0.08) : Colors.transparent,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                               color: sel
//                                   ? _cBlue.withOpacity(0.3)
//                                   : Colors.transparent),
//                         ),
//                         child: Row(children: [
//                           Text(itemLabel(item),
//                               style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight:
//                                       sel ? FontWeight.w700 : FontWeight.w400,
//                                   color: sel ? _cBlue : _c0)),
//                           const Spacer(),
//                           if (sel)
//                             Container(
//                               width: 22,
//                               height: 22,
//                               decoration: BoxDecoration(
//                                   color: _cBlue, shape: BoxShape.circle),
//                               child: const Icon(Icons.check_rounded,
//                                   size: 13, color: Colors.white),
//                             ),
//                         ]),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
//             ],
//           ),
//         ),
//       ),
//     ).whenComplete(() => sc.dispose());
//   }

//   @override
//   Widget build(BuildContext ctx) => SizedBox(
//         width: 130,
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(label,
//               style: const TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                   color: _c2,
//                   letterSpacing: 0.3)),
//           const SizedBox(height: 4),
//           GestureDetector(
//             onTap: () => _openSheet(ctx),
//             child: Container(
//               height: 48,
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 color: _cCard,
//                 border: Border.all(color: _cBdr),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(children: [
//                 Expanded(
//                   child: Text(displayValue,
//                       style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: _c0),
//                       overflow: TextOverflow.ellipsis),
//                 ),
//                 const Icon(Icons.keyboard_arrow_down_rounded,
//                     size: 18, color: _c3),
//               ]),
//             ),
//           ),
//         ]),
//       );
// }

// // ── Convenience wrappers keep call-sites clean ────────────────

// class _YearAuto extends StatelessWidget {
//   final String label;
//   final int value;
//   final List<int> allYears;
//   final int? minY, maxY;
//   final void Function(int) onChanged;

//   const _YearAuto({
//     required this.label,
//     required this.value,
//     required this.allYears,
//     this.minY,
//     this.maxY,
//     required this.onChanged,
//   });

//   List<int> get _filtered => allYears.where((y) {
//         if (minY != null && y < minY!) return false;
//         if (maxY != null && y > maxY!) return false;
//         return true;
//       }).toList();

//   @override
//   Widget build(BuildContext ctx) {
//     final years = _filtered;
//     final safe = years.contains(value)
//         ? value
//         : years.isNotEmpty
//             ? years.last
//             : value;
//     return _PickerField(
//       label: label,
//       displayValue: safe.toString(),
//       items: years,
//       selectedItem: safe,
//       itemLabel: (y) => y.toString(),
//       onChanged: onChanged,
//     );
//   }
// }

// // class _MonthDropdown extends StatelessWidget {
// //   final String label;
// //   final int value;
// //   final List<int> months;
// //   final int? minMonth, maxMonth;
// //   final void Function(int) onChanged;

// //   const _MonthDropdown({
// //     required this.label,
// //     required this.value,
// //     required this.months,
// //     this.minMonth,
// //     this.maxMonth,
// //     required this.onChanged,
// //   });

// //   List<int> get _filtered => months.where((m) {
// //         if (minMonth != null && m < minMonth!) return false;
// //         if (maxMonth != null && m > maxMonth!) return false;
// //         return true;
// //       }).toList();

// //   @override
// //   Widget build(BuildContext ctx) {
// //     final filtered = _filtered;
// //     final safe = filtered.contains(value)
// //         ? value
// //         : filtered.isNotEmpty
// //             ? filtered.first
// //             : value;
// //     return _PickerField(
// //       label: label,
// //       displayValue: '${_monthName(safe)} ($safe)',
// //       items: filtered,
// //       selectedItem: safe,
// //       itemLabel: (m) => '$m  —  ${_monthName(m)}',
// //       onChanged: onChanged,
// //     );
// //   }
// // }

// class _MonthDropdown extends StatelessWidget {
//   final String label;
//   final int value;
//   final List<int> months;
//   final int selectedYear;
//   final int? minMonth, maxMonth;
//   final void Function(int) onChanged;

//   const _MonthDropdown({
//     required this.label,
//     required this.value,
//     required this.months,
//     required this.selectedYear,
//     this.minMonth,
//     this.maxMonth,
//     required this.onChanged,
//   });

//   List<int> get _filtered {
//     final now = DateTime.now();

//     return months.where((m) {
//       if (minMonth != null && m < minMonth!) return false;
//       if (maxMonth != null && m > maxMonth!) return false;

//       // Disable future months for current year
//       if (selectedYear == now.year && m > now.month) {
//         return false;
//       }

//       return true;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext ctx) {
//     final filtered = _filtered;

//     final safe = filtered.contains(value)
//         ? value
//         : filtered.isNotEmpty
//             ? filtered.last
//             : value;

//     return _PickerField(
//       label: label,
//       displayValue: '${_monthName(safe)} ($safe)',
//       items: filtered,
//       selectedItem: safe,
//       itemLabel: (m) => '$m — ${_monthName(m)}',
//       onChanged: onChanged,
//     );
//   }
// }

// // ── ViewToggle (Yearwise / Overall) — shown only in Yearwise subview ──

// class _ViewToggle extends StatelessWidget {
//   final String value;
//   final void Function(String) onChanged;
//   const _ViewToggle({required this.value, required this.onChanged});

//   @override
//   Widget build(BuildContext ctx) =>
//       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const Text('View',
//             style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//                 color: _c2,
//                 letterSpacing: 0.3)),
//         const SizedBox(height: 4),
//         Container(
//           height: 38,
//           decoration: BoxDecoration(
//               color: _cBg,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: _cBdr)),
//           child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: ['Yearwise', 'Overall'].map((t) {
//                 final sel = value == t;
//                 return GestureDetector(
//                     onTap: () => onChanged(t),
//                     child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 180),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 14, vertical: 8),
//                         decoration: BoxDecoration(
//                             color: sel ? _cBlue : Colors.transparent,
//                             borderRadius: BorderRadius.circular(9)),
//                         child: Text(t,
//                             style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: sel ? Colors.white : _c2))));
//               }).toList()),
//         ),
//       ]);
// }

// // ── Quick date-range chips (Yearwise only) ────────────────────

// class _QuickChips extends StatelessWidget {
//   final FilterState filter;
//   final void Function(FilterState) onChanged;

//   const _QuickChips({required this.filter, required this.onChanged});

//   @override
//   Widget build(BuildContext ctx) {
//     const now = _currentYear;
//     final presets = [
//       ('3Y', now - 2, now),
//       ('5Y', now - 4, now),
//       ('10Y', now - 9, now),
//       ('All', 2006, now),
//     ];
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const Text('Quick',
//           style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.w600,
//               color: _c2,
//               letterSpacing: 0.3)),
//       const SizedBox(height: 4),
//       Row(
//           mainAxisSize: MainAxisSize.min,
//           children: presets.map((p) {
//             final sel = filter.fromYear == p.$2 && filter.toYear == p.$3;
//             return Padding(
//                 padding: const EdgeInsets.only(right: 5),
//                 child: GestureDetector(
//                     onTap: () => onChanged(
//                         filter.copyWith(fromYear: p.$2, toYear: p.$3)),
//                     child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 180),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 7),
//                         decoration: BoxDecoration(
//                             color: sel ? _cIndi : _cBg,
//                             border: Border.all(color: sel ? _cIndi : _cBdr),
//                             borderRadius: BorderRadius.circular(20)),
//                         child: Text(p.$1,
//                             style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600,
//                                 color: sel ? Colors.white : _c2)))));
//           }).toList()),
//     ]);
//   }
// }

// // ════════════════════════════════════════════════════════════
// //  SIDE NAV
// // ════════════════════════════════════════════════════════════

// class _SideNav extends StatelessWidget {
//   final int tab;
//   final void Function(int) onTab;
//   const _SideNav({required this.tab, required this.onTab});

//   static const _items = [
//     (Icons.dashboard_rounded, 'Overview'),
//     (Icons.bar_chart_rounded, 'Charts'),
//     (Icons.table_chart_rounded, 'Table'),
//     (Icons.lightbulb_rounded, 'Insights'),
//     (Icons.summarize_rounded, 'Summary'),
//   ];

//   @override
//   Widget build(BuildContext ctx) => Container(
//         width: 200,
//         color: _c0,
//         child: Column(children: [
//           const SizedBox(height: 24),
//           Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(children: [
//                 _AppIcon(),
//                 const SizedBox(width: 10),
//                 const Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('HR Analytics',
//                           style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white)),
//                       Text('Turnover',
//                           style: TextStyle(fontSize: 10, color: _c3)),
//                     ]),
//               ])),
//           const SizedBox(height: 24),
//           ..._items.asMap().entries.map((e) {
//             final sel = tab == e.key;
//             return GestureDetector(
//                 onTap: () => onTab(e.key),
//                 child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 180),
//                     margin:
//                         const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 14, vertical: 11),
//                     decoration: BoxDecoration(
//                         color: sel ? _cBlue : Colors.transparent,
//                         borderRadius: BorderRadius.circular(10)),
//                     child: Row(children: [
//                       Icon(e.value.$1,
//                           size: 18, color: sel ? Colors.white : _c3),
//                       const SizedBox(width: 10),
//                       Text(e.value.$2,
//                           style: TextStyle(
//                               fontSize: 13,
//                               fontWeight:
//                                   sel ? FontWeight.w600 : FontWeight.w400,
//                               color: sel ? Colors.white : _c3)),
//                     ])));
//           }),
//           const Spacer(),
//           const _LiveBadge(dark: true),
//           const SizedBox(height: 20),
//         ]),
//       );
// }

// class _TabStrip extends StatelessWidget {
//   final int tab;
//   final void Function(int) onTab;
//   const _TabStrip({required this.tab, required this.onTab});
//   static const _lbl = ['Overview', 'Charts', 'Table', 'Insights', 'Summary'];

//   @override
//   Widget build(BuildContext ctx) => Container(
//         color: _cCard,
//         child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//                 children: List.generate(_lbl.length, (i) {
//               final sel = tab == i;
//               return GestureDetector(
//                   onTap: () => onTab(i),
//                   child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 11),
//                       decoration: BoxDecoration(
//                           border: Border(
//                               bottom: BorderSide(
//                                   color: sel ? _cBlue : Colors.transparent,
//                                   width: 2.5))),
//                       child: Text(_lbl[i],
//                           style: TextStyle(
//                               fontSize: 12,
//                               fontWeight:
//                                   sel ? FontWeight.w700 : FontWeight.w400,
//                               color: sel ? _cBlue : _c2))));
//             }))),
//       );
// }

// // ════════════════════════════════════════════════════════════
// //  OVERVIEW TAB
// // ════════════════════════════════════════════════════════════

// class _OverviewTab extends StatelessWidget {
//   final List<TurnoverRecord> data, raw;
//   final FilterState filter;
//   final TurnoverRecord agg;

//   const _OverviewTab({
//     required this.data,
//     required this.raw,
//     required this.filter,
//     required this.agg,
//   });

//   String get _rangeLabel {
//     if (filter.subView == SubView.monthwise) {
//       return '${filter.monthYear}  •  '
//           '${_monthName(filter.fromMonth)} – ${_monthName(filter.toMonth)}';
//     }
//     return filter.view == 'Overall'
//         ? 'Aggregated  •  ${filter.fromYear} – ${filter.toYear}'
//         : 'Year-by-Year  •  ${filter.fromYear} – ${filter.toYear}  •  ${raw.length} records';
//   }

//   @override
//   Widget build(BuildContext ctx) {
//     if (data.isEmpty) return const _Empty();
//     final d = data.first;
//     final w = MediaQuery.of(ctx).size.width;
//     final cols = w >= 900
//         ? 4
//         : w >= 600
//             ? 3
//             : 2;
//     final pad = w >= 600 ? 20.0 : 14.0;

//     return ListView(padding: EdgeInsets.all(pad), children: [
//       _SecLabel(_rangeLabel),
//       const SizedBox(height: 12),
//       _Grid(cols: cols, gap: 10, children: [
//         _Kpi('Begin HC', d.beginHC.toString(), 'Start of period',
//             Icons.groups_rounded, _cBlue),
//         _Kpi('End HC', d.endHC.toString(), 'End of period', Icons.group_rounded,
//             _cTeal),
//         _Kpi('Avg HC', d.avgHC.round().toString(), 'Workforce avg',
//             Icons.people_outline_rounded, _cIndi),
//         _Kpi('Total Left', _commas(d.left), 'Departures',
//             Icons.exit_to_app_rounded, _cRose),
//         _Kpi('Retention', '${d.retentionPct.toStringAsFixed(1)}%', 'Stayed',
//             Icons.favorite_rounded, _cTeal),
//         _Kpi('Turnover', '${d.pct.toStringAsFixed(2)}%', _riskLabel(d.pct),
//             Icons.trending_down_rounded, _riskColor(d.pct)),
//         _Kpi(
//             'Net Change',
//             '${d.netChange >= 0 ? '+' : ''}${d.netChange}',
//             d.netChange >= 0 ? 'Grew' : 'Shrank',
//             d.netChange >= 0
//                 ? Icons.arrow_upward_rounded
//                 : Icons.arrow_downward_rounded,
//             d.netChange >= 0 ? _cTeal : _cRose),
//         _Kpi(
//             filter.subView == SubView.monthwise ? 'Months' : 'Years',
//             filter.subView == SubView.monthwise
//                 ? '${filter.toMonth - filter.fromMonth + 1}'
//                 : '${raw.length}',
//             filter.subView == SubView.monthwise
//                 ? '${_monthName(filter.fromMonth)} – ${_monthName(filter.toMonth)}'
//                 : '${filter.fromYear} – ${filter.toYear}',
//             Icons.calendar_month_rounded,
//             _cPurp),
//       ]),
//       const SizedBox(height: 16),
//       _Gauge(pct: d.pct),
//       const SizedBox(height: 12),
//       _Donut(retPct: d.retentionPct),
//       const SizedBox(height: 12),
//       if (raw.length > 1) _Spark(data: raw),
//     ]);
//   }
// }

// // ════════════════════════════════════════════════════════════
// //  CHARTS TAB
// // ════════════════════════════════════════════════════════════

// class _ChartsTab extends StatefulWidget {
//   final List<TurnoverRecord> data;
//   const _ChartsTab({required this.data});

//   @override
//   State<_ChartsTab> createState() => _ChartsTabState();
// }

// class _ChartsTabState extends State<_ChartsTab> {
//   String _m = 'Turnover %';
//   static const _opts = [
//     'Turnover %',
//     'Headcount',
//     'Attrition',
//     'Net Change',
//     'Retention %'
//   ];

//   List<double> _vals() => switch (_m) {
//         'Turnover %' => widget.data.map((r) => r.pct).toList(),
//         'Headcount' => widget.data.map((r) => r.endHC.toDouble()).toList(),
//         'Attrition' => widget.data.map((r) => r.left.toDouble()).toList(),
//         'Net Change' => widget.data.map((r) => r.netChange.toDouble()).toList(),
//         'Retention %' => widget.data.map((r) => r.retentionPct).toList(),
//         _ => [],
//       };

//   @override
//   Widget build(BuildContext ctx) {
//     if (widget.data.isEmpty) return const _Empty();
//     return ListView(padding: const EdgeInsets.all(16), children: [
//       _SecLabel('Chart Explorer'),
//       const SizedBox(height: 8),
//       SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//               children: _opts
//                   .map((o) => Padding(
//                         padding: const EdgeInsets.only(right: 7),
//                         child: _Chip(
//                             label: o,
//                             sel: _m == o,
//                             onTap: () => setState(() => _m = o)),
//                       ))
//                   .toList())),
//       const SizedBox(height: 16),
//       _BarChart(data: widget.data, vals: _vals(), metric: _m),
//       const SizedBox(height: 14),
//       _DualLine(data: widget.data),
//       const SizedBox(height: 14),
//       _TurnoverArea(data: widget.data),
//     ]);
//   }
// }

// // ════════════════════════════════════════════════════════════
// //  TABLE TAB
// // ════════════════════════════════════════════════════════════

// class _TableTab extends StatefulWidget {
//   final List<TurnoverRecord> data;
//   const _TableTab({required this.data});

//   @override
//   State<_TableTab> createState() => _TableTabState();
// }

// class _TableTabState extends State<_TableTab> {
//   int _col = 0;
//   bool _asc = true;
//   String _q = '';

//   List<TurnoverRecord> get _rows {
//     var list = widget.data
//         .where((r) => _q.isEmpty || r.year.toString().contains(_q))
//         .toList();
//     list.sort((a, b) {
//       int c = switch (_col) {
//         0 => a.year.compareTo(b.year),
//         1 => a.beginHC.compareTo(b.beginHC),
//         2 => a.endHC.compareTo(b.endHC),
//         3 => a.left.compareTo(b.left),
//         4 => a.pct.compareTo(b.pct),
//         5 => a.retentionPct.compareTo(b.retentionPct),
//         6 => a.netChange.compareTo(b.netChange),
//         _ => 0,
//       };
//       return _asc ? c : -c;
//     });
//     return list;
//   }

//   @override
//   Widget build(BuildContext ctx) {
//     final rows = _rows;
//     return Column(children: [
//       Container(
//           color: _cCard,
//           padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//           child: Row(children: [
//             Expanded(
//                 child: TextField(
//               decoration: const InputDecoration(
//                   hintText: 'Filter by year…',
//                   prefixIcon: Icon(Icons.search_rounded, size: 16),
//                   hintStyle: TextStyle(fontSize: 12, color: _c3)),
//               style: const TextStyle(fontSize: 13),
//               onChanged: (v) => setState(() => _q = v),
//             )),
//             const SizedBox(width: 10),
//             Text('${rows.length} rows',
//                 style: const TextStyle(fontSize: 11, color: _c3)),
//           ])),
//       Expanded(
//           child: SingleChildScrollView(
//               padding: const EdgeInsets.all(14),
//               child: Column(children: [
//                 _TblHdr(
//                     col: _col,
//                     asc: _asc,
//                     onSort: (c) => setState(() {
//                           _col == c ? _asc = !_asc : _asc = true;
//                           _col = c;
//                         })),
//                 ...rows
//                     .asMap()
//                     .entries
//                     .map((e) => _TblRow(rec: e.value, even: e.key.isEven)),
//                 const SizedBox(height: 20),
//               ]))),
//     ]);
//   }
// }

// // ════════════════════════════════════════════════════════════
// //  INSIGHTS TAB
// // ════════════════════════════════════════════════════════════

// class _InsightsTab extends StatelessWidget {
//   final List<TurnoverRecord> data;
//   final TurnoverRecord agg;
//   const _InsightsTab({required this.data, required this.agg});

//   @override
//   Widget build(BuildContext ctx) {
//     if (data.isEmpty) return const _Empty();
//     final sorted = [...data]..sort((a, b) => a.pct.compareTo(b.pct));
//     final best = sorted.first, worst = sorted.last;
//     final avg = data.fold(0.0, (s, r) => s + r.pct) / data.length;
//     final trend = data.length > 1 ? data.last.pct - data.first.pct : 0.0;
//     final hi = data.where((r) => r.pct >= 20).length;

//     return ListView(padding: const EdgeInsets.all(14), children: [
//       _SecLabel('Key Insights'),
//       const SizedBox(height: 10),
//       _InsCard(
//           icon: Icons.emoji_events_rounded,
//           color: _cTeal,
//           title: 'Best Year: ${best.year}',
//           body: 'Lowest turnover at ${best.pct.toStringAsFixed(2)}% — '
//               '${_commas(best.left)} departures from ${best.avgHC.round()} avg staff.'),
//       const SizedBox(height: 8),
//       _InsCard(
//           icon: Icons.warning_amber_rounded,
//           color: _cRose,
//           title: 'Highest Turnover: ${worst.year}',
//           body: 'Peak at ${worst.pct.toStringAsFixed(2)}% — '
//               '${_commas(worst.left)} left. Investigate attrition drivers.'),
//       const SizedBox(height: 8),
//       _InsCard(
//           icon: Icons.trending_up_rounded,
//           color: _cAmber,
//           title:
//               'Trend: ${trend >= 0 ? '▲ Rising' : '▼ Declining'} ${trend.abs().toStringAsFixed(2)}pp',
//           body: trend >= 0
//               ? 'Turnover is worsening. Consider escalating to leadership.'
//               : 'Positive trend — retention is improving. Reinforce initiatives.'),
//       const SizedBox(height: 8),
//       _InsCard(
//           icon: Icons.bar_chart_rounded,
//           color: _cBlue,
//           title: 'Period Avg: ${avg.toStringAsFixed(2)}%',
//           body:
//               '${_commas(agg.left)} cumulative departures over ${data.length} record(s). '
//               'Industry benchmark is typically 10–15%.'),
//       const SizedBox(height: 8),
//       _InsCard(
//           icon: Icons.gpp_bad_rounded,
//           color: _cPurp,
//           title: 'High-Risk Periods: $hi of ${data.length}',
//           body:
//               '${(hi / data.length * 100).toStringAsFixed(0)}% of periods had turnover ≥ 20%. '
//               '${hi == 0 ? 'Excellent stability.' : 'Root-cause analysis recommended.'}'),
//       const SizedBox(height: 16),
//       _SecLabel('Year-over-Year Δ Turnover'),
//       const SizedBox(height: 8),
//       if (data.length > 1)
//         ...List.generate(data.length - 1, (i) {
//           final d = data[i + 1].pct - data[i].pct;
//           return _YoY(year: data[i + 1].year, delta: d);
//         }),
//     ]);
//   }
// }

// // ════════════════════════════════════════════════════════════
// //  SUMMARY TAB
// // ════════════════════════════════════════════════════════════

// class _SummaryTab extends StatelessWidget {
//   final List<TurnoverRecord> data;
//   final TurnoverRecord agg;
//   const _SummaryTab({required this.data, required this.agg});

//   @override
//   Widget build(BuildContext ctx) {
//     if (data.isEmpty) return const _Empty();
//     final avg = data.fold(0.0, (s, r) => s + r.pct) / data.length;
//     final best = data.reduce((a, b) => a.pct < b.pct ? a : b);
//     final grade = avg < 10
//         ? 'A'
//         : avg < 15
//             ? 'B'
//             : avg < 20
//                 ? 'C'
//                 : avg < 25
//                     ? 'D'
//                     : 'F';
//     final gradeC = avg < 15
//         ? _cTeal
//         : avg < 20
//             ? _cAmber
//             : _cRose;

//     return ListView(padding: const EdgeInsets.all(16), children: [
//       _SecLabel('Executive Scorecard'),
//       const SizedBox(height: 12),
//       Container(
//         padding: const EdgeInsets.all(20),
//         decoration:
//             BoxDecoration(color: _c0, borderRadius: BorderRadius.circular(16)),
//         child: Column(children: [
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               const Text('Health Grade',
//                   style: TextStyle(fontSize: 12, color: _c3)),
//               const SizedBox(height: 4),
//               Text(grade,
//                   style: TextStyle(
//                       fontSize: 56,
//                       fontWeight: FontWeight.w900,
//                       color: gradeC,
//                       height: 1)),
//               const SizedBox(height: 4),
//               Text(avg < 15 ? 'Within target' : 'Needs attention',
//                   style: TextStyle(
//                       fontSize: 11, color: avg < 15 ? _cTeal : _cRose)),
//             ]),
//             _MiniDonut(pct: 100 - avg),
//           ]),
//           const SizedBox(height: 16),
//           Row(children: [
//             Expanded(
//                 child: _ScoreStat(
//                     'Avg Turnover', '${avg.toStringAsFixed(1)}%', _cAmber)),
//             const SizedBox(width: 8),
//             Expanded(
//                 child: _ScoreStat(
//                     'Total Left', _fmtK(agg.left.toDouble()), _cRose)),
//             const SizedBox(width: 8),
//             Expanded(child: _ScoreStat('Best Year', '${best.year}', _cTeal)),
//           ]),
//         ]),
//       ),
//       const SizedBox(height: 16),
//       _SecLabel('Benchmarks'),
//       const SizedBox(height: 10),
//       ...[
//         ('< 10%', 'Low turnover — excellent retention', _cTeal),
//         ('10–15%', 'Industry average — acceptable', _cAmber),
//         (
//           '15–20%',
//           'Moderate concern — review policies',
//           const Color(0xFFEA580C)
//         ),
//         ('> 20%', 'High turnover — urgent action required', _cRose),
//       ].map((b) => Padding(
//           padding: const EdgeInsets.only(bottom: 7),
//           child: _Bench(range: b.$1, label: b.$2, color: b.$3))),
//       const SizedBox(height: 16),
//       _SecLabel('Top 5 Worst Years'),
//       const SizedBox(height: 8),
//       ...([...data]..sort((a, b) => b.pct.compareTo(a.pct)))
//           .take(5)
//           .toList()
//           .asMap()
//           .entries
//           .map((e) => _RankRow(rank: e.key + 1, rec: e.value)),
//     ]);
//   }
// }

// // ════════════════════════════════════════════════════════════
// //  CHART PAINTERS
// // ════════════════════════════════════════════════════════════

// class _BarChart extends StatelessWidget {
//   final List<TurnoverRecord> data;
//   final List<double> vals;
//   final String metric;
//   const _BarChart(
//       {required this.data, required this.vals, required this.metric});

//   String _lbl(double v) {
//     if (metric == 'Turnover %' || metric == 'Retention %') {
//       return '${v.toStringAsFixed(1)}%';
//     }
//     return _fmtK(v);
//   }

//   @override
//   Widget build(BuildContext ctx) {
//     if (vals.isEmpty) return const SizedBox();
//     final hasNeg = vals.any((v) => v < 0);
//     final maxV = vals.map((v) => v.abs()).reduce(max);
//     final bW = MediaQuery.of(ctx).size.width >= 600 ? 28.0 : 20.0;
//     return _CCard(
//         title: metric,
//         child: SizedBox(
//             height: 210,
//             child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: SizedBox(
//                     width: max(data.length * (bW + 12) + 20, 280),
//                     child: CustomPaint(
//                         painter: _BPainter(
//                             vals: vals,
//                             labels: data.map((r) => '${r.year}').toList(),
//                             maxV: maxV,
//                             hasNeg: hasNeg,
//                             bW: bW,
//                             fmt: _lbl))))));
//   }
// }

// class _BPainter extends CustomPainter {
//   final List<double> vals;
//   final List<String> labels;
//   final double maxV, bW;
//   final bool hasNeg;
//   final String Function(double) fmt;

//   _BPainter({
//     required this.vals,
//     required this.labels,
//     required this.maxV,
//     required this.hasNeg,
//     required this.bW,
//     required this.fmt,
//   });

//   @override
//   void paint(Canvas c, Size s) {
//     const bP = 28.0, tP = 14.0;
//     final h = s.height - bP - tP;
//     final base = hasNeg ? tP + h / 2 : tP + h;
//     final step = s.width / vals.length;
//     final tp = TextPainter(textDirection: TextDirection.ltr);

//     c.drawLine(
//         Offset(0, base),
//         Offset(s.width, base),
//         Paint()
//           ..color = _cBdr
//           ..strokeWidth = 0.8);

//     for (int i = 0; i < vals.length; i++) {
//       final v = vals[i];
//       final x = step * i + step / 2;
//       final frac = maxV > 0 ? v.abs() / maxV : 0;
//       final bH =
//           (frac * (hasNeg ? h / 2 : h) * 0.88).clamp(2.0, double.infinity);
//       final isPos = v >= 0;
//       final col = v < 0
//           ? _cRose
//           : frac > 0.75
//               ? _cRose
//               : frac > 0.45
//                   ? _cAmber
//                   : _cBlue;

//       final top = isPos ? base - bH : base;
//       c.drawRRect(
//           RRect.fromRectAndRadius(
//               Rect.fromLTWH(x - bW / 2, top, bW, bH), const Radius.circular(4)),
//           Paint()..color = col);

//       if (bH > 20) {
//         tp.text = TextSpan(
//             text: fmt(v),
//             style: const TextStyle(
//                 fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700));
//         tp.layout();
//         tp.paint(
//             c,
//             Offset(
//                 x - tp.width / 2, isPos ? top + 3 : top + bH - tp.height - 3));
//       }

//       tp.text = TextSpan(
//           text: "'${labels[i].substring(2)}",
//           style: const TextStyle(fontSize: 8.5, color: _c3));
//       tp.layout();
//       tp.paint(c, Offset(x - tp.width / 2, s.height - bP + 5));
//     }
//   }

//   @override
//   bool shouldRepaint(_) => true;
// }

// class _DualLine extends StatelessWidget {
//   final List<TurnoverRecord> data;
//   const _DualLine({required this.data});

//   @override
//   Widget build(BuildContext ctx) {
//     if (data.length < 2) return const SizedBox();
//     return _CCard(
//         title: 'Avg Headcount vs Departures',
//         legend: Row(children: [
//           _LDot(color: _cBlue, label: 'Avg HC'),
//           const SizedBox(width: 12),
//           _LDot(color: _cRose, label: 'Left'),
//         ]),
//         child: SizedBox(
//             height: 190,
//             child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: SizedBox(
//                     width: max(data.length * 34.0, 260),
//                     child: CustomPaint(painter: _DLPainter(data: data))))));
//   }
// }

// class _DLPainter extends CustomPainter {
//   final List<TurnoverRecord> data;
//   _DLPainter({required this.data});

//   @override
//   void paint(Canvas c, Size s) {
//     const bP = 22.0, tP = 8.0;
//     final h = s.height - bP - tP;
//     final step = s.width / (data.length - 1);
//     final hcV = data.map((r) => r.avgHC).toList();
//     final lV = data.map((r) => r.left.toDouble()).toList();
//     final mx = [...hcV, ...lV].reduce(max);

//     for (var f in [0.25, 0.5, 0.75]) {
//       final y = tP + h * (1 - f);
//       c.drawLine(
//           Offset(0, y),
//           Offset(s.width, y),
//           Paint()
//             ..color = _cBdr
//             ..strokeWidth = 0.5);
//     }

//     void drawLine(List<double> vals, Color col) {
//       final paint = Paint()
//         ..color = col
//         ..strokeWidth = 2.2
//         ..style = PaintingStyle.stroke
//         ..strokeCap = StrokeCap.round
//         ..strokeJoin = StrokeJoin.round;
//       final fill = Paint()
//         ..color = col.withOpacity(0.07)
//         ..style = PaintingStyle.fill;
//       final lp = Path(), fp = Path();
//       for (int i = 0; i < vals.length; i++) {
//         final x = i * step, y = tP + h - (vals[i] / mx * h * 0.9);
//         if (i == 0) {
//           lp.moveTo(x, y);
//           fp.moveTo(x, s.height - bP);
//           fp.lineTo(x, y);
//         } else {
//           lp.lineTo(x, y);
//           fp.lineTo(x, y);
//         }
//       }
//       fp.lineTo(s.width, s.height - bP);
//       fp.close();
//       c.drawPath(fp, fill);
//       c.drawPath(lp, paint);
//       for (int i = 0; i < vals.length; i++) {
//         final x = i * step, y = tP + h - (vals[i] / mx * h * 0.9);
//         c.drawCircle(
//             Offset(x, y),
//             3.5,
//             Paint()
//               ..color = _cCard
//               ..style = PaintingStyle.fill);
//         c.drawCircle(
//             Offset(x, y),
//             3.5,
//             Paint()
//               ..color = col
//               ..style = PaintingStyle.stroke
//               ..strokeWidth = 1.8);
//       }
//     }

//     drawLine(hcV, _cBlue);
//     drawLine(lV, _cRose);

//     final tp = TextPainter(textDirection: TextDirection.ltr);
//     for (int i = 0; i < data.length; i += max(1, data.length ~/ 7)) {
//       tp.text = TextSpan(
//           text: "'${data[i].year.toString().substring(2)}",
//           style: const TextStyle(fontSize: 8, color: _c3));
//       tp.layout();
//       tp.paint(c, Offset(i * step - tp.width / 2, s.height - bP + 4));
//     }
//   }

//   @override
//   bool shouldRepaint(_) => true;
// }

// class _TurnoverArea extends StatelessWidget {
//   final List<TurnoverRecord> data;
//   const _TurnoverArea({required this.data});

//   @override
//   Widget build(BuildContext ctx) {
//     if (data.length < 2) return const SizedBox();
//     return _CCard(
//         title: 'Turnover % — Color-zoned',
//         legend: Row(children: [
//           _LDot(color: _cTeal, label: '< 10%'),
//           const SizedBox(width: 10),
//           _LDot(color: _cAmber, label: '10–20%'),
//           const SizedBox(width: 10),
//           _LDot(color: _cRose, label: '> 20%'),
//         ]),
//         child: SizedBox(
//             height: 170,
//             child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: SizedBox(
//                     width: max(data.length * 34.0, 260),
//                     child: CustomPaint(painter: _TAPainter(data: data))))));
//   }
// }

// class _TAPainter extends CustomPainter {
//   final List<TurnoverRecord> data;
//   _TAPainter({required this.data});

//   @override
//   void paint(Canvas c, Size s) {
//     const bP = 22.0, tP = 8.0, mxP = 40.0;
//     final h = s.height - bP - tP;
//     final step = s.width / (data.length - 1);

//     for (var th in [10.0, 20.0]) {
//       final y = tP + h * (1 - th / mxP);
//       c.drawLine(
//           Offset(0, y),
//           Offset(s.width, y),
//           Paint()
//             ..color = _cBdr
//             ..strokeWidth = 0.8);
//     }

//     for (int i = 0; i < data.length - 1; i++) {
//       final x0 = i * step, x1 = (i + 1) * step;
//       final y0 = tP + h * (1 - (data[i].pct / mxP).clamp(0, 1));
//       final y1 = tP + h * (1 - (data[i + 1].pct / mxP).clamp(0, 1));
//       final avg = (data[i].pct + data[i + 1].pct) / 2;
//       final col = avg < 10
//           ? _cTeal
//           : avg < 20
//               ? _cAmber
//               : _cRose;
//       c.drawPath(
//           Path()
//             ..moveTo(x0, s.height - bP)
//             ..lineTo(x0, y0)
//             ..lineTo(x1, y1)
//             ..lineTo(x1, s.height - bP)
//             ..close(),
//           Paint()
//             ..color = col.withOpacity(0.16)
//             ..style = PaintingStyle.fill);
//     }
//     final lp = Path();
//     for (int i = 0; i < data.length; i++) {
//       final x = i * step, y = tP + h * (1 - (data[i].pct / mxP).clamp(0, 1));
//       i == 0 ? lp.moveTo(x, y) : lp.lineTo(x, y);
//     }
//     c.drawPath(
//         lp,
//         Paint()
//           ..color = _cSlate
//           ..strokeWidth = 1.8
//           ..style = PaintingStyle.stroke
//           ..strokeCap = StrokeCap.round);
//     for (int i = 0; i < data.length; i++) {
//       final x = i * step, y = tP + h * (1 - (data[i].pct / mxP).clamp(0, 1));
//       final col = data[i].pct < 10
//           ? _cTeal
//           : data[i].pct < 20
//               ? _cAmber
//               : _cRose;
//       c.drawCircle(Offset(x, y), 4, Paint()..color = _cCard);
//       c.drawCircle(
//           Offset(x, y),
//           4,
//           Paint()
//             ..color = col
//             ..style = PaintingStyle.stroke
//             ..strokeWidth = 2);
//     }
//     final tp = TextPainter(textDirection: TextDirection.ltr);
//     for (int i = 0; i < data.length; i += max(1, data.length ~/ 7)) {
//       tp.text = TextSpan(
//           text: "'${data[i].year.toString().substring(2)}",
//           style: const TextStyle(fontSize: 8, color: _c3));
//       tp.layout();
//       tp.paint(c, Offset(i * step - tp.width / 2, s.height - bP + 4));
//     }
//   }

//   @override
//   bool shouldRepaint(_) => true;
// }

// // ════════════════════════════════════════════════════════════
// //  TABLE WIDGETS
// // ════════════════════════════════════════════════════════════

// class _TblHdr extends StatelessWidget {
//   final int col;
//   final bool asc;
//   final void Function(int) onSort;
//   const _TblHdr({required this.col, required this.asc, required this.onSort});
//   static const _cols = [
//     'Year',
//     'Begin',
//     'End',
//     'Left',
//     'Rate',
//     'Retention',
//     'Net Δ'
//   ];

//   @override
//   Widget build(BuildContext ctx) => Container(
//       decoration: BoxDecoration(
//           color: _c0,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
//       child: Row(
//           children: List.generate(_cols.length, (i) {
//         final sel = col == i;
//         return Expanded(
//             child: GestureDetector(
//                 onTap: () => onSort(i),
//                 child: Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
//                     child: Row(
//                         mainAxisAlignment: i == 0
//                             ? MainAxisAlignment.start
//                             : MainAxisAlignment.end,
//                         children: [
//                           Text(_cols[i],
//                               style: TextStyle(
//                                   fontSize: 9.5,
//                                   fontWeight: FontWeight.w700,
//                                   color: sel ? Colors.white : _c3)),
//                           if (sel)
//                             Icon(
//                                 asc
//                                     ? Icons.arrow_upward_rounded
//                                     : Icons.arrow_downward_rounded,
//                                 size: 9,
//                                 color: Colors.white),
//                         ]))));
//       })));
// }

// class _TblRow extends StatelessWidget {
//   final TurnoverRecord rec;
//   final bool even;
//   const _TblRow({required this.rec, required this.even});

//   @override
//   Widget build(BuildContext ctx) {
//     final rc = _riskColor(rec.pct);
//     return Container(
//         color: even ? _cBg : _cCard,
//         child: Row(children: [
//           Expanded(child: _TC('${rec.year}', left: true, bold: true)),
//           Expanded(child: _TC(_fmtK(rec.beginHC.toDouble()))),
//           Expanded(child: _TC(_fmtK(rec.endHC.toDouble()))),
//           Expanded(child: _TC(_fmtK(rec.left.toDouble()))),
//           Expanded(
//               child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
//                   child: Align(
//                       alignment: Alignment.centerRight,
//                       child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 5, vertical: 2),
//                           decoration: BoxDecoration(
//                               color: rc.withOpacity(0.12),
//                               borderRadius: BorderRadius.circular(4)),
//                           child: Text('${rec.pct.toStringAsFixed(1)}%',
//                               style: TextStyle(
//                                   fontSize: 9,
//                                   fontWeight: FontWeight.w700,
//                                   color: rc)))))),
//           Expanded(
//               child: _TC('${rec.retentionPct.toStringAsFixed(1)}%',
//                   color: _cTeal)),
//           Expanded(
//               child: _TC('${rec.netChange >= 0 ? '+' : ''}${rec.netChange}',
//                   color: rec.netChange >= 0 ? _cTeal : _cRose)),
//         ]));
//   }
// }

// class _TC extends StatelessWidget {
//   final String text;
//   final bool left, bold;
//   final Color? color;
//   const _TC(this.text, {this.left = false, this.bold = false, this.color});

//   @override
//   Widget build(BuildContext ctx) => Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
//       child: Text(text,
//           textAlign: left ? TextAlign.left : TextAlign.right,
//           style: TextStyle(
//               fontSize: 10.5,
//               color: color ?? _c0,
//               fontWeight: bold ? FontWeight.w700 : FontWeight.w400)));
// }

// // ════════════════════════════════════════════════════════════
// //  KPI + VISUAL COMPONENTS
// // ════════════════════════════════════════════════════════════

// class _Kpi extends StatelessWidget {
//   final String label, value, sub;
//   final IconData icon;
//   final Color color;
//   const _Kpi(this.label, this.value, this.sub, this.icon, this.color);

//   @override
//   Widget build(BuildContext ctx) => Container(
//       padding: const EdgeInsets.all(13),
//       decoration: BoxDecoration(
//           color: _cCard,
//           border: Border.all(color: _cBdr),
//           borderRadius: BorderRadius.circular(14)),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                   color: _tint(color), borderRadius: BorderRadius.circular(9)),
//               child: Icon(icon, color: color, size: 16)),
//           const Spacer(),
//           Container(
//               width: 6,
//               height: 6,
//               decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
//         ]),
//         const SizedBox(height: 10),
//         Text(value,
//             style: const TextStyle(
//                 fontSize: 20, fontWeight: FontWeight.w800, color: _c0)),
//         const SizedBox(height: 1),
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 10.5, color: _c1, fontWeight: FontWeight.w600)),
//         Text(sub, style: const TextStyle(fontSize: 9.5, color: _c3)),
//       ]));
// }

// class _Gauge extends StatelessWidget {
//   final double pct;
//   const _Gauge({required this.pct});

//   @override
//   Widget build(BuildContext ctx) {
//     final color = _riskColor(pct);
//     final frac = (pct / 50).clamp(0.0, 1.0);
//     return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//             color: _cCard,
//             border: Border.all(color: _cBdr),
//             borderRadius: BorderRadius.circular(14)),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [
//             const Text('Turnover Rate',
//                 style: TextStyle(
//                     fontSize: 13, fontWeight: FontWeight.w700, color: _c0)),
//             const Spacer(),
//             _Badge(label: _riskLabel(pct), color: color),
//           ]),
//           const SizedBox(height: 12),
//           Row(
//               crossAxisAlignment: CrossAxisAlignment.baseline,
//               textBaseline: TextBaseline.alphabetic,
//               children: [
//                 Text('${pct.toStringAsFixed(2)}%',
//                     style: TextStyle(
//                         fontSize: 34,
//                         fontWeight: FontWeight.w900,
//                         color: color)),
//                 const SizedBox(width: 8),
//                 const Text('annual',
//                     style: TextStyle(fontSize: 13, color: _c3)),
//               ]),
//           const SizedBox(height: 14),
//           Stack(children: [
//             Container(
//                 height: 10,
//                 decoration: BoxDecoration(
//                     color: _cBg, borderRadius: BorderRadius.circular(8))),
//             FractionallySizedBox(
//                 widthFactor: frac,
//                 child: Container(
//                     height: 10,
//                     decoration: BoxDecoration(
//                         color: color, borderRadius: BorderRadius.circular(8)))),
//           ]),
//           const SizedBox(height: 6),
//           Row(children: [
//             const Text('0%', style: TextStyle(fontSize: 9, color: _c3)),
//             const Spacer(),
//             Text('Target < 10%',
//                 style: TextStyle(
//                     fontSize: 9, color: _cTeal, fontWeight: FontWeight.w600)),
//             const Spacer(),
//             const Text('50%+', style: TextStyle(fontSize: 9, color: _c3)),
//           ]),
//         ]));
//   }
// }

// class _Donut extends StatelessWidget {
//   final double retPct;
//   const _Donut({required this.retPct});

//   @override
//   Widget build(BuildContext ctx) => _CCard(
//       title: 'Retention vs Attrition',
//       child: SizedBox(
//           height: 160,
//           child: Row(children: [
//             SizedBox(
//                 width: 160,
//                 child: CustomPaint(
//                     size: const Size(160, 160),
//                     painter: _DonutP(retained: retPct))),
//             const SizedBox(width: 12),
//             Expanded(
//                 child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                   _LDot(color: _cTeal, label: 'Retained'),
//                   const SizedBox(height: 4),
//                   Text('${retPct.toStringAsFixed(1)}%',
//                       style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.w800,
//                           color: _cTeal)),
//                   const SizedBox(height: 12),
//                   _LDot(color: _cRose, label: 'Attrition'),
//                   const SizedBox(height: 4),
//                   Text('${(100 - retPct).toStringAsFixed(1)}%',
//                       style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.w800,
//                           color: _cRose)),
//                 ])),
//           ])));
// }

// class _DonutP extends CustomPainter {
//   final double retained;
//   _DonutP({required this.retained});

//   @override
//   void paint(Canvas c, Size s) {
//     final cx = s.width / 2, cy = s.height / 2, r = min(cx, cy) - 16;
//     const sw = 22.0;
//     final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
//     final frac = 2 * pi * (retained / 100);
//     c.drawArc(
//         rect,
//         -pi / 2,
//         2 * pi,
//         false,
//         Paint()
//           ..color = _cBdr
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = sw);
//     c.drawArc(
//         rect,
//         -pi / 2,
//         frac,
//         false,
//         Paint()
//           ..color = _cTeal
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = sw
//           ..strokeCap = StrokeCap.round);
//     c.drawArc(
//         rect,
//         -pi / 2 + frac,
//         2 * pi - frac,
//         false,
//         Paint()
//           ..color = _cRose
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = sw
//           ..strokeCap = StrokeCap.round);
//     final tp = TextPainter(textDirection: TextDirection.ltr)
//       ..text = TextSpan(
//           text: '${retained.toStringAsFixed(0)}%',
//           style: const TextStyle(
//               fontSize: 18, fontWeight: FontWeight.w800, color: _c0))
//       ..layout();
//     tp.paint(c, Offset(cx - tp.width / 2, cy - tp.height / 2));
//   }

//   @override
//   bool shouldRepaint(_) => true;
// }

// class _Spark extends StatelessWidget {
//   final List<TurnoverRecord> data;
//   const _Spark({required this.data});

//   @override
//   Widget build(BuildContext ctx) {
//     final mx = data.map((r) => r.pct).reduce(max);
//     return _CCard(
//         title: 'Turnover Trend Sparkline',
//         child: SizedBox(
//             height: 72,
//             child: CustomPaint(
//                 size: const Size(double.infinity, 72),
//                 painter: _SparkP(
//                     vals: data.map((r) => r.pct / max(mx, 1)).toList()))));
//   }
// }

// class _SparkP extends CustomPainter {
//   final List<double> vals;
//   _SparkP({required this.vals});

//   @override
//   void paint(Canvas c, Size s) {
//     if (vals.length < 2) return;
//     final step = s.width / (vals.length - 1);
//     final lp = Path(), fp = Path();
//     for (int i = 0; i < vals.length; i++) {
//       final x = i * step, y = s.height - vals[i] * s.height * 0.88;
//       if (i == 0) {
//         lp.moveTo(x, y);
//         fp.moveTo(x, s.height);
//         fp.lineTo(x, y);
//       } else {
//         lp.lineTo(x, y);
//         fp.lineTo(x, y);
//       }
//     }
//     fp.lineTo(s.width, s.height);
//     fp.close();
//     c.drawPath(
//         fp,
//         Paint()
//           ..color = _cBlue.withOpacity(0.07)
//           ..style = PaintingStyle.fill);
//     c.drawPath(
//         lp,
//         Paint()
//           ..color = _cBlue
//           ..strokeWidth = 2
//           ..style = PaintingStyle.stroke
//           ..strokeCap = StrokeCap.round
//           ..strokeJoin = StrokeJoin.round);
//   }

//   @override
//   bool shouldRepaint(_) => false;
// }

// // ════════════════════════════════════════════════════════════
// //  SUMMARY COMPONENTS
// // ════════════════════════════════════════════════════════════

// class _MiniDonut extends StatelessWidget {
//   final double pct;
//   const _MiniDonut({required this.pct});

//   @override
//   Widget build(BuildContext ctx) => SizedBox(
//       width: 90, height: 90, child: CustomPaint(painter: _MDP(pct: pct)));
// }

// class _MDP extends CustomPainter {
//   final double pct;
//   _MDP({required this.pct});

//   @override
//   void paint(Canvas c, Size s) {
//     final cx = s.width / 2, cy = s.height / 2, r = cx - 8;
//     const sw = 10.0;
//     final frac = (pct / 100).clamp(0.0, 1.0);
//     c.drawCircle(
//         Offset(cx, cy),
//         r,
//         Paint()
//           ..color = Colors.white.withOpacity(0.1)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = sw);
//     c.drawArc(
//         Rect.fromCircle(center: Offset(cx, cy), radius: r),
//         -pi / 2,
//         2 * pi * frac,
//         false,
//         Paint()
//           ..color = _cTeal
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = sw
//           ..strokeCap = StrokeCap.round);
//     final tp = TextPainter(textDirection: TextDirection.ltr)
//       ..text = TextSpan(
//           text: '${pct.toStringAsFixed(0)}%',
//           style: const TextStyle(
//               fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))
//       ..layout();
//     tp.paint(c, Offset(cx - tp.width / 2, cy - tp.height / 2));
//   }

//   @override
//   bool shouldRepaint(_) => true;
// }

// class _ScoreStat extends StatelessWidget {
//   final String label, value;
//   final Color color;
//   const _ScoreStat(this.label, this.value, this.color);

//   @override
//   Widget build(BuildContext ctx) => Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.07),
//           borderRadius: BorderRadius.circular(10)),
//       child: Column(children: [
//         Text(value,
//             style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.w800, color: color)),
//         const SizedBox(height: 2),
//         Text(label,
//             style: const TextStyle(fontSize: 9, color: _c3),
//             textAlign: TextAlign.center),
//       ]));
// }

// class _Bench extends StatelessWidget {
//   final String range, label;
//   final Color color;
//   const _Bench({required this.range, required this.label, required this.color});

//   @override
//   Widget build(BuildContext ctx) => Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
//       decoration: BoxDecoration(
//           color: _cCard,
//           border: Border.all(color: _cBdr),
//           borderRadius: BorderRadius.circular(10)),
//       child: Row(children: [
//         Container(
//             width: 5,
//             height: 28,
//             decoration: BoxDecoration(
//                 color: color, borderRadius: BorderRadius.circular(3))),
//         const SizedBox(width: 12),
//         Text(range,
//             style: TextStyle(
//                 fontSize: 13, fontWeight: FontWeight.w700, color: color)),
//         const SizedBox(width: 10),
//         Expanded(
//             child:
//                 Text(label, style: const TextStyle(fontSize: 12, color: _c2))),
//       ]));
// }

// class _RankRow extends StatelessWidget {
//   final int rank;
//   final TurnoverRecord rec;
//   const _RankRow({required this.rank, required this.rec});

//   @override
//   Widget build(BuildContext ctx) {
//     final color = _riskColor(rec.pct);
//     return Container(
//         margin: const EdgeInsets.only(bottom: 7),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//         decoration: BoxDecoration(
//             color: _cCard,
//             border: Border.all(color: _cBdr),
//             borderRadius: BorderRadius.circular(10)),
//         child: Row(children: [
//           Container(
//               width: 28,
//               height: 28,
//               decoration: BoxDecoration(
//                   color: _tint(color), borderRadius: BorderRadius.circular(8)),
//               child: Center(
//                   child: Text('#$rank',
//                       style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w800,
//                           color: color)))),
//           const SizedBox(width: 10),
//           Text('${rec.year}',
//               style: const TextStyle(
//                   fontSize: 14, fontWeight: FontWeight.w700, color: _c0)),
//           const SizedBox(width: 8),
//           Text('${_commas(rec.left)} left',
//               style: const TextStyle(fontSize: 12, color: _c2)),
//           const Spacer(),
//           _Badge(label: '${rec.pct.toStringAsFixed(1)}%', color: color),
//         ]));
//   }
// }

// // ════════════════════════════════════════════════════════════
// //  SMALL REUSABLE WIDGETS
// // ════════════════════════════════════════════════════════════

// class _CCard extends StatelessWidget {
//   final String title;
//   final Widget child;
//   final Widget? legend;
//   const _CCard({required this.title, required this.child, this.legend});

//   @override
//   Widget build(BuildContext ctx) => Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: _cCard,
//           border: Border.all(color: _cBdr),
//           borderRadius: BorderRadius.circular(14)),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(title,
//             style: const TextStyle(
//                 fontSize: 13, fontWeight: FontWeight.w700, color: _c0)),
//         if (legend != null) ...[const SizedBox(height: 6), legend!],
//         const SizedBox(height: 12),
//         child,
//       ]));
// }

// class _InsCard extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String title, body;
//   const _InsCard(
//       {required this.icon,
//       required this.color,
//       required this.title,
//       required this.body});

//   @override
//   Widget build(BuildContext ctx) => Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//           color: _cCard,
//           border: Border.all(color: _cBdr),
//           borderRadius: BorderRadius.circular(12)),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//                 color: _tint(color), borderRadius: BorderRadius.circular(10)),
//             child: Icon(icon, color: color, size: 18)),
//         const SizedBox(width: 12),
//         Expanded(
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(title,
//               style: const TextStyle(
//                   fontSize: 13, fontWeight: FontWeight.w600, color: _c0)),
//           const SizedBox(height: 4),
//           Text(body,
//               style: const TextStyle(fontSize: 12, color: _c2, height: 1.45)),
//         ])),
//       ]));
// }

// class _YoY extends StatelessWidget {
//   final int year;
//   final double delta;
//   const _YoY({required this.year, required this.delta});

//   @override
//   Widget build(BuildContext ctx) {
//     final imp = delta < 0;
//     final color = imp ? _cTeal : _cRose;
//     return Container(
//         margin: const EdgeInsets.only(bottom: 6),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//         decoration: BoxDecoration(
//             color: _cCard,
//             border: Border.all(color: _cBdr),
//             borderRadius: BorderRadius.circular(9)),
//         child: Row(children: [
//           Text('$year',
//               style: const TextStyle(
//                   fontSize: 13, fontWeight: FontWeight.w700, color: _c0)),
//           const Spacer(),
//           Icon(imp ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
//               color: color, size: 14),
//           const SizedBox(width: 4),
//           Text('${delta > 0 ? '+' : ''}${delta.toStringAsFixed(2)}pp',
//               style: TextStyle(
//                   fontSize: 13, fontWeight: FontWeight.w700, color: color)),
//         ]));
//   }
// }

// class _Badge extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _Badge({required this.label, required this.color});

//   @override
//   Widget build(BuildContext ctx) => Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//           color: _tint(color), borderRadius: BorderRadius.circular(20)),
//       child: Text(label,
//           style: TextStyle(
//               fontSize: 11, fontWeight: FontWeight.w700, color: color)));
// }

// class _Chip extends StatelessWidget {
//   final String label;
//   final bool sel;
//   final VoidCallback onTap;
//   const _Chip({required this.label, required this.sel, required this.onTap});

//   @override
//   Widget build(BuildContext ctx) => GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
//           decoration: BoxDecoration(
//               color: sel ? _cBlue : _cCard,
//               border: Border.all(color: sel ? _cBlue : _cBdr),
//               borderRadius: BorderRadius.circular(20)),
//           child: Text(label,
//               style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: sel ? Colors.white : _c2))));
// }

// class _LDot extends StatelessWidget {
//   final Color color;
//   final String label;
//   const _LDot({required this.color, required this.label});

//   @override
//   Widget build(BuildContext ctx) =>
//       Row(mainAxisSize: MainAxisSize.min, children: [
//         Container(
//             width: 9,
//             height: 9,
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
//         const SizedBox(width: 5),
//         Text(label, style: const TextStyle(fontSize: 11, color: _c2)),
//       ]);
// }

// class _SecLabel extends StatelessWidget {
//   final String text;
//   const _SecLabel(this.text);

//   @override
//   Widget build(BuildContext ctx) => Text(text,
//       style: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w700,
//           color: _c2,
//           letterSpacing: 0.4));
// }

// class _AppIcon extends StatelessWidget {
//   @override
//   Widget build(BuildContext ctx) => Container(
//       width: 32,
//       height: 32,
//       decoration:
//           BoxDecoration(color: _cBlue, borderRadius: BorderRadius.circular(9)),
//       child:
//           const Icon(Icons.people_alt_rounded, color: Colors.white, size: 17));
// }

// class _LiveBadge extends StatelessWidget {
//   final bool dark;
//   const _LiveBadge({this.dark = false});

//   @override
//   Widget build(BuildContext ctx) => Container(
//       margin: EdgeInsets.only(right: dark ? 0 : 10),
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//           color:
//               dark ? Colors.white.withOpacity(0.08) : _cBlue.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(20)),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         const Icon(Icons.circle, color: _cTeal, size: 7),
//         const SizedBox(width: 5),
//         Text('Live',
//             style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: dark ? _c3 : _cBlue)),
//       ]));
// }

// class _Grid extends StatelessWidget {
//   final int cols;
//   final double gap;
//   final List<Widget> children;
//   const _Grid({required this.cols, required this.gap, required this.children});

//   @override
//   Widget build(BuildContext ctx) {
//     final rows = <Widget>[];
//     for (int i = 0; i < children.length; i += cols) {
//       final rc = children.sublist(i, min(i + cols, children.length));
//       while (rc.length < cols) {
//         rc.add(const SizedBox());
//       }
//       rows.add(Row(
//           children: rc
//               .asMap()
//               .entries
//               .map((e) => Expanded(
//                   child: Padding(
//                       padding: EdgeInsets.only(
//                           right: e.key < rc.length - 1 ? gap : 0),
//                       child: e.value)))
//               .toList()));
//       if (i + cols < children.length) rows.add(SizedBox(height: gap));
//     }
//     return Column(children: rows);
//   }
// }

// class _Empty extends StatelessWidget {
//   const _Empty();

//   @override
//   Widget build(BuildContext ctx) => const Center(
//           child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//         Icon(Icons.search_off_rounded, size: 48, color: _c3),
//         SizedBox(height: 10),
//         Text('No data for selected range',
//             style: TextStyle(color: _c2, fontSize: 14)),
//       ]));
// }


import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ════════════════════════════════════════════════════════════
//  DATA MODELS
// ════════════════════════════════════════════════════════════

class TurnoverRecord {
  final int year;
  final String monthYear; // e.g. "2025-01" for monthwise, "" for yearwise
  final int beginHC, endHC, left;
  final double avgHC, rate, pct;

  const TurnoverRecord({
    required this.year,
    required this.monthYear,
    required this.beginHC,
    required this.endHC,
    required this.avgHC,
    required this.left,
    required this.rate,
    required this.pct,
  });

  int get netChange => endHC - beginHC;
  double get retentionPct => 100 - pct;

  /// Short label for chart x-axis: "Jan" for monthwise, "'25" for yearwise
  String get chartLabel {
    if (monthYear.isNotEmpty && monthYear.length >= 7) {
      final m = int.tryParse(monthYear.substring(5, 7)) ?? 0;
      return _monthName(m);
    }
    return "'${year.toString().substring(2)}";
  }

  /// Full label for table first column
  String get tableLabel {
    if (monthYear.isNotEmpty && monthYear.length >= 7) {
      final m = int.tryParse(monthYear.substring(5, 7)) ?? 0;
      return '${_monthName(m)} $year';
    }
    return year.toString();
  }

  factory TurnoverRecord.fromJson(Map<String, dynamic> e,
      {bool isMonth = false}) =>
      TurnoverRecord(
        year: e['year'] ?? 0,
        monthYear: (e['monthYear'] ?? '') as String,
        beginHC: e['beginHeadCount'] ?? 0,
        endHC: e['endHeadCount'] ?? 0,
        avgHC: (e['averageHeadCount'] ?? 0).toDouble(),
        left: e['employeesLeft'] ?? 0,
        rate: (e['turnoverRate'] ?? 0).toDouble(),
        pct: (e['turnoverPercentage'] ?? 0).toDouble(),
      );
}

// ════════════════════════════════════════════════════════════
//  FILTER STATE
// ════════════════════════════════════════════════════════════

enum SubView { yearwise, monthwise }

class FilterState {
  final SubView subView;
  final int fromYear;
  final int toYear;
  final int monthYear;
  final int fromMonth;
  final int toMonth;

  const FilterState({
    this.subView = SubView.yearwise,
    this.fromYear = 2006,
    this.toYear = 2026,
    this.monthYear = 2025,
    this.fromMonth = 1,
    this.toMonth = 12,
  });

  FilterState copyWith({
    SubView? subView,
    int? fromYear,
    int? toYear,
    int? monthYear,
    int? fromMonth,
    int? toMonth,
  }) {
    final newMonthYear = monthYear ?? this.monthYear;
    final maxAllowed =
        newMonthYear == _currentYear ? _currentMonth : 12;
    // clamp toMonth if switching to current year
    final newToMonth = (toMonth ?? this.toMonth).clamp(1, maxAllowed);
    // clamp fromMonth so it never exceeds toMonth
    final newFromMonth = (fromMonth ?? this.fromMonth).clamp(1, newToMonth);
    return FilterState(
      subView: subView ?? this.subView,
      fromYear: fromYear ?? this.fromYear,
      toYear: toYear ?? this.toYear,
      monthYear: newMonthYear,
      fromMonth: newFromMonth,
      toMonth: newToMonth,
    );
  }

  Map<String, dynamic> get yearwiseBody => {
        'type': 'year',
        'fromYear': fromYear,
        'toYear': toYear,
        'year': 0,
        'fromMonth': 0,
        'toMonth': 0,
      };

  Map<String, dynamic> get monthwiseBody => {
        'type': 'month',
        'fromYear': monthYear,
        'toYear': monthYear,
        'year': monthYear,
        'fromMonth': fromMonth,
        'toMonth': toMonth,
      };
}

// ════════════════════════════════════════════════════════════
//  API SERVICE
// ════════════════════════════════════════════════════════════

class TurnoverApiService {
  static const String _baseUrl =
      'http://10.3.0.70:9042/api/HR/GetTurnOverReport';

  static Future<List<TurnoverRecord>> fetch(FilterState fs) async {
    final body =
        fs.subView == SubView.yearwise ? fs.yearwiseBody : fs.monthwiseBody;

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {'accept': '*/*', 'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('API failed [${response.statusCode}]: ${response.body}');
    }

    final List<dynamic> list = jsonDecode(response.body);
    return list
        .map((e) => TurnoverRecord.fromJson(e,
            isMonth: fs.subView == SubView.monthwise))
        .toList();
  }
}

// ════════════════════════════════════════════════════════════
//  HELPERS
// ════════════════════════════════════════════════════════════

const int _currentYear = 2026;
// Live current month — caps available months when year = current year
final int _currentMonth = DateTime.now().month;

String _monthName(int m) => const [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][m.clamp(0, 12)];

String _fmtK(double v) => v.abs() >= 1000
    ? '${(v / 1000).toStringAsFixed(1)}K'
    : v.round().toString();

String _commas(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

// ════════════════════════════════════════════════════════════
//  THEME
// ════════════════════════════════════════════════════════════

const Color _c0 = Color(0xFF0F172A);
const Color _c1 = Color(0xFF1E293B);
const Color _c2 = Color(0xFF475569);
const Color _c3 = Color(0xFF94A3B8);
const Color _cBg = Color(0xFFF8FAFC);
const Color _cCard = Colors.white;
const Color _cBdr = Color(0xFFE2E8F0);
const Color _cBlue = Color(0xFF2563EB);
const Color _cIndi = Color(0xFF6366F1);
const Color _cTeal = Color(0xFF0D9488);
const Color _cAmber = Color(0xFFD97706);
const Color _cRose = Color(0xFFE11D48);
const Color _cPurp = Color(0xFF7C3AED);
const Color _cSlate = Color(0xFF64748B);

Color _tint(Color c, [double o = 0.10]) => c.withOpacity(o);

String _riskLabel(double p) =>
    p < 10 ? 'Healthy' : p < 20 ? 'Moderate' : p < 30 ? 'High' : 'Critical';

Color _riskColor(double p) => p < 10 ? _cTeal : p < 20 ? _cAmber : _cRose;

// ════════════════════════════════════════════════════════════
//  ROOT SCREEN
// ════════════════════════════════════════════════════════════

class TurnOverScreen extends StatefulWidget {
  const TurnOverScreen({super.key});
  @override
  State<TurnOverScreen> createState() => _TurnOverScreenState();
}

class _TurnOverScreenState extends State<TurnOverScreen>
    with SingleTickerProviderStateMixin {
  FilterState _filter = const FilterState();
  int _tab = 0;
  List<TurnoverRecord> _data = [];
  bool _loading = false;
  String? _error;
  late AnimationController _ac;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _data = await TurnoverApiService.fetch(_filter);
      _ac
        ..reset()
        ..forward();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onFilterChanged(FilterState fs) {
    setState(() => _filter = fs);
    _loadData();
  }

  bool get _isMonth => _filter.subView == SubView.monthwise;

  @override
  Widget build(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 900 ? _wide() : _narrow();

  Widget _wide() => Scaffold(
        backgroundColor: _cBg,
        body: Row(children: [
          _SideNav(tab: _tab, onTab: (t) => setState(() => _tab = t)),
          Expanded(
              child: Column(children: [
            _FilterBar(
                filter: _filter, onChanged: _onFilterChanged, isWide: true),
            Expanded(child: _body()),
          ])),
        ]),
      );

  Widget _narrow() => Scaffold(
        backgroundColor: _cBg,
        body: Column(children: [
          _Header(),
          _FilterBar(
              filter: _filter, onChanged: _onFilterChanged, isWide: false),
          _TabStrip(tab: _tab, onTab: (t) => setState(() => _tab = t)),
          Expanded(child: _body()),
        ]),
      );

  Widget _body() {
    if (_loading) return const _Loader();
    if (_error != null)
      return _ErrorView(error: _error!, onRetry: _loadData);
    if (_data.isEmpty) return const _Empty();
    return FadeTransition(opacity: _fade, child: _tabContent());
  }

  Widget _tabContent() {
    // agg = first record for KPI cards (overview uses all records for charts)
    final agg = _data.first;
    switch (_tab) {
      case 0:
        return _OverviewTab(data: _data, filter: _filter, agg: agg);
      case 1:
        return _ChartsTab(data: _data, isMonth: _isMonth);
      case 2:
        return _TableTab(data: _data, isMonth: _isMonth);
      case 3:
        return _InsightsTab(data: _data, agg: agg, isMonth: _isMonth);
      case 4:
        return _SummaryTab(data: _data, agg: agg, isMonth: _isMonth);
      default:
        return const SizedBox();
    }
  }
}

// ════════════════════════════════════════════════════════════
//  HEADER (narrow only)
// ════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: _cBdr))),
        child: Row(children: [
          _AppIcon(),
          const SizedBox(width: 10),
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('HR Analytics',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _c0)),
                Text('Turnover Dashboard',
                    style: TextStyle(fontSize: 11, color: _c2)),
              ])),
          const _LiveBadge(),
        ]),
      );
}

// ════════════════════════════════════════════════════════════
//  LOADING / ERROR / EMPTY
// ════════════════════════════════════════════════════════════

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext ctx) => const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircularProgressIndicator(color: _cBlue, strokeWidth: 2.5),
        SizedBox(height: 14),
        Text('Loading turnover data…',
            style: TextStyle(fontSize: 13, color: _c2)),
      ]));
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext ctx) => Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: _cRose),
          const SizedBox(height: 12),
          const Text('Failed to load data',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _c0)),
          const SizedBox(height: 6),
          Text(error,
              style: const TextStyle(fontSize: 11, color: _c3),
              textAlign: TextAlign.center),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
                backgroundColor: _cBlue, foregroundColor: Colors.white),
          ),
        ]),
      ));
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext ctx) => const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off_rounded, size: 48, color: _c3),
        SizedBox(height: 10),
        Text('No data for selected range',
            style: TextStyle(color: _c2, fontSize: 14)),
      ]));
}

// ════════════════════════════════════════════════════════════
//  FILTER BAR
// ════════════════════════════════════════════════════════════

class _FilterBar extends StatelessWidget {
  final FilterState filter;
  final void Function(FilterState) onChanged;
  final bool isWide;

  const _FilterBar(
      {required this.filter,
      required this.onChanged,
      required this.isWide});

  static final List<int> _allYears =
      List.generate(_currentYear - 2006 + 1, (i) => 2006 + i);
  static const List<int> _months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  @override
  Widget build(BuildContext ctx) => Container(
        color: _cCard,
        padding: EdgeInsets.symmetric(
            horizontal: isWide ? 24 : 14, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Type toggle ──
          _SubViewToggle(
            value: filter.subView,
            onChanged: (sv) => onChanged(filter.copyWith(subView: sv)),
          ),
          const SizedBox(height: 10),
          // ── Date pickers ──
          if (filter.subView == SubView.yearwise)
            Wrap(spacing: 10, runSpacing: 10, children: [
              _PickerField(
                label: 'From Year',
                displayValue: filter.fromYear.toString(),
                items: _allYears
                    .where((y) => y <= filter.toYear)
                    .toList(),
                selectedItem: filter.fromYear,
                itemLabel: (y) => y.toString(),
                onChanged: (y) => onChanged(filter.copyWith(fromYear: y)),
              ),
              _PickerField(
                label: 'To Year',
                displayValue: filter.toYear.toString(),
                items: _allYears
                    .where((y) => y >= filter.fromYear)
                    .toList(),
                selectedItem: filter.toYear,
                itemLabel: (y) => y.toString(),
                onChanged: (y) => onChanged(filter.copyWith(toYear: y)),
              ),
            ])
          else
            Wrap(spacing: 10, runSpacing: 10, children: [
              _PickerField(
                label: 'Year',
                displayValue: filter.monthYear.toString(),
                items: _allYears,
                selectedItem: filter.monthYear,
                itemLabel: (y) => y.toString(),
                onChanged: (y) => onChanged(filter.copyWith(monthYear: y)),
              ),
              _PickerField(
                label: 'From Month',
                displayValue:
                    '${_monthName(filter.fromMonth)} (${filter.fromMonth})',
                // cap at current month if current year selected
                items: _months
                    .where((m) =>
                        m <= filter.toMonth &&
                        (filter.monthYear < _currentYear ||
                            m <= _currentMonth))
                    .toList(),
                selectedItem: filter.fromMonth,
                itemLabel: (m) => '$m — ${_monthName(m)}',
                onChanged: (m) => onChanged(filter.copyWith(fromMonth: m)),
              ),
              _PickerField(
                label: 'To Month',
                displayValue:
                    '${_monthName(filter.toMonth)} (${filter.toMonth})',
                // cap at current month if current year selected
                items: _months
                    .where((m) =>
                        m >= filter.fromMonth &&
                        (filter.monthYear < _currentYear ||
                            m <= _currentMonth))
                    .toList(),
                selectedItem: filter.toMonth,
                itemLabel: (m) => '$m — ${_monthName(m)}',
                onChanged: (m) => onChanged(filter.copyWith(toMonth: m)),
              ),
            ]),
        ]),
      );
}

// ── SubView toggle ────────────────────────────────────────────

class _SubViewToggle extends StatelessWidget {
  final SubView value;
  final void Function(SubView) onChanged;
  const _SubViewToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext ctx) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Type',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _c2,
                letterSpacing: 0.3)),
        const SizedBox(height: 4),
        Container(
          height: 38,
          decoration: BoxDecoration(
              color: _cBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _cBdr)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _btn('Yearwise', SubView.yearwise),
            _btn('Monthwise', SubView.monthwise),
          ]),
        ),
      ]);

  Widget _btn(String label, SubView sv) {
    final sel = value == sv;
    return GestureDetector(
      onTap: () => onChanged(sv),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: sel ? _cIndi : Colors.transparent,
            borderRadius: BorderRadius.circular(9)),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : _c2)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  UNIFIED PICKER FIELD  (bottom-sheet, identical for year & month)
// ════════════════════════════════════════════════════════════

class _PickerField extends StatelessWidget {
  final String label, displayValue;
  final List<int> items;
  final int selectedItem;
  final String Function(int) itemLabel;
  final void Function(int) onChanged;

  const _PickerField({
    required this.label,
    required this.displayValue,
    required this.items,
    required this.selectedItem,
    required this.itemLabel,
    required this.onChanged,
  });

  void _open(BuildContext ctx) {
    final idx = items.indexOf(selectedItem);
    final sc = ScrollController(
        initialScrollOffset: idx > 3 ? (idx - 3) * 52.0 : 0);
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.55),
        decoration: const BoxDecoration(
          color: _cCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: _cBdr, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _c0)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: _cBg,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: _c2),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: _cBdr),
          Flexible(
            child: ListView.builder(
              controller: sc,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final sel = item == selectedItem;
                return GestureDetector(
                  onTap: () {
                    onChanged(item);
                    Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: sel
                          ? _cBlue.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel
                              ? _cBlue.withOpacity(0.3)
                              : Colors.transparent),
                    ),
                    child: Row(children: [
                      Text(itemLabel(item),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: sel ? _cBlue : _c0)),
                      const Spacer(),
                      if (sel)
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                              color: _cBlue, shape: BoxShape.circle),
                          child: const Icon(Icons.check_rounded,
                              size: 13, color: Colors.white),
                        ),
                    ]),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
        ]),
      ),
    ).whenComplete(() => sc.dispose());
  }

  @override
  Widget build(BuildContext ctx) => SizedBox(
        width: 130,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _c2,
                  letterSpacing: 0.3)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _open(ctx),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _cCard,
                border: Border.all(color: _cBdr),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(displayValue,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _c0),
                      overflow: TextOverflow.ellipsis),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: _c3),
              ]),
            ),
          ),
        ]),
      );
}

// ════════════════════════════════════════════════════════════
//  SIDE NAV
// ════════════════════════════════════════════════════════════

class _SideNav extends StatelessWidget {
  final int tab;
  final void Function(int) onTab;
  const _SideNav({required this.tab, required this.onTab});

  static const _items = [
    (Icons.dashboard_rounded, 'Overview'),
    (Icons.bar_chart_rounded, 'Charts'),
    (Icons.table_chart_rounded, 'Table'),
    (Icons.lightbulb_rounded, 'Insights'),
    (Icons.summarize_rounded, 'Summary'),
  ];

  @override
  Widget build(BuildContext ctx) => Container(
        width: 200,
        color: _c0,
        child: Column(children: [
          const SizedBox(height: 24),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _AppIcon(),
                const SizedBox(width: 10),
                const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HR Analytics',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      Text('Turnover',
                          style: TextStyle(fontSize: 10, color: _c3)),
                    ]),
              ])),
          const SizedBox(height: 24),
          ..._items.asMap().entries.map((e) {
            final sel = tab == e.key;
            return GestureDetector(
                onTap: () => onTab(e.key),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                        color: sel ? _cBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      Icon(e.value.$1,
                          size: 18, color: sel ? Colors.white : _c3),
                      const SizedBox(width: 10),
                      Text(e.value.$2,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: sel
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: sel ? Colors.white : _c3)),
                    ])));
          }),
          const Spacer(),
          const _LiveBadge(dark: true),
          const SizedBox(height: 20),
        ]),
      );
}

class _TabStrip extends StatelessWidget {
  final int tab;
  final void Function(int) onTab;
  const _TabStrip({required this.tab, required this.onTab});
  static const _lbl = ['Overview', 'Charts', 'Table', 'Insights', 'Summary'];

  @override
  Widget build(BuildContext ctx) => Container(
        color: _cCard,
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: List.generate(_lbl.length, (i) {
              final sel = tab == i;
              return GestureDetector(
                  onTap: () => onTab(i),
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color:
                                      sel ? _cBlue : Colors.transparent,
                                  width: 2.5))),
                      child: Text(_lbl[i],
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: sel ? _cBlue : _c2))));
            }))),
      );
}

// ════════════════════════════════════════════════════════════
//  OVERVIEW TAB
// ════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  final List<TurnoverRecord> data;
  final FilterState filter;
  final TurnoverRecord agg;

  const _OverviewTab(
      {required this.data, required this.filter, required this.agg});

  bool get _isMonth => filter.subView == SubView.monthwise;

  String get _rangeLabel => _isMonth
      ? '${filter.monthYear}  •  ${_monthName(filter.fromMonth)} – ${_monthName(filter.toMonth)}  •  ${data.length} months'
      : 'Year-by-Year  •  ${filter.fromYear} – ${filter.toYear}  •  ${data.length} records';

  @override
  Widget build(BuildContext ctx) {
    final d = agg;
    final w = MediaQuery.of(ctx).size.width;
    final cols = w >= 900 ? 4 : w >= 600 ? 3 : 2;
    final pad = w >= 600 ? 20.0 : 14.0;

    // totals across all records for overview when monthwise
    final totalLeft = data.fold(0, (s, r) => s + r.left);
    final avgPct = data.fold(0.0, (s, r) => s + r.pct) / data.length;

    return ListView(padding: EdgeInsets.all(pad), children: [
      _SecLabel(_rangeLabel),
      const SizedBox(height: 12),
      _Grid(cols: cols, gap: 10, children: [
        _Kpi('Begin HC', _commas(d.beginHC), 'Start of period',
            Icons.groups_rounded, _cBlue),
        _Kpi('End HC', _commas(d.endHC), 'End of period',
            Icons.group_rounded, _cTeal),
        _Kpi('Avg HC', _fmtK(d.avgHC), 'Workforce avg',
            Icons.people_outline_rounded, _cIndi),
        _Kpi('Total Left',
            _isMonth ? _commas(totalLeft) : _commas(d.left),
            'Departures', Icons.exit_to_app_rounded, _cRose),
        _Kpi('Retention',
            '${d.retentionPct.toStringAsFixed(1)}%', 'Stayed',
            Icons.favorite_rounded, _cTeal),
        _Kpi('Turnover',
            '${(_isMonth ? avgPct : d.pct).toStringAsFixed(2)}%',
            _riskLabel(_isMonth ? avgPct : d.pct),
            Icons.trending_down_rounded,
            _riskColor(_isMonth ? avgPct : d.pct)),
        _Kpi(
            'Net Change',
            '${d.netChange >= 0 ? '+' : ''}${d.netChange}',
            d.netChange >= 0 ? 'Grew' : 'Shrank',
            d.netChange >= 0
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            d.netChange >= 0 ? _cTeal : _cRose),
        _Kpi(
            _isMonth ? 'Months' : 'Years',
            '${data.length}',
            _isMonth
                ? '${_monthName(filter.fromMonth)} – ${_monthName(filter.toMonth)}'
                : '${filter.fromYear} – ${filter.toYear}',
            Icons.calendar_month_rounded,
            _cPurp),
      ]),
      const SizedBox(height: 16),
      _Gauge(pct: _isMonth ? avgPct : d.pct),
      const SizedBox(height: 12),
      _Donut(retPct: d.retentionPct),
      const SizedBox(height: 12),
      if (data.length > 1) _Spark(data: data),
    ]);
  }
}

// ════════════════════════════════════════════════════════════
//  CHARTS TAB
// ════════════════════════════════════════════════════════════

class _ChartsTab extends StatefulWidget {
  final List<TurnoverRecord> data;
  final bool isMonth;
  const _ChartsTab({required this.data, required this.isMonth});

  @override
  State<_ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends State<_ChartsTab> {
  String _m = 'Turnover %';
  static const _opts = [
    'Turnover %',
    'Headcount',
    'Attrition',
    'Net Change',
    'Retention %',
  ];

  List<double> _vals() => switch (_m) {
        'Turnover %' => widget.data.map((r) => r.pct).toList(),
        'Headcount' => widget.data.map((r) => r.endHC.toDouble()).toList(),
        'Attrition' => widget.data.map((r) => r.left.toDouble()).toList(),
        'Net Change' =>
          widget.data.map((r) => r.netChange.toDouble()).toList(),
        'Retention %' => widget.data.map((r) => r.retentionPct).toList(),
        _ => [],
      };

  @override
  Widget build(BuildContext ctx) {
    if (widget.data.isEmpty) return const _Empty();
    return ListView(padding: const EdgeInsets.all(16), children: [
      _SecLabel('Chart Explorer  •  ${widget.isMonth ? 'Monthly' : 'Yearly'} View'),
      const SizedBox(height: 8),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: _opts
                  .map((o) => Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: _Chip(
                            label: o,
                            sel: _m == o,
                            onTap: () => setState(() => _m = o)),
                      ))
                  .toList())),
      const SizedBox(height: 16),
      _BarChart(data: widget.data, vals: _vals(), metric: _m),
      const SizedBox(height: 14),
      _DualLine(data: widget.data),
      const SizedBox(height: 14),
      _TurnoverArea(data: widget.data),
    ]);
  }
}

// ════════════════════════════════════════════════════════════
//  TABLE TAB
// ════════════════════════════════════════════════════════════

class _TableTab extends StatefulWidget {
  final List<TurnoverRecord> data;
  final bool isMonth;
  const _TableTab({required this.data, required this.isMonth});

  @override
  State<_TableTab> createState() => _TableTabState();
}

class _TableTabState extends State<_TableTab> {
  int _col = 0;
  bool _asc = true;
  String _q = '';

  List<TurnoverRecord> get _rows {
    var list = widget.data.where((r) {
      if (_q.isEmpty) return true;
      return r.tableLabel.toLowerCase().contains(_q.toLowerCase()) ||
          r.year.toString().contains(_q);
    }).toList();

    list.sort((a, b) {
      int c = switch (_col) {
        0 => a.tableLabel.compareTo(b.tableLabel),
        1 => a.beginHC.compareTo(b.beginHC),
        2 => a.endHC.compareTo(b.endHC),
        3 => a.left.compareTo(b.left),
        4 => a.pct.compareTo(b.pct),
        5 => a.retentionPct.compareTo(b.retentionPct),
        6 => a.netChange.compareTo(b.netChange),
        _ => 0,
      };
      return _asc ? c : -c;
    });
    return list;
  }

  @override
  Widget build(BuildContext ctx) {
    final rows = _rows;
    return Column(children: [
      Container(
          color: _cCard,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(children: [
            Expanded(
                child: TextField(
              decoration: InputDecoration(
                  hintText: widget.isMonth
                      ? 'Filter by month…'
                      : 'Filter by year…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 16),
                  hintStyle: const TextStyle(fontSize: 12, color: _c3)),
              style: const TextStyle(fontSize: 13),
              onChanged: (v) => setState(() => _q = v),
            )),
            const SizedBox(width: 10),
            Text('${rows.length} rows',
                style: const TextStyle(fontSize: 11, color: _c3)),
          ])),
      Expanded(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                _TblHdr(
                    col: _col,
                    asc: _asc,
                    isMonth: widget.isMonth,
                    onSort: (c) => setState(() {
                          _col == c ? _asc = !_asc : _asc = true;
                          _col = c;
                        })),
                ...rows.asMap().entries.map(
                    (e) => _TblRow(rec: e.value, even: e.key.isEven)),
                const SizedBox(height: 20),
              ]))),
    ]);
  }
}

// ════════════════════════════════════════════════════════════
//  INSIGHTS TAB
// ════════════════════════════════════════════════════════════

class _InsightsTab extends StatelessWidget {
  final List<TurnoverRecord> data;
  final TurnoverRecord agg;
  final bool isMonth;
  const _InsightsTab(
      {required this.data, required this.agg, required this.isMonth});

  @override
  Widget build(BuildContext ctx) {
    if (data.isEmpty) return const _Empty();
    final sorted = [...data]..sort((a, b) => a.pct.compareTo(b.pct));
    final best = sorted.first, worst = sorted.last;
    final avg = data.fold(0.0, (s, r) => s + r.pct) / data.length;
    final trend = data.length > 1 ? data.last.pct - data.first.pct : 0.0;
    final hi = data.where((r) => r.pct >= 20).length;
    final totalLeft = data.fold(0, (s, r) => s + r.left);
    final period = isMonth ? 'Month' : 'Year';

    return ListView(padding: const EdgeInsets.all(14), children: [
      _SecLabel('Key Insights'),
      const SizedBox(height: 10),
      _InsCard(
          icon: Icons.emoji_events_rounded,
          color: _cTeal,
          title: 'Best $period: ${best.tableLabel}',
          body:
              'Lowest turnover at ${best.pct.toStringAsFixed(2)}% — '
              '${_commas(best.left)} departures from ${_fmtK(best.avgHC)} avg staff.'),
      const SizedBox(height: 8),
      _InsCard(
          icon: Icons.warning_amber_rounded,
          color: _cRose,
          title: 'Highest Turnover: ${worst.tableLabel}',
          body:
              'Peak at ${worst.pct.toStringAsFixed(2)}% — '
              '${_commas(worst.left)} left. Investigate attrition drivers.'),
      const SizedBox(height: 8),
      _InsCard(
          icon: Icons.trending_up_rounded,
          color: _cAmber,
          title:
              'Trend: ${trend >= 0 ? '▲ Rising' : '▼ Declining'} ${trend.abs().toStringAsFixed(2)}pp',
          body: trend >= 0
              ? 'Turnover is worsening. Consider escalating to leadership.'
              : 'Positive trend — retention is improving. Reinforce initiatives.'),
      const SizedBox(height: 8),
      _InsCard(
          icon: Icons.bar_chart_rounded,
          color: _cBlue,
          title: 'Period Avg: ${avg.toStringAsFixed(2)}%',
          body:
              '${_commas(totalLeft)} total departures over ${data.length} ${isMonth ? 'month(s)' : 'year(s)'}. '
              'Industry benchmark is typically 10–15%.'),
      const SizedBox(height: 8),
      _InsCard(
          icon: Icons.gpp_bad_rounded,
          color: _cPurp,
          title: 'High-Risk Periods: $hi of ${data.length}',
          body:
              '${(hi / data.length * 100).toStringAsFixed(0)}% of periods had turnover ≥ 20%. '
              '${hi == 0 ? 'Excellent stability.' : 'Root-cause analysis recommended.'}'),
      const SizedBox(height: 16),
      _SecLabel('${isMonth ? 'Month-over-Month' : 'Year-over-Year'} Δ Turnover'),
      const SizedBox(height: 8),
      if (data.length > 1)
        ...List.generate(data.length - 1, (i) {
          final d = data[i + 1].pct - data[i].pct;
          return _YoY(
              label: data[i + 1].tableLabel, delta: d);
        }),
    ]);
  }
}

// ════════════════════════════════════════════════════════════
//  SUMMARY TAB
// ════════════════════════════════════════════════════════════

class _SummaryTab extends StatelessWidget {
  final List<TurnoverRecord> data;
  final TurnoverRecord agg;
  final bool isMonth;
  const _SummaryTab(
      {required this.data, required this.agg, required this.isMonth});

  @override
  Widget build(BuildContext ctx) {
    if (data.isEmpty) return const _Empty();
    final avg = data.fold(0.0, (s, r) => s + r.pct) / data.length;
    final best = data.reduce((a, b) => a.pct < b.pct ? a : b);
    final totalLeft = data.fold(0, (s, r) => s + r.left);
    final grade = avg < 10
        ? 'A'
        : avg < 15
            ? 'B'
            : avg < 20
                ? 'C'
                : avg < 25
                    ? 'D'
                    : 'F';
    final gradeC = avg < 15 ? _cTeal : avg < 20 ? _cAmber : _cRose;

    return ListView(padding: const EdgeInsets.all(16), children: [
      _SecLabel('Executive Scorecard'),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: _c0, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Health Grade',
                  style: TextStyle(fontSize: 12, color: _c3)),
              const SizedBox(height: 4),
              Text(grade,
                  style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: gradeC,
                      height: 1)),
              const SizedBox(height: 4),
              Text(avg < 15 ? 'Within target' : 'Needs attention',
                  style: TextStyle(
                      fontSize: 11,
                      color: avg < 15 ? _cTeal : _cRose)),
            ]),
            _MiniDonut(pct: 100 - avg),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: _ScoreStat(
                    'Avg Turnover', '${avg.toStringAsFixed(1)}%', _cAmber)),
            const SizedBox(width: 8),
            Expanded(
                child: _ScoreStat(
                    'Total Left', _fmtK(totalLeft.toDouble()), _cRose)),
            const SizedBox(width: 8),
            Expanded(
                child: _ScoreStat(
                    isMonth ? 'Best Month' : 'Best Year',
                    best.tableLabel,
                    _cTeal)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      _SecLabel('Benchmarks'),
      const SizedBox(height: 10),
      ...[
        ('< 10%', 'Low turnover — excellent retention', _cTeal),
        ('10–15%', 'Industry average — acceptable', _cAmber),
        ('15–20%', 'Moderate concern — review policies',
            const Color(0xFFEA580C)),
        ('> 20%', 'High turnover — urgent action required', _cRose),
      ].map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: _Bench(range: b.$1, label: b.$2, color: b.$3))),
      const SizedBox(height: 16),
      _SecLabel('Top 5 Worst ${isMonth ? 'Months' : 'Years'}'),
      const SizedBox(height: 8),
      ...([...data]..sort((a, b) => b.pct.compareTo(a.pct)))
          .take(5)
          .toList()
          .asMap()
          .entries
          .map((e) => _RankRow(rank: e.key + 1, rec: e.value)),
    ]);
  }
}

// ════════════════════════════════════════════════════════════
//  CHART PAINTERS
// ════════════════════════════════════════════════════════════

class _BarChart extends StatelessWidget {
  final List<TurnoverRecord> data;
  final List<double> vals;
  final String metric;
  const _BarChart(
      {required this.data, required this.vals, required this.metric});

  String _lbl(double v) =>
      (metric == 'Turnover %' || metric == 'Retention %')
          ? '${v.toStringAsFixed(1)}%'
          : _fmtK(v);

  @override
  Widget build(BuildContext ctx) {
    if (vals.isEmpty) return const SizedBox();
    final hasNeg = vals.any((v) => v < 0);
    final maxV = vals.map((v) => v.abs()).reduce(max);
    final bW = MediaQuery.of(ctx).size.width >= 600 ? 28.0 : 20.0;
    return _CCard(
        title: metric,
        child: SizedBox(
            height: 210,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                    width: max(data.length * (bW + 12) + 20, 280),
                    child: CustomPaint(
                        painter: _BPainter(
                            vals: vals,
                            // ✅ Use chartLabel — works for both year and month
                            labels: data.map((r) => r.chartLabel).toList(),
                            maxV: maxV,
                            hasNeg: hasNeg,
                            bW: bW,
                            fmt: _lbl))))));
  }
}

class _BPainter extends CustomPainter {
  final List<double> vals;
  final List<String> labels;
  final double maxV, bW;
  final bool hasNeg;
  final String Function(double) fmt;

  _BPainter(
      {required this.vals,
      required this.labels,
      required this.maxV,
      required this.hasNeg,
      required this.bW,
      required this.fmt});

  @override
  void paint(Canvas c, Size s) {
    const bP = 28.0, tP = 14.0;
    final h = s.height - bP - tP;
    final base = hasNeg ? tP + h / 2 : tP + h;
    final step = s.width / vals.length;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    c.drawLine(Offset(0, base), Offset(s.width, base),
        Paint()..color = _cBdr..strokeWidth = 0.8);

    for (int i = 0; i < vals.length; i++) {
      final v = vals[i];
      final x = step * i + step / 2;
      final frac = maxV > 0 ? v.abs() / maxV : 0;
      final bH = (frac * (hasNeg ? h / 2 : h) * 0.88)
          .clamp(2.0, double.infinity);
      final isPos = v >= 0;
      final col = v < 0
          ? _cRose
          : frac > 0.75
              ? _cRose
              : frac > 0.45
                  ? _cAmber
                  : _cBlue;

      final top = isPos ? base - bH : base;
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x - bW / 2, top, bW, bH),
              const Radius.circular(4)),
          Paint()..color = col);

      if (bH > 20) {
        tp.text = TextSpan(
            text: fmt(v),
            style: const TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.w700));
        tp.layout();
        tp.paint(
            c,
            Offset(x - tp.width / 2,
                isPos ? top + 3 : top + bH - tp.height - 3));
      }

      // ✅ Use pre-built chartLabel directly — no more substring(2)
      tp.text = TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 8.5, color: _c3));
      tp.layout();
      tp.paint(c, Offset(x - tp.width / 2, s.height - bP + 5));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class _DualLine extends StatelessWidget {
  final List<TurnoverRecord> data;
  const _DualLine({required this.data});

  @override
  Widget build(BuildContext ctx) {
    if (data.length < 2) return const SizedBox();
    return _CCard(
        title: 'Avg Headcount vs Departures',
        legend: Row(children: [
          _LDot(color: _cBlue, label: 'Avg HC'),
          const SizedBox(width: 12),
          _LDot(color: _cRose, label: 'Left'),
        ]),
        child: SizedBox(
            height: 190,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                    width: max(data.length * 34.0, 260),
                    child: CustomPaint(
                        painter: _DLPainter(data: data))))));
  }
}

class _DLPainter extends CustomPainter {
  final List<TurnoverRecord> data;
  _DLPainter({required this.data});

  @override
  void paint(Canvas c, Size s) {
    const bP = 22.0, tP = 8.0;
    final h = s.height - bP - tP;
    final step = s.width / (data.length - 1);
    final hcV = data.map((r) => r.avgHC).toList();
    final lV = data.map((r) => r.left.toDouble()).toList();
    final mx = [...hcV, ...lV].reduce(max);

    for (var f in [0.25, 0.5, 0.75]) {
      final y = tP + h * (1 - f);
      c.drawLine(Offset(0, y), Offset(s.width, y),
          Paint()..color = _cBdr..strokeWidth = 0.5);
    }

    void drawLine(List<double> vals, Color col) {
      final paint = Paint()
        ..color = col
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final fill = Paint()
        ..color = col.withOpacity(0.07)
        ..style = PaintingStyle.fill;
      final lp = Path(), fp = Path();
      for (int i = 0; i < vals.length; i++) {
        final x = i * step, y = tP + h - (vals[i] / mx * h * 0.9);
        if (i == 0) {
          lp.moveTo(x, y);
          fp
            ..moveTo(x, s.height - bP)
            ..lineTo(x, y);
        } else {
          lp.lineTo(x, y);
          fp.lineTo(x, y);
        }
      }
      fp
        ..lineTo(s.width, s.height - bP)
        ..close();
      c.drawPath(fp, fill);
      c.drawPath(lp, paint);
      for (int i = 0; i < vals.length; i++) {
        final x = i * step, y = tP + h - (vals[i] / mx * h * 0.9);
        c.drawCircle(Offset(x, y), 3.5,
            Paint()..color = _cCard..style = PaintingStyle.fill);
        c.drawCircle(Offset(x, y), 3.5,
            Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 1.8);
      }
    }

    drawLine(hcV, _cBlue);
    drawLine(lV, _cRose);

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < data.length; i += max(1, data.length ~/ 7)) {
      tp.text = TextSpan(
          text: data[i].chartLabel,
          style: const TextStyle(fontSize: 8, color: _c3));
      tp.layout();
      tp.paint(
          c, Offset(i * step - tp.width / 2, s.height - bP + 4));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class _TurnoverArea extends StatelessWidget {
  final List<TurnoverRecord> data;
  const _TurnoverArea({required this.data});

  @override
  Widget build(BuildContext ctx) {
    if (data.length < 2) return const SizedBox();
    return _CCard(
        title: 'Turnover % — Color-zoned',
        legend: Row(children: [
          _LDot(color: _cTeal, label: '< 10%'),
          const SizedBox(width: 10),
          _LDot(color: _cAmber, label: '10–20%'),
          const SizedBox(width: 10),
          _LDot(color: _cRose, label: '> 20%'),
        ]),
        child: SizedBox(
            height: 170,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                    width: max(data.length * 34.0, 260),
                    child: CustomPaint(
                        painter: _TAPainter(data: data))))));
  }
}

class _TAPainter extends CustomPainter {
  final List<TurnoverRecord> data;
  _TAPainter({required this.data});

  @override
  void paint(Canvas c, Size s) {
    const bP = 22.0, tP = 8.0, mxP = 40.0;
    final h = s.height - bP - tP;
    final step = s.width / (data.length - 1);

    for (var th in [10.0, 20.0]) {
      final y = tP + h * (1 - th / mxP);
      c.drawLine(Offset(0, y), Offset(s.width, y),
          Paint()..color = _cBdr..strokeWidth = 0.8);
    }

    for (int i = 0; i < data.length - 1; i++) {
      final x0 = i * step, x1 = (i + 1) * step;
      final y0 = tP + h * (1 - (data[i].pct / mxP).clamp(0, 1));
      final y1 = tP + h * (1 - (data[i + 1].pct / mxP).clamp(0, 1));
      final avg = (data[i].pct + data[i + 1].pct) / 2;
      final col = avg < 10 ? _cTeal : avg < 20 ? _cAmber : _cRose;
      c.drawPath(
          Path()
            ..moveTo(x0, s.height - bP)
            ..lineTo(x0, y0)
            ..lineTo(x1, y1)
            ..lineTo(x1, s.height - bP)
            ..close(),
          Paint()
            ..color = col.withOpacity(0.16)
            ..style = PaintingStyle.fill);
    }

    final lp = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * step,
          y = tP + h * (1 - (data[i].pct / mxP).clamp(0, 1));
      i == 0 ? lp.moveTo(x, y) : lp.lineTo(x, y);
    }
    c.drawPath(
        lp,
        Paint()
          ..color = _cSlate
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    for (int i = 0; i < data.length; i++) {
      final x = i * step,
          y = tP + h * (1 - (data[i].pct / mxP).clamp(0, 1));
      final col = data[i].pct < 10
          ? _cTeal
          : data[i].pct < 20
              ? _cAmber
              : _cRose;
      c.drawCircle(Offset(x, y), 4, Paint()..color = _cCard);
      c.drawCircle(Offset(x, y), 4,
          Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < data.length; i += max(1, data.length ~/ 7)) {
      tp.text = TextSpan(
          text: data[i].chartLabel,
          style: const TextStyle(fontSize: 8, color: _c3));
      tp.layout();
      tp.paint(
          c, Offset(i * step - tp.width / 2, s.height - bP + 4));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

// ════════════════════════════════════════════════════════════
//  TABLE WIDGETS
// ════════════════════════════════════════════════════════════

class _TblHdr extends StatelessWidget {
  final int col;
  final bool asc, isMonth;
  final void Function(int) onSort;
  const _TblHdr(
      {required this.col,
      required this.asc,
      required this.isMonth,
      required this.onSort});

  @override
  Widget build(BuildContext ctx) {
    final cols = [
      isMonth ? 'Month' : 'Year',
      'Begin',
      'End',
      'Left',
      'Rate',
      'Retain',
      'Net Δ'
    ];
    return Container(
        decoration: BoxDecoration(
            color: _c0,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(10))),
        child: Row(
            children: List.generate(cols.length, (i) {
          final sel = col == i;
          return Expanded(
              child: GestureDetector(
                  onTap: () => onSort(i),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: Row(
                          mainAxisAlignment: i == 0
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            Text(cols[i],
                                style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: sel ? Colors.white : _c3)),
                            if (sel)
                              Icon(
                                  asc
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  size: 9,
                                  color: Colors.white),
                          ]))));
        })));
  }
}

class _TblRow extends StatelessWidget {
  final TurnoverRecord rec;
  final bool even;
  const _TblRow({required this.rec, required this.even});

  @override
  Widget build(BuildContext ctx) {
    final rc = _riskColor(rec.pct);
    return Container(
        color: even ? _cBg : _cCard,
        child: Row(children: [
          Expanded(
              child: _TC(rec.tableLabel, left: true, bold: true)),
          Expanded(child: _TC(_fmtK(rec.beginHC.toDouble()))),
          Expanded(child: _TC(_fmtK(rec.endHC.toDouble()))),
          Expanded(child: _TC(_fmtK(rec.left.toDouble()))),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 3, vertical: 8),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                              color: rc.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text('${rec.pct.toStringAsFixed(1)}%',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: rc)))))),
          Expanded(
              child: _TC(
                  '${rec.retentionPct.toStringAsFixed(1)}%',
                  color: _cTeal)),
          Expanded(
              child: _TC(
                  '${rec.netChange >= 0 ? '+' : ''}${rec.netChange}',
                  color: rec.netChange >= 0 ? _cTeal : _cRose)),
        ]));
  }
}

class _TC extends StatelessWidget {
  final String text;
  final bool left, bold;
  final Color? color;
  const _TC(this.text,
      {this.left = false, this.bold = false, this.color});

  @override
  Widget build(BuildContext ctx) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      child: Text(text,
          textAlign: left ? TextAlign.left : TextAlign.right,
          style: TextStyle(
              fontSize: 10.5,
              color: color ?? _c0,
              fontWeight:
                  bold ? FontWeight.w700 : FontWeight.w400)));
}

// ════════════════════════════════════════════════════════════
//  KPI + VISUAL COMPONENTS
// ════════════════════════════════════════════════════════════

class _Kpi extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _Kpi(this.label, this.value, this.sub, this.icon, this.color);

  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: _cCard,
          border: Border.all(color: _cBdr),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: _tint(color),
                      borderRadius: BorderRadius.circular(9)),
                  child: Icon(icon, color: color, size: 16)),
              const Spacer(),
              Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _c0)),
            const SizedBox(height: 1),
            Text(label,
                style: const TextStyle(
                    fontSize: 10.5,
                    color: _c1,
                    fontWeight: FontWeight.w600)),
            Text(sub,
                style: const TextStyle(fontSize: 9.5, color: _c3)),
          ]));
}

class _Gauge extends StatelessWidget {
  final double pct;
  const _Gauge({required this.pct});

  @override
  Widget build(BuildContext ctx) {
    final color = _riskColor(pct);
    final frac = (pct / 50).clamp(0.0, 1.0);
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _cCard,
            border: Border.all(color: _cBdr),
            borderRadius: BorderRadius.circular(14)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('Turnover Rate',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _c0)),
                const Spacer(),
                _Badge(label: _riskLabel(pct), color: color),
              ]),
              const SizedBox(height: 12),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${pct.toStringAsFixed(2)}%',
                        style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: color)),
                    const SizedBox(width: 8),
                    const Text('avg',
                        style: TextStyle(fontSize: 13, color: _c3)),
                  ]),
              const SizedBox(height: 14),
              Stack(children: [
                Container(
                    height: 10,
                    decoration: BoxDecoration(
                        color: _cBg,
                        borderRadius: BorderRadius.circular(8))),
                FractionallySizedBox(
                    widthFactor: frac,
                    child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8)))),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Text('0%',
                    style: TextStyle(fontSize: 9, color: _c3)),
                const Spacer(),
                Text('Target < 10%',
                    style: TextStyle(
                        fontSize: 9,
                        color: _cTeal,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                const Text('50%+',
                    style: TextStyle(fontSize: 9, color: _c3)),
              ]),
            ]));
  }
}

class _Donut extends StatelessWidget {
  final double retPct;
  const _Donut({required this.retPct});

  @override
  Widget build(BuildContext ctx) => _CCard(
      title: 'Retention vs Attrition',
      child: SizedBox(
          height: 160,
          child: Row(children: [
            SizedBox(
                width: 160,
                child: CustomPaint(
                    size: const Size(160, 160),
                    painter: _DonutP(retained: retPct))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _LDot(color: _cTeal, label: 'Retained'),
                  const SizedBox(height: 4),
                  Text('${retPct.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _cTeal)),
                  const SizedBox(height: 12),
                  _LDot(color: _cRose, label: 'Attrition'),
                  const SizedBox(height: 4),
                  Text('${(100 - retPct).toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _cRose)),
                ])),
          ])));
}

class _DonutP extends CustomPainter {
  final double retained;
  _DonutP({required this.retained});

  @override
  void paint(Canvas c, Size s) {
    final cx = s.width / 2, cy = s.height / 2, r = min(cx, cy) - 16;
    const sw = 22.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final frac = 2 * pi * (retained / 100);
    c.drawArc(rect, -pi / 2, 2 * pi, false,
        Paint()..color = _cBdr..style = PaintingStyle.stroke..strokeWidth = sw);
    c.drawArc(rect, -pi / 2, frac, false,
        Paint()..color = _cTeal..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
    c.drawArc(rect, -pi / 2 + frac, 2 * pi - frac, false,
        Paint()..color = _cRose..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
          text: '${retained.toStringAsFixed(0)}%',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: _c0))
      ..layout();
    tp.paint(c, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => true;
}

class _Spark extends StatelessWidget {
  final List<TurnoverRecord> data;
  const _Spark({required this.data});

  @override
  Widget build(BuildContext ctx) {
    final mx = data.map((r) => r.pct).reduce(max);
    return _CCard(
        title: 'Turnover Trend',
        child: SizedBox(
            height: 72,
            child: CustomPaint(
                size: const Size(double.infinity, 72),
                painter: _SparkP(
                    vals: data
                        .map((r) => r.pct / max(mx, 1))
                        .toList()))));
  }
}

class _SparkP extends CustomPainter {
  final List<double> vals;
  _SparkP({required this.vals});

  @override
  void paint(Canvas c, Size s) {
    if (vals.length < 2) return;
    final step = s.width / (vals.length - 1);
    final lp = Path(), fp = Path();
    for (int i = 0; i < vals.length; i++) {
      final x = i * step, y = s.height - vals[i] * s.height * 0.88;
      if (i == 0) {
        lp.moveTo(x, y);
        fp..moveTo(x, s.height)..lineTo(x, y);
      } else {
        lp.lineTo(x, y);
        fp.lineTo(x, y);
      }
    }
    fp..lineTo(s.width, s.height)..close();
    c.drawPath(fp,
        Paint()..color = _cBlue.withOpacity(0.07)..style = PaintingStyle.fill);
    c.drawPath(
        lp,
        Paint()
          ..color = _cBlue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ════════════════════════════════════════════════════════════
//  SUMMARY COMPONENTS
// ════════════════════════════════════════════════════════════

class _MiniDonut extends StatelessWidget {
  final double pct;
  const _MiniDonut({required this.pct});

  @override
  Widget build(BuildContext ctx) => SizedBox(
      width: 90,
      height: 90,
      child: CustomPaint(painter: _MDP(pct: pct)));
}

class _MDP extends CustomPainter {
  final double pct;
  _MDP({required this.pct});

  @override
  void paint(Canvas c, Size s) {
    final cx = s.width / 2, cy = s.height / 2, r = cx - 8;
    const sw = 10.0;
    final frac = (pct / 100).clamp(0.0, 1.0);
    c.drawCircle(Offset(cx, cy), r,
        Paint()..color = Colors.white.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = sw);
    c.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -pi / 2,
        2 * pi * frac,
        false,
        Paint()..color = _cTeal..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
          text: '${pct.toStringAsFixed(0)}%',
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white))
      ..layout();
    tp.paint(c, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => true;
}

class _ScoreStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ScoreStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 9, color: _c3),
            textAlign: TextAlign.center),
      ]));
}

class _Bench extends StatelessWidget {
  final String range, label;
  final Color color;
  const _Bench(
      {required this.range, required this.label, required this.color});

  @override
  Widget build(BuildContext ctx) => Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
          color: _cCard,
          border: Border.all(color: _cBdr),
          borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Container(
            width: 5,
            height: 28,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 12),
        Text(range,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color)),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label,
                style:
                    const TextStyle(fontSize: 12, color: _c2))),
      ]));
}

class _RankRow extends StatelessWidget {
  final int rank;
  final TurnoverRecord rec;
  const _RankRow({required this.rank, required this.rec});

  @override
  Widget build(BuildContext ctx) {
    final color = _riskColor(rec.pct);
    return Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: _cCard,
            border: Border.all(color: _cBdr),
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: _tint(color),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text('#$rank',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color)))),
          const SizedBox(width: 10),
          Text(rec.tableLabel,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _c0)),
          const SizedBox(width: 8),
          Text('${_commas(rec.left)} left',
              style: const TextStyle(fontSize: 12, color: _c2)),
          const Spacer(),
          _Badge(
              label: '${rec.pct.toStringAsFixed(1)}%', color: color),
        ]));
  }
}

// ════════════════════════════════════════════════════════════
//  SMALL REUSABLE WIDGETS
// ════════════════════════════════════════════════════════════

class _CCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? legend;
  const _CCard(
      {required this.title, required this.child, this.legend});

  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _cCard,
          border: Border.all(color: _cBdr),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _c0)),
            if (legend != null) ...[
              const SizedBox(height: 6),
              legend!
            ],
            const SizedBox(height: 12),
            child,
          ]));
}

class _InsCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, body;
  const _InsCard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body});

  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _cCard,
          border: Border.all(color: _cBdr),
          borderRadius: BorderRadius.circular(12)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: _tint(color),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _c0)),
              const SizedBox(height: 4),
              Text(body,
                  style: const TextStyle(
                      fontSize: 12, color: _c2, height: 1.45)),
            ])),
      ]));
}

class _YoY extends StatelessWidget {
  final String label;
  final double delta;
  const _YoY({required this.label, required this.delta});

  @override
  Widget build(BuildContext ctx) {
    final imp = delta < 0;
    final color = imp ? _cTeal : _cRose;
    return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
            color: _cCard,
            border: Border.all(color: _cBdr),
            borderRadius: BorderRadius.circular(9)),
        child: Row(children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _c0)),
          const Spacer(),
          Icon(
              imp
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
              size: 14),
          const SizedBox(width: 4),
          Text('${delta > 0 ? '+' : ''}${delta.toStringAsFixed(2)}pp',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ]));
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: _tint(color), borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)));
}

class _Chip extends StatelessWidget {
  final String label;
  final bool sel;
  final VoidCallback onTap;
  const _Chip(
      {required this.label, required this.sel, required this.onTap});

  @override
  Widget build(BuildContext ctx) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
              color: sel ? _cBlue : _cCard,
              border: Border.all(color: sel ? _cBlue : _cBdr),
              borderRadius: BorderRadius.circular(20)),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : _c2))));
}

class _LDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LDot({required this.color, required this.label});

  @override
  Widget build(BuildContext ctx) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 9,
            height: 9,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: _c2)),
      ]);
}

class _SecLabel extends StatelessWidget {
  final String text;
  const _SecLabel(this.text);

  @override
  Widget build(BuildContext ctx) => Text(text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _c2,
          letterSpacing: 0.4));
}

class _AppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
          color: _cBlue, borderRadius: BorderRadius.circular(9)),
      child: const Icon(Icons.people_alt_rounded,
          color: Colors.white, size: 17));
}

class _LiveBadge extends StatelessWidget {
  final bool dark;
  const _LiveBadge({this.dark = false});

  @override
  Widget build(BuildContext ctx) => Container(
      margin: EdgeInsets.only(right: dark ? 0 : 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: dark
              ? Colors.white.withOpacity(0.08)
              : _cBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.circle, color: _cTeal, size: 7),
        const SizedBox(width: 5),
        Text('Live',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: dark ? _c3 : _cBlue)),
      ]));
}

class _Grid extends StatelessWidget {
  final int cols;
  final double gap;
  final List<Widget> children;
  const _Grid(
      {required this.cols,
      required this.gap,
      required this.children});

  @override
  Widget build(BuildContext ctx) {
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += cols) {
      final rc =
          children.sublist(i, min(i + cols, children.length)).toList();
      while (rc.length < cols) rc.add(const SizedBox());
      rows.add(Row(
          children: rc
              .asMap()
              .entries
              .map((e) => Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(
                          right: e.key < rc.length - 1 ? gap : 0),
                      child: e.value)))
              .toList()));
      if (i + cols < children.length) rows.add(SizedBox(height: gap));
    }
    return Column(children: rows);
  }
}