import 'package:flutter/material.dart';
import 'package:gate_pass_project/constant_uri.dart';
import 'package:gate_pass_project/screens/list_of_jobs/list_of_jobs_model.dart';
import 'package:gate_pass_project/screens/list_of_jobs/list_of_jobs_service.dart';

class CompanyListView extends StatefulWidget {
  const CompanyListView({super.key,required this.userId});
  final int userId;

  @override
  State<CompanyListView> createState() => _CompanyListViewState();
}

class _CompanyListViewState extends State<CompanyListView> {
  late Future<List<CompanyModel>> futureCompanies;

  @override
  void initState() {
    super.initState();
    futureCompanies = fetchCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companies'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<CompanyModel>>(
        future: futureCompanies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No companies found"));
          }

          final companies = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  // Display the logo
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: 25,
                    backgroundImage: NetworkImage(
                      "$imageBaseUrl${company.logo}",
                    ),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Fallback to a default icon if the image fails to load
                      return;
                    },
                    child: company.logo.isEmpty
                        ? const Icon(
                            Icons.business,
                            size: 40,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  // Display the name
                  title: Text(
                    company.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  // Display the description
                  subtitle: Text(
                    company.description,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  onTap: () {
                    // Optional: Add navigation or other actions here.
                    print("Tapped on ${company.name}");
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
