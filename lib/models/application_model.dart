import 'job_model.dart';

/// ApplicationModel represents a job application submitted by the candidate.
///
/// Viva/Interview explanation:
/// "It links a candidate to a job, tracks the application status
/// ('Applied', 'Reviewed', 'Interviewing', 'Accepted', 'Rejected'),
/// and embeds the associated JobModel for easy display in the UI."
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

  /// Factory constructor to parse JSON response from GET /api/v1/applications
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

  /// Converts ApplicationModel to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'cover_letter': coverLetter,
    };
  }
}
