import 'package:animated_movies_app/MNT_Modules/qr_scan_bloc.dart';
import 'package:animated_movies_app/MNT_Modules/qr_scan_event.dart';
import 'package:animated_movies_app/MNT_Modules/qr_scan_state.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaintenanceQrCodeScannerScreen extends StatelessWidget {
  final LoginModelApi userData;

  const MaintenanceQrCodeScannerScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrScanBloc(),
      child: Scaffold(
        body: BlocConsumer<QrScanBloc, QrScanState>(listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        }, builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// QR ICON
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 30),

                  /// SCAN BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              context.read<QrScanBloc>().add(StartQrScan());
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Scan QR Code',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// LOADING
                  if (state.isLoading) const CircularProgressIndicator(),

                  const SizedBox(height: 20),

                  /// RESULT CARD
                  if (state.scannedData != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Scanned Result',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.scannedData!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
