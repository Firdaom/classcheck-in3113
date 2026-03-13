import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _resolved = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openManualEntry() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter QR code manually'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'QR value',
              hintText: 'CLS-2026-SEC01',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                Navigator.of(context).pop(value.isEmpty ? null : value);
              },
              child: const Text('Use code'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    Navigator.of(context).pop(result);
  }

  void _handleDetection(String? value) {
    if (_resolved || value == null || value.trim().isEmpty) {
      return;
    }

    _resolved = true;
    Navigator.of(context).pop(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan class QR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              final value = barcodes.isEmpty ? null : barcodes.first.rawValue;
              _handleDetection(value);
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Point the camera at the classroom QR code.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'If camera scanning is not available, enter the QR value manually.',
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                      onPressed: _openManualEntry,
                      icon: const Icon(Icons.keyboard_alt_outlined),
                      label: const Text('Enter code manually'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}