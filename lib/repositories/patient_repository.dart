import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/patient_info.dart';

class PatientRepository {
  // Fetch patient info using Bearer token
  Future<List<PatientInfo>> getPatientInfo(String token) async {
    try {
      print(
        '🔵 [PATIENT] Fetching patient info from: ${AppConfig.patientInfoUrl}',
      );
      print('🔵 [PATIENT] Using token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(AppConfig.patientInfoUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔵 [PATIENT] Response status code: ${response.statusCode}');
      print('🔵 [PATIENT] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        print(
          '✅ [PATIENT] Successfully fetched ${responseData.length} booklet(s)',
        );

        return responseData
            .map((json) => PatientInfo.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print(
          '❌ [PATIENT] Failed to fetch patient info: ${response.statusCode}',
        );
        throw Exception('Failed to fetch patient info: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [PATIENT] Error fetching patient info: $e');
      throw Exception('Error fetching patient info: $e');
    }
  }
}
