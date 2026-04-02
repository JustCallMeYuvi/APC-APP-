import 'dart:convert';

import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api/apis_page.dart';
import 'miss_punches_card_widget.dart';
import 'miss_punches_day_widget.dart';
import 'miss_punches_no_data_widget.dart';

// ── Theme Registry (dynamic, built once) ──────────────────────────────────────

const _colors = [
  (Color(0xFFDC3545), Color(0xFFFFF0F0)),
  (Color(0xFF0D6EFD), Color(0xFFEFF6FF)),
  (Color(0xFF198754), Color(0xFFEFFFF4)),
  (Color(0xFF6F42C1), Color(0xFFF5F0FF)),
  (Color(0xFFE67E22), Color(0xFFFFF8F0)),
  (Color(0xFF0097A7), Color(0xFFE8FAFB)),
  (Color(0xFFAD1457), Color(0xFFFFF0F6)),
  (Color(0xFF37474F), Color(0xFFF3F4F5)),
];

final Map<String, (Color, Color)> _themeMap = {};
int _themeIdx = 0;

(Color, Color) themeOf(String reason) => _themeMap.putIfAbsent(
      reason,
      () => _colors[_themeIdx++ % _colors.length],
    );

// ── Models ────────────────────────────────────────────────────────────────────

class Day {
  final DateTime date;
  final List<Punch> punches;
  const Day(this.date, this.punches);
}

class Punch {
  final DateTime time;
  final String reason;
  const Punch(this.time, this.reason);
  (Color, Color) get theme => themeOf(reason);
}

// ── Parse once at startup ─────────────────────────────────────────────────────

// final List<String> _allReasons = _themeMap.keys.toList()..sort();
List<String> _allReasons = [];

// ── Formatters ────────────────────────────────────────────────────────────────

const _mo = [
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
];
const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String fDate(DateTime d) =>
    '${_wd[d.weekday - 1]}, ${d.day.toString().padLeft(2, '0')} ${_mo[d.month - 1]} ${d.year}';
String fShort(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_mo[d.month - 1]} ${d.year}';
String fTime(DateTime t) {
  int h = t.hour;
  final m = t.minute.toString().padLeft(2, '0');
  final ap = h >= 12 ? 'PM' : 'AM';
  h = h == 0
      ? 12
      : h > 12
          ? h - 12
          : h;
  return '${h.toString().padLeft(2, '0')}:$m $ap';
}

DateTime dOnly(DateTime d) => DateTime(d.year, d.month, d.day);

// ── Home Page ─────────────────────────────────────────────────────────────────

class MissPunchesScreen extends StatefulWidget {
  final LoginModelApi userData;
  const MissPunchesScreen({super.key, required this.userData});
  @override
  State<MissPunchesScreen> createState() => _MissPunchesScreenState();
}

class _MissPunchesScreenState extends State<MissPunchesScreen> {
  late DateTime _from, _to;
  String? _reason;

  @override
  void initState() {
    super.initState();
    _to = dOnly(DateTime.now());
    _from = _to.subtract(const Duration(days: 30));

    fetchMissPunches(); // 🔥 IMPORTANT
  }

  String formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  List<Day> _allDays = [];
  bool _isLoading = false;

  Future<void> fetchMissPunches({DateTime? fromDate, DateTime? toDate}) async {
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('${ApiHelper.baseUrl}get-miss-punches');

      final response = await http.get(
        Uri.parse(
          '${url.toString()}?empNo=${widget.userData.empNo}'
          // '&startDate=${_from.toIso8601String()}'
          // '&endDate=${_to.toIso8601String()}'),
          '&startDate=${formatDate(_from)}'
          '&endDate=${formatDate(_to)}',
        ),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        // setState(() {
        //   _allDays = data.map((e) {
        //     final date = DateTime.parse(e['mdate']);

        //     final punches = (e['records'] as List).map((r) {
        //       return Punch(
        //         // DateTime.parse(r['mtime']),
        //         DateTime.parse(r['mtime'].replaceFirst(' ', 'T')),
        //         (r['reason'] as String).toUpperCase(),
        //       );
        //     }).toList();

        //     return Day(date, punches);
        //   }).toList();
        // });

        setState(() {
          _allDays = data.map((e) {
            final date = DateTime.parse(e['mdate']);

            final punches = (e['records'] as List).map((r) {
              return Punch(
                DateTime.parse(r['mtime'].replaceFirst(' ', 'T')),
                (r['reason'] as String).toUpperCase(),
              );
            }).toList();

            return Day(date, punches);
          }).toList();

          // ✅ NEW CODE (IMPORTANT)
          _allReasons = _allDays
              .expand((d) => d.punches)
              .map((p) => p.reason)
              .toSet()
              .toList()
            ..sort();
        });
        print("URL: ${response.request?.url}");
      }
    } catch (e) {
      print("❌ ERROR: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Compute filtered list — O(n) single pass
  List<Day> get _filtered {
    final result = <Day>[];
    for (final day in _allDays) {
      final d = dOnly(day.date);
      if (d.isBefore(_from) || d.isAfter(_to)) continue;
      final punches = _reason == null
          ? day.punches
          : day.punches.where((p) => p.reason == _reason).toList();
      if (punches.isNotEmpty) result.add(Day(day.date, punches));
    }
    return result;
  }

  // Summary counts from filtered
  Map<String, int> _counts(List<Day> days) {
    final m = <String, int>{};
    for (final d in days)
      for (final p in d.punches) m[p.reason] = (m[p.reason] ?? 0) + 1;
    return m;
  }

  Future<void> _pick(bool isFrom) async {
    final p = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (c, w) => Theme(
        data: Theme.of(c).copyWith(
            colorScheme: const ColorScheme.light(
                primary: Color(0xFF1A3A6B), onPrimary: Colors.white)),
        child: w!,
      ),
    );
    if (p == null) return;
    setState(() {
      if (isFrom) {
        _from = p;
        if (_from.isAfter(_to)) _to = _from;
      } else {
        _to = p;
        if (_to.isBefore(_from)) _from = _to;
      }
    });
      fetchMissPunches(); // 🔥 MUST ADD THIS
  }

  // void _quick(int days) => setState(() {
  //       _to = dOnly(DateTime.now());
  //       _from = _to.subtract(Duration(days: days));
  //     });
  void _quick(int days) {
    setState(() {
      _to = dOnly(DateTime.now());
      _from = _to.subtract(Duration(days: days));
    });

    fetchMissPunches(); // 🔥 MUST ADD
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= 600;
    final hp = wide ? 20.0 : 12.0;
    final list = _filtered;
    final counts = _counts(list);
    final total = list.fold(0, (s, d) => s + d.punches.length);
    final span = _to.difference(_from).inDays + 1;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(children: [
              // ── Top bar
              Container(
                color: const Color(0xFF1A3A6B),
                padding: EdgeInsets.symmetric(horizontal: hp, vertical: 12),
                child: Row(children: [
                  const Icon(Icons.corporate_fare_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Employee Punch Exceptions',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                  _Pill('$span days', const Color(0xFF4ADE80)),
                ]),
              ),

              Expanded(
                  child: CustomScrollView(slivers: [
                // ── Date range panel
                SliverToBoxAdapter(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(hp, 14, hp, 0),
                  child: MissPunchesCardWidget(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        // Header
                        _SecHeader(
                            Icons.date_range_rounded, 'Date Range Filter',
                            trailing: _Pill(
                                '$span ${span == 1 ? "day" : "days"}',
                                const Color(0xFF1A3A6B))),
                        const SizedBox(height: 12),
                        // Date pickers
                        wide
                            ? Row(children: [
                                Expanded(
                                    child: _DateField('From', _from, true,
                                        () => _pick(true))),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Icon(Icons.arrow_forward_rounded,
                                        size: 15, color: Colors.grey[400])),
                                Expanded(
                                    child: _DateField(
                                        'To', _to, false, () => _pick(false))),
                              ])
                            : Column(children: [
                                _DateField('From Date', _from, true,
                                    () => _pick(true)),
                                const SizedBox(height: 8),
                                _DateField(
                                    'To Date', _to, false, () => _pick(false)),
                              ]),
                        const SizedBox(height: 12),
                        // Quick select
                        const Text('QUICK SELECT',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1)),
                        const SizedBox(height: 6),
                        Row(children: [
                          Expanded(child: _QBtn('7 Days', () => _quick(7))),
                          const SizedBox(width: 7),
                          Expanded(child: _QBtn('30 Days', () => _quick(30))),
                          const SizedBox(width: 7),
                          Expanded(child: _QBtn('90 Days', () => _quick(90))),
                        ]),
                      ])),
                )),

                // ── Summary
                SliverToBoxAdapter(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(hp, 12, hp, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: _StatBox(
                                  'Anomaly Days',
                                  '${list.length}',
                                  Icons.today_rounded,
                                  const Color(0xFF1A3A6B))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _StatBox(
                                  'Total Events',
                                  '$total',
                                  Icons.event_note_rounded,
                                  const Color(0xFF0A58CA))),
                        ]),
                        if (counts.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: wide ? 4 : 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: wide ? 2.4 : 2.1,
                            ),
                            itemCount: counts.length,
                            itemBuilder: (_, i) {
                              final e = counts.entries.elementAt(i);
                              final (c, bg) = themeOf(e.key);
                              return _ReasonBox(e.key, e.value, c, bg);
                            },
                          ),
                        ],
                      ]),
                )),

                // ── Filter chips
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 2),
                  child: SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: hp),
                        children: [null, ..._allReasons].map((r) {
                          final sel = r == _reason;
                          final (c, bg) = r != null
                              ? themeOf(r)
                              : (
                                  const Color(0xFF1A3A6B),
                                  const Color(0xFFEEF4FF)
                                );
                          return GestureDetector(
                            onTap: () => setState(() => _reason = r),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              margin: const EdgeInsets.only(right: 7),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 7),
                              decoration: BoxDecoration(
                                color: sel ? c : bg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: sel ? c : c.withOpacity(0.3)),
                              ),
                              // child: Text(r ?? 'All',
                              //     style: TextStyle(
                              //         fontSize: 11,
                              //         fontWeight: FontWeight.w700,
                              //         color: sel ? Colors.white : c)),
                              child: Text(
                                (r ?? 'All')
                                    .replaceAll('PUNCH', '')
                                    .replaceAll('_', ' ')
                                    .trim(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: sel ? Colors.white : c,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )),
                )),

                // ── List or No Data
                if (list.isEmpty)
                  const SliverFillRemaining(
                      hasScrollBody: false, child: MissPunchesNoDataWidget())
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hp, 6, hp, 28),
                    sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (_, i) => MissPunchesDayWidget(day: list[i]),
                      childCount: list.length,
                    )),
                  ),
              ])),
            ]),
          ),
          // 🔥 LOADING OVERLAY (FIXED)
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      );
}

class _SecHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const _SecHeader(this.icon, this.title, {this.trailing});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 15, color: const Color(0xFF1A3A6B)),
        const SizedBox(width: 7),
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3A6B)))),
        if (trailing != null) trailing!,
      ]);
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isStart;
  final VoidCallback onTap;
  const _DateField(this.label, this.date, this.isStart, this.onTap);
  @override
  Widget build(BuildContext context) {
    final c = isStart ? const Color(0xFF1A3A6B) : const Color(0xFF198754);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: c.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(
                isStart ? Icons.calendar_today_rounded : Icons.event_rounded,
                size: 15,
                color: c),
          ),
          const SizedBox(width: 9),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(fShort(date),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis),
              ])),
          Icon(Icons.edit_calendar_rounded, size: 13, color: Colors.grey[400]),
        ]),
      ),
    );
  }
}

class _QBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QBtn(this.label, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155)),
              overflow: TextOverflow.ellipsis),
        ),
      );
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBox(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B))),
                Text(label,
                    style:
                        const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis),
              ])),
        ]),
      );
}

class _ReasonBox extends StatelessWidget {
  final String reason;
  final int count;
  final Color color, bg;
  const _ReasonBox(this.reason, this.count, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(7)),
            child: Icon(Icons.fingerprint_rounded, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text('$count',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: color,
                        height: 1.1)),
                Text(reason,
                    style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ])),
        ]),
      );
}
