import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// โครงสร้างข้อมูลปุ่มแต่ละปุ่ม
class BarButtonData {
  final IconData icon;
  final String label;
  const BarButtonData({required this.icon, required this.label});
}

class MainBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // 🎯 ก้อนข้อมูลปุ่มที่เราจะเอาไว้ลูป (ขยับขยายเพิ่ม-ลดปุ่มตรงนี้ได้เลย)
  static const List<BarButtonData> _buttonItems = [
    BarButtonData(icon: Icons.home_rounded, label: 'หน้าหลัก'),
    BarButtonData(icon: Icons.bar_chart_rounded, label: 'ประวัติฝึก'),
    BarButtonData(icon: Icons.settings_rounded, label: 'ตั้งค่า'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppTheme.backgroundCream,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 🚀 เริ่มต้นการลูปเอาข้อมูลปุ่มมาสร้างเป็น UI ปุ่มด้านล่างหน้าจอ
          for (int i = 0; i < _buttonItems.length; i++) ...[
            _buildCustomButton(
              index: i,
              isActive: currentIndex == i,
              data: _buttonItems[i],
            ),
          ]
        ],
      ),
    );
  }

  // 🛠️ ฟังก์ชันสร้างตัว "Custom Button" ย่อยแต่ละปุ่ม
  Widget _buildCustomButton({
    required int index,
    required bool isActive,
    required BarButtonData data,
  }) {
    final activeColor = AppTheme.primaryColor;
    final inactiveColor = AppTheme.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: activeColor.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ส่วนของไอคอน (ถ้า Active จะขยายใหญ่ขึ้นนิดนึงให้ดูมีมิติ)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                data.icon,
                color: isActive ? activeColor : inactiveColor,
                size: isActive ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            // ส่วนของตัวอักษรใต้ปุ่ม
            Text(
              data.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}