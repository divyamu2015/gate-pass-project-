import 'package:flutter/material.dart';

class JobDetailScreen extends StatefulWidget {
  // final int companyId;
  // final String companyName;
  // final String companyLogo;
  // final List<dynamic> jobs; // Replace dynamic with your job model type if available

  const JobDetailScreen({
    super.key,
    // required this.companyId,
    // required this.companyName,
    // required this.companyLogo,
    // required this.jobs,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('companyName'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('companyLogo'),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(height: 12),
                Text(
                  'companyName',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
              ],
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
                              backgroundImage: NetworkImage(
                                 // 'http://127.0.0.1:8003{job['logo']}'
                                ' http://127.0.0.1:8003/'
                                  ),
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
                                        backgroundColor: Colors.deepPurple,
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(Icons.place,
                                          color: Colors.grey[600]),
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
              style:
                  const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
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
