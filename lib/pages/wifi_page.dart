import 'package:flutter/material.dart';
import 'package:my_printer/pages/pdf_select_page.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> openWifiSettings() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please connect manually using device WiFi settings.')),
    );
    await WiFiForIoTPlugin.forceWifiUsage(true); // ensures app routes traffic via WiFi
    await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      final result = await Permission.locationWhenInUse.request();
      return result.isGranted;
    }
    return true;
  }

  Future<void> confirmConnection() async {
    bool granted = await requestLocationPermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required to detect WiFi SSID')),
      );
      return;
    }

    String? connectedSSID = await WiFiForIoTPlugin.getSSID();

    if (connectedSSID == null || connectedSSID.isEmpty || connectedSSID.toLowerCase() == 'unknown ssid') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to detect connected WiFi. Please ensure you are connected.')),
      );
      return;
    }

    // Normalize SSID
    String normalizedSSID = connectedSSID.replaceAll('"', '').trim();

    if (normalizedSSID.toLowerCase() == ssid.toLowerCase()) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PdfSelectPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Connected to "$normalizedSSID", not the expected "$ssid". Please connect to correct WiFi.'),
        ),
      );
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
              onPressed: openWifiSettings,
              child: const Text('Open WiFi Settings'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: confirmConnection,
              child: const Text('I am connected'),
            ),
          ],
        ),
      ),
    );
  }
}