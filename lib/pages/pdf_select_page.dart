import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'print_options_page.dart';

class PdfSelectPage extends StatefulWidget {
  const PdfSelectPage({super.key});

  @override
  State<PdfSelectPage> createState() => _PdfSelectPageState();
}

class _PdfSelectPageState extends State<PdfSelectPage> {
  PlatformFile? selectedFile;

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );
    if (result != null) setState(() => selectedFile = result.files.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select PDF')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedFile == null) ...[
                const Icon(Icons.picture_as_pdf, size: 100, color: Colors.grey),
                const SizedBox(height: 20),
                const Text("No PDF selected", style: TextStyle(fontSize: 18)),
              ] else ...[
                const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red),
                const SizedBox(height: 20),
                Text(
                  selectedFile!.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("${(selectedFile!.size / 1024).toStringAsFixed(2)} KB"),
              ],
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: pickPdf,
                icon: const Icon(Icons.file_open),
                label: Text(selectedFile == null ? 'Pick PDF' : 'Change PDF'),
              ),
              const SizedBox(height: 20),
              if (selectedFile != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text('Next'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrintOptionsPage(file: selectedFile!),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
