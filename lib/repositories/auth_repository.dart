import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/user_model.dart';

/// AuthRepository manages candidate authentication, registration,
/// token storage, and candidate profile operations.
///
/// Viva/Interview explanation:
/// "The Repository layer abstracts data fetching logic away from UI screens.
/// If our API endpoint changes or if we add local caching, only the repository
/// needs modification, while the UI screens remain completely unchanged."
class AuthRepository {
  final ApiService _apiService;

  AuthRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Registers a new user account, stores the received JWT token,
  /// and returns the created UserModel.
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? location,
  }) async {
    final response = await _apiService.post(
      ApiConstants.register,
      requiresAuth: false,
      body: {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'phone': phone?.trim(),
        'location': location?.trim(),
      },
    );

    if (response is Map<String, dynamic>) {
      final token = response['access_token'] as String;
      await _apiService.saveToken(token);

      final userData = response['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    }

    throw ApiException('Unexpected response format during registration.');
  }

  /// Logs in with email and password, stores JWT token,
  /// and returns the logged-in UserModel.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.login,
      requiresAuth: false,
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    if (response is Map<String, dynamic>) {
      final token = response['access_token'] as String;
      await _apiService.saveToken(token);

      final userData = response['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    }

    throw ApiException('Unexpected response format during login.');
  }

  /// Fetches the profile of the currently authenticated candidate (HTTP GET).
  Future<UserModel> getProfile() async {
    final response = await _apiService.get(
      '/users/me',
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return UserModel.fromJson(response);
    }

    throw ApiException('Failed to parse user profile response.');
  }

  /// Updates profile information (HTTP PUT).
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? location,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName.trim();
    if (phone != null) body['phone'] = phone.trim();
    if (location != null) body['location'] = location.trim();

    final response = await _apiService.put(
      '/users/me',
      requiresAuth: true,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return UserModel.fromJson(response);
    }

    throw ApiException('Failed to parse updated profile response.');
  }

  /// Clears stored JWT token on user logout.
  Future<void> logout() async {
    await _apiService.clearToken();
  }

  /// Checks if candidate has an active session token.
  Future<bool> isLoggedIn() async {
    return await _apiService.hasToken();
  }
}
