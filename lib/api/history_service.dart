import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class HistoryService {
  /// 📊 ดึงประวัติการฝึกซ้อมทั้งหมด
  static Future<List<Map<String, dynamic>>> getHistoryList() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/history'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }

  /// 🩺 ดึงประวัติฝึกซ้อมเฉพาะของคนไข้ ID นี้
  static Future<List<Map<String, dynamic>>> getHistoryByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/history/user/$userId'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['history']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching patient history: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getTodaySummary(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/history/summary/today/$userId'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return Map<String, dynamic>.from(data['summary']);
      }
    }
    return null;
  } catch (e) {
    print('Error fetching today summary: $e');
    return null;
  }
}

}