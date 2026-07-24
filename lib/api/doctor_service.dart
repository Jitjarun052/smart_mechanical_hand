import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class DoctorService {
  /// 🩺 ดึงรายชื่อหมอสำหรับ Autocomplete Dropdown
  static Future<List<Map<String, String>>> getDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/doctor'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        return data.map((doc) {
          final code = doc['doctor_code']?.toString() ?? doc['id']?.toString() ?? '';
          final name = doc['name'] ?? '${doc['firstname']} ${doc['lastname']}';
          final specialty = doc['specialty'] != null ? ' (${doc['specialty']})' : '';
          
          return {
            'id': code,
            'name': '$name$specialty',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }
}