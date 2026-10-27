import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/job_model.dart';
import '../repositories/job_repository.dart';
import '../repositories/saved_job_repository.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

/// JobListScreen displays all available jobs with filter chips and live backend data.
class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final JobRepository _jobRepository = JobRepository();
  final SavedJobRepository _savedJobRepository = SavedJobRepository();

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Full-time', 'Remote', 'Internship'];

  bool _isLoading = true;
  String? _errorMessage;
  List<JobModel> _jobs = [];

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jobs = await _jobRepository.getJobs(
        jobType: _selectedFilter == 'All' ? null : _selectedFilter,
      );

      if (!mounted) return;

      setState(() {
        _jobs = jobs;
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

  Future<void> _toggleSaveJob(JobModel job) async {
    final bool wasSaved = job.isSaved;
    final int targetJobId = job.id;

    setState(() {
      _jobs = _jobs.map((j) {
        if (j.id == targetJobId) {
          return j.copyWith(isSaved: !wasSaved);
        }
        return j;
      }).toList();
    });

    try {
      if (wasSaved) {
        await _savedJobRepository.removeSavedJob(targetJobId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job removed from saved list')),
        );
      } else {
        await _savedJobRepository.saveJob(targetJobId);
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
      setState(() {
        _jobs = _jobs.map((j) {
          if (j.id == targetJobId) {
            return j.copyWith(isSaved: wasSaved);
          }
          return j;
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update saved job: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Jobs',
            onPressed: () => context.push('/search').then((_) => _fetchJobs()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Horizontal List
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected && _selectedFilter != filter) {
                      setState(() => _selectedFilter = filter);
                      _fetchJobs();
                    }
                  },
                );
              },
            ),
          ),

          // Job list content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchJobs,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading jobs...');
    }

    if (_errorMessage != null) {
      return ErrorRetryWidget(
        message: _errorMessage!,
        onRetry: _fetchJobs,
      );
    }

    if (_jobs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_off_outlined, size: 48, color: AppTheme.textSecondary),
              SizedBox(height: 12),
              Text(
                'No jobs found for this category.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _jobs.length,
      itemBuilder: (context, index) {
        final job = _jobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: JobCard(
            id: job.id,
            title: job.title,
            companyName: job.companyName,
            location: job.location,
            jobType: job.jobType,
            salary: job.salary,
            isSaved: job.isSaved,
            onTap: () => context.push('/jobs/${job.id}').then((_) => _fetchJobs()),
            onSaveToggle: () => _toggleSaveJob(job),
          ),
        );
      },
    );
  }
}
