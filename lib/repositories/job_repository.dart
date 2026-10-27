import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/job_model.dart';

/// JobRepository handles fetching job listings and single job details.
///
/// Viva/Interview explanation:
/// "The repository interacts with ApiConstants and ApiService.
/// It converts raw JSON lists and maps into strongly-typed JobModel objects
/// before returning them to our StatefulWidgets."
class JobRepository {
  final ApiService _apiService;

  JobRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Fetches job listings with optional search query and job type filter (HTTP GET).
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

  /// Fetches complete details of a specific job by ID (HTTP GET).
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
