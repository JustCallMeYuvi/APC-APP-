

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordCard extends StatelessWidget {
  final String name;
  final String empId;
  final String awpnNo;
  final String status;
  final String department;
  final String description;
  final String issueDate;
  final String lastUpdated;
  final bool hasRewardImpact;
  final IconData deptIcon;

  const RecordCard({
    super.key,
    required this.name,
    required this.empId,
    required this.awpnNo,
    required this.status,
    required this.department,
    required this.description,
    required this.issueDate,
    required this.lastUpdated,
    this.hasRewardImpact = false,
    required this.deptIcon,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBg;
    Color statusText;
    switch (status) {
      case 'Approved':
        statusBg = const Color(0xFF98F994);
        statusText = const Color(0xFF002204);
        break;
      case 'Pending':
        statusBg = const Color(0xFFFFDCC2);
        statusText = const Color(0xFF2E1500);
        break;
      default:
        statusBg = const Color(0xFFFFDAD6);
        statusText = const Color(0xFF93000A);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C1D),
                    ),
                  ),
                  Text(
                    empId,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF717786),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'awpnNo: $awpnNo',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005EA4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(deptIcon, size: 16, color: const Color(0xFF005EA4)),
                const SizedBox(width: 8),
                Text(
                  department,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                status == 'Rejected'
                    ? Icons.report_problem
                    : Icons.warning_amber_rounded,
                color:
                    status == 'Pending' ? Colors.amber[800] : Colors.red[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFC1C6D7), thickness: 0.2),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDateInfo('Issue Date', issueDate),
              const SizedBox(width: 40),
              _buildDateInfo('Last Updated', lastUpdated),
            ],
          ),
          if (hasRewardImpact) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF005EA4).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.military_tech,
                          color: Color(0xFF005EA4), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'REWARD IMPACT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005EA4),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildImpactValue('Qty', '0.00'),
                      const SizedBox(width: 16),
                      _buildImpactValue('Amount', '\$0.00'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFF717786)),
        ),
        Text(
          date,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildImpactValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Color(0xFF717786)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}