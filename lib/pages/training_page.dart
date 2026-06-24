import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import './notification_page.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  // ⏱️ ตัวแปรระบบเวลาและข้อมูลเซนเซอร์
  bool _isTraining = false;
  Timer? _timer;
  int _secondsElapsed = 0;
  
  // 📊 ค่าสถานะจากเซนเซอร์
  int _flexCount = 35; 
  int _targetDays = 5; 
  double _accuracy = 95.0; 
  int _totalTrainingMin = 145; 

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    String minsStr = mins.toString().padLeft(2, '0');
    String secsStr = secs.toString().padLeft(2, '0');
    return "$minsStr:$secsStr";
  }

  void _toggleTraining() {
    setState(() {
      _isTraining = !_isTraining;
    });

    if (_isTraining) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsElapsed++;
        });
      });
    } else {
      _timer?.cancel();
      setState(() {
        _secondsElapsed = 0;
      });
    }
  }

  void _simulateGloveAction() {
    if (!_isTraining) return;
    setState(() {
      _flexCount++; 
      if (_flexCount % 10 == 0) {
        _totalTrainingMin++;
      }
      _accuracy = 85 + Random().nextDouble() * 14; 
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // 🛠️ 1. เพิ่มปุ่มกระดิ่งแจ้งเตือน (Notification) ไว้บน Topbar ตามต้นแบบ
      appBar: AppBar(
        title: const Text('ข้อมูลจากเซนเซอร์', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_rounded, color: Colors.blue, size: 28),
                  onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationPage()),
                  );
                  },
                ),
                // 🔴 ตัวเลขแจ้งเตือนสีแดง (Badge)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: const Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 🤖 2. กล่องควบคุมและแผงเวลาดีไซน์รวมร่าง ( Action Card สไตล์ "พร้อมเริ่มปั่น" )
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              // เปลี่ยนสีการ์ดให้เด่นขึ้นถ้ากําลังทํางาน
              color: _isTraining ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      _isTraining ? '🤖 กำลังฝึกซ้อมกายภาพ' : 'พร้อมเริ่มฝึกซ้อม',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: _isTraining ? AppTheme.primaryColor : AppTheme.textPrimary
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // แถวพารามิเตอร์ย่อยในบาร์ (เวลา และ อุปกรณ์)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.access_time_filled_rounded, color: AppTheme.primaryColor.withOpacity(0.7)),
                            const SizedBox(height: 6),
                            Text(_formatTime(_secondsElapsed), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const Text('เวลา', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.bluetooth_connected_rounded, color: _isTraining ? Colors.green : Colors.grey),
                            const SizedBox(height: 6),
                            const Text('Smart Hand', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(_isTraining ? 'ออนไลน์' : 'สแตนด์บาย', style: TextStyle(fontSize: 12, color: _isTraining ? Colors.green : AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // 🚀 ปุ่มกด Action "เริ่มฝึก / หยุดฝึก" ภายในตัวการ์ดตามสไตล์ที่คุณชอบ
                    SizedBox(
                      width: 160,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTraining ? Colors.red : AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                          elevation: 2,
                        ),
                        onPressed: _toggleTraining,
                        icon: Icon(_isTraining ? Icons.stop_rounded : Icons.play_arrow_rounded),
                        label: Text(
                          _isTraining ? 'หยุดฝึก' : 'เริ่มฝึกซ้อม',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📊 3. แถวแสดงจำนวนครั้งสะสม และ ความคืบหน้าเป้าหมาย
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 90,
                                height: 90,
                                child: CircularProgressIndicator(
                                  value: (_flexCount % 100) / 100,
                                  strokeWidth: 8,
                                  backgroundColor: AppTheme.backgroundColor,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                ),
                              ),
                              Text('$_flexCount', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('ครั้ง', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const Text('จำนวนครั้งสะสมวันนี้', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('$_targetDays', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                              const Text(' / 30', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('วัน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 20),
                          const Text('ความคืบหน้าตามเป้าหมาย', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 📉 4. แถวแสดงความแม่นยำและระยะเวลาฝึกรวม
            Row(
              children: [
                Expanded(
                  child: _buildBottomMetricCard(Icons.track_changes_rounded, 'ความแม่นยำ', '${_accuracy.toStringAsFixed(0)} %'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBottomMetricCard(Icons.timelapse_rounded, 'ระยะเวลาฝึกรวม', '$_totalTrainingMin min'),
                ),
              ],
            ),
            
            // 💡 ปุ่มยิงเซนเซอร์จำลอง
            if (_isTraining) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _simulateGloveAction,
                icon: const Icon(Icons.bolt, color: Colors.orange),
                label: const Text('จำลองการกำ/เหยียดนิ้ว (เซนเซอร์ทำงาน)', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomMetricCard(IconData icon, String label, String value) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor.withOpacity(0.8), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}