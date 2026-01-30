import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'qr_scan_event.dart';
import 'qr_scan_state.dart';

class QrScanBloc extends Bloc<QrScanEvent, QrScanState> {
  QrScanBloc() : super(const QrScanState()) {
    on<StartQrScan>(_onStartScan);
  }

  Future<void> _onStartScan(
    StartQrScan event,
    Emitter<QrScanState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await FlutterBarcodeScanner.scanBarcode(
        '#FF6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (result == '-1') {
        emit(state.copyWith(isLoading: false));
      } else {
        emit(state.copyWith(
          isLoading: false,
          scannedData: result,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'QR scan failed',
      ));
    }
  }
}
