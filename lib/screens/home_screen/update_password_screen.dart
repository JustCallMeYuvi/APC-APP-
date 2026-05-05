import 'dart:convert';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../onboarding_screen/login_page.dart';

class UpdatePasswordScreen extends StatefulWidget {
  final LoginModelApi userData;

  const UpdatePasswordScreen({super.key, required this.userData});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool showOld = false, showNew = false, showConfirm = false;
  String errorText = "";
  double strength = 0;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 SAME HEADER (exact)
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.shade50,
                  child:
                      Icon(Icons.lock, size: 16, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Change password",
                        style: TextStyle(fontSize: 15)),
                    Text(
                      "You'll be signed out after update",
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔥 CURRENT PASSWORD
            _fieldLabel("CURRENT PASSWORD"),
            _passwordField(
              controller: oldPasswordController,
              hint: "Enter current password",
              visible: showOld,
              icon: Icons.person_outline,
              onToggle: () => setState(() => showOld = !showOld),
            ),

            const SizedBox(height: 12),

            /// 🔥 NEW PASSWORD
            _fieldLabel("NEW PASSWORD"),
            _passwordField(
              controller: newPasswordController,
              hint: "Enter new password",
              visible: showNew,
              icon: Icons.lock_outline,
              onToggle: () => setState(() => showNew = !showNew),
              onChanged: (v) {
                setState(() => strength = _calcStrength(v));
              },
            ),

            const SizedBox(height: 6),
            _strengthBar(strength),

            const SizedBox(height: 12),

            /// 🔥 CONFIRM PASSWORD
            _fieldLabel("CONFIRM NEW PASSWORD"),
            _passwordField(
              controller: confirmController,
              hint: "Re-enter new password",
              visible: showConfirm,
              icon: Icons.check_circle_outline,
              onToggle: () => setState(() => showConfirm = !showConfirm),
              borderColor: confirmController.text.isEmpty
                  ? null
                  : (confirmController.text == newPasswordController.text
                      ? Colors.green
                      : Colors.red),
              onChanged: (_) => setState(() {}),
            ),

            if (confirmController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  confirmController.text == newPasswordController.text
                      ? "Passwords match"
                      : "Passwords do not match",
                  style: TextStyle(
                    fontSize: 11,
                    color: confirmController.text == newPasswordController.text
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),

            if (errorText.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(errorText,
                    style: TextStyle(color: Colors.red.shade700)),
              ),

            const SizedBox(height: 20),

            /// 🔥 BUTTON (same validation)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: isLoading ? null : _updatePassword,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("UPDATE PASSWORD"),
            )
          ],
        ),
      ),
    );
  }

  /// 🔥 SAME VALIDATION + API (copied from your dialog)
  Future<void> _updatePassword() async {
    final old = oldPasswordController.text.trim();
    final nw = newPasswordController.text.trim();
    final conf = confirmController.text.trim();

    if (old.isEmpty || nw.isEmpty || conf.isEmpty) {
      setState(() => errorText = "Please fill in all fields.");
      return;
    }

    if (nw != conf) {
      setState(() => errorText = "New passwords do not match.");
      return;
    }

    if (old == nw) {
      setState(() => errorText = "New password must differ from current.");
      return;
    }

    double currentStrength = _calcStrength(nw);

    if (currentStrength < 0.5) {
      setState(() => errorText = "Use uppercase, number & special character");
      return;
    }

    setState(() {
      isLoading = true;
      errorText = "";
    });

    final result = await changePassword(widget.userData.username, old, nw);

    setState(() => isLoading = false);

    if (!context.mounted) return;

    if (result["success"] == true) {
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmController.clear();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Success"),
          content: Text(result["message"]),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } else {
      setState(() => errorText = result["message"]);
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String username,
    String oldPassword,
    String newPassword,
  ) async {
    final url = Uri.parse('${ApiHelper.baseUrl}UpdateUserPassword');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      // 🔥 HANDLE EMPTY RESPONSE
      if (response.body.isEmpty) {
        return {
          "success": false,
          "message": "Empty response from server",
        };
      }

      // 🔥 SAFE JSON PARSE
      final responseJson = jsonDecode(response.body);

      return {
        "success": responseJson["success"] ?? false,
        "message": responseJson["message"] ?? "Something went wrong",
      };
    } catch (e) {
      print("ERROR: $e");

      return {
        "success": false,
        "message": "Server error or invalid response",
      };
    }
  }

  /// 🔽 helpers (same)
  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(text,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 0.8)),
      );

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required IconData icon,
    required VoidCallback onToggle,
    Color? borderColor,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, size: 16),
        suffixIcon: IconButton(
          iconSize: 16,
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: borderColor ?? Colors.lightGreen, width: 1.5),
        ),
      ),
    );
  }

  double _calcStrength(String v) {
    if (v.isEmpty) return 0;

    double s = 0;

    if (v.length >= 6) s += 0.2;
    if (v.length >= 10) s += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(v)) s += 0.2;
    if (RegExp(r'[0-9]').hasMatch(v)) s += 0.2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) s += 0.2;

    return s.clamp(0, 1);
  }

  Widget _strengthBar(double strength) {
    Color color = strength <= 0.25
        ? Colors.red
        : strength <= 0.5
            ? Colors.orange
            : strength <= 0.75
                ? Colors.lightGreen
                : Colors.green;
    String label = strength <= 0
        ? ""
        : strength <= 0.25
            ? "Weak"
            : strength <= 0.5
                ? "Fair"
                : strength <= 0.75
                    ? "Good"
                    : "Strong";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: strength,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(label, style: TextStyle(fontSize: 11, color: color)),
          ),
      ],
    );
  }
}
