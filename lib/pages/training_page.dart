import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../api/history_service.dart';
import '../api/device_service.dart';

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
  int _targetCount = 12; // รอบเป้าหมาย
  double _accuracy = 0.0;
  int _totalTrainingMin = 0;
  
  String _deviceName = 'ถุงมืออัจฉริยะ';
  String _deviceStatus = 'พร้อมใช้งาน';
  bool _isConnected = true; 

  @override
  void initState() {
    super.initState();
    debugPrint('🔍 TrainingPage loaded with userId: ${widget.userId}, deviceId: ${widget.deviceId}');
    _fetchDeviceInfoAndSummary();
    _startLiveSync(); // เริ่มซิงค์ข้อมูลกับ Backend/ESP32
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _stopwatchTimer?.cancel();
    super.dispose();
  }

  // 📡 1. ดึงข้อมูลอุปกรณ์และสรุปประวัติรวมจาก Database
  Future<void> _fetchDeviceInfoAndSummary() async {
    try {
      final deviceData = await DeviceService.getDeviceByUserId(widget.userId);
      if (deviceData != null && mounted) {
        setState(() {
          _deviceName = deviceData['device_name'] ?? 'ถุงมืออัจฉริยะ Smart Glove';
          _isConnected = true;
          _deviceStatus = _isTraining ? 'กำลังทำงาน' : 'พร้อมใช้งาน';
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
      debugPrint('Fetch Device Info Error: $e');
    }
  }

  // 🔴 1. เมื่อกดปุ่ม "เริ่มต้น / หยุดการฝึกซ้อม" บนหน้าจอหลัก
  Future<void> _toggleTraining() async {
    if (_isTraining) {
      // 🟢 สั่งพักเครื่องก่อนทันที เพื่อให้ลมหยุดเป่าขณะขึ้น Pop-up ถาม
      try {
        await DeviceService.sendControlCommand(widget.deviceId, 'PAUSE-APP');
      } catch (_) {}

      _showStopConfirmDialog();
    } else {
      // สั่งเริ่มฝึกใหม่ตั้งแต่รอบแรก
      try {
        await DeviceService.sendControlCommand(widget.deviceId, 'START-APP');
      } catch (e) {
        debugPrint('IoT Command Send Error: $e');
      }

      setState(() {
        _isTraining = true;
        _startLocalTimer(resetTime: true); // ล้างเวลาเป็น 0 เมื่อเริ่มฝึกใหม่
      });
    }
  }

  // 📡 ซิงค์สเตตัสเรียลไทม์กับ Backend
  void _startLiveSync() {
    _liveTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) async {
      try {
        final statusData = await DeviceService.getDeviceStatus(widget.deviceId);
        
        if (mounted && statusData != null) {
          String statusStr = statusData['training_status']?.toString().toUpperCase() ?? '';
          
          // 🟢 เช็กให้ครอบคลุม: ถ้ารับมาเป็น "START-APP" หรือ "START-IOT" ให้ถือว่ากำลังฝึกซ้อม!
          bool isIoTActive = statusStr.contains('START');
          int liveCountFromBackend = (statusData['live_count'] as num? ?? 0).toInt();

          // 🟢 เมื่อสเตตัสใน DB เปลี่ยนแปลง (เช่น เปิดจากปุ่มภายนอก หรือกดจากแอป)
          if (isIoTActive != _isTraining) {
            setState(() {
              _isTraining = isIoTActive;
              if (_isTraining) {
                _startLocalTimer(resetTime: false); 
              } else {
                _stopLocalTimer();
                _fetchDeviceInfoAndSummary(); // ดึงสรุปผล
              }
            });
          }

          setState(() {
            _isConnected = true;
            _deviceStatus = _isTraining ? 'กำลังทำงาน' : 'พร้อมใช้งาน';
            if (_isTraining) {
              _flexCount = liveCountFromBackend;
              if (_flexCount >= _targetCount) {
                _isTraining = false;
                _showGoalReachedDialog();
              }
            }
          });
        }
      } catch (e) {
        debugPrint('LiveSync Error: $e');
      }
    });
  }
  
  // ❓ Pop-up ถามยืนยันเมื่อกดหยุดฝึกซ้อมกลางคัน
  void _showStopConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('หยุดการฝึกซ้อม?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'คุณทำไปแล้ว $_flexCount / $_targetCount ครั้ง ต้องการหยุดและบันทึกผลการฝึกซ้อมตอนนี้เลยหรือไม่?',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            // 🟢 กรณีเลือก "ฝึกต่อ": ยิง START-APP เพื่อให้ ESP32 ลุยต่อจากรอบเดิม!
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await DeviceService.sendControlCommand(widget.deviceId, 'START-APP');
                } catch (_) {}
                
                setState(() {
                  _isTraining = true;
                  _startLocalTimer(resetTime: false); // นับเวลาต่อจากเดิม ไม่ reset เป็น 0
                });
              },
              child: const Text('ฝึกต่อ', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
            
            // 🔴 กรณีเลือก "หยุด & บันทึกผล": ยิง STOP-APP เพื่อบันทึก DB และล้างค่า
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

  // ⏱️ ยุบเหลือฟังก์ชันเดียว ควบคุมการ reset เวลาด้วย resetTime ( default = false )
  void _startLocalTimer({bool resetTime = false}) {
    if (resetTime) {
      _secondsElapsed = 0; // ล้างเวลาเป็น 0 เมื่อสั่งเริ่มเซสชันใหม่จริงๆ
    }
    
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _stopLocalTimer() {
    _stopwatchTimer?.cancel();
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  // 🏆 Pop-up เมื่อฝึกซ้อมครบตามเป้าหมาย (Goal Reached)
  void _showGoalReachedDialog() {
    _stopLocalTimer();
    
    // 🟢 สั่ง PAUSE-APP ไว้ชั่วคราว เพื่อหยุดลมระหว่างผู้ป่วยเลือกเมนู
    try {
      DeviceService.sendControlCommand(widget.deviceId, 'PAUSE-APP');
    } catch (_) {}

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
                '🎉 ยินดีด้วย! ครบเป้าหมายแล้ว',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'คุณบริหารมือครบ $_targetCount ครั้งตามที่ตั้งไว้เรียบร้อยแล้ว!',
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // 🟢 1. ปุ่ม "เสร็จสิ้น & บันทึกผล"
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
                  onPressed: () async {
                    Navigator.pop(context);
                    
                    // 🚀 ยิงสั่ง STOP-APP ไปที่ Backend/ESP32 เพื่อบันทึก DB และล้างค่าเป็น 0
                    try {
                      await DeviceService.sendControlCommand(widget.deviceId, 'STOP-APP');
                    } catch (e) {
                      debugPrint('Send STOP-APP Goal Error: $e');
                    }

                    setState(() {
                      _isTraining = false;
                      _flexCount = 0; 
                      _secondsElapsed = 0;
                    });
                    _fetchDeviceInfoAndSummary();
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('เสร็จสิ้น & บันทึกผล', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),

              // 🟢 2. ปุ่ม "พักผ่อน 1 นาที"
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10AC84),
                    side: const BorderSide(color: Color(0xFF10AC84), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showRestTimerDialog();
                  },
                  icon: const Icon(Icons.timer_rounded),
                  label: const Text('พักผ่อน 1 นาที (พักมือ)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),

              // 🟢 3. ปุ่ม "ฝึกต่ออีก 5 ครั้ง (+5)"
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); 
                  
                  // 🚀 ยิงสั่ง START-APP กลับไปเพื่อให้ ESP32 เริ่มเป่าลมต่อและนับรอบต่อจากเดิม
                  try {
                    await DeviceService.sendControlCommand(widget.deviceId, 'START-APP');
                  } catch (_) {}

                  setState(() {
                    _targetCount += 5;   
                    _isTraining = true;  
                  });

                  _startLocalTimer(resetTime: false); // นับเวลาต่อจากเดิม
                },
                child: const Text('ฝึกต่ออีก 5 ครั้ง (+5)', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      },
    );
  }

  void _showRestTimerDialog() {
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
                
                // 🟢 1. เมื่อพักผ่อนครบ 60 วินาที -> ยิงสั่ง START-APP เพื่อลุยต่ออีก 5 ครั้ง!
                try {
                  DeviceService.sendControlCommand(widget.deviceId, 'START-APP');
                } catch (e) {
                  debugPrint('Send START-APP Rest complete Error: $e');
                }

                setState(() {
                  _targetCount += 5;
                  _isTraining = true;
                });
                _startLocalTimer(resetTime: false); // นับเวลาต่อจากเดิม
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
                    const Text('ช่วงเวลาพักผ่อนกล้ามเนื้อ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        // 🔴 2. เมื่อกดปุ่ม "ข้ามพักผ่อน & พอแค่นี้" -> ยิงสั่ง STOP-APP จบการฝึกทันที!
                        onPressed: () async {
                          restTimer?.cancel();
                          Navigator.pop(context);
                          
                          try {
                            // 🟢 ยิง STOP-APP เพื่อเซฟ DB และล้างค่าใน ESP32
                            await DeviceService.sendControlCommand(widget.deviceId, 'STOP-APP');
                          } catch (e) {
                            debugPrint('Send STOP-APP Skip Rest Error: $e');
                          }

                          setState(() {
                            _isTraining = false;
                            _flexCount = 0;
                            _secondsElapsed = 0;
                          });
                          _stopLocalTimer();
                          _fetchDeviceInfoAndSummary();
                        },
                        child: const Text('ข้ามพักผ่อน & พอแค่นี้', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showTargetPickerBottomSheet() {
    int tempTarget = _targetCount;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'กำหนดเป้าหมายจำนวนครั้ง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ตั้งค่าจำนวนรอบการบริหารมือต่อเซสชันนี้',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: tempTarget > 1
                            ? () => setModalState(() => tempTarget--)
                            : null,
                        icon: const Icon(Icons.remove_rounded),
                        iconSize: 28,
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '$tempTarget',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10AC84),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ครั้ง',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton.filledTonal(
                        onPressed: () => setModalState(() => tempTarget++),
                        icon: const Icon(Icons.add_rounded),
                        iconSize: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10AC84),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _targetCount = tempTarget;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'บันทึกเป้าหมาย',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('โหมดฝึกซ้อมกายภาพ', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
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
            const SizedBox(height: 24),

            SizedBox(
              height: 180,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: _isTraining ? AppTheme.primaryColor.withOpacity(0.12) : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    boxShadow: _isTraining
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.25),
                              blurRadius: 20,
                              spreadRadius: 4,
                            )
                          ]
                        : [],
                  ),
                  child: Icon(
                    Icons.back_hand_rounded,
                    size: 90,
                    color: _isTraining ? AppTheme.primaryColor : Colors.grey.shade400,
                  ),
                ),
              ),
            ),

            const Text(
              'ท่าบริหารงอ-เหยียดนิ้วมือ (Grip & Release)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: _isTraining ? null : _showTargetPickerBottomSheet,
                  borderRadius: BorderRadius.circular(50),
                  child: _buildCircleMetric(
                    value: '$_targetCount',
                    label: 'เป้าหมาย',
                    unit: 'ครั้ง (แตะเปลี่ยน)',
                    color: const Color(0xFF10AC84),
                  ),
                ),
                _buildCircleMetric(
                  value: _formatTime(_secondsElapsed),
                  label: 'ระยะเวลา',
                  unit: 'นาที:วินาที',
                  color: const Color(0xFF10AC84),
                  isBig: true,
                ),
                _buildCircleMetric(
                  value: '$_flexCount',
                  label: 'ทำไปแล้ว',
                  unit: 'ครั้ง',
                  color: const Color(0xFF10AC84),
                ),
              ],
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTraining ? Colors.redAccent : const Color(0xFF10AC84),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                onPressed: _toggleTraining,
                icon: Icon(_isTraining ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded, size: 28),
                label: Text(
                  _isTraining ? 'หยุดการฝึกซ้อม' : 'เริ่มต้นการฝึกซ้อม',
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

  Widget _buildCircleMetric({
    required String value,
    required String label,
    required String unit,
    required Color color,
    bool isBig = false,
  }) {
    double size = isBig ? 105 : 85;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: isBig ? 4 : 3),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isBig ? 22 : 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
      ],
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