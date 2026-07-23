import 'dart:io'; // 👈 นำเข้า File
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:flutter/foundation.dart';

class Step1PersonalForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Uint8List? selectedImageBytes; // 📸 เปลี่ยนมารับไฟล์จริง (File?)
  final VoidCallback onPickImage;
  final bool acceptTerms;
  final ValueChanged<bool> onAcceptTermsChanged;
  final VoidCallback onNext;

  const Step1PersonalForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.selectedImageBytes,
    required this.onPickImage,
    required this.acceptTerms,
    required this.onAcceptTermsChanged,
    required this.onNext,
  });

  @override
  State<Step1PersonalForm> createState() => _Step1PersonalFormState();
}

class _Step1PersonalFormState extends State<Step1PersonalForm> {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('สร้างบัญชีใหม่ 🔐', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            const Text('ขั้นตอนที่ 1: กรอกข้อมูลส่วนตัวเพื่อเปิดใช้งานระบบ', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),

            // 📸 ส่วนแสดง/เลือกรูปภาพจริงจากแกลเลอรี
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    backgroundImage: widget.selectedImageBytes != null 
                        ? MemoryImage(widget.selectedImageBytes!) // 👈 ใช้ MemoryImage แสดงผลภาพบน Web ได้ทันที!
                        : null,
                    child: widget.selectedImageBytes == null
                        ? const Icon(Icons.person_rounded, size: 50, color: AppTheme.primaryColor)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: widget.onPickImage, // 👈 กดแล้วเปิดแกลเลอรีจริง
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildInputLabel('ชื่อ - นามสกุลผู้ป่วย'),
            TextFormField(
              controller: widget.nameController,
              style: const TextStyle(fontSize: 14),
              decoration: _buildDecoration('กรอกชื่อและนามสกุลของคุณ', Icons.person_outline_rounded),
              validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกชื่อ-นามสกุล' : null,
            ),
            const SizedBox(height: 18),

            _buildInputLabel('อีเมลผู้ใช้งาน'),
            TextFormField(
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 14),
              decoration: _buildDecoration('example@mail.com', Icons.email_outlined),
              validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกอีเมล' : null,
            ),
            const SizedBox(height: 18),

            _buildInputLabel('รหัสผ่าน (Password)'),
            TextFormField(
              controller: widget.passwordController,
              obscureText: _isPasswordObscured,
              style: const TextStyle(fontSize: 14),
              decoration: _buildDecoration('กำหนดรหัสผ่าน 6 ตัวขึ้นไป', Icons.lock_outline_rounded).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: Colors.grey),
                  onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                ),
              ),
              validator: (v) => v == null || v.length < 6 ? 'รหัสผ่านต้องยาว 6 ตัวขึ้นไป' : null,
            ),
            const SizedBox(height: 18),

            _buildInputLabel('ยืนยันรหัสผ่านอีกครั้ง'),
            TextFormField(
              controller: widget.confirmPasswordController,
              obscureText: _isConfirmPasswordObscured,
              style: const TextStyle(fontSize: 14),
              decoration: _buildDecoration('กรอกรหัสผ่านให้ตรงกัน', Icons.lock_clock_outlined).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: Colors.grey),
                  onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                ),
              ),
              validator: (v) => v != widget.passwordController.text ? 'รหัสผ่านไม่ตรงกัน' : null,
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                SizedBox(
                  width: 22, height: 22,
                  child: Checkbox(
                    value: widget.acceptTerms,
                    activeColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (v) => widget.onAcceptTermsChanged(v ?? false),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('ฉันยินยอมให้ระบบจัดเก็บสถิติการฝึกเพื่อการรักษา', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ),
              ],
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                onPressed: widget.onNext,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ขั้นตอนถัดไป ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
    child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
  );

  InputDecoration _buildDecoration(String hint, IconData icon) => InputDecoration(
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