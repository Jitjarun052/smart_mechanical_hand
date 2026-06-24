import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickHistoryPage extends StatelessWidget {
  const QuickHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎯 Mock ข้อมูลประวัติการฝึกซ้อมแบบละเอียดยิบตามดีไซน์รูปภาพของคุณ
    final List<Map<String, dynamic>> mockData = [
      {
        'date': 'วันนี้, 18 มิ.ย.',
        'count': '150 ครั้ง',
        'time': '25 นาที',
        'accuracy': '88%',
        'color': const Color(0xFF38B6FF), // แถบสีฟ้า
      },
      {
        'date': '17 มิ.ย. 2569',
        'count': '200 ครั้ง',
        'time': '45 นาที',
        'accuracy': '92%',
        'color': const Color(0xFFFFD166), // แถบสีเหลือง
      },
      {
        'date': '15 มิ.ย. 2569',
        'count': '120 ครั้ง',
        'time': '15 นาที',
        'accuracy': '80%',
        'color': const Color(0xFF06D6A0), // แถบสีเขียวมิ้นต์
      },
      {
        'date': '14 มิ.ย. 2569',
        'count': '180 ครั้ง',
        'time': '35 นาที',
        'accuracy': '85%',
        'color': AppTheme.primaryColor, // แถบสีส้มอิฐหลัก
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'ประวัติย้อนหลัง',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        itemCount: mockData.length,
        itemBuilder: (context, index) {
          final item = mockData[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // 🎨 1. แถบสีตกแต่งด้านซ้าย (Color Indicator) ตามดีไซน์รูปภาพ
                    Container(
                      width: 5,
                      color: item['color'],
                    ),
                    const SizedBox(width: 16),
                    
                    // 📝 2. ส่วนเนื้อหาข้อมูลหลัก
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // แถววันที่ + ไอคอนลูกศรขวา
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['date'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // แถวแสดงพารามิเตอร์ 3 ค่า (จำนวนครั้ง, เวลา, ความแม่นยำ)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusItem(Icons.back_hand_rounded, 'จำนวนครั้ง', item['count']),
                                _buildStatusItem(Icons.access_time_filled_rounded, 'เวลา', item['time']),
                                _buildStatusItem(Icons.track_changes_rounded, 'ความแม่นยำ', item['accuracy']),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget ย่อยสำหรับสร้างชุดไอคอน + ข้อความ (ตัวพารามิเตอร์)
  Widget _buildStatusItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryColor.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}