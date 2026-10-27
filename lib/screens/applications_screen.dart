import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/application_model.dart';
import '../repositories/application_repository.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

/// ApplicationsScreen lists all jobs the candidate has submitted applications for in PostgreSQL.
class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final ApplicationRepository _applicationRepository = ApplicationRepository();

  bool _isLoading = true;
  String? _errorMessage;
  List<ApplicationModel> _applications = [];

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _applicationRepository.getMyApplications();
      if (!mounted) return;

      setState(() {
        _applications = list;
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'shortlisted':
        return Colors.green;
      case 'reviewed':
      case 'interviewing':
        return Colors.blue;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return Colors.orange;
    }
  }

  void _withdrawApplication(ApplicationModel app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Application'),
        content: Text(
          'Are you sure you want to withdraw your application for "${app.job?.title ?? "this job"}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () async {
              Navigator.pop(ctx);
              final prevList = List<ApplicationModel>.from(_applications);

              setState(() {
                _applications.removeWhere((a) => a.id == app.id);
              });

              try {
                await _applicationRepository.withdrawApplication(app.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application withdrawn successfully.')),
                );
              } catch (e) {
                if (!mounted) return;
                setState(() => _applications = prevList);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to withdraw application: $e')),
                );
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchApplications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading your applications...');
    }

    if (_errorMessage != null) {
      return ErrorRetryWidget(
        message: _errorMessage!,
        onRetry: _fetchApplications,
      );
    }

    if (_applications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: AppTheme.textSecondary.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No applications submitted yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'When you apply for a job, you can track its progress here',
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
      itemCount: _applications.length,
      itemBuilder: (context, index) {
        final app = _applications[index];
        final job = app.job;
        final statusColor = _getStatusColor(app.status);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job?.title ?? 'Position #${app.jobId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        app.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  job?.companyName ?? 'Company',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                if (app.coverLetter != null && app.coverLetter!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Note: "${app.coverLetter}"',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Applied: ${app.appliedAt.split('T').first}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    Row(
                      children: [
                        if (job != null)
                          TextButton(
                            onPressed: () => context.push('/jobs/${job.id}'),
                            child: const Text('View Job', style: TextStyle(fontSize: 13)),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.errorColor),
                          tooltip: 'Withdraw Application',
                          onPressed: () => _withdrawApplication(app),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
