import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../api/device_service.dart';
import '../api/history_service.dart';
import '../api/api_config.dart';
import '../theme/app_theme.dart';
import 'patient_info_page.dart';
import 'doctor_info_page.dart';
import 'device_setting_page.dart';
import 'achievement_page.dart';
import '../screens/sign_in_screen.dart';

class SettingsPage extends StatefulWidget {
  final String? userToken;

  const SettingsPage({super.key, this.userToken});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isBluetoothConnected = false;
  bool _autoSyncData = true;
  bool _enableReminder = true;
  bool _isLoading = true;

  int? _userId;
  String _userName = 'ผู้ป่วย';
  String _userEmail = 'patient@health.com';
  String? _userImage;

  int? _deviceId;
  String? _deviceName;
  String? _serialNumber;
  int? _deviceStatus;
  bool _isDeviceOnline = false; // 🟢 สถานะ Online/Offline จริงจาก Backend

  int _totalSessions = 0;
  int _totalMinutes = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchSettingsData();
  }

  Future<void> _fetchSettingsData() async {
    setState(() => _isLoading = true);

    if (widget.userToken != null && widget.userToken!.isNotEmpty) {
      final userResult = await AuthService.getMe(widget.userToken!);
      if (userResult['success'] == true) {
        final userData = userResult['user'];
        final int? userId = userData['user_id'] ?? userData['id'];
        final String? imageName = userData['image'];

        if (mounted) {
          setState(() {
            _userName = '${userData['firstname'] ?? ''} ${userData['lastname'] ?? ''}'.trim();
            if (_userName.isEmpty) _userName = 'ผู้ป่วย';
            _userEmail = userData['email'] ?? 'patient@health.com';
            _userImage = ApiConfig.getImageUrl(imageName);
            _userId = userId;
          });
        }

        if (userId != null) {
          final deviceData = await DeviceService.getDeviceByUserId(userId);
          if (deviceData != null && mounted) {
            setState(() {
              _deviceId = deviceData['device_id'];
              _deviceName = deviceData['device_name'];
              _serialNumber = deviceData['serial_number'];
              _deviceStatus = deviceData['device_status'];
              // 🟢 เช็กสถานะออนไลน์จริงจาก Backend
              _isDeviceOnline = (deviceData['is_online'] == 1 || deviceData['is_online'] == true);
              _isBluetoothConnected = _isDeviceOnline;
            });
          }
        }
      }
    }

    final historyData = await HistoryService.getHistoryList();
    if (mounted) {
      int sumCount = 0;
      int sumDurationSeconds = 0;

      for (var item in historyData) {
        sumCount += (item['count'] as num? ?? 0).toInt();
        sumDurationSeconds += (item['duration'] as num? ?? 0).toInt();
      }

      setState(() {
        _totalSessions = historyData.length;
        _totalMinutes = (sumDurationSeconds / 60).round();
        _totalCount = sumCount;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDeviceBound = _serialNumber != null && _serialNumber!.isNotEmpty;

    return _isLoading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(50.0),
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🟠 Profile Header
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.only(top: 16.0, bottom: 28.0),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.white,
                            backgroundImage: (_userImage != null && _userImage!.isNotEmpty)
                                ? NetworkImage(_userImage!)
                                : null,
                            child: (_userImage == null || _userImage!.isEmpty)
                                ? const Icon(Icons.person, size: 65, color: Colors.grey)
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF38B6FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'คุณ$_userName',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                // 📊 Profile Stat Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStatItem('$_totalSessions', 'เซสชัน'),
                      _buildVerticalDivider(),
                      _buildProfileStatItem('$_totalMinutes', 'นาที'),
                      _buildVerticalDivider(),
                      _buildProfileStatItem('$_totalCount', 'ครั้งรวม'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🦾 อุปกรณ์ของฉัน
                      _buildSectionTitle('อุปกรณ์ของฉัน'),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          if (isDeviceBound) {
                            _showUnbindBottomSheet(context);
                          } else {
                            if (_userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('กำลังโหลดข้อมูลผู้ใช้ กรุณารอสักครู่แล้วลองใหม่อีกครั้ง'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              _fetchSettingsData();
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeviceSettingPage(userId: _userId),
                              ),
                            ).then((_) => _fetchSettingsData());
                          }
                        },
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDeviceBound
                                  ? (_isDeviceOnline ? Colors.green.withOpacity(0.4) : Colors.grey.shade300)
                                  : AppTheme.primaryColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDeviceBound
                                        ? (_isDeviceOnline ? Colors.green.withOpacity(0.1) : Colors.grey.shade100)
                                        : AppTheme.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isDeviceBound
                                        ? Icons.precision_manufacturing_rounded
                                        : Icons.add_to_queue_rounded,
                                    color: isDeviceBound 
                                        ? (_isDeviceOnline ? Colors.green.shade700 : Colors.grey.shade600) 
                                        : AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            isDeviceBound
                                                ? (_deviceName ?? 'ถุงมือกลกายภาพบำบัด')
                                                : 'ยังไม่ได้ผูกอุปกรณ์มือกล',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          if (isDeviceBound) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _isDeviceOnline ? Colors.green.shade50 : Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: _isDeviceOnline ? Colors.green.shade300 : Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Text(
                                                _isDeviceOnline ? 'ออนไลน์' : 'ออฟไลน์',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: _isDeviceOnline ? Colors.green.shade700 : Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isDeviceBound
                                            ? 'Serial Number: $_serialNumber'
                                            : 'คลิกที่นี่เพื่อระบุรหัสเครื่องมือกลเพื่อเริ่มซิงก์ข้อมูลฝึกซ้อม',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 🏆 กิจกรรมและความสำเร็จ
                      _buildSectionTitle('กิจกรรมและความสำเร็จ'),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AchievementPage(userId: _userId),
                                ),
                              );
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.amber,
                                size: 22,
                              ),
                            ),
                            title: const Text(
                              'ตราความสำเร็จและพัฒนาการ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              'ดูเข็มตราความสำเร็จและเป้าหมายการฝึก',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 📡 การเชื่อมต่อและการแจ้งเตือน
                      _buildSectionTitle('การเชื่อมต่อและการแจ้งเตือน'),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.bluetooth_rounded,
                                  color: _isDeviceOnline
                                      ? AppTheme.primaryColor
                                      : Colors.grey,
                                ),
                                title: const Text(
                                  'เชื่อมต่อถุงมืออัจฉริยะ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  _isDeviceOnline
                                      ? 'เชื่อมต่อกับ ${_deviceName ?? "Smart Glove"} แล้ว (ออนไลน์)'
                                      : 'อุปกรณ์ขาดการเชื่อมต่อ (ปิดเครื่องอยู่)',
                                ),
                                trailing: Switch(
                                  value: _isBluetoothConnected,
                                  activeColor: AppTheme.primaryColor,
                                  onChanged: (value) =>
                                      setState(() => _isBluetoothConnected = value),
                                ),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(
                                  Icons.cloud_sync_rounded,
                                  color: Colors.blueGrey,
                                ),
                                title: const Text(
                                  'ซิงค์ข้อมูลประวัติอัตโนมัติ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: const Text(
                                  'ส่งผลคะแนนฝึกไปยังระบบแพทย์ทันที',
                                ),
                                trailing: Switch(
                                  value: _autoSyncData,
                                  activeColor: AppTheme.primaryColor,
                                  onChanged: (value) =>
                                      setState(() => _autoSyncData = value),
                                ),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(
                                  Icons.notifications_active_rounded,
                                  color: Colors.amber,
                                ),
                                title: const Text(
                                  'เตือนฝึกซ้อมประจำวัน',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: const Text(
                                  'แจ้งเตือนให้ออกกำลังกายมือตามเวลาที่กำหนด',
                                ),
                                trailing: Switch(
                                  value: _enableReminder,
                                  activeColor: AppTheme.primaryColor,
                                  onChanged: (value) =>
                                      setState(() => _enableReminder = value),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 👤 บัญชีผู้ใช้งาน
                      _buildSectionTitle('บัญชีผู้ใช้งาน'),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PatientInfoScreen(userToken: widget.userToken),
                                    ),
                                  );
                                },
                                leading: const Icon(
                                  Icons.person_outline_rounded,
                                  color: AppTheme.textSecondary,
                                ),
                                title: const Text(
                                  'ข้อมูลส่วนตัวผู้ป่วย',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoctorInfoScreen(userToken: widget.userToken), 
                                    ),
                                  );
                                },
                                leading: const Icon(
                                  Icons.medical_services_outlined,
                                  color: AppTheme.textSecondary,
                                ),
                                title: const Text(
                                  'ข้อมูลแพทย์ประจำตัวผู้ดูแล',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 🔴 ออกจากระบบ
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.red.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        color: Colors.red.withOpacity(0.05),
                        child: ListTile(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.logout_rounded, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text(
                                        'ยืนยันการออกจากระบบ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Text(
                                    'คุณต้องการออกจากระบบบัญชีผู้ใช้นี้ใช่หรือไม่?',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'ยกเลิก',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SignInScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                      child: const Text(
                                        'ออกจากระบบ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          leading: const Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                          ),
                          title: const Text(
                            'ออกจากระบบบัญชี',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  void _showUnbindBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                Text(
                  'รายละเอียดอุปกรณ์',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ],
            ),
            const Divider(height: 32),
            Text('ชื่ออุปกรณ์: ${_deviceName ?? "ถุงมือกลกายภาพบำบัด"}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Serial Number: $_serialNumber', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text(
              _isDeviceOnline ? 'สถานะ: ออนไลน์ (พร้อมใช้งาน)' : 'สถานะ: ออฟไลน์ (ปิดเครื่องอยู่)', 
              style: TextStyle(
                fontSize: 13, 
                color: _isDeviceOnline ? Colors.green : Colors.grey, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: BorderSide(color: Colors.red.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.link_off_rounded),
                label: const Text('ยกเลิกการผูกอุปกรณ์นี้', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  Navigator.pop(context);
                  _confirmUnbindDevice();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmUnbindDevice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันการยกเลิกการผูกอุปกรณ์'),
        content: const Text('คุณต้องการยกเลิกการเชื่อมต่อถุงมือกลชิ้นนี้ออกจากบัญชีใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
            onPressed: () async {
              Navigator.pop(context);
              if (_deviceId != null) {
                final success = await DeviceService.unbindDevice(_deviceId!);
                if (success) {
                  _fetchSettingsData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ยกเลิกการผูกอุปกรณ์เรียบร้อยแล้ว')),
                  );
                }
              }
            },
            child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.2));
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppTheme.textSecondary,
      ),
    );
  }
}