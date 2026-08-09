import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrintStatusPage extends StatefulWidget {
  final String jobId;
  final String baseUrl; // Base URL of the print service

  const PrintStatusPage({
    super.key,
    required this.jobId,
    required this.baseUrl,
  });

  @override
  State<PrintStatusPage> createState() => _PrintStatusPageState();
}

class _PrintStatusPageState extends State<PrintStatusPage> {
  Timer? _timer;
  Map<String, dynamic>? _jobStatus;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    // Poll every 2 seconds as requested
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/status/${widget.jobId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _jobStatus = data;
            _isLoading = false;
            _error = null;
          });
        }

        // Stop polling if terminal state reached
        final status = data['status'];
        if (status == 'done' || status == 'failed') {
          _timer?.cancel();
        }
      } else if (response.statusCode == 404) {
        _timer?.cancel();
        if (mounted) {
          setState(() {
            _error = "Job not found on server.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Polling error: $e");
      // Don't stop timer on network errors, just wait for next tick
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _jobStatus?['status'] ?? 'Fetching status...';
    final progress =
        (_jobStatus?['progress_percent'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Print Status")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                status.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),
              if (status == 'printing' || status == 'received') ...[
                LinearProgressIndicator(
                  value: progress > 0 ? progress / 100 : null,
                  minHeight: 8,
                ),
                const SizedBox(height: 10),
                Text(
                  "${progress.toInt()}%",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 40),
              if (status == 'done' || status == 'failed' || _error != null)
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text("Back to Home"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
