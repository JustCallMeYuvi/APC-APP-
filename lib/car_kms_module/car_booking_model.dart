import 'package:flutter/material.dart';

class CarBookingTrack {
  final int sno;
  final int carDetails;
  final int carBookingId;
  final String travellers;
  final String carNo;
  final String carName;
  final DateTime carInTime;
  late TextEditingController kmsCtrl;
  bool saving = false;

  CarBookingTrack({
    required this.sno,
    required this.carDetails,
    required this.carBookingId,
    required this.travellers,
    required this.carNo,
    required this.carName,
    required this.carInTime,
    String? actualKms,
  }) {
    kmsCtrl = TextEditingController(text: actualKms ?? '');
  }

  factory CarBookingTrack.fromJson(Map<String, dynamic> j) => CarBookingTrack(
        sno: j['sno'],
        carDetails: j['caR_DETAILS'] ?? 0,
        carBookingId: j['carbookingid'],
        travellers:
            (j['travellers'] ?? '').toString().replaceAll('\n', ', ').trim(),
        carNo: j['caR_NO'] ?? '',
        carName: j['caR_NAME'] ?? '',
        carInTime: DateTime.parse(j['caR_IN_TIME']),
        actualKms: j['actualKms']?.toString(),
      );

  void dispose() {
    kmsCtrl.dispose();
  }
}