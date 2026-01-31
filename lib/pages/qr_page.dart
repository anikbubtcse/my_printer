import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'wifi_page.dart';

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  final MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan WiFi QR',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final String? code = capture.barcodes.first.rawValue;
          print("QR DATA: $code");

          if (code != null && code.startsWith('WIFI:')) {
            controller.stop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WifiConnectPage(qrData: code)),
            );
          }
        },
      ),
    );
  }
}
