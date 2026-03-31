// class DisciplinaryModel {
//   final String awpnNo;
//   final String empName;
//   final String empNo;
//   final String deptName;
//   final String reason;
//   final String status;
//   final String disciplinaryDate;
//   final String lastDate;
//   final String rewardQty;
//   final String rewardAmount;

//   DisciplinaryModel({
//     required this.awpnNo,
//     required this.empName,
//     required this.empNo,
//     required this.deptName,
//     required this.reason,
//     required this.status,
//     required this.disciplinaryDate,
//     required this.lastDate,
//     required this.rewardQty,
//     required this.rewardAmount,
//   });

//   factory DisciplinaryModel.fromJson(Map<String, dynamic> json) {
//     return DisciplinaryModel(
//       awpnNo: json['awpnNo'] ?? '',
//       empName: json['empName'] ?? '',
//       empNo: json['empNo'] ?? '',
//       deptName: json['deptName'] ?? '',
//       reason: json['reason'] ?? '',
//       status: json['status'] ?? '',
//       disciplinaryDate: json['disciplinaryDate'] ?? '',
//       lastDate: json['lastDate'] ?? '',
//       rewardQty: json['rewardQuantity'] ?? '0',
//       rewardAmount: json['rewardAmount'] ?? '0',
//     );
//   }
// }


// ─── Data Model ───────────────────────────────────────────────────────────────

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DisciplinaryDto {
  final String empNo, empName, deptName, disciplinaryDate;
  final String rewardCode, rewardName, rewardQuantity, rewardAmount, reason;

  DisciplinaryDto({
    required this.empNo,
    required this.empName,
    required this.deptName,
    required this.disciplinaryDate,
    required this.rewardCode,
    required this.rewardName,
    required this.rewardQuantity,
    required this.rewardAmount,
    required this.reason,
  });
}

// ─── Reward Style ─────────────────────────────────────────────────────────────

class RewardStyle {
  final Color color, bgColor, borderColor;
  final IconData icon;
  final String label;
  const RewardStyle({
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.icon,
    required this.label,
  });
}

RewardStyle getRewardStyle(String code) {
  switch (code) {
    case '1':
      return const RewardStyle(
          color: Color(0xFF0EA271),
          bgColor: Color(0xFFE6F7F2),
          borderColor: Color(0xFFB0E8D5),
          icon: Icons.star_rounded,
          label: 'Praise');
    case '2':
      return const RewardStyle(
          color: Color(0xFF2F80ED),
          bgColor: Color(0xFFE8F1FD),
          borderColor: Color(0xFFB3D0F7),
          icon: Icons.thumb_up_rounded,
          label: 'Minor Merit');
    case '3':
      return const RewardStyle(
          color: Color(0xFF6941C6),
          bgColor: Color(0xFFF0EBFF),
          borderColor: Color(0xFFD0BCFF),
          icon: Icons.emoji_events_rounded,
          label: 'Major Merit');
    case '4':
      return const RewardStyle(
          color: Color(0xFFF0A500),
          bgColor: Color(0xFFFFF8E6),
          borderColor: Color(0xFFFFDFA0),
          icon: Icons.warning_amber_rounded,
          label: 'Warning');
    case '5':
      return const RewardStyle(
          color: Color(0xFFE05C2A),
          bgColor: Color(0xFFFFF1EB),
          borderColor: Color(0xFFFFCCB5),
          icon: Icons.remove_circle_rounded,
          label: 'Minor Demerit');
    case '6':
      return const RewardStyle(
          color: Color(0xFFD0152A),
          bgColor: Color(0xFFFFF0F0),
          borderColor: Color(0xFFFFB3B3),
          icon: Icons.cancel_rounded,
          label: 'Major Demerit');
    default:
      return const RewardStyle(
          color: Color(0xFF6B7A99),
          bgColor: Color(0xFFEEF1F8),
          borderColor: Color(0xFFD0D7E8),
          icon: Icons.flag_rounded,
          label: 'Unknown');
  }
}

// ─── App Colors ───────────────────────────────────────────────────────────────

class AppColors {
  static const Color background = Color(0xFFF4F6FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF1A2B4A);
  static const Color textPrimary = Color(0xFF1A2B4A);
  static const Color textSecond = Color(0xFF6B7A99);
  static const Color divider = Color(0xFFE8ECF4);
  static const Color tagBg = Color(0xFFEEF1F8);
}
