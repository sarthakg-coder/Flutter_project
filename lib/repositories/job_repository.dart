import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/job_model.dart';

class JobRepository {
  final ApiService _apiService;

  JobRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<JobModel>> getJobs({
    String? search,
    String? jobType,
  }) async {
    final queryParameters = <String, String>{};

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (jobType != null &&
        jobType.trim().isNotEmpty &&
        jobType.trim().toLowerCase() != 'all') {
      queryParameters['job_type'] = jobType.trim();
    }

    final response = await _apiService.get(
      ApiConstants.jobs,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      requiresAuth: true,
    );

    if (response is List) {
      return response
          .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<JobModel> getJobById(int id) async {
    final response = await _apiService.get(
      ApiConstants.jobDetails(id),
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return JobModel.fromJson(response);
    }

    throw ApiException('Failed to parse job details response.');
  }
}
