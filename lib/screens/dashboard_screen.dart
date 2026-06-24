import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../pages/history_page.dart';
import '../pages/settings_page.dart';
import '../pages/training_page.dart';
import '../pages/quick_history_page.dart';
import '../pages/speed_setting_page.dart';
import '../pages/contact_doctor_page.dart';
import '../pages/device_setting_page.dart';

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
    // 🦾 [Mock Data สำหรับเทสเปลี่ยนสถานะ]
    // String? mockDeviceSerialNumber = "Glove-2026-9999"; // สถานะ: มีอุปกรณ์ผูกอยู่
    String? mockDeviceSerialNumber = null;               // สถานะ: ยังไม่ได้ผูกอุปกรณ์

    final bool isDeviceRegistered = mockDeviceSerialNumber != null;

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

            // 🚀 2. [จุดอัปเดตแก้มือคลิก & บั๊กตัวหนังสือล้น]: เปลี่ยนมาใช้ InkWell + Container แยกสถานะ
            InkWell(
              onTap: () {
                print("DEBUG: จิ้มโดนปุ่มสถานะอุปกรณ์แล้ว! ค่าระบบ = $isDeviceRegistered");
                if (isDeviceRegistered) {
                  // 🟢 2.1 เงื่อนไขหากเชื่อมต่อสำเร็จแล้ว -> ดึงหน้าต่างข้อมูลองศามือขึ้นมา
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    backgroundColor: Colors.white,
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.precision_manufacturing_rounded, color: AppTheme.primaryColor, size: 28),
                              SizedBox(width: 12),
                              Text('ข้อมูลอุปกรณ์มือกล', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                            ],
                          ),
                          const Divider(height: 32),
                          const Text('ชื่ออุปกรณ์: ถุงมือกลกายภาพบำบัดอัจฉริยะ', style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
                          const SizedBox(height: 10),
                          Text('Serial Number: $mockDeviceSerialNumber', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                          const SizedBox(height: 10),
                          const Text('สถานะองศามือปัจจุบัน: สแตนด์บาย (0°)', style: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DeviceSettingPage()),
                    );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isDeviceRegistered 
                      ? AppTheme.primaryColor.withOpacity(0.05) 
                      : Colors.orange.shade50.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDeviceRegistered ? AppTheme.primaryColor : Colors.orangeAccent.shade400,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDeviceRegistered ? Icons.bluetooth_connected_rounded : Icons.warning_amber_rounded, 
                      color: isDeviceRegistered ? AppTheme.primaryColor : Colors.orangeAccent.shade700, 
                      size: 32
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('สถานะอุปกรณ์มือกล', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(
                            isDeviceRegistered 
                                ? '⚡ เชื่อมต่อถุงมืออัจฉริยะแล้ว (คลิกดูข้อมูล)' 
                                : '⚠️ ยังไม่ได้ลงทะเบียนถุงมือกล (คลิกเพื่อผูกอุปกรณ์)', 
                            style: TextStyle(
                              color: isDeviceRegistered ? Colors.green.shade700 : Colors.orange.shade900, 
                              fontWeight: FontWeight.w600, 
                              fontSize: 13
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded, 
                      size: 16, 
                      color: isDeviceRegistered ? AppTheme.primaryColor.withOpacity(0.4) : Colors.orangeAccent
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

           // 3. เมนูด่วนในการสั่งงาน (จัดโครงสร้างใหม่ตามไอเดียคุณ)
            const Text(
              'เมนูใช้งาน',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),

            // 🚀 3.1 เอาการ์ดเริ่มฝึกซ้อมมาตั้งตระหง่านไว้บนสุดเดี่ยว ๆ (ขนาดใหญ่ขึ้น เห็นชัดเจน)
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 200, // ปรับความสูงให้พอดี ดูนุ่มนวล
                child: _buildMenuCard(
                  context, 
                  'เริ่มโหมดฝึกซ้อม', 
                  Icons.play_circle_fill_rounded, 
                  AppTheme.primaryColor, 
                  isHighlight: true, // ยังคงความเด่นสีส้มอิฐไว้ครับ
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🚀 3.2 เอาการ์ดที่เหลืออีก 2 อันมาซอยเรียงแถวหน้ากระดาน
            GridView.count(
              crossAxisCount: 2, 
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4, 
              children: [
                _buildMenuCard(context, 'ประวัติย้อนหลัง', Icons.bar_chart_rounded, Colors.blueGrey),
                _buildMenuCard(context, 'ติดต่อแพทย์', Icons.contact_support_rounded, Colors.teal),
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
      const HistoryPage(),
      // ⚙️ [หน้าย่อยตั้งค่า]
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
            _currentIndex = index; 
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
  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, {bool isHighlight = false}) {
    return Card(
      elevation: isHighlight ? 4 : 1, 
      color: isHighlight ? AppTheme.primaryColor : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isHighlight ? BorderSide.none : BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
          Widget destinationPage;
          if (title == 'เริ่มโหมดฝึกซ้อม') {
            destinationPage = const TrainingPage();
          } else if (title == 'ประวัติย้อนหลัง') {
            destinationPage = const QuickHistoryPage();
          } else if (title == 'ตั้งค่าความเร็ว') {
            destinationPage = const SpeedSettingPage();
          } else {
            destinationPage = const ContactDoctorPage();
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6), 
                decoration: BoxDecoration(
                  color: isHighlight ? Colors.white : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: isHighlight ? AppTheme.primaryColor : color, 
                  size: 24 
                ),
              ),
              const SizedBox(height: 10), 
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: isHighlight ? Colors.white : AppTheme.textPrimary, 
                  fontSize: 12 
                ),
                maxLines: 1, 
                overflow: TextOverflow.ellipsis, 
              ),
            ],
          ),
        ),
      ),
    );
  }
}