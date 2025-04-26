import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class EmpPunch extends StatefulWidget {
  final LoginModelApi userData;
  const EmpPunch({Key? key, required this.userData}) : super(key: key);

  @override
  _EmpPunchState createState() => _EmpPunchState();
}

class _EmpPunchState extends State<EmpPunch> {
  String _location = "Fetching location...";
  String _latLng = "Fetching latLng";
  String _macAddress = "Fetching MAC address...";
  String? _apiResponse; // Store response here
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

  // void _onPunchPressed() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //         content: Text(
  //             'Punch recorded at $_location ($_latLng)\nMAC: $_macAddress')),
  //   );
  // }

  void _showResponseDialog(String message) {
    // bool isMacMismatch =
    //     message == "Your barcode doesn't match the registered MAC address";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Punch Details"),
          content: Text(message),
          actions: [
            // if (isMacMismatch)
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                // You can navigate to settings or handle device switch here
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              // child: Text(isMacMismatch ? "OK" : "Cancel"),
              child: const Text("OK"),

              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // if (!isMacMismatch)
            //   TextButton(
            //     child: const Text("OK"),
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //     },
            //   ),
          ],
        );
      },
    );
  }

  void _onPunchPressed() async {
    final empNo = widget.userData.empNo;
    final lat = _latLng.contains('Lat:')
        ? _latLng.split(',')[0].split(':')[1].trim()
        : "0";
    final long = _latLng.contains('Long:')
        ? _latLng.split(',')[1].split(':')[1].trim()
        : "0";

    final url = Uri.parse(
      '${ApiHelper.baseUrl}EmpPunch?barcode=$empNo&longitude=$long&latitude=$lat&macadrress=$_macAddress',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _apiResponse = response.body; // You can parse JSON if needed
        });
        // Show dialog
        _showResponseDialog(_apiResponse!);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Punch Successful!')),
        // );
      } else {
        _showResponseDialog("Error: ${response.reasonPhrase}");
        setState(() {
          _apiResponse = "Error: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      _showResponseDialog("Failed to connect: $e");
      setState(() {
        _apiResponse = "Failed to connect: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
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
                      // const SizedBox(height: 10),
                      // Text(
                      //   _location,
                      //   style: const TextStyle(fontSize: 16),
                      //   textAlign: TextAlign.center,
                      // ),
                      const SizedBox(height: 10),
                      _latLng.contains("Fetching")
                          ? const CircularProgressIndicator()
                          : Text(
                              _latLng,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold),
                            ),
                      const SizedBox(height: 10),
                      _macAddress.contains("Fetching")
                          ? const CircularProgressIndicator()
                          : Text(
                              'MAC Address: $_macAddress',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
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
