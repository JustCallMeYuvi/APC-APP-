import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────── Constants ──────────────────────────────
class AppColors {
  static const bg = Color(0xFF0D0F1A);
  static const surface = Color(0xFF161829);
  static const card = Color(0xFF1E2138);
  static const accent = Color(0xFF6C63FF);
  static const accentGlow = Color(0xFF8B85FF);
  static const teal = Color(0xFF00D4AA);
  static const coral = Color(0xFFFF6B6B);
  static const textPrimary = Color(0xFFEEF0FF);
  static const textSecondary = Color(0xFF8A8FAD);
  static const border = Color(0xFF2A2D45);
  static const inputBg = Color(0xFF13152A);
}

// ────────────────────── Main Page ───────────────────────────────
class LeaveRequestScreen extends StatefulWidget {
  final LoginModelApi userData;
  const LeaveRequestScreen({super.key, required this.userData});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen>
    with TickerProviderStateMixin {
  // Step management
  int _currentStep = 0;
  final int _totalSteps = 4;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // Form state
  final TextEditingController _employeeIdCtrl = TextEditingController();
  final TextEditingController _employeeNameCtrl = TextEditingController();
  final TextEditingController _departmentCtrl = TextEditingController();
  final TextEditingController _positionCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();
  final TextEditingController _approverNameCtrl = TextEditingController();

  String? _leaveType;
  String? _hrApprover;
  DateTime? _fromDate;
  TimeOfDay? _fromTime;
  DateTime? _toDate;
  TimeOfDay? _toTime;
  bool _isSubmitting = false;
  bool _submitted = false;

  final _leaveTypes = [
    {'label': 'Casual Leave', 'icon': Icons.beach_access_rounded},
    {'label': 'Sick Leave', 'icon': Icons.medical_services_rounded},
    {'label': 'Earned Leave', 'icon': Icons.star_rounded},
    {'label': 'Maternity Leave', 'icon': Icons.favorite_rounded},
    {'label': 'Paternity Leave', 'icon': Icons.child_care_rounded},
    {'label': 'Loss of Pay', 'icon': Icons.money_off_rounded},
    {'label': 'Compensatory Off', 'icon': Icons.swap_horiz_rounded},
  ];

  final _hrApprovers = ['Priya Sharma', 'Ravi Kumar', 'Meena Nair'];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    final user = widget.userData;

    _employeeIdCtrl.text = user.empNo;
    _employeeNameCtrl.text = user.username;
    _departmentCtrl.text = user.deptName ?? '';
    _positionCtrl.text = user.position ?? '';
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _employeeIdCtrl.dispose();
    _employeeNameCtrl.dispose();
    _departmentCtrl.dispose();
    _positionCtrl.dispose();
    _reasonCtrl.dispose();
    _approverNameCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _fadeCtrl.reset();
      setState(() => _currentStep++);
      _fadeCtrl.forward();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _fadeCtrl.reset();
      setState(() => _currentStep--);
      _fadeCtrl.forward();
    }
  }

  String get _duration {
    if (_fromDate == null || _toDate == null) return '—';
    final from = DateTime(
      _fromDate!.year,
      _fromDate!.month,
      _fromDate!.day,
      _fromTime?.hour ?? 0,
      _fromTime?.minute ?? 0,
    );
    final to = DateTime(
      _toDate!.year,
      _toDate!.month,
      _toDate!.day,
      _toTime?.hour ?? 0,
      _toTime?.minute ?? 0,
    );
    final diff = to.difference(from);
    if (diff.isNegative) return 'Invalid';
    return '${diff.inDays}d ${diff.inHours % 24}h ${diff.inMinutes % 60}m';
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => _themedPicker(ctx, child),
    );
    if (picked == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => _themedPicker(ctx, child),
    );
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        _fromTime = time;
      } else {
        _toDate = picked;
        _toTime = time;
      }
    });
  }

  Widget _themedPicker(BuildContext ctx, Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          onPrimary: Colors.white,
          surface: AppColors.card,
          onSurface: AppColors.textPrimary,
        ),
        dialogBackgroundColor: AppColors.surface,
      ),
      child: child!,
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    }
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _submitted ? _buildSuccess() : _buildForm(),
    );
  }

  // ── Success Screen ───────────────────────────────────────────
  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.teal, AppColors.accent],
                ),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.teal.withOpacity(0.4), blurRadius: 30)
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 52),
            ),
            const SizedBox(height: 28),
            const Text('Request Submitted!',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            const Text('Your leave request has been sent\nfor approval.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
            const SizedBox(height: 36),
            _gradientButton('Back to Home',
                onTap: () => setState(() {
                      _submitted = false;
                      _currentStep = 0;
                    })),
          ],
        ),
      ),
    );
  }

  // ── Form Scaffold ────────────────────────────────────────────
  Widget _buildForm() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildStepIndicator(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: _buildCurrentStep(),
              ),
            ),
          ),
          _buildNavBar(),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader() {
    final stepTitles = [
      'Employee Info',
      'Leave Details',
      'Approval',
      'Date & Time'
    ];
    final stepSubs = [
      'Who is requesting?',
      'Type & reason',
      'Assign approvers',
      'Set duration'
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentGlow]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: AppColors.accent.withOpacity(0.4), blurRadius: 12)
              ],
            ),
            child: const Icon(Icons.event_available_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stepTitles[_currentStep],
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text(stepSubs[_currentStep],
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          _stepBadge(),
        ],
      ),
    );
  }

  Widget _stepBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Text('${_currentStep + 1}/$_totalSteps',
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accentGlow)),
    );
  }

  // ── Step Indicator ───────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: List.generate(_totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIdx = i ~/ 2;
            final filled = stepIdx < _currentStep;
            return Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: filled
                      ? const LinearGradient(
                          colors: [AppColors.accent, AppColors.teal])
                      : null,
                  color: filled ? null : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }
          final idx = i ~/ 2;
          final done = idx < _currentStep;
          final current = idx == _currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: current ? 32 : 28,
            height: current ? 32 : 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: (done || current)
                  ? const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentGlow])
                  : null,
              color: (done || current) ? null : AppColors.card,
              border: Border.all(
                color: current
                    ? AppColors.accent
                    : (done ? Colors.transparent : AppColors.border),
                width: current ? 2 : 1,
              ),
              boxShadow: current
                  ? [
                      BoxShadow(
                          color: AppColors.accent.withOpacity(0.5),
                          blurRadius: 10)
                    ]
                  : [],
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : Text('${idx + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: current ? Colors.white : AppColors.textSecondary,
                      )),
            ),
          );
        }),
      ),
    );
  }

  // ── Current Step Content ─────────────────────────────────────
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return const SizedBox();
    }
  }

  // ── Step 1: Employee Info ─────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      children: [
        _styledField(
          ctrl: _employeeIdCtrl,
          label: 'Employee ID',
          hint: 'e.g. EMP-00123',
          icon: Icons.badge_rounded,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        _styledField(
          ctrl: _employeeNameCtrl,
          label: 'Full Name',
          hint: 'Your full name',
          icon: Icons.person_rounded,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        _styledField(
          ctrl: _departmentCtrl,
          label: 'Department',
          hint: 'e.g. Production',
          icon: Icons.business_rounded,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        _styledField(
          ctrl: _positionCtrl,
          label: 'Position',
          hint: 'e.g. Floor Supervisor',
          icon: Icons.work_rounded,
          readOnly: true,
        ),
        const SizedBox(height: 24),
        _infoChip(
            'Pre-filled fields will be auto-populated\nfrom your employee profile.'),
      ],
    );
  }

  // ── Step 2: Leave Details ────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Leave Type'),
        const SizedBox(height: 12),
        ...(_leaveTypes.map((lt) => _leaveTypeCard(lt))),
        const SizedBox(height: 24),
        const _SectionTitle('Reason for Leave'),
        const SizedBox(height: 12),
        _styledField(
          ctrl: _reasonCtrl,
          label: '',
          hint: 'Briefly describe your reason...',
          icon: Icons.notes_rounded,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _leaveTypeCard(Map<String, dynamic> lt) {
    final selected = _leaveType == lt['label'];
    return GestureDetector(
      onTap: () => setState(() => _leaveType = lt['label'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withOpacity(0.12) : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: AppColors.accent.withOpacity(0.2), blurRadius: 12)
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accent.withOpacity(0.2)
                    : AppColors.inputBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(lt['icon'] as IconData,
                  size: 18,
                  color: selected
                      ? AppColors.accentGlow
                      : AppColors.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(lt['label'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  )),
            ),
            if (selected)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [AppColors.accent, AppColors.accentGlow]),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 12, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  // ── Step 3: Approval ─────────────────────────────────────────
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _approvalInfoCard(
          label: 'Dept Approval',
          barcode: '70068',
          name: 'Yuvi',
          color: AppColors.teal,
          icon: Icons.supervisor_account_rounded,
        ),
        const SizedBox(height: 16),
        _approvalInfoCard(
          label: 'Applicant',
          barcode: '67657',
          name: 'Imran',
          color: AppColors.accent,
          icon: Icons.person_rounded,
        ),
        const SizedBox(height: 24),
        const _SectionTitle('HR Dept Approval'),
        const SizedBox(height: 12),
        _styledDropdown(
          value: _hrApprover,
          hint: 'Select HR Approver',
          icon: Icons.how_to_reg_rounded,
          items: _hrApprovers,
          onChanged: (v) => setState(() => _hrApprover = v),
        ),
        const SizedBox(height: 16),
        _styledField(
          ctrl: _approverNameCtrl,
          label: 'Special Approver (optional)',
          hint: 'Enter approver name',
          icon: Icons.verified_user_rounded,
        ),
      ],
    );
  }

  Widget _approvalInfoCard({
    required String label,
    required String barcode,
    required String name,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 3),
              Text(name,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text('ID: $barcode',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          Icon(Icons.lock_rounded, size: 16, color: color.withOpacity(0.5)),
        ],
      ),
    );
  }

  // ── Step 4: Date & Time ──────────────────────────────────────
  Widget _buildStep4() {
    return Column(
      children: [
        _dateTimeCard(
          label: 'From',
          date: _fromDate,
          time: _fromTime,
          color: AppColors.accent,
          icon: Icons.flight_takeoff_rounded,
          onTap: () => _pickDate(true),
        ),
        const SizedBox(height: 16),
        _dateTimeCard(
          label: 'To',
          date: _toDate,
          time: _toTime,
          color: AppColors.teal,
          icon: Icons.flight_land_rounded,
          onTap: () => _pickDate(false),
        ),
        const SizedBox(height: 20),
        _durationCard(),
        const SizedBox(height: 28),
        _gradientButton(
          'Submit Request',
          isLoading: _isSubmitting,
          onTap: _submit,
          icon: Icons.send_rounded,
        ),
      ],
    );
  }

  Widget _dateTimeCard({
    required String label,
    required DateTime? date,
    required TimeOfDay? time,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: hasDate ? color.withOpacity(0.4) : AppColors.border),
          boxShadow: hasDate
              ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 16)]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(
                    hasDate
                        ? '${date!.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                            '  ${time?.hour.toString().padLeft(2, '0') ?? '--'}:${time?.minute.toString().padLeft(2, '0') ?? '--'}'
                        : 'Tap to select date & time',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                      color: hasDate
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: hasDate ? color : AppColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _durationCard() {
    final hasDuration = _fromDate != null && _toDate != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: hasDuration
            ? const LinearGradient(
                colors: [Color(0xFF1A1F3A), Color(0xFF1A2A38)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasDuration ? null : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              hasDuration ? AppColors.teal.withOpacity(0.4) : AppColors.border,
        ),
        boxShadow: hasDuration
            ? [
                BoxShadow(
                    color: AppColors.teal.withOpacity(0.15), blurRadius: 20)
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.timelapse_rounded,
                color: AppColors.teal, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Duration',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(_duration,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: hasDuration
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    letterSpacing: 0.5,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav Bar ───────────────────────────────────────────
  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: GestureDetector(
                onTap: _prevStep,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded,
                          color: AppColors.textSecondary, size: 18),
                      SizedBox(width: 8),
                      Text('Back',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          if (_currentStep < _totalSteps - 1)
            Expanded(
              flex: 2,
              child: _gradientButton('Continue',
                  onTap: _nextStep, icon: Icons.arrow_forward_rounded),
            ),
        ],
      ),
    );
  }

  // ── Reusable Widgets ─────────────────────────────────────────
  Widget _styledField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8A90A8),
            ),

            // 🔥 Better Icon Styling
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.accent),
            ),

            filled: true,
            fillColor: AppColors.inputBg,

            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

            // 🔥 Smooth Rounded Border
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.border.withOpacity(0.6),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.accent,
                width: 1.5,
              ),
            ),

            // 🔥 Subtle Shadow Effect
            enabled: true,
          ),
        ),
      ],
    );
  }

  Widget _styledDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      dropdownColor: AppColors.card,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF4A4F6A)),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary)),
              ))
          .toList(),
    );
  }

  Widget _gradientButton(
    String label, {
    required VoidCallback onTap,
    IconData? icon,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B52F5), Color(0xFF8B85FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        )),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(icon, size: 18, color: Colors.white),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.accentGlow),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ───────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.teal],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            )),
      ],
    );
  }
}
