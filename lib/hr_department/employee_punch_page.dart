import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class EmpPunch extends StatefulWidget {
  final LoginModelApi userData;
  const EmpPunch({Key? key, required this.userData}) : super(key: key);

  @override
  _EmpPunchState createState() => _EmpPunchState();
}

class _EmpPunchState extends State<EmpPunch> {
  String _location = "Fetching location...";
  String _latLng = "";
  String _macAddress = "Fetching MAC address...";
  @override
  void initState() {
    super.initState();
    _getLocationPermission();
    _getMacAddress();
  }

  Future<void> _getMacAddress() async {
    try {
      final info = NetworkInfo();
      String? mac = await info.getWifiBSSID(); // sometimes works better for MAC
      setState(() {
        _macAddress = mac ?? "MAC not available";
      });
    } catch (e) {
      setState(() {
        _macAddress = "Error getting MAC address: $e";
      });
    }
  }

  Future<void> _getLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      setState(() {
        _location = "Location permission denied";
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latLng = 'Lat: ${position.latitude}, Long: ${position.longitude}';
      });

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;

          setState(() {
            _location =
                '${place.name ?? ''}, ${place.street ?? ''}, ${place.locality ?? ''}, '
                '${place.administrativeArea ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}';
          });
        } else {
          setState(() {
            _location = 'Address not found. Only showing coordinates.';
          });
        }
      } catch (e) {
        setState(() {
          _location = 'Address lookup failed. Only showing coordinates.';
        });
      }
    } catch (e) {
      setState(() {
        _location = "Error fetching location: $e";
      });
    }
  }

  void _onPunchPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Punch recorded at $_location ($_latLng)\nMAC: $_macAddress')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Emp No: ${widget.userData.empNo}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _location,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _latLng,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'MAC Address: $_macAddress',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: MaterialButton(
                onPressed:
                    _location.contains("Error") || _location.contains("denied")
                        ? null
                        : _onPunchPressed,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                disabledColor: Colors.grey[400],
                elevation: 0,
                child: const Text(
                  'Punch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
