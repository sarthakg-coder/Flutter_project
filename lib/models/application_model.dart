import 'job_model.dart';

class ApplicationModel {
  final int id;
  final int userId;
  final int jobId;
  final String? coverLetter;
  final String status;
  final String appliedAt;
  final JobModel? job;

  const ApplicationModel({
    required this.id,
    required this.userId,
    required this.jobId,
    this.coverLetter,
    required this.status,
    required this.appliedAt,
    this.job,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      jobId: json['job_id'] as int,
      coverLetter: json['cover_letter'] as String?,
      status: json['status'] as String? ?? 'Applied',
      appliedAt: json['applied_at'] as String? ?? '',
      job: json['job'] != null ? JobModel.fromJson(json['job'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'cover_letter': coverLetter,
    };
  }
}
