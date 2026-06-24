import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SpeedSettingPage extends StatefulWidget {
  const SpeedSettingPage({super.key});

  @override
  State<SpeedSettingPage> createState() => _SpeedSettingPageState();
}

class _SpeedSettingPageState extends State<SpeedSettingPage> {
  double _currentSpeed = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('ตั้งค่าความเร็วมือกล', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.speed_rounded, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text('ปรับความเร็วในการงอ-เหยียดนิ้วมือกล', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Slider(
              value: _currentSpeed,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              activeColor: Colors.orange,
              onChanged: (val) => setState(() => _currentSpeed = val),
            ),
            Text('ระดับความเร็วปัจจุบัน: ${_currentSpeed.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
          ],
        ),
      ),
    );
  }
}