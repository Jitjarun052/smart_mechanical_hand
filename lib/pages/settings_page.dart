import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'patient_info_page.dart';
import 'doctor_info_page.dart';
// 🦾 ✨ [ADDED]: นำเข้าหน้าลงทะเบียนอุปกรณ์เพื่อเชื่อมการทำงานตรงๆ ตามที่คุยกันไว้
import 'device_setting_page.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isBluetoothConnected = true;
  bool _autoSyncData = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            padding: const EdgeInsets.only(top: 16.0, bottom: 28.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 65, color: Colors.grey),
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
                const Text(
                  'คุณผู้ป่วย (กายภาพบำบัด)',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'patient@health.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileStatItem('28', 'เซสชัน'),
                _buildVerticalDivider(),
                _buildProfileStatItem('145', 'นาที'),
                _buildVerticalDivider(),
                _buildProfileStatItem('1,550', 'ครั้งรวม'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 🦾 การ์ดเชิญชวนผูกอุปกรณ์กรณีผู้ป่วยกดข้ามขั้นตอนมาตอน Register
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('อุปกรณ์ของฉัน'),
                const SizedBox(height: 12),
                
                // 🛠️ [✨ อัปเดตจุดเปลี่ยน]: ลบฟังก์ชันขี่ BottomSheet ออก แล้วสั่งเปิดหน้าใหม่ตรงๆ คลีนสะใจแน่นอน
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeviceSettingPage(),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppTheme.primaryColor.withOpacity(0.3),
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
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_to_queue_rounded,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ยังไม่ได้ผูกอุปกรณ์มือกล',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'คลิกที่นี่เพื่อระบุรหัสเครื่องมือกลเพื่อเริ่มซิงก์ข้อมูลฝึกซ้อม',
                                  style: TextStyle(
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
                                ? 'เชื่อมต่อกับ Smart Glove v1 แล้ว'
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
                                builder: (context) => const PatientInfoScreen(),
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
                                builder: (context) => const DoctorInfoScreen(),
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
                    onTap: () => Navigator.pop(context),
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