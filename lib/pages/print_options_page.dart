import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'send_to_pc.dart';

class PrintOptionsPage extends StatefulWidget {
  final List<PlatformFile> files;
  const PrintOptionsPage({super.key, required this.files});

  @override
  State<PrintOptionsPage> createState() => _PrintOptionsPageState();
}

class _PrintOptionsPageState extends State<PrintOptionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Options')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.files.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(widget.files[index].name));
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (widget.files.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No PDF selected')),
                  );
                  return;
                }

                // Convert all PlatformFiles to File
                final filesList = widget.files
                    .where((f) => f.path != null)
                    .map((f) => File(f.path!))
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SendToPcPage(pdfFiles: filesList),
                  ),
                );
              },
              child: const Text('Send to Computer'),
            ),
          ],
        ),
      ),
    );
  }
}
