import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../models/login_request.dart';
import '../models/patient_info.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔍 [BLOC] Checking authentication status...');

    // Log all SharedPreferences data
    await _logSharedPreferencesData();

    emit(AuthLoading());
    try {
      final user = await authRepository.getSavedUser();
      if (user != null && !user.isTokenExpired) {
        print('✅ [BLOC] User is authenticated: ${user.username}');
        emit(AuthAuthenticated(user));
      } else {
        print('⚠️ [BLOC] User is not authenticated');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ [BLOC] Error checking authentication: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _logSharedPreferencesData() async {
    print('\n📦 ========== SHARED PREFERENCES DATA ========== 📦');

    // Get token and user info
    final user = await authRepository.getSavedUser();
    if (user != null) {
      print('🔑 Token: ${user.token.substring(0, 50)}...');
      print('👤 Username: ${user.username}');
      print('⏰ Expiration: ${user.expiration}');
      print('🎭 Roles: ${user.roles}');
      print('📅 Is Expired: ${user.isTokenExpired}');
    } else {
      print('⚠️ No user token found in SharedPreferences');
    }

    print('\n📋 Patient Info:');
    // Get patient info
    final patientInfo = await authRepository.getSavedPatientInfo();
    if (patientInfo != null && patientInfo.isNotEmpty) {
      print('📊 Total Booklets: ${patientInfo.length}');
      for (var i = 0; i < patientInfo.length; i++) {
        final booklet = patientInfo[i];
        print('   ${i + 1}. ${booklet.fullName} (${booklet.bookletNo})');
        print('      Relation: ${booklet.relation}');
        print('      Gender: ${booklet.gender}');
        print('      Blood Group: ${booklet.bloodGroup}');
        print('      Mobile: ${booklet.mobileNo}');
      }

      final activeBookletNo = await authRepository.getActiveBookletNo();
      print('✅ Active Booklet: $activeBookletNo');
    } else {
      print('⚠️ No patient info found in SharedPreferences');
    }

    print('📦 ============================================== 📦\n');
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 [BLOC] Login requested for username: ${event.username}');
    emit(AuthLoading());
    try {
      final loginRequest = LoginRequest(
        username: event.username,
        password: event.password,
      );

      print('🔐 [BLOC] Calling auth repository login...');
      final loginResponse = await authRepository.login(loginRequest);

      print('🔐 [BLOC] Login response received, saving user...');
      // Save to SharedPreferences
      await authRepository.saveUser(loginResponse);

      // Fetch patient info immediately after login
      print('🔐 [BLOC] Fetching patient info...');
      try {
        final response = await http.get(
          Uri.parse(AppConfig.patientInfoUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${loginResponse.token}',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> responseData = json.decode(response.body);
          final patientInfoList = responseData
              .map((json) => PatientInfo.fromJson(json as Map<String, dynamic>))
              .toList();

          if (patientInfoList.isNotEmpty) {
            // Save patient info with first booklet as active
            await authRepository.savePatientInfo(
              patientInfoList,
              patientInfoList[0].bookletNo,
            );
            print(
              '✅ [BLOC] Patient info fetched and saved (${patientInfoList.length} booklets)',
            );
          }
        } else {
          print(
            '⚠️ [BLOC] Failed to fetch patient info: ${response.statusCode}',
          );
        }
      } catch (e) {
        print('⚠️ [BLOC] Error fetching patient info: $e');
        // Continue with login even if patient info fetch fails
      }

      // Create user object
      final user = User(
        token: loginResponse.token,
        username: loginResponse.username,
        expiration: loginResponse.expiration,
        roles: loginResponse.roles,
      );

      print('✅ [BLOC] Login successful, emitting authenticated state');
      emit(AuthAuthenticated(user));
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(
          11,
        ); // Remove "Exception: " prefix
      }

      print('❌ [BLOC] Login failed: $errorMessage');
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🚪 [BLOC] Logout requested');
    await authRepository.clearUser();
    print('✅ [BLOC] Logout complete, emitting unauthenticated state');
    emit(AuthUnauthenticated());
  }
}
