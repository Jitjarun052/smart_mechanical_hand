import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // 📝 ประกาศ Controller รับค่าข้อมูลคุณหมอ
  late TextEditingController _nameController;
  late TextEditingController _hospitalController;
  late TextEditingController _doctorLicenseController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // ม็อคค่าเริ่มต้นล็อกไว้ตามสเตทหน้าแรก
    _nameController = TextEditingController(text: 'นพ. สมชาย รักดี');
    _hospitalController = TextEditingController(text: 'โรงพยาบาลเชียงรายประชานุเคราะห์');
    _doctorLicenseController = TextEditingController(text: 'วท. 99842');
    _emailController = TextEditingController(text: 'somchai.doctor@gmail.com');
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
      body: SingleChildScrollView(
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

              // 🏷️ กล่องกรอก: เลขที่ใบประกอบวิชาชีพ (รบ.)
              _buildInputLabel('เลขที่ใบประกอบวิชาชีพเวชกรรม (รบ.)'),
              _buildProfileTextField(
                controller: _doctorLicenseController,
                hintText: 'ตัวอย่าง: วท. XXXXX',
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

              // 💾 ปุ่มบันทึกข้อมูลแบบเต็มความกว้างขอบมน
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 🔄 จังหวะกดเซฟ ส่งสแน็กบาร์แจ้งเตือนแล้วเด้งกลับหน้าเดิม
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('💾 บันทึกการเปลี่ยนแปลงโปรไฟล์เรียบร้อย...')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
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