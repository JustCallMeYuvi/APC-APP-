
// ─── Disciplinary Card ────────────────────────────────────────────────────────

import 'package:animated_movies_app/disciplinary_folder/disciplinary_model.dart';
import 'package:flutter/material.dart';

class DisciplinaryCard extends StatelessWidget {
  final DisciplinaryDto data;
  const DisciplinaryCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final style = getRewardStyle(data.rewardCode);
    final style =
        getRewardStyle(data.rewardCode.replaceFirst(RegExp(r'^0+'), ''));
    final isNarrow = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: style.color,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
          ),

          // Badge + Date
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: style.bgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: style.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(style.icon, size: 13, color: style.color),
                      const SizedBox(width: 5),
                      Text(style.label,
                          style: TextStyle(
                              color: style.color,
                              fontSize: isNarrow ? 10 : 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 12, color: AppColors.textSecond),
                    const SizedBox(width: 4),
                    Text(data.disciplinaryDate,
                        style: const TextStyle(
                            color: AppColors.textSecond,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reason
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.notes_rounded,
                            size: 12, color: AppColors.textSecond),
                        SizedBox(width: 5),
                        Text('REASON',
                            style: TextStyle(
                                color: AppColors.textSecond,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0)),
                      ]),
                      const SizedBox(height: 6),
                      Text(data.reason,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Stats
                Row(
                  children: [
                    Expanded(
                        child: _statChip(
                      label: 'QUANTITY',
                      value: data.rewardQuantity,
                      icon: Icons.format_list_numbered_rounded,
                      color: style.color,
                      bg: style.bgColor,
                      border: style.borderColor,
                      isNarrow: isNarrow,
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statChip(
                      label: 'AMOUNT',
                      value: data.rewardAmount == '0'
                          ? '—'
                          : '₹${data.rewardAmount}',
                      icon: Icons.currency_rupee_rounded,
                      color: AppColors.primary,
                      bg: AppColors.tagBg,
                      border: AppColors.divider,
                      isNarrow: isNarrow,
                    )),
                  ],
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: style.color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Type Code: ${data.rewardCode}  •  ${style.label}',
                    style: TextStyle(
                        color: style.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
    required Color border,
    required bool isNarrow,
  }) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: color.withOpacity(0.65),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: isNarrow ? 13 : 15,
                        fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
