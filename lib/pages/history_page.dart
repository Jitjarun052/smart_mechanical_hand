import 'package:flutter/material.dart';
import '../api/history_service.dart';
import '../theme/app_theme.dart';
import 'history_detail_page.dart'; // 👈 นำเข้า HistoryDetailPage

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedTab = 1; // 0 = รายวัน, 1 = รายสัปดาห์, 2 = รายเดือน

  String _selectedYear = 'ปี: 2569';
  String _selectedMonth = 'เดือน: ม.ค.';

  bool _isLoading = true;
  List<Map<String, dynamic>> _rawHistoryList = [];

  // Map ค่าชื่อเดือนเป็นหมายเลขเดือน (1-12)
  final Map<String, int> _monthMap = {
    'เดือน: ม.ค.': 1,
    'เดือน: ก.พ.': 2,
    'เดือน: มี.ค.': 3,
    'เดือน: เม.ย.': 4,
    'เดือน: พ.ค.': 5,
    'เดือน: มิ.ย.': 6,
    'เดือน: ก.ค.': 7,
    'เดือน: ส.ค.': 8,
    'เดือน: ก.ย.': 9,
    'เดือน: ต.ค.': 10,
    'เดือน: พ.ย.': 11,
    'เดือน: ธ.ค.': 12,
  };

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  // 📡 ดึงข้อมูลประวัติทั้งหมดจาก MySQL
  Future<void> _fetchHistoryData() async {
    setState(() => _isLoading = true);
    final data = await HistoryService.getHistoryList();
    if (mounted) {
      setState(() {
        _rawHistoryList = data;
        _isLoading = false;
      });
    }
  }

  // 🛠️ แปลง String จาก DB เป็น DateTime ไทย (+7)
  DateTime _parseToLocalDateTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return DateTime.now();
    try {
      String formattedRaw = rawDate.replaceAll(' ', 'T');
      if (!formattedRaw.endsWith('Z') && !formattedRaw.contains('+')) {
        formattedRaw += 'Z';
      }
      return DateTime.parse(formattedRaw).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  // 🧮 ฟังก์ชันคำนวณข้อมูลสถิติและกราฟตาม แท็บ, เดือน, และปี ที่เลือก
  Map<String, dynamic> _calculateStats() {
    final int targetYearBE = int.tryParse(_selectedYear.replaceAll('ปี: ', '')) ?? 2569;
    final int targetYearAD = targetYearBE - 543;
    final int targetMonth = _monthMap[_selectedMonth] ?? 1;

    final filteredByYear = _rawHistoryList.where((item) {
      if (item['created_at'] == null) return false;
      final DateTime dt = _parseToLocalDateTime(item['created_at'].toString());
      return dt.year == targetYearAD;
    }).toList();

    final filteredByMonth = filteredByYear.where((item) {
      final DateTime dt = _parseToLocalDateTime(item['created_at'].toString());
      return dt.month == targetMonth;
    }).toList();

    int totalCount = 0;
    int totalDurationSec = 0;
    double sumAccuracy = 0.0;
    int sessionCount = 0;

    List<double> chartScores = [];
    List<String> chartLabels = [];

    if (_selectedTab == 0) {
      // 🟢 แท็บรายวัน
      sessionCount = filteredByMonth.length;
      for (var item in filteredByMonth) {
        totalCount += (item['count'] as num? ?? 0).toInt();
        totalDurationSec += (item['duration'] as num? ?? 0).toInt();
        sumAccuracy += (item['accuracy'] as num? ?? 0).toDouble();
      }

      chartLabels = ['อา.', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.'];
      chartScores = List.filled(7, 0.0);
      List<int> dayCounts = List.filled(7, 0);

      for (var item in filteredByMonth) {
        final DateTime dt = _parseToLocalDateTime(item['created_at'].toString());
        int dayIdx = dt.weekday % 7;
        chartScores[dayIdx] += (item['accuracy'] as num? ?? 0).toDouble();
        dayCounts[dayIdx] += 1;
      }

      for (int i = 0; i < 7; i++) {
        if (dayCounts[i] > 0) {
          chartScores[i] = chartScores[i] / dayCounts[i];
        }
      }

    } else if (_selectedTab == 1) {
      // 🔵 แท็บรายสัปดาห์
      sessionCount = filteredByMonth.length;
      for (var item in filteredByMonth) {
        totalCount += (item['count'] as num? ?? 0).toInt();
        totalDurationSec += (item['duration'] as num? ?? 0).toInt();
        sumAccuracy += (item['accuracy'] as num? ?? 0).toDouble();
      }

      chartLabels = ['สัปดาห์ 1', 'สัปดาห์ 2', 'สัปดาห์ 3', 'สัปดาห์ 4', 'สัปดาห์ 5'];
      List<double> weekSums = List.filled(5, 0.0);
      List<int> weekCounts = List.filled(5, 0);

      for (var item in filteredByMonth) {
        final DateTime dt = _parseToLocalDateTime(item['created_at'].toString());
        int weekIdx = ((dt.day - 1) / 7).floor();
        if (weekIdx >= 5) weekIdx = 4;

        weekSums[weekIdx] += (item['accuracy'] as num? ?? 0).toDouble();
        weekCounts[weekIdx] += 1;
      }

      chartScores = List.generate(5, (i) => weekCounts[i] > 0 ? (weekSums[i] / weekCounts[i]) : 0.0);

    } else {
      // 🟠 แท็บรายเดือน
      sessionCount = filteredByYear.length;
      for (var item in filteredByYear) {
        totalCount += (item['count'] as num? ?? 0).toInt();
        totalDurationSec += (item['duration'] as num? ?? 0).toInt();
        sumAccuracy += (item['accuracy'] as num? ?? 0).toDouble();
      }

      chartLabels = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
      List<double> monthSums = List.filled(12, 0.0);
      List<int> monthCounts = List.filled(12, 0);

      for (var item in filteredByYear) {
        final DateTime dt = _parseToLocalDateTime(item['created_at'].toString());
        int mIdx = dt.month - 1;
        if (mIdx >= 0 && mIdx < 12) {
          monthSums[mIdx] += (item['accuracy'] as num? ?? 0).toDouble();
          monthCounts[mIdx] += 1;
        }
      }

      chartScores = List.generate(12, (i) => monthCounts[i] > 0 ? (monthSums[i] / monthCounts[i]) : 0.0);
    }

    final double avgAccuracy = sessionCount > 0 ? (sumAccuracy / sessionCount) : 0.0;
    final int totalMinutes = (totalDurationSec / 60).round();

    return {
      'totalCount': '$totalCount ครั้ง',
      'accuracy': '${avgAccuracy.toStringAsFixed(0)} %',
      'totalTime': '$totalMinutes นาที',
      'sessions': '$sessionCount ครั้ง',
      'chartScores': chartScores,
      'chartLabels': chartLabels,
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentStats = _calculateStats();
    final List<double> weeklyScores = List<double>.from(currentStats['chartScores']);
    final List<String> weeks = List<String>.from(currentStats['chartLabels']);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
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
                                items: _monthMap.keys.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedMonth = newValue;
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
                                items: <String>['ปี: 2569', 'ปี: 2568', 'ปี: 2567']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedYear = newValue;
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

                  // แท็บเม็ดยาเปลี่ยนช่วงเวลา
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

                  // 📊 กราฟแนวโน้มพัฒนาการ
                  const Text('กราฟแนวโน้มพัฒนาการ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (int i = 0; i < weeklyScores.length; i++) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      weeklyScores[i] > 0 ? '${weeklyScores[i].toInt()}%' : '-', 
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)
                                    ),
                                    const SizedBox(height: 8),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 16, 
                                      height: weeklyScores[i] > 0 ? (weeklyScores[i] * 1.1).clamp(5.0, 120.0) : 5.0,
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
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 📋 รายการบันทึกการฝึกซ้อมย้อนหลัง (ปรับสไตล์ Dashboard + กดข้ามไป HistoryDetailPage)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.history_toggle_off_rounded,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'บันทึกการฝึกซ้อม',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_rawHistoryList.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 20, color: AppTheme.primaryColor),
                        onPressed: _fetchHistoryData,
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  _rawHistoryList.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: const Center(
                            child: Text('ยังไม่มีบันทึกการฝึกซ้อมในระบบ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _rawHistoryList.length,
                          itemBuilder: (context, index) {
                            final item = _rawHistoryList[index];
                            final int count = item['count'] ?? 0;
                            final int accuracy = (item['accuracy'] as num? ?? 0).round();
                            final int duration = item['duration'] ?? 0;
                            final String rawDate = item['created_at']?.toString() ?? item['train_date']?.toString() ?? '';

                            String formattedDate = 'ฝึกซ้อมกายภาพ';
                            if (rawDate.isNotEmpty) {
                              try {
                                DateTime dt = _parseToLocalDateTime(rawDate);
                                const monthsTH = ['', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
                                formattedDate = 'รอบวันที่ ${dt.day} ${monthsTH[dt.month]}';
                              } catch (_) {}
                            }

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // ⚡ กดการ์ดประวัติย่อยแล้วเปิดข้ามไปหน้า HistoryDetailPage สดๆ
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HistoryDetailPage(historyData: item),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFFF9F43),
                                                      borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                                                    ),
                                                    child: Text(
                                                      '$count ครั้ง',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFFFB976),
                                                      borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                                                    ),
                                                    child: Text(
                                                      '$duration วินาที',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              width: 58,
                                              height: 58,
                                              child: CircularProgressIndicator(
                                                value: accuracy / 100,
                                                strokeWidth: 4.5,
                                                backgroundColor: Colors.grey.shade200,
                                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                              ),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '$accuracy%',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w900,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                ),
                                                const Text(
                                                  'แม่นยำ',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    color: AppTheme.textSecondary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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