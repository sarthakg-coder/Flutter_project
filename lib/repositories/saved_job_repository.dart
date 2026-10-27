import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/saved_job_model.dart';

/// SavedJobRepository manages user bookmarks/wishlist.
///
/// Demonstrates:
/// - HTTP GET (fetch saved jobs)
/// - HTTP POST (bookmark a job)
/// - HTTP DELETE (remove a job from bookmarks)
class SavedJobRepository {
  final ApiService _apiService;

  SavedJobRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Retrieves all jobs bookmarked by the logged-in candidate (HTTP GET).
  Future<List<SavedJobModel>> getSavedJobs() async {
    final response = await _apiService.get(
      ApiConstants.savedJobs,
      requiresAuth: true,
    );

    if (response is List) {
      return response
          .map((item) => SavedJobModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Saves a job to candidate's wishlist (HTTP POST).
  Future<SavedJobModel> saveJob(int jobId) async {
    final response = await _apiService.post(
      ApiConstants.savedJobs,
      body: {'job_id': jobId},
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return SavedJobModel.fromJson(response);
    }

    throw ApiException('Failed to parse saved job response.');
  }

  /// Removes a job from candidate's wishlist (HTTP DELETE).
  Future<void> removeSavedJob(int jobId) async {
    await _apiService.delete(
      ApiConstants.removeSavedJob(jobId),
      requiresAuth: true,
    );
  }
}
