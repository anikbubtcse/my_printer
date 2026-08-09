import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_printer/pages/print_status_page.dart';


class FilePrintOptions {
  File file;
  int copies;
  bool color;
  String pages;
  String sides;
  String paperSize;
  String orientation;
  String userAccountNumber;
  String accessToken;
  String paymentReference;
  String price;

  FilePrintOptions({
    required this.file,
    this.copies = 1,
    this.color = true,
    this.pages = '',
    this.sides = 'single',
    this.paperSize = 'A4',
    this.orientation = 'portrait',
    this.userAccountNumber = 'ACC123',
    this.accessToken = 'eyJ...',
    this.paymentReference = 'PAY456',
    this.price = '1.5',
  });

  Map<String, dynamic> toMap() {
    return {
      'filename': file.path.split('/').last,
      'copies': copies,
      'color': color ? 'color' : 'bw',
      'pages': pages,
      'sides': sides,
      'paper_size': paperSize,
      'orientation': orientation,
      'user_account_number': userAccountNumber,
      'access_token': accessToken,
      'payment_reference': paymentReference,
      'price': price,
    };
  }
}

class SendToPcPage extends StatefulWidget {
  final File pdfFile;

  const SendToPcPage({super.key, required this.pdfFile});

  @override
  State<SendToPcPage> createState() => _SendToPcPageState();
}



class _SendToPcPageState extends State<SendToPcPage> {
  late FilePrintOptions fileOpt;
  bool sending = false;
  final TextEditingController mobileController = TextEditingController();

  // 🔥 CHANGE THIS TO YOUR PC IP
  final String serverUrl = 'http://192.168.15.54:5000/api/print';

  @override
  void initState() {
    super.initState();
    fileOpt = FilePrintOptions(file: widget.pdfFile);
  }

  bool isValidPageRange(String value) {
    if (value.trim().isEmpty) return true;
    final regex = RegExp(r'^(\d+(-\d+)?)(,\d+(-\d+)?)*$');
    return regex.hasMatch(value.replaceAll(' ', ''));
  }

  Future<void> sendFiles() async {
    if (mobileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a mobile number')),
      );
      return;
    }

    if (!isValidPageRange(fileOpt.pages)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid page range format')),
      );
      return;
    }

    setState(() => sending = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          fileOpt.file.path,
          filename: fileOpt.file.path.split('/').last,
        ),
      );

      // ✅ Add config metadata for one file as a JSON string containing an array
      request.fields['config'] = jsonEncode([fileOpt.toMap()]);

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      setState(() => sending = false);

      if (responseData.statusCode == 201) {
        final responseBody = jsonDecode(responseData.body);
        final jobId = responseBody['job_id'];
        debugPrint("Job ID received: $jobId");

        if (!mounted) return;

        // Navigate to PrintStatusPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PrintStatusPage(
              jobId: jobId,
              baseUrl: serverUrl.replaceAll('/print', ''),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${responseData.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                hintText: 'Enter customer mobile number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileOpt.file.path.split('/').last,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 30),

                    // Pages
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Pages',
                        hintText: 'Example: 1-5 or 1,3,5-8',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => fileOpt.pages = value,
                    ),
                    const SizedBox(height: 15),

                    // Account Info
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Account Number',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => fileOpt.userAccountNumber = value,
                      controller: TextEditingController(text: fileOpt.userAccountNumber),
                    ),
                    const SizedBox(height: 15),

                    // Payment Reference
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Payment Reference',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => fileOpt.paymentReference = value,
                      controller: TextEditingController(text: fileOpt.paymentReference),
                    ),
                    const SizedBox(height: 15),

                    // Price
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => fileOpt.price = value,
                      controller: TextEditingController(text: fileOpt.price),
                    ),
                    const SizedBox(height: 20),

                    // Dropdowns for Sides, Paper Size, Orientation
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: fileOpt.sides,
                            decoration: const InputDecoration(labelText: 'Sides'),
                            items: ['single', 'double'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => fileOpt.sides = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: fileOpt.paperSize,
                            decoration: const InputDecoration(labelText: 'Paper Size'),
                            items: ['A4', 'Letter', 'Legal'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => fileOpt.paperSize = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: fileOpt.orientation,
                      decoration: const InputDecoration(labelText: 'Orientation'),
                      items: ['portrait', 'landscape'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => fileOpt.orientation = v!),
                    ),
                    const SizedBox(height: 20),

                    // Copies & Color
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Copies', style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (fileOpt.copies > 1) setState(() => fileOpt.copies--);
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${fileOpt.copies}', style: const TextStyle(fontSize: 18)),
                            IconButton(
                              onPressed: () => setState(() => fileOpt.copies++),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Color Printing', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: fileOpt.color,
                          onChanged: (v) => setState(() => fileOpt.color = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            sending
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.print),
                      onPressed: sendFiles,
                      label: const Text('Send to PC', style: TextStyle(fontSize: 18)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }
}