import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api/v1';
      }
    } catch (_) {
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  static const Duration timeoutDuration = Duration(seconds: 15);

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/me';

  static const String jobs = '/jobs';
  static String jobDetails(int id) => '/jobs/$id';

  static const String savedJobs = '/saved-jobs';
  static String removeSavedJob(int jobId) => '/saved-jobs/$jobId';

  static const String applications = '/applications';
  static String withdrawApplication(int applicationId) => '/applications/$applicationId';
}
