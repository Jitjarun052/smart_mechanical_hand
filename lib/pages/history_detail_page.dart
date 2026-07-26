import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> historyData;

  const HistoryDetailPage({super.key, required this.historyData});

  @override
  Widget build(BuildContext context) {
    // 🛠️ ดึงพารามิเตอร์จริงจากตาราง history
    final int count = historyData['count'] ?? 0;
    final int duration = historyData['duration'] ?? 0;
    final int accuracy = (historyData['accuracy'] as num? ?? 0).round();
    final double maxForce = (historyData['max_force'] as num? ?? 0.0).toDouble();
    final double speed = (historyData['speed'] as num? ?? 0.0).toDouble();
    final double wristAngle = (historyData['wrist_angle'] as num? ?? 0.0).toDouble();

    // ค่าทั้ง 5 นิ้ว
    final int thumb = historyData['finger_thumb'] ?? 0;
    final int indexFinger = historyData['finger_index'] ?? 0;
    final int middle = historyData['finger_middle'] ?? 0;
    final int ring = historyData['finger_ring'] ?? 0;
    final int pinky = historyData['finger_pinky'] ?? 0;

    final String rawDate = historyData['created_at']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'รายละเอียดการฝึกซ้อม',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟠 1. Header Card สไตล์แอปสุขภาพ (ส้มไล่เฉด)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.back_hand_rounded, color: Colors.white, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            '$count',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const Text('จำนวนครั้ง (รอบ)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      Container(width: 1, height: 60, color: Colors.white24),
                      Column(
                        children: [
                          const Icon(Icons.timer_rounded, color: Colors.white, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            '$duration',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const Text('ระยะเวลา (วินาที)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('🎯 ความแม่นยำ: $accuracy%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('💪 แรงบีบสูงสุด: $maxForce N', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('สถิติมุมมองระดับลึก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 14),

            // 📊 2. Grid Dashboard 4 กล่องสไตล์ในรูป
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
              children: [
                _buildHealthGridCard(
                  title: 'ข้อมือ (Wrist)',
                  value: '$wristAngle°',
                  subtitle: 'องศาการกระดกข้อมือ',
                  icon: Icons.accessible_rounded,
                  color: Colors.blue.shade600,
                ),
                _buildHealthGridCard(
                  title: 'ความเร็วฝึก',
                  value: '$speed',
                  subtitle: 'รอบ / นาที',
                  icon: Icons.speed_rounded,
                  color: Colors.teal.shade600,
                ),
                _buildHealthGridCard(
                  title: 'แรงบีบสูงสุด',
                  value: '$maxForce',
                  subtitle: 'นิวตัน (N)',
                  icon: Icons.fitness_center_rounded,
                  color: Colors.purple.shade600,
                ),
                _buildHealthGridCard(
                  title: 'ความแม่นยำ',
                  value: '$accuracy%',
                  subtitle: 'คะแนนองศาเป้าหมาย',
                  icon: Icons.track_changes_rounded,
                  color: Colors.orange.shade700,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🖐️ 3. การ์ดแสดงผลสถิติ 5 นิ้วมือ
            const Text('สถิติการงอนิ้วมือ (ทั้ง 5 นิ้ว)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildFingerProgress('นิ้วหัวแม่มือ (Thumb)', thumb, Colors.redAccent),
                  _buildFingerProgress('นิ้วชี้ (Index)', indexFinger, Colors.orangeAccent),
                  _buildFingerProgress('นิ้วกลาง (Middle)', middle, Colors.amber.shade700),
                  _buildFingerProgress('นิ้วนาง (Ring)', ring, Colors.green),
                  _buildFingerProgress('นิ้วก้อย (Pinky)', pinky, Colors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthGridCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              )
            ],
          ),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildFingerProgress(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text('$value°', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (value / 180).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          )
        ],
      ),
    );
  }
}