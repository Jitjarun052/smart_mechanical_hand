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
  bool _isDeviceOnline = false; // 🟢 ตัวแปรสถานะ Online/Offline จริงจาก Backend

  String _selectedFilter = 'all';
  int _displayLimit = 5; // 🟢 จำนวนรายการแสดงผลเริ่มต้น 5 รายการ

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

  // 🟢 ฟังก์ชันกรองข้อมูลตาม Filter Chip ที่เลือก
  List<Map<String, dynamic>> get _filteredHistoryList {
    if (_selectedFilter == 'today') {
      DateTime now = DateTime.now();
      return _historyList.where((item) {
        String rawDate = item['created_at']?.toString() ?? '';
        if (rawDate.isEmpty) return false;
        try {
          DateTime dt = DateTime.parse(rawDate.replaceAll(' ', 'T')).toLocal();
          return dt.year == now.year && dt.month == now.month && dt.day == now.day;
        } catch (_) {
          return false;
        }
      }).toList();
    } else if (_selectedFilter == '7days') {
      DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      return _historyList.where((item) {
        String rawDate = item['created_at']?.toString() ?? '';
        if (rawDate.isEmpty) return false;
        try {
          DateTime dt = DateTime.parse(rawDate.replaceAll(' ', 'T')).toLocal();
          return dt.isAfter(sevenDaysAgo);
        } catch (_) {
          return false;
        }
      }).toList();
    } else if (_selectedFilter == 'high_acc') {
      return _historyList.where((item) {
        num accuracy = item['accuracy'] as num? ?? 0;
        return accuracy >= 80;
      }).toList();
    }
    
    return _historyList; // 'all'
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
              // 🟢 ดึงสถานะ online จาก backend
              _isDeviceOnline = (deviceData['is_online'] == 1 || deviceData['is_online'] == true);
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
                  // ⚡ 2. ส่วนแสดงสถานะอุปกรณ์ (ปรับสีและข้อความตาม Online/Offline จริง)
                  InkWell(
                    onTap: () {
                      if (isDeviceActive) {
                        _showDeviceBottomSheet(context, _deviceName, _deviceSerialNumber);
                      } else {
                        if (_currentUserId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('กำลังโหลดข้อมูลผู้ใช้ กรุณารอสักครู่แล้วลองใหม่อีกครั้ง'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          _fetchDashboardData();
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeviceSettingPage(userId: _currentUserId),
                          ),
                        ).then((_) => _fetchDashboardData());
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: (isDeviceActive && _isDeviceOnline) 
                            ? const Color(0xFF2ECC71).withOpacity(0.06) 
                            : Colors.orange.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (isDeviceActive && _isDeviceOnline) ? Colors.green.shade400 : Colors.orangeAccent.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (isDeviceActive && _isDeviceOnline) 
                                ? Icons.bluetooth_connected_rounded 
                                : Icons.sensors_off_rounded, 
                            color: (isDeviceActive && _isDeviceOnline) ? Colors.green.shade700 : Colors.orangeAccent.shade700, 
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
                                  !isDeviceRegistered
                                      ? '⚠️ ยังไม่ได้ลงทะเบียนถุงมือกล (คลิกเพื่อผูกอุปกรณ์)'
                                      : _deviceStatus == 1
                                          ? '⛔ อุปกรณ์ถูกระงับการใช้งาน (ติดต่อเจ้าหน้าที่)'
                                          : _isDeviceOnline
                                              ? '⚡ เชื่อมต่อ ${_deviceName ?? "ถุงมืออัจฉริยะ"} แล้ว (ออนไลน์)'
                                              : '⚪ ${_deviceName ?? "ถุงมืออัจฉริยะ"} ปิดเครื่องอยู่ (ออฟไลน์)', 
                                  style: TextStyle(
                                    color: (isDeviceActive && _isDeviceOnline) ? Colors.green.shade800 : Colors.orange.shade900, 
                                    fontWeight: FontWeight.w600, 
                                    fontSize: 12
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded, 
                            size: 14, 
                            color: (isDeviceActive && _isDeviceOnline) ? Colors.green.withOpacity(0.5) : Colors.orangeAccent
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 🦾 3. ปุ่มเริ่มโหมดฝึก
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
                            const SnackBar(content: Text('กรุณาลงทะเบียนผูกอุปกรณ์ Smart Glove ก่อนเริ่มฝึก')),
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
                                Text('เริ่มโหมดฝึก', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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
                    childAspectRatio: 1.1,
                    children: [
                      _buildMorpromMenuCard(
                        context: context,
                        title: 'ประวัติย้อนหลัง',
                        imagePath: 'assets/icons/history.png',
                        circleBgColor: const Color(0xFFEBF5FB),
                        targetPage: const QuickHistoryPage(),
                      ),
                      _buildMorpromMenuCard(
                        context: context,
                        title: 'ติดต่อแพทย์',
                        imagePath: 'assets/icons/doctor.png',
                        circleBgColor: const Color(0xFFE8F8F5),
                        targetPage: ContactDoctorPage(userToken: widget.userToken),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // 🏆 5. รายการประวัติ (พร้อม Filter Chips)
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
                          Text(
                            'บันทึกการฝึก (${_filteredHistoryList.length < _displayLimit ? _filteredHistoryList.length : _displayLimit}/${_filteredHistoryList.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 20, color: AppTheme.primaryColor),
                        onPressed: () {
                          setState(() => _displayLimit = 5);
                          _fetchDashboardData();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 🏷️ 5.1 แถบตัวกรอง Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ทั้งหมด', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('วันนี้', 'today'),
                        const SizedBox(width: 8),
                        _buildFilterChip('7 วันล่าสุด', '7days'),
                        const SizedBox(width: 8),
                        _buildFilterChip('แม่นยำสูง (≥80%)', 'high_acc'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 📜 5.2 แสดงรายการประวัติที่ผ่านการกรองแล้ว
                  _isLoading
                      ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                      : _filteredHistoryList.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white, 
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Center(
                                child: Text('ไม่พบประวัติการฝึกตามเงื่อนไขที่เลือก', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredHistoryList.length < _displayLimit ? _filteredHistoryList.length : _displayLimit,
                              itemBuilder: (context, index) {
                                final item = _filteredHistoryList[index];
                                final int count = item['count'] ?? 0;
                                final int accuracy = (item['accuracy'] as num? ?? 0).round();
                                final int duration = item['duration'] ?? 0;
                                final String rawDate = item['created_at']?.toString() ?? '';

                                String formattedDate = 'ฝึกกายภาพ';
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

                  if (!_isLoading && _filteredHistoryList.length > _displayLimit)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                          ),
                          onPressed: () {
                            setState(() {
                              _displayLimit += 5;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                          label: Text(
                            'แสดงประวัติเพิ่มเติม (เหลืออีก ${_filteredHistoryList.length - _displayLimit} รายการ)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
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

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
        ),
      ),
      showCheckmark: false,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
            _displayLimit = 5;
          });
        }
      },
    );
  }

  Widget _buildMorpromMenuCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    required Color circleBgColor,
    required Widget targetPage,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage)),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: circleBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
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
            Text(
              _isDeviceOnline ? 'สถานะ: ออนไลน์ (พร้อมใช้งาน)' : 'สถานะ: ออฟไลน์ (ปิดเครื่องอยู่)',
              style: TextStyle(
                fontSize: 13, 
                color: _isDeviceOnline ? Colors.green : Colors.grey, 
                fontWeight: FontWeight.w700
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}