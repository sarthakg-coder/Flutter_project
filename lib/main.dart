import 'package:flutter/material.dart';
import 'app/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JobFinderApp());
}

/// JobFinderApp is the root widget of our mobile application.
/// It configures:
/// 1. GoRouter routing via MaterialApp.router
/// 2. Global light theme from AppTheme
/// 3. App title and debugging banners
class JobFinderApp extends StatelessWidget {
  const JobFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JobFinder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
