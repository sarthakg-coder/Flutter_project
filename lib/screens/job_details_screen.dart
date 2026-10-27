import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/theme/app_theme.dart';
import '../models/job_model.dart';
import '../repositories/application_repository.dart';
import '../repositories/job_repository.dart';
import '../repositories/saved_job_repository.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

/// JobDetailsScreen displays complete information about a specific job
/// and allows the candidate to submit an application or bookmark the role.
class JobDetailsScreen extends StatefulWidget {
  final int jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final JobRepository _jobRepository = JobRepository();
  final SavedJobRepository _savedJobRepository = SavedJobRepository();
  final ApplicationRepository _applicationRepository = ApplicationRepository();

  JobModel? _job;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSaved = false;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  Future<void> _loadJobDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final job = await _jobRepository.getJobById(widget.jobId);
      if (!mounted) return;

      setState(() {
        _job = job;
        _isSaved = job.isSaved;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSave() async {
    final bool previousSaved = _isSaved;
    setState(() => _isSaved = !previousSaved);

    try {
      if (previousSaved) {
        await _savedJobRepository.removeSavedJob(widget.jobId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job removed from saved list')),
        );
      } else {
        await _savedJobRepository.saveJob(widget.jobId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job saved to your wishlist!'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaved = previousSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update bookmark: $e')),
      );
    }
  }

  void _showApplyDialog() {
    final coverLetterController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Apply for this Job',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cover Letter / Note to Recruiter (Optional):',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: coverLetterController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Explain why your skills and experience make you a great fit...',
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Submit Application',
                    isLoading: _isApplying,
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(ctx);
                      setState(() => _isApplying = true);

                      try {
                        await _applicationRepository.applyForJob(
                          jobId: widget.jobId,
                          coverLetter: coverLetterController.text,
                        );

                        if (!mounted) return;
                        setState(() => _isApplying = false);

                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Application submitted successfully! Track it under Applied Jobs.'),
                            backgroundColor: AppTheme.accentColor,
                          ),
                        );
                      } on ApiException catch (e) {
                        if (!mounted) return;
                        setState(() => _isApplying = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(e.message),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        setState(() => _isApplying = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Failed to submit application: $e'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const LoadingWidget(message: 'Loading job details...'),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: ErrorRetryWidget(
          message: _errorMessage!,
          onRetry: _loadJobDetails,
        ),
      );
    }

    final job = _job!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? AppTheme.primaryColor : null,
            ),
            tooltip: _isSaved ? 'Remove from saved' : 'Save job',
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company & Title Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : 'J',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.companyName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Key Info Cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.location_on_outlined,
                      'Location',
                      job.location,
                    ),
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: AppTheme.borderColor,
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.access_time_outlined,
                      'Type',
                      job.jobType,
                    ),
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: AppTheme.borderColor,
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.payments_outlined,
                      'Salary',
                      job.salary ?? 'Negotiable',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'Job Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              job.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Required Skills
            if (job.skillsList.isNotEmpty) ...[
              const Text(
                'Required Skills',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.skillsList.map((skill) => _buildSkillChip(skill)).toList(),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.borderColor)),
        ),
        child: CustomButton(
          text: 'Apply Now',
          isLoading: _isApplying,
          onPressed: _showApplyDialog,
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
