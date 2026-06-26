import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'patient_detail_page.dart';
import 'edit_profile_page.dart'; 

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0; // ✨ สำหรับจำจำสเตตัสว่าคุณหมอกำลังเลือกเปิดแท็บไหนอยู่
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  late AnimationController _refreshAnimationController;

  // 🏥 ม็อคข้อมูลรายชื่อผู้ป่วยเดิมของคุณ
  final List<Map<String, dynamic>> _myPatients = [
    {'id': 'P001', 'name': 'จิตร์จรัญ คืนมาเมือง', 'age': '65', 'symptom': 'หลอดเลือดสมอง (Stroke) / อ่อนแรงซีกซ้าย', 'last_session': '17 มิ.ย. 2569', 'progress': '85%'},
    {'id': 'P002', 'name': 'สมชาย ใจดี', 'age': '58', 'symptom': 'กล้ามเนื้อเหยียดนิ้วมือหดเกร็ง', 'last_session': '15 มิ.ย. 2569', 'progress': '90%'},
    {'id': 'P003', 'name': 'สมศรี รักสงบ', 'age': '70', 'symptom': 'อุบัติเหตุเส้นประสาทส่วนปลายบาดเจ็บ', 'last_session': 'ยังไม่มีการฝึก', 'progress': '0%'},
  ];

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 ลิสต์รายการหน้าจอที่จะสลับเปลี่ยนตามแท็บด้านล่างที่คุณหมอกดเลือก
    final List<Widget> _doctorScreens = [
      _buildMainDashboardTab(), // 🏠 แท็บที่ 1: หน้าหลักค้นหาผู้ป่วย
      _buildHistoryTab(),       // 📊 แท็บที่ 2: หน้าประวัติฝึกรวม
      _buildProfileSettingTab(), // ⚙️ แท็บที่ 3: หน้าตั้งค่าและแก้ไขโปรไฟล์หมอ
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // 🚫 [REMOVE TOPBAR]: ถอด appBar: AppBar(...) ออกถาวรเพื่อให้หน้าจอโปร่งโล่งตาตามคำขอครับ!
      body: SafeArea(
        child: _doctorScreens[_currentIndex], // พ่นหน้าจอตามดัชนีแท็บที่กดเลือก
      ),
      
      // 🧡 [ADDED ✨]: แถบเนวิเกชันด้านล่าง ดีไซน์สีส้มอิฐ-น้ำตาล อิงตามรูปต้นแบบเป๊ะๆ
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
              _currentIndex = index; // สลับสเตทหน้าจอ
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor, // สีส้มอิฐตอนเลือกใช้งาน
          unselectedItemColor: Colors.brown.shade300, // สีน้ำตาลจางตอนไม่ได้เลือก
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed, // ล็อกแถบให้นิ่งไม่ให้ขยับดึ๋งดั๋ง
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

  // ==================== 🏠 แท็บที่ 1: โครงสร้างหน้า Dashboard ค้นหาเดิมของคุณ ====================
  Widget _buildMainDashboardTab() {
    final filteredPatients = _myPatients.where((patient) {
      return patient['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             patient['symptom']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สวัสดีครับ, นพ.สมชาย 👋',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text('ระบบติดตามสถิติผู้ป่วย Smart Mechanical Hand', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          
          Row(
            children: [
              _buildStatCard('ผู้ป่วยทั้งหมด', '${_myPatients.length} คน', Icons.people_alt_rounded, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('ต้องดูแลด่วน', '1 คน', Icons.warning_amber_rounded, Colors.orange),
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔄 รีเฟรชข้อมูลผู้ป่วยล่าสุดเรียบร้อย...')));
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

          ListView.builder(
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
                        builder: (context) => PatientDetailPage(patientData: patient),
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

  // ==================== 📊 แท็บที่ 2: หน้าประวัติฝึกภาพรวม (Log ย้อนหลังรวมทุกคน) ====================
  Widget _buildHistoryTab() {
    // 📋 ม็อคข้อมูลรายการฝึกซ้อมล่าสุดรวมของผู้ป่วยทุกคน (ล้อตามโครงสร้างตารางเซสชันใน MySQL)
    final List<Map<String, dynamic>> _allHistoryLogs = [
      {
        'patient_name': 'จิตร์จรัญ คืนมาเมือง',
        'date': '26 มิ.ย. 2569',
        'time': '11:15 น.',
        'finger': 'นิ้วชี้',
        'max_angle': '145°',
        'duration': '15 นาที',
        'performance': 'ดีเยี่ยม 📈',
        'status_color': Colors.green
      },
      {
        'patient_name': 'สมชาย ใจดี',
        'date': '25 มิ.ย. 2569',
        'time': '16:40 น.',
        'finger': 'นิ้วโป้ง',
        'max_angle': '95°',
        'duration': '15 นาที',
        'performance': 'ตามเป้าหมาย',
        'status_color': Colors.blue
      },
      {
        'patient_name': 'จิตร์จรัญ คืนมาเมือง',
        'date': '24 มิ.ย. 2569',
        'time': '09:30 น.',
        'finger': 'นิ้วกลาง',
        'max_angle': '110°',
        'duration': '10 นาที',
        'performance': 'ปกติ',
        'status_color': Colors.blue
      },
      {
        'patient_name': 'สมชาย ใจดี',
        'date': '23 มิ.ย. 2569',
        'time': '14:20 น.',
        'finger': 'นิ้วชี้',
        'max_angle': '85°',
        'duration': '15 นาที',
        'performance': 'ต้องกระตุ้น ⚠️',
        'status_color': Colors.orange
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนหัวของหน้าประวัติฝึก
          const Text(
            'ประวัติการฝึกซ้อมรวม 📊',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'บันทึกเซสชันกายภาพบำบัดล่าสุดของผู้ป่วยทุกคนในการดูแล',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // 📜 ลิสต์รายการการฝึกซ้อมเรียงตามไทม์ไลน์
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allHistoryLogs.length,
            itemBuilder: (context, index) {
              final log = _allHistoryLogs[index];
              
              // 🚀 [แก้ไขตรงนี้]: เปลี่ยน Container เดิม เป็น Card + InkWell เพื่อให้กดคลิกได้
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.12)),
                ),
                clipBehavior: Clip.antiAlias, // คุมให้เอฟเฟกต์คลิกไม่ล้นขอบมน
                child: InkWell(
                  onTap: () {
                    // 🏥 สับรางแปลงข้อมูลเพื่อให้เข้าคู่กับหน้า PatientDetailPage
                    final patientTarget = {
                      'id': log['patient_name'] == 'จิตร์จรัญ คืนมาเมือง' ? 'P001' : 'P002',
                      'name': log['patient_name'],
                      'age': log['patient_name'] == 'จิตร์จรัญ คืนมาเมือง' ? '65' : '58',
                      'symptom': log['patient_name'] == 'จิตร์จรัญ คืนมาเมือง' 
                          ? 'หลoderดสมอง (Stroke) / อ่อนแรงซีกซ้าย'
                          : 'กล้ามเนื้อเหยียดนิ้วมือหดเกร็ง',
                    };

                    // 📈 พุ่งตัวไปสู่หน้าประวัติกราฟเชิงลึกรายบุคคลทันที!
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientDetailPage(patientData: patientTarget),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // ย้าย padding จาก Container มาไว้ตรงนี้
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ไอคอนบ่งบอกสถานะการฝึกแยกตามสีสเตตัส (โค้ดเดิมของคุณ)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (log['status_color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.accessibility_new_rounded,
                            color: log['status_color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // ข้อมูลรายละเอียดของเซสชันฝึก (โค้ดเดิมของคุณ)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log['patient_name']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ฝึกซ้อม: ${log['finger']} | ระยะเวลา: ${log['duration']}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_month_rounded, size: 12, color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${log['date']} • ${log['time']}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // สรุปตัวเลขผลลัพธ์องศาที่ทำได้ฝั่งขวาจัด (โค้ดเดิมของคุณ)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              log['max_angle']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              log['performance']!,
                              style: TextStyle(
                                fontSize: 11, 
                                color: log['status_color'] as Color, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  // ==================== ⚙️ แท็บที่ 3: หน้าตั้งค่า + แก้ไขโปรไฟล์หมอ (ตามที่คุณขอเพิ่มเติม) ====================
  Widget _buildProfileSettingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ตั้งค่าระบบ & โปรไฟล์', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 24),
          
          // 👨‍⚕️ ส่วนรูปและการ์ดจัดการข้อมูลส่วนตัวหมอ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.15))),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(radius: 45, backgroundColor: AppTheme.primaryColor.withOpacity(0.1), child: const Icon(Icons.medical_information_rounded, size: 45, color: AppTheme.primaryColor)),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                const Text('นพ. สมชาย รักดี', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const Text('แพทย์ผู้เชี่ยวชาญด้านเวชศาสตร์ฟื้นฟู', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 20),
                
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfilePage()),
                    );
                  },
                  icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                  label: const Text('แก้ไขข้อมูลส่วนตัว', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 🚪 ปุ่มกดออกจากระบบกลับไปหน้า Login
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.red.shade100)),
            color: Colors.red.shade50.withOpacity(0.5), // ปรับค่าความโปร่งแสงเป็น 50% แบบถูกต้องตามหลัก Flutter
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: Colors.red.shade700),
              title: Text('ออกจากระบบ (Logout)', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 14)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.red),
              onTap: () => Navigator.pop(context), // เด้งออกหน้า Login สวยๆ
            ),
          )
        ],
      ),
    );
  }

  // Widget ตัวสร้างการ์ดสถิติเดิม
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

  void alertSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}