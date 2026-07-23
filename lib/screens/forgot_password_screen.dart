import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/forgot_password/verify_identity_step.dart';
import '../widgets/forgot_password/reset_password_step.dart';
import '../widgets/forgot_password/forgot_password_dialogs.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1;
  int? _verifiedUserId;
  String? _verifiedName;

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  // 🔍 Step 1: ยืนยันข้อมูลผู้ใช้
  Future<void> _handleVerifyIdentity() async {
    if (!_formKeyStep1.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.verifyIdentity(
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ForgotPasswordDialogs.showConfirmIdentityDialog(
        context: context,
        userName: result['firstname'] ?? 'ผู้ใช้งาน',
        onConfirm: () {
          setState(() {
            _verifiedUserId = result['userId'];
            _verifiedName = result['firstname'];
            _step = 2; // 🚀 วาร์ปไป Step 2
          });
        },
      );
    } else {
      ForgotPasswordDialogs.showNotFoundDialog(
        context,
        result['message'] ?? 'ไม่พบข้อมูลผู้ใช้งานในระบบ',
      );
    }
  }

  // 🔑 Step 2: ตั้งรหัสผ่านใหม่
  Future<void> _handleResetPassword() async {
    if (!_formKeyStep2.currentState!.validate()) return;
    if (_verifiedUserId == null) return;

    setState(() => _isLoading = true);

    final result = await AuthService.resetPassword(
      userId: _verifiedUserId!,
      newPassword: _newPasswordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ForgotPasswordDialogs.showSuccessDialog(context, () {
        Navigator.pop(context); // ปิด Dialog
        Navigator.pop(context); // ย้อนกลับไปหน้า SignIn
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'เกิดข้อผิดพลาดในการตั้งรหัสผ่านใหม่'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () {
            if (_step == 2) {
              setState(() => _step = 1);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _step == 1
                ? VerifyIdentityStep(
                    formKey: _formKeyStep1,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    isLoading: _isLoading,
                    onSubmit: _handleVerifyIdentity,
                  )
                : ResetPasswordStep(
                    formKey: _formKeyStep2,
                    userName: _verifiedName ?? 'ผู้ใช้งาน',
                    newPasswordController: _newPasswordController,
                    confirmPasswordController: _confirmPasswordController,
                    isLoading: _isLoading,
                    onSubmit: _handleResetPassword,
                  ),
          ),
        ),
      ),
    );
  }
}