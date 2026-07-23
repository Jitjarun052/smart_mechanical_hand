import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class VerifyIdentityStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const VerifyIdentityStep({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.phoneController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_search_rounded, size: 44, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          const Text('ลืมรหัสผ่าน 🔑', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          const Text('ขั้นตอนที่ 1/2: ยืนยันตัวตนด้วยข้อมูลที่เคยลงทะเบียนไว้', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 32),

          _buildInputLabel('อีเมลผู้ใช้งาน (Email)'),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 14),
            decoration: _buildInputDecoration('กรอกอีเมลของคุณ', Icons.email_outlined),
            validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกอีเมล' : null,
          ),
          const SizedBox(height: 20),

          _buildInputLabel('เบอร์โทรศัพท์ติดต่อ / ฉุกเฉิน'),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 14),
            decoration: _buildInputDecoration('กรอกเบอร์โทรศัพท์ที่เคยลงทะเบียน', Icons.phone_outlined),
            validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกเบอร์โทรศัพท์' : null,
          ),
          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: isLoading ? null : onSubmit,
              child: isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('ตรวจสอบข้อมูล', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
    child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
  );

  InputDecoration _buildInputDecoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 13),
    prefixIcon: Icon(icon, color: Colors.grey, size: 20),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
  );
}