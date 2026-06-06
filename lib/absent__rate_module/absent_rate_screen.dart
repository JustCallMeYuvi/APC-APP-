import 'package:flutter/material.dart';
import 'attendance_report_model.dart';
import 'attendance_service.dart';

// ═══════════════════════════════════════════════════════════════
// FIELD DISPLAY NAME MAP  (source: Names.xlsx)
// ═══════════════════════════════════════════════════════════════
class FieldNames {
  // ── Date / Period ──────────────────────────────────────────
  static const date = 'Date';
  static const fromDate = 'From Date';
  static const toDate = 'To Date';
  static const workingDays = 'Working Days';

  // ── Employee Strength ──────────────────────────────────────
  static const totalStrength = 'Total Strength';
  static const activeEmployees = 'Active Employees';
  static const maleStrength = 'Male Strength';
  static const femaleStrength = 'Female Strength';
  static const presentToday = 'Present Today';

  // ── Absent Count ───────────────────────────────────────────
  static const maleAbsentDays = 'Male Absent (Days)';
  static const femaleAbsentDays = 'Female Absent (Days)';
  static const totalAbsentDays = 'Total Absent (Days)';

  // ── Absenteeism Rate % (of own gender) ─────────────────────
  static const maleAbsentRate = 'Male Absenteeism Rate (%)';
  static const femaleAbsentRate = 'Female Absenteeism Rate (%)';
  static const overallAbsentRate = 'Overall Absenteeism Rate (%)';

  // ── Absent Share % (of total workforce) ────────────────────
  static const maleAbsentShare = 'Male Absent Share (%)';
  static const femaleAbsentShare = 'Female Absent Share (%)';
  static const totalAbsentShare = 'Total Absent Share (%)';
}

// ═══════════════════════════════════════════════════════════════
// THEME
// ═══════════════════════════════════════════════════════════════
class T {
  static const Color navy = Color(0xFF0B1929);
  static const Color navyMid = Color(0xFF112240);
  static const Color navyLight = Color(0xFF1A3A6B);
  static const Color blue = Color(0xFF2D7FF9);
  static const Color blueGlow = Color(0xFF5BA4FF);
  static const Color teal = Color(0xFF00CFB4);
  static const Color amber = Color(0xFFFFB545);
  static const Color rose = Color(0xFFFF5472);
  static const Color pink = Color(0xFFFF4699);
  static const Color bg = Color(0xFFF4F6FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF0D1B2A);
  static const Color muted = Color(0xFF8392A5);
  static const Color border = Color(0xFFE4EAF4);
  static const Color maleC = Color(0xFF2D7FF9);
  static const Color femaleC = Color(0xFFFF4699);
  static const Color totalC = Color(0xFF00CFB4);
  static const Color holiday = Color(0xFFFFB545);
}

// ═══════════════════════════════════════════════════════════════
// RESPONSIVE HELPER
// ═══════════════════════════════════════════════════════════════
class RS {
  final double width;
  RS(this.width);

  bool get tiny => width < 360;
  bool get small => width >= 360 && width < 480;
  bool get mid => width >= 480 && width < 720;
  bool get wide => width >= 720;

  double get hPad => tiny
      ? 8
      : wide
          ? 28
          : 14;
  double get vPad => tiny ? 10 : 18;
  double get gap => tiny ? 8 : 12;
  double get cardP => tiny ? 12 : 18;

  double fontSize(double base) => tiny
      ? base * 0.82
      : small
          ? base * 0.9
          : base;
}

// ═══════════════════════════════════════════════════════════════
// DATA MODEL  — wraps AttendanceReportModel
// ═══════════════════════════════════════════════════════════════
class AR {
  final DateTime date;

  // Strength
  final int activeEmp;
  final int totalEmp;
  final int maleEmpCount;
  final int femaleEmpCount;
  final int presentEmp;

  // Absent counts
  final double maleAbsent;
  final double femaleAbsent;
  final double totalAbsent;

  // Absenteeism Rate % (of own gender)
  final double maleAbsentRate;
  final double femaleAbsentRate;
  final double totalAbsentRate;

  // Absent Share % (of total workforce) — used for chart/KPIs
  final double malePct;
  final double femalePct;
  final double totalPct;

  // Period (month-wise only)
  final String? fromDate;
  final String? toDate;
  final int totalWorkingDays;

  const AR({
    required this.date,
    required this.activeEmp,
    required this.totalEmp,
    required this.maleEmpCount,
    required this.femaleEmpCount,
    required this.presentEmp,
    required this.maleAbsent,
    required this.femaleAbsent,
    required this.totalAbsent,
    required this.maleAbsentRate,
    required this.femaleAbsentRate,
    required this.totalAbsentRate,
    required this.malePct,
    required this.femalePct,
    required this.totalPct,
    this.fromDate,
    this.toDate,
    this.totalWorkingDays = 0,
  });

  // bool get isHoliday => totalPct >= 95;
  bool get isHoliday => false;

  /// Factory from API model
  factory AR.fromApi(AttendanceReportModel e) {
    final rawDate = e.date.isNotEmpty ? e.date : (e.fromDate ?? '');
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(rawDate);
    } catch (_) {
      parsedDate = DateTime.now();
    }
    return AR(
      date: parsedDate,
      activeEmp: e.activeEmployees,
      totalEmp: e.totalEmployees,
      maleEmpCount: e.maleEmpCount,
      femaleEmpCount: e.femaleEmpCount,
      presentEmp: e.presentEmployees,
      maleAbsent: e.maleAbsentCount,
      femaleAbsent: e.femaleAbsentCount,
      totalAbsent: e.totalAbsentCount,
      maleAbsentRate: e.maleAbsentEmpPercentage,
      femaleAbsentRate: e.femaleAbsentEmpPercentage,
      totalAbsentRate: e.totalAbsentEmpPercentage,
      malePct: e.maleAbsentPercentage,
      femalePct: e.femaleAbsentPercentage,
      totalPct: e.totalAbsentPercentage,
      fromDate: e.fromDate,
      toDate: e.toDate,
      totalWorkingDays: e.totalWorkingDays,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════
const _months = [
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
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String fmtFull(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';
String fmtShort(DateTime d) => '${d.day} ${_months[d.month - 1]}';
String dayName(DateTime d) => _days[d.weekday - 1];

Color statusColor(double pct) {
  if (pct >= 95) return T.holiday;
  if (pct > 14) return T.rose;
  if (pct > 12) return T.amber;
  return T.teal;
}

// ═══════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════
class AbsentRateDashboard extends StatefulWidget {
  const AbsentRateDashboard({super.key});
  @override
  State<AbsentRateDashboard> createState() => _AbsentRateDashboardState();
}

class _AbsentRateDashboardState extends State<AbsentRateDashboard> {
  DateTime _from = DateTime.utc(DateTime.now().year, DateTime.now().month, 1);
  DateTime _to = DateTime.now().toUtc();
  String _viewMode = 'DAYWISE';
  bool _loading = false;
  String? _errorMsg;
  List<AR> _data = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      final result = await AttendanceService.getAttendanceReport(
        fromDate: _from,
        toDate: _to,
        type: _viewMode == 'DAYWISE' ? 'daywise' : 'monthwise',
      );
      setState(() {
        _data = result.map((e) => AR.fromApi(e)).toList();
        _loading = false;
      });
      print("TOTAL RECORDS = ${_data.length}");
      print("WORKING DAYS = ${_wd.length}");
      // Check exact API values
      for (final e in result) {
        debugPrint(
          'Date=${e.date} | '
          'Male=${e.maleAbsentPercentage} | '
          'Female=${e.femaleAbsentPercentage} | '
          'Total=${e.totalAbsentPercentage}',
        );
      }
      for (final r in _data) {
        debugPrint(
          'Date: ${r.date} | Total: ${r.totalPct} | Male: ${r.malePct} | Female: ${r.femalePct}',
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMsg = 'Failed to load data. Please check your connection.';
      });
    }
  }

  List<AR> get _shown => _data.where((r) => !r.isHoliday).toList();
  List<AR> get _wd => _data.where((r) => !r.isHoliday).toList();

  double _avg(double Function(AR) f) {
    final w = _wd;
    if (w.isEmpty) return 0;
    return w.map(f).reduce((a, b) => a + b) / w.length;
  }

  double _sum(double Function(AR) f) => _wd.fold(0.0, (s, r) => s + f(r));
  AR? _peak() {
    final w = _wd;
    return w.isEmpty
        ? null
        : w.reduce((a, b) => a.totalPct > b.totalPct ? a : b);
  }

  AR? _best() {
    final w = _wd;
    return w.isEmpty
        ? null
        : w.reduce((a, b) => a.totalPct < b.totalPct ? a : b);
  }

  // Future<void> _pickDate(bool isFrom) async {
  //   final d = await showDatePicker(
  //     context: context,
  //     initialDate: isFrom ? _from : _to,
  //     firstDate: DateTime.utc(2020, 1, 1),
  //     lastDate: DateTime.utc(2030, 12, 31),
  //     builder: (ctx, child) => Theme(
  //       data: Theme.of(ctx).copyWith(
  //         colorScheme: const ColorScheme.light(primary: T.blue),
  //       ),
  //       child: child!,
  //     ),
  //   );

  //   if (d != null) {
  //     setState(() {
  //       if (isFrom) {
  //         _from = d;

  //         // Maximum range = 31 days
  //         _to = d.add(const Duration(days: 30));
  //       } else {
  //         // Allow To Date only within 31 days from From Date
  //         final maxToDate = _from.add(const Duration(days: 30));

  //         if (d.isAfter(maxToDate)) {
  //           _to = maxToDate;
  //         } else {
  //           _to = d;
  //         }
  //       }
  //     });

  //     // _load();
  //   }
  // }
  Future<void> _pickDate(bool isFrom) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        if (isFrom) {
          _from = selected;

          // Keep To Date as today if selected From Date is before today
          if (_to.isBefore(_from)) {
            _to = DateTime.now();
          }
        } else {
          _to = selected;
        }
      });
    }
  }

  // Future<void> _pickToDate() async {
  //   final selected = await showDatePicker(
  //     context: context,
  //     initialDate: _to,
  //     firstDate: _from,
  //     lastDate: _from.add(const Duration(days: 30)),
  //   );

  //   if (selected != null) {
  //     setState(() {
  //       _to = selected;
  //     });
  //   }
  // }
  Future<void> _pickToDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _to,
      firstDate: _from,
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      final diff = selected.difference(_from).inDays;

      if (diff > 31) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Date range cannot exceed 31 days'),
          ),
        );
        return;
      }

      setState(() {
        _to = selected;
      });
    }
  }

  void _setRange(DateTime from, DateTime to) {
    setState(() {
      _from = from;
      _to = to;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final rs = RS(MediaQuery.of(context).size.width);
    final now = DateTime.now();
    final ranges = [
      // (
      //   'This Month',
      //   DateTime.utc(now.year, now.month, 1),
      //   DateTime.utc(now.year, now.month + 1, 0)
      // ),
      (
        'This Month',
        DateTime.utc(now.year, now.month, 1),
        now,
      ),
      (
        'Last Month',
        DateTime.utc(now.year, now.month - 1, 1),
        DateTime.utc(now.year, now.month, 0)
      ),
      ('Last 7d', now.subtract(const Duration(days: 7)), now),
      ('Last 30d', now.subtract(const Duration(days: 30)), now),
    ];

    return Scaffold(
      backgroundColor: T.bg,
      body: Column(
        children: [
          _Header(rs: rs),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: T.blue))
                : _errorMsg != null
                    ? _ErrorView(message: _errorMsg!, onRetry: _load, rs: rs)
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal: rs.hPad, vertical: rs.vPad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FilterCard(
                              rs: rs,
                              from: _from,
                              to: _to,
                              viewMode: _viewMode,
                              onFromTap: () => _pickDate(true),
                              // onToTap: () => _pickDate(false),
                              onToTap: _pickToDate,
                              onModeChanged: (m) {
                                setState(() => _viewMode = m!);
                                _load();
                              },
                              onRangeSelected: _setRange,
                              ranges: ranges, onSearch: _load,
                            ),
                            SizedBox(height: rs.gap),
                            // if (_data.isEmpty)
                            //   _EmptyState(rs: rs)
                            // else ...[
                            //   // _KPIRow(
                            //   //   rs: rs,
                            //   //   avgTotal: _avg((r) => r.totalPct),
                            //   //   avgMale: _avg((r) => r.malePct),
                            //   //   avgFemale: _avg((r) => r.femalePct),
                            //   //   avgTotalRate: _avg((r) => r.totalAbsentRate),
                            //   //   peak: _peak(),
                            //   //   best: _best(),
                            //   //   wdCount: _wd.length,
                            //   //   sumAbsent: _sum((r) => r.totalAbsent),
                            //   // ),

                            //   _KPIRow(
                            //     rs: rs,
                            //     avgTotal: _viewMode == 'DAYWISE'
                            //         ? (_peak()?.totalPct ?? 0)
                            //         : _avg((r) => r.totalPct),
                            //     avgMale: _viewMode == 'DAYWISE'
                            //         ? (_peak()?.malePct ?? 0)
                            //         : _avg((r) => r.malePct),
                            //     avgFemale: _viewMode == 'DAYWISE'
                            //         ? (_peak()?.femalePct ?? 0)
                            //         : _avg((r) => r.femalePct),
                            //     avgTotalRate: _viewMode == 'DAYWISE'
                            //         ? (_peak()?.totalAbsentRate ?? 0)
                            //         : _avg((r) => r.totalAbsentRate),
                            //     peak: _peak(),
                            //     best: _best(),
                            //     wdCount: _wd.length,
                            //     sumAbsent: _sum((r) => r.totalAbsent),
                            //   ),
                            //   SizedBox(height: rs.gap),
                            //   if (_viewMode == 'DAYWISE') ...[
                            //     _ChartCard(data: _shown, rs: rs),
                            //     SizedBox(height: rs.gap),
                            //     _TableCard(data: _shown, rs: rs),
                            //   ] else ...[
                            //     _OverallCard(wd: _wd, rs: rs),
                            //     SizedBox(height: rs.gap),
                            //     _GenderCard(
                            //       rs: rs,
                            //       avgMale: _avg((r) => r.malePct),
                            //       avgFemale: _avg((r) => r.femalePct),
                            //       avgTotal: _avg((r) => r.totalPct),
                            //       avgMaleRate: _avg((r) => r.maleAbsentRate),
                            //       avgFemaleRate:
                            //           _avg((r) => r.femaleAbsentRate),
                            //       avgTotalRate: _avg((r) => r.totalAbsentRate),
                            //       sumMale: _sum((r) => r.maleAbsent),
                            //       sumFemale: _sum((r) => r.femaleAbsent),
                            //     ),
                            //     SizedBox(height: rs.gap),
                            //     // overall absent rate ui not need ui
                            //     // _DayBarsCard(wd: _wd, rs: rs),
                            //   ],
                            // ],

                            if (_data.isEmpty)
                              _EmptyState(rs: rs)
                            else ...[
                              if (_viewMode != 'DAYWISE') ...[
                                _OverallCard(wd: _wd, rs: rs),
                                SizedBox(height: rs.gap),
                              ],
                              // if (_peak() != null)
                              if (_viewMode == 'DAYWISE' && _peak() != null)
                                Container(
                                  width: double.infinity,
                                  // padding: EdgeInsets.all(rs.cardP),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  margin: EdgeInsets.only(bottom: rs.gap),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFEF4444),
                                        Color(0xFFFF7A7A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Highest Absent Day',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              fmtFull(_peak()!.date),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Absent Rate: ${_peak()!.totalPct.toStringAsFixed(2)}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              _KPIRow(
                                rs: rs,
                                avgTotal: _viewMode == 'DAYWISE'
                                    ? (_peak()?.totalPct ?? 0)
                                    : _avg((r) => r.totalPct),
                                avgMale: _viewMode == 'DAYWISE'
                                    ? (_peak()?.malePct ?? 0)
                                    : _avg((r) => r.malePct),
                                avgFemale: _viewMode == 'DAYWISE'
                                    ? (_peak()?.femalePct ?? 0)
                                    : _avg((r) => r.femalePct),
                                avgTotalRate: _viewMode == 'DAYWISE'
                                    ? (_peak()?.totalAbsentRate ?? 0)
                                    : _avg((r) => r.totalAbsentRate),
                                peak: _peak(),
                                best: _best(),
                                wdCount: _wd.length,
                                sumAbsent: _sum((r) => r.totalAbsent),
                              ),
                              SizedBox(height: rs.gap),
                              if (_viewMode == 'DAYWISE') ...[
                                _ChartCard(data: _shown, rs: rs),
                                SizedBox(height: rs.gap),
                                _TableCard(data: _shown, rs: rs),
                              ] else ...[
                                _GenderCard(
                                  rs: rs,
                                  avgMale: _avg((r) => r.malePct),
                                  avgFemale: _avg((r) => r.femalePct),
                                  avgTotal: _avg((r) => r.totalPct),
                                  avgMaleRate: _avg((r) => r.maleAbsentRate),
                                  avgFemaleRate:
                                      _avg((r) => r.femaleAbsentRate),
                                  avgTotalRate: _avg((r) => r.totalAbsentRate),
                                  sumMale: _sum((r) => r.maleAbsent),
                                  sumFemale: _sum((r) => r.femaleAbsent),
                                ),
                              ],
                            ],
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final RS rs;
  const _Header({required this.rs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [T.navy, T.navyLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: rs.hPad + 4, vertical: rs.tiny ? 10 : 14),
          child: Row(
            children: [
              Container(
                width: rs.tiny ? 32 : 40,
                height: rs.tiny ? 32 : 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [T.blue, T.blueGlow]),
                  borderRadius: BorderRadius.circular(rs.tiny ? 8 : 10),
                  boxShadow: [
                    BoxShadow(
                        color: T.blue.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Icon(Icons.analytics_rounded,
                    color: Colors.white, size: rs.tiny ? 16 : 22),
              ),
              SizedBox(width: rs.tiny ? 8 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WORKFORCE ANALYTICS',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: rs.fontSize(rs.tiny ? 11 : 14),
                            fontWeight: FontWeight.w800,
                            letterSpacing: rs.tiny ? 1 : 2)),
                    Text('Absence Rate Report',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: rs.fontSize(rs.tiny ? 9 : 11),
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
              _Pill(label: '● LIVE', color: T.teal, tiny: rs.tiny),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ERROR / EMPTY STATES
// ═══════════════════════════════════════════════════════════════
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final RS rs;
  const _ErrorView(
      {required this.message, required this.onRetry, required this.rs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rs.hPad * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: T.rose, size: 48),
            const SizedBox(height: 16),
            Text(message,
                style: TextStyle(color: T.ink, fontSize: rs.fontSize(14)),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: T.blue),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final RS rs;
  const _EmptyState({required this.rs});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: rs.cardP,
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.inbox_rounded, color: T.muted, size: 48),
          const SizedBox(height: 12),
          Text('No records found for the selected date range.',
              style: TextStyle(color: T.muted, fontSize: rs.fontSize(13)),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FILTER CARD
// ═══════════════════════════════════════════════════════════════
class _FilterCard extends StatelessWidget {
  final RS rs;
  final DateTime from, to;
  final String viewMode;
  final VoidCallback onFromTap, onToTap;
  final ValueChanged<String?> onModeChanged;
  final void Function(DateTime, DateTime) onRangeSelected;
  final List<(String, DateTime, DateTime)> ranges;
  final VoidCallback onSearch;

  const _FilterCard({
    required this.rs,
    required this.from,
    required this.to,
    required this.viewMode,
    required this.onFromTap,
    required this.onToTap,
    required this.onModeChanged,
    required this.onRangeSelected,
    required this.ranges,
    required this.onSearch, // ADD THIS
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: rs.cardP,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.tune_rounded, size: 15, color: T.blue),
            const SizedBox(width: 6),
            Text('Report Filters',
                style: TextStyle(
                    fontSize: rs.fontSize(13),
                    fontWeight: FontWeight.w700,
                    color: T.ink)),
            const Spacer(),
            Text('${from.year}',
                style: TextStyle(fontSize: rs.fontSize(11), color: T.muted)),
          ]),
          SizedBox(height: rs.tiny ? 10 : 14),
          if (rs.wide)
            Row(children: [
              Expanded(
                  child: _DateBtn(
                      label: FieldNames.fromDate,
                      date: from,
                      onTap: onFromTap,
                      tiny: rs.tiny)),
              const SizedBox(width: 10),
              Expanded(
                  child: _DateBtn(
                      label: FieldNames.toDate,
                      date: to,
                      onTap: onToTap,
                      tiny: rs.tiny)),
              const SizedBox(width: 10),
              Expanded(
                  child: _ModeDropdown(
                      value: viewMode,
                      onChanged: onModeChanged,
                      tiny: rs.tiny)),
            ])
          else
            Column(children: [
              Row(children: [
                Expanded(
                    child: _DateBtn(
                        label: FieldNames.fromDate,
                        date: from,
                        onTap: onFromTap,
                        tiny: rs.tiny)),
                SizedBox(width: rs.gap),
                Expanded(
                    child: _DateBtn(
                        label: FieldNames.toDate,
                        date: to,
                        onTap: onToTap,
                        tiny: rs.tiny)),
              ]),
              SizedBox(height: rs.gap),
              _ModeDropdown(
                  value: viewMode, onChanged: onModeChanged, tiny: rs.tiny),
            ]),
          SizedBox(height: rs.tiny ? 10 : 14),
          Wrap(
            spacing: rs.tiny ? 6 : 8,
            runSpacing: rs.tiny ? 6 : 8,
            children: ranges.map((r) {
              return _Chip(
                label: r.$1,
                // active: from == r.$2 && to == r.$3,
                active: from.year == r.$2.year &&
                    from.month == r.$2.month &&
                    from.day == r.$2.day &&
                    to.year == r.$3.year &&
                    to.month == r.$3.month &&
                    to.day == r.$3.day,
                onTap: () => onRangeSelected(r.$2, r.$3),
                tiny: rs.tiny,
              );
            }).toList(),
          ),
          const SizedBox(height: 05),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSearch,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBtn extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  final bool tiny;
  const _DateBtn(
      {required this.label,
      required this.date,
      required this.onTap,
      required this.tiny});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: tiny ? 8 : 12, vertical: tiny ? 7 : 10),
        decoration: BoxDecoration(
          color: T.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: T.border),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_rounded,
              size: tiny ? 12 : 14, color: T.blue),
          SizedBox(width: tiny ? 5 : 8),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      fontSize: tiny ? 8 : 9,
                      color: T.muted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(tiny ? fmtShort(date) : fmtFull(date),
                  style: TextStyle(
                      fontSize: tiny ? 10 : 12,
                      fontWeight: FontWeight.w700,
                      color: T.ink),
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
          Icon(Icons.expand_more, size: tiny ? 13 : 16, color: T.muted),
        ]),
      ),
    );
  }
}

class _ModeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final bool tiny;
  const _ModeDropdown(
      {required this.value, required this.onChanged, required this.tiny});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: tiny ? 8 : 12, vertical: tiny ? 6 : 8),
      decoration: BoxDecoration(
        color: T.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: T.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('View Mode',
            style: TextStyle(
                fontSize: tiny ? 8 : 9,
                color: T.muted,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 2),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            isExpanded: true,
            style: TextStyle(
                fontSize: tiny ? 10 : 12,
                fontWeight: FontWeight.w700,
                color: T.ink),
            items: [
              DropdownMenuItem(
                  value: 'DAYWISE',
                  child: Row(children: [
                    Icon(Icons.view_day_rounded,
                        size: tiny ? 12 : 14, color: T.blue),
                    const SizedBox(width: 4),
                    const Text('DAY WISE'),
                  ])),
              DropdownMenuItem(
                  value: 'OVERALL',
                  child: Row(children: [
                    Icon(Icons.donut_large_rounded,
                        size: tiny ? 12 : 14, color: T.blue),
                    const SizedBox(width: 4),
                    const Text('OVERALL'),
                  ])),
            ],
            onChanged: onChanged,
          ),
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active, tiny;
  final VoidCallback onTap;
  const _Chip(
      {required this.label,
      required this.active,
      required this.onTap,
      required this.tiny});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: tiny ? 10 : 14, vertical: tiny ? 4 : 6),
        decoration: BoxDecoration(
          color: active ? T.blue : T.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? T.blue : T.border),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: tiny ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : T.muted,
            )),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// KPI ROW — labels use FieldNames
// ═══════════════════════════════════════════════════════════════
class _KPIRow extends StatelessWidget {
  final RS rs;
  final double avgTotal, avgMale, avgFemale, avgTotalRate, sumAbsent;
  final AR? peak, best;
  final int wdCount;

  const _KPIRow({
    required this.rs,
    required this.avgTotal,
    required this.avgMale,
    required this.avgFemale,
    required this.avgTotalRate,
    required this.peak,
    required this.best,
    required this.wdCount,
    required this.sumAbsent,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KD(
        icon: Icons.person_off_rounded,
        label: FieldNames.overallAbsentRate,
        // value: '${avgTotalRate.toStringAsFixed(2)}%',
        value: peak == null
            ? 'N/A'
            : '${peak!.totalPct.toStringAsFixed(2)}%', // peak data
        sub: '$wdCount ${FieldNames.workingDays.toLowerCase()}',
        g: [const Color(0xFFEF4444), const Color(0xFFFF7A7A)],
        badge: avgTotalRate > 13 ? 'HIGH' : 'NORMAL',
        badgeColor: avgTotalRate > 13 ? T.rose : T.teal,
      ),
      _KD(
        icon: Icons.man_2_rounded,
        label: FieldNames.maleAbsentShare,
        value: '${avgMale.toStringAsFixed(2)}%',
        sub: 'avg per working day',
        g: [const Color(0xFF2D7FF9), const Color(0xFF60AFFE)],
        badge: 'MALE',
        badgeColor: T.maleC,
      ),
      _KD(
        icon: Icons.woman_2_rounded,
        label: FieldNames.femaleAbsentShare,
        value: '${avgFemale.toStringAsFixed(2)}%',
        sub: 'avg per working day',
        g: [const Color(0xFFFF4699), const Color(0xFFFF85BF)],
        badge: 'FEMALE',
        badgeColor: T.femaleC,
      ),
      // _KD(
      //   icon: Icons.trending_up_rounded,
      //   label: 'Peak Day',
      //   value: peak == null ? 'N/A' : '${peak!.totalPct.toStringAsFixed(2)}%',
      //   sub: peak == null
      //       ? '-'
      //       : '${fmtShort(peak!.date)} (${dayName(peak!.date)})',
      //   g: [const Color(0xFFFFB545), const Color(0xFFFFD080)],
      //   badge: '↑ WORST',
      //   badgeColor: T.amber,
      // ),
    ];

    if (rs.wide) {
      return Row(
        children: cards
            .asMap()
            .entries
            .map((e) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: e.key < cards.length - 1 ? rs.gap : 0),
                    child: _KPICard(data: e.value, rs: rs),
                  ),
                ))
            .toList(),
      );
    }

    return Column(children: [
      _KPICard(data: cards[0], rs: rs),

      // Row(children: [
      //   Expanded(child: _KPICard(data: cards[0], rs: rs)),
      //   SizedBox(width: rs.gap),
      //   Expanded(child: _KPICard(data: cards[1], rs: rs)),
      // ]),
      SizedBox(height: rs.gap),

      Row(
        children: [
          Expanded(child: _KPICard(data: cards[1], rs: rs)),
          SizedBox(width: rs.gap), // Space between cards
          Expanded(child: _KPICard(data: cards[2], rs: rs)),
          // _KPICard(data: cards[2], rs: rs),
        ],
      ),
    ]);
  }
}

class _KD {
  final IconData icon;
  final String label, value, sub, badge;
  final List<Color> g;
  final Color badgeColor;
  const _KD({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.g,
    required this.badge,
    required this.badgeColor,
  });
}

class _KPICard extends StatelessWidget {
  final _KD data;
  final RS rs;
  const _KPICard({required this.data, required this.rs});

  @override
  Widget build(BuildContext context) {
    final valueFontSize = rs.tiny
        ? 16.0
        : rs.small
            ? 18.0
            : 22.0;
    return Container(
      padding: EdgeInsets.all(rs.tiny ? 10 : 16),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.g[0].withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: data.g[0].withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: rs.tiny ? 28 : 36,
            height: rs.tiny ? 28 : 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: data.g),
              borderRadius: BorderRadius.circular(rs.tiny ? 8 : 10),
            ),
            child:
                Icon(data.icon, color: Colors.white, size: rs.tiny ? 14 : 18),
          ),
          const Spacer(),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: rs.tiny ? 5 : 7, vertical: 3),
            decoration: BoxDecoration(
              color: data.badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(data.badge,
                style: TextStyle(
                    fontSize: rs.tiny ? 7 : 9,
                    fontWeight: FontWeight.w800,
                    color: data.badgeColor,
                    letterSpacing: 0.3)),
          ),
        ]),
        SizedBox(height: rs.tiny ? 8 : 12),
        Text(data.value,
            style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.w900,
                color: data.g[0],
                letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(data.label,
            style: TextStyle(
                fontSize: rs.fontSize(12),
                fontWeight: FontWeight.w700,
                color: T.ink),
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(data.sub,
            style: TextStyle(fontSize: rs.fontSize(10), color: T.muted),
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CHART CARD
// ═══════════════════════════════════════════════════════════════
class _ChartCard extends StatelessWidget {
  final List<AR> data;
  final RS rs;
  const _ChartCard({required this.data, required this.rs});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: rs.cardP,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.show_chart_rounded, size: 16, color: T.blue),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Absence Rate Trend',
                  style: TextStyle(
                      fontSize: rs.fontSize(14),
                      fontWeight: FontWeight.w800,
                      color: T.ink))),
          if (!rs.tiny) ...[
            const _LegendItem('Total', T.totalC),
            const SizedBox(width: 8),
            const _LegendItem('Male', T.maleC),
            const SizedBox(width: 8),
            const _LegendItem('Female', T.femaleC),
          ],
        ]),
        if (rs.tiny) ...[
          const SizedBox(height: 6),
          const Wrap(spacing: 8, children: [
            _LegendItem('Total', T.totalC),
            _LegendItem('Male', T.maleC),
            _LegendItem('Female', T.femaleC),
          ]),
        ],
        SizedBox(height: rs.tiny ? 4 : 6),
        Text('${FieldNames.totalAbsentShare} by gender — day wise',
            style: TextStyle(fontSize: rs.fontSize(11), color: T.muted)),
        SizedBox(height: rs.tiny ? 10 : 16),
        data.isEmpty
            ? SizedBox(
                height: 120,
                child: Center(
                    child: Text('No data',
                        style: TextStyle(
                            color: T.muted, fontSize: rs.fontSize(12)))))
            : SizedBox(
                height: rs.tiny
                    ? 160
                    : rs.small
                        ? 190
                        : 230,
                child: CustomPaint(
                  painter: _ChartPainter(data: data, tiny: rs.tiny),
                  size: Size.infinite,
                ),
              ),
      ]),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 14,
          height: 3,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(
              fontSize: 10, color: T.muted, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _ChartPainter extends CustomPainter {
  final List<AR> data;
  final bool tiny;
  const _ChartPainter({required this.data, required this.tiny});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final lp = size.width < 250 ? 30.0 : 46.0;
    final bp = tiny ? 28.0 : 38.0;
    const tp = 16.0;
    final rp = tiny ? 6.0 : 12.0;
    final area = Rect.fromLTRB(lp, tp, size.width - rp, size.height - bp);

    // const yMin = 8.0;
    // const yMax = 20.0;
    const yMin = 0.0;
    const yMax = 20.0;

    final gp = Paint()
      ..color = T.border
      ..strokeWidth = 0.8;
    final ls = TextStyle(fontSize: tiny ? 8.0 : 9.0, color: T.muted);

    for (var i = 0; i <= 4; i++) {
      final y = area.bottom - (i / 4) * area.height;
      final val = yMin + (i / 4) * (yMax - yMin);
      canvas.drawLine(Offset(area.left, y), Offset(area.right, y), gp);
      _paintText(canvas, '${val.toStringAsFixed(0)}%', ls,
          Offset(area.left - (tiny ? 26 : 38), y - 5),
          width: tiny ? 24 : 34, align: TextAlign.right);
    }

    double tx(int i) => data.length == 1
        ? area.left + area.width / 2
        : area.left + (i / (data.length - 1)) * area.width;

    double ty(double pct) {
      if (pct >= 95) return area.top;
      return area.bottom -
          ((pct.clamp(yMin, yMax) - yMin) / (yMax - yMin)) * area.height;
    }

    void drawFill(List<double> vals, Color c) {
      final path = Path();
      bool started = false;
      int? fi, li;
      for (var i = 0; i < data.length; i++) {
        if (data[i].isHoliday) {
          started = false;
          continue;
        }
        final x = tx(i);
        final y = ty(vals[i]);
        if (!started) {
          path.moveTo(x, y);
          fi = i;
          started = true;
        } else {
          path.lineTo(x, y);
        }
        li = i;
      }
      if (fi != null && li != null) {
        path.lineTo(tx(li), area.bottom);
        path.lineTo(tx(fi), area.bottom);
        path.close();
      }
      canvas.drawPath(
          path,
          Paint()
            ..shader = LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [c.withOpacity(0.18), c.withOpacity(0.01)])
                .createShader(area)
            ..style = PaintingStyle.fill);
    }

    void drawLine(List<double> vals, Color c) {
      final path = Path();
      bool started = false;
      for (var i = 0; i < data.length; i++) {
        if (data[i].isHoliday) {
          started = false;
          continue;
        }
        final x = tx(i);
        final y = ty(vals[i]);
        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = c
            ..strokeWidth = tiny ? 1.6 : 2.2
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }

    final tot = data.map((r) => r.totalPct).toList();
    final mal = data.map((r) => r.malePct).toList();
    final fem = data.map((r) => r.femalePct).toList();

    drawFill(tot, T.totalC);
    drawLine(fem, T.femaleC);
    drawLine(mal, T.maleC);
    drawLine(tot, T.totalC);

    final step = (data.length / (tiny ? 4 : 7)).ceil().clamp(1, 99);
    final dotP = Paint()..style = PaintingStyle.fill;
    final dotOuter = tiny ? 3.0 : 4.0;
    final dotInner = tiny ? 2.0 : 3.0;

    for (var i = 0; i < data.length; i++) {
      final r = data[i];
      final x = tx(i);
      if (r.isHoliday) {
        canvas.drawLine(
            Offset(x, area.top),
            Offset(x, area.bottom),
            Paint()
              ..color = T.holiday.withOpacity(0.4)
              ..strokeWidth = 1.2
              ..style = PaintingStyle.stroke);
        if (!tiny) _paintText(canvas, '🏖', ls, Offset(x - 6, area.top - 14));
      } else {
        for (final (pct, c) in [
          (r.totalPct, T.totalC),
          (r.malePct, T.maleC),
          (r.femalePct, T.femaleC)
        ]) {
          final y = ty(pct);
          dotP.color = Colors.white;
          canvas.drawCircle(Offset(x, y), dotOuter, dotP);
          dotP.color = c;
          canvas.drawCircle(Offset(x, y), dotInner, dotP);
        }
      }
      if (i % step == 0 || i == data.length - 1) {
        _paintText(
            canvas,
            fmtShort(r.date),
            TextStyle(fontSize: tiny ? 8.0 : 9.0, color: T.muted),
            Offset(x - 14, area.bottom + 5),
            width: 28,
            align: TextAlign.center);
      }
    }

    final ap = Paint()
      ..color = T.border
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(area.left, area.top), Offset(area.left, area.bottom), ap);
    canvas.drawLine(
        Offset(area.left, area.bottom), Offset(area.right, area.bottom), ap);
  }

  void _paintText(Canvas canvas, String text, TextStyle style, Offset offset,
      {double width = 60, TextAlign align = TextAlign.left}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: width);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_ChartPainter o) => o.data != data || o.tiny != tiny;
}

// ═══════════════════════════════════════════════════════════════
// DATA TABLE — columns use FieldNames
// ═══════════════════════════════════════════════════════════════
class _TableCard extends StatefulWidget {
  final List<AR> data;
  final RS rs;
  const _TableCard({required this.data, required this.rs});
  @override
  State<_TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<_TableCard> {
  int? _sel;

  // List<String> get _headers {
  //   final rs = widget.rs;
  //   if (rs.tiny) return [FieldNames.date, 'Total %', 'Status'];
  //   if (rs.wide) {
  //     return [
  //       FieldNames.date,
  //       'Day',
  //       FieldNames.activeEmployees,
  //       FieldNames.totalStrength,
  //       FieldNames.presentToday,
  //       FieldNames.totalAbsentDays,
  //       FieldNames.maleAbsentRate,
  //       FieldNames.femaleAbsentRate,
  //       FieldNames.overallAbsentRate,
  //       'Status',
  //     ];
  //   }
  //   return [
  //     FieldNames.date,
  //     'Day',
  //     FieldNames.totalAbsentDays,
  //     FieldNames.maleAbsentShare,
  //     FieldNames.femaleAbsentShare,
  //     FieldNames.totalAbsentShare,
  //   ];
  // }

  List<String> get _headers {
    final rs = widget.rs;

    if (rs.tiny) {
      return [
        FieldNames.date,
        'Total %',
        'Status',
      ];
    }

    return [
      FieldNames.date,
      'Day',
      FieldNames.totalAbsentDays,
      FieldNames.maleAbsentShare,
      FieldNames.femaleAbsentShare,
      FieldNames.totalAbsentShare,
    ];
  }

  // List<String> _rowCells(AR r) {
  //   final rs = widget.rs;
  //   if (rs.tiny) {
  //     return [
  //       fmtShort(r.date),
  //       '${r.totalPct.toStringAsFixed(1)}%',
  //       r.isHoliday
  //           ? 'HOL'
  //           : r.totalAbsentRate > 14
  //               ? 'HIGH'
  //               : 'OK',
  //     ];
  //   }
  //   if (rs.wide) {
  //     return [
  //       fmtShort(r.date),
  //       dayName(r.date),
  //       r.activeEmp.toString(),
  //       r.totalEmp == 0 ? '-' : r.totalEmp.toString(),
  //       r.presentEmp.toString(),
  //       r.totalAbsent.toStringAsFixed(0),
  //       '${r.maleAbsentRate.toStringAsFixed(1)}%',
  //       '${r.femaleAbsentRate.toStringAsFixed(1)}%',
  //       '${r.totalAbsentRate.toStringAsFixed(2)}%',
  //       r.isHoliday
  //           ? 'HOLIDAY'
  //           : r.totalAbsentRate > 14
  //               ? 'HIGH'
  //               : 'NORMAL',
  //     ];
  //   }
  //   return [
  //     fmtShort(r.date),
  //     dayName(r.date),
  //     r.totalAbsent.toStringAsFixed(0),
  //     '${r.malePct.toStringAsFixed(1)}%',
  //     '${r.femalePct.toStringAsFixed(1)}%',
  //     '${r.totalPct.toStringAsFixed(2)}%',
  //   ];
  // }

  List<String> _rowCells(AR r) {
    final rs = widget.rs;

    if (rs.tiny) {
      return [
        fmtShort(r.date),
        '${r.totalPct.toStringAsFixed(1)}%',
        r.isHoliday
            ? 'HOL'
            : r.totalPct > 14
                ? 'HIGH'
                : 'OK',
      ];
    }

    return [
      fmtShort(r.date),
      dayName(r.date),
      r.totalAbsent.toStringAsFixed(0),
      // '${r.malePct.toStringAsFixed(1)}%',
      // '${r.femalePct.toStringAsFixed(1)}%',
      // '${r.totalPct.toStringAsFixed(2)}%',
      // '${r.malePct}%',
      // '${r.femalePct}%',
      // '${r.totalPct}%',
      '${r.malePct.toString()}%',
      '${r.femalePct.toString()}%',
      '${r.totalPct.toString()}%',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final rs = widget.rs;
    return _Card(
      padding: rs.cardP,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.table_rows_rounded, size: 15, color: T.blue),
          const SizedBox(width: 6),
          Text('Daily Breakdown',
              style: TextStyle(
                  fontSize: rs.fontSize(14),
                  fontWeight: FontWeight.w800,
                  color: T.ink)),
          const Spacer(),
          _Pill(label: '${d.length} Records', color: T.blue, tiny: rs.tiny),
        ]),
        SizedBox(height: rs.tiny ? 10 : 14),
        _TRow(
            cells: _headers,
            isHeader: true,
            isLast: false,
            isHoliday: false,
            statusColor: null,
            tiny: rs.tiny),
        const Divider(height: 1, color: T.border),
        ...d.asMap().entries.map((e) {
          final i = e.key;
          final r = e.value;
          final sel = _sel == i;
          // final sc = statusColor(r.totalAbsentRate);
          final sc = statusColor(r.totalPct);
          return Column(children: [
            GestureDetector(
              onTap: () => setState(() => _sel = sel ? null : i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: r.isHoliday
                      ? T.holiday.withOpacity(0.06)
                      : sel
                          ? T.blue.withOpacity(0.05)
                          : i.isEven
                              ? const Color(0xFFF8FAFC)
                              : Colors.transparent,
                  border: sel
                      ? const Border(left: BorderSide(color: T.blue, width: 3))
                      : null,
                ),
                child: _TRow(
                  cells: _rowCells(r),
                  isHeader: false,
                  isLast: true,
                  isHoliday: r.isHoliday,
                  statusColor: sc,
                  tiny: rs.tiny,
                ),
              ),
            ),
            const Divider(
                height: 1, color: T.border, indent: 10, endIndent: 10),
          ]);
        }),
        SizedBox(height: rs.tiny ? 6 : 8),
        if (!rs.tiny)
          const Wrap(spacing: 12, runSpacing: 4, children: [
            _TLegend(color: T.teal, label: 'Normal (<12%)'),
            _TLegend(color: T.amber, label: 'Moderate (12–14%)'),
            _TLegend(color: T.rose, label: 'High (>14%)'),
            _TLegend(color: T.holiday, label: 'Holiday'),
          ]),
      ]),
    );
  }
}

class _TRow extends StatelessWidget {
  final List<String> cells;
  final bool isHeader, isLast, isHoliday, tiny;
  final Color? statusColor;
  const _TRow({
    required this.cells,
    required this.isHeader,
    required this.isLast,
    required this.isHoliday,
    required this.statusColor,
    required this.tiny,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: tiny ? 8 : 12, vertical: tiny ? 7 : 10),
      child: Row(
        children: cells.asMap().entries.map((e) {
          final i = e.key;
          final cell = e.value;
          final isStatusCol = isLast && i == cells.length - 1;
          Color textColor = isHeader ? T.muted : T.ink;
          if (!isHeader && isHoliday) textColor = T.holiday;
          if (isStatusCol && statusColor != null) textColor = statusColor!;
          final flex = i == 0 ? 2 : 1;

          return Expanded(
            flex: flex,
            child: isStatusCol && !isHeader
                ? Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: tiny ? 4 : 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(cell,
                        style: TextStyle(
                            fontSize: tiny ? 8 : 10,
                            fontWeight: FontWeight.w800,
                            color: textColor),
                        textAlign: TextAlign.center),
                  )
                : Text(cell,
                    style: TextStyle(
                      fontSize: isHeader ? (tiny ? 8 : 10) : (tiny ? 9 : 12),
                      fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
                      letterSpacing: isHeader ? 0.4 : 0,
                    ),
                    textAlign: i == 0 ? TextAlign.left : TextAlign.center,
                    overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ),
    );
  }
}

class _TLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _TLegend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: T.muted)),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
// OVERALL VIEW — uses FieldNames throughout
// ═══════════════════════════════════════════════════════════════
class _OverallCard extends StatelessWidget {
  final List<AR> wd;
  final RS rs;
  const _OverallCard({required this.wd, required this.rs});

  @override
  Widget build(BuildContext context) {
    if (wd.isEmpty) {
      return _Card(
        padding: rs.cardP,
        child: Center(
            child: Text('No working day data',
                style: TextStyle(color: T.muted, fontSize: rs.fontSize(12)))),
      );
    }

    final sumAbsent = wd.fold(0.0, (s, r) => s + r.totalAbsent);
    final sumPresent = wd.fold(0.0, (s, r) => s + r.presentEmp.toDouble());
    final total = sumAbsent + sumPresent;
    final presPct = total > 0 ? sumPresent / total : 0.0;
    final absPct = 1 - presPct;
    final avgAbs = sumAbsent / wd.length;
    final peak =
        wd.reduce((a, b) => a.totalAbsentRate > b.totalAbsentRate ? a : b);
    final best =
        wd.reduce((a, b) => a.totalAbsentRate < b.totalAbsentRate ? a : b);

    // Period info from first record
    final firstRec = wd.first;
    final periodLabel = firstRec.fromDate != null && firstRec.toDate != null
        ? '${firstRec.fromDate} → ${firstRec.toDate}'
        : null;
    final wdLabel = firstRec.totalWorkingDays > 0
        ? '${firstRec.totalWorkingDays} ${FieldNames.workingDays}'
        : '${wd.length} days';

    return _Card(
      padding: rs.cardP,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.summarize_rounded, size: 15, color: T.blue),
          const SizedBox(width: 6),
          Text('Overall Summary',
              style: TextStyle(
                  fontSize: rs.fontSize(14),
                  fontWeight: FontWeight.w800,
                  color: T.ink)),
          const Spacer(),
          _Pill(label: wdLabel, color: T.blue, tiny: rs.tiny),
        ]),
        if (periodLabel != null) ...[
          const SizedBox(height: 6),
          Text(periodLabel,
              style: TextStyle(fontSize: rs.fontSize(11), color: T.muted)),
        ],
        // SizedBox(height: rs.tiny ? 14 : 20),
        // _ProgressBar(
        //   label: 'Attendance Rate',
        //   pct: presPct,
        //   color: T.teal,
        //   leftText:
        //       '${(presPct * 100).toStringAsFixed(1)}% ${FieldNames.presentToday}',
        //   rightText:
        //       '${(absPct * 100).toStringAsFixed(1)}% ${FieldNames.totalAbsentDays}',
        //   tiny: rs.tiny,
        // ),
        // SizedBox(height: rs.tiny ? 14 : 20),
        // if (rs.wide)
        //   Row(children: [
        //     _OStat(FieldNames.totalAbsentDays, sumAbsent.toStringAsFixed(0),
        //         T.rose, rs),
        //     _OStat(FieldNames.presentToday, sumPresent.toStringAsFixed(0),
        //         T.teal, rs),
        //     _OStat('Avg Daily', avgAbs.toStringAsFixed(0), T.amber, rs),
        //     _OStat(
        //         'Peak',
        //         '${peak.totalAbsentRate.toStringAsFixed(1)}%\n${fmtShort(peak.date)}',
        //         T.rose,
        //         rs),
        //     _OStat(
        //         'Best',
        //         '${best.totalAbsentRate.toStringAsFixed(1)}%\n${fmtShort(best.date)}',
        //         T.teal,
        //         rs),
        //   ])
        // else
        //   Wrap(children: [
        //     _OStat(FieldNames.totalAbsentDays.split(' ').first,
        //         sumAbsent.toStringAsFixed(0), T.rose, rs),
        //     _OStat(FieldNames.presentToday.split(' ').first,
        //         sumPresent.toStringAsFixed(0), T.teal, rs),
        //     _OStat('Avg/Day', avgAbs.toStringAsFixed(0), T.amber, rs),
        //     _OStat('Peak', '${peak.totalAbsentRate.toStringAsFixed(1)}%',
        //         T.rose, rs),
        //     _OStat('Best', '${best.totalAbsentRate.toStringAsFixed(1)}%',
        //         T.teal, rs),
        //   ]),
      ]),
    );
  }
}

class _OStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final RS rs;
  const _OStat(this.label, this.value, this.color, this.rs);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: rs.tiny ? 70 : 90,
      margin: const EdgeInsets.all(4),
      child: Column(children: [
        Text(value,
            style: TextStyle(
                fontSize: rs.tiny ? 13 : 18,
                fontWeight: FontWeight.w900,
                color: color),
            textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(fontSize: rs.tiny ? 8 : 10, color: T.muted),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final RS rs;
  final double avgMale, avgFemale, avgTotal;
  final double avgMaleRate, avgFemaleRate, avgTotalRate;
  final double sumMale, sumFemale;
  const _GenderCard({
    required this.rs,
    required this.avgMale,
    required this.avgFemale,
    required this.avgTotal,
    required this.avgMaleRate,
    required this.avgFemaleRate,
    required this.avgTotalRate,
    required this.sumMale,
    required this.sumFemale,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: rs.cardP,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.people_alt_rounded, size: 15, color: T.blue),
          const SizedBox(width: 6),
          Text('Gender Analysis',
              style: TextStyle(
                  fontSize: rs.fontSize(14),
                  fontWeight: FontWeight.w800,
                  color: T.ink)),
        ]),
        SizedBox(height: rs.tiny ? 10 : 14),

        // Absenteeism Rate % section
        Text(
          'Absenteeism Rate (% of own gender)',
          style: TextStyle(
              fontSize: rs.fontSize(11),
              color: T.muted,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: rs.tiny ? 8 : 10),
        _GBar(FieldNames.maleAbsentRate, avgMaleRate, T.maleC,
            sumMale.toStringAsFixed(0), rs),
        SizedBox(height: rs.tiny ? 8 : 12),
        _GBar(FieldNames.femaleAbsentRate, avgFemaleRate, T.femaleC,
            sumFemale.toStringAsFixed(0), rs),
        SizedBox(height: rs.tiny ? 8 : 12),
        _GBar(FieldNames.overallAbsentRate, avgTotalRate, T.totalC,
            (sumMale + sumFemale).toStringAsFixed(0), rs),

        const Divider(color: T.border, height: 24),

        // Absent Share % section
        Text(
          'Absent Share (% of total workforce)',
          style: TextStyle(
              fontSize: rs.fontSize(11),
              color: T.muted,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: rs.tiny ? 8 : 10),
        _GBar(FieldNames.maleAbsentShare, avgMale, T.maleC, '-', rs),
        SizedBox(height: rs.tiny ? 8 : 12),
        _GBar(FieldNames.femaleAbsentShare, avgFemale, T.femaleC, '-', rs),
        SizedBox(height: rs.tiny ? 8 : 12),
        _GBar(FieldNames.totalAbsentShare, avgTotal, T.totalC, '-', rs),

        SizedBox(height: rs.tiny ? 10 : 16),
        const Divider(color: T.border),
        SizedBox(height: rs.tiny ? 8 : 12),
        // _Insight(
        //   icon: avgMaleRate > avgFemaleRate
        //       ? Icons.man_2_rounded
        //       : Icons.woman_2_rounded,
        //   color: avgMaleRate > avgFemaleRate ? T.maleC : T.femaleC,
        //   text:
        //       '${avgMaleRate > avgFemaleRate ? "Male" : "Female"} absenteeism rate higher by '
        //       '${(avgMaleRate - avgFemaleRate).abs().toStringAsFixed(2)}% avg',
        //   tiny: rs.tiny,
        // ),
      ]),
    );
  }
}

class _GBar extends StatelessWidget {
  final String label, totalCount;
  final double pct;
  final Color color;
  final RS rs;
  const _GBar(this.label, this.pct, this.color, this.totalCount, this.rs);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
            child: Text(label,
                style: TextStyle(
                    fontSize: rs.fontSize(12),
                    fontWeight: FontWeight.w700,
                    color: T.ink),
                overflow: TextOverflow.ellipsis)),
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (!rs.tiny && totalCount != '-')
            Text('Total: $totalCount  ',
                style: TextStyle(fontSize: rs.fontSize(10), color: T.muted)),
          Text('${pct.toStringAsFixed(2)}%',
              style: TextStyle(
                  fontSize: rs.fontSize(13),
                  fontWeight: FontWeight.w900,
                  color: color)),
        ]),
      ]),
      const SizedBox(height: 8),
      Stack(children: [
        Container(
            height: rs.tiny ? 8 : 10,
            decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(5))),
        FractionallySizedBox(
          widthFactor: (pct / 22).clamp(0.0, 1.0),
          child: Container(
              height: rs.tiny ? 8 : 10,
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [color, color.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(5),
              )),
        ),
      ]),
    ]);
  }
}

class _Insight extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final bool tiny;
  const _Insight(
      {required this.icon,
      required this.color,
      required this.text,
      required this.tiny});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: tiny ? 8 : 12, vertical: tiny ? 8 : 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: tiny ? 14 : 18),
        SizedBox(width: tiny ? 6 : 10),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: tiny ? 10 : 12,
                    color: color,
                    fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class _DayBarsCard extends StatelessWidget {
  final List<AR> wd;
  final RS rs;
  const _DayBarsCard({required this.wd, required this.rs});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: rs.cardP,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.bar_chart_rounded, size: 15, color: T.blue),
          const SizedBox(width: 6),
          Text(FieldNames.overallAbsentRate,
              style: TextStyle(
                  fontSize: rs.fontSize(14),
                  fontWeight: FontWeight.w800,
                  color: T.ink)),
        ]),
        SizedBox(height: rs.tiny ? 12 : 16),
        ...wd.map((r) {
          final sc = statusColor(r.totalAbsentRate);
          final barH = rs.tiny ? 22.0 : 28.0;
          return Padding(
            padding: EdgeInsets.only(bottom: rs.tiny ? 8 : 12),
            child: Row(children: [
              SizedBox(
                width: rs.tiny ? 36 : 48,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fmtShort(r.date),
                          style: TextStyle(
                              fontSize: rs.tiny ? 9 : 11,
                              fontWeight: FontWeight.w700,
                              color: T.ink)),
                      Text(
                          rs.tiny
                              ? dayName(r.date).substring(0, 2)
                              : dayName(r.date),
                          style: const TextStyle(fontSize: 9, color: T.muted)),
                    ]),
              ),
              SizedBox(width: rs.tiny ? 6 : 10),
              Expanded(
                child: Stack(children: [
                  Container(
                      height: barH,
                      decoration: BoxDecoration(
                          color: T.bg, borderRadius: BorderRadius.circular(6))),
                  FractionallySizedBox(
                    widthFactor: (r.totalAbsentRate / 22).clamp(0.0, 1.0),
                    child: Container(
                        height: barH,
                        decoration: BoxDecoration(
                          gradient:
                              LinearGradient(colors: [sc.withOpacity(0.8), sc]),
                          borderRadius: BorderRadius.circular(6),
                        )),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          rs.tiny
                              ? '${r.totalAbsentRate.toStringAsFixed(1)}%'
                              : '${r.totalAbsentRate.toStringAsFixed(2)}%  (${r.totalAbsent.toStringAsFixed(0)} absent)',
                          style: TextStyle(
                              fontSize: rs.tiny ? 9 : 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════
class _Card extends StatelessWidget {
  final Widget child;
  final double padding;
  const _Card({required this.child, this.padding = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool tiny;
  const _Pill({required this.label, required this.color, this.tiny = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: tiny ? 7 : 10, vertical: tiny ? 3 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: tiny ? 8 : 10,
              fontWeight: FontWeight.w800,
              color: color)),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label, leftText, rightText;
  final double pct;
  final Color color;
  final bool tiny;
  const _ProgressBar({
    required this.label,
    required this.pct,
    required this.color,
    required this.leftText,
    required this.rightText,
    required this.tiny,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(
                fontSize: tiny ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: T.muted)),
        Text(leftText,
            style: TextStyle(
                fontSize: tiny ? 10 : 12,
                fontWeight: FontWeight.w700,
                color: color)),
      ]),
      SizedBox(height: tiny ? 6 : 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(children: [
          Container(height: tiny ? 10 : 14, color: T.rose.withOpacity(0.15)),
          FractionallySizedBox(
            widthFactor: pct.clamp(0.0, 1.0),
            child: Container(
              height: tiny ? 10 : 14,
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [color, color.withOpacity(0.75)]),
              ),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(leftText, style: TextStyle(fontSize: tiny ? 9 : 10, color: color)),
        Text(rightText,
            style: TextStyle(fontSize: tiny ? 9 : 10, color: T.rose)),
      ]),
    ]);
  }
}
