import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class AuthService {
  // 🌐 เปลี่ยน URL ตามสภาพแวดล้อมที่รัน
  // - Flutter Web / Chrome: 'http://localhost:5000/api'
  // - Android Emulator: 'http://10.0.2.2:5000/api'
  // - เครื่องจริง Realme GT 6: 'http://<IP_เครื่องคอมในวง_LAN>:5000/api'
  static const String baseUrl = 'http://localhost:5000/api';

  /// 🔌 ยิง Smart Login (เช็กได้ทั้ง Doctor และ Patient)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'success': true,
          'role': data['role'] ?? '',
          'token': data['token'] ?? '',
          'user': data['user'] ?? {},
          'message': data['message'] ?? 'เข้าสู่ระบบสำเร็จ'
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'เข้าสู่ระบบไม่สำเร็จ',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> registerPatient({
    required String firstname,
    required String lastname,
    required String email,
    required String phone,
    required String password,
    required String age,
    required String gender,
    required String symptoms,
    required String emergencyPhone,
    String? doctorId,
    String? serialNumber,
    String? deviceName,
    File? imageFile,          // สำหรับ Mobile (Android / iOS)
    Uint8List? imageBytes,    // สำหรับ Web
    String? imageName,        // ชื่อไฟล์รูป
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/user/register');
      var request = http.MultipartRequest('POST', uri);

      // 📝 ผูกข้อมูล Text Form
      request.fields['firstname'] = firstname;
      request.fields['lastname'] = lastname;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['password'] = password;
      request.fields['age'] = age;
      request.fields['gender'] = gender;
      request.fields['symptoms'] = symptoms;
      request.fields['emergency_phone'] = emergencyPhone;
      
      if (doctorId != null) request.fields['doctor_code'] = doctorId;
      if (serialNumber != null && serialNumber.isNotEmpty) {
        request.fields['serial_number'] = serialNumber;
      }
      if (deviceName != null && deviceName.isNotEmpty) {
        request.fields['device_name'] = deviceName;
      }

      // 📸 [แนบรูปภาพ]: สลับตามแพลตฟอร์มอัตโนมัติ
      if (kIsWeb && imageBytes != null) {
        // ฝั่ง Web ยิงด้วย Bytes
        request.files.add(
          http.MultipartFile.fromBytes(
            'image', 
            imageBytes,
            filename: imageName ?? 'profile.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else if (!kIsWeb && imageFile != null) {
        // ฝั่ง Mobile (Android/iOS) ยิงด้วย File Path
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': data['message'] ?? 'ลงทะเบียนสำเร็จ!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'เกิดข้อผิดพลาดในการลงทะเบียน'};
      }
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e'};
    }
  }

  static Future<List<Map<String, String>>> getDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctor'), // URL ยิงไปหา Endpoint ดึงรายชื่อหมอ
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // แปลงข้อมูลจาก Backend ให้ตรงกับโครงสร้างที่ Autocomplete ต้องใช้
        return data.map((doc) {
          final code = doc['doctor_code']?.toString() ?? doc['id']?.toString() ?? '';
          final name = doc['name'] ?? '${doc['firstname']} ${doc['lastname']}';
          final specialty = doc['specialty'] != null ? ' (${doc['specialty']})' : '';
          
          return {
            'id': code, // doctor_code ที่จะส่งกลับไปบันทึกตอนสมัคร
            'name': '$name$specialty', // ชื่อหมอ + ความเชี่ยวชาญสำหรับโชว์ในรายการ
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

  // 1. ตรวจสอบข้อมูลผู้ใช้
static Future<Map<String, dynamic>> verifyIdentity({
  required String email,
  required String phone,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/user/verify-identity'),
      headers: {'Content-Type': 'application/json'},
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

// 2. ตั้งรหัสผ่านใหม่
static Future<Map<String, dynamic>> resetPassword({
  required int userId,
  required String newPassword,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/user/reset-password'),
      headers: {'Content-Type': 'application/json'},
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