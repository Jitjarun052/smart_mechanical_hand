import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 💡 อย่าลืม pub add intl ไว้ฟอร์แมตวันที่ (ถ้าไม่มีสามารถแปลง String ธรรมดาได้)
import '../api/history_service.dart';
import '../theme/app_theme.dart';

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

  // 📡 ฟังก์ชันดึงประวัติการฝึกจริงจาก Backend (ตาราง history)[cite: 5]
  Future<void> _fetchHistoryData() async {
    setState(() => _isLoading = true);

    // ดึงข้อมูลผ่าน HistoryService ที่เราสร้างไว้[cite: 5]
    final data = await HistoryService.getHistoryList();

    if (mounted) {
      setState(() {
        _historyData = data;
        _isLoading = false;
      });
    }
  }

  // 🗓️ ฟังก์ชันช่วยแปลงวันที่จาก Database เป็นฟอร์แมตอ่านง่าย
  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'ไม่ระบุวันที่';
    try {
      final dateTime = DateTime.parse(rawDate).toLocal();
      // ตัวอย่างผลลัพธ์: 18 ก.ค. 2569 เวลา 14:30 น.
      return DateFormat('d MMM yyyy • HH:mm', 'th_TH').format(dateTime);
    } catch (e) {
      // กรณี Parse วันที่ไม่ผ่าน ให้ส่งข้อความเดิมกลับไป
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
            onPressed: _fetchHistoryData, // กดปุ่มมุมขวาเพื่อโหลดข้อมูลใหม่
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

                      // 🛠️ ดึงค่าพารามิเตอร์จากคอลัมน์ในตาราง history จริง[cite: 5]
                      final count = '${item['count'] ?? 0} ครั้ง';
                      final duration = '${item['duration'] ?? 0} วินาที';
                      final accuracy = '${item['accuracy'] ?? 0}%';
                      final dateStr = _formatDate(item['created_at'] ?? item['train_date']);

                      // 🎨 วนแถบสีตกแต่งตาม Index
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                // 🎨 1. แถบสีตกแต่งด้านซ้าย (Color Indicator)
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
                                        // แถววันที่ + ไอคอนลูกศรขวา[cite: 11]
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

                                        // แถวแสดงพารามิเตอร์ 3 ค่า (จำนวนครั้ง, เวลา, ความแม่นยำ)[cite: 11]
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
                      );
                    },
                  ),
                ),
    );
  }

  // 📭 หน้าตาแสดงผลเมื่อยังไม่มีประวัติในฐานข้อมูล
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

  // Widget ย่อยสำหรับสร้างชุดไอคอน + ข้อความ (ตัวพารามิเตอร์)[cite: 11]
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