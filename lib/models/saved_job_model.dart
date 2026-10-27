import 'job_model.dart';

/// SavedJobModel represents a job bookmarked by the user to their wishlist.
///
/// Viva/Interview explanation:
/// "It links the user to a job ID and allows candidate quick access
/// to jobs they plan to apply for later."
class SavedJobModel {
  final int id;
  final int userId;
  final int jobId;
  final String? createdAt;
  final JobModel? job;

  const SavedJobModel({
    required this.id,
    required this.userId,
    required this.jobId,
    this.createdAt,
    this.job,
  });

  /// Factory constructor to parse JSON response from GET /api/v1/saved-jobs
  factory SavedJobModel.fromJson(Map<String, dynamic> json) {
    return SavedJobModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      jobId: json['job_id'] as int,
      createdAt: json['created_at'] as String?,
      job: json['job'] != null ? JobModel.fromJson(json['job'] as Map<String, dynamic>) : null,
    );
  }

  /// Converts SavedJobModel to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
    };
  }
}
