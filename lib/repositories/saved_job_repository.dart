import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/saved_job_model.dart';

class SavedJobRepository {
  final ApiService _apiService;

  SavedJobRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

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

  Future<void> removeSavedJob(int jobId) async {
    await _apiService.delete(
      ApiConstants.removeSavedJob(jobId),
      requiresAuth: true,
    );
  }
}
