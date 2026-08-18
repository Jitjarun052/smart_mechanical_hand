import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class DeviceService {
  /// ⚡ ดึงข้อมูลอุปกรณ์ที่ผูกกับ user_id ของผู้ป่วย
  static Future<Map<String, dynamic>?> getDeviceByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/device?user_id=$userId'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return Map<String, dynamic>.from(data.first); // ดึงอุปกรณ์ชิ้นแรกที่ผูกไว้
        }
      }
      return null;
    } catch (e) {
      print('Error fetching device: $e');
      return null;
    }
  }

  static Future<bool> unbindDevice(int deviceId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/device/unbind'),
        headers: ApiConfig.headers,
        body: jsonEncode({'device_id': deviceId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error unbinding device: $e');
      return false;
    }
  }

  /// ⚡ ผูกอุปกรณ์ด้วย Serial Number
  static Future<Map<String, dynamic>> bindDevice({
    required String serialNumber,
    required int userId,
    String? deviceName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/device/bind'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'serial_number': serialNumber,
          'user_id': userId,
          'device_name': deviceName,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'เกิดข้อผิดพลาด'};
      }
    } catch (e) {
      print('Error binding device: $e');
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้'};
    }
  }

  static Future<bool> sendControlCommand(int deviceId, String command) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/device/control/$deviceId'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'command': command, // 🟢 ส่ง 'START-APP' หรือ 'STOP-APP'
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

// 📡 เช็กสเตตัสการทำงานและจำนวนรอบ Real-time (ส่ง ?caller=app เพื่อไม่ให้อัปเดต last_seen)
static Future<Map<String, dynamic>?> getDeviceStatus(int deviceId) async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/device/status/$deviceId?caller=app'), // 👈 เติม ?caller=app ตรงนี้ครับ
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    return null;
  } catch (e) {
    print('Error getting device status: $e');
    return null;
  }
}
}