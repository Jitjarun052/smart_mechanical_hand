import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import '../api/history_service.dart';
import '../api/device_service.dart';
import '../api/api_config.dart';
import '../widgets/video_train/glove_video_widget.dart';

class TrainingPage extends StatefulWidget {
  final int userId;
  final int deviceId;

  const TrainingPage({
    super.key,
    required this.userId,
    required this.deviceId,
  });

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  bool _isTraining = false;
  Timer? _liveTimer;
  Timer? _stopwatchTimer;
  int _secondsElapsed = 0;

  int _flexCount = 0; // รอบจริงที่รับมาจาก ESP32
  int _targetCount = 10; // รอบเป้าหมายต่อเซ็ต (ดึงจากหมอ)
  int _targetSet = 3; // จำนวนเซ็ตเป้าหมาย (ดึงจากหมอ)
  int _currentSet = 1; // เซ็ตปัจจุบันที่กำลังฝึก

  double _accuracy = 0.0;
  int _totalTrainingMin = 0;
  
  String _deviceName = 'ถุงมืออัจฉริยะ';
  String _deviceStatus = 'กำลังตรวจสอบสถานะ...';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔍 TrainingPage loaded with userId: ${widget.userId}, deviceId: ${widget.deviceId}');
    _fetchDeviceInfoAndSummary();
    _startLiveSync();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _stopwatchTimer?.cancel();
    super.dispose();
  }

  // 📡 1. ดึงเป้าหมายจากแพทย์ + ข้อมูลอุปกรณ์ + สรุปประวัติรวม
  Future<void> _fetchDeviceInfoAndSummary() async {
    try {
      final userRes = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (userRes.statusCode == 200) {
        final uData = jsonDecode(userRes.body);
        final userData = uData['user'] ?? uData['data'] ?? uData;
        if (userData != null && mounted) {
          setState(() {
            _targetCount = (userData['target_count'] as num?)?.toInt() ?? 10;
            _targetSet = (userData['target_set'] as num?)?.toInt() ?? 3;
          });
        }
      }

      final deviceData = await DeviceService.getDeviceByUserId(widget.userId);
      if (deviceData != null && mounted) {
        setState(() {
          _deviceName = deviceData['device_name'] ?? 'ถุงมืออัจฉริยะ Smart Glove';
        });
      }

      final historyList = await HistoryService.getHistoryByUserId(widget.userId.toString());
      if (historyList.isNotEmpty && mounted) {
        int totalDurationSec = 0;
        double sumAccuracy = 0.0;

        for (var item in historyList) {
          totalDurationSec += (item['duration'] as num? ?? 0).toInt();
          sumAccuracy += (item['accuracy'] as num? ?? 0).toDouble();
        }

        setState(() {
          _totalTrainingMin = (totalDurationSec / 60).round();
          _accuracy = sumAccuracy / historyList.length;
        });
      }
    } catch (e) {
      debugPrint('Fetch Training Info Error: $e');
    }
  }

  // 🔴 เมื่อกดปุ่ม "เริ่มต้น / หยุดการฝึก"
  Future<void> _toggleTraining() async {
    if (!_isConnected && !_isTraining) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ กรุณาเปิดเครื่องถุงมืออัจฉริยะ (ESP32) และรอให้ออนไลน์ก่อนเริ่มฝึก'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isTraining) {
      try {
        await DeviceService.sendControlCommand(widget.deviceId, 'PAUSE-APP');
      } catch (_) {}
      _showStopConfirmDialog();
    } else {
      try {
        await DeviceService.sendControlCommand(widget.deviceId, 'START-APP');
      } catch (e) {
        debugPrint('IoT Command Send Error: $e');
      }

      setState(() {
        _isTraining = true;
        _startLocalTimer(resetTime: _flexCount == 0);
      });
    }
  }

  // 📡 ซิงค์สเตตัสเรียลไทม์กับ Backend
  void _startLiveSync() {
    _liveTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      try {
        final statusData = await DeviceService.getDeviceStatus(widget.deviceId);
        
        if (mounted && statusData != null) {
          final dynamic rawOnline = statusData['is_online'];
          final bool onlineStatus = (rawOnline == true || rawOnline == 1 || rawOnline == 'true' || rawOnline == '1');

          String statusStr = statusData['training_status']?.toString().toUpperCase() ?? '';
          bool isIoTActive = statusStr.contains('START');
          int liveCountFromBackend = (statusData['live_count'] as num? ?? 0).toInt();

          if (!onlineStatus && _isTraining) {
            setState(() {
              _isTraining = false;
              _stopLocalTimer();
            });
          }

          if (isIoTActive != _isTraining && onlineStatus) {
            setState(() {
              _isTraining = isIoTActive;
              if (_isTraining) {
                _startLocalTimer(resetTime: false); 
              } else {
                _stopLocalTimer();
                _fetchDeviceInfoAndSummary();
              }
            });
          }

          setState(() {
            _isConnected = onlineStatus;
            _deviceStatus = !_isConnected 
                ? 'อุปกรณ์ออฟไลน์ (ปิดเครื่อง)' 
                : (_isTraining ? 'กำลังทำงาน' : 'พร้อมใช้งาน');

            if (_isTraining && _isConnected) {
              _flexCount = liveCountFromBackend;
              // 🟢 เมื่อจำนวนครั้งถึงเป้าหมายประจำเซ็ต
              if (_flexCount >= _targetCount) {
                _isTraining = false;
                _handleSetOrWorkoutComplete();
              }
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isConnected = false;
            _deviceStatus = 'ไม่สามารถเชื่อมต่ออุปกรณ์ได้';
          });
        }
      }
    });
  } 

  // 🔀 🟢 จัดการเมื่อทำครบเซ็ต -> สั่ง STOP-APP เพื่อบันทึก DB และล้างค่า ESP32 เป็น 0 ทันที
  Future<void> _handleSetOrWorkoutComplete() async {
    setState(() {
      _isTraining = false;
      _flexCount = 0;
    });
    _stopLocalTimer();

    // 🚀 ยิง STOP-APP เพื่อให้ ESP32 สั่ง sendDataToDatabase() และรีเซ็ต repCount = 0
    try {
      await DeviceService.sendControlCommand(widget.deviceId, 'STOP-APP');
    } catch (e) {
      debugPrint('Error sending STOP-APP on set complete: $e');
    }

    setState(() {
      _flexCount = 0;
      _secondsElapsed = 0;
    });

    _fetchDeviceInfoAndSummary(); // ดึงประวัติที่เพิ่งบันทึกมาอัปเดตสถิติ

    if (!mounted) return;
    if (_currentSet < _targetSet) {
      _showSetCompletedDialog(); // จบเซ็ตย่อย -> แจ้งเตือนและเตรียมเซ็ตถัดไป
    } else {
      _showAllSetsCompletedDialog(); // ครบทุกเซ็ต -> จบโปรแกรมฝึก
    }
  }

  // 🔔 1. Pop-up เมื่อจบเซ็ตย่อย (บันทึกเซ็ตนี้เรียบร้อย)
  void _showSetCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: Column(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10AC84), size: 52),
              const SizedBox(height: 10),
              Text(
                '🎉 บันทึกเซ็ตที่ $_currentSet เรียบร้อย!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ระบบบันทึกผลการฝึกเซ็ตที่ $_currentSet เข้าสู่ประวัติแล้ว\n(เหลืออีก ${_targetSet - _currentSet} เซ็ตตามเป้าหมายของแพทย์)',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // ปุ่มพักผ่อน 1 นาทีก่อนเริ่มเซ็ตใหม่
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10AC84),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showRestTimerDialog(isNextSet: true);
                  },
                  icon: const Icon(Icons.timer_rounded),
                  label: Text('พักมือ 1 นาที เพื่อเริ่มเซ็ตที่ ${_currentSet + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),

              // ปุ่มเริ่มเซ็ตถัดไปทันที
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _startNextSetImmediately();
                },
                child: Text('ไม่พัก เริ่มเซ็ตที่ ${_currentSet + 1} ทันที ➔', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🏆 2. Pop-up เมื่อฝึกครบทุกเซ็ตตามแผนแพทย์
  void _showAllSetsCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: Column(
            children: const [
              Icon(Icons.emoji_events_rounded, color: Color(0xFFFF9F43), size: 56),
              SizedBox(height: 12),
              Text(
                '🏆 ยอดเยี่ยมมาก!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'คุณบริหารมือครบทั้ง $_targetSet เซ็ต ($_targetCount ครั้ง/เซ็ต)\nและบันทึกประวัติการรักษาทั้งหมดเรียบร้อยแล้ว!',
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _isTraining = false;
                      _flexCount = 0; 
                      _currentSet = 1;
                      _secondsElapsed = 0;
                    });
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('เสร็จสิ้นการฝึก', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ⏱️ ตัวนับเวลาพักผ่อน
  void _showRestTimerDialog({bool isNextSet = false}) {
    int restSeconds = 60;
    Timer? restTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setRestState) {
            restTimer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (restSeconds > 1) {
                setRestState(() => restSeconds--);
              } else {
                t.cancel();
                Navigator.pop(context);
                if (isNextSet) {
                  _startNextSetImmediately();
                }
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.airline_seat_recline_extra_rounded, color: Colors.blue, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      isNextSet ? 'พักมือเตรียมเริ่มเซ็ตที่ ${_currentSet + 1}' : 'ช่วงเวลาพักผ่อนกล้ามเนื้อ',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text('ผ่อนคลายข้อมือและนิ้วมือชั่วคราว', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 20),
                    
                    Text(
                      '$restSeconds',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.blue),
                    ),
                    const Text('วินาที', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: AppTheme.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        onPressed: () {
                          restTimer?.cancel();
                          Navigator.pop(context);
                          if (isNextSet) {
                            _startNextSetImmediately();
                          }
                        },
                        child: const Text('ข้ามเวลาพัก & ลุยต่อทันที', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🚀 🟢 เริ่มเซ็ตถัดไป (นับครั้งเริ่มจาก 0 ใหม่)
  Future<void> _startNextSetImmediately() async {
    setState(() {
      _currentSet++;
      _flexCount = 0;
      _secondsElapsed = 0;
      _isTraining = true;
    });

    try {
      await DeviceService.sendControlCommand(widget.deviceId, 'START-APP');
    } catch (_) {}

    _startLocalTimer(resetTime: true);
  }

  // ❓ ยืนยันเมื่อกดหยุดกลางคัน
  void _showStopConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('หยุดการฝึก?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'คุณทำไปแล้ว $_flexCount / $_targetCount ครั้ง ในเซ็ตที่ $_currentSet/$_targetSet ต้องการหยุดและบันทึกผลเซ็ตนี้เลยหรือไม่?',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await DeviceService.sendControlCommand(widget.deviceId, 'START-APP');
                } catch (_) {}
                
                setState(() {
                  _isTraining = true;
                  _startLocalTimer(resetTime: false);
                });
              },
              child: const Text('ฝึกต่อ', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await DeviceService.sendControlCommand(widget.deviceId, 'STOP-APP');
                } catch (e) {
                  debugPrint('Send STOP-APP Error: $e');
                }

                setState(() {
                  _isTraining = false;
                  _flexCount = 0;
                  _currentSet = 1;
                  _secondsElapsed = 0; 
                  _stopLocalTimer();
                  _fetchDeviceInfoAndSummary();
                });
              },
              child: const Text('หยุด & บันทึกผล', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _startLocalTimer({bool resetTime = false}) {
    if (resetTime) _secondsElapsed = 0;
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsElapsed++);
    });
  }

  void _stopLocalTimer() => _stopwatchTimer?.cancel();

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('โหมดฝึกกายภาพ', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          children: [
            // 📡 1. แถบสถานะอุปกรณ์
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _isConnected ? const Color(0xFF10AC84).withOpacity(0.08) : Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isConnected ? const Color(0xFF10AC84).withOpacity(0.3) : Colors.red.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _isConnected ? const Color(0xFF10AC84) : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isConnected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_disabled_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'อุปกรณ์: $_deviceName',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                        ),
                        Text(
                          'สถานะ: $_deviceStatus',
                          style: TextStyle(
                            fontSize: 11,
                            color: _isConnected ? const Color(0xFF10AC84) : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isConnected)
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10AC84), size: 20),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🎯 2. แถบแสดงแผนการรักษาของแพทย์
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.medical_services_rounded, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    'แผนฝึกของแพทย์: เซ็ตที่ $_currentSet/$_targetSet (เป้าหมาย $_targetCount ครั้ง/เซ็ต)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🟢 วิดีโอแนะนำการฝึก
            SizedBox(
              height: 200,
              child: Center(
                child: GloveVideoWidget(isTraining: _isTraining),
              ),
            ),

            const Text(
              'ท่าบริหารงอ-เหยียดนิ้วมือ (Grip & Release)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 🟢 วงกลมคู่แสดงความคืบหน้า
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 145,
                  height: 145,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10AC84).withOpacity(0.05),
                    border: Border.all(color: const Color(0xFF10AC84), width: 3.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$_flexCount',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10AC84),
                            ),
                          ),
                          Text(
                            ' / $_targetCount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'ทำไปแล้ว / เป้าหมาย',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      Text(
                        'เซ็ตที่ $_currentSet จาก $_targetSet เซ็ต',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF10AC84), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 20),

                // ระยะเวลาฝึก
                Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.teal.shade300, width: 2.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(_secondsElapsed),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'ระยะเวลา',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const Text(
                        'นาที:วินาที',
                        style: TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ปุ่มเริ่มต้น/หยุดการฝึก
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTraining 
                      ? Colors.redAccent 
                      : (_isConnected ? const Color(0xFF10AC84) : Colors.grey.shade400),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                onPressed: _toggleTraining,
                icon: Icon(
                  _isTraining ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded, 
                  size: 28,
                ),
                label: Text(
                  _isTraining 
                      ? 'หยุดการฝึก' 
                      : (_isConnected ? 'เริ่มต้นการฝึก' : 'อุปกรณ์ออฟไลน์'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildBigMetricCard(
                    icon: Icons.track_changes_rounded,
                    title: 'ความแม่นยำเฉลี่ย',
                    value: '${_accuracy.toStringAsFixed(0)}%',
                    subtitle: 'ประสิทธิภาพการกำมือ',
                    iconColor: Colors.teal,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildBigMetricCard(
                    icon: Icons.access_time_filled_rounded,
                    title: 'เวลาสะสมวันนี้',
                    value: '$_totalTrainingMin นาที',
                    subtitle: 'รวมจากทุกเซสชัน',
                    iconColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBigMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}