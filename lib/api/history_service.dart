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
}