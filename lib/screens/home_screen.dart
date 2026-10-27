import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/job_model.dart';
import '../repositories/job_repository.dart';
import '../repositories/saved_job_repository.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

/// HomeScreen is the central hub for the candidate.
/// Displays greeting, quick shortcuts, and featured jobs loaded from FastAPI + PostgreSQL.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JobRepository _jobRepository = JobRepository();
  final SavedJobRepository _savedJobRepository = SavedJobRepository();

  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<JobModel> _featuredJobs = [];

  @override
  void initState() {
    super.initState();
    _loadFeaturedJobs();
  }

  /// Fetches jobs from the backend API using JobRepository
  Future<void> _loadFeaturedJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jobs = await _jobRepository.getJobs();
      if (!mounted) return;

      setState(() {
        _featuredJobs = jobs;
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

  /// Toggles saving or unsaving a job in the wishlist
  Future<void> _toggleSaveJob(JobModel job) async {
    final bool wasSaved = job.isSaved;
    final int targetJobId = job.id;

    // Optimistically update local UI state with setState
    setState(() {
      _featuredJobs = _featuredJobs.map((j) {
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
      // Revert if API call fails
      if (!mounted) return;
      setState(() {
        _featuredJobs = _featuredJobs.map((j) {
          if (j.id == targetJobId) {
            return j.copyWith(isSaved: wasSaved);
          }
          return j;
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating saved status: $e')),
      );
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        context.push('/saved-jobs').then((_) => _loadFeaturedJobs());
        break;
      case 2:
        context.push('/applications');
        break;
      case 3:
        context.push('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.work, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'JobFinder',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search Jobs',
            onPressed: () => context.push('/search').then((_) => _loadFeaturedJobs()),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeaturedJobs,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find Your Dream Job Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore high quality opportunities matched for your skills.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      onPressed: () => context.push('/jobs').then((_) => _loadFeaturedJobs()),
                      icon: const Icon(Icons.explore_outlined, size: 18),
                      label: const Text('Browse All Jobs'),
                    ),
                  ],
                ),
              ),

              // Quick Category Shortcuts
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.list_alt_rounded,
                        title: 'All Jobs',
                        color: Colors.blue.shade50,
                        iconColor: Colors.blue.shade700,
                        onTap: () => context.push('/jobs').then((_) => _loadFeaturedJobs()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.bookmark_outline,
                        title: 'Saved Jobs',
                        color: Colors.purple.shade50,
                        iconColor: Colors.purple.shade700,
                        onTap: () => context.push('/saved-jobs').then((_) => _loadFeaturedJobs()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.assignment_turned_in_outlined,
                        title: 'Applications',
                        color: Colors.teal.shade50,
                        iconColor: Colors.teal.shade700,
                        onTap: () => context.push('/applications'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section Header: Featured Jobs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Opportunities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/jobs').then((_) => _loadFeaturedJobs()),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),

              // Content based on state
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: LoadingWidget(message: 'Loading opportunities...'),
                )
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ErrorRetryWidget(
                    message: _errorMessage!,
                    onRetry: _loadFeaturedJobs,
                  ),
                )
              else if (_featuredJobs.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No jobs available at this moment.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                ..._featuredJobs.take(5).map((job) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: JobCard(
                      id: job.id,
                      title: job.title,
                      companyName: job.companyName,
                      location: job.location,
                      jobType: job.jobType,
                      salary: job.salary,
                      isSaved: job.isSaved,
                      onTap: () => context.push('/jobs/${job.id}').then((_) => _loadFeaturedJobs()),
                      onSaveToggle: () => _toggleSaveJob(job),
                    ),
                  );
                }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Applied',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
