import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleMockSignIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    if (email == 'admin@health.com' && password == '123456') {
      _showLoginSuccess('ยินดีต้อนรับคุณหมอ/เจ้าหน้าที่ (นักกายภาพบำบัด)');
    } else if (email == 'patient@health.com' && password == '123456') {
      _showLoginSuccess('ยินดีต้อนรับผู้ป่วย เข้าสู่ระบบบันทึกผลมือกล');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อีเมลหรือรหัสผ่านจำลองไม่ถูกต้อง (ลองใช้อีเมล patient@health.com รหัส 123456)')),
      );
    }
  }

  void _showLoginSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('เข้าสู่ระบบสำเร็จ (Mock)'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // 🛠️ ใช้ชื่อสากลแล้ว
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.back_hand_rounded, size: 80, color: AppTheme.primaryColor), // 🛠️ ใช้ชื่อสากลแล้ว
              const SizedBox(height: 16),
              const Text(
                'Smart Mechanical Hand',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), // 🛠️ ใช้ชื่อสากลแล้ว
              ),
              const SizedBox(height: 8),
              const Text(
                'ระบบมือกลและแอปพลิเคชันเพื่อสุขภาพ',
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondary), // 🛠️ ใช้ชื่อสากลแล้ว
              ),
              const SizedBox(height: 48),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'กรอกอีเมลของคุณ',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'กรอกรหัสผ่านของคุณ',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor, // 🛠️ ใช้ชื่อสากลแล้ว
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  onPressed: _handleMockSignIn,
                  child: const Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("ยังไม่มีบัญชีใช้งาน? "),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'สมัครสมาชิก',
                      style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold), // 🛠️ ใช้ชื่อสากลแล้ว
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}