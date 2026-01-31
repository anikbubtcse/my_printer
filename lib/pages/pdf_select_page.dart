import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'print_options_page.dart';

class PdfSelectPage extends StatefulWidget {
  const PdfSelectPage({super.key});

  @override
  State<PdfSelectPage> createState() => _PdfSelectPageState();
}

class _PdfSelectPageState extends State<PdfSelectPage> {
  List<PlatformFile> files = [];

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result != null) setState(() => files = result.files);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select PDF')),
      body: Column(
        children: [
          ElevatedButton(onPressed: pickPdf, child: const Text('Pick PDF')),
          Expanded(
            child: ListView(
              children: files
                  .map((f) => ListTile(title: Text(f.name)))
                  .toList(),
            ),
          ),
          if (files.isNotEmpty)
            ElevatedButton(
              child: const Text('Next'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrintOptionsPage(files: files),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
