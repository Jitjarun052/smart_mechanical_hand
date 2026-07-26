import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class NotificationService {
  /// 📡 ดึงรายการแจ้งเตือนจากตาราง notifications ใน MySQL
  static Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications/user/$userId'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['notifications']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  /// 🔵 อัปเดตสถานะเป็น "อ่านแล้ว"
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/read/$notificationId'),
        headers: ApiConfig.headers,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}