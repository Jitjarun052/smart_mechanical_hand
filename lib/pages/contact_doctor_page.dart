import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ContactDoctorPage extends StatelessWidget {
  const ContactDoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('ติดต่อผู้ดูแล/แพทย์', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(radius: 50, backgroundColor: Colors.teal, child: Icon(Icons.healing_rounded, size: 50, color: Colors.white)),
            const SizedBox(height: 16),
            const Text('นพ.สมชาย ตั้งใจรักษา', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const Text('แพทย์ผู้เชี่ยวชาญด้านกายภาพบำบัด', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 32),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.teal),
                title: const Text('เบอร์โทรศัพท์ติดต่อด่วน'),
                subtitle: const Text('089-123-4567'),
                trailing: IconButton(icon: const Icon(Icons.call), onPressed: () {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}