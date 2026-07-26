import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/history_service.dart';
import '../theme/app_theme.dart';
import 'history_detail_page.dart'; // 👈 นำเข้า HistoryDetailPage

class QuickHistoryPage extends StatefulWidget {
  const QuickHistoryPage({super.key});

  @override
  State<QuickHistoryPage> createState() => _QuickHistoryPageState();
}

class _QuickHistoryPageState extends State<QuickHistoryPage> {
  bool _isLoading = true;
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

  // 📡 ฟังก์ชันดึงประวัติการฝึกจริงจาก Backend (ตาราง history)
  Future<void> _fetchHistoryData() async {
    setState(() => _isLoading = true);

    // ดึงข้อมูลผ่าน HistoryService ที่เราสร้างไว้
    final data = await HistoryService.getHistoryList();

    if (mounted) {
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
        title: const Text(
          'ประวัติย้อนหลัง',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchHistoryData,
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
                  onRefresh: _fetchHistoryData,
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    itemCount: _historyData.length,
                    itemBuilder: (context, index) {
                      final item = _historyData[index];

                      final count = '${item['count'] ?? 0} ครั้ง';
                      final duration = '${item['duration'] ?? 0} วินาที';
                      final accuracy = '${item['accuracy'] ?? 0}%';
                      final dateStr = _formatDate(item['created_at'] ?? item['train_date']);

                      final indicatorColor = _accentColors[index % _accentColors.length];

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
                                    // 🎨 1. แถบสีตกแต่งด้านซ้าย
                                    Container(
                                      width: 5,
                                      color: indicatorColor,
                                    ),
                                    const SizedBox(width: 16),

                                    // 📝 2. ส่วนเนื้อหาข้อมูลหลัก
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