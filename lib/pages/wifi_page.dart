import 'package:flutter/material.dart';
import 'package:my_printer/pages/pdf_select_page.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiConnectPage extends StatefulWidget {
  final String qrData;
  const WifiConnectPage({super.key, required this.qrData});

  @override
  State<WifiConnectPage> createState() => _WifiConnectPageState();
}

class _WifiConnectPageState extends State<WifiConnectPage> {
  String ssid = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    parseQR();
  }

  void parseQR() {
    try {
      final data = widget.qrData;

      // Example: WIFI:T:WPA;S:MyWifi;P:Password;;
      final ssidMatch = RegExp(r'S:([^;]+)').firstMatch(data);
      final passMatch = RegExp(r'P:([^;]+)').firstMatch(data);

      ssid = ssidMatch?.group(1) ?? '';
      password = passMatch?.group(1) ?? '';

      if (ssid.isEmpty) {
        throw Exception('SSID not found in QR code');
      }
    } catch (e) {
      debugPrint('QR Parse Error: $e');
    }
  }

  Future<void> connectWifi() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Connecting to WiFi...')));

    try {
      await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        security: NetworkSecurity.WPA,
        withInternet: false,
      );

      // Wait until Android finishes connection
      await Future.delayed(const Duration(seconds: 4));

      // ✅ RELIABLE CHECK
      final isConnected = await WiFiForIoTPlugin.isConnected();

      if (isConnected) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('WiFi Connected')));

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PdfSelectPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to WiFi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('WiFi error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect WiFi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('SSID: $ssid'),
            Text('Password: $password'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: connectWifi,
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}
