import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'send_to_pc.dart';

class PrintOptionsPage extends StatefulWidget {
  final PlatformFile file;
  const PrintOptionsPage({super.key, required this.file});

  @override
  State<PrintOptionsPage> createState() => _PrintOptionsPageState();
}

class _PrintOptionsPageState extends State<PrintOptionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Options')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              widget.file.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.file.path == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File path is missing')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SendToPcPage(pdfFile: File(widget.file.path!)),
                    ),
                  );
                },
                child: const Text('Configure Print Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
