import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // 📊 อย่าลืมตรวจสอบว่ารันคำสั่ง flutter pub add fl_chart แล้วนะครับ
import '../theme/app_theme.dart';

class PatientDetailPage extends StatefulWidget {
  final Map<String, dynamic> patientData;
  const PatientDetailPage({super.key, required this.patientData});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  int _selectedTab = 1; // Default: รายสัปดาห์
  
  // 🖐️ ตัวแปรสลับเลือกดูสถิติแยกตามนิ้วมือ (จากรูปต้นแบบที่คุณชอบ ✨)
  String _selectedFinger = 'นิ้วชี้';
  final List<String> _fingers = ['นิ้วโป้ง', 'นิ้วชี้', 'นิ้วกลาง', 'นิ้วนาง', 'นิ้วก้อย'];

  String _selectedYear = 'ปี: 2569';
  String _selectedMonth = 'เดือน: ม.ค.';

  // 📊 ก้อนข้อมูลสรุปสถิติตามช่วงเวลาที่คุณออกแบบไว้
  final Map<String, Map<int, Map<String, dynamic>>> _statsByYearAndTab = {
    'ปี: 2569': {
      0: {
        'totalCount': '55 ครั้ง', 'accuracy': '92 %', 'totalTime': '15 นาที', 'sessions': '1 ครั้ง',
      },
      1: { 
        'totalCount': '1,550 ครั้ง', 'accuracy': '95 %', 'totalTime': '145 นาที', 'sessions': '28 ครั้ง',
      },
      2: {
        'totalCount': '5,840 ครั้ง', 'accuracy': '89 %', 'totalTime': '620 นาที', 'sessions': '96 ครั้ง',
      },
    },
    'ปี: 2568': {
      0: {'totalCount': '40 ครั้ง', 'accuracy': '85 %', 'totalTime': '12 นาที', 'sessions': '1 ครั้ง'},
      1: {'totalCount': '980 ครั้ง', 'accuracy': '88 %', 'totalTime': '90 นาที', 'sessions': '15 ครั้ง'},
      2: {'totalCount': '3,400 ครั้ง', 'accuracy': '86 %', 'totalTime': '410 นาที', 'sessions': '50 ครั้ง'},
    },
  };

  @override
  Widget build(BuildContext context) {
    final Map<int, Map<String, dynamic>> statsOfSelectedYear = 
        _statsByYearAndTab[_selectedYear] ?? _statsByYearAndTab['ปี: 2569']!;

    Map<String, dynamic> currentStats = statsOfSelectedYear[_selectedTab] ?? statsOfSelectedYear[1]!;

    final List<Map<String, String>> detailedHistory = [
      {'date': '17 มิ.ย. 2569', 'time': '15:30 น.', 'duration': '15 นาที', 'score': '145°', 'mode': 'โหมดอัตโนมัติ'},
      {'date': '16 มิ.ย. 2569', 'time': '10:15 น.', 'duration': '20 นาที', 'score': '110°', 'mode': 'โหมดฝึกงอ-เหยียด'},
      {'date': '15 มิ.ย. 2569', 'time': '18:45 น.', 'duration': '12 นาที', 'score': '85%', 'mode': 'โหมดอัตโนมัติ'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ข้อมูลคนไข้: ${widget.patientData['name']}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🩺 1. ส่วนการ์ดโปรไฟล์คนไข้ด้านบน (ตามรูปที่คุณชอบ อันที่ 1)
            _buildPatientHeaderProfile(),
            const SizedBox(height: 24),

            // 📈 2. ส่วนหัวกราฟพัฒนาการองศาขยับนิ้วมือ + Dropdown เลือกนิ้ว (ตามรูปอันที่ 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'กราฟพัฒนาการองศาขยับนิ้วมือ 📈',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'เปรียบเทียบผลการเหยียดในแต่ละเซสชัน',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                
                // กล่อง Dropdown เลือกนิ้วมือขอบมน
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFinger,
                      items: _fingers.map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)));
                      }).toList(),
                      onChanged: (newValue) => setState(() => _selectedFinger = newValue!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 📊 3. ตัวกล่องกราฟเส้น Line Chart (จัดสเกลเส้นหนา-บางตามภาพเป๊ะๆ)
            Container(
              height: 250,
              padding: const EdgeInsets.only(right: 20, top: 16, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
              ),
              child: _buildLineChartGraphic(),
            ),
            const SizedBox(height: 28),

            // 💊 4. บล็อกฟิลเตอร์สลับเวลาและสรุปตัวเลขที่คุณทำไว้ก่อนหน้านี้
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('รายงานผลรวมแบ่งตามช่วงเวลา', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Row(
                  children: [
                    _buildDropdownFilter(_selectedMonth, <String>['เดือน: ม.ค.', 'เดือน: ก.พ.', 'เดือน: มี.ค.'], (val) => setState(() => _selectedMonth = val!)),
                    const SizedBox(width: 6),
                    _buildDropdownFilter(_selectedYear, <String>['ปี: 2569', 'ปี: 2568'], (val) => setState(() => _selectedYear = val!)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCapsuleTab(0, 'รายวัน'),
                _buildCapsuleTab(1, 'รายสัปดาห์'),
                _buildCapsuleTab(2, 'รายเดือน'),
              ],
            ),
            const SizedBox(height: 16),

            _buildWideStatCard(icon: Icons.back_hand_rounded, value: currentStats['totalCount'] ?? '0 ครั้ง', label: 'จำนวนการกำ-เหยียดสะสมในช่วงเวลา', subtitle: 'ระดับพัฒนาการโดยรวมมีความต่อเนื่องดีขึ้น', iconColor: Colors.blue),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildModernMiniCard(Icons.track_changes_rounded, currentStats['accuracy'] ?? '0 %', 'ความแม่นยำเฉลี่ย', Colors.teal)),
                const SizedBox(width: 12),
                Expanded(child: _buildModernMiniCard(Icons.access_time_filled_rounded, currentStats['totalTime'] ?? '0 นาที', 'เวลาฝึกรวม', Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),

            const Text('บันทึกการฝึกซ้อมรายเซสชัน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
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
                    leading: CircleAvatar(backgroundColor: AppTheme.backgroundColor, child: const Icon(Icons.blur_on_rounded, color: AppTheme.primaryColor)),
                    title: Text('${item['date']} - ${item['time']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${item['mode']} | ${item['duration']}', style: const TextStyle(fontSize: 12)),
                    trailing: Text(item['score']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryColor)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🏥 Widget การ์ดโปรไฟล์ส่วนบนตามรูปถ่ายของคุณ
  Widget _buildPatientHeaderProfile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.orange.shade50,
                child: Icon(Icons.assignment_ind_rounded, color: Colors.orange.shade800),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.patientData['name']} (อายุ ${widget.patientData['age']} ปี)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'รหัสผู้ป่วย: ${widget.patientData['id']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontFamily: 'mono'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28, thickness: 1),
          const Text('วินิจฉัย/อาการคนไข้:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          Text(
            '${widget.patientData['symptom']}',
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }

  // 📊 ตัวสร้างกราฟเส้น FL Chart ลอกมิติแกน X/Y มาจากรูปภาพ
  Widget _buildLineChartGraphic() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 30,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1, dashArray: [5, 5]),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 30,
              reservedSize: 35,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value == 1) return const Text('ครั้งที่ 1', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold));
                if (value == 2) return const Text('ครั้งที่ 2', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold));
                if (value == 3) return const Text('ครั้งที่ 3', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold));
                if (value == 4) return const Text('ครั้งที่ 4', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold));
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 1, maxX: 4,
        minY: 0, maxY: 180,
        lineBarsData: [
          LineChartBarData(
            spots: _selectedFinger == 'นิ้วชี้' 
                ? [const FlSpot(1, 45), const FlSpot(2, 85), const FlSpot(3, 110), const FlSpot(4, 145)] // คาบองศาตรงตามรูปเป๊ะๆ ครับ ✨
                : [const FlSpot(1, 30), const FlSpot(2, 60), const FlSpot(3, 95), const FlSpot(4, 120)],
            isCurved: false, // ทำเป็นเส้นตรงหักมุมคมๆ ตามกราฟต้นแบบที่คุณส่งมาครับ
            color: AppTheme.primaryColor,
            barWidth: 4, // เพิ่มความหนาของเส้นส้มอิฐ
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              // getDotNavigator: (p0, p1, p2, p3) => FlDotNavigator(),
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 5, color: AppTheme.primaryColor, strokeWidth: 1, strokeColor: Colors.white),
            ),
            belowBarData: BarAreaData(show: true, color: AppTheme.primaryColor.withOpacity(0.05)),
          ),
        ],
      ),
    );
  }

  // สไตล์ Dropdown คัดกรองช่วงเวลารอง
  Widget _buildDropdownFilter(String currentVal, List<String> listItems, Function(String?) eventChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withOpacity(0.15))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(value: currentVal, icon: const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.primaryColor), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), items: listItems.map((String val) => DropdownMenuItem<String>(value: val, child: Text(val))).toList(), onChanged: eventChange),
      ),
    );
  }

  Widget _buildCapsuleTab(int index, String label) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? AppTheme.primaryColor : Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))] : []),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textSecondary, fontSize: 13)),
      ),
    );
  }

  Widget _buildWideStatCard({required IconData icon, required String value, required String label, required String subtitle, required Color iconColor}) {
    return Card(
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 26)),
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
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), color: Colors.white,
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