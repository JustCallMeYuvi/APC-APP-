import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/screens/home_screen/efficiency_report_page.dart';
import 'package:animated_movies_app/screens/home_screen/target_output_report_page.dart';
import 'package:flutter/material.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({Key? key}) : super(key: key);

  @override
  _GraphsScreenState createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Graphs Screen'),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: UiConstants.backgroundGradient.gradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            // Target Output Report
            // ListTile(
            //   title: Text(
            //     'Target Output Report',
            //     style: TextStyle(color: Colors.white),
            //   ),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => TargetOutputReportPage()),
            //     );
            //   },
            // ),
            _buildReportCard(
              title: 'Target Output Report',
              icon: Icons.show_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TargetOutputReportPage()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Efficiency Report
            // ListTile(
            //   title: Text(
            //     'Efficiency Report',
            //     style: TextStyle(color: Colors.white),
            //   ),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => EfficiencyReportPage()),
            //     );
            //   },
            // ),
            // Efficiency Report
            _buildReportCard(
              title: 'Efficiency Report',
              icon: Icons.bar_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EfficiencyReportPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            // RFT Report (RQC RFT)
            _buildReportCard(
              title: 'RFT Report (RQC RFT)',
              icon: Icons.pie_chart,
              onTap: () {
                // Add navigation to RftReportPage
              },
            ),
            const SizedBox(height: 16),
            // PO Completion Report
            _buildReportCard(
              title: 'PO Completion Report',
              icon: Icons.assignment_turned_in,
              onTap: () {
                // Add navigation to PoCompletionReportPage
              },
            ),
            // Divider(color: Colors.white),
            // // RFT Report (RQC RFT)
            // ListTile(
            //   title: Text(
            //     'RFT Report (RQC RFT)',
            //     style: TextStyle(color: Colors.white),
            //   ),
            //   onTap: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(builder: (context) => RftReportPage()),
            //     // );
            //   },
            // ),
            // Divider(color: Colors.white),
            // // PO Completion Report
            // ListTile(
            //   title: Text(
            //     'PO Completion Report',
            //     style: TextStyle(color: Colors.white),
            //   ),
            //   onTap: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(builder: (context) => PoCompletionReportPage()),
            //     // );
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  // Function to create a card with icon and text
  Widget _buildReportCard({
    required String title,
    required IconData icon,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
