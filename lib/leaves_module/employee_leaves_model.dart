
// ─── Data Model ───────────────────────────────────────────────────────────────

import 'dart:ui';

import 'package:flutter/material.dart';

class LeaveDto {
  final String empNo;
  final String holidayCode;
  final String holidayName;
  final DateTime startDate;
  final DateTime endDate;
  final double holidayQty;

  LeaveDto({
    required this.empNo,
    required this.holidayCode,
    required this.holidayName,
    required this.startDate,
    required this.endDate,
    required this.holidayQty,
  });
}

// ─── Leave Type Config ────────────────────────────────────────────────────────

class LeaveTypeStyle {
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final IconData icon;

  const LeaveTypeStyle({
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.icon,
  });
}

LeaveTypeStyle getLeaveStyle(String code) {
  switch (code) {
    case '05':
      return const LeaveTypeStyle(
          color: Color(0xFF2F80ED),
          bgColor: Color(0xFFE8F3FF),
          borderColor: Color(0xFFB3D4F7),
          icon: Icons.beach_access_rounded);
    case '15':
      return const LeaveTypeStyle(
          color: Color(0xFF6941C6),
          bgColor: Color(0xFFF0EBFF),
          borderColor: Color(0xFFD0BCFF),
          icon: Icons.person_rounded);
    case '02':
      return const LeaveTypeStyle(
          color: Color(0xFF0EA271),
          bgColor: Color(0xFFE6F7F2),
          borderColor: Color(0xFFB0E8D5),
          icon: Icons.event_available_rounded);
    case '08':
      return const LeaveTypeStyle(
          color: Color(0xFFD0152A),
          bgColor: Color(0xFFFFF0F0),
          borderColor: Color(0xFFFFB3B3),
          icon: Icons.local_hospital_rounded);
    default:
      return const LeaveTypeStyle(
          color: Color(0xFFF0A500),
          bgColor: Color(0xFFFFF8E6),
          borderColor: Color(0xFFFFDFA0),
          icon: Icons.event_note_rounded);
  }
}

// ─── App Colors ───────────────────────────────────────────────────────────────

class C {
  static const Color bg = Color(0xFFF0F4FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color navy = Color(0xFF1A2B4A);
  static const Color navyLight = Color(0xFF253A60);
  static const Color text = Color(0xFF1A2B4A);
  static const Color sub = Color(0xFF6B7A99);
  static const Color divider = Color(0xFFE4EAF4);
  static const Color tag = Color(0xFFEEF1F8);
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_month(d.month)} ${d.year}';

String fmtTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String fmtShort(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

String _month(int m) => const [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][m];

String hrsLabel(double qty) {
  final days = qty / 8;
  if (days == days.roundToDouble()) {
    return '${days.toInt()}d';
  }
  return '${qty.toStringAsFixed(0)}h';
}
