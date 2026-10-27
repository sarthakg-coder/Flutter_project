import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/saved_job_model.dart';
import '../repositories/saved_job_repository.dart';
import '../widgets/error_widget.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';

/// SavedJobsScreen displays the user's bookmarked/wishlisted jobs fetched from PostgreSQL.
class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  final SavedJobRepository _savedJobRepository = SavedJobRepository();

  bool _isLoading = true;
  String? _errorMessage;
  List<SavedJobModel> _savedJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchSavedJobs();
  }

  Future<void> _fetchSavedJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _savedJobRepository.getSavedJobs();
      if (!mounted) return;

      setState(() {
        _savedJobs = list;
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

  Future<void> _removeJob(SavedJobModel item) async {
    final int targetJobId = item.jobId;

    // Optimistic removal from UI list
    setState(() {
      _savedJobs.removeWhere((s) => s.id == item.id);
    });

    try {
      await _savedJobRepository.removeSavedJob(targetJobId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ${item.job?.title ?? "Job"} from wishlist'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Revert if API failed
      if (!mounted) return;
      _fetchSavedJobs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove saved job: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSavedJobs,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading your saved jobs...');
    }

    if (_errorMessage != null) {
      return ErrorRetryWidget(
        message: _errorMessage!,
        onRetry: _fetchSavedJobs,
      );
    }

    if (_savedJobs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bookmark_border_rounded,
                  size: 64,
                  color: AppTheme.textSecondary.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No saved jobs yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Jobs you bookmark will appear here for easy access',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _savedJobs.length,
      itemBuilder: (context, index) {
        final saved = _savedJobs[index];
        final job = saved.job;
        if (job == null) return const SizedBox.shrink();

        return Dismissible(
          key: Key(saved.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) => _removeJob(saved),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: JobCard(
              id: job.id,
              title: job.title,
              companyName: job.companyName,
              location: job.location,
              jobType: job.jobType,
              salary: job.salary,
              isSaved: true,
              onTap: () => context.push('/jobs/${job.id}').then((_) => _fetchSavedJobs()),
              onSaveToggle: () => _removeJob(saved),
            ),
          ),
        );
      },
    );
  }
}
