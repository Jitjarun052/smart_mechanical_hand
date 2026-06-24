import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔔 Mock รายการแจ้งเตือนที่สอดรับกับความก้าวหน้าของถุงมือกล
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'ถึงเวลาออกกำลังกายแล้ว!',
        'subtitle': 'อย่าลืมออกกำลังกายวันนี้ด้วยนะคะ',
        'time': '10 นาทีที่แล้ว',
        'icon': Icons.fitness_center_rounded,
        'iconColor': Colors.blue,
        'isUnread': true, // 🔵 แสดงจุดฟ้าว่ายังไม่อ่าน
      },
      {
        'title': 'ความสำเร็จใหม่! 🏆',
        'subtitle': 'คุณทำสถิติฝึกเหยียดนิ้วได้สำเร็จ 5 วันติดต่อกัน',
        'time': '1 ชั่วโมงที่แล้ว',
        'icon': Icons.emoji_events_rounded,
        'iconColor': Colors.amber,
        'isUnread': true,
      },
      {
        'title': 'อัปเดตแอปเวอร์ชันใหม่',
        'subtitle': 'อัปเดตระบบเสถียรภาพการรับค่าองศาเซนเซอร์เพื่อการใช้งานที่ดีขึ้น',
        'time': '1 วันที่แล้ว',
        'icon': Icons.system_update_rounded,
        'iconColor': Colors.grey,
        'isUnread': false,
      },
      {
        'title': 'ยินดีต้อนรับคุณผู้ป่วย!',
        'subtitle': 'ขอบคุณที่เลือกใช้งานระบบกายภาพบำบัดมือกลอัจฉริยะ เริ่มต้นรันเซสชันแรกกันเลย!',
        'time': '3 วันที่แล้ว',
        'icon': Icons.handshake_rounded,
        'iconColor': AppTheme.primaryColor,
        'isUnread': false,
      },
    ];
    
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
          'การแจ้งเตือน',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // 🎨 วงกลมไอคอนฝั่งซ้ายสไตล์ Material
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (item['iconColor'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'], color: item['iconColor'], size: 24),
                  ),
                  const SizedBox(width: 16),
                  
                  // 📝 รายละเอียดข้อความ คุมโครงสร้างกันตัวหนังสือล้นจอ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['subtitle'],
                          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['time'],
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  
                  // 🔵 จุดไข่ปลาสีฟ้าแสดงสถานะยังไม่ได้อ่านด้านขวาสุด
                  if (item['isUnread'])
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}