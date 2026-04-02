// ─── Leave Card ───────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'employee_leaves_model.dart';

class LeaveCard extends StatelessWidget {
  final LeaveDto leave;
  const LeaveCard({Key? key, required this.leave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = getLeaveStyle(leave.holidayCode);
    final isNarrow = MediaQuery.of(context).size.width < 360;
    final days = leave.holidayQty / 8;
    final isMulti = leave.startDate.day != leave.endDate.day;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.divider),
        boxShadow: [
          BoxShadow(
              color: C.navy.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top accent ──
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: style.color,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: Leave type badge + duration pill ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
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
                          Text(leave.holidayName,
                              style: TextStyle(
                                  color: style.color,
                                  fontSize: isNarrow ? 10 : 12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Duration pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: C.navy,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            // days == days.roundToDouble()
                            //     ? '${days.toInt()} ${days == 1 ? 'Day' : 'Days'}'
                            //     : '${leave.holidayQty.toStringAsFixed(0)} Hrs',
                            days == days.roundToDouble()
                                ? '${days.toInt()} ${days == 1 ? 'Day' : 'Days'}'
                                : '${leave.holidayQty.toStringAsFixed(2)} Hrs', // ✅ FIX
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Row 2: Date range visual ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: C.divider),
                  ),
                  child: isMulti ? _multiDayRange(style) : _singleDay(style),
                ),

                const SizedBox(height: 12),

                // ── Row 3: Stats row ──
                Row(
                  children: [
                    Expanded(
                        child: _infoTile(
                      icon: Icons.tag_rounded,
                      label: 'CODE',
                      value: leave.holidayCode,
                      color: style.color,
                      bg: style.bgColor,
                    )),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _infoTile(
                      icon: Icons.hourglass_bottom_rounded,
                      label: 'HOURS',
                      // value: '${leave.holidayQty.toStringAsFixed(0)} hrs',

                      value: '${leave.holidayQty.toStringAsFixed(2)} hrs',
                      color: C.navy,
                      bg: C.tag,
                    )),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _infoTile(
                      icon: Icons.today_rounded,
                      label: 'DAYS',
                      value: days == days.roundToDouble()
                          ? '${days.toInt()} day${days > 1 ? 's' : ''}'
                          : '< 1 day',
                      color: C.navy,
                      bg: C.tag,
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Single day range ────────────────────────────────────────────────────────
  Widget _singleDay(LeaveTypeStyle style) {
    return Row(
      children: [
        Icon(Icons.calendar_today_rounded, size: 14, color: style.color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fmtDate(leave.startDate),
                  style: const TextStyle(
                      color: C.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text('${fmtTime(leave.startDate)}  –  ${fmtTime(leave.endDate)}',
                  style: const TextStyle(color: C.sub, fontSize: 11)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: style.bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: style.borderColor),
          ),
          child: Text('1 Day',
              style: TextStyle(
                  color: style.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  // ── Multi day range ─────────────────────────────────────────────────────────
  Widget _multiDayRange(LeaveTypeStyle style) {
    return Row(
      children: [
        // From
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('FROM',
                  style: TextStyle(
                      color: C.sub,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text(fmtDate(leave.startDate),
                  style: const TextStyle(
                      color: C.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(fmtTime(leave.startDate),
                  style: const TextStyle(color: C.sub, fontSize: 11)),
            ],
          ),
        ),
        // Arrow + days
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: style.bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: style.borderColor),
              ),
              child: Text(
                '${(leave.holidayQty / 8).toInt()}d',
                style: TextStyle(
                    color: style.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                    width: 20,
                    height: 1.5,
                    color: style.color.withOpacity(0.3)),
                Icon(Icons.arrow_forward_rounded, size: 14, color: style.color),
              ],
            ),
          ],
        ),
        // To
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('TO',
                  style: TextStyle(
                      color: C.sub,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text(fmtDate(leave.endDate),
                  style: const TextStyle(
                      color: C.text, fontSize: 12, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.right),
              const SizedBox(height: 2),
              Text(fmtTime(leave.endDate),
                  style: const TextStyle(color: C.sub, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Info tile ───────────────────────────────────────────────────────────────
  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 11, color: color.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7)),
          ]),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
