import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/sign_in_screen.dart'; // 1. import เข้ามา
import 'package:intl/date_symbol_data_local.dart';

void main() {
  runApp(const MyApp());
  initializeDateFormatting('th_TH', null); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Mechanical Hand',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SignInScreen(), // 2. เปลี่ยนให้เปิดหน้า SignInScreen เป็นตัวแรก
    );
  }
}