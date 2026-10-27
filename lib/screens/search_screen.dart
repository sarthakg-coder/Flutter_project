import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/job_model.dart';
import '../repositories/job_repository.dart';
import '../repositories/saved_job_repository.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

/// SearchScreen allows candidates to search jobs by keyword, title, company, or skill.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final JobRepository _jobRepository = JobRepository();
  final SavedJobRepository _savedJobRepository = SavedJobRepository();

  String _query = '';
  Timer? _debounce;
  bool _isLoading = false;
  String? _errorMessage;
  List<JobModel> _results = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() {
      _query = val.trim();
    });

    _debounce?.cancel();
    if (_query.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(_query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final jobs = await _jobRepository.getJobs(search: query);
      if (!mounted) return;

      setState(() {
        _results = jobs;
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
      _results = _results.map((j) {
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
        _results = _results.map((j) {
          if (j.id == targetJobId) {
            return j.copyWith(isSaved: wasSaved);
          }
          return j;
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update bookmark: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search title, company, or skills...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
          onSubmitted: (val) => _performSearch(val.trim()),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Searching jobs...');
    }

    if (_errorMessage != null) {
      return ErrorRetryWidget(
        message: _errorMessage!,
        onRetry: () => _performSearch(_query),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'Type a keyword to search jobs',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 56, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(
              'No jobs found matching "$_query"',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final job = _results[index];
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
            onTap: () => context.push('/jobs/${job.id}').then((_) => _performSearch(_query)),
            onSaveToggle: () => _toggleSaveJob(job),
          ),
        );
      },
    );
  }
}
