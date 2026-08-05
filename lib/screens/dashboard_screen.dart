import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../api/history_service.dart';
import '../api/device_service.dart';
import '../api/notification_service.dart';
import '../theme/app_theme.dart';
import '../pages/history_page.dart';
import '../pages/settings_page.dart';
import '../pages/training_page.dart';
import '../pages/quick_history_page.dart';
import '../pages/contact_doctor_page.dart';
import '../pages/device_setting_page.dart';
import '../pages/notification_page.dart';
import '../pages/history_detail_page.dart';
import '../api/api_config.dart';
import '../widgets/notification/notification_badge_icon.dart';

class BarButtonData {
  final IconData icon;
  final String label;
  const BarButtonData({required this.icon, required this.label});
}

class DashboardScreen extends StatefulWidget {
  final String? userToken;

  const DashboardScreen({super.key, this.userToken});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  bool _isLoading = true;
  int? _currentUserId;
  String _userName = 'ผู้ป่วย';
  String? _userImage;
  
  // ⚡ ตัวแปรเก็บข้อมูลอุปกรณ์จาก DB
  int? _deviceId;
  String? _deviceSerialNumber;
  String? _deviceName;
  int? _deviceStatus; // 0 = ปกติ, 1 = ถูกระงับ

  List<Map<String, dynamic>> _historyList = [];
  int _unreadNotiCount = 0;

  static const List<BarButtonData> _buttonItems = [
    BarButtonData(icon: Icons.home_rounded, label: 'หน้าหลัก'),
    BarButtonData(icon: Icons.bar_chart_rounded, label: 'ประวัติฝึก'),
    BarButtonData(icon: Icons.settings_rounded, label: 'ตั้งค่า'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    print('🔑 Current userToken in Dashboard: ${widget.userToken}');

    // 1. ดึงข้อมูล Profile ผู้ป่วย
    if (widget.userToken != null && widget.userToken!.isNotEmpty) {
      final userResult = await AuthService.getMe(widget.userToken!);
      
      print('📦 userResult from getMe: $userResult');

      if (userResult['success'] == true && userResult['user'] != null) {
        final userData = userResult['user'];
        
        // 🛡️ ดึง user_id แบบยืดหยุ่น (เผื่อเป็น int หรือ String หรือ num)
        final dynamic rawUserId = userData['user_id'] ?? userData['id'];
        final int? userId = rawUserId != null ? int.tryParse(rawUserId.toString()) : null;
        
        final String firstname = userData['firstname'] ?? userData['name'] ?? '';
        final String lastname = userData['lastname'] ?? '';
        final String? imageName = userData['image'];

        print('👤 Parsed User ID: $userId, Name: $firstname $lastname');

        if (mounted) {
          setState(() {
            _userName = firstname.isNotEmpty ? '$firstname $lastname'.trim() : 'ผู้ป่วย';
            _userImage = ApiConfig.getImageUrl(imageName);
            _currentUserId = userId;
          });
        }

        // 2. ⚡ ดึงข้อมูลอุปกรณ์และการแจ้งเตือน
        if (userId != null) {
          final deviceData = await DeviceService.getDeviceByUserId(userId);
          final notiList = await NotificationService.getNotifications(userId);
          
          int unread = notiList.where((item) => (item['is_unread'] ?? 0) == 1).length;
          
          if (mounted) {
            setState(() => _unreadNotiCount = unread);
          }

          if (deviceData != null && mounted) {
            setState(() {
              _deviceId = deviceData['device_id'];
              _deviceSerialNumber = deviceData['serial_number'];
              _deviceName = deviceData['device_name'];
              _deviceStatus = deviceData['device_status'];
            });
          }
        }
      } else {
        print('❌ Failed to fetch user profile: ${userResult['message']}');
      }
    } else {
      print('⚠️ Token is null or empty in DashboardScreen!');
    }

    // 3. ดึงประวัติฝึก
    final historyData = await HistoryService.getHistoryList();

    if (mounted) {
      historyData.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(1970);
        DateTime dateB = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      setState(() {
        _historyList = historyData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDeviceRegistered = _deviceSerialNumber != null && _deviceSerialNumber!.isNotEmpty;
    final bool isDeviceActive = isDeviceRegistered && _deviceStatus == 0;

    final List<Widget> pages = [
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟠 1. Header
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
                        children: [
                          const Text(
                            'สวัสดีครับ 👋',
                            style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLoading ? 'กำลังโหลด...' : 'คุณ$_userName',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ],
                      ),
                      
                      // 🔔 Notification Icon + Profile Image
                      Row(
                        children: [
                          NotificationBadgeIcon(
                            unreadCount: _unreadNotiCount,
                            onPressed: () {
                              if (_currentUserId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotificationPage(userId: _currentUserId!),
                                  ),
                                ).then((_) => _fetchDashboardData());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('กำลังโหลดข้อมูลผู้ป่วย กรุณาลองใหม่อีกครั้ง')),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: (_userImage != null && _userImage!.isNotEmpty)
                                ? NetworkImage(_userImage!)
                                : null,
                            child: (_userImage == null || _userImage!.isEmpty)
                                ? const Icon(Icons.person_rounded, color: Colors.white, size: 28)
                                : null,
                          ),
                        ],
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
                  // ⚡ 2. ส่วนแสดงสถานะอุปกรณ์
                  InkWell(
                    onTap: () {
                      if (isDeviceActive) {
                        _showDeviceBottomSheet(context, _deviceName, _deviceSerialNumber);
                      } else {
                        // 🛡️ เช็กว่ามี userId หรือยัง ถ้ายังไม่มาให้แจ้งเตือนและรีเฟรชข้อมูลก่อน
                        if (_currentUserId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('กำลังโหลดข้อมูลผู้ใช้ กรุณารอสักครู่แล้วลองใหม่อีกครั้ง'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          _fetchDashboardData(); // พยายามดึงข้อมูลใหม่อีกครั้ง
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeviceSettingPage(userId: _currentUserId), // 👈 ส่ง userId ที่ผ่านการเช็กแล้ว
                          ),
                        ).then((_) => _fetchDashboardData());
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: isDeviceActive 
                            ? const Color(0xFF2ECC71).withOpacity(0.06) 
                            : Colors.orange.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDeviceActive ? Colors.green.shade400 : Colors.orangeAccent.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDeviceActive ? Icons.bluetooth_connected_rounded : Icons.warning_amber_rounded, 
                            color: isDeviceActive ? Colors.green.shade700 : Colors.orangeAccent.shade700, 
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
                                  isDeviceActive 
                                      ? '⚡ เชื่อมต่อ ${_deviceName ?? "ถุงมืออัจฉริยะ"} แล้ว (คลิกดูข้อมูล)' 
                                      : isDeviceRegistered && _deviceStatus == 1
                                          ? '⛔ อุปกรณ์ถูกระงับการใช้งาน (ติดต่อเจ้าหน้าที่)'
                                          : '⚠️ ยังไม่ได้ลงทะเบียนถุงมือกล (คลิกเพื่อผูกอุปกรณ์)', 
                                  style: TextStyle(
                                    color: isDeviceActive ? Colors.green.shade800 : Colors.orange.shade900, 
                                    fontWeight: FontWeight.w600, 
                                    fontSize: 12
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDeviceActive ? Colors.green.withOpacity(0.5) : Colors.orangeAccent)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 🦾 3. ปุ่มเริ่มโหมดฝึกซ้อม
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
                      onTap: () {
                        if (_currentUserId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('กำลังโหลดข้อมูลผู้ป่วย กรุณาลองใหม่อีกครั้ง')),
                          );
                          return;
                        }

                        if (_deviceId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('กรุณาลงทะเบียนผูกอุปกรณ์ Smart Glove ก่อนเริ่มฝึกซ้อม')),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrainingPage(
                              userId: _currentUserId!,
                              deviceId: _deviceId!,
                            ),
                          ),
                        ).then((_) => _fetchDashboardData());
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('เริ่มโหมดฝึกซ้อม', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                SizedBox(height: 4),
                                Text('เปิดระบบคุมถุงมือและบันทึกผลสถิติ', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 48),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 📊 4. เมนูย่อย
                  GridView.count(
                    crossAxisCount: 2, 
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5, 
                    children: [
                      _buildModernMenuCard(
                        context, 
                        'ประวัติย้อนหลัง', 
                        Icons.insert_chart_rounded, 
                        Colors.blue.shade700, 
                        const QuickHistoryPage()
                      ),
                      _buildModernMenuCard(
                        context, 
                        'ติดต่อแพทย์', 
                        Icons.forum_rounded, 
                        Colors.teal.shade600, 
                        ContactDoctorPage(userToken: widget.userToken)
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // 🏆 5. รายการประวัติแบบใหม่ (แสดง 5 รายการล่าสุด)
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
                            'บันทึกการฝึกซ้อมล่าสุด',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_historyList.length}',
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
                        onPressed: _fetchDashboardData,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  _isLoading
                      ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                      : _historyList.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                              child: const Center(
                                child: Text('ยังไม่มีประวัติการฝึกซ้อมในระบบ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _historyList.length > 5 ? 5 : _historyList.length,
                              itemBuilder: (context, index) {
                                // 🟢 ดึงตามลำดับ Index (เพราะจัดเรียง DESC ใน _fetchDashboardData แล้ว)
                                final item = _historyList[index];
                                final int count = item['count'] ?? 0;
                                final int accuracy = (item['accuracy'] as num? ?? 0).round();
                                final int duration = item['duration'] ?? 0;
                                final String rawDate = item['created_at']?.toString() ?? '';

                                String formattedDate = 'ฝึกซ้อมกายภาพ';
                                if (rawDate.isNotEmpty) {
                                  try {
                                    DateTime dt = DateTime.parse(rawDate.replaceAll(' ', 'T')).toLocal();
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
                                                    value: (accuracy / 100).clamp(0.0, 1.0),
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
          ],
        ),
      ),
      const HistoryPage(),
      SettingsPage(userToken: widget.userToken),
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
        onTap: () {
          setState(() => _currentIndex = index);
          if (index == 0) {
            _fetchDashboardData();
          }
        },
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

  void _showDeviceBottomSheet(BuildContext context, String? name, String? serial) {
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
            Text('ชื่ออุปกรณ์: ${name ?? "ถุงมือกลอัจฉริยะ"}', style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text('Serial Number: ${serial ?? "ไม่มีข้อมูล"}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 10),
            const Text('สถานะการใช้งาน: พร้อมใช้งาน (0°)', style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}