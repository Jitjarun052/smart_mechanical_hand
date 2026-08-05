import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
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

  // 📷 1. ฟังก์ชันเปิดกล้องสแกน QR Code แบบ Modal / BottomSheet
  void _openCameraScanner() {
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
              // แถบหัว Modal
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
              
              // กล้องสแกน QR Code
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
                              // 🟢 ได้ค่า Serial มาแล้ว นำไปใส่ใน TextField ทันที!
                              setState(() {
                                _serialController.text = barcode.rawValue!;
                              });
                              scannerController.dispose();
                              Navigator.pop(ctx); // ปิดหน้าสแกน
                              
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
                      // กรอบสี่เหลี่ยมมาร์กจุดสแกน
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

  // 🖼️ 2. ฟังก์ชันเลือกรูปภาพจาก Gallery แล้วดึงค่า QR Code
  Future<void> _pickImageAndScan() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return; // ผู้ใช้ยกเลิกการเลือกรูป

      if (kIsWeb) {
        _showResultModal(
          title: 'ไม่รองรับบนเว็บ',
          message: 'ฟังก์ชันสแกนจากรูปภาพรองรับเฉพาะบนแอปพลิเคชันมือถือ (Android/iOS) เท่านั้น กรุณาใช้ปุ่ม "เปิดกล้องสแกน" แทนครับ',
          isSuccess: false,
        );
        return;
      }
      
      final MobileScannerController controller = MobileScannerController();
      final BarcodeCapture? capture = await controller.analyzeImage(image.path);
      controller.dispose();

      if (capture != null && capture.barcodes.isNotEmpty) {
        final String? code = capture.barcodes.first.rawValue;
        if (code != null && code.isNotEmpty) {
          setState(() {
            _serialController.text = code;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('อ่านค่า QR Code สำเร็จ: $code'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _showResultModal(
            title: 'อ่านค่าไม่สำเร็จ',
            message: 'ไม่พบข้อมูล QR Code ในรูปภาพนี้',
            isSuccess: false,
          );
        }
      } else {
        _showResultModal(
          title: 'ไม่พบ QR Code',
          message: 'รูปภาพที่เลือกไม่มี QR Code หรือรูปไม่ชัดเจน',
          isSuccess: false,
        );
      }
    } catch (e) {
      _showResultModal(
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถอ่านไฟล์รูปภาพได้: $e',
        isSuccess: false,
      );
    }
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
      _showResultModal(
        title: 'ลงทะเบียนสำเร็จ! 🎉',
        message: 'ผูกอุปกรณ์มือกลเข้ากับบัญชีของคุณเรียบร้อยแล้ว',
        isSuccess: true,
        onConfirm: () {
          Navigator.pop(context);
          Navigator.pop(context, true);
        },
      );
    } else {
      _showResultModal(
        title: 'ไม่สามารถผูกอุปกรณ์ได้',
        message: result['message'] ?? 'เกิดข้อผิดพลาด',
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
                Navigator.pop(context);
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
            const Text('ระบุหมายเลขเครื่องมือกล หรือสแกน QR Code เพื่อเริ่มระบบ', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),

            // 📸 ปุ่มทางเลือกสแกน: เปิดกล้อง / เลือกไฟล์รูป
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _openCameraScanner,
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
                    onTap: _pickImageAndScan,
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

            // 1. ช่องกรอก Serial Number
            const Text('หมายเลขซีเรียลนัมเบอร์อุปกรณ์ (Serial Number)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _serialController,
              decoration: InputDecoration(
                hintText: 'เช่น Glove-2569-XXXX หรือกดสแกนด้านบน',
                prefixIcon: const Icon(Icons.pin_rounded, color: AppTheme.primaryColor),
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