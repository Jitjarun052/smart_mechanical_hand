import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/auth_service.dart';
import '../api/api_config.dart';
import '../theme/app_theme.dart';
import 'patient_detail_page.dart';
import 'edit_profile_page.dart';
import '../screens/sign_in_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorDashboardPage extends StatefulWidget {
  final String? doctorToken; // 🔑 รับ Token ของแพทย์เมื่อเข้าสู่ระบบ

  const DoctorDashboardPage({super.key, this.doctorToken});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoading = true;

  // 👨‍⚕️ ข้อมูลแพทย์ประจำตัว
  String _doctorName = 'นพ. ผู้ดูแลระบบ';
  String _doctorSpecialty = 'แพทย์ผู้เชี่ยวชาญด้านเวชศาสตร์ฟื้นฟู';
  String _hospitalName = 'โรงพยาบาลศูนย์กายภาพบำบัด';
  String? _doctorImage;

  // 🏥 รายชื่อผู้ป่วย & ประวัติฝึก
  List<Map<String, dynamic>> _myPatients = [];
  List<Map<String, dynamic>> _allHistoryLogs = [];

  // 🟢 ช่องค้นหาผู้ป่วยในแท็บ 1
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // 🟢 ตัวแปรค้นหา & ตัวกรอง สำหรับแท็บ 2 (ประวัติฝึกรวม)
  final TextEditingController _historySearchController = TextEditingController();
  String _historySearchQuery = "";
  String _selectedHistoryFilter = 'all';

  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchDoctorDataAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _historySearchController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  // 🟢 Getter ฟังก์ชันสำหรับค้นหาและกรองข้อมูลประวัติการฝึกรวม
  List<Map<String, dynamic>> get _filteredHistoryLogs {
    // 1. กรองตามชื่อผู้ป่วยจากช่องค้นหา
    List<Map<String, dynamic>> result = _allHistoryLogs.where((log) {
      final name = log['patient_name'].toString().toLowerCase();
      final q = _historySearchQuery.toLowerCase();
      return name.contains(q);
    }).toList();

    // 2. กรองตาม Filter Chips
    if (_selectedHistoryFilter == 'today') {
      DateTime now = DateTime.now();
      return result.where((log) {
        final dynamic rawDateObj = log['created_at_raw'];
        if (rawDateObj == null) return false;
        try {
          DateTime dt = DateTime.parse(rawDateObj.toString()).toLocal();
          return dt.year == now.year && dt.month == now.month && dt.day == now.day;
        } catch (_) {
          return false;
        }
      }).toList();
    } else if (_selectedHistoryFilter == '7days') {
      DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      return result.where((log) {
        final dynamic rawDateObj = log['created_at_raw'];
        if (rawDateObj == null) return false;
        try {
          DateTime dt = DateTime.parse(rawDateObj.toString()).toLocal();
          return dt.isAfter(sevenDaysAgo);
        } catch (_) {
          return false;
        }
      }).toList();
    } else if (_selectedHistoryFilter == 'good') {
      return result.where((log) => ((log['accuracy_raw'] as num?) ?? 0) >= 80).toList();
    } else if (_selectedHistoryFilter == 'need_focus') {
      return result.where((log) => ((log['accuracy_raw'] as num?) ?? 0) < 80).toList();
    }

    return result; // 'all'
  }

  // 📡 ดึงข้อมูลโปรไฟล์หมอ + ผู้ป่วยในการดูแล + ประวัติการฝึกรวม
  Future<void> _fetchDoctorDataAll() async {
    if (widget.doctorToken == null || widget.doctorToken!.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. ดึงโปรไฟล์หมอผ่าน /api/user/me
      final meResult = await AuthService.getMe(widget.doctorToken!);
      if (meResult['success'] == true && meResult['role'] == 'doctor') {
        final doc = meResult['user'];
        final String rolePrefix = doc['role_type'] == 'therapist' ? 'นักกายภาพบำบัด' : 'นพ.';
        
        setState(() {
          _doctorName = ' ${doc['name'] ?? ''}'.trim();
          _doctorSpecialty = doc['specialty'] ?? 'แพทย์ผู้เชี่ยวชาญด้านเวชศาสตร์ฟื้นฟู';
          _hospitalName = doc['hospital_name'] ?? 'ศูนย์กายภาพบำบัด';
          _doctorImage = ApiConfig.getImageUrl(doc['image']);
        });
      }

      // 2. ดึงผู้ป่วยในการดูแลเฉพาะของหมอคนนี้
      final patientsRes = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/doctor/my-patients'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.doctorToken}',
        },
      );

      if (patientsRes.statusCode == 200) {
        final pData = jsonDecode(patientsRes.body);
        if (pData['status'] == 'success') {
          _myPatients = List<Map<String, dynamic>>.from(pData['patients'].map((item) {
            String lastSession = 'ยังไม่มีการฝึก';
            if (item['last_session_raw'] != null) {
              try {
                final dt = DateTime.parse(item['last_session_raw']).toLocal();
                lastSession = DateFormat('d มิ.ย. yyyy', 'th').format(dt);
              } catch (_) {}
            }
            return {
              'id': item['id'].toString(),
              'name': item['name'] ?? 'ไม่ระบุชื่อ',
              'age': item['age']?.toString() ?? '-',
              'symptom': item['symptom'] ?? 'ไม่ระบุอาการ',
              'last_session': lastSession,
              'progress': '${item['avg_accuracy'] ?? 0}%',
            };
          }));
        }
      }

      // 3. ดึง Log การฝึกรวมของผู้ป่วยในการดูแล
      final logsRes = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/doctor/history-logs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.doctorToken}',
        },
      );

      if (logsRes.statusCode == 200) {
        final lData = jsonDecode(logsRes.body);
        if (lData['status'] == 'success') {
          _allHistoryLogs = List<Map<String, dynamic>>.from(lData['logs'].map((item) {
            String dateStr = '';
            String timeStr = '';
            if (item['created_at'] != null) {
              try {
                final dt = DateTime.parse(item['created_at']).toLocal();
                dateStr = DateFormat('d มิ.ย. yyyy', 'th').format(dt);
                timeStr = DateFormat('HH:mm น.').format(dt);
              } catch (_) {}
            }
            int acc = ((item['accuracy'] as num?) ?? 0).toInt();
            return {
              'patient_name': item['patient_name'] ?? 'ไม่ระบุผู้ป่วย',
              'date': dateStr,
              'time': timeStr,
              'created_at_raw': item['created_at'],
              'accuracy_raw': acc,
              'finger': 'นิ้วกล',
              'max_angle': '$acc%',
              'duration': '${(((item['duration'] as num?) ?? 0) / 60).round()} นาที',
              'performance': acc >= 80 ? 'ดีเยี่ยม 📈' : 'ต้องกระตุ้น ⚠️',
              'status_color': acc >= 80 ? Colors.green : Colors.orange,
            };
          }));
        }
      }

    } catch (e) {
      print('Doctor Dashboard Fetch Error: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> doctorScreens = [
      _buildMainDashboardTab(),
      _buildHistoryTab(),
      _buildProfileSettingTab(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : doctorScreens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.brown.shade300,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_rounded, size: 24),
              ),
              label: 'หน้าหลัก',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.bar_chart_rounded, size: 24),
              ),
              label: 'ประวัติฝึก',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.settings_rounded, size: 24),
              ),
              label: 'ตั้งค่า',
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 🏠 แท็บที่ 1: หน้า Dashboard ค้นหาผู้ป่วย ====================
  Widget _buildMainDashboardTab() {
    final filteredPatients = _myPatients.where((patient) {
      final name = patient['name'].toString().toLowerCase();
      final symptom = patient['symptom'].toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || symptom.contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สวัสดีครับ, $_doctorName 👋',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(_hospitalName, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),

          Row(
            children: [
              _buildStatCard('ผู้ป่วยในการดูแล', '${_myPatients.length} คน', Icons.people_alt_rounded, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('ต้องดูแลด่วน', '${_myPatients.where((p) => p['progress'] == '0%').length} คน', Icons.warning_amber_rounded, Colors.orange),
            ],
          ),
          const SizedBox(height: 28),

          const Text('ค้นหาข้อมูลผู้ป่วย', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'พิมพ์ชื่อผู้ป่วย หรืออาการที่ต้องการค้นหา...',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                    filled: true, fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 52, width: 52,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                child: IconButton(
                  icon: RotationTransition(turns: _refreshAnimationController, child: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor, size: 24)),
                  onPressed: () {
                    _refreshAnimationController.forward(from: 0.0);
                    _fetchDoctorDataAll();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('รายชื่อผู้ป่วยในการดูแล', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text('พบ ${filteredPatients.length} รายการ', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),

          filteredPatients.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('ไม่พบข้อมูลผู้ป่วยในการดูแล', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = filteredPatients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.15))),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientDetailPage(
                                patientData: patient,
                                doctorToken: widget.doctorToken, 
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(radius: 22, backgroundColor: AppTheme.primaryColor.withOpacity(0.1), child: const Icon(Icons.person_search_rounded, color: AppTheme.primaryColor, size: 20)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${patient['name']} (${patient['age']} ปี)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text('อาการ: ${patient['symptom']}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Text('ฝึกซ้อมล่าสุด: ${patient['last_session']} | พัฒนาการ: ${patient['progress']}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // ==================== 📊 แท็บที่ 2: หน้าประวัติฝึกภาพรวม (พร้อมช่องค้นหา + ตัวกรอง) ====================
  Widget _buildHistoryTab() {
    final logs = _filteredHistoryLogs;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ประวัติการฝึกซ้อมรวม 📊', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text('บันทึกเซสชันกายภาพบำบัดของผู้ป่วยในการดูแล', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
                onPressed: _fetchDoctorDataAll,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔍 ช่องค้นหาชื่อผู้ป่วยในแท็บประวัติ
          TextFormField(
            controller: _historySearchController,
            onChanged: (value) => setState(() => _historySearchQuery = value),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'ค้นหาด้วยชื่อผู้ป่วย...',
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
              suffixIcon: _historySearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                      onPressed: () {
                        _historySearchController.clear();
                        setState(() => _historySearchQuery = "");
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
            ),
          ),
          const SizedBox(height: 12),

          // 🏷️ แถบตัวกรอง Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHistoryFilterChip('ทั้งหมด (${_allHistoryLogs.length})', 'all'),
                const SizedBox(width: 8),
                _buildHistoryFilterChip('วันนี้', 'today'),
                const SizedBox(width: 8),
                _buildHistoryFilterChip('7 วันล่าสุด', '7days'),
                const SizedBox(width: 8),
                _buildHistoryFilterChip('ดีเยี่ยม (≥80%)', 'good'),
                const SizedBox(width: 8),
                _buildHistoryFilterChip('ต้องกระตุ้น (<80%)', 'need_focus'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          logs.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(
                    child: Text('ไม่พบรายการประวัติการฝึกตามเงื่อนไขที่ค้นหา', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.12))),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (log['status_color'] as Color).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.accessibility_new_rounded, color: log['status_color'] as Color, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(log['patient_name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary)),
                                  const SizedBox(height: 4),
                                  Text('ระยะเวลาฝึก: ${log['duration']}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_month_rounded, size: 12, color: Colors.grey.shade400),
                                      const SizedBox(width: 4),
                                      Text('${log['date']} • ${log['time']}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(log['max_angle']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor)),
                                const SizedBox(height: 2),
                                Text(log['performance']!, style: TextStyle(fontSize: 11, color: log['status_color'] as Color, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
        ],
      ),
    );
  }

  // 🟢 Widget สำหรับสร้างปุ่ม Filter Chip ในแท็บประวัติ
  Widget _buildHistoryFilterChip(String label, String value) {
    bool isSelected = _selectedHistoryFilter == value;
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
            _selectedHistoryFilter = value;
          });
        }
      },
    );
  }

  // ==================== ⚙️ แท็บที่ 3: หน้าตั้งค่า + แก้ไขโปรไฟล์หมอ ====================
  Widget _buildProfileSettingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ตั้งค่าระบบ & โปรไฟล์', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.15))),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  backgroundImage: (_doctorImage != null && _doctorImage!.isNotEmpty) ? NetworkImage(_doctorImage!) : null,
                  child: (_doctorImage == null || _doctorImage!.isEmpty)
                      ? const Icon(Icons.medical_information_rounded, size: 45, color: AppTheme.primaryColor)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(_doctorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text(_doctorSpecialty, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                Text(_hospitalName, style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                ElevatedButton.icon(
                  onPressed: () async {
                    final isSaved = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(doctorToken: widget.doctorToken), 
                      ),
                    );

                    if (isSaved == true) {
                      _fetchDoctorDataAll(); 
                    }
                  },
                  icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                  label: const Text('แก้ไขข้อมูลส่วนตัว', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 🚪 ปุ่ม Logout
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.red.shade100)),
            color: Colors.red.shade50.withOpacity(0.5),
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: Colors.red.shade700),
              title: Text('ออกจากระบบ (Logout)', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 14)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.red),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (route) => false,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.15))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}