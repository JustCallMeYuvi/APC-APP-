import 'dart:convert';
import 'package:animated_movies_app/MNT_Modules/power_panel_model.dart';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

import 'qr_scan_event.dart';
import 'qr_scan_state.dart';

class QrScanBloc extends Bloc<QrScanEvent, QrScanState> {
  QrScanBloc() : super(const QrScanState()) {
    on<StartQrScan>(_onStartScan);
    on<FetchPanelDetails>(_onFetchPanelDetails);
  }

  Future<void> _onStartScan(
    StartQrScan event,
    Emitter<QrScanState> emit,
  ) async {
    try {
      final scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#FF6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      print('SCANNED VALUE 👉 $scanResult');

      if (scanResult == '-1' || scanResult.isEmpty) {
        return; // cancel
      }

      // 🔥 IMPORTANT: scan pannadhu edhuvo adha pass pannu
      add(FetchPanelDetails(scanResult));
    } catch (e) {
      emit(state.copyWith(error: 'QR scan failed'));
    }
  }

  Future<void> _onFetchPanelDetails(
    FetchPanelDetails event,
    Emitter<QrScanState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // final url = 'http://10.3.0.70:9042/api/MNT_/scan-qr/${event.panelId}';

      final url = Uri.parse(
        '${ApiHelper.mntURL}scan-qr/${event.panelId}',
      );

      print('API CALL 👉 $url');

      final response = await http.get((url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        emit(state.copyWith(
          isLoading: false,
          panel: PowerPanelModel.fromJson(jsonData),
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'No data found',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'API failed',
      ));
    }
  }
}
