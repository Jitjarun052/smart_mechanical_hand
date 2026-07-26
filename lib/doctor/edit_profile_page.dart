import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import '../api/auth_service.dart';
import '../api/api_config.dart';

class EditProfilePage extends StatefulWidget {
  final String? doctorToken; // 🔑 รับ Token เพื่อดึงและบันทึกข้อมูลหมอจริง
  const EditProfilePage({super.key, this.doctorToken});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // 📝 Controller รับค่าข้อมูลคุณหมอ
  late TextEditingController _nameController;
  late TextEditingController _hospitalController;
  late TextEditingController _doctorLicenseController;
  late TextEditingController _emailController;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _hospitalController = TextEditingController();
    _doctorLicenseController = TextEditingController();
    _emailController = TextEditingController();

    _fetchDoctorProfile();
  }

  // 📡 ดึงข้อมูลโปรไฟล์หมอปัจจุบันจาก API
  Future<void> _fetchDoctorProfile() async {
    if (widget.doctorToken == null || widget.doctorToken!.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final meResult = await AuthService.getMe(widget.doctorToken!);
      if (meResult['success'] == true && meResult['role'] == 'doctor') {
        final doc = meResult['user'];
        setState(() {
          _nameController.text = doc['name'] ?? '';
          _hospitalController.text = doc['hospital_name'] ?? '';
          _doctorLicenseController.text = doc['doctor_code'] ?? '';
          _emailController.text = doc['email'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching doctor profile: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // 💾 ยิง API บันทึกการเปลี่ยนแปลงข้อมูลลง MySQL
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.doctorToken == null || widget.doctorToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ ไม่พบสิทธิ์สำหรับบันทึกข้อมูล')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/doctor/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.doctorToken}',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'hospital_name': _hospitalController.text.trim(),
          'doctor_code': _doctorLicenseController.text.trim(),
          'email': _emailController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (mounted) {
        setState(() => _isSaving = false);

        if (response.statusCode == 200 && data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('💾 บันทึกการเปลี่ยนแปลงโปรไฟล์เรียบร้อย...')),
          );
          Navigator.pop(context, true); // ส่งค่า true กลับไปให้หน้าเดิม Reload
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ ${data['error'] ?? "บันทึกข้อมูลไม่สำเร็จ"}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hospitalController.dispose();
    _doctorLicenseController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'แก้ไขข้อมูลโปรไฟล์',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👨‍⚕️ ส่วนรูปอวาตาร์คุณหมอตรงกลาง
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: const Icon(Icons.medical_information_rounded, size: 50, color: AppTheme.primaryColor),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 🏷️ กล่องกรอก: ชื่อ-นามสกุล แพทย์
                    _buildInputLabel('ชื่อ - นามสกุล แพทย์'),
                    _buildProfileTextField(
                      controller: _nameController,
                      hintText: 'กรอกชื่อและนามสกุลของคุณ',
                      icon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 20),

                    // 🏷️ กล่องกรอก: โรงพยาบาล / ต้นสังกัด
                    _buildInputLabel('โรงพยาบาล / คลินิกต้นสังกัด'),
                    _buildProfileTextField(
                      controller: _hospitalController,
                      hintText: 'กรอกชื่อโรงพยาบาลต้นสังกัด',
                      icon: Icons.local_hospital_rounded,
                    ),
                    const SizedBox(height: 20),

                    // 🏷️ กล่องกรอก: เลขที่ใบประกอบวิชาชีพ (รบ.) / รหัสแพทย์
                    _buildInputLabel('เลขที่ใบประกอบวิชาชีพ / รหัสแพทย์'),
                    _buildProfileTextField(
                      controller: _doctorLicenseController,
                      hintText: 'ตัวอย่าง: DOC-99X',
                      icon: Icons.badge_rounded,
                    ),
                    const SizedBox(height: 20),

                    // 🏷️ กล่องกรอก: อีเมลติดต่อ
                    _buildInputLabel('อีเมลติดต่อ (Email)'),
                    _buildProfileTextField(
                      controller: _emailController,
                      hintText: 'example@gmail.com',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 40),

                    // 💾 ปุ่มบันทึกข้อมูล
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'บันทึกข้อมูล',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
      child: Text(
        labelText,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
      ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '❌ จำเป็นต้องกรอกข้อมูลช่องนี้ครับ';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withOpacity(0.12))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.red.shade200)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
      ),
    );
  }
}