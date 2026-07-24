import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class PasswordService {
  /// 🔍 1. ตรวจสอบข้อมูลผู้ใช้ (Verify Identity)
  static Future<Map<String, dynamic>> verifyIdentity({
    required String email,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/verify-identity'),
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email, 'phone': phone}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true, 
          'userId': data['userId'], 
          'firstname': data['firstname']
        };
      } else {
        return {'success': false, 'message': data['error'] ?? 'ไม่พบข้อมูลในระบบ'};
      }
    } catch (e) {
      return {'success': false, 'message': 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้: $e'};
    }
  }

  /// 🔑 2. ตั้งรหัสผ่านใหม่ (Reset Password)
  static Future<Map<String, dynamic>> resetPassword({
    required int userId,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/reset-password'),
        headers: ApiConfig.headers,
        body: jsonEncode({'userId': userId, 'newPassword': newPassword}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'รีเซ็ตสำเร็จ'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'เกิดข้อผิดพลาด'};
      }
    } catch (e) {
      return {'success': false, 'message': 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้: $e'};
    }
  }
}