import 'package:flutter/material.dart';
import '../api/device_service.dart';
import '../theme/app_theme.dart';

class DeviceSettingPage extends StatefulWidget {
  final int? userId; // 🔑 รับ user_id เพื่อใช้ผูกกับอุปกรณ์

  const DeviceSettingPage({super.key, this.userId});

  @override
  State<DeviceSettingPage> createState() => _DeviceSettingPageState();
}

class _DeviceSettingPageState extends State<DeviceSettingPage> {
  final _serialController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _serialController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // 🚀 ฟังก์ชันยืนยันการลงทะเบียน
  Future<void> _handleBindDevice() async {
    final serial = _serialController.text.trim();
    final name = _nameController.text.trim();

    if (serial.isEmpty) {
      _showResultModal(
        title: 'กรุณากรอกข้อมูล',
        message: 'กรุณาระบุหมายเลขซีเรียลนัมเบอร์ของอุปกรณ์',
        isSuccess: false,
      );
      return;
    }

    if (widget.userId == null) {
      _showResultModal(
        title: 'ไม่พบข้อมูลผู้ใช้',
        message: 'กรุณาเข้าสู่ระบบใหม่อีกครั้ง',
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    // 📡 ยิง API ไปตรวจสอบและผูกอุปกรณ์
    final result = await DeviceService.bindDevice(
      serialNumber: serial,
      userId: widget.userId!,
      deviceName: name.isNotEmpty ? name : null,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // ✅ ผูกสำเร็จ เด้ง Modal แจ้งเตือน + พากลับหน้าก่อนหน้า
      _showResultModal(
        title: 'ลงทะเบียนสำเร็จ! 🎉',
        message: 'ผูกอุปกรณ์มือกลเข้ากับบัญชีของคุณเรียบร้อยแล้ว',
        isSuccess: true,
        onConfirm: () {
          Navigator.pop(context); // ปิด Modal
          Navigator.pop(context, true); // ถอยกลับหน้าหลักพร้อมส่งสัญญาณให้ reload
        },
      );
    } else {
      // ❌ ไม่พบอุปกรณ์ / ถูกผูกไปแล้ว เด้ง Modal แจ้งเตือน
      _showResultModal(
        title: 'ไม่สามารถผูกอุปกรณ์ได้',
        message: result['message'],
        isSuccess: false,
      );
    }
  }

  // 📱 ฟังก์ชันสร้าง Modal แสดงแจ้งเตือนผลลัพธ์
  void _showResultModal({
    required String title,
    required String message,
    required bool isSuccess,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: isSuccess ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? AppTheme.primaryColor : Colors.grey.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              if (onConfirm != null) {
                onConfirm();
              } else {
                Navigator.pop(context); // ปิด Modal อย่างเดียว
              }
            },
            child: const Text('ตกลง', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('ลงทะเบียนอุปกรณ์ใหม่', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ผูกอุปกรณ์มือกลของคุณ 🦾', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            const Text('ระบุหมายเลขเครื่องมือกลเพื่อเริ่มระบบกายภาพบำบัด', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 28),

            // 1. ช่องกรอก Serial Number
            const Text('หมายเลขซีเรียลนัมเบอร์อุปกรณ์ (Serial Number)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _serialController,
              decoration: InputDecoration(
                hintText: 'เช่น Glove-2569-XXXX',
                prefixIcon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // 2. ช่องกรอก Device Name
            const Text('ตั้งชื่ออุปกรณ์ของคุณ (Device Name)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'เช่น ถุงมือฟื้นฟูของฉัน',
                prefixIcon: const Icon(Icons.edit_rounded, color: AppTheme.primaryColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 36),

            // 3. ปุ่มยืนยัน
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _handleBindDevice,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ยืนยันผูกอุปกรณ์', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}