import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gate_pass_project/screens/view_job_details/bloc/job_details_bloc.dart';

class JobDetailScreen extends StatefulWidget {
  final String companyName;
  final String logo;
  final int companyId;

  const JobDetailScreen({
    super.key,
    required this.companyName,
    required this.logo,
    required this.companyId,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  String? companyName;
  String? logo;
  late final JobDetailsBloc bloc;
  File? _selectedResume;
    bool isloading = false;
  @override
  void initState() {
    super.initState();
    companyName = widget.companyName;
    logo = widget.logo;
    print(' companyId in job details view: ${widget.companyId}');
    bloc = JobDetailsBloc();
    bloc.add(JobDetailsEvent.viewJobDetails(companyId: widget.companyId));
  }

  Future<void> _showApplyDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload your resume'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('Choose Resume File'),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'doc', 'docx'],
                );
                if (result != null && result.files.single.path != null) {
                  setState(() {
                    _selectedResume = File(result.files.single.path!);
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            if (_selectedResume != null)
              Text('Selected: ${_selectedResume!.path.split('/').last}'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Upload'),
            onPressed: () {
              if (_selectedResume != null) {
                // Implement your upload logic here
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Resume uploaded: ${_selectedResume!.path.split('/').last}',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a resume file')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 227, 227),
      appBar: AppBar(
        title: Text(
          widget.companyName,
          style: TextStyle(
            color: const Color.fromARGB(221, 68, 68, 68),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo[200],
      ),
      body: BlocConsumer<JobDetailsBloc, JobDetailsState>(
       listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {
              setState(() {
                isloading = true;
              });
            },
            success: (response) async {
              
                setState(() {
                  isloading = false;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("User login successful"),
                      backgroundColor: Colors.green,
                    ),
                  );
                 
                });
             
            },

            error: (error) {
              setState(() {
                isloading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: $error"),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
        builder: (context, state) =>Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Card(
                child: Column(
                  children: [
                    Container(
                      height: h * 0.2,
                      width: w * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        shape: BoxShape.rectangle,
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(40),
                        image: (logo != null && logo!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(logo!),
                                fit: BoxFit.fitWidth,
                              )
                            : null,
                      ),
                      child: (logo == null || logo!.isEmpty)
                          ? const Icon(
                              Icons.business,
                              size: 50,
                              color: Colors.grey,
                            )
                          : null,
        
                      // child: CircleAvatar(
                      //   radius: 90,
                      //   backgroundColor: Colors.grey[200],
                      //   backgroundImage: (logo != null && logo!.isNotEmpty)
                      //       ? NetworkImage(logo!)
                      //       : null,
                      //   child: (logo == null || logo!.isEmpty)
                      //       ? const Icon(Icons.business, size: 50, color: Colors.grey)
                      //       : null,
                      // ),
                    ),
        
                    const SizedBox(height: 12),
                    Text(
                      widget.companyName,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 107, 125, 158),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  //   final job = jobs[];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey[200],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      //' job['title']',
                                      'title',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(
                                            // job['job_type'],
                                            'job_type',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            36,
                                            53,
                                            146,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Icon(
                                          Icons.place,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          // ' job['place']'
                                          'place',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _infoRow('Date', 'date'),
                          _infoRow('Salary', 'salary'),
                          _infoRow('Vacancy', 'vacancy'),
                          _infoRow('Qualifications', 'qualifications'),
                          _infoRow('Responsibilities', 'responsibilities'),
                          _infoRow('Description', 'description'),
        
                          const SizedBox(height: 20.0),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 34, 53, 165),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                'Apply Now',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        

      )
        
      );
    
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
