import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mockHistory = [
      {'date': '17 มิ.ย. 2569', 'time': '15 นาที', 'score': '85%'},
      {'date': '16 มิ.ย. 2569', 'time': '20 นาที', 'score': '90%'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('สวัสดีครับ, คุณผู้ป่วย 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          const Text('วันนี้พร้อมสำหรับโปรแกรมกายภาพบำบัดมือกลแล้วหรือยัง?', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
            color: AppTheme.primaryColor.withOpacity(0.05),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.bluetooth_connected_rounded, color: AppTheme.primaryColor, size: 32),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('สถานะอุปกรณ์มือกล', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 16)),
                      Text('เชื่อมต่อถุงมืออัจฉริยะแล้ว (Mocked)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('บันทึกการฝึกซ้อมล่าสุด', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockHistory.length,
            itemBuilder: (context, index) {
              final item = mockHistory[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: AppTheme.backgroundColor, child: Icon(Icons.accessibility_new_rounded, color: AppTheme.primaryColor)),
                  title: Text('วันที่ฝึก: ${item['date']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('เวลาที่ใช้: ${item['time']}'),
                  trailing: Text('คะแนน ${item['score']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 16)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}