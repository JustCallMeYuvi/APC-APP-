// import 'package:flutter/material.dart';

// import 'car_booking_card.dart';
// import 'car_booking_model.dart';
// import 'car_conveyance_kms_track_service.dart';
// import 'car_filter_bar.dart';

// class CarListScreen extends StatefulWidget {
//   const CarListScreen({super.key});

//   @override
//   State<CarListScreen> createState() => _CarListScreenState();
// }

// class _CarListScreenState extends State<CarListScreen> {
//   List<CarBookingTrack> _all = [];
//   bool _isLoading = false;
//   String? _error;

//   // Filters
//   DateTime? fromDate;
//   DateTime? toDate;
//   String? selectedCar;
//   String statusFilter = 'All'; // All | Pending | Done

//   // Default date range = today
//   late DateTime _defaultFrom;
//   late DateTime _defaultTo;

//   @override
//   void initState() {
//     super.initState();
//     final now = DateTime.now();
//     _defaultFrom = DateTime(now.year, now.month, 1); // first of current month
//     _defaultTo = now;
//     fromDate = _defaultFrom;
//     toDate = _defaultTo;
//     _fetchData();
//   }

//   @override
//   void dispose() {
//     for (final b in _all) {
//       b.dispose();
//     }
//     super.dispose();
//   }

//   // ── API ──────────────────────────────────────────────────────────────────

//   Future<void> _fetchData() async {
//     if (fromDate == null || toDate == null) return;

//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final bookings = await CarConveyanceService.getKmsReport(
//         fromDate: fromDate!,
//         toDate: toDate!,
//       );
//       // Dispose old controllers
//       for (final b in _all) {
//         b.dispose();
//       }
//       bookings.sort((a, b) => b.carInTime.compareTo(a.carInTime));
//       setState(() {
//         _all = bookings;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _error = e.toString();
//       });
//     }
//   }

//   Future<void> _saveKms(CarBookingTrack b) async {
//     final kmsText = b.kmsCtrl.text.trim();
//     if (kmsText.isEmpty) {
//       _showSnack('Please enter actual KMs', const Color(0xFFEF4444));
//       return;
//     }

//     // final kmsValue = int.tryParse(kmsText);
//     final kmsValue = double.tryParse(kmsText);
//     if (kmsValue == null || kmsValue <= 0) {
//       _showSnack('Enter a valid KM number', const Color(0xFFEF4444));
//       return;
//     }

//     setState(() => b.saving = true);

//     try {
//       await CarConveyanceService.updateActualKms(
//         carInTime: b.carInTime,
//         actualKms: kmsValue,
//         carDetails: b.carDetails,
//       );
//       if (mounted) {
//         _showSnack(
//             'Saved ${kmsValue} km for SNO ${b.sno}', const Color(0xFF16A34A));
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnack('Failed to save: $e', const Color(0xFFEF4444));
//       }
//     } finally {
//       if (mounted) setState(() => b.saving = false);
//     }
//   }

//   // ── Helpers ──────────────────────────────────────────────────────────────

//   void _showSnack(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   Future<void> _pickDate(bool isFrom) async {
//     final initial =
//         isFrom ? (fromDate ?? DateTime.now()) : (toDate ?? DateTime.now());
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (context, child) => Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: const ColorScheme.light(primary: Color(0xFF5B5FEF)),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isFrom) {
//           fromDate = picked;
//         } else {
//           toDate = picked;
//         }
//       });
//       // _fetchData(); // re-fetch on date change
//     }
//   }

//   void _clearFilters() {
//     setState(() {
//       fromDate = _defaultFrom;
//       toDate = _defaultTo;
//       selectedCar = null;
//       statusFilter = 'All';
//     });
//     _fetchData();
//   }

//   // ── Computed ─────────────────────────────────────────────────────────────

//   List<String> get _carOptions {
//     final names = _all.map((b) => b.carName).toSet().toList()..sort();
//     return ['All', ...names];
//   }

//   List<CarBookingTrack> get _filtered {
//     return _all.where((b) {
//       if (selectedCar != null &&
//           selectedCar != 'All' &&
//           b.carName != selectedCar) return false;

//       final hasKms = b.kmsCtrl.text.trim().isNotEmpty;
//       if (statusFilter == 'Pending' && hasKms) return false;
//       if (statusFilter == 'Done' && !hasKms) return false;

//       return true;
//     }).toList();
//   }

//   String _fmtDateTime(DateTime dt) {
//     final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
//     final ampm = dt.hour >= 12 ? 'PM' : 'AM';
//     return '${dt.day}/${dt.month}/${dt.year}  $h:${dt.minute.toString().padLeft(2, '0')} $ampm';
//   }

//   String _fmtDate(DateTime? dt) =>
//       dt == null ? '' : '${dt.day}/${dt.month}/${dt.year}';

//   // ── Build ─────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final results = _filtered;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FB),
//       body: CustomScrollView(
//         slivers: [
//           // App Bar
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: Colors.white,
//             elevation: 0,
//             centerTitle: false,
//             title: const Text(
//               'Car KMS Report',
//               style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                   color: Color(0xFF1E2139)),
//             ),
//             actions: [
//               IconButton(
//                 icon:
//                     const Icon(Icons.refresh_rounded, color: Color(0xFF5B5FEF)),
//                 tooltip: 'Refresh',
//                 onPressed: _isLoading ? null : _fetchData,
//               ),
//               const SizedBox(width: 4),
//             ],
//           ),

//           // Filter bar
//           SliverToBoxAdapter(
//             child: CarFilterBar(
//               fromLabel: _fmtDate(fromDate),
//               toLabel: _fmtDate(toDate),
//               onFromTap: () => _pickDate(true),
//               onToTap: () => _pickDate(false),
//               onClear: _clearFilters,
//               resultCount: results.length,
//               isLoading: _isLoading,
//               carOptions: _carOptions,
//               selectedCar: selectedCar,
//               onCarChanged: (v) => setState(() => selectedCar = v),
//               statusFilter: statusFilter,
//               onStatusChanged: (v) => setState(() => statusFilter = v),
//             ),
//           ),

//           // Error state
//           if (_error != null)
//             SliverFillRemaining(
//               hasScrollBody: false,
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(32),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(Icons.cloud_off_rounded,
//                           size: 52, color: Color(0xFFEF4444)),
//                       const SizedBox(height: 12),
//                       Text(
//                         'Failed to load data',
//                         style: TextStyle(
//                             color: Colors.grey[700],
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         _error!,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.grey[500], fontSize: 12),
//                       ),
//                       const SizedBox(height: 20),
//                       ElevatedButton.icon(
//                         onPressed: _fetchData,
//                         icon: const Icon(Icons.refresh_rounded, size: 18),
//                         label: const Text('Retry'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF5B5FEF),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             )

//           // Loading shimmer / empty / grid
//           else if (_isLoading)
//             const SliverFillRemaining(
//               hasScrollBody: false,
//               child: Center(
//                 child: CircularProgressIndicator(color: Color(0xFF5B5FEF)),
//               ),
//             )
//           else if (results.isEmpty)
//             SliverFillRemaining(
//               hasScrollBody: false,
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.search_off_rounded,
//                         size: 52, color: Colors.grey[350]),
//                     const SizedBox(height: 12),
//                     Text(
//                       'No bookings in this range',
//                       style: TextStyle(
//                           color: Colors.grey[500],
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
//               sliver: SliverLayoutBuilder(
//                 builder: (context, constraints) {
//                   final w = constraints.crossAxisExtent;
//                   final cols = w > 1100 ? 3 : (w > 650 ? 2 : 1);
//                   return SliverGrid(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: cols,
//                       mainAxisExtent: 178,
//                       crossAxisSpacing: 12,
//                       mainAxisSpacing: 12,
//                     ),
//                     delegate: SliverChildBuilderDelegate(
//                       (context, i) => CarBookingCard(
//                         booking: results[i],
//                         formattedTime: _fmtDateTime(results[i].carInTime),
//                         onSave: () => _saveKms(results[i]),
//                       ),
//                       childCount: results.length,
//                     ),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
