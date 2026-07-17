import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🌐 กำหนด Base URL ตัวกลางประจำหลังบ้านของคุณ (พอร์ต 5000)
  // หากใช้ Android Emulator ให้ใช้ 10.0.2.2 แต่ถ้าใช้เครื่องจริง Realme GT 6 ให้เปลี่ยนเป็น IP วงแลนของคุณครับ
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const String baseUrl = 'http://localhost:5000/api';

  // 🔑 1. ฟังก์ชันสำหรับระบบล็อกอินอัจฉริยะ (Smart Login) ดักจับ 2 ตาราง
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/user/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // แปลงข้อมูล Response ขากลับจาก Node.js เป็น Map Object
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      // แนบรหัส StatusCode กลับไปเช็กความถูกต้องด้วย
      responseData['statusCode'] = response.statusCode;
      return responseData;
      
    } catch (e) {
      return {
        'status': 'error',
        'error': 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์พอร์ต 5000 ได้: $e',
        'statusCode': 500
      };
    }
  }
  

  // 📝 2. ฟังก์ชันตรวจสอบสิทธิ์ Token (Get Me) เผื่อใช้ดึงข้อมูลโปรไฟล์ล่าสุด
  static Future<Map<String, dynamic>> getMe(String token) async {
    final url = Uri.parse('$baseUrl/user/me');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ส่ง Token ไปใน Header ตามโครงสร้างหลังบ้าน
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      responseData['statusCode'] = response.statusCode;
      return responseData;
    } catch (e) {
      return {
        'status': 'error',
        'error': 'เกิดข้อผิดพลาดในการยืนยันตัวตน: $e',
        'statusCode': 500
      };
    }
  }
}