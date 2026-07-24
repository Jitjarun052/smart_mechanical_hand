import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../screens/scan_screen.dart';
import '../../api/device_service.dart'; // 👈 นำเข้า DeviceService

class Step3DeviceForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController serialNumberController;
  final TextEditingController deviceNameController;
  final bool isSubmitting;
  final Function(Map<String, dynamic> deviceData) onSubmitWithDevice; // 👈 ส่งข้อมูลอุปกรณ์ที่ผูกสำเร็จกลับไป
  final VoidCallback onSkip;
  final VoidCallback onPrev;

  const Step3DeviceForm({
    super.key,
    required this.formKey,
    required this.serialNumberController,
    required this.deviceNameController,
    required this.isSubmitting,
    required this.onSubmitWithDevice,
    required this.onSkip,
    required this.onPrev,
  });

  // 📱 ฟังก์ชันแสดง Modal แจ้งเตือนข้อผิดพลาด/คำแนะนำ
  void _showErrorModal(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
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
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('ลองใหม่อีกครั้ง', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 🚀 ฟังก์ชันตรวจสอบ Serial Number ก่อนส่งผ่าน Step
  Future<void> _handleDeviceValidation(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final serial = serialNumberController.text.trim();
    final name = deviceNameController.text.trim();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
    );

    // 📡 ยิง API ไปเช็ก Serial Number ในตาราง device ว่ามีจริงไหม และว่างอยู่หรือไม่
    // (หมายเหตุ: ใช้ temp userId = 0 เพื่อตรวจสอบการถือครองก่อน)
    final checkResult = await DeviceService.bindDevice(
      serialNumber: serial,
      userId: 0, // หรือสร้าง API เช็กแยกเฉพาะ /device/check-serial
      deviceName: name,
    );

    if (context.mounted) Navigator.pop(context); // ปิด Loading Indicator

    // ❌ กรณีไม่พบอุปกรณ์ หรือ ถูกผู้อื่นใช้งานไปแล้ว
    if (checkResult['success'] == false) {
      if (context.mounted) {
        _showErrorModal(
          context,
          'ไม่สามารถผูกอุปกรณ์ได้',
          checkResult['message'] ?? 'ไม่พบ Serial Number นี้ในระบบ หรือ ถูกลงทะเบียนไปแล้ว',
        );
      }
    } else {
      // ✅ ผ่าน! อุปกรณ์มีจริงและพร้อมใช้งาน -> ส่งข้อมูลไปยัง callback เพื่อสมัครสมาชิกต่อ
      onSubmitWithDevice({
        'serial_number': serial,
        'device_name': name,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ผูกอุปกรณ์มือกล 🦾', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            const Text('ขั้นตอนที่ 3: ระบุหมายเลขเครื่องมือกลเพื่อซิงก์ข้อมูลแนวโน้ม', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 28),

            _buildInputLabel('หมายเลขซีเรียลนัมเบอร์อุปกรณ์ (Serial Number)'),
            TextFormField(
              controller: serialNumberController,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              decoration: _buildDecoration('เช่น Glove-2569-XXXX', Icons.developer_board_rounded).copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor, size: 22),
                  onPressed: () async {
                    final String? scanned = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (_) => const ScanScreen()),
                    );
                    if (scanned != null) {
                      serialNumberController.text = scanned;
                    }
                  },
                ),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'กรุณาระบุ Serial Number' : null,
            ),
            const SizedBox(height: 20),

            _buildInputLabel('ตั้งชื่ออุปกรณ์ของคุณ (Device Name)'),
            TextFormField(
              controller: deviceNameController,
              style: const TextStyle(fontSize: 14),
              decoration: _buildDecoration('เช่น ถุงมือฟื้นฟูของสมชาย', Icons.drive_file_rename_outline_rounded),
              validator: (v) => v == null || v.trim().isEmpty ? 'กรุณาตั้งชื่อเล่นให้อุปกรณ์' : null,
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.withOpacity(0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: isSubmitting ? null : onPrev,
                      child: const Text('ย้อนกลับ', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                      onPressed: isSubmitting
                          ? null
                          : () => _handleDeviceValidation(context), // 👈 เรียกฟังก์ชันตรวจเช็ก Serial Number ก่อนส่งผ่าน
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('ยืนยันลงทะเบียน', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // ⏩ ปุ่มข้ามขั้นตอน
            Center(
              child: TextButton(
                onPressed: isSubmitting ? null : onSkip, // 👈 กดข้ามได้ทันทีโดยไม่เช็กช่องอินพุต
                child: const Text('ข้ามขั้นตอนผูกอุปกรณ์ไปก่อน', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
    child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
  );

  InputDecoration _buildDecoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 13),
    prefixIcon: Icon(icon, color: Colors.grey, size: 20),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
  );
}