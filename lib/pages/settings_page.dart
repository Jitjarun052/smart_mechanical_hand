import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../api/device_service.dart';
import '../api/history_service.dart';
import '../api/api_config.dart';
import '../theme/app_theme.dart';
import 'patient_info_page.dart';
import 'doctor_info_page.dart';
import 'device_setting_page.dart';
import '../screens/sign_in_screen.dart';

class SettingsPage extends StatefulWidget {
  final String? userToken; // 🔑 รับ Token เพื่อดึงข้อมูลเฉพาะบุคคล

  const SettingsPage({super.key, this.userToken});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isBluetoothConnected = true;
  bool _autoSyncData = true;
  bool _isLoading = true;

  // 👤 ตัวแปร Profile
  int? _userId;
  String _userName = 'ผู้ป่วย';
  String _userEmail = 'patient@health.com';
  String? _userImage;

  // ⚡ ตัวแปร Device
  int? _deviceId;
  String? _deviceName;
  String? _serialNumber;
  int? _deviceStatus;

  // 📊 ตัวแปร สถิติฝึกซ้อม
  int _totalSessions = 0;
  int _totalMinutes = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchSettingsData();
  }

  // 📡 ดึงข้อมูล Profile + Device + Stats จาก Backend
  Future<void> _fetchSettingsData() async {
    setState(() => _isLoading = true);

    if (widget.userToken != null && widget.userToken!.isNotEmpty) {
      // 1. ดึง Profile
      final userResult = await AuthService.getMe(widget.userToken!);
      if (userResult['success'] == true) {
        final userData = userResult['user'];
        final int? userId = userData['user_id'];
        final String? imageName = userData['image'];

        if (mounted) {
          setState(() {
            _userName = '${userData['firstname']} ${userData['lastname']}';
            _userEmail = userData['email'] ?? 'patient@health.com';
            _userImage = ApiConfig.getImageUrl(imageName);
            _userId = userId;
          });
        }

        // 2. ดึงข้อมูลอุปกรณ์
        if (userId != null) {
          final deviceData = await DeviceService.getDeviceByUserId(userId);
          if (deviceData != null && mounted) {
            setState(() {
              _deviceId = deviceData['device_id'];
              _deviceName = deviceData['device_name'];
              _serialNumber = deviceData['serial_number'];
              _deviceStatus = deviceData['device_status'];
            });
          }
        }
      }
    }

    // 3. ดึงประวัติมาคำนวณสถิติรวม
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
                // 🟠 Header Profile ส่วนบน
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

                // 📊 แผงสถิติรวมจริง
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

                // 🦾 การ์ดแสดงอุปกรณ์ของฉัน
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('อุปกรณ์ของฉัน'),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () {
                        if (isDeviceBound) {
                          // 📱 ถ้าผูกแล้ว ให้เปิด BottomSheet โชว์ข้อมูลและปุ่มยกเลิกการเชื่อมต่อ
                          _showUnbindBottomSheet(context);
                        } else {
                          // 📝 ถ้ายังไม่ผูก ค่อยส่งไปหน้าลงทะเบียนผูกอุปกรณ์
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  DeviceSettingPage(userId: _userId),
                            ),
                          ).then((_) => _fetchSettingsData()); // รีเฟรชข้อมูลเมื่อกลับมา
                        }
                      },
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDeviceBound
                                  ? Colors.green.withOpacity(0.4)
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
                                        ? Colors.green.withOpacity(0.1)
                                        : AppTheme.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isDeviceBound
                                        ? Icons.precision_manufacturing_rounded
                                        : Icons.add_to_queue_rounded,
                                    color: isDeviceBound ? Colors.green.shade700 : AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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

                      _buildSectionTitle('การเชื่อมต่อและอุปกรณ์'),
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
                                  color: _isBluetoothConnected
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
                                  _isBluetoothConnected
                                      ? 'เชื่อมต่อกับ ${_deviceName ?? "Smart Glove"} แล้ว'
                                      : 'อุปกรณ์ขาดการเชื่อมต่อ',
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

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
                                      // 🔑 แนบ userToken ส่งไปให้ PatientInfoScreen ดึงข้อมูลจริง
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
                                      // 🔑 แนบ userToken ไปให้ DoctorInfoScreen
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

                      // 🔴 ปุ่มออกจากระบบ
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
          const Text('สถานะ: เชื่อมต่อและพร้อมใช้งาน', style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 28),

          // 🔴 ปุ่มยกเลิกการเชื่อมต่อ
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
                Navigator.pop(context); // ปิด BottomSheet
                _confirmUnbindDevice(); // เรียก Dialog ยืนยัน
              },
            ),
          ),
        ],
      ),
    ),
  );
}

// ⚠️ Dialog ยืนยันการปลดอุปกรณ์
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
                _fetchSettingsData(); // 🔄 โหลดข้อมูลหน้าตั้งค่าใหม่ การ์ดจะกลับเป็น "ยังไม่ได้ผูกอุปกรณ์"
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