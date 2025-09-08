import 'package:flutter/material.dart';

class CarBookingScreen extends StatefulWidget {
  // final String carName; // Add this

  const CarBookingScreen({Key? key, }) : super(key: key);

  @override
  _CarBookingScreenState createState() => _CarBookingScreenState();
}

class _CarBookingScreenState extends State<CarBookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Screen'), // Use the car name here
        backgroundColor: Colors.lightGreen,
      ),
      body: const Center(
        child: Text('Booking details for Car'),
      ),
    );
  }
}
