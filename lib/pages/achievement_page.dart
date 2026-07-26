import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../api/history_service.dart';

class AchievementPage extends StatefulWidget {
  final int? userId;

  const AchievementPage({super.key, this.userId});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  bool _isLoading = true;
  int _totalDays = 0;
  int _totalSessions = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchAchievementStats();
  }

  // 📡 ดึงประวัติฝึกเพื่อคำนวณการปลดล็อกตราความสำเร็จจริง
 // 📡 ดึงประวัติฝึกเพื่อคำนวณการปลดล็อกตราความสำเร็จจริง
  Future<void> _fetchAchievementStats() async {
    setState(() => _isLoading = true);
    if (widget.userId != null) {
      // 🟢 1. เปลี่ยนชนิดตัวแปรฝั่งรับเป็น List<dynamic> ให้ตรงกับ HistoryService
      final List<dynamic> historyList = await HistoryService.getHistoryByUserId(widget.userId.toString());
      
      if (mounted && historyList.isNotEmpty) {
        Set<String> uniqueDays = {};
        int sumCount = 0;

        for (var item in historyList) {
          if (item is Map<String, dynamic>) {
            final String rawDate = item['created_at']?.toString() ?? item['train_date']?.toString() ?? '';
            if (rawDate.isNotEmpty) {
              String dateOnly = rawDate.replaceAll(' ', 'T').split('T')[0];
              uniqueDays.add(dateOnly);
            }
            sumCount += (item['count'] as num? ?? 0).toInt();
          }
        }

        setState(() {
          _totalDays = uniqueDays.length;
          _totalSessions = historyList.length;
          _totalCount = sumCount;
          _isLoading = false;
        });
        return;
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🏆 รายการ Badge ถ้วยรางวัล พร้อมเงื่อนไขการปลดล็อกสดๆ
    final List<Map<String, dynamic>> badges = [
      {
        'title': 'ก้าวแรกของการฟื้นฟู',
        'subtitle': 'เข้าใช้งานและเริ่มฝึกซ้อมครั้งแรก',
        'icon': Icons.directions_walk_rounded,
        'color': Colors.blue,
        'isUnlocked': _totalSessions >= 1,
        'progress': '${_totalSessions > 0 ? 1 : 0}/1',
      },
      {
        'title': 'ความพยายาม 3 วัน',
        'subtitle': 'ฝึกซ้อมกายภาพสะสมครบ 3 วัน',
        'icon': Icons.local_fire_department_rounded,
        'color': Colors.orange,
        'isUnlocked': _totalDays >= 3,
        'progress': '$_totalDays/3 วัน',
      },
      {
        'title': 'วินัยเหล็ก 5 วัน',
        'subtitle': 'ฝึกซ้อมกายภาพสะสมครบ 5 วัน',
        'icon': Icons.emoji_events_rounded,
        'color': Colors.amber,
        'isUnlocked': _totalDays >= 5,
        'progress': '$_totalDays/5 วัน',
      },
      {
        'title': 'นักสู้ 10 วัน',
        'subtitle': 'ฝึกซ้อมกายภาพสะสมครบ 10 วัน',
        'icon': Icons.military_tech_rounded,
        'color': Colors.purple,
        'isUnlocked': _totalDays >= 10,
        'progress': '$_totalDays/10 วัน',
      },
      {
        'title': 'จอมขยัน 100 รอบ',
        'subtitle': 'ทำจำนวนครั้งกำ-เหยียดสะสมครบ 100 ครั้ง',
        'icon': Icons.back_hand_rounded,
        'color': Colors.teal,
        'isUnlocked': _totalCount >= 100,
        'progress': '$_totalCount/100 ครั้ง',
      },
      {
        'title': 'พิชิต 1 เดือน',
        'subtitle': 'ฝึกซ้อมกายภาพสะสมครบ 30 วัน',
        'icon': Icons.workspace_premium_rounded,
        'color': Colors.redAccent,
        'isUnlocked': _totalDays >= 30,
        'progress': '$_totalDays/30 วัน',
      },
    ];

    int unlockedCount = badges.where((b) => b['isUnlocked'] == true).length;

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
          'ตราความสำเร็จ',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🟠 1. การ์ดสรุปจำนวนถ้วยรางวัลที่ปลดล็อก
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, Color(0xFFE67E22)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.stars_rounded, color: Colors.white, size: 40),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ปลดล็อกความสำเร็จแล้ว', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              '$unlockedCount / ${badges.length} ตรา',
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('เข็มตราความสำเร็จทั้งหมด', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),

                  // 🏆 2. รายการการ์ด Badge ทั้งหมด
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final item = badges[index];
                      final bool isUnlocked = item['isUnlocked'];
                      final Color iconColor = item['color'];

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isUnlocked ? Colors.white : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isUnlocked ? iconColor.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                            width: isUnlocked ? 1.5 : 1,
                          ),
                          boxShadow: isUnlocked
                              ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: isUnlocked ? iconColor.withOpacity(0.15) : Colors.grey.shade300,
                                  child: Icon(
                                    item['icon'],
                                    color: isUnlocked ? iconColor : Colors.grey.shade500,
                                    size: 32,
                                  ),
                                ),
                                if (!isUnlocked)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.grey.shade600,
                                      child: const Icon(Icons.lock_rounded, size: 12, color: Colors.white),
                                    ),
                                  )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isUnlocked ? AppTheme.textPrimary : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['subtitle'],
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isUnlocked ? iconColor.withOpacity(0.1) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item['progress'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? iconColor : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}