
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tabletap_frontend/utils/api_helper.dart';

class GenerateQRScreen extends StatefulWidget {
  const GenerateQRScreen({super.key});

  @override
  State<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  final TextEditingController _tableController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String? _generatedTableNumber;

  bool get _isInputValid {
    final text = _tableController.text;
    if (text.isEmpty) return false;
    final number = int.tryParse(text);
    return number != null && number > 0;
  }

  Future<bool> _requestPermission() async {
    if (await Permission.photos.request().isGranted) {
      return true;
    }
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<void> _saveQrToGallery() async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied.')),
      );
      return;
    }

    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: QR code not found.')),
        );
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating image bytes.')),
        );
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();

      // ✅ Save directly with image_gallery_saver_plus
      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name: "TableTap_QR_${_generatedTableNumber ?? 'table'}",
      );

      if (result["isSuccess"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code saved to Gallery! ✅')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save QR code.')),
        );
      }
    } catch (e) {
      debugPrint("QR Save Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while saving QR code.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate QR Code"),
        leading: const BackButton(),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _tableController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter Table Number",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isInputValid
                    ? () {
                        setState(() {
                          _generatedTableNumber = _tableController.text;
                        });
                      }
                    : null,
                icon: const Icon(Icons.qr_code),
                label: const Text("Generate QR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isInputValid ? Colors.deepPurple : Colors.grey,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
              const SizedBox(height: 30),
              if (_generatedTableNumber != null) ...[
                RepaintBoundary(
                  key: _qrKey,
                  child: QrImageView(
                    data: "${api('/customer')}?table_number=$_generatedTableNumber",
                    version: QrVersions.auto,
                    size: 250,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _saveQrToGallery,
                  icon: const Icon(Icons.download),
                  label: const Text("Download QR Code"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
