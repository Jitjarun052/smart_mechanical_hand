import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../api/history_service.dart';
import '../api/device_service.dart';
import './notification_page.dart';

class TrainingPage extends StatefulWidget {
  final int userId;
  final int deviceId;

  const TrainingPage({
    super.key, 
    required this.userId,   // 👈 บังคับส่ง userId จริงมา
    required this.deviceId, // 👈 บังคับส่ง deviceId จริงมา
  });

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  // ⏱️ ตัวแปรระบบเวลาและสถานะ
  bool _isTraining = false;
  Timer? _liveTimer;      // Timer สำหรับดึงข้อมูลสด (Live Stream)
  Timer? _stopwatchTimer; // Timer สำหรับนับเวลาหน้าจอ
  int _secondsElapsed = 0;

  // 📊 ข้อมูลสถิติจริงจาก DB & IoT
  int _flexCount = 0; 
  int _targetDays = 5; 
  double _accuracy = 0.0; 
  int _totalTrainingMin = 0; 
  String _deviceStatus = 'สแตนด์บาย';

  @override
  void initState() {
    super.initState();
    _fetchTodaySummary(); // ดึงประวัติของวันนี้มาโชว์ตอนเปิดหน้าจอครั้งแรก
    _startLiveSync();     // เริ่มวงรอบดึงข้อมูล Live จาก IoT
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _stopwatchTimer?.cancel();
    super.dispose();
  }

  // 📡 1. [แก้ไข ✨] ดึงประวัติภาพรวมวันนี้ผ่าน HistoryService
  Future<void> _fetchTodaySummary() async {
    try {
      final historyList = await HistoryService.getHistoryByUserId(widget.userId.toString());
      
      if (historyList.isNotEmpty && mounted) {
        int totalCount = 0;
        int totalDurationSec = 0;
        double sumAccuracy = 0.0;

        for (var item in historyList) {
          totalCount += (item['count'] as num? ?? 0).toInt();
          totalDurationSec += (item['duration'] as num? ?? 0).toInt();
          sumAccuracy += (item['accuracy'] as num? ?? 0).toDouble();
        }

        setState(() {
          _flexCount = totalCount;
          _totalTrainingMin = (totalDurationSec / 60).round();
          _accuracy = historyList.isNotEmpty ? (sumAccuracy / historyList.length) : 0.0;
        });
      }
    } catch (e) {
      debugPrint('Fetch Summary Error: $e');
    }
  }

  // 🔄 2. [แก้ไข ✨] ดึงข้อมูลสดจาก IoT ผ่าน DeviceService
  void _startLiveSync() {
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final statusData = await DeviceService.getDeviceStatus(widget.deviceId);
        if (statusData != null && mounted) {
          bool isIoTActive = statusData['is_training'] ?? false;

          // ซิงค์สเตทกับปุ่มที่ตัวถุงมือ Smart Glove อัตโนมัติ
          if (isIoTActive != _isTraining) {
            setState(() {
              _isTraining = isIoTActive;
              if (_isTraining) {
                _startLocalTimer();
              } else {
                _stopLocalTimer();
                _fetchTodaySummary();
              }
            });
          }

          if (_isTraining && statusData['live_count'] != null) {
            setState(() {
              _flexCount = statusData['live_count'];
              _deviceStatus = 'กำลังทำงาน';
            });
          } else {
            setState(() {
              _deviceStatus = _isTraining ? 'กำลังทำงาน' : 'สแตนด์บาย';
            });
          }
        }
      } catch (_) {}
    });
  }
// ใช้ตอนมีอุปกรณื IoT จริง แต่ตอนนี้ยังไม่มีอุปกรณ์จริง เลยจำลองการนับรอบและความแม่นยำเอง
  // 🚀 3. [แก้ไข ✨] สั่งงานเริ่ม/หยุดฝึกไปยัง ESP32 ผ่าน DeviceService
  // Future<void> _toggleTraining() async {
  //   bool nextState = !_isTraining;
  //   String command = nextState ? 'START' : 'STOP';

  //   bool success = await DeviceService.sendControlCommand(widget.deviceId, command);

  //   if (success && mounted) {
  //     setState(() {
  //       _isTraining = nextState;
  //       if (_isTraining) {
  //         _startLocalTimer();
  //       } else {
  //         _stopLocalTimer();
  //         _fetchTodaySummary();
  //       }
  //     });
  //   } else if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('ไม่สามารถเชื่อมต่อกับอุปกรณ์ Smart Glove ได้')),
  //     );
  //   }
  // }

  
  // void _startLocalTimer() {
  //   _secondsElapsed = 0;
  //   _stopwatchTimer?.cancel();
  //   _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (t) {
  //     setState(() => _secondsElapsed++);
  //   });
  // }


  //แบบจำลองข้อมูลการนับรอบและความแม่นยำจาก IoT (ESP32) โดยใช้ Timer

  // 🚀 [แก้ไข ✨] สั่งงานเริ่ม/หยุดฝึกซ้อม
  Future<void> _toggleTraining() async {
    setState(() {
      _isTraining = !_isTraining;
      if (_isTraining) {
        _startLocalTimer(); // เริ่มจับเวลา + เริ่มสุ่มนับรอบจำลองอัตโนมัติ
      } else {
        _stopLocalTimer();  // หยุดจับเวลา
        _fetchTodaySummary(); // รีเฟรชสถิติสรุป
      }
    });

    // 📡 พยายามยิงสั่งงาน ESP32 ขนานกันไป (ถ้ามีอุปกรณ์จริงเชื่อมต่ออยู่)
    try {
      String command = _isTraining ? 'START' : 'STOP';
      await DeviceService.sendControlCommand(widget.deviceId, command);
    } catch (e) {
      // ซ่อน Error ไว้ช่วงพัฒนา จะได้ไม่ขึ้น SnackBar กวนใจตอนทดสอบจำลองครับ
      debugPrint('IoT Command Offline Mode: $e');
    }
  }
  void _startLocalTimer() {
    _secondsElapsed = 0;
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;

        // 💡 [เพิ่มลอจิกจำลอง]: ทุกๆ 6 วินาที = มือกำ/เหยียด 1 รอบ
        if (_secondsElapsed % 6 == 0) {
          _flexCount++; // เพิ่มจำนวนรอบอัตโนมัติ
          _accuracy = 85.0 + (Random().nextDouble() * 12); // สุ่มความแม่นยำ 85-97%
        }
      });
    });
  }

  void _stopLocalTimer() {
    _stopwatchTimer?.cancel();
    setState(() => _secondsElapsed = 0);
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
            // 🤖 การ์ดควบคุมและจับเวลาฝึก
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            Text(_deviceStatus, style: TextStyle(fontSize: 12, color: _isTraining ? Colors.green : AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
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

            // 📊 แสดงจำนวนครั้งสะสมวันนี้
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

            // 📉 สรุปความแม่นยำและเวลาสะสม
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