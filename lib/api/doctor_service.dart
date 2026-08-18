import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class DoctorService {
  /// 🩺 ดึงรายชื่อแพทย์/นักกายภาพบำบัด (รองรับกรองตาม hospitalId)
  static Future<List<Map<String, dynamic>>> getDoctors({int? hospitalId}) async {
    try {
      String url = '${ApiConfig.baseUrl}/doctor';
      if (hospitalId != null) {
        url += '?hospital_id=$hospitalId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        return data.map((doc) {
          final code = doc['doctor_code']?.toString() ?? doc['id']?.toString() ?? '';
          final name = doc['name'] ?? '${doc['firstname'] ?? ''} ${doc['lastname'] ?? ''}'.trim();
          final specialty = doc['specialty'] != null ? ' (${doc['specialty']})' : '';
          final roleType = doc['role_type'] == 'therapist' ? '🧘‍♂️ [นักกายภาพบำบัด]' : '🩺 [แพทย์]';
          final hospital = doc['hospital_name'] != null ? ' - ${doc['hospital_name']}' : '';

          return {
            'id': code,
            'raw_id': doc['id'],
            'name': '$roleType $name$specialty$hospital',
            'role_type': doc['role_type'] ?? 'doctor',
            'hospital_id': doc['hospital_id'],
            'hospital_name': doc['hospital_name'] ?? '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> updatePrescription({
    required dynamic patientId,
    required int targetCount,
    required int targetSet,
    String? doctorToken,
  }) async {
    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      if (doctorToken != null && doctorToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $doctorToken';
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/doctor/update-prescription'),
        headers: headers,
        body: jsonEncode({
          'patient_id': patientId,
          'target_count': targetCount,
          'target_set': targetSet,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        return {'success': true, 'message': data['message'] ?? 'บันทึกเป้าหมายสำเร็จ'};
      } else {
        return {'success': false, 'message': data['message'] ?? data['error'] ?? 'เกิดข้อผิดพลาดในการบันทึก'};
      }
    } catch (e) {
      print('Error updating prescription: $e');
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้'};
    }
  }
}