import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// ApiConstants holds all API endpoints and server configuration.
/// Beginners tip for Viva:
/// "Never hardcode URLs in UI screens. By keeping all paths in ApiConstants,
/// if the backend URL or route changes, we only need to update it in one place."
class ApiConstants {
  // Base server URL
  // - Android emulator accesses localhost at 10.0.2.2
  // - Windows desktop, Chrome web, and iOS simulator access localhost at 127.0.0.1
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api/v1';
      }
    } catch (_) {
      // Fallback
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  // Network timeout duration
  static const Duration timeoutDuration = Duration(seconds: 15);

  // Authentication endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/me';

  // Job endpoints
  static const String jobs = '/jobs';
  static String jobDetails(int id) => '/jobs/$id';

  // Saved Jobs endpoints
  static const String savedJobs = '/saved-jobs';
  static String removeSavedJob(int jobId) => '/saved-jobs/$jobId';

  // Application endpoints
  static const String applications = '/applications';
  static String withdrawApplication(int applicationId) => '/applications/$applicationId';
}
