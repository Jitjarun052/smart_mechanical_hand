import 'package:flutter/material.dart';

class AppTheme {
  // 🎯 การตั้งชื่อแบบ Semantic (เป็นกลางตามหน้าที่ของสี)
  static const Color primaryColor = Color(0xFFD35400);   // สีหลักของแอป (ปุ่มหลัก, ไฮไลท์)
  static const Color backgroundColor = Color(0xFFFAF6F0); // สีพื้นหลังของแอป
  static const Color textPrimary = Color(0xFF3E2723);     // สีตัวอักษรหลัก (หัวข้อ, ข้อความสำคัญ)
  static const Color textSecondary = Color(0xFF8D6E63);   // สีตัวอักษรรอง (คำอธิบายใต้ภาพ, Hint Text)
  static const Color cardColor = Colors.white;            // สีพื้นหลังของการ์ดหรือกล่องข้อความ

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        surface: backgroundColor,
        onPrimary: Colors.white, 
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        color: cardColor, 
      ),
    );
  }
}