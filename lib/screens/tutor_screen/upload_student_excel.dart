import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';

class StudentExcelUploader extends StatefulWidget {
  const StudentExcelUploader({super.key});

  @override
  State<StudentExcelUploader> createState() => _StudentExcelUploaderState();
}

class _StudentExcelUploaderState extends State<StudentExcelUploader> {
  bool _uploading = false;
  String? _message;

  List<List<String>> excelData = []; // store table rows for UI

  Future<void> _pickAndUploadExcel() async {
    setState(() {
      _uploading = true;
      _message = null;
      excelData.clear();
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null) {
      setState(() {
        _uploading = false;
        _message = "No file selected";
      });
      return;
    }

    Uint8List? fileBytes = result.files.first.bytes;
    String fileName = result.files.first.name;

    try {
      /// ✅ 1. Parse Excel for UI
      final excel = Excel.decodeBytes(fileBytes as List<int>);
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];

      if (sheet != null) {
        for (var row in sheet.rows) {
          excelData.add(
            row.map((cell) => cell?.value.toString() ?? "").toList(),
          );
        }
      }

      /// ✅ 2. Upload to backend
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://417sptdw-8003.inc1.devtunnels.ms/userapp/student/upload/',
        ),
      );

      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes as List<int>, filename: fileName),
      );

      var response = await request.send();

      if (response.statusCode == 201) {
        setState(() {
          _message = "Student data uploaded successfully";
        });
      } else {
        final body = await response.stream.bytesToString();
        setState(() {
          _message = "Upload failed: ${response.statusCode}, $body";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    }

    setState(() {
      _uploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Excel Upload")),
      body: _uploading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickAndUploadExcel,
                  child: const Text("Upload Excel"),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _message!,
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
                const SizedBox(height: 20),

                /// ✅ Data Table from Excel
                Expanded(
                  child: excelData.isEmpty
                      ? const Center(child: Text("No data loaded"))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: excelData.first
                                .map(
                                  (col) => DataColumn(
                                    label: Text(
                                      col,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            rows: excelData.skip(1).map((row) {
                              return DataRow(
                                cells: row
                                    .map((val) => DataCell(Text(val)))
                                    .toList(),
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
