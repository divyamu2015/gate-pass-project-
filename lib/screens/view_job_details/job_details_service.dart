import 'dart:convert';
import 'package:gate_pass_project/constant_uri.dart';
import 'package:gate_pass_project/screens/view_job_details/job_details_model.dart';
import 'package:http/http.dart' as http;

class JobService {
  // final String baseUrl = 'http://127.0.0.1:8003/userapp/job_by_company/';

  Future<List<CompanyResponseModel>> fetchJobsByCompany(int companyId) async {
    final response = await http.get(
      Uri.parse('${Urlsss.listjobDetails}/$companyId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List jobs = data['jobs'];
      return jobs
          .map((jobJson) => CompanyResponseModel.fromJson(jobJson))
          .toList();
    } else {
      throw Exception('Failed to load jobs');
    }
  }
}
