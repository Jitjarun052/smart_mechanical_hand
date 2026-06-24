import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/scan_screen.dart'; // เรียกใช้หน้าสแกนเดิมของคุณ

class DeviceSettingPage extends StatefulWidget {
  const DeviceSettingPage({super.key});

  @override
  State<DeviceSettingPage> createState() => _DeviceSettingPageState();
}

class _DeviceSettingPageState extends State<DeviceSettingPage> {
  final _formKey = GlobalKey<FormState>();
  final _serialNumberController = TextEditingController();
  final _deviceNameController = TextEditingController();

  void _handleRegisterDevice() {
    if (_formKey.currentState!.validate()) {
      // 🟢 พาร์ทนี้ในอนาคตเอาไว้ใส่ฟังก์ชันยิง API ไปอัปเดตข้อมูลใน MySQL หลังบ้านครับ
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor)),
        ),
      );

      Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
        Navigator.pop(context); // ปิด Loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ผูกอุปกรณ์รหัส ${_serialNumberController.text} สำเร็จแล้ว!')),
        );
        Navigator.pop(context); // หนีกลับหน้าหลัก Dashboard
      });
    }
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ลงทะเบียนอุปกรณ์ใหม่',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('ผูกอุปกรณ์มือกลของคุณ 🦾', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              const Text('ระบุหมายเลขเครื่องมือกลเพื่อเริ่มระบบกายภาพบำบัด', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 32),

              _buildInputLabel('หมายเลขซีเรียลนัมเบอร์อุปกรณ์ (Serial Number)'),
              TextFormField(
                controller: _serialNumberController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                decoration: _buildInputDecoration('เช่น Glove-2569-XXXX', Icons.developer_board_rounded).copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor, size: 22),
                    onPressed: () async {
                      final String? scannedResult = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(builder: (context) => const ScanScreen()),
                      );
                      if (scannedResult != null && mounted) {
                        setState(() {
                          _serialNumberController.text = scannedResult;
                        });
                      }
                    },
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'กรุณาระบุ Serial Number' : null,
              ),
              const SizedBox(height: 20),

              _buildInputLabel('ตั้งชื่ออุปกรณ์ของคุณ (Device Name)'),
              TextFormField(
                controller: _deviceNameController,
                style: const TextStyle(fontSize: 14),
                decoration: _buildInputDecoration('เช่น ถุงมือฟื้นฟูของฉัน', Icons.drive_file_rename_outline_rounded),
                validator: (value) => value!.isEmpty ? 'กรุณาตั้งชื่อเล่นให้อุปกรณ์' : null,
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
                    elevation: 0
                  ),
                  onPressed: _handleRegisterDevice,
                  child: const Text('ยืนยันผูกอุปกรณ์', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1)),
    );
  }
}