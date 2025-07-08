import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';

class BussinessInfoPage extends StatefulWidget {
  final LoginModelApi userData;
  const BussinessInfoPage({Key? key, required this.userData}) : super(key: key);

  @override
  _BussinessInfoPageState createState() => _BussinessInfoPageState();
}

class _BussinessInfoPageState extends State<BussinessInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Business Info"),
      //   centerTitle: true,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Business Logo
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  AssetImage('assets/logo.png'), // Replace with your image
            ),
            const SizedBox(height: 16),

            // Business Name & Tagline
            const Text(
              "Maxking Enterprises",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Quality. Trust. Innovation.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 32),

            // Contact Info
            buildInfoTile(Icons.phone, "Phone", "+91 98765 43210"),
            buildInfoTile(Icons.email, "Email", "info@maxking.com"),
            buildInfoTile(Icons.web, "Website", "www.maxking.com"),
            buildInfoTile(Icons.location_on, "Address",
                "No 123, Anna Salai, Chennai, Tamil Nadu, India"),

            const Divider(height: 32),

            // Social Media Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: const Icon(Icons.facebook),
                    onPressed: () {
                      // launch FB link
                    }),
                IconButton(
                    icon: const Icon(Icons.linked_camera),
                    onPressed: () {
                      // launch Instagram
                    }),
                IconButton(
                    icon: const Icon(Icons.business),
                    onPressed: () {
                      // launch LinkedIn
                    }),
              ],
            ),

            const SizedBox(height: 16),

            // About Business
            const Text(
              "About Us",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Maxking Enterprises is a leading provider of high-quality manufacturing solutions, serving clients globally. Our mission is to deliver excellence and value through innovation and customer-focused services.",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }
}
