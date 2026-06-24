import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('เข้าสู่ระบบสำเร็จ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ปิดป๊อปอัป
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
            child: const Text('ตกลง', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // เปลี่ยนเป็นชิดซ้ายตามสไตล์ SignUp
              children: [
                // 🔝 ส่วนของโลโก้แบบหรูหราลอยตัวกึ่งกลาง
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(Icons.back_hand_rounded, size: 64, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Smart Mechanical Hand',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'ระบบมือกลและแอปพลิเคชันเพื่อสุขภาพ',
                        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // 📝 1. ช่องกรอก Email
                _buildInputLabel('อีเมลผู้ใช้งาน (Email)'),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 14),
                  decoration: _buildInputDecoration('กรอกอีเมลของคุณ', Icons.email_outlined),
                ),
                const SizedBox(height: 24),

                // 📝 2. ช่องกรอก Password
                _buildInputLabel('รหัสผ่าน (Password)'),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontSize: 14),
                  decoration: _buildInputDecoration('กรอกรหัสผ่านของคุณ', Icons.lock_outline_rounded).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
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

                // 🔘 ปุ่มเข้าสู่ระบบแถวยาวโค้งมนระนาบเดียวกันกับหน้า SignUp
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // เปลี่ยนเป็น 16 ให้รับเข้าเซ็ต
                      elevation: 0,
                    ),
                    onPressed: _handleMockSignIn,
                    child: const Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ส่วนสลับย้ายไปสมัครสมาชิก
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('ยังไม่มีบัญชีใช้งาน? ', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        'สมัครสมาชิก',
                        style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper สร้างป้าย Label เหนือช่องกรอกดึงดีไซน์เข้าคู่ SignUp
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
      ),
    );
  }

  // Helper คุมความสวยงามของกรอบและรูปทรงกล่องกรอกให้ถอดแบบเดียวกันเป๊ะๆ
  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
    );
  }
}