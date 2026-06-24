import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PatientInfoScreen extends StatefulWidget {
  const PatientInfoScreen({super.key});

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false; // ✏️ false = ดูข้อมูลอย่างเดียว, true = เปิดโหมดแก้ไข

  // 🩺 [✨ ADDED]: ตัวแปรจัดการสิทธิ์และรายชื่อแพทย์ที่ขาดหายไป
  String? _selectedDoctorId = "1"; // ค่าเริ่มต้นผูกกับหมอคนแรก
  
  final List<Map<String, String>> _mockDoctors = [
    {'id': '1', 'name': 'นพ. สมชาย รักดี (เชี่ยวชาญด้านประสาทวิทยา)'},
    {'id': '2', 'name': 'พญ. พรทิพย์ สุขใจ (เชี่ยวชาญด้านเวชศาสตร์ฟื้นฟู)'},
  ];

  // Mock ข้อมูลผู้ป่วยเดิม
  final _nameController = TextEditingController(text: "จิตร์จรัญ คืนมาเมือง");
  final _ageController = TextEditingController(text: "65");
  final _genderController = TextEditingController(text: "ชาย");
  final _symptomController = TextEditingController(text: "หลอดเลือดสมอง (Stroke) / อ่อนแรงซีกซ้าย");
  final _emergencyPhoneController = TextEditingController(text: "081-234-5678");

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _symptomController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // 🟢 ตรงนี้เอาไว้ใส่ Logic ยิงอัปเดตข้อมูลไปที่ API (MySQL หลังบ้าน)
      setState(() => _isEditing = false); // บันทึกเสร็จแล้ว เด้งกลับโหมดดูข้อมูลปกติ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัปเดตข้อมูลส่วนตัวเรียบร้อยแล้ว!')),
      );
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
          // ปุ่มสลับโหมด แก้ไข / ยกเลิก ด้านบนขวา
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
      body: SingleChildScrollView(
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
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    if (_isEditing) // โชว์ปุ่มกล้องถ่ายรูปเฉพาะตอนกดแก้ไขเท่านั้น
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildInfoField(
                label: 'ชื่อ - นามสกุลผู้ป่วย',
                controller: _nameController,
                icon: Icons.person_outline_rounded,
                enabled: false, // 🔒 [🛠️ ปรับปรุง]: แช่แข็งไว้ถาวรไม่ให้คนไข้แก้เองป้องกันบั๊กข้อมูลสับสน
              ),
              const SizedBox(height: 18),

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

              _buildInfoField(
                label: 'โรคประจำตัว / อาการกล้ามเนื้ออ่อนแรง',
                controller: _symptomController,
                icon: Icons.healing_rounded,
                enabled: false, // 🔒 [🛠️ ปรับปรุง]: แช่แข็งไว้ถาวร เพื่อให้แพทย์คุมโปรแกรมการฝึกผ่านแอดมิน
                maxLines: 2,
              ),
              const SizedBox(height: 18),

              // 🩺 ส่วนแสดงผล/แก้ไข แพทย์ผู้เชี่ยวชาญประจำตัว
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: const Text('แพทย์ผู้เชี่ยวชาญประจำตัว', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
              ),
              if (!_isEditing)
                // 🟢 โหมดปกติ: โชว์ชื่อแพทย์ปัจจุบันแบบ อ่านได้อย่างเดียว (ล็อกขอบเทา)
                TextFormField(
                  controller: TextEditingController(
                    text: _mockDoctors.firstWhere((doc) => doc['id'] == _selectedDoctorId, orElse: () => {'name': 'ยังไม่ได้เลือกแพทย์ประจำตัว'})['name']
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
                // 🟡 โหมดแก้ไข: เปลี่ยนร่างเป็น Autocomplete ค้นหาพิมพ์กรองชื่อแพทย์ได้ทันที คลีนๆ ไม่ล้นจอ
                Autocomplete<Map<String, String>>(
                  initialValue: TextEditingValue(
                    text: _mockDoctors.firstWhere((doc) => doc['id'] == _selectedDoctorId, orElse: () => {'name': ''})['name']!
                  ),
                  displayStringForOption: (Map<String, String> option) => option['name']!,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) return _mockDoctors;
                    return _mockDoctors.where((doc) => doc['name']!.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (Map<String, String> selection) {
                    setState(() {
                      _selectedDoctorId = selection['id']; // อัปเดต doctor_id ตัวใหม่สแตนด์บายรอส่งไป MySQL
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

              _buildInfoField(
                label: 'เบอร์โทรศัพท์ติดต่อฉุกเฉิน (ญาติ/ผู้ดูแล)',
                controller: _emergencyPhoneController,
                icon: Icons.contact_phone_rounded,
                enabled: _isEditing, // ✏️ เปิดให้แก้ได้เต็มที่
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 40),

              // ปุ่มกดยืนยันบันทึกข้อมูล (โชว์เฉพาะตอนอยู่ในโหมดแก้ไขเท่านั้น)
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

  // ฟังก์ชันตัวช่วยวาดช่องข้อมูล สลับสถานะระหว่างพิมพ์ได้ กับอ่านได้อย่างเดียว
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

  // 📝 [✨ ADDED]: ฟังก์ชันจัดหน้าตาดีไซน์ของช่องอินพุต คืนสิทธิ์ให้ Autocomplete แสดงเส้นสีส้มอิฐสวยงาม
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