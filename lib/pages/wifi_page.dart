import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:my_printer/pages/pdf_select_page.dart';

class WifiConnectPage extends StatefulWidget {
  final String qrData;

  const WifiConnectPage({
    super.key,
    required this.qrData,
  });

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

      final ssidMatch = RegExp(r'S:([^;]*)').firstMatch(data);
      final passMatch = RegExp(r'P:([^;]*)').firstMatch(data);

      ssid = ssidMatch?.group(1) ?? '';
      password = passMatch?.group(1) ?? '';

      if (ssid.isEmpty) {
        throw Exception("SSID not found in QR code");
      }
    } catch (e) {
      debugPrint("QR Parse Error: $e");
    }
  }

  Future<void> checkConnection() async {
    try {
      final currentSSID = await WiFiForIoTPlugin.getSSID();

      final connectedSSID = currentSSID?.replaceAll('"', '');

      if (!mounted) return;

      if (connectedSSID == ssid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("WiFi Connected"),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PdfSelectPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please connect to '$ssid' before continuing.",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error checking WiFi: $e"),
        ),
      );
    }
  }

  void openWifiSettings() {
    AppSettings.openAppSettings(
      type: AppSettingsType.wifi,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect WiFi"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi,
              size: 90,
              color: Colors.blue,
            ),

            const SizedBox(height: 25),

            const Text(
              "Scan successful!\n\nConnect your phone to the WiFi below.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Text(
                      "WiFi Name (SSID)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    SelectableText(
                      ssid,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),

                    const Divider(height: 30),

                    const Text(
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    SelectableText(
                      password,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text("Open WiFi Settings"),
                onPressed: openWifiSettings,
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text("I've Connected"),
                onPressed: checkConnection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}