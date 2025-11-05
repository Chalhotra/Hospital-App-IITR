import 'package:dummy/bloc/auth_bloc.dart';
import 'package:dummy/bloc/auth_event.dart';
import 'package:dummy/bloc/auth_state.dart';
import 'package:dummy/bloc/patient_bloc.dart';
import 'package:dummy/bloc/prescription_bloc.dart';
import 'package:dummy/pages/book_appointment_page/book_appointment_page.dart';
import 'package:dummy/pages/login_page.dart';
import 'package:dummy/repositories/auth_repository.dart';
import 'package:dummy/repositories/patient_repository.dart';
import 'package:dummy/repositories/prescription_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize SharedPreferences before running the app
  await SharedPreferences.getInstance();

  // Request storage permissions on Android
  if (Platform.isAndroid) {
    print('📱 Requesting storage permissions...');

    // Request appropriate permissions based on Android version
    PermissionStatus status;

    // For Android 13+ (API 33+), we don't need storage permissions for app-specific directories
    // But we'll request them anyway for broader access
    if (Platform.isAndroid) {
      // Try to request storage permission
      status = await Permission.storage.request();

      // Also try manageExternalStorage for Android 11+
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }

      if (status.isGranted) {
        print('✅ Storage permission granted');
      } else if (status.isDenied) {
        print('⚠️ Storage permission denied');
      } else if (status.isPermanentlyDenied) {
        print('⚠️ Storage permission permanently denied');
      } else {
        print('⚠️ Storage permission status: $status');
      }
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();

    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: authRepository)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: authRepository)
                  ..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => PatientBloc(
              patientRepository: PatientRepository(),
              authRepository: authRepository,
            ),
          ),
          BlocProvider(
            create: (context) => PrescriptionBloc(
              prescriptionRepository: PrescriptionRepository(),
              authRepository: authRepository,
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'IITR Hospital Login',
          theme: ThemeData(primarySwatch: Colors.red),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading || state is AuthInitial) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (state is AuthAuthenticated) {
                return const BookAppointmentPage();
              } else {
                return const LoginPage();
              }
            },
          ),
        ),
      ),
    );
  }
}
