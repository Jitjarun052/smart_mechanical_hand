import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../api/doctor_service.dart';
import '../api/api_config.dart';
import '../theme/app_theme.dart';

class PatientInfoScreen extends StatefulWidget {
  final String? userToken; // 🔑 รับ Token เพื่อดึงและอัปเดตข้อมูลผู้ป่วย

  const PatientInfoScreen({super.key, this.userToken});

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false; // ✏️ false = ดูอย่างเดียว, true = แก้ไข
  bool _isLoading = true;

  // 🩺 ข้อมูลแพทย์ที่ดึงมาจาก API
  String? _selectedDoctorId;
  List<Map<String, String>> _doctorOptions = [];

  // Controllers สำหรับทุกช่องข้อมูล
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _symptomController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  
  String? _userImage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _symptomController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  // 📡 โหลดข้อมูลผู้ป่วย และ รายชื่อหมอจาก DB
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    // 1. ดึงรายชื่อหมอจาก Database
    final doctors = await DoctorService.getDoctors();
    _doctorOptions = doctors;

    // 2. ดึงข้อมูล Profile ผู้ป่วยปัจจุบัน
    if (widget.userToken != null && widget.userToken!.isNotEmpty) {
      final result = await AuthService.getMe(widget.userToken!);
      if (result['success'] == true) {
        final user = result['user'];
        _firstnameController.text = user['firstname'] ?? '';
        _lastnameController.text = user['lastname'] ?? '';
        _ageController.text = user['age']?.toString() ?? '';
        _genderController.text = user['gender'] ?? '';
        _symptomController.text = user['symptoms'] ?? '';
        _emergencyPhoneController.text = user['emergency_phone'] ?? '';
        _selectedDoctorId = user['doctor_id']?.toString();
        
        final String? imageName = user['image'];
        _userImage = ApiConfig.getImageUrl(imageName);
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // 💾 บันทึกข้อมูล
  // 💾 บันทึกข้อมูลเข้า MySQL จริง
  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/user/update-profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.userToken}', // 🔑 ส่ง Token ไปยืนยันตัวตน
          },
          body: jsonEncode({
            'firstname': _firstnameController.text,
            'lastname': _lastnameController.text,
            'age': _ageController.text,
            'gender': _genderController.text,
            'symptoms': _symptomController.text,
            'emergency_phone': _emergencyPhoneController.text,
            'doctor_id': _selectedDoctorId,
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['status'] == 'success') {
          if (mounted) {
            setState(() {
              _isEditing = false;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('อัปเดตข้อมูลลงฐานข้อมูลเรียบร้อยแล้ว!')),
            );
          }
        } else {
          throw Exception(data['error'] ?? 'อัปเดตไม่สำเร็จ');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ข้อมูลส่วนตัวผู้ป่วย',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded, color: AppTheme.primaryColor),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          )
        ],
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
                    // 📸 ส่วนแสดงรูปภาพโปรไฟล์
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: (_userImage != null && _userImage!.isNotEmpty)
                                ? NetworkImage(_userImage!)
                                : null,
                            child: (_userImage == null || _userImage!.isEmpty)
                                ? const Icon(Icons.person, size: 60, color: Colors.white)
                                : null,
                          ),
                          if (_isEditing)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ✨ เปิดให้แก้: ชื่อ และ นามสกุล
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoField(
                            label: 'ชื่อ',
                            controller: _firstnameController,
                            icon: Icons.person_outline_rounded,
                            enabled: _isEditing, // 🔓 เปิดให้แก้แล้ว!
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoField(
                            label: 'นามสกุล',
                            controller: _lastnameController,
                            icon: Icons.person_outline_rounded,
                            enabled: _isEditing, // 🔓 เปิดให้แก้แล้ว!
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ✨ เปิดให้แก้: อายุ และ เพศ
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoField(
                            label: 'อายุ (ปี)',
                            controller: _ageController,
                            icon: Icons.calendar_today_rounded,
                            enabled: _isEditing,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoField(
                            label: 'เพศ',
                            controller: _genderController,
                            icon: Icons.wc_rounded,
                            enabled: _isEditing,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ✨ เปิดให้แก้: อาการ / โรคประจำตัว
                    _buildInfoField(
                      label: 'โรคประจำตัว / อาการกล้ามเนื้ออ่อนแรง',
                      controller: _symptomController,
                      icon: Icons.healing_rounded,
                      enabled: _isEditing, // 🔓 เปิดให้แก้แล้ว!
                      maxLines: 2,
                    ),
                    const SizedBox(height: 18),

                    // 🩺 แพทย์ผู้เชี่ยวชาญประจำตัว
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: const Text('แพทย์ผู้เชี่ยวชาญประจำตัว', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                    ),
                    if (!_isEditing)
                      TextFormField(
                        controller: TextEditingController(
                          text: _doctorOptions.firstWhere(
                            (doc) => doc['id'] == _selectedDoctorId,
                            orElse: () => {'name': 'ยังไม่ได้เลือกแพทย์ประจำตัว'},
                          )['name'],
                        ),
                        enabled: false,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_search_rounded, color: Colors.grey.shade400, size: 20),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1)),
                        ),
                      )
                    else
                      Autocomplete<Map<String, String>>(
                        initialValue: TextEditingValue(
                          text: _doctorOptions.firstWhere(
                            (doc) => doc['id'] == _selectedDoctorId,
                            orElse: () => {'name': ''},
                          )['name']!,
                        ),
                        displayStringForOption: (option) => option['name']!,
                        optionsBuilder: (textEditingValue) {
                          if (textEditingValue.text.isEmpty) return _doctorOptions;
                          return _doctorOptions.where((doc) => doc['name']!.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (selection) {
                          setState(() {
                            _selectedDoctorId = selection['id'];
                          });
                        },
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            style: const TextStyle(fontSize: 14),
                            decoration: _buildInputDecoration('พิมพ์ค้นหาชื่อแพทย์...', Icons.person_search_rounded),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                              child: Container(
                                width: MediaQuery.of(context).size.width - 48,
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () => onSelected(option),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(option['name']!, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 18),

                    // ✨ เปิดให้แก้: เบอร์โทรฉุกเฉิน
                    _buildInfoField(
                      label: 'เบอร์โทรศัพท์ติดต่อฉุกเฉิน (ญาติ/ผู้ดูแล)',
                      controller: _emergencyPhoneController,
                      icon: Icons.contact_phone_rounded,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 40),

                    // ปุ่มกดบันทึก
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: _handleSave,
                          child: const Text('บันทึกข้อมูลใหม่', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
        ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14, color: enabled ? AppTheme.textPrimary : Colors.grey.shade600, fontWeight: enabled ? FontWeight.normal : FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: enabled ? AppTheme.primaryColor : Colors.grey.shade400, size: 20),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1)),
    );
  }
}