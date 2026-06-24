import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedTab = 1; 
  
  // ตัวแปรเก็บสถานะคำเลือกบน Dropdown
  String _selectedYear = 'ปี: 2569';
  String _selectedMonth = 'เดือน: ม.ค.';

  // ก้อนข้อมูลสรุปสถิติตามช่วงเวลา
  // ก้อนข้อมูลแยกตาม ปี -> ประเภทแท็บ -> ข้อมูลสถิติ
  final Map<String, Map<int, Map<String, dynamic>>> _statsByYearAndTab = {
    'ปี: 2569': {
      0: {
        'totalCount': '55 ครั้ง',
        'accuracy': '92 %',
        'totalTime': '15 นาที',
        'sessions': '1 ครั้ง',
        'chartScores': [0.0, 0.0, 0.0, 0.0, 55.0],
        'chartLabels': ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.'],
      },
      1: { // ม.ค. 2569 (Default ของแท็บรายสัปดาห์)
        'totalCount': '1,550 ครั้ง',
        'accuracy': '95 %',
        'totalTime': '145 นาที',
        'sessions': '28 ครั้ง',
        'chartScores': [75.0, 80.0, 78.0, 85.0, 92.0],
        'chartLabels': ['สัปดาห์ 1', 'สัปดาห์ 2', 'สัปดาห์ 3', 'สัปดาห์ 4', 'สัปดาห์ 5'],
      },
      2: {
        'totalCount': '5,840 ครั้ง',
        'accuracy': '89 %',
        'totalTime': '620 นาที',
        'sessions': '96 ครั้ง',
        'chartScores': [82.0, 88.0, 95.0, 0.0, 0.0],
        'chartLabels': ['พ.ย.', 'ธ.ค.', 'ม.ค.', 'ก.พ.', 'มี.ค.'],
      },
      3: { // ก.พ. 2569 ย่อย
        'totalCount': '1,820 ครั้ง',
        'accuracy': '96 %',
        'totalTime': '180 นาที',
        'sessions': '32 ครั้ง',
        'chartScores': [80.0, 85.0, 90.0, 88.0, 96.0],
        'chartLabels': ['สัปดาห์ 1', 'สัปดาห์ 2', 'สัปดาห์ 3', 'สัปดาห์ 4', 'สัปดาห์ 5'],
      },
      4: { // มี.ค. 2569 ย่อย
        'totalCount': '1,210 ครั้ง',
        'accuracy': '91 %',
        'totalTime': '110 นาที',
        'sessions': '20 ครั้ง',
        'chartScores': [70.0, 75.0, 82.0, 80.0, 91.0],
        'chartLabels': ['สัปดาห์ 1', 'สัปดาห์ 2', 'สัปดาห์ 3', 'สัปดาห์ 4', 'สัปดาห์ 5'],
      }
    },
    'ปี: 2568': {
      0: {
        'totalCount': '40 ครั้ง',
        'accuracy': '85 %',
        'totalTime': '12 นาที',
        'sessions': '1 ครั้ง',
        'chartScores': [40.0, 0.0, 0.0, 0.0, 0.0],
        'chartLabels': ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.'],
      },
      1: { // รายสัปดาห์ ปี 2568 (สมมุติตามเดือนที่เลือก)
        'totalCount': '980 ครั้ง',
        'accuracy': '88 %',
        'totalTime': '90 นาที',
        'sessions': '15 ครั้ง',
        'chartScores': [60.0, 65.0, 70.0, 68.0, 72.0],
        'chartLabels': ['สัปดาห์ 1', 'สัปดาห์ 2', 'สัปดาห์ 3', 'สัปดาห์ 4', 'สัปดาห์ 5'],
      },
      2: {
        'totalCount': '3,400 ครั้ง',
        'accuracy': '86 %',
        'totalTime': '410 นาที',
        'sessions': '50 ครั้ง',
        'chartScores': [70.0, 75.0, 80.0, 85.0, 88.0],
        'chartLabels': ['พ.ย.', 'ธ.ค.', 'ม.ค.', 'ก.พ.', 'มี.ค.'],
      }
    },
  };

  @override
  Widget build(BuildContext context) {

    final Map<int, Map<String, dynamic>> statsOfSelectedYear = 
        _statsByYearAndTab[_selectedYear] ?? _statsByYearAndTab['ปี: 2569']!;

    // 💡 🛠️ ปรับการเช็คข้อมูลใหม่: ดึงข้อมูลพื้นฐานจากแท็บหลักก่อนเสมอแบบปลอดภัย
    Map<String, dynamic> currentStats;

    // 2. ใช้ Logic ที่คุณปรับปรุงไว้มาคัดกรองแท็บและเดือนย่อยจากปีนั้น ๆ
    if (_selectedTab == 0) {
      // รายวัน
      currentStats = statsOfSelectedYear[0]!;
    } else if (_selectedTab == 1) {
      // รายสัปดาห์ — แยกย่อยตามเดือน (ตรวจเช็คเฉพาะปี 2569 เป็นหลักก่อน)
      if (_selectedYear == 'ปี: 2569' && _selectedMonth == 'เดือน: ก.พ.') {
        currentStats = statsOfSelectedYear[3]!;
      } else if (_selectedYear == 'ปี: 2569' && _selectedMonth == 'เดือน: มี.ค.') {
        currentStats = statsOfSelectedYear[4]!;
      } else {
        currentStats = statsOfSelectedYear[1]!; // ม.ค. default หรือปีอื่น ๆ
      }
    } else {
      // รายเดือน
      currentStats = statsOfSelectedYear[2]!;
    }
    
    final List<double> weeklyScores = List<double>.from(currentStats['chartScores'] ?? [0.0, 0.0, 0.0, 0.0, 0.0]);
    final List<String> weeks = List<String>.from(currentStats['chartLabels'] ?? ['', '', '', '', '']);

    final List<Map<String, String>> detailedHistory = [
      {'date': '17 มิ.ย. 2569', 'time': '15:30 น.', 'duration': '15 นาที', 'score': '85%', 'mode': 'โหมดอัตโนมัติ'},
      {'date': '16 มิ.ย. 2569', 'time': '10:15 น.', 'duration': '20 นาที', 'score': '90%', 'mode': 'โหมดฝึกงอ-เหยียด'},
      {'date': '15 มิ.ย. 2569', 'time': '18:45 น.', 'duration': '12 นาที', 'score': '78%', 'mode': 'โหมดอัตโนมัติ'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('รายงานผลฟื้นฟู', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    Text('ข้อมูลสรุปกลไกมือกล', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                
                Row(
                  children: [
                    // 1. Dropdown เลือกเดือน
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.15))
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMonth, 
                          icon: const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.primaryColor),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          items: <String>['เดือน: ม.ค.', 'เดือน: ก.พ.', 'เดือน: มี.ค.']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedMonth = newValue; // ตัวหนังสือเปลี่ยนปุ๊บ บล็อกคำนวณข้างบนจะสลับก้อนปีใน Map ทันทีครับ
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // 2. Dropdown เลือกปี
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.15))
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedYear, 
                          icon: const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.primaryColor),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          items: <String>['ปี: 2569', 'ปี: 2568']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedYear = newValue; // ตัวหนังสือเปลี่ยนปุ๊บ บล็อกคำนวณข้างบนจะสลับก้อนปีใน Map ทันทีครับ
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),

            // แท็บเม็ดยาเปลี่ยนช่วงเวลา (รายวัน / รายสัปดาห์ / รายเดือน)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCapsuleTab(0, 'รายวัน'),
                _buildCapsuleTab(1, 'รายสัปดาห์'),
                _buildCapsuleTab(2, 'รายเดือน'),
              ],
            ),
            const SizedBox(height: 24),

            _buildWideStatCard(
              icon: Icons.back_hand_rounded,
              value: currentStats['totalCount'] ?? '0 ครั้ง',
              label: 'จำนวนการกำ-เหยียดสะสมในช่วงเวลา',
              subtitle: 'ระดับพัฒนาการโดยรวมมีความต่อเนื่องดีขึ้น',
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildModernMiniCard(Icons.track_changes_rounded, currentStats['accuracy'] ?? '0 %', 'ความแม่นยำเฉลี่ย', Colors.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernMiniCard(Icons.access_time_filled_rounded, currentStats['totalTime'] ?? '0 นาที', 'เวลาฝึกรวม', Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildWideStatCard(
              icon: Icons.refresh_rounded,
              value: currentStats['sessions'] ?? '0 ครั้ง',
              label: 'ความถี่ในการเปิดใช้งานเครื่องมือกลเพื่อสุขภาพ',
              subtitle: 'สถิติซิงค์ตรงกับฐานข้อมูลของแพทย์ประจำตัวแล้ว',
              iconColor: Colors.indigo,
            ),
            const SizedBox(height: 28),

            const Text('กราฟแนวโน้มพัฒนาการ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < weeklyScores.length; i++) ...[
                      Column(
                        children: [
                          Text(
                            weeklyScores[i] > 0 ? '${weeklyScores[i].toInt()}%' : '-', 
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)
                          ),
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 16, 
                            height: weeklyScores[i] > 0 ? weeklyScores[i] * 1.1 : 5.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.4),
                                  AppTheme.primaryColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(weeks[i], style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            const Text('บันทึกการฝึกซ้อม', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detailedHistory.length,
              itemBuilder: (context, index) {
                final item = detailedHistory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.backgroundColor,
                      child: const Icon(Icons.blur_on_rounded, color: AppTheme.primaryColor),
                    ),
                    title: Text('${item['date']} - ${item['time']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${item['mode']} | ${item['duration']}', style: const TextStyle(fontSize: 12)),
                    trailing: Text(item['score']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapsuleTab(int index, String label) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))] : [],
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textSecondary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildWideStatCard({required IconData icon, required String value, required String label, required String subtitle, required Color iconColor}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModernMiniCard(IconData icon, String value, String label, Color iconColor) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}