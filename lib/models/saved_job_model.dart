import 'job_model.dart';

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

  factory SavedJobModel.fromJson(Map<String, dynamic> json) {
    return SavedJobModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      jobId: json['job_id'] as int,
      createdAt: json['created_at'] as String?,
      job: json['job'] != null ? JobModel.fromJson(json['job'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
    };
  }
}
