import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../api/history_service.dart';
import '../api/doctor_service.dart';

class PatientDetailPage extends StatefulWidget {
  final Map<String, dynamic> patientData;
  final String? doctorToken; // 🔑 รับ doctorToken สำหรับยืนยันสิทธิ์

  const PatientDetailPage({
    super.key, 
    required this.patientData, 
    this.doctorToken,
  });

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  int _selectedTab = 1; // 0 = รายวัน, 1 = รายสัปดาห์, 2 = รายเดือน
  int _displayLimit = 10; // 🟢 จำนวนแสดงผลเริ่มต้น
  
  // 🩺 ค่าเป้าหมายที่แพทย์กำหนด (Prescription Target)
  late int _targetCount;
  late int _targetSet;

  String _selectedFinger = 'นิ้วชี้';
  final List<String> _fingers = ['นิ้วโป้ง', 'นิ้วชี้', 'นิ้วกลาง', 'นิ้วนาง', 'นิ้วก้อย'];

  String _selectedYear = 'ปี: 2569';
  String _selectedMonth = 'เดือน: มิ.ย.';

  bool _isLoading = true;
  List<dynamic> _patientHistoryList = [];

  final Map<String, int> _monthMap = {
    'เดือน: ม.ค.': 1, 'เดือน: ก.พ.': 2, 'เดือน: มี.ค.': 3, 'เดือน: เม.ย.': 4,
    'เดือน: พ.ค.': 5, 'เดือน: มิ.ย.': 6, 'เดือน: ก.ค.': 7, 'เดือน: ส.ค.': 8,
    'เดือน: ก.ย.': 9, 'เดือน: ต.ค.': 10, 'เดือน: พ.ย.': 11, 'เดือน: ธ.ค.': 12,
  };

  final Map<String, String> _fingerColumnMap = {
    'นิ้วโป้ง': 'finger_thumb',
    'นิ้วชี้': 'finger_index',
    'นิ้วกลาง': 'finger_middle',
    'นิ้วนาง': 'finger_ring',
    'นิ้วก้อย': 'finger_pinky',
  };

  @override
  void initState() {
    super.initState();
    // 🟢 ดึงค่าเป้าหมายเดิมจาก patientData หรือตั้ง Default (10 ครั้ง / 3 เซ็ต)
    _targetCount = (widget.patientData['target_count'] as num?)?.toInt() ?? 10;
    _targetSet = (widget.patientData['target_set'] as num?)?.toInt() ?? 3;
    _fetchPatientHistory();
  }

  Future<void> _fetchPatientHistory() async {
    setState(() => _isLoading = true);
    
    final String userId = widget.patientData['id'].toString();
    final data = await HistoryService.getHistoryByUserId(userId);

    if (mounted) {
      setState(() {
        _patientHistoryList = data;
        _isLoading = false;
      });
    }
  }

  // 📝 Dialog สำหรับให้แพทย์แก้ไข/กำหนดจำนวนเป้าหมาย พร้อมเรียก API
  Future<void> _showEditTargetDialog() async {
    final TextEditingController countController = TextEditingController(text: _targetCount.toString());
    final TextEditingController setController = TextEditingController(text: _targetSet.toString());
    bool isSaving = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.edit_calendar_rounded, color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text('กำหนดเป้าหมายการฝึก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: countController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'จำนวนครั้งต่อเซ็ต (ครั้ง)',
                        prefixIcon: Icon(Icons.repeat_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: setController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'จำนวนเซ็ตเป้าหมาย (เซ็ต)',
                        prefixIcon: Icon(Icons.fitness_center_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final int? newCount = int.tryParse(countController.text.trim());
                          final int? newSet = int.tryParse(setController.text.trim());

                          if (newCount == null || newSet == null || newCount <= 0 || newSet <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('กรุณาระบุจำนวนครั้งและเซ็ตให้ถูกต้อง'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSaving = true);

                          // 📡 🟢 ยิง API ไปยัง Backend ผ่าน DoctorService
                          final result = await DoctorService.updatePrescription(
                            patientId: widget.patientData['id'],
                            targetCount: newCount,
                            targetSet: newSet,
                            doctorToken: widget.doctorToken,
                          );

                          setDialogState(() => isSaving = false);

                          if (result['success'] == true) {
                            setState(() {
                              _targetCount = newCount;
                              _targetSet = newSet;
                              widget.patientData['target_count'] = newCount;
                              widget.patientData['target_set'] = newSet;
                            });

                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ?? 'บันทึกเป้าหมายการฝึกเรียบร้อยแล้ว'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ?? 'เกิดข้อผิดพลาดในการบันทึก'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('บันทึกเป้าหมาย', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> _calculateStats() {
    final int targetYearBE = int.tryParse(_selectedYear.replaceAll('ปี: ', '')) ?? 2569;
    final int targetYearAD = targetYearBE - 543;
    final int targetMonth = _monthMap[_selectedMonth] ?? 6;

    final filteredByYear = _patientHistoryList.where((item) {
      if (item['created_at'] == null) return false;
      try {
        final DateTime dt = DateTime.parse(item['created_at'].toString()).toLocal();
        return dt.year == targetYearAD;
      } catch (_) { 
        return false; 
      }
    }).toList();

    final List<Map<String, dynamic>> filteredByMonth = filteredByYear.where((item) {
      if (item['created_at'] == null) return false;
      try {
        final DateTime dt = DateTime.parse(item['created_at'].toString()).toLocal();
        return dt.month == targetMonth;
      } catch (_) {
        return false;
      }
    }).map((item) => Map<String, dynamic>.from(item as Map)).toList();

    int totalCount = 0;
    int totalDurationSec = 0;
    double sumAccuracy = 0.0;

    final targetList = (_selectedTab == 2) 
        ? filteredByYear.map((item) => Map<String, dynamic>.from(item as Map)).toList() 
        : filteredByMonth;
        
    final int sessionCount = targetList.length;

    for (var item in targetList) {
      totalCount += (item['count'] as num? ?? 0).toInt();
      totalDurationSec += (item['duration'] as num? ?? 0).toInt();
      sumAccuracy += (item['accuracy'] as num? ?? 0).toDouble();
    }

    final double avgAccuracy = sessionCount > 0 ? (sumAccuracy / sessionCount) : 0.0;
    final int totalMinutes = (totalDurationSec / 60).round();

    return {
      'totalCount': '$totalCount ครั้ง',
      'accuracy': '${avgAccuracy.toStringAsFixed(0)} %',
      'totalTime': '$totalMinutes นาที',
      'sessions': '$sessionCount ครั้ง',
      'monthData': filteredByMonth,
    };
  }

  List<FlSpot> _generateChartSpots(List<Map<String, dynamic>> monthData) {
    if (monthData.isEmpty) {
      return [const FlSpot(1, 0), const FlSpot(2, 0), const FlSpot(3, 0), const FlSpot(4, 0)];
    }

    final String targetColumn = _fingerColumnMap[_selectedFinger] ?? 'finger_index';

    List<FlSpot> spots = [];
    for (int i = 0; i < monthData.length; i++) {
      final item = monthData[i];
      double angle = (item[targetColumn] as num? ?? item['wrist_angle'] as num? ?? item['accuracy'] as num? ?? 0).toDouble();
      if (angle > 180) angle = 180;
      spots.add(FlSpot((i + 1).toDouble(), angle));
    }

    while (spots.length < 4) {
      spots.add(FlSpot((spots.length + 1).toDouble(), spots.isNotEmpty ? spots.last.y : 0));
    }

    return spots.sublist(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final currentStats = _calculateStats();
    final List<Map<String, dynamic>> currentMonthLogs = List<Map<String, dynamic>>.from(currentStats['monthData'] ?? []);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ข้อมูลคนไข้: ${widget.patientData['name']}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🩺 1. การ์ดโปรไฟล์คนไข้
                  _buildPatientHeaderProfile(),
                  const SizedBox(height: 16),

                  // 🎯 2. การ์ดเป้าหมายการฝึกที่แพทย์กำหนด (Prescription Card)
                  _buildTargetPrescriptionCard(),
                  const SizedBox(height: 24),

                  // 📈 3. ส่วนหัวกราฟพัฒนาการ + Dropdown เลือกนิ้ว
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'พัฒนาการ องศา$_selectedFinger 📈',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const Text(
                            'เปรียบเทียบองศาการงอ-เหยียดในแต่ละเซสชัน',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.withOpacity(0.15)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFinger,
                            items: _fingers.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value, 
                                child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                            onChanged: (newValue) => setState(() => _selectedFinger = newValue!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 📊 4. ตัวกล่องกราฟเส้น
                  Container(
                    height: 250,
                    padding: const EdgeInsets.only(right: 20, top: 16, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.12)),
                    ),
                    child: _buildLineChartGraphic(currentMonthLogs),
                  ),
                  const SizedBox(height: 28),

                  // 💊 5. รายงานผลรวมแบ่งตามช่วงเวลา
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('รายงานผลรวมแบ่งตามช่วงเวลา', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      Row(
                        children: [
                          _buildDropdownFilter(_selectedMonth, _monthMap.keys.toList(), (val) => setState(() => _selectedMonth = val!)),
                          const SizedBox(width: 6),
                          _buildDropdownFilter(_selectedYear, <String>['ปี: 2569', 'ปี: 2568', 'ปี: 2567'], (val) => setState(() => _selectedYear = val!)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCapsuleTab(0, 'รายวัน'),
                      _buildCapsuleTab(1, 'รายสัปดาห์'),
                      _buildCapsuleTab(2, 'รายเดือน'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildWideStatCard(
                    icon: Icons.back_hand_rounded, 
                    value: currentStats['totalCount'] ?? '0 ครั้ง', 
                    label: 'จำนวนการกำ-เหยียดสะสมในช่วงเวลา', 
                    subtitle: 'สถิติล่าสุดซิงค์ตรงกับเซิร์ฟเวอร์เรียบร้อย', 
                    iconColor: Colors.blue
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _buildModernMiniCard(Icons.track_changes_rounded, currentStats['accuracy'] ?? '0 %', 'ความแม่นยำเฉลี่ย', Colors.teal)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildModernMiniCard(Icons.access_time_filled_rounded, currentStats['totalTime'] ?? '0 นาที', 'เวลาฝึกรวม', Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 📋 6. รายการประวัติฝึกซ้อมย้อนหลัง
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'บันทึกการฝึกซ้อมรายเซสชัน (${_patientHistoryList.length < _displayLimit ? _patientHistoryList.length : _displayLimit}/${_patientHistoryList.length})', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 20, color: AppTheme.primaryColor),
                        onPressed: () {
                          setState(() => _displayLimit = 10);
                          _fetchPatientHistory();
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  _patientHistoryList.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: const Center(child: Text('คนไข้รายนี้ยังไม่มีประวัติการฝึกซ้อมในระบบ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
                        )
                      : Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _patientHistoryList.length < _displayLimit ? _patientHistoryList.length : _displayLimit,
                              itemBuilder: (context, index) {
                                final item = _patientHistoryList[index];
                                final int count = item['count'] ?? 0;
                                final int duration = item['duration'] ?? 0;
                                final num? wristAngle = item['wrist_angle'];
                                final String rawDate = item['created_at'] ?? '';

                                final int fThumb = item['finger_thumb'] ?? 0;
                                final int fIndex = item['finger_index'] ?? 0;
                                final int fMiddle = item['finger_middle'] ?? 0;
                                final int fRing = item['finger_ring'] ?? 0;
                                final int fPinky = item['finger_pinky'] ?? 0;

                                String formattedDate = 'ไม่ระบุวันที่';
                                String formattedTime = '';

                                if (rawDate.isNotEmpty) {
                                  try {
                                    final DateTime dt = DateTime.parse(rawDate.replaceAll('T', ' ')).toLocal();
                                    
                                    final List<String> thaiMonths = [
                                      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
                                      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
                                    ];

                                    final String day = dt.day.toString();
                                    final String month = thaiMonths[dt.month];
                                    final String yearBE = (dt.year + 543).toString();
                                    final String hour = dt.hour.toString().padLeft(2, '0');
                                    final String minute = dt.minute.toString().padLeft(2, '0');

                                    formattedDate = '$day $month $yearBE';
                                    formattedTime = '$hour:$minute น.';
                                  } catch (e) {
                                    debugPrint('Date Parse Error: $e');
                                  }
                                }
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), 
                                    side: BorderSide(color: Colors.grey.withOpacity(0.1))
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.backgroundColor, 
                                        child: const Icon(Icons.blur_on_rounded, color: AppTheme.primaryColor),
                                      ),
                                      title: Text('$formattedDate $formattedTime', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text('จำนวน: $count ครั้ง | เวลา: $duration วินาที | ข้อมือ: ${wristAngle ?? 0}°', style: const TextStyle(fontSize: 12)),
                                          const SizedBox(height: 4),
                                          Text(
                                            'องศานิ้ว [โป้ง:$fThumb° | ชี้:$fIndex° | กลาง:$fMiddle° | นาง:$fRing° | ก้อย:$fPinky°]',
                                            style: TextStyle(fontSize: 11, color: Colors.teal.shade700, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (_patientHistoryList.length > _displayLimit)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryColor,
                                      side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _displayLimit += 10;
                                      });
                                    },
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                    label: Text(
                                      'แสดงประวัติเพิ่มเติม (เหลืออีก ${_patientHistoryList.length - _displayLimit} รายการ)',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ],
              ),
            ),
    );
  }

  // 🎯 การ์ดแสดงเป้าหมายการฝึกที่แพทย์กำหนด + ปุ่มแก้ไข
  Widget _buildTargetPrescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.flag_rounded, color: AppTheme.primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text('เป้าหมายการฝึก', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor, size: 22),
                tooltip: 'แก้ไขจำนวนเป้าหมาย',
                onPressed: _showEditTargetDialog,
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('จำนวนครั้ง / เซ็ต', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text('$_targetCount ครั้ง', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
              Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.3)),
              Column(
                children: [
                  const Text('จำนวนเซ็ตเป้าหมาย', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text('$_targetSet เซ็ต', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPatientHeaderProfile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.orange.shade50,
                child: Icon(Icons.assignment_ind_rounded, color: Colors.orange.shade800),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.patientData['name']} (อายุ ${widget.patientData['age']} ปี)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'รหัสผู้ป่วย: HN-${widget.patientData['id']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontFamily: 'mono'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28, thickness: 1),
          const Text('วินิจฉัย/อาการคนไข้:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          Text(
            '${widget.patientData['symptom'] ?? "ไม่มีระบุอาการ"}',
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartGraphic(List<Map<String, dynamic>> monthData) {
    final spots = _generateChartSpots(monthData);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 30,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1, dashArray: [5, 5]),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 30,
              reservedSize: 35,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}°', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int idx = value.toInt();
                if (idx >= 1 && idx <= 4) {
                  return Text('ครั้งที่ $idx', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold));
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 1, maxX: 4,
        minY: 0, maxY: 180,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: AppTheme.primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 5, color: AppTheme.primaryColor, strokeWidth: 1.5, strokeColor: Colors.white),
            ),
            belowBarData: BarAreaData(show: true, color: AppTheme.primaryColor.withOpacity(0.08)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String currentVal, List<String> listItems, Function(String?) eventChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withOpacity(0.15))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentVal, 
          icon: const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.primaryColor), 
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), 
          items: listItems.map((String val) => DropdownMenuItem<String>(value: val, child: Text(val))).toList(), 
          onChanged: eventChange,
        ),
      ),
    );
  }

  Widget _buildCapsuleTab(int index, String label) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))] : [],
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textSecondary, fontSize: 13)),
      ),
    );
  }

  Widget _buildWideStatCard({required IconData icon, required String value, required String label, required String subtitle, required Color iconColor}) {
    return Card(
      elevation: 0, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 26)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModernMiniCard(IconData icon, String value, String label, Color iconColor) {
    return Card(
      elevation: 0, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}