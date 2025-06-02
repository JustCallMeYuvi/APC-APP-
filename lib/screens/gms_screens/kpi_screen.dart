import 'package:flutter/material.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';

class KpiScreen extends StatefulWidget {
  final LoginModelApi userData;

  const KpiScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _KpiScreenState createState() => _KpiScreenState();
}

class _KpiScreenState extends State<KpiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(),
            const SizedBox(height: 20),
            const Text(
              'Your KPI Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildKpiCard(
              title: 'Sales Target',
              value: '75%',
              color: Colors.blueAccent,
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 12),
            _buildKpiCard(
              title: 'Customer Satisfaction',
              value: '92%',
              color: Colors.green,
              icon: Icons.sentiment_satisfied_alt,
            ),
            const SizedBox(height: 12),
            _buildKpiCard(
              title: 'Tasks Completed',
              value: '47/50',
              color: Colors.orange,
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(widget.userData.empNo),
        subtitle: Text('Employee No: ${widget.userData.empNo}'),
        trailing: Icon(Icons.verified_user, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          value,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}
