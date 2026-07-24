import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../theme/app_theme.dart';

class DoctorInfoScreen extends StatefulWidget {
  final String? userToken; // 🔑 รับ Token ของผู้ป่วยเข้ามารับข้อมูลหมอ

  const DoctorInfoScreen({super.key, this.userToken});

  @override
  State<DoctorInfoScreen> createState() => _DoctorInfoScreenState();
}

class _DoctorInfoScreenState extends State<DoctorInfoScreen> {
  bool _isLoading = true;

  // 🩺 ตัวแปรสำหรับเก็บข้อมูลแพทย์ประจำตัว
  String _doctorName = 'ยังไม่ได้ผูกแพทย์ผู้ดูแล';
  String _doctorSpecialty = 'แพทย์ผู้เชี่ยวชาญด้านกายภาพบำบัด';
  String _hospitalName = 'โรงพยาบาลศูนย์กายภาพบำบัด';
  String _department = 'ศูนย์ฟื้นฟูสมรรถภาพการเคลื่อนไหว';
  String _hospitalPhone = 'ไม่มีข้อมูลเบอร์ติดต่อ';

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  // 📡 ยิง API ไปที่ /api/user/me เพื่อดึงข้อมูลหมอที่ JOIN มากับ User
  Future<void> _fetchDoctorData() async {
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
          _doctorSpecialty = userData['doctor_specialty'] ?? 'แพทย์ผู้เชี่ยวชาญด้านเวชศาสตร์ฟื้นฟู';
          _hospitalName = userData['hospital_name'] ?? 'โรงพยาบาลศูนย์กายภาพบำบัด';
          _hospitalPhone = userData['hospital_phone'] ?? '02-123-4567';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'แพทย์ผู้ดูแล',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // 👨‍⚕️ Card สรุปโปรไฟล์แพทย์
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: const Icon(Icons.medical_services_rounded, size: 50, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _doctorName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _doctorSpecialty,
                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _hospitalName,
                              style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🏥 Card ข้อมูลแผนกและเบอร์โทรติดต่อ
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.local_hospital_rounded, color: AppTheme.textSecondary),
                          title: const Text('แผนก / คลินิก', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                          trailing: Text(
                            _department,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.phone_rounded, color: Colors.green),
                          title: const Text('เบอร์ติดต่อสายด่วนโรงพยาบาล', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                          trailing: Text(
                            _hospitalPhone,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('กำลังโทรออกไปยัง $_hospitalName ($_hospitalPhone)...')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}