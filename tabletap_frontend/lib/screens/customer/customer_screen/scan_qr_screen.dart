import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  bool _isScanning = true;

  void _onQRCodeScanned(String qrData) {
    if (!_isScanning) return;

    setState(() {
      _isScanning = false;
    });

    debugPrint("Scanned QR: $qrData"); // For debugging

    // Navigate to Menu screen with QR data
    Navigator.pushNamed(
      context,
      '/menu',
      arguments: {'menuUrl': qrData},
    ).then((_) {
      // Resume scanning if user comes back
      setState(() {
        _isScanning = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        fit: BoxFit.cover, // Makes camera view full screen
        onDetect: (capture) {
          if (!_isScanning) return; // Avoid multiple triggers
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            if (code != null && code.isNotEmpty) {
              _onQRCodeScanned(code);
            }
          }
        },
      ),
    );
  }
}
