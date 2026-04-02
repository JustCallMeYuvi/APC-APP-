
import 'package:flutter/material.dart';


import 'miss_punches_screen.dart';

class MissPunchesDayWidget extends StatefulWidget {
  final Day day;
  const MissPunchesDayWidget({super.key, required this.day});
  @override
  State<MissPunchesDayWidget> createState() => _MissPunchesDayWidgetState();
}

class _MissPunchesDayWidgetState extends State<MissPunchesDayWidget>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 220));
  late final Animation<double> _anim =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final (ac, _) = themeOf(day.punches.first.reason);
    final n = day.punches.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: [
        // Header
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Accent bar
            Container(
              width: 5,
              height: 72,
              decoration: BoxDecoration(
                color: ac,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 11, 10, 11),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(fDate(day.date),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B)),
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 6),
                      Text('$n ${n == 1 ? "event" : "events"}',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.5).animate(_anim),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 20, color: Color(0xFF94A3B8)),
                      ),
                    ]),
                    const SizedBox(height: 7),
                    Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: day.punches.map((p) {
                          final (c, bg) = p.theme;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: c.withOpacity(0.3)),
                            ),
                            child: Text(p.reason,
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: c)),
                          );
                        }).toList()),
                  ]),
            )),
          ]),
        ),

        // Expandable rows
        SizeTransition(
            sizeFactor: _anim,
            child: Column(children: [
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ...day.punches.asMap().entries.map((e) {
                final p = e.value;
                final last = e.key == day.punches.length - 1;
                final (c, bg) = p.theme;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(children: [
                          Container(
                            width: 26,
                            height: 26,
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                                color: bg,
                                shape: BoxShape.circle,
                                border: Border.all(color: c.withOpacity(0.4))),
                            child: Icon(Icons.access_time_rounded,
                                size: 12, color: c),
                          ),
                          if (!last)
                            Container(
                                width: 2,
                                height: 20,
                                color: const Color(0xFFE8EDF5)),
                        ]),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(p.reason,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: c)),
                                  const SizedBox(height: 2),
                                  Text(fTime(p.time),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B)),
                                      overflow: TextOverflow.ellipsis),
                                ])),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: c.withOpacity(0.3))),
                              child: Text(p.reason,
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: c),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                        )),
                      ]),
                );
              }),
              const SizedBox(height: 8),
            ])),
      ]),
    );
  }
}