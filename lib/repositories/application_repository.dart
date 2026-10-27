import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/application_model.dart';

/// ApplicationRepository handles job application lifecycle.
///
/// Demonstrates:
/// - HTTP POST (apply for a job)
/// - HTTP GET (fetch all submitted applications)
/// - HTTP DELETE (withdraw an application)
class ApplicationRepository {
  final ApiService _apiService;

  ApplicationRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Submits an application for a specific job (HTTP POST).
  Future<ApplicationModel> applyForJob({
    required int jobId,
    String? coverLetter,
  }) async {
    final response = await _apiService.post(
      ApiConstants.applications,
      body: {
        'job_id': jobId,
        'cover_letter': coverLetter?.trim(),
      },
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return ApplicationModel.fromJson(response);
    }

    throw ApiException('Failed to parse application response.');
  }

  /// Retrieves all applications submitted by current candidate (HTTP GET).
  Future<List<ApplicationModel>> getMyApplications() async {
    final response = await _apiService.get(
      ApiConstants.applications,
      requiresAuth: true,
    );

    if (response is List) {
      return response
          .map((item) => ApplicationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Withdraws a submitted application (HTTP DELETE).
  Future<void> withdrawApplication(int applicationId) async {
    await _apiService.delete(
      ApiConstants.withdrawApplication(applicationId),
      requiresAuth: true,
    );
  }
}
