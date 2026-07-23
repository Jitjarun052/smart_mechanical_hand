import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Step2MedicalForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController ageController;
  final TextEditingController genderController;
  final TextEditingController symptomController;
  final TextEditingController emergencyPhoneController;
  final String? selectedDoctorId;
  final List<Map<String, String>> doctorsList; // 🩺 รับรายชื่อหมอจริงจาก MySQL
  final bool isLoadingDoctors;                 // ⏳ รับสเตตัสการโหลดข้อมูลหมอ
  final ValueChanged<String?> onDoctorSelected;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const Step2MedicalForm({
    super.key,
    required this.formKey,
    required this.ageController,
    required this.genderController,
    required this.symptomController,
    required this.emergencyPhoneController,
    required this.selectedDoctorId,
    required this.doctorsList,
    required this.isLoadingDoctors,
    required this.onDoctorSelected,
    required this.onNext,
    required this.onPrev,
  });

  @override
  State<Step2MedicalForm> createState() => _Step2MedicalFormState();
}

class _Step2MedicalFormState extends State<Step2MedicalForm> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ข้อมูลอาการผู้ป่วย 🏥', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            const Text('ขั้นตอนที่ 2: ระบุรายละเอียดอาการเพื่อใช้ออกแบบแผนฟื้นฟู', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel('อายุ (ปี)'),
                      TextFormField(
                        controller: widget.ageController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14),
                        decoration: _buildDecoration('เช่น 65', Icons.calendar_today_rounded),
                        validator: (v) => v == null || v.isEmpty ? 'ระบุอายุ' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel('เพศ'),
                      TextFormField(
                        controller: widget.genderController,
                        style: const TextStyle(fontSize: 14),
                        decoration: _buildDecoration('ชาย / หญิง', Icons.wc_rounded),
                        validator: (v) => v == null || v.isEmpty ? 'ระบุเพศ' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildInputLabel('โรคประจำตัว / อาการกล้ามเนื้ออ่อนแรง'),
            TextFormField(
              controller: widget.symptomController,
              maxLines: 2,
              style: const TextStyle(fontSize: 14),
              decoration: _buildDecoration('เช่น หลอดเลือดสมอง (Stroke) / อ่อนแรงซีกซ้าย', Icons.healing_rounded),
              validator: (v) => v == null || v.isEmpty ? 'กรุณาระบุอาการเบื้องต้น' : null,
            ),
            const SizedBox(height: 20),

            // 🩺 [UPDATED]: ช่องเลือกแพทย์ประจำตัวที่ดึงข้อมูลจริงมาจาก MySQL
            _buildInputLabel('แพทย์ผู้เชี่ยวชาญประจำตัว'),
            widget.isLoadingDoctors
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor)),
                        SizedBox(width: 12),
                        Text('กำลังโหลดรายชื่อแพทย์จากระบบ...', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    ),
                  )
                : Autocomplete<Map<String, String>>(
                    displayStringForOption: (doc) => doc['name']!,
                    optionsBuilder: (textVal) {
                      if (textVal.text.isEmpty) return widget.doctorsList;
                      return widget.doctorsList.where((d) => d['name']!.toLowerCase().contains(textVal.text.toLowerCase()));
                    },
                    onSelected: (doc) => widget.onDoctorSelected(doc['id']),
                    fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
                      return TextFormField(
                        controller: ctrl,
                        focusNode: focusNode,
                        style: const TextStyle(fontSize: 14),
                        decoration: _buildDecoration(
                          widget.doctorsList.isEmpty ? 'ไม่พบรายชื่อแพทย์ในระบบ' : 'พิมพ์ค้นหาชื่อแพทย์ผู้รักษา...', 
                          Icons.person_search_rounded
                        ),
                        validator: (v) => widget.selectedDoctorId == null ? 'กรุณาเลือกแพทย์ผู้ดูแลจากรายการ' : null,
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
                            width: MediaQuery.of(context).size.width - 60,
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
            const SizedBox(height: 20),

            _buildInputLabel('เบอร์โทรศัพท์ติดต่อฉุกเฉิน (ญาติ/ผู้ดูแล)'),
            TextFormField(
              controller: widget.emergencyPhoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 14),
              decoration: _buildDecoration('เช่น 081-XXX-XXXX', Icons.contact_phone_rounded),
              validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกเบอร์ติดต่อฉุกเฉิน' : null,
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.withOpacity(0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: widget.onPrev,
                      child: const Text('ย้อนกลับ', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                      onPressed: widget.onNext,
                      child: const Text('ถัดไป', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ],
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