import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_config.dart';

class AuthService {
  /// 🔌 ยิง Smart Login (เช็กได้ทั้ง Doctor และ Patient)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/login'),
        headers: ApiConfig.headers,
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

  /// 📝 สมัครสมาชิกผู้ป่วย
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
    int? hospitalId,
    String? doctorId,
    String? serialNumber,
    String? deviceName,
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/user/register');
      var request = http.MultipartRequest('POST', uri);

      request.fields['firstname'] = firstname;
      request.fields['lastname'] = lastname;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['password'] = password;
      request.fields['age'] = age;
      request.fields['gender'] = gender;
      request.fields['symptoms'] = symptoms;
      request.fields['emergency_phone'] = emergencyPhone;
      
      if (hospitalId != null) request.fields['hospital_id'] = hospitalId.toString();
      if (doctorId != null) request.fields['doctor_code'] = doctorId;
      if (serialNumber != null && serialNumber.isNotEmpty) {
        request.fields['serial_number'] = serialNumber;
      }
      if (deviceName != null && deviceName.isNotEmpty) {
        request.fields['device_name'] = deviceName;
      }

      if (kIsWeb && imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image', 
            imageBytes,
            filename: imageName ?? 'profile.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else if (!kIsWeb && imageFile != null) {
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

  // ฟังก์ชัน getMe ใน AuthService
  static Future<Map<String, dynamic>> getMe(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'success': true,
          'role': data['role'] ?? '', // 👈 คืนค่า role ('doctor' หรือ 'patient')
          'user': data['user'] ?? {},
        };
      } else {
        return {'success': false, 'message': data['error'] ?? 'ดึงข้อมูลผู้ใช้ล้มเหลว'};
      }
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e'};
    }
  }

}