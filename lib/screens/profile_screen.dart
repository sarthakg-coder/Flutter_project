import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

/// ProfileScreen displays candidate account details fetched from PostgreSQL and logout action.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = true;
  String? _errorMessage;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _authRepository.getProfile();
      if (!mounted) return;

      setState(() {
        _user = profile;
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

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of JobFinder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () async {
              Navigator.pop(ctx);
              await _authRepository.logout();
              if (!mounted) return;
              context.go('/login');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () async {
                final result = await context.push('/profile/edit', extra: _user);
                if (result == true && mounted) {
                  _loadProfile();
                }
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading your profile...');
    }

    if (_errorMessage != null) {
      return ErrorRetryWidget(
        message: _errorMessage!,
        onRetry: _loadProfile,
      );
    }

    final user = _user!;
    final initial = user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U';

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Avatar Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profile Info List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.phone_outlined, 'Phone', user.phone ?? 'Not provided'),
                  const Divider(height: 1),
                  _buildListTile(Icons.location_on_outlined, 'Location', user.location ?? 'Not provided'),
                  const Divider(height: 1),
                  _buildListTile(Icons.email_outlined, 'Email', user.email),
                  if (user.createdAt != null) ...[
                    const Divider(height: 1),
                    _buildListTile(
                      Icons.calendar_today_outlined,
                      'Member Since',
                      user.createdAt!.split('T').first,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Edit Profile Button
            CustomButton(
              text: 'Edit Profile',
              isOutlined: true,
              icon: Icons.edit_outlined,
              onPressed: () async {
                final result = await context.push('/profile/edit', extra: user);
                if (result == true && mounted) {
                  _loadProfile();
                }
              },
            ),
            const SizedBox(height: 16),

            // Logout Button
            CustomButton(
              text: 'Log Out',
              icon: Icons.logout_rounded,
              onPressed: _confirmLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
