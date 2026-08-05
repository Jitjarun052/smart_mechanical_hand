import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/history_service.dart';
import '../theme/app_theme.dart';
import 'history_detail_page.dart';

class QuickHistoryPage extends StatefulWidget {
  const QuickHistoryPage({super.key});

  @override
  State<QuickHistoryPage> createState() => _QuickHistoryPageState();
}

class _QuickHistoryPageState extends State<QuickHistoryPage> {
  bool _isLoading = true;
  int _displayLimit = 10; // 🟢 จำนวนการแสดงผลรายการย้อนหลังเริ่มต้น 10 รายการ
  List<Map<String, dynamic>> _historyData = [];

  // 🎨 รายการแถบสีสำหรับสุ่ม/วนใช้ตกแต่งด้านซ้ายของแต่ละ Card
  final List<Color> _accentColors = [
    const Color(0xFF38B6FF), // ฟ้า
    const Color(0xFFFFD166), // เหลือง
    const Color(0xFF06D6A0), // เขียวมิ้นต์
    AppTheme.primaryColor,   // ส้มหลัก
    Colors.purpleAccent,     // ม่วง
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }


  // 📡 ฟังก์ชันดึงประวัติการฝึกจริงจาก Backend
  Future<void> _fetchHistoryData() async {
    setState(() => _isLoading = true);

    final data = await HistoryService.getHistoryList();

    if (mounted) {
      // 🟢 Sort ข้อมูลด้วย created_at หรือ history_id ให้ล่าสุดขึ้นก่อนเสมอ!
      data.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(1970);
        DateTime dateB = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA); // เรียงจาก มาก -> น้อย (ล่าสุด -> เก่าสุด)
      });

      setState(() {
        _historyData = data;
        _isLoading = false;
      });
    }
  }

  // 🗓️ ฟังก์ชันแปลงวันที่และเวลาไทย
  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'ไม่ระบุวันที่';
    try {
      String formattedRaw = rawDate.replaceAll(' ', 'T');
      if (!formattedRaw.endsWith('Z') && !formattedRaw.contains('+')) {
        formattedRaw += 'Z';
      }

      DateTime dt = DateTime.parse(formattedRaw).toLocal();
      int yearBE = dt.year + 543;

      const monthsTH = [
        '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
        'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
      ];
      String monthStr = monthsTH[dt.month];

      String hour = dt.hour.toString().padLeft(2, '0');
      String minute = dt.minute.toString().padLeft(2, '0');

      return '${dt.day} $monthStr $yearBE • $hour:$minute น.';
    } catch (e) {
      debugPrint('Format Date Error: $e');
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          _historyData.isEmpty 
              ? 'ประวัติย้อนหลัง' 
              : 'ประวัติย้อนหลัง (${_historyData.length < _displayLimit ? _historyData.length : _displayLimit}/${_historyData.length})',
          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _displayLimit = 10); // 🟢 รีเซ็ตกลับเป็น 10 รายการแรกเมื่อกด Refresh
              _fetchHistoryData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : _historyData.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _displayLimit = 10);
                    await _fetchHistoryData();
                  },
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    // 🟢 คำนวณจำนวนไอเทม: +1 สำหรับการ์ดการฝึกล่าสุดบนสุด +1 สำหรับปุ่มดูเพิ่มเติมด้านล่างสุด
                    itemCount: 1 + 
                               (_historyData.length < _displayLimit ? _historyData.length : _displayLimit) + 
                               (_historyData.length > _displayLimit ? 1 : 0),
                    itemBuilder: (context, index) {
                      // 🟢 1. แสดงการ์ดไฮไลต์ "การฝึกล่าสุด (Index 0)" ไว้ที่ส่วนหัวสุด
                      if (index == 0) {
                        return _buildLatestSessionCard(_historyData[0]);
                      }

                      // คำนวณ index จริงใน List ข้อมูล (หักออก 1 เพราะตำแหน่ง 0 ถูกใช้โดยการ์ดล่าสุด)
                      final listIndex = index - 1;

                      // 🟢 2. แสดงปุ่ม "แสดงประวัติเพิ่มเติม (+10)" ที่ท้ายสุด
                      if (listIndex == (_historyData.length < _displayLimit ? _historyData.length : _displayLimit)) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                              ),
                              onPressed: () {
                                setState(() {
                                  _displayLimit += 10; // 🟢 เพิ่มการแสดงผลทีละ 10 รายการ
                                });
                              },
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              label: Text(
                                'แสดงประวัติเพิ่มเติม (เหลืออีก ${_historyData.length - _displayLimit} รายการ)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        );
                      }

                      // 🟢 3. รายการประวัติย้อนหลังแต่ละเซสชัน
                      final item = _historyData[listIndex];

                      final count = '${item['count'] ?? 0} ครั้ง';
                      final duration = '${item['duration'] ?? 0} วินาที';
                      final accuracy = '${item['accuracy'] ?? 0}%';
                      final dateStr = _formatDate(item['created_at'] ?? item['train_date']);

                      final indicatorColor = _accentColors[listIndex % _accentColors.length];

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
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // ⚡ กดการ์ดแล้วเปิดข้ามไปหน้า HistoryDetailPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryDetailPage(historyData: item),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    // 🎨 แถบสีตกแต่งด้านซ้าย
                                    Container(
                                      width: 5,
                                      color: indicatorColor,
                                    ),
                                    const SizedBox(width: 16),

                                    // 📝 ส่วนเนื้อหาข้อมูลหลัก
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  dateStr,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                ),
                                                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                                              ],
                                            ),
                                            const SizedBox(height: 16),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                _buildStatusItem(Icons.back_hand_rounded, 'จำนวนครั้ง', count),
                                                _buildStatusItem(Icons.access_time_filled_rounded, 'เวลา', duration),
                                                _buildStatusItem(Icons.track_changes_rounded, 'ความแม่นยำ', accuracy),
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
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // 💥 Widget การ์ดแสดงผลการฝึกล่าสุด ( Latest Training Session Card )
  Widget _buildLatestSessionCard(Map<String, dynamic> latestItem) {
    final count = latestItem['count'] ?? 0;
    final duration = latestItem['duration'] ?? 0;
    final accuracy = (latestItem['accuracy'] as num? ?? 0).round();
    final dateStr = _formatDate(latestItem['created_at'] ?? latestItem['train_date']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0, top: 4.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10AC84), Color(0xFF1DD1A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10AC84).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryDetailPage(historyData: latestItem),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'การฝึกล่าสุดของคุณ',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('$count', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        const Text('ครั้ง (รอบ)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                    Container(width: 1, height: 30, color: Colors.white24),
                    Column(
                      children: [
                        Text('$duration', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        const Text('วินาที', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                    Container(width: 1, height: 30, color: Colors.white24),
                    Column(
                      children: [
                        Text('$accuracy%', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        const Text('ความแม่นยำ', style: TextStyle(color: Colors.white70, fontSize: 11)),
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มีประวัติการฝึกซ้อม',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'เมื่อคุณเริ่มโหมดฝึกซ้อม ข้อมูลจะถูกบันทึกมาแสดงที่นี่',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}