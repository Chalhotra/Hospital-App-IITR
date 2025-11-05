import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/opd.dart';
import '../models/prescription.dart';
import '../config/app_config.dart';

class PrescriptionRepository {
  Future<List<Opd>> getOpdsByBooklet(String token, String bookletNo) async {
    final url = AppConfig.opdByBookletUrl(bookletNo);
    print('🔵 Fetching OPDs by booklet: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔵 OPD by booklet response status: ${response.statusCode}');
      print('🔵 OPD by booklet response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final opds = jsonList
            .map((json) => Opd.fromJson(json as Map<String, dynamic>))
            .toList();
        print('✅ Successfully fetched ${opds.length} OPDs');
        return opds;
      } else {
        print('❌ Failed to fetch OPDs: ${response.statusCode}');
        throw Exception('Failed to fetch OPDs: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching OPDs: $e');
      throw Exception('Error fetching OPDs: $e');
    }
  }

  Future<List<Prescription>> getPrescriptionsByOpdId(
    String token,
    int opdId,
  ) async {
    final url = AppConfig.prescriptionsByOpdUrl(opdId);
    print('🔵 Fetching prescriptions by OPD ID: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔵 Prescriptions response status: ${response.statusCode}');
      print('🔵 Prescriptions response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final prescriptions = jsonList
            .map((json) => Prescription.fromJson(json as Map<String, dynamic>))
            .toList();
        print('✅ Successfully fetched ${prescriptions.length} prescriptions');
        return prescriptions;
      } else {
        print('❌ Failed to fetch prescriptions: ${response.statusCode}');
        throw Exception(
          'Failed to fetch prescriptions: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error fetching prescriptions: $e');
      throw Exception('Error fetching prescriptions: $e');
    }
  }
}
