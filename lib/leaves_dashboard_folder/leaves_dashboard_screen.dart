import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api/apis_page.dart';
import '../screens/onboarding_screen/login_page.dart';

// ── Models ───────────────────────────────────────────────
class Leave {
  const Leave(this.name, this.hours, this.days, this.color);
  final String name;
  final double hours, days;
  final Color color;
}

class Department {
  const Department(this.no, this.name, this.hours, this.days);
  final String no, name;
  final double hours, days;
}

const _leaveColors = [
  Color(0xFF2196F3),
  Color(0xFF9C27B0),
  Color(0xFF4CAF50),
  Color(0xFFF44336),
  Color(0xFFFF9800),
];

List<Leave> _parseLeaves(List data) => List.generate(
    data.length,
    (i) => Leave(
          data[i]['holidaY_NAME'],
          double.parse(data[i]['totaL_HOLIDAY_QTY'].toString()),
          double.parse(data[i]['totaL_DAYS'].toString()),
          _leaveColors[i % _leaveColors.length],
        ));

List<Department> _parseDepts(List data) => data
    .map((d) => Department(
          d['depT_NO'] ?? '',
          d['depT_NAME'] ?? '',
          double.parse(d['totaL_HOLIDAY_QTY'].toString()),
          double.parse(d['totaL_DAYS'].toString()),
        ))
    .toList();

// ── Dashboard ─────────────────────────────────────────────
class LeavesDashboardScreen extends StatefulWidget {
  final LoginModelApi userData;
  const LeavesDashboardScreen({super.key, required this.userData});
  @override
  State<LeavesDashboardScreen> createState() => _LeavesDashboardScreenState();
}

class _LeavesDashboardScreenState extends State<LeavesDashboardScreen> {
  bool _showFilter = false;
  late DateTime _from, _to;
  final _now = DateTime.now();
  bool _isLoading = true;

  List<Leave> _allLeaves = [];
  List<Department> _allDepts = [];

  @override
  void initState() {
    super.initState();
    _setRange(7);
    _fetchData();
    // _setYesterday(); // ✅ only yesterday
  }

  void _setYesterday() {
    final yesterday = _now.subtract(const Duration(days: 1));

    setState(() {
      _from = yesterday;
      _to = yesterday;
      _showFilter = false;
    });

    _fetchData(); // ✅ API call with yesterday
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _isLoading = true);

      final startDate = _formatApiDate(_from);
      final endDate = _formatApiDate(_to);

      final url = Uri.parse(
          '${ApiHelper.baseUrl}get-leaves-data?startDate=$startDate&endDate=$endDate');
      // final url =
      //     'http://10.3.0.70:9042/api/HR/get-leaves-data?startDate=$startDate&endDate=$endDate';

      final response = await http.get(url);
      // print('API Response Status: ${response.statusCode}');
      // print('API Response Body: ${response.body}');
      // print(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        setState(() {
          _allLeaves = _parseLeaves(json['holidayData']);
          _allDepts = _parseDepts(json['topDepartments']);
          _isLoading = false; // ✅ IMPORTANT
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error: $e');
    }
  }

  String _formatApiDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  DateTime get _minDate => DateTime(_now.year - 1, _now.month, _now.day);
  void _setRange(int days) => setState(() {
        _to = _now;
        _from = _now.subtract(Duration(days: days - 1));
        _showFilter = false;
        // 👇 CALL API
        _fetchData();
      });

  Future<void> _pick(bool isFrom) async {
    final first = isFrom ? _minDate : _from;
    final last = isFrom
        ? _to
        : (_from.add(const Duration(days: 30)).isAfter(_now)
            ? _now
            : _from.add(const Duration(days: 30)));

    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: first,
      lastDate: last,
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to.difference(_from).inDays > 30) {
          _to = _from.add(const Duration(days: 30));
        }
      } else {
        _to = picked;
        _showFilter = false;
      }
    });

    // 🔥 CALL API AFTER DATE CHANGE
    await _fetchData();
  }

  double get _ratio => (_to.difference(_from).inDays + 1) / 365.0;

  List<Leave> get _leaves => _allLeaves
      .map((l) => Leave(l.name, l.hours * _ratio, l.days * _ratio, l.color))
      .toList();

  List<Department> get _depts => _allDepts
      .map((d) => Department(d.no, d.name, d.hours * _ratio, d.days * _ratio))
      .toList();

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    // 🔥 ADD HERE
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final leaves = _leaves;
    final depts = _depts;
    // 🔹 2. EMPTY STATE (SAFE)
    if (leaves.isEmpty || depts.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F4F8),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 50, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "No Data Available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    final totalHours = leaves.fold(0.0, (s, l) => s + l.hours);
    final totalDays = leaves.fold(0.0, (s, l) => s + l.days);
    // final maxDeptHrs = depts.first.hours;
    // final maxDeptHrs = depts.isNotEmpty ? depts.first.hours : 0.0;
    // ✅ Safe max value
    final sortedDepts = [...depts]..sort((a, b) => b.hours.compareTo(a.hours));

    final maxDeptHrs = sortedDepts.isNotEmpty ? sortedDepts.first.hours : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Filter Panel ────────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: _showFilter
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: _FilterPanel(
                from: _from,
                to: _to,
                onPickFrom: () => _pick(true),
                onPickTo: () => _pick(false),
                onQuick: _setRange,
                fmt: _fmt,
              ),
              secondChild: const SizedBox.shrink(),
            ),
            if (_showFilter) const SizedBox(height: 12),

            // ── Summary Cards ───────────────────────────────
            _Summary(
                totalHours: totalHours,
                totalDays: totalDays,
                types: leaves.length,
                range: '${_fmt(_from)} – ${_fmt(_to)}'),
            const SizedBox(height: 16),

            // ── Leave Distribution Chart ─────────────────────
            const _SectionLabel('Leave Distribution'),
            const SizedBox(height: 6),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(builder: (_, box) {
                  final wide = box.maxWidth > 420;
                  final chart = SizedBox(
                    width: 190,
                    height: 190,
                    child: CustomPaint(painter: _PiePainter(leaves, totalDays)),
                  );
                  final legend = _PieLegend(data: leaves, total: totalDays);
                  return wide
                      ? Row(children: [
                          chart,
                          const SizedBox(width: 24),
                          Expanded(child: legend)
                        ])
                      : Column(children: [
                          chart,
                          const SizedBox(height: 14),
                          legend
                        ]);
                }),
              ),
            ),
            const SizedBox(height: 16),

            // ── Leave Data Table ─────────────────────────────
            const _SectionLabel('Leave Details'),
            const SizedBox(height: 6),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              clipBehavior: Clip.antiAlias,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.4),
                  1: FlexColumnWidth(1.3),
                  2: FlexColumnWidth(1.1),
                },
                children: [
                  _tHead(['Leave Type', 'Leave Days', '% Share']),
                  ...leaves.map((l) => _leaveRow(l, totalDays)),
                  _tTotal(totalDays),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Top Departments ──────────────────────────────
            const _SectionLabel('Top Departments by Leave Hours'),
            const SizedBox(height: 6),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  children: depts
                      .asMap()
                      .entries
                      .map((e) => _DeptBar(
                          dept: e.value, rank: e.key + 1, max: maxDeptHrs))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ]),
        ),

        // 🔹 FLOATING FILTER BUTTON
        Positioned(
          top: 40,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B4F72),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _showFilter ? Icons.filter_list_off : Icons.filter_list,
                color: Colors.white,
              ),
              onPressed: () => setState(() => _showFilter = !_showFilter),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Dept Bar Row ─────────────────────────────────────────
class _DeptBar extends StatelessWidget {
  const _DeptBar({required this.dept, required this.rank, required this.max});
  final Department dept;
  final int rank;
  final double max;

  static const _rankColors = [
    Color(0xFFFFD700),
    Color(0xFFC0C0C0),
    Color(0xFFCD7F32),
  ];

  @override
  Widget build(BuildContext context) {
    final pct = dept.hours / max;
    final rankColor =
        rank <= 3 ? _rankColors[rank - 1] : const Color(0xFF1B4F72);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        // Rank badge
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text('$rank',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        // Name + bar
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(dept.name,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 6),
              Text('${dept.hours.toStringAsFixed(1)} hrs',
                  style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ]),
            const SizedBox(height: 3),
            LayoutBuilder(
                builder: (_, box) => Stack(children: [
                      Container(
                          height: 7,
                          width: box.maxWidth,
                          decoration: BoxDecoration(
                              color: const Color(0xFF1B4F72).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6))),
                      Container(
                          height: 7,
                          width: box.maxWidth * pct,
                          decoration: BoxDecoration(
                              color: const Color(0xFF1B4F72)
                                  .withOpacity(0.6 + 0.4 * pct),
                              borderRadius: BorderRadius.circular(6))),
                    ])),
          ]),
        ),
      ]),
    );
  }
}

// ── Filter Panel ──────────────────────────────────────────
class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.from,
    required this.to,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onQuick,
    required this.fmt,
  });
  final DateTime from, to;
  final VoidCallback onPickFrom, onPickTo;
  final void Function(int) onQuick;
  final String Function(DateTime) fmt;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 1,
        // color: const Color(0xFF1B4F72).withOpacity(0.05),
        color: Colors.white.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: const Color(0xFF1B4F72).withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Quick Select',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45)),
            const SizedBox(height: 8),
            Row(
                children: [7, 15, 30]
                    .map((d) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1B4F72),
                              side: const BorderSide(color: Color(0xFF1B4F72)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => onQuick(d),
                            child: Text('$d Days',
                                style: const TextStyle(fontSize: 12)),
                          ),
                        ))
                    .toList()),
            const SizedBox(height: 12),
            const Text('Custom Range',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: _DateBtn(
                      label: 'From', value: fmt(from), onTap: onPickFrom)),
              const SizedBox(width: 10),
              Expanded(
                  child:
                      _DateBtn(label: 'To', value: fmt(to), onTap: onPickTo)),
            ]),
            const SizedBox(height: 5),
            const Text('Max range: 30 days  •  Data scaled proportionally',
                style: TextStyle(fontSize: 10, color: Colors.black38)),
          ]),
        ),
      );
}

class _DateBtn extends StatelessWidget {
  const _DateBtn(
      {required this.label, required this.value, required this.onTap});
  final String label, value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1B4F72).withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today,
                size: 13, color: Color(0xFF1B4F72)),
            const SizedBox(width: 6),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(fontSize: 10, color: Colors.black45)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),
      );
}

// ── Summary ───────────────────────────────────────────────
class _Summary extends StatelessWidget {
  const _Summary(
      {required this.totalHours,
      required this.totalDays,
      required this.types,
      required this.range});
  final double totalHours, totalDays;
  final int types;
  final String range;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: _KpiCard('Total Hours', totalHours.toStringAsFixed(1),
                    Icons.access_time, const Color(0xFF1B4F72))),
            const SizedBox(width: 10),
            Expanded(
                child: _KpiCard('Total Days', totalDays.toStringAsFixed(1),
                    Icons.today, const Color(0xFF0D7377))),
            const SizedBox(width: 10),
            Expanded(
                child: _KpiCard('Leave Types', '$types', Icons.category,
                    const Color(0xFF7B1FA2))),
          ]),
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.date_range, size: 12, color: Colors.black38),
            const SizedBox(width: 4),
            Text('Showing: $range',
                style: const TextStyle(fontSize: 11, color: Colors.black45)),
          ]),
        ],
      );
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(this.label, this.value, this.icon, this.color);
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 10)),
          ]),
        ),
      );
}

// ── Pie Chart ─────────────────────────────────────────────
class _PiePainter extends CustomPainter {
  const _PiePainter(this.data, this.total);
  final List<Leave> data;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 4;
    double angle = -math.pi / 2;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 2;

    for (final l in data) {
      final sweep = (l.days / total) * 2 * math.pi;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), angle, sweep, true,
          Paint()..color = l.color);
      canvas.drawArc(
          Rect.fromCircle(center: c, radius: r), angle, sweep, true, stroke);
      angle += sweep;
    }
    canvas.drawCircle(c, r * 0.52, Paint()..color = Colors.white);

    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(children: [
        TextSpan(
            text: '${total.toStringAsFixed(0)}\n',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4F72))),
        const TextSpan(
            text: 'Total Days',
            style: TextStyle(fontSize: 9, color: Colors.grey)),
      ]),
    )..layout(maxWidth: r * 1.5);
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) =>
      old.total != total || old.data != data;
}

class _PieLegend extends StatelessWidget {
  const _PieLegend({required this.data, required this.total});
  final List<Leave> data;
  final double total;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.map((l) {
          final pct = l.days / total * 100;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                      color: l.color, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(l.name, style: const TextStyle(fontSize: 12))),
              Text('${pct.toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: l.color)),
            ]),
          );
        }).toList(),
      );
}

// ── Shared Helpers ────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4F72)));
}

Widget _cell(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    child: child);

// Leave table helpers
TableRow _tHead(List<String> cols) => TableRow(
      decoration: const BoxDecoration(color: Color(0xFF1B4F72)),
      children: cols
          .map((c) => _cell(Text(c,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12))))
          .toList(),
    );

TableRow _leaveRow(Leave l, double total) {
  final pct = l.days / total * 100;
  return TableRow(children: [
    _cell(Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: l.color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Expanded(child: Text(l.name, style: const TextStyle(fontSize: 12))),
    ])),
    _cell(
        Text(l.days.toStringAsFixed(2), style: const TextStyle(fontSize: 12))),
    _cell(Text('${pct.toStringAsFixed(1)}%',
        style: TextStyle(
            fontSize: 12, color: l.color, fontWeight: FontWeight.w600))),
  ]);
}

TableRow _tTotal(double days) => TableRow(
      decoration: const BoxDecoration(color: Color(0xFFE8F5E9)),
      children: [
        _cell(const Text('TOTAL',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        _cell(Text(days.toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        _cell(const Text('100.0%',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
      ],
    );

// Dept table helpers
TableRow _tHead2(List<String> cols) => TableRow(
      decoration: const BoxDecoration(color: Color(0xFF0D7377)),
      children: cols
          .map((c) => _cell(Text(c,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12))))
          .toList(),
    );

TableRow _deptRow(int rank, Department d) => TableRow(
      decoration: BoxDecoration(
          color: rank.isEven ? const Color(0xFFF5FAFA) : Colors.white),
      children: [
        _cell(Text('$rank',
            style: const TextStyle(fontSize: 12, color: Colors.black54))),
        _cell(Text(d.no,
            style: const TextStyle(fontSize: 11, color: Colors.black54))),
        _cell(Text(d.name, style: const TextStyle(fontSize: 12))),
        _cell(Text(d.hours.toStringAsFixed(2),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        _cell(Text(d.days.toStringAsFixed(2),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
      ],
    );
