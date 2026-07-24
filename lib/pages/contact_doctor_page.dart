import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // 💡 นำเข้าแพ็กเกจสำหรับกดโทรออก (ถ้ามี)
import '../api/auth_service.dart';
import '../theme/app_theme.dart';

class ContactDoctorPage extends StatefulWidget {
  final String? userToken; // 🔑 รับ Token ของผู้ป่วยที่ล็อกอินเข้ามา

  const ContactDoctorPage({super.key, this.userToken});

  @override
  State<ContactDoctorPage> createState() => _ContactDoctorPageState();
}

class _ContactDoctorPageState extends State<ContactDoctorPage> {
  bool _isLoading = true;
  
  // 🩺 ตัวแปรสำหรับเก็บข้อมูลแพทย์ประจำตัว
  String _doctorName = 'ไม่พบข้อมูลแพทย์ผู้ดูแล';
  String _doctorSpecialty = 'แพทย์ผู้เชี่ยวชาญ';
  String _hospitalName = 'โรงพยาบาลศูนย์กายภาพบำบัด';
  String _hospitalPhone = 'ไม่มีข้อมูลเบอร์โทรศัพท์';

  @override
  void initState() {
    super.initState();
    _fetchDoctorInfo();
  }

  // 📡 ฟังก์ชันยิง API ดึงข้อมูลแพทย์จาก /api/user/me
  Future<void> _fetchDoctorInfo() async {
    if (widget.userToken == null || widget.userToken!.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final result = await AuthService.getMe(widget.userToken!);

    if (mounted) {
      if (result['success'] == true) {
        final userData = result['user'];
        setState(() {
          _doctorName = userData['doctor_name'] ?? 'ยังไม่ได้ผูกแพทย์ผู้ดูแล';
          _doctorSpecialty = userData['doctor_specialty'] ?? 'แพทย์ผู้เชี่ยวชาญกายภาพบำบัด';
          _hospitalName = userData['hospital_name'] ?? 'โรงพยาบาลศูนย์กายภาพบำบัด';
          _hospitalPhone = userData['hospital_phone'] ?? userData['phone'] ?? '02-123-4567';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  // 📞 ฟังก์ชันกดสั่งโทรออกไปยังเบอร์โรงพยาบาล/แพทย์
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถโทรออกไปที่ $phoneNumber ได้')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'ติดต่อผู้ดูแล/แพทย์', 
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // 👨‍⚕️ รูปไอคอนโปรไฟล์แพทย์
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.healing_rounded, size: 48, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📝 ชื่อแพทย์ และ ความเชี่ยวชาญ
                  Text(
                    _doctorName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _doctorSpecialty,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _hospitalName,
                    style: TextStyle(fontSize: 13, color: Colors.teal.shade700, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // 📞 การ์ดแสดงเบอร์โทรศัพท์พร้อมปุ่มกดโทรออก[cite: 12]
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone_in_talk_rounded, color: Colors.teal, size: 24),
                        ),
                        title: const Text(
                          'เบอร์โทรศัพท์ติดต่อด่วน', 
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        subtitle: Text(
                          _hospitalPhone, 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        trailing: IconButton(
                          icon: const CircleAvatar(
                            backgroundColor: Colors.teal,
                            radius: 18,
                            child: Icon(Icons.call, color: Colors.white, size: 18),
                          ),
                          onPressed: () => _makePhoneCall(_hospitalPhone), // กดแล้วโทรออกทันที
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}