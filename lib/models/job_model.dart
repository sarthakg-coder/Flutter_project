/// JobModel represents an available job listing in the JobFinder app.
///
/// Viva/Interview explanation:
/// "Each field corresponds to a column in our PostgreSQL `jobs` table.
/// We also include helper getters like `formattedSalary` and `skillsList`
/// to make rendering in UI widgets clean and readable."
class JobModel {
  final int id;
  final String title;
  final String companyName;
  final String location;
  final String jobType; // e.g. 'Full-time', 'Part-time', 'Remote', 'Internship'
  final String? salary;
  final String description;
  final String? requiredSkills;
  final String? createdAt;
  final bool isSaved;

  const JobModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.jobType,
    this.salary,
    required this.description,
    this.requiredSkills,
    this.createdAt,
    this.isSaved = false,
  });

  /// Factory constructor to parse JSON response from GET /api/v1/jobs
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled Position',
      companyName: json['company_name'] as String? ?? 'Unknown Company',
      location: json['location'] as String? ?? 'Remote',
      jobType: json['job_type'] as String? ?? 'Full-time',
      salary: json['salary'] as String?,
      description: json['description'] as String? ?? '',
      requiredSkills: json['required_skills'] as String?,
      createdAt: json['created_at'] as String?,
      isSaved: json['is_saved'] as bool? ?? false,
    );
  }

  /// Converts JobModel to JSON Map if sending to server
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company_name': companyName,
      'location': location,
      'job_type': jobType,
      'salary': salary,
      'description': description,
      'required_skills': requiredSkills,
    };
  }

  /// Parses comma-separated skills into an easy-to-render List of Strings for chips.
  List<String> get skillsList {
    if (requiredSkills == null || requiredSkills!.trim().isEmpty) {
      return [];
    }
    return requiredSkills!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Returns a clean copy of JobModel with updated values (e.g. toggled isSaved).
  JobModel copyWith({
    int? id,
    String? title,
    String? companyName,
    String? location,
    String? jobType,
    String? salary,
    String? description,
    String? requiredSkills,
    String? createdAt,
    bool? isSaved,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      jobType: jobType ?? this.jobType,
      salary: salary ?? this.salary,
      description: description ?? this.description,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      createdAt: createdAt ?? this.createdAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
