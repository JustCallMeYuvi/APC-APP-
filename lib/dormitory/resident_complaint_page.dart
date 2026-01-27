import 'package:animated_movies_app/dormitory/complaint_bloc.dart';
import 'package:animated_movies_app/dormitory/complaint_event.dart';
import 'package:animated_movies_app/dormitory/complaint_state.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResidentComplaintPage extends StatefulWidget {
  final LoginModelApi userData;
  const ResidentComplaintPage({Key? key, required this.userData})
      : super(key: key);

  @override
  State<ResidentComplaintPage> createState() => _ResidentComplaintPageState();
}

class _ResidentComplaintPageState extends State<ResidentComplaintPage> {
  late final ComplaintBloc _complaintBloc;
  final TextEditingController _complaintController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _complaintBloc = ComplaintBloc()..add(LoadComplaintTypes());
  }

  @override
  void dispose() {
    _complaintBloc.close();
    _complaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _complaintBloc,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: BlocConsumer<ComplaintBloc, ComplaintState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }

            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Complaint Submitted")),
              );
              _complaintController.clear();
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black12,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _showComplaintDropdown(context),
                              // child: _dropdown(state.selectedType),
                              child: _dropdown(state.selectedDept?.name),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _complaintController,
                              maxLines: 6,
                              decoration:
                                  _inputDecoration("Describe your issue"),
                            ),
                            const SizedBox(height: 30),
                            _submitButton(
                                context, state, widget.userData.empNo),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _submitButton(
      BuildContext context, ComplaintState state, String empNo) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: state.isLoading
            ? null
            : () {
                context.read<ComplaintBloc>().add(
                      SubmitComplaint(
                        description: _complaintController.text.trim(),
                        empNo: empNo,
                        employeeDept: widget.userData.deptName ?? "",
                      ),
                    );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFff512f), Color(0xFFdd2476)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: Center(
            child: state.isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)
                : const Text(
                    "Submit Complaint",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI Helpers ----------------

  Widget _header() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFff512f), Color(0xFFdd2476)],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: const Text(
          "Raise a Complaint",
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );

  Widget _dropdown(String? value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.apartment, color: Color(0xFFdd2476)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? "Select Complaint Department",
                style: TextStyle(
                  fontSize: 16,
                  color: value == null ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  // ---------------- Bottom Sheet ----------------

  void _showComplaintDropdown(BuildContext context) {
    final bloc = context.read<ComplaintBloc>();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: BlocBuilder<ComplaintBloc, ComplaintState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: state.departments.map((dept) {
                  return ListTile(
                    title: Text(dept.name), // IT / MNT
                    subtitle: Text(dept.dept), // IT-Hardware / Maintenance
                    onTap: () {
                      context
                          .read<ComplaintBloc>()
                          .add(SelectComplaintType(dept));
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }
}
