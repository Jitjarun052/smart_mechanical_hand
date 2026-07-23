import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ResetPasswordStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String userName;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const ResetPasswordStep({
    super.key,
    required this.formKey,
    required this.userName,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<ResetPasswordStep> createState() => _ResetPasswordStepState();
}

class _ResetPasswordStepState extends State<ResetPasswordStep> {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(Icons.lock_reset_rounded, size: 44, color: Colors.green),
            ),
          ),
          const SizedBox(height: 24),
          const Text('ตั้งรหัสผ่านใหม่ ✨', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Text('สวัสดีคุณ ${widget.userName}! กรุณากำหนดรหัสผ่านใหม่ของคุณ', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 32),

          _buildInputLabel('รหัสผ่านใหม่ (New Password)'),
          TextFormField(
            controller: widget.newPasswordController,
            obscureText: _isPasswordObscured,
            style: const TextStyle(fontSize: 14),
            decoration: _buildInputDecoration('กำหนดรหัสผ่านใหม่ 6 ตัวขึ้นไป', Icons.lock_outline_rounded).copyWith(
              suffixIcon: IconButton(
                icon: Icon(_isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20),
                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
              ),
            ),
            validator: (v) => v == null || v.length < 6 ? 'รหัสผ่านต้องยาวอย่างน้อย 6 ตัวอักษร' : null,
          ),
          const SizedBox(height: 20),

          _buildInputLabel('ยืนยันรหัสผ่านใหม่อีกครั้ง'),
          TextFormField(
            controller: widget.confirmPasswordController,
            obscureText: _isConfirmPasswordObscured,
            style: const TextStyle(fontSize: 14),
            decoration: _buildInputDecoration('กรอกรหัสผ่านใหม่อีกครั้ง', Icons.lock_clock_outlined).copyWith(
              suffixIcon: IconButton(
                icon: Icon(_isConfirmPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20),
                onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
              ),
            ),
            validator: (v) => v != widget.newPasswordController.text ? 'รหัสผ่านไม่ตรงกัน' : null,
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
              onPressed: widget.isLoading ? null : widget.onSubmit,
              child: widget.isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('บันทึกรหัสผ่านใหม่', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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