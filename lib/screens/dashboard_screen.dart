import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../pages/history_page.dart';
import '../pages/settings_page.dart';
import '../pages/training_page.dart';
import '../pages/quick_history_page.dart';
import '../pages/speed_setting_page.dart';
import '../pages/contact_doctor_page.dart';
import '../pages/device_setting_page.dart';

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

  static const List<BarButtonData> _buttonItems = [
    BarButtonData(icon: Icons.home_rounded, label: 'หน้าหลัก'),
    BarButtonData(icon: Icons.bar_chart_rounded, label: 'ประวัติฝึก'),
    BarButtonData(icon: Icons.settings_rounded, label: 'ตั้งค่า'),
  ];

  @override
  Widget build(BuildContext context) {
    String? mockDeviceSerialNumber = null; // สถานะ: ยังไม่ได้ผูกอุปกรณ์
    final bool isDeviceRegistered = mockDeviceSerialNumber != null;

    final List<Map<String, String>> mockHistory = [
      {'date': '17 มิ.ย. 2569', 'time': '15 นาที', 'score': '85%'},
      {'date': '16 มิ.ย. 2569', 'time': '20 นาที', 'score': '90%'},
      {'date': '15 มิ.ย. 2569', 'time': '12 นาที', 'score': '78%'},
    ];

    final List<Widget> pages = [
      // 🏠 หน้าหลักดีไซน์ใหม่พรีเมียม
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟠 1. ส่วนทักทายดีไซน์ใหม่สไตล์แผง Header ไล่เฉดสีส้มพรีเมียม
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFFE67E22)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'สวัสดีครับ 👋',
                            style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'คุณผู้ป่วย',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'วันนี้พร้อมสำหรับโปรแกรมกายภาพบำบัดมือกลแล้วหรือยัง?',
                    style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⚡ 2. ส่วนสถานะบลูทูธ/อุปกรณ์ (เคลียร์คำว่า habits บั๊กพิมพ์เกินออกแล้ว)
                  InkWell(
                    onTap: () {
                      if (isDeviceRegistered) {
                        _showDeviceBottomSheet(context, mockDeviceSerialNumber);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DeviceSettingPage()),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: isDeviceRegistered 
                            ? const Color(0xFF2ECC71).withOpacity(0.06) 
                            : Colors.orange.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDeviceRegistered ? Colors.green.shade400 : Colors.orangeAccent.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDeviceRegistered ? Icons.bluetooth_connected_rounded : Icons.warning_amber_rounded, 
                            color: isDeviceRegistered ? Colors.green.shade700 : Colors.orangeAccent.shade700, 
                            size: 28
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('สถานะอุปกรณ์มือกล', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 15)),
                                const SizedBox(height: 3),
                                Text(
                                  isDeviceRegistered 
                                      ? '⚡ เชื่อมต่อถุงมืออัจฉริยะแล้ว (คลิกดูข้อมูล)' 
                                      : '⚠️ ยังไม่ได้ลงทะเบียนถุงมือกล (คลิกเพื่อผูกอุปกรณ์)', 
                                  style: TextStyle(
                                    color: isDeviceRegistered ? Colors.green.shade800 : Colors.orange.shade900, 
                                    fontWeight: FontWeight.w600, 
                                    fontSize: 12
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDeviceRegistered ? Colors.green.withOpacity(0.5) : Colors.orangeAccent)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 🦾 3. ปุ่มเริ่มโหมดฝึกซ้อม ดีไซน์ใหม่แบบ "Hero Banner" (แก้ไขจาก shadows เป็น boxShadow เรียบร้อย)
                  const Text('เมนูหลัก', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 14),
                  
                  Container(
                    width: double.infinity,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ]
                    ),
                    child: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrainingPage())),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('เริ่มโหมดฝึกซ้อม', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                SizedBox(height: 4),
                                Text('เปิดระบบคุมถุงมือและบันทึกผลสถิติ', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 48),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 📊 4. เมนูย่อยแบบ Grid
                  GridView.count(
                    crossAxisCount: 2, 
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5, 
                    children: [
                      _buildModernMenuCard(context, 'ประวัติย้อนหลัง', Icons.insert_chart_rounded, Colors.blue.shade700, const QuickHistoryPage()),
                      _buildModernMenuCard(context, 'ติดต่อแพทย์', Icons.forum_rounded, Colors.teal.shade600, const ContactDoctorPage()),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // 🏆 5. รายการประวัติการฝึกฝนล่าสุด
                  const Text('บันทึกการฝึกซ้อมล่าสุด', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 14),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: mockHistory.length,
                    itemBuilder: (context, index) {
                      final item = mockHistory[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                          ]
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: AppTheme.backgroundColor, shape: BoxShape.circle),
                            child: const Icon(Icons.accessibility_new_rounded, color: AppTheme.primaryColor, size: 22),
                          ),
                          title: Text('วันที่ฝึก: ${item['date']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 14)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('เวลาที่ใช้: ${item['time']}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ),
                          trailing: Text(
                            '${item['score']}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryColor, fontSize: 18),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const HistoryPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: pages[_currentIndex],
      
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (int i = 0; i < _buttonItems.length; i++) ...[
              _buildCustomBarButton(index: i, isActive: _currentIndex == i, data: _buttonItems[i]),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildModernMenuCard(BuildContext context, String title, IconData icon, Color uiColor, Widget targetPage) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08))
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage)),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: uiColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: uiColor, size: 20),
              ),
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

  Widget _buildCustomBarButton({required int index, required bool isActive, required BarButtonData data}) {
    final activeColor = AppTheme.primaryColor;
    final inactiveColor = AppTheme.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        splashColor: activeColor.withOpacity(0.05),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? activeColor.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, color: isActive ? activeColor : inactiveColor, size: isActive ? 24 : 22),
            ),
            const SizedBox(height: 3),
            Text(
              data.label,
              style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? activeColor : inactiveColor),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceBottomSheet(BuildContext context, String? serial) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.precision_manufacturing_rounded, color: AppTheme.primaryColor, size: 26),
                SizedBox(width: 12),
                Text('ข้อมูลอุปกรณ์มือกล', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ],
            ),
            const Divider(height: 32),
            Text('ชื่ออุปกรณ์: ถุงมือกลกายภาพบำบัดอัจฉริยะ', style: TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text('Serial Number: $serial', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 10),
            const Text('สถานะองศามือปัจจุบัน: สแตนด์บาย (0°)', style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}