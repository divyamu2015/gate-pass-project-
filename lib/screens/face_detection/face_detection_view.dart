import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gate_pass_project/screens/face_detection/face_detection_model.dart';
import 'package:gate_pass_project/screens/face_detection/face_detection_service.dart';
import 'package:gate_pass_project/screens/home_page/home_page.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({
    super.key,
    required this.studId,
    required this.studentId,
  });
  final int studId;
  final String studentId;
  @override
  // ignore: library_private_types_in_public_api
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final AttendanceService _attendanceService = AttendanceService();
  int? studId;
  String? studentId;
  @override
  void initState() {
    super.initState();
    studId = widget.studId;
    studentId = widget.studentId;
    print("face detection =$studId");
    print("face detection =$studentId");
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }
    if (studentId == null || studentId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Student ID missing. Please try again or contact support.',
          ),
        ),
      );
    }
    try { 
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Marking attendance...')));

      final AttendanceResponse response = await _attendanceService
          .markAttendance(imageFile: _image!, studentId: studentId!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Success! ${response.message}'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home screen after successful attendance
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen(studId: studId!,studentId: studentId!,)),
      );
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()), // Show actual error message
          backgroundColor: Colors.red,
        ),
      );
    }
    // print()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 140, 192, 235),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(studId: studId!,studentId: studentId!,),
            ),
          ),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Mark Attendance'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Face Detection',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a clear photo for attendance.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 140,
              backgroundImage: _image != null ? FileImage(_image!) : null,
              child: _image == null
                  ? Icon(Icons.person, size: 72, color: Colors.grey[400])
                  : null,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: const Color.fromARGB(255, 151, 188, 252),
                  ),
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color.fromARGB(255, 136, 161, 230),
                shape: const StadiumBorder(),
                elevation: 2,
              ),
              onPressed: _image != null ? _uploadImage : null,
              child: const Text(
                "Upload & Mark Attendance",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
