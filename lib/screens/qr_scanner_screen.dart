import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/monitoring_provider.dart';
import '../theme/colors.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false; // Flag untuk mencegah pemindaian ganda

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// Fungsi untuk menangani data dari QR code yang berhasil dipindai
  void _handleQrCode(String qrCodeData) {
    print('--- QR Code Terdeteksi ---');
    print('Data mentah yang diterima: [$qrCodeData]');
    print('--- Akhir Data ---');
    // Menggunakan mounted check untuk memastikan widget masih ada di tree
    if (!mounted) return;

    try {
      final data = jsonDecode(qrCodeData) as Map<String, dynamic>;
      final ruangId = data['ruangId'] as String?;
      final alatId = data['alatId'] as String?;

      if (ruangId != null && alatId != null) {
        context.read<MonitoringProvider>().toggleAlatStatus(ruangId, alatId);

        // Beri umpan balik dan tutup halaman scanner
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status alat berhasil diubah!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        throw const FormatException('Format QR Code tidak sesuai.');
      }
    } catch (e) {
      // Jika format QR salah atau terjadi error lain
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: QR Code tidak valid atau tidak dikenali.'),
          backgroundColor: AppColors.error,
        ),
      );
      // Kembali siap untuk memindai lagi setelah jeda singkat
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pindai QR Code Alat'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Widget utama dari package mobile_scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              if (_isProcessing) return; // Jika sedang memproses, abaikan deteksi baru

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? qrCodeValue = barcodes.first.rawValue;
                if (qrCodeValue != null) {
                  setState(() {
                    _isProcessing = true; // Kunci proses agar tidak berjalan ganda
                  });
                  _handleQrCode(qrCodeValue);
                }
              }
            },
          ),
          // UI Overlay untuk memandu pengguna
          _buildScannerOverlay(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.7), width: 4),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Arahkan kamera ke QR Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.7))],
            ),
          ),
        ],
      ),
    );
  }
}
