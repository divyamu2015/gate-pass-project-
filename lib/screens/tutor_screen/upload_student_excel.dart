import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// A persistent Excel uploader + local store + delete-per-row implementation.
class StudentExcelUploader extends StatefulWidget {
  const StudentExcelUploader({super.key});

  @override
  State<StudentExcelUploader> createState() => _StudentExcelUploaderState();
}

class _StudentExcelUploaderState extends State<StudentExcelUploader> {
  bool _uploading = false;
  String? _message;
  List<Map<String, String>> _rows = []; // list of row-maps (headers -> value)
  List<String> _headers = [];

  final String _localFileName = 'students_data.json';
  final String uploadUrl =
      'https://417sptdw-8003.inc1.devtunnels.ms/userapp/student/upload/';
  final String studentDeleteBase =
      'https://417sptdw-8003.inc1.devtunnels.ms/userapp/student/';

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  /// Get file handle in app documents
  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_localFileName');
  }

  /// Save current _rows and _headers to local JSON file
  Future<void> _saveLocalData() async {
    try {
      final file = await _localFile();
      final jsonObj = {
        'headers': _headers,
        'rows': _rows,
      };
      await file.writeAsString(json.encode(jsonObj));
    } catch (e) {
      // ignore or log
      debugPrint('Failed saving local data: $e');
    }
  }

  /// Load local JSON if exists
  Future<void> _loadLocalData() async {
    try {
      final file = await _localFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonObj = json.decode(content);
        final hdrs = List<String>.from(jsonObj['headers'] ?? []);
        final rows = List<Map<String, dynamic>>.from(jsonObj['rows'] ?? []);
        setState(() {
          _headers = hdrs;
          _rows = rows
              .map((m) => m.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Failed loading local data: $e');
    }
  }

  /// Clear local persisted JSON
  Future<void> _clearLocalData() async {
    try {
      final file = await _localFile();
      if (await file.exists()) {
        await file.delete();
      }
      setState(() {
        _rows.clear();
        _headers.clear();
        _message = 'Local data cleared';
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to clear local data: $e';
      });
    }
  }

  /// Attempt to find a student id value in a row map (common heuristics)
  /// Returns null if no id found.
  String? _extractStudentId(Map<String, String> row) {
    // common column name patterns
    for (final entry in row.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value.trim();
      if (key.contains('student') && key.contains('id') && value.isNotEmpty) {
        return value;
      }
    }
    // fallback: any column name with 'id', or a numeric-looking cell
    for (final entry in row.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value.trim();
      if (key.contains('id') && value.isNotEmpty) return value;
    }
    // fallback: any numeric cell that could be id
    for (final entry in row.entries) {
      final value = entry.value.trim();
      if (RegExp(r'^\d+$').hasMatch(value)) return value;
    }
    return null;
  }

  /// Delete a student from server (if id known) and remove locally
  Future<void> _deleteRowAt(int index) async {
    final row = _rows[index];
    final id = _extractStudentId(row);
    bool serverOk = false;

    if (id != null) {
      // try server delete
      try {
        final uri = Uri.parse('$studentDeleteBase$id/');
        final resp = await http.delete(uri);
        if (resp.statusCode == 204 || resp.statusCode == 200) {
          serverOk = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deleted on server')),
          );
        } else {
          // server responded but not deleted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server delete failed: ${resp.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server delete error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No student id found for server delete')),
      );
    }

    // Remove locally regardless (if you want to only remove when serverOk set guard here)
    setState(() {
      _rows.removeAt(index);
    });
    await _saveLocalData();
  }

  /// pick file, parse, upload and persist
  Future<void> _pickAndUploadExcel() async {
    setState(() {
      _uploading = true;
      _message = null;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result == null || result.files.isEmpty || result.files.first.bytes == null) {
      setState(() {
        _uploading = false;
        _message = "No file selected";
      });
      return;
    }

    final Uint8List fileBytes = result.files.first.bytes!;
    final String fileName = result.files.first.name;

    try {
      // 1) Parse Excel for UI
      final excel = Excel.decodeBytes(fileBytes);
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];

      if (sheet == null || sheet.rows.isEmpty) {
        setState(() {
          _message = "Excel has no data";
          _uploading = false;
        });
        return;
      }

      // Build headers & row maps
      final parsedHeaders = sheet.rows.first.map((c) => c?.value.toString() ?? '').toList();
      final parsedRows = <Map<String, String>>[];
      for (int r = 1; r < sheet.rows.length; r++) {
        final row = sheet.rows[r];
        final mapRow = <String, String>{};
        for (int c = 0; c < parsedHeaders.length; c++) {
          final header = parsedHeaders[c].toString();
          final value = c < row.length ? (row[c]?.value.toString() ?? '') : '';
          mapRow[header] = value;
        }
        parsedRows.add(mapRow);
      }

      // 2) Update local UI and persist immediately (so data remains even if upload fails)
      setState(() {
        _headers = parsedHeaders;
        // append to existing rows rather than overwrite? you can choose. We'll append.
        _rows.addAll(parsedRows);
      });
      await _saveLocalData();

      // 3) Upload file to backend (multipart)
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

      final streamedResp = await request.send();
      final respBody = await streamedResp.stream.bytesToString();

      if (streamedResp.statusCode == 201 || streamedResp.statusCode == 200) {
        setState(() {
          _message = "Student data uploaded successfully";
        });
      } else {
        // show server response for debugging; we already saved locally
        setState(() {
          _message = "Upload failed: ${streamedResp.statusCode}, $respBody";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error parsing/uploading: $e";
      });
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  /// helper to build DataTable from _headers/_rows (with delete icon)
  Widget _buildTable() {
    if (_rows.isEmpty || _headers.isEmpty) {
      return const Center(child: Text("No data loaded"));
    }

    // Build columns plus a delete column
    final columns = _headers
        .map((h) => DataColumn(
              label: Text(
                h,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ))
        .toList();

    // Add actions column
    columns.add(const DataColumn(label: Text('Actions')));

    final rows = _rows.asMap().entries.map((entry) {
      final idx = entry.key;
      final row = entry.value;
      final cells = _headers.map((h) => DataCell(Text(row[h] ?? ''))).toList();

      // add delete cell
      cells.add(DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete'),
                      content: const Text('Delete this student (local + server if possible)?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                      ],
                    ),
                  ) ??
                  false;
              if (!confirmed) return;
              await _deleteRowAt(idx);
            },
          ),
        ],
      )));

      return DataRow(cells: cells);
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(columns: columns, rows: rows),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Excel Upload"),
        actions: [
          IconButton(
            tooltip: 'Clear local data',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Clear local data'),
                      content: const Text('This will remove all locally saved entries. Continue?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
                      ],
                    ),
                  ) ??
                  false;
              if (!confirm) return;
              await _clearLocalData();
            },
          ),
        ],
      ),
      body: _uploading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Excel"),
                    onPressed: _pickAndUploadExcel,
                  ),
                  const SizedBox(height: 12),
                  if (_message != null) ...[
                    Text(
                      _message!,
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Table area
                  Expanded(child: _buildTable()),
                ],
              ),
            ),
    );
  }
}
