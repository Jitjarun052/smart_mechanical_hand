import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../api/device_service.dart';

class Step3DeviceForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController serialNumberController;
  final TextEditingController deviceNameController;
  final bool isSubmitting;
  final Function(Map<String, dynamic> deviceData) onSubmitWithDevice;
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

  // 📷 1. ฟังก์ชันเปิดกล้องสแกน QR Code แบบ Modal
  void _openCameraScanner(BuildContext context) {
    final MobileScannerController scannerController = MobileScannerController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'สแกน QR Code ถุงมือกล',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      scannerController.dispose();
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MobileScanner(
                        controller: scannerController,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
                              serialNumberController.text = barcode.rawValue!;
                              scannerController.dispose();
                              Navigator.pop(ctx);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('สแกนสำเร็จ: ${barcode.rawValue}'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              break;
                            }
                          }
                        },
                      ),
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primaryColor, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'ส่องกล้องไปที่ QR Code บนตัวเครื่องถุงมือกล',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🖼️ 2. ฟังก์ชันเลือกรูปภาพจาก Gallery แล้วอ่านค่า QR Code
  Future<void> _pickImageAndScan(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      if (kIsWeb) {
        if (context.mounted) {
          _showErrorModal(
            context,
            'ไม่รองรับบนเว็บ',
            'ฟังก์ชันสแกนจากรูปภาพรองรับเฉพาะบนแอปพลิเคชันมือถือ (Android/iOS) เท่านั้น กรุณาใช้ปุ่ม "เปิดกล้องสแกน" แทนครับ',
          );
        }
        return;
      }
      
      final MobileScannerController controller = MobileScannerController();
      final BarcodeCapture? capture = await controller.analyzeImage(image.path);
      controller.dispose();

      if (capture != null && capture.barcodes.isNotEmpty) {
        final String? code = capture.barcodes.first.rawValue;
        if (code != null && code.isNotEmpty) {
          serialNumberController.text = code;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('อ่านค่า QR Code สำเร็จ: $code'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (context.mounted) _showErrorModal(context, 'อ่านค่าไม่สำเร็จ', 'ไม่พบข้อมูล QR Code ในรูปภาพนี้');
        }
      } else {
        if (context.mounted) _showErrorModal(context, 'ไม่พบ QR Code', 'รูปภาพที่เลือกไม่มี QR Code หรือรูปไม่ชัดเจน');
      }
    } catch (e) {
      if (context.mounted) _showErrorModal(context, 'เกิดข้อผิดพลาด', 'ไม่สามารถอ่านไฟล์รูปภาพได้: $e');
    }
  }

  // 📱 ฟังก์ชันแสดง Modal แจ้งเตือน
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
            child: const Text('ตกลง', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 🚀 ฟังก์ชันส่งข้อมูล Serial Number ไปให้ขั้นตอนบันทึกสมัครสมาชิก
  void _handleDeviceValidation(BuildContext context) {
    if (!formKey.currentState!.validate()) return;

    final serial = serialNumberController.text.trim();
    final name = deviceNameController.text.trim();

    // 🟢 ส่งข้อมูลไปยัง onSubmitWithDevice (ซึ่งจะไปเรียก _handleFinalSignUp ใน signup_screen.dart ทันที)
    onSubmitWithDevice({
      'serial_number': serial,
      'device_name': name,
    });
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
            const Text('ขั้นตอนที่ 3: ระบุหมายเลขเครื่องมือกล หรือสแกน QR Code', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),

            // 📸 ปุ่มเปิดกล้องสแกน & ปุ่มเลือกรูปจากอัลบั้ม
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _openCameraScanner(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor, size: 20),
                          SizedBox(width: 8),
                          Text('เปิดกล้องสแกน', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickImageAndScan(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library_rounded, color: AppTheme.textSecondary, size: 20),
                          SizedBox(width: 8),
                          Text('เลือกรูปภาพ', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildInputLabel('หมายเลขซีเรียลนัมเบอร์อุปกรณ์ (Serial Number)'),
            TextFormField(
              controller: serialNumberController,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              decoration: _buildDecoration('เช่น Glove-2569-XXXX หรือสแกนด้านบน', Icons.developer_board_rounded),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
                        elevation: 0
                      ),
                      onPressed: isSubmitting ? null : () => _handleDeviceValidation(context),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 24, 
                              height: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text('ยืนยันลงทะเบียน', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Center(
              child: TextButton(
                onPressed: isSubmitting ? null : onSkip,
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