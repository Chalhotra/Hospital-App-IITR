import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/user.dart';
import '../models/patient_info.dart';

class AuthRepository {
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  static const String _expirationKey = 'expiration';
  static const String _rolesKey = 'roles';
  static const String _patientInfoKey = 'patient_info';
  static const String _activeBookletKey = 'active_booklet';

  // Login API call
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final loginUrl = AppConfig.loginUrl;
      print('🔵 [AUTH] Making login request to: $loginUrl');
      print('🔵 [AUTH] Request body: ${json.encode(request.toJson())}');

      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      print('🔵 [AUTH] Response status code: ${response.statusCode}');
      print('🔵 [AUTH] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(
          '✅ [AUTH] Login successful for user: ${responseData['username']}',
        );
        return LoginResponse.fromJson(responseData);
      } else {
        // Try to parse error message from response body
        String errorMessage = 'Invalid credentials';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {
          // If parsing fails, use status code based message
          if (response.statusCode == 401) {
            errorMessage = 'Invalid username or password';
          } else if (response.statusCode == 404) {
            errorMessage = 'Service not available';
          } else {
            errorMessage = 'Login failed (${response.statusCode})';
          }
        }

        print('❌ [AUTH] Login failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ [AUTH] Login error: $e');
      // Re-throw the exception without wrapping it again if it's already an Exception
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Please check your connection');
    }
  }

  // Register API call
  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      final registerUrl = AppConfig.registerUrl;
      print('🔵 [AUTH] Making register request to: $registerUrl');
      print('🔵 [AUTH] Request body: ${json.encode(request.toJson())}');

      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      print('🔵 [AUTH] Response status code: ${response.statusCode}');
      print('🔵 [AUTH] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(
          '✅ [AUTH] Registration successful for user: ${responseData['username']}',
        );
        return LoginResponse.fromJson(responseData);
      } else {
        // Try to parse error message from response body
        String errorMessage = 'Registration failed';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {
          // If parsing fails, use status code based message
          if (response.statusCode == 400) {
            errorMessage = 'User already exists or invalid data';
          } else if (response.statusCode == 404) {
            errorMessage = 'Service not available';
          } else {
            errorMessage = 'Registration failed (${response.statusCode})';
          }
        }

        print('❌ [AUTH] Registration failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ [AUTH] Registration error: $e');
      // Re-throw the exception without wrapping it again if it's already an Exception
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Please check your connection');
    }
  }

  // Save user data to SharedPreferences
  Future<void> saveUser(LoginResponse loginResponse) async {
    print('💾 [AUTH] Saving user data to SharedPreferences');
    print('💾 [AUTH] Username: ${loginResponse.username}');
    print('💾 [AUTH] Expiration: ${loginResponse.expiration}');
    print('💾 [AUTH] Roles: ${loginResponse.roles}');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, loginResponse.token);
    await prefs.setString(_usernameKey, loginResponse.username);
    await prefs.setString(_expirationKey, loginResponse.expiration);
    await prefs.setString(_rolesKey, loginResponse.roles);

    print('✅ [AUTH] User data saved successfully');
  }

  // Fetch patient info and save it (without triggering auth state)
  Future<bool> fetchAndSavePatientInfo(String token) async {
    try {
      print('📋 [AUTH] Fetching patient info with token...');

      final response = await http.get(
        Uri.parse(AppConfig.patientInfoUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final patientInfoList = responseData
            .map((json) => PatientInfo.fromJson(json as Map<String, dynamic>))
            .toList();

        if (patientInfoList.isNotEmpty) {
          // Save patient info with first booklet as active
          await savePatientInfo(patientInfoList, patientInfoList[0].bookletNo);
          print(
            '✅ [AUTH] Patient info fetched and saved (${patientInfoList.length} booklets)',
          );
          return true;
        } else {
          print('⚠️ [AUTH] No patient info returned from API');
          return false;
        }
      } else {
        print('⚠️ [AUTH] Failed to fetch patient info: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ [AUTH] Error fetching patient info: $e');
      return false;
    }
  }

  // Get saved user from SharedPreferences
  Future<User?> getSavedUser() async {
    print('📖 [AUTH] Reading saved user from SharedPreferences');

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(_tokenKey);
    final username = prefs.getString(_usernameKey);
    final expiration = prefs.getString(_expirationKey);
    final roles = prefs.getString(_rolesKey);

    if (token == null ||
        username == null ||
        expiration == null ||
        roles == null) {
      print('⚠️ [AUTH] No saved user found in SharedPreferences');
      return null;
    }

    print('📖 [AUTH] Found saved user: $username');
    print('📖 [AUTH] Token expiration: $expiration');

    final user = User(
      token: token,
      username: username,
      expiration: expiration,
      roles: roles,
    );

    // Check if token is expired
    if (user.isTokenExpired) {
      print('⏰ [AUTH] Token is expired, clearing user data');
      await clearUser();
      return null;
    }

    print('✅ [AUTH] Token is valid, returning user');
    return user;
  }

  // Clear user data from SharedPreferences
  Future<void> clearUser() async {
    print('🗑️ [AUTH] Clearing user data from SharedPreferences');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_expirationKey);
    await prefs.remove(_rolesKey);
    await prefs.remove(_patientInfoKey);
    await prefs.remove(_activeBookletKey);

    print('✅ [AUTH] User data cleared successfully');
  }

  // Save patient info to SharedPreferences
  Future<void> savePatientInfo(
    List<PatientInfo> patientInfoList,
    String activeBookletNo,
  ) async {
    print(
      '💾 [AUTH] Saving ${patientInfoList.length} patient booklet(s) to SharedPreferences',
    );

    final prefs = await SharedPreferences.getInstance();
    final patientInfoJson = patientInfoList.map((p) => p.toJson()).toList();
    await prefs.setString(_patientInfoKey, json.encode(patientInfoJson));
    await prefs.setString(_activeBookletKey, activeBookletNo);

    print('✅ [AUTH] Patient info saved successfully');
  }

  // Get saved patient info from SharedPreferences
  Future<List<PatientInfo>?> getSavedPatientInfo() async {
    print('📖 [AUTH] Reading saved patient info from SharedPreferences');

    final prefs = await SharedPreferences.getInstance();
    final patientInfoString = prefs.getString(_patientInfoKey);

    if (patientInfoString == null) {
      print('⚠️ [AUTH] No saved patient info found');
      return null;
    }

    try {
      final List<dynamic> patientInfoJson = json.decode(patientInfoString);
      final patientInfoList = patientInfoJson
          .map((json) => PatientInfo.fromJson(json as Map<String, dynamic>))
          .toList();

      print('✅ [AUTH] Loaded ${patientInfoList.length} booklet(s) from cache');
      return patientInfoList;
    } catch (e) {
      print('❌ [AUTH] Error parsing patient info: $e');
      return null;
    }
  }

  // Get active booklet number
  Future<String?> getActiveBookletNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeBookletKey);
  }

  // Update active booklet
  Future<void> updateActiveBooklet(String bookletNo) async {
    print('💾 [AUTH] Updating active booklet to: $bookletNo');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeBookletKey, bookletNo);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final user = await getSavedUser();
    return user != null && !user.isTokenExpired;
  }
}
