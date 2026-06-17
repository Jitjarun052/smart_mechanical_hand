import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '📊 หน้าแสดงกราฟและประวัติฝึกซ้อมย้อนหลัง (Mock)',
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}