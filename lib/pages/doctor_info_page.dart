import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DoctorInfoScreen extends StatelessWidget {
  const DoctorInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('แพทย์ผู้ดูแล', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary)),
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
          children: [
            const SizedBox(height: 16),
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
                    const Text('นพ. สมชาย รักดี', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const Text('แพทย์ผู้เชี่ยวชาญด้านเวชศาสตร์ฟื้นฟู', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Text('โรงพยาบาลศูนย์กายภาพบำบัด', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.local_hospital_rounded, color: AppTheme.textSecondary),
                    title: Text('แผนก / คลินิก', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    trailing: Text('ศูนย์ฟื้นฟูสมรรถภาพสมอง', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone_rounded, color: Colors.green),
                    title: const Text('เบอร์ติดต่อสายด่วนโรงพยาบาล', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    trailing: const Text('02-XXX-XXXX', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กำลังจำลองการโทรออกไปยังศูนย์การแพทย์...')),
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