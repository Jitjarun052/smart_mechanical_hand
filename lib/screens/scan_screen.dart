import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 240.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onMockScanSuccess() {
    String mockedSerialNumber = "Glove-2569-SMART88"; 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('⚡️ ตรวจพบอุปกรณ์: $mockedSerialNumber')),
    );
    Navigator.pop(context, mockedSerialNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const Text('สแกน QR Code อุปกรณ์', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 40), 
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _laserAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _laserAnimation.value,
                        left: 15,
                        right: 15,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.8), blurRadius: 8, spreadRadius: 2)],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('จัดให้รหัส QR Code อยู่ในกรอบสี่เหลี่ยม', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _onMockScanSuccess,
                  icon: const Icon(Icons.flash_on_rounded, color: Colors.amber),
                  label: const Text('จำลองการสแกนสำเร็จ (ตรวจพบบอร์ด)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}