import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Custom exception class to represent API and network errors clearly.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// ApiService is a centralized HTTP client for making API requests.
///
/// Features:
/// 1. Uses the official Dart `http` package only.
/// 2. Implements all 4 HTTP methods: GET, POST, PUT, DELETE.
/// 3. Automatically attaches JWT tokens to authenticated requests.
/// 4. Handles network timeouts, bad responses, and JSON decoding safely.
class ApiService {
  // Singleton pattern so the entire app shares one instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'jwt_access_token';

  // -------------------------------------------------------------
  // TOKEN MANAGEMENT (Secure Storage)
  // -------------------------------------------------------------

  /// Saves the JWT access token securely on the device.
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Retrieves the saved JWT token. Returns null if not logged in.
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  /// Clears the saved JWT token on logout.
  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// Checks if the user is currently logged in.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // -------------------------------------------------------------
  // HEADERS HELPER
  // -------------------------------------------------------------

  /// Constructs common headers, automatically adding the Bearer token when required.
  Future<Map<String, String>> _buildHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // -------------------------------------------------------------
  // HTTP METHODS: GET, POST, PUT, DELETE
  // -------------------------------------------------------------

  /// Performs a GET request.
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    try {
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConstants.timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot connect to server. Please check your internet or make sure backend is running.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Performs a POST request with JSON body.
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot connect to server. Please check your internet or make sure backend is running.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Performs a PUT request with JSON body.
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot connect to server. Please check your internet or make sure backend is running.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Performs a DELETE request.
  Future<dynamic> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final response = await http
          .delete(uri, headers: headers)
          .timeout(ApiConstants.timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot connect to server. Please check your internet or make sure backend is running.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // -------------------------------------------------------------
  // HELPER METHODS
  // -------------------------------------------------------------

  /// Combines the base URL, endpoint path, and query parameters.
  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final fullUrl = '${ApiConstants.baseUrl}$endpoint';
    final parsed = Uri.parse(fullUrl);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return parsed.replace(queryParameters: queryParameters);
    }
    return parsed;
  }

  /// Validates HTTP status code and decodes JSON response.
  dynamic _handleResponse(http.Response response) {
    dynamic decodedBody;
    if (response.body.isNotEmpty) {
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        decodedBody = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    // Extract backend error message if available (FastAPI usually returns {"detail": "..."})
    String errorMessage = 'Request failed with status code ${response.statusCode}';
    if (decodedBody is Map && decodedBody.containsKey('detail')) {
      final detail = decodedBody['detail'];
      if (detail is String) {
        errorMessage = detail;
      } else if (detail is List && detail.isNotEmpty) {
        // Pydantic validation error list
        final first = detail.first;
        if (first is Map && first.containsKey('msg')) {
          errorMessage = first['msg'].toString();
        } else {
          errorMessage = detail.toString();
        }
      }
    }

    switch (response.statusCode) {
      case 400:
        throw ApiException(errorMessage, statusCode: 400);
      case 401:
        throw ApiException('Unauthorized: $errorMessage', statusCode: 401);
      case 403:
        throw ApiException('Forbidden: $errorMessage', statusCode: 403);
      case 404:
        throw ApiException('Not Found: $errorMessage', statusCode: 404);
      case 409:
        throw ApiException('Conflict: $errorMessage', statusCode: 409);
      case 500:
        throw ApiException('Server error: $errorMessage', statusCode: 500);
      default:
        throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }
}
