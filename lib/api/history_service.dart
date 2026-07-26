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
  static Future<List<dynamic>> getHistoryByUserId(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/history/user/$userId'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 🟢 กรณี Backend ส่งกลับมาเป็น Map {"status": "success", "history": [...]}
      if (data is Map<String, dynamic>) {
        if (data.containsKey('history') && data['history'] is List) {
          return data['history'];
        }
        return [];
      } 
      // 🟢 กรณี Backend ส่งกลับมาเป็น List [...] ตรงๆ
      else if (data is List) {
        return data;
      }
    }
    return [];
  } catch (e) {
    print('❌ Error fetching patient history: $e');
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

/// 💾 บันทึกข้อมูลประวัติการฝึกซ้อมใหม่ลงฐานข้อมูล
  static Future<Map<String, dynamic>> addHistory(Map<String, dynamic> historyData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/history'), // ยิงไปที่ POST /api/history
        headers: ApiConfig.headers,
        body: jsonEncode(historyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ (${response.statusCode})'
        };
      }
    } catch (e) {
      print('Error adding history: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }
  

}