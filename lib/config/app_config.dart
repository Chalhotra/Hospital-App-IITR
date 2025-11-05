import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // API Configuration
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.17.1.5';
  static String get apiLoginEndpoint =>
      dotenv.env['API_LOGIN_ENDPOINT'] ?? '/api/Auth/login';
  static String get apiPatientInfoEndpoint =>
      dotenv.env['API_PATIENT_INFO_ENDPOINT'] ?? '/api/Patients/my-info';
  static String get apiOpdByBookletEndpoint =>
      dotenv.env['API_OPD_BY_BOOKLET_ENDPOINT'] ??
      '/api/Patients/my-opd-by-booklet';
  static String get apiPrescriptionsByOpdEndpoint =>
      dotenv.env['API_PRESCRIPTIONS_BY_OPD_ENDPOINT'] ??
      '/api/Patients/my-prescriptions';

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'IITR Hospital';

  // Computed values
  static String get loginUrl => '$apiBaseUrl$apiLoginEndpoint';
  static String get patientInfoUrl => '$apiBaseUrl$apiPatientInfoEndpoint';
  static String opdByBookletUrl(String bookletNo) =>
      '$apiBaseUrl$apiOpdByBookletEndpoint/$bookletNo';
  static String prescriptionsByOpdUrl(int opdId) =>
      '$apiBaseUrl$apiPrescriptionsByOpdEndpoint/$opdId';
}
