import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SendToPcPage extends StatefulWidget {
  final List<File> pdfFiles;

  const SendToPcPage({super.key, required this.pdfFiles});

  @override
  State<SendToPcPage> createState() => _SendToPcPageState();
}

class FilePrintOptions {
  File file;
  int copies;
  bool color;

  FilePrintOptions({required this.file, this.copies = 1, this.color = true});

  Map<String, dynamic> toMap() {
    return {
      'filename': file.path.split('/').last,
      'copies': copies,
      'color': color ? 'color' : 'bw',
    };
  }
}

class _SendToPcPageState extends State<SendToPcPage> {
  List<FilePrintOptions> fileOptions = [];
  bool sending = false;

  // CHANGE to your PC IP
  final String serverUrl = 'http://192.168.23.45:5000/print';

  @override
  void initState() {
    super.initState();
    fileOptions = widget.pdfFiles
        .map((f) => FilePrintOptions(file: f))
        .toList();
  }

  Future<void> sendFiles() async {
    setState(() {
      sending = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));

      // Add files
      for (var fileOpt in fileOptions) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            fileOpt.file.path,
            filename: fileOpt.file.path.split('/').last,
          ),
        );
      }

      // Add JSON metadata for all files
      List<Map<String, dynamic>> metadata = fileOptions
          .map((e) => e.toMap())
          .toList();
      request.fields['metadata'] = jsonEncode(metadata);

      var response = await request.send();

      setState(() {
        sending = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Files and options sent successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send (code ${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        sending = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send to PC')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: fileOptions.length,
                itemBuilder: (context, index) {
                  final fileOpt = fileOptions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileOpt.file.path.split('/').last,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('Copies:'),
                              IconButton(
                                onPressed: () {
                                  if (fileOpt.copies > 1) {
                                    setState(() => fileOpt.copies--);
                                  }
                                },
                                icon: const Icon(Icons.remove),
                              ),
                              Text('${fileOpt.copies}'),
                              IconButton(
                                onPressed: () {
                                  setState(() => fileOpt.copies++);
                                },
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Color printing'),
                              Switch(
                                value: fileOpt.color,
                                onChanged: (v) {
                                  setState(() => fileOpt.color = v);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            sending
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: sendFiles,
                    child: const Text('Send all to PC'),
                  ),
          ],
        ),
      ),
    );
  }
}
