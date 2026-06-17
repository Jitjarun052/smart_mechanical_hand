import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// 1. โมเดลข้อมูลปุ่มสำหรับเอาไว้ลูปบาร์ด้านล่างตามไอเดียคุณ
class BarButtonData {
  final IconData icon;
  final String label;
  const BarButtonData({required this.icon, required this.label});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // 🎯 รายการปุ่มที่เราจะเอาไว้รันลูปใน Bar ข้างล่างหน้าจอ
  static const List<BarButtonData> _buttonItems = [
    BarButtonData(icon: Icons.home_rounded, label: 'หน้าหลัก'),
    BarButtonData(icon: Icons.bar_chart_rounded, label: 'ประวัติฝึก'),
    BarButtonData(icon: Icons.settings_rounded, label: 'ตั้งค่า'),
  ];

  @override
  Widget build(BuildContext context) {
    // 🎯 Mock ข้อมูลประวัติการฝึกซ้อมล่าสุดของผู้ป่วย
    final List<Map<String, String>> mockHistory = [
      {'date': '17 มิ.ย. 2569', 'time': '15 นาที', 'score': '85%'},
      {'date': '16 มิ.ย. 2569', 'time': '20 นาที', 'score': '90%'},
      {'date': '15 มิ.ย. 2569', 'time': '12 นาที', 'score': '78%'},
    ];

    // รายชื่อหน้าที่จะสลับ (Index 0 = หน้าแดชบอร์ดเดิม, Index 1 และ 2 = หน้าจำลอง)
    final List<Widget> pages = [
      // 🏠 [หน้าหลัก - โค้ดเดิมทั้งหมดของคุณ]
      SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ส่วนทักทายผู้ใช้แอป
            const Text(
              'สวัสดีครับ, คุณผู้ป่วย 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'วันนี้พร้อมสำหรับโปรแกรมกายภาพบำบัดมือกลแล้วหรือยัง?',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),

            // 2. การ์ดแจ้งเตือนสถานะถุงมือ (Smart Glove Connection)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
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
                        Text(
                          'สถานะอุปกรณ์มือกล',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 16),
                        ),
                        Text(
                          'เชื่อมต่อถุงมืออัจฉริยะแล้ว (Mocked)',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 3. เมนูด่วนในการสั่งงาน (Grid Menu)
            const Text(
              'เมนูใช้งาน',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildMenuCard(context, 'เริ่มโหมดฝึกซ้อม', Icons.play_circle_fill_rounded, AppTheme.primaryColor),
                _buildMenuCard(context, 'ประวัติย้อนหลัง', Icons.bar_chart_rounded, Colors.blueGrey),
                _buildMenuCard(context, 'ตั้งค่าความเร็ว', Icons.speed_rounded, Colors.orange),
                _buildMenuCard(context, 'ติดต่อผู้ดูแล/แพทย์', Icons.contact_support_rounded, Colors.teal),
              ],
            ),
            const SizedBox(height: 32),

            // 4. แสดงลิสต์ประวัติการฝึกซ้อมย้อนหลัง (Mock ล่าสุด)
            const Text(
              'บันทึกการฝึกซ้อมล่าสุด',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
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
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.backgroundColor,
                      child: Icon(Icons.accessibility_new_rounded, color: AppTheme.primaryColor),
                    ),
                    title: Text('วันที่ฝึก: ${item['date']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('เวลาที่ใช้: ${item['time']}'),
                    trailing: Text(
                      'คะแนน ${item['score']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // 📊 [หน้าย่อยประวัติฝึกซ้อม]
      const Center(child: Text('📊 หน้าแสดงกราฟและประวัติฝึกซ้อมย้อนหลังแบบละเอียด (Mock)')),
      // ⚙️ [หน้าย่อยตั้งค่า]
      const Center(child: Text('⚙️ หน้าตั้งค่าอุปกรณ์มือกลและความเร็ว (Mock)')),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'หน้าหลักผู้ป่วย',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.primaryColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      // 🚀 แสดงเนื้อหาหน้าตาม Index ปุ่มด้านล่างที่โดนคลิก
      body: pages[_currentIndex],
      
      // 🛠️ แถบ Button Bar ด้านล่างที่รันด้วย Loop ข้อมูลปุ่มตามไอเดียของคุณ
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // เริ่มต้นการลูปเอาข้อมูลปุ่มบาร์มาพ่นแสดงผลเป็น UI บนหน้าจอ
            for (int i = 0; i < _buttonItems.length; i++) ...[
              _buildCustomBarButton(
                index: i,
                isActive: _currentIndex == i,
                data: _buttonItems[i],
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Widget สำหรับสร้างปุ่มย่อยแต่ละอันใน Button Bar ด้านล่าง
  Widget _buildCustomBarButton({
    required int index,
    required bool isActive,
    required BarButtonData data,
  }) {
    final activeColor = AppTheme.primaryColor;
    final inactiveColor = AppTheme.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index; // กดแล้วสั่งอัปเดตสลับเนื้อหาด้านบนทันที
          });
        },
        splashColor: activeColor.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                data.icon,
                color: isActive ? activeColor : inactiveColor,
                size: isActive ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ตัวช่วยสร้างการ์ดเมนูในหน้าหลัก (Grid Menu)
  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('กำลังเปิดฟังก์ชัน: $title (Mock)')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}