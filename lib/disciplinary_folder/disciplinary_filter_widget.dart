
// import 'package:flutter/material.dart';

// class FilterSection extends StatelessWidget {
//   final TextEditingController empController;
//   final TextEditingController fromDateController;
//   final TextEditingController toDateController;
//   final VoidCallback onApply;
//   final Function(TextEditingController) onPickDate;
//   const FilterSection({
//     super.key,
//     required this.empController,
//     required this.fromDateController,
//     required this.toDateController,
//     required this.onApply,
//     required this.onPickDate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF3F4F5),
//         borderRadius: BorderRadius.circular(32),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildInputLabel('Employee Number'),

//           // _buildInputField(Icons.badge_outlined, 'Enter ID...'),
//           _buildInputField(
//             icon: Icons.badge_outlined,
//             hint: 'Enter ID...',
//             controller: empController,
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildInputLabel('From Date'),
//                     // _buildInputField(Icons.calendar_today_outlined, '01 Jan 2024'),
//                     _buildInputField(
//                       icon: Icons.calendar_today_outlined,
//                       hint: '01 Jan 2024',
//                       controller: fromDateController,
//                       onTap: () => onPickDate(fromDateController),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildInputLabel('To Date'),
//                     // _buildInputField(Icons.event_outlined, '31 Dec 2024'),
//                     _buildInputField(
//                       icon: Icons.event_outlined,
//                       hint: '31 Dec 2024',
//                       controller: toDateController,
//                       onTap: () => onPickDate(toDateController),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           GestureDetector(
//             onTap: onApply,
//             child: Container(
//               width: double.infinity,
//               height: 56,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF005EA4), Color(0xFF0077CE)],
//                 ),
//                 borderRadius: BorderRadius.circular(28),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF005EA4).withOpacity(0.3),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.search, color: Colors.white),
//                     SizedBox(width: 8),
//                     Text(
//                       'Apply Filters',
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInputLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, bottom: 4),
//       child: Text(
//         text.toUpperCase(),
//         style: const TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 1.2,
//           color: Color(0xFF717786),
//         ),
//       ),
//     );
//   }

//   // Widget _buildInputField(IconData icon, String value) {
//   //   return Container(
//   //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(28),
//   //     ),
//   //     child: Row(
//   //       children: [
//   //         Icon(icon, size: 18, color: const Color(0xFF717786)),
//   //         const SizedBox(width: 10),
//   //         Text(
//   //           value,
//   //           style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _buildInputField({
//     required IconData icon,
//     required String hint,
//     TextEditingController? controller,
//     VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap, // for date picker
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(28),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 18, color: const Color(0xFF717786)),
//             const SizedBox(width: 10),

//             // ✅ Editable OR Display
//             Expanded(
//               child: controller == null
//                   ? Text(
//                       hint,
//                       style: const TextStyle(
//                           fontSize: 13, fontWeight: FontWeight.w600),
//                     )
//                   : AbsorbPointer(
//                       absorbing: onTap != null, // block typing for date
//                       child: TextField(
//                         controller: controller,
//                         decoration: const InputDecoration(
//                           isDense: true,
//                           border: InputBorder.none,
//                         ),
//                         style: const TextStyle(
//                             fontSize: 13, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }