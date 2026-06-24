import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'scan_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();
  int _currentStep = 0; // 0 = บัญชี, 1 = อาการผู้ป่วย, 2 = อุปกรณ์ IoT

  // 📝 คอนโทรลเลอร์ Step 1: ข้อมูลบัญชี
  final _nameController = TextEditingController(); //[cite: 2]
  final _emailController = TextEditingController(); //[cite: 2]
  final _passwordController = TextEditingController(); //[cite: 2]
  final _confirmPasswordController = TextEditingController(); //[cite: 2]
  
  // 📸 [ADDED ✨] ตัวแปรสำหรับจำลองการเลือกไฟล์รูปภาพโปรไฟล์ (ฝั่ง Flutter จริงจะใช้ XFile? จาก image_picker)
  String? _selectedImagePath; 

  // 🏥 คอนโทรลเลอร์ Step 2: ข้อมูลอาการผู้ป่วย[cite: 2]
  final _ageController = TextEditingController(); //[cite: 2]
  final _genderController = TextEditingController(); //[cite: 2]
  final _symptomController = TextEditingController(); // โรคประจำตัว/อาการ[cite: 2]
  final _emergencyPhoneController = TextEditingController(); // เบอร์ติดต่อฉุกเฉิน[cite: 2]
  
  // 🩺 [ADDED ✨] ตัวแปรควบคุมการเลือกแพทย์ประจำตัว (สอดรับกับ doctor_id ของ MySQL)
  String? _selectedDoctorId;
  // จำลองลิสต์แพทย์เพื่อนำมารันตระกูล Dropdown หรือ List สลับค่า
  final List<Map<String, String>> _mockDoctors = [
    {'id': '1', 'name': 'นพ. สมชาย รักดี (เชี่ยวชาญด้านประสาทวิทยา)'},
    {'id': '2', 'name': 'พญ. พรทิพย์ สุขใจ (เชี่ยวชาญด้านเวชศาสตร์ฟื้นฟู)'},
  ];

  // 🦾 คอนโทรลเลอร์ Step 3: ข้อมูลอุปกรณ์ IoT[cite: 2]
  final _serialNumberController = TextEditingController(); //[cite: 2]
  final _deviceNameController = TextEditingController();  //[cite: 2]

  bool _isPasswordObscured = true; //[cite: 2]
  bool _isConfirmPasswordObscured = true; //[cite: 2]
  bool _acceptTerms = false; //[cite: 2]

  // ฟังก์ชันควบคุมการเดินหน้าฟอร์ม[cite: 2]
  void _nextStep() {
    if (_currentStep == 0 && _formKeyStep1.currentState!.validate()) { //[cite: 2]
      if (!_acceptTerms) { //[cite: 2]
        ScaffoldMessenger.of(context).showSnackBar( //[cite: 2]
          const SnackBar(content: Text('กรุณากดยอมรับเงื่อนไขการใช้งานระบบก่อน')), //[cite: 2]
        );
        return; //[cite: 2]
      }
      _animateToPage(1); //[cite: 2]
    } else if (_currentStep == 1 && _formKeyStep2.currentState!.validate()) { //[cite: 2]
      if (_selectedDoctorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเลือกแพทย์ประจำตัวผู้ป่วยก่อนดำเนินการต่อ')),
        );
        return;
      }
      _animateToPage(2); //[cite: 2]
    }
  }

  // ฟังก์ชันควบคุมการถอยหลังฟอร์ม[cite: 2]
  void _prevStep() {
    if (_currentStep > 0) { //[cite: 2]
      _animateToPage(_currentStep - 1); //[cite: 2]
    }
  }

  void _animateToPage(int page) {
    setState(() => _currentStep = page); //[cite: 2]
    _pageController.animateToPage( //[cite: 2]
      page, //[cite: 2]
      duration: const Duration(milliseconds: 300), //[cite: 2]
      curve: Curves.easeInOut, //[cite: 2]
    );
  }

  // 🚀 กดสมัครสมาชิกแบบกรอกครบทุกอย่าง[cite: 2]
  void _handleFinalSignUp() {
    if (_formKeyStep3.currentState!.validate()) { //[cite: 2]
      _showLoadingAndNavigate( //[cite: 2]
        'ลงทะเบียนบัญชีคุณ ${_nameController.text} พร้อมรูปถ่ายและผูกอุปกรณ์เรียบร้อย!', //[cite: 2]
      );
    }
  }

  void _showLoadingAndNavigate(String successMessage) {
    showDialog( //[cite: 2]
      context: context, //[cite: 2]
      barrierDismissible: false, //[cite: 2]
      builder: (context) => const Center( //[cite: 2]
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor)), //[cite: 2]
      ),
    );

    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () { //[cite: 2]
      Navigator.pop(context); // ปิด Loading[cite: 2]
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage))); //[cite: 2]
      Navigator.pop(context); // กลับหน้า Login[cite: 2]
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); //[cite: 2]
    _nameController.dispose(); //[cite: 2]
    _emailController.dispose(); //[cite: 2]
    _passwordController.dispose(); //[cite: 2]
    _confirmPasswordController.dispose(); //[cite: 2]
    _ageController.dispose(); //[cite: 2]
    _genderController.dispose(); //[cite: 2]
    _symptomController.dispose(); //[cite: 2]
    _emergencyPhoneController.dispose(); //[cite: 2]
    _serialNumberController.dispose(); //[cite: 2]
    _deviceNameController.dispose(); //[cite: 2]
    super.dispose(); //[cite: 2]
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //[cite: 2]
      backgroundColor: AppTheme.backgroundColor, //[cite: 2]
      body: SafeArea( //[cite: 2]
        child: Column( //[cite: 2]
          children: [ //[cite: 2]
            // แถบหัวหน้าจอและตัวบ่งชี้ขั้นตอน (3 จุด)[cite: 2]
            Padding( //[cite: 2]
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16), //[cite: 2]
              child: Row( //[cite: 2]
                mainAxisAlignment: MainAxisAlignment.spaceBetween, //[cite: 2]
                children: [ //[cite: 2]
                  GestureDetector( //[cite: 2]
                    onTap: () { //[cite: 2]
                      if (_currentStep > 0) { //[cite: 2]
                        _prevStep(); //[cite: 2]
                      } else { //[cite: 2]
                        Navigator.pop(context); //[cite: 2]
                      }
                    },
                    child: Container( //[cite: 2]
                      padding: const EdgeInsets.all(8), //[cite: 2]
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), //[cite: 2]
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textPrimary), //[cite: 2]
                    ),
                  ),
                  Row( //[cite: 2]
                    children: [ //[cite: 2]
                      _buildStepDot(isActive: _currentStep == 0), //[cite: 2]
                      const SizedBox(width: 6), //[cite: 2]
                      _buildStepDot(isActive: _currentStep == 1), //[cite: 2]
                      const SizedBox(width: 6), //[cite: 2]
                      _buildStepDot(isActive: _currentStep == 2), //[cite: 2]
                    ],
                  ),
                  const SizedBox(width: 34), //[cite: 2]
                ],
              ),
            ),
            Expanded( //[cite: 2]
              child: PageView( //[cite: 2]
                controller: _pageController, //[cite: 2]
                physics: const NeverScrollableScrollPhysics(), //[cite: 2]
                children: [ //[cite: 2]
                  _buildStep1PersonalForm(), //[cite: 2]
                  _buildStep2MedicalForm(), // หน้ากรอกอาการที่เพิ่มเข้ามาใหม่ ✨[cite: 2]
                  _buildStep3DeviceForm(), //[cite: 2]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== [ STEP 1: ข้อมูลบัญชี ] ====================[cite: 2]
  Widget _buildStep1PersonalForm() {
    return SingleChildScrollView( //[cite: 2]
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0), //[cite: 2]
      child: Form( //[cite: 2]
        key: _formKeyStep1, //[cite: 2]
        child: Column( //[cite: 2]
          crossAxisAlignment: CrossAxisAlignment.start, //[cite: 2]
          children: [ //[cite: 2]
            const Text('สร้างบัญชีใหม่ 🔐', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)), //[cite: 2]
            const SizedBox(height: 4), //[cite: 2]
            const Text('ขั้นตอนที่ 1: กรอกข้อมูลส่วนตัวเพื่อเปิดใช้งานระบบ', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)), //[cite: 2]
            const SizedBox(height: 20),

            // 📸 [ADDED ✨]: ส่วนการเลือกรูปภาพโปรไฟล์ผู้ป่วยแบบ Mock อัปโหลด
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    backgroundImage: _selectedImagePath != null 
                        ? AssetImage(_selectedImagePath!) 
                        : null,
                    child: _selectedImagePath == null
                        ? const Icon(Icons.person_rounded, size: 50, color: AppTheme.primaryColor)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // จำลองว่ากดยลเลือกรูปภาพสำเร็จ
                        setState(() {
                          _selectedImagePath = 'assets/images/mock_avatar.png'; 
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('เลือกรูปโปรไฟล์จำลองเรียบร้อย! (Mocked)')),
                        );
                      },
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

            _buildInputLabel('ชื่อ - นามสกุลผู้ป่วย'), //[cite: 2]
            TextFormField( //[cite: 2]
              controller: _nameController, //[cite: 2]
              style: const TextStyle(fontSize: 14), //[cite: 2]
              decoration: _buildInputDecoration('กรอกชื่อและนามสกุลของคุณ', Icons.person_outline_rounded), //[cite: 2]
              validator: (value) => value!.isEmpty ? 'กรุณากรอกชื่อ-นามสกุล' : null, //[cite: 2]
            ), //[cite: 2]
            const SizedBox(height: 18), //[cite: 2]

            _buildInputLabel('อีเมลผู้ใช้งาน'), //[cite: 2]
            TextFormField( //[cite: 2]
              controller: _emailController, //[cite: 2]
              keyboardType: TextInputType.emailAddress, //[cite: 2]
              style: const TextStyle(fontSize: 14), //[cite: 2]
              decoration: _buildInputDecoration('example@mail.com', Icons.email_outlined), //[cite: 2]
              validator: (value) => value!.isEmpty ? 'กรุณากรอกอีเมล' : null, //[cite: 2]
            ), //[cite: 2]
            const SizedBox(height: 18), //[cite: 2]

            _buildInputLabel('รหัสผ่าน (Password)'), //[cite: 2]
            TextFormField( //[cite: 2]
              controller: _passwordController, //[cite: 2]
              obscureText: _isPasswordObscured, //[cite: 2]
              style: const TextStyle(fontSize: 14), //[cite: 2]
              decoration: _buildInputDecoration('กำหนดรหัสผ่าน 6 ตัวขึ้นไป', Icons.lock_outline_rounded).copyWith( //[cite: 2]
                suffixIcon: IconButton( //[cite: 2]
                  icon: Icon(_isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: Colors.grey), //[cite: 2]
                  onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured), //[cite: 2]
                ), //[cite: 2]
              ), //[cite: 2]
              validator: (value) => value!.length < 6 ? 'รหัสผ่านต้องยาว 6 ตัวขึ้นไป' : null, //[cite: 2]
            ), //[cite: 2]
            const SizedBox(height: 18), //[cite: 2]

            _buildInputLabel('ยืนยันรหัสผ่านอีกครั้ง'), //[cite: 2]
            TextFormField( //[cite: 2]
              controller: _confirmPasswordController, //[cite: 2]
              obscureText: _isConfirmPasswordObscured, //[cite: 2]
              style: const TextStyle(fontSize: 14), //[cite: 2]
              decoration: _buildInputDecoration('กรอกรหัสผ่านให้ตรงกัน', Icons.lock_clock_outlined).copyWith( //[cite: 2]
                suffixIcon: IconButton( //[cite: 2]
                  icon: Icon(_isConfirmPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: Colors.grey), //[cite: 2]
                  onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured), //[cite: 2]
                ), //[cite: 2]
              ), //[cite: 2]
              validator: (value) => value != _passwordController.text ? 'รหัสผ่านไม่ตรงกัน' : null, //[cite: 2]
            ), //[cite: 2]
            const SizedBox(height: 18), //[cite: 2]

            Row( //[cite: 2]
              children: [ //[cite: 2]
                SizedBox( //[cite: 2]
                  width: 22, //[cite: 2]
                  height: 22, //[cite: 2]
                  child: Checkbox( //[cite: 2]
                    value: _acceptTerms, //[cite: 2]
                    activeColor: AppTheme.primaryColor, //[cite: 2]
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), //[cite: 2]
                    onChanged: (value) => setState(() => _acceptTerms = value ?? false), //[cite: 2]
                  ), //[cite: 2]
                ), //[cite: 2]
                const SizedBox(width: 10), //[cite: 2]
                const Expanded( //[cite: 2]
                  child: Text('ฉันยินยอมให้ระบบจัดเก็บสถิติการฝึกเพื่อการรักษา', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)), //[cite: 2]
                ), //[cite: 2]
              ], //[cite: 2]
            ), //[cite: 2]
            const SizedBox(height: 28), //[cite: 2]

            SizedBox( //[cite: 2]
              width: double.infinity, //[cite: 2]
              height: 52, //[cite: 2]
              child: ElevatedButton( //[cite: 2]
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), //[cite: 2]
                onPressed: _nextStep, //[cite: 2]
                child: const Row( //[cite: 2]
                  mainAxisAlignment: MainAxisAlignment.center, //[cite: 2]
                  children: [Text('ขั้นตอนถัดไป ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)), Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white)], //[cite: 2]
                ), //[cite: 2]
              ), //[cite: 2]
            ), //[cite: 2]
          ], //[cite: 2]
        ), //[cite: 2]
      ), //[cite: 2]
    ); //[cite: 2]
  }

  // ==================== [ STEP 2: ข้อมูลอาการผู้ป่วย ] ====================[cite: 2]
  Widget _buildStep2MedicalForm() {
    return SingleChildScrollView( //[cite: 2]
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0), //[cite: 2]
      child: Form( //[cite: 2]
        key: _formKeyStep2, //[cite: 2]
        child: Column( //[cite: 2]
          crossAxisAlignment: CrossAxisAlignment.start, //[cite: 2]
          children: [ //[cite: 2]
            const Text('ข้อมูลอาการผู้ป่วย 🏥', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)), //[cite: 2]
            const SizedBox(height: 4), //[cite: 2]
            const Text('ขั้นตอนที่ 2: ระบุรายละเอียดอาการเพื่อใช้ออกแบบแผนฟื้นฟู', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)), //[cite: 2]
            const SizedBox(height: 32), //[cite: 2]

            Row( //[cite: 2]
              children: [ //[cite: 2]
                Expanded( //[cite: 2]
                  child: Column( //[cite: 2]
                    crossAxisAlignment: CrossAxisAlignment.start, //[cite: 2]
                    children: [ //[cite: 2]
                      _buildInputLabel('อายุ (ปี)'), //[cite: 2]
                      TextFormField( //[cite: 2]
                        controller: _ageController, //[cite: 2]
                        keyboardType: TextInputType.number, //[cite: 2]
                        style: const TextStyle(fontSize: 14), //[cite: 2]
                        decoration: _buildInputDecoration('เช่น 65', Icons.calendar_today_rounded), //[cite: 2]
                        validator: (value) => value!.isEmpty ? 'ระบุอายุ' : null, //[cite: 2]
                      ), //[cite: 2]
                    ], //[cite: 2]
                  ), //[cite: 2]
                ), //[cite: 2]
                const SizedBox(width: 16), //[cite: 2]
                Expanded( //[cite: 2]
                  child: Column( //[cite: 2]
                    crossAxisAlignment: CrossAxisAlignment.start, //[cite: 2]
                    children: [ //[cite: 2]
                      _buildInputLabel('เพศ'), //[cite: 2]
                      TextFormField( //[cite: 2]
                        controller: _genderController, //[cite: 2]
                        style: const TextStyle(fontSize: 14), //[cite: 2]
                        decoration: _buildInputDecoration('ชาย / หญิง', Icons.wc_rounded), //[cite: 2]
                        validator: (value) => value!.isEmpty ? 'ระบุเพศ' : null, //[cite: 2]
                      ), //[cite: 2]
                    ], //[cite: 2]
                  ), //[cite: 2]
                ), //[cite: 2]
              ], //[cite: 2]
            ), //[cite: 2]
            const SizedBox(height: 20), //[cite: 2]

            _buildInputLabel('โรคประจำตัว / อาการกล้ามเนื้ออ่อนแรง'), //[cite: 2]
            TextFormField( //[cite: 2]
              controller: _symptomController, //[cite: 2]
              maxLines: 2, //[cite: 2]
              style: const TextStyle(fontSize: 14), //[cite: 2]
              decoration: _buildInputDecoration('เช่น หลอดเลือดสมอง (Stroke) / อ่อนแรงซีกซ้าย', Icons.healing_rounded), //[cite: 2]
              validator: (value) => value!.isEmpty ? 'กรุณาระบุอาการเบื้องต้นของผู้ป่วย' : null, //[cite: 2]
            ), //[cite: 2]
            const SizedBox(height: 20), //[cite: 2]

            // 🩺 [ADDED ✨]: ส่วนช่องเลือกแพทย์เจ้าของไข้ผู้รับผิดชอบ (Dropdown ใช้งานง่ายหลบเลเยอร์พัง)
            // 🩺 [อัปเดตใหม่ ✨]: เปลี่ยนจาก Dropdown เป็น Autocomplete ค้นหาชื่อแพทย์ได้ ไม่ต้องไถหาให้ตาตั้ง
            _buildInputLabel('แพทย์ผู้เชี่ยวชาญประจำตัว'),
            Autocomplete<Map<String, String>>(
              displayStringForOption: (Map<String, String> option) => option['name']!,
              optionsBuilder: (TextEditingValue textEditingValue) {
                // ถ้ายังไม่ได้พิมพ์อะไร ให้โชว์รายชื่อแพทย์ทั้งหมด (หรือจำกัดแค่ 5 คนแรกก่อนก็ได้)
                if (textEditingValue.text.isEmpty) {
                  return _mockDoctors;
                }
                // ถ้าพิมพ์ข้อความ ให้กรองชื่อแพทย์ที่ตรงกับคำที่พิมพ์
                return _mockDoctors.where((Map<String, String> doc) {
                  return doc['name']!.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (Map<String, String> selection) {
                setState(() {
                  _selectedDoctorId = selection['id']; // ผูก doctor_id ไปใช้ส่งหลังบ้านเหมือนเดิมเป๊ะ!
                });
                print("DEBUG: เลือกแพทย์ ID = $_selectedDoctorId");
              },
              // 🎨 ส่วนจัดหน้าตาช่อง Input ให้สวยเนี๊ยบเข้าธีมเดิมของคุณ
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: const TextStyle(fontSize: 14),
                  decoration: _buildInputDecoration('พิมพ์ค้นหาชื่อแพทย์ผู้รักษา...', Icons.person_search_rounded),
                  validator: (value) {
                    if (_selectedDoctorId == null || value!.isEmpty) {
                      return 'กรุณาเลือกแพทย์ผู้ดูแลจากรายการ';
                    }
                    return null;
                  },
                );
              },
              // 🎨 ส่วนจัดหน้าตากล่องผลลัพธ์ (Dropdown List ที่เด้งลอยขึ้นมา)
              // 🎨 ส่วนจัดหน้าตากล่องผลลัพธ์ (แก้ไขจุดนี้เพื่อเคลียร์ตัวแดง)
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 60, // ปรับความกว้างให้พอดีกับช่องกรอก
                      // ✨ ใช้ constraints คุมความสูงสูงสุดแทน SizedBox จะไม่แดงและนิ่งสนิทครับ
                      constraints: const BoxConstraints(
                        maxHeight: 200, 
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, String> option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Text(
                                option['name']!, 
                                style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)
                              ),
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

            _buildInputLabel('เบอร์โทรศัพท์ติดต่อฉุกเฉิน (ญาติ/ผู้ดูแล)'), //[cite: 2]
            TextFormField( //[cite: 2]
              controller: _emergencyPhoneController, //[cite: 2]
              keyboardType: TextInputType.phone, //[cite: 2]
              style: const TextStyle(fontSize: 14), //[cite: 2]
              decoration: _buildInputDecoration('เช่น 081-XXX-XXXX', Icons.contact_phone_rounded), //[cite: 2]
              validator: (value) => value!.isEmpty ? 'กรุณากรอกเบอร์ติดต่อฉุกเฉิน' : null, //[cite: 2]
            ), //[cite: 2]
            const SizedBox(height: 40), //[cite: 2]

            Row( //[cite: 2]
              children: [ //[cite: 2]
                Expanded( //[cite: 2]
                  child: SizedBox( //[cite: 2]
                    height: 52, //[cite: 2]
                    child: OutlinedButton( //[cite: 2]
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.withOpacity(0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), //[cite: 2]
                      onPressed: _prevStep, //[cite: 2]
                      child: const Text('ย้อนกลับ', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)), //[cite: 2]
                    ), //[cite: 2]
                  ), //[cite: 2]
                ), //[cite: 2]
                const SizedBox(width: 12), //[cite: 2]
                Expanded( //[cite: 2]
                  child: SizedBox( //[cite: 2]
                    height: 52, //[cite: 2]
                    child: ElevatedButton( //[cite: 2]
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), //[cite: 2]
                      onPressed: _nextStep, //[cite: 2]
                      child: const Text('ถัดไป', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)), //[cite: 2]
                    ), //[cite: 2]
                  ), //[cite: 2]
                ), //[cite: 2]
              ], //[cite: 2]
            ), //[cite: 2]
          ], //[cite: 2]
        ), //[cite: 2]
      ), //[cite: 2]
    ); //[cite: 2]
  }

  // ==================== [ STEP 3: ข้อมูลอุปกรณ์ IoT ] ====================[cite: 2]
  Widget _buildStep3DeviceForm() {
    return SingleChildScrollView( //[cite: 2]
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0), //[cite: 2]
      child: Form( //[cite: 2]
        key: _formKeyStep3, //[cite: 2]
        child: Column( //[cite: 2]
          crossAxisAlignment: CrossAxisAlignment.start, //[cite: 2]
          children: [ //[cite: 2]
            const Text('ผูกอุปกรณ์มือกล 🦾', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)), //[cite: 2]
            const SizedBox(height: 4), //[cite: 2]
            const Text('ขั้นตอนที่ 3: ระบุหมายเลขเครื่องมือกลเพื่อซิงก์ข้อมูลแนวโน้ม', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)), //[cite: 2]
            const SizedBox(height: 28), //[cite: 2]

            _buildInputLabel('หมายเลขซีเรียลนัมเบอร์อุปกรณ์ (Serial Number)'), //[cite: 2]
            TextFormField( //[cite: 2]
              controller: _serialNumberController, //[cite: 2]
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), //[cite: 2]
              decoration: _buildInputDecoration('เช่น Glove-2569-XXXX', Icons.developer_board_rounded).copyWith( //[cite: 2]
                suffixIcon: IconButton( //[cite: 2]
                  icon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor, size: 22), //[cite: 2]
                  onPressed: () async { //[cite: 2]
                    final String? scannedResult = await Navigator.push<String>( //[cite: 2]
                      context, //[cite: 2]
                      MaterialPageRoute(builder: (context) => const ScanScreen()), //[cite: 2]
                    ); //[cite: 2]
                    if (scannedResult != null && mounted) { //[cite: 2]
                      setState(() { //[cite: 2]
                        _serialNumberController.text = scannedResult; //[cite: 2]
                      }); //[cite: 2]
                    }
                  },
                ),
              ),
              validator: (value) => value!.isEmpty ? 'กรุณาระบุ Serial Number' : null, //[cite: 2]
            ), //[cite: 2]
            const SizedBox(height: 20), //[cite: 2]

            _buildInputLabel('ตั้งชื่ออุปกรณ์ของคุณ (Device Name)'), //[cite: 2]
            TextFormField( //[cite: 2]
              controller: _deviceNameController, //[cite: 2]
              style: const TextStyle(fontSize: 14), //[cite: 2]
              decoration: _buildInputDecoration('เช่น ถุงมือฟื้นฟูของสมชาย', Icons.drive_file_rename_outline_rounded), //[cite: 2]
              validator: (value) => value!.isEmpty ? 'กรุณาตั้งชื่อเล่นให้อุปกรณ์' : null, //[cite: 2]
            ), //[cite: 2]
            const SizedBox(height: 40), //[cite: 2]

            Row( //[cite: 2]
              children: [ //[cite: 2]
                Expanded( //[cite: 2]
                  flex: 1, //[cite: 2]
                  child: SizedBox( //[cite: 2]
                    height: 52, //[cite: 2]
                    child: OutlinedButton( //[cite: 2]
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.withOpacity(0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), //[cite: 2]
                      onPressed: _prevStep, //[cite: 2]
                      child: const Text('ย้อนกลับ', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)), //[cite: 2]
                    ), //[cite: 2]
                  ), //[cite: 2]
                ), //[cite: 2]
                const SizedBox(width: 12), //[cite: 2]
                Expanded( //[cite: 2]
                  flex: 2, //[cite: 2]
                  child: SizedBox( //[cite: 2]
                    height: 52, //[cite: 2]
                    child: ElevatedButton( //[cite: 2]
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), //[cite: 2]
                      onPressed: _handleFinalSignUp, //[cite: 2]
                      child: const Text('ยืนยันลงทะเบียน', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)), //[cite: 2]
                    ), //[cite: 2]
                  ), //[cite: 2]
                ), //[cite: 2]
              ], //[cite: 2]
            ), //[cite: 2]
            const SizedBox(height: 24), //[cite: 2]
            Center( //[cite: 2]
              child: TextButton( //[cite: 2]
                onPressed: () => _showLoadingAndNavigate('สร้างบัญชีคุณ ${_nameController.text} สำเร็จ! (ประวัติอาการบันทึกแล้ว/ผูกถุงมือกลภายหลัง)'), //[cite: 2]
                child: const Text('ข้ามขั้นตอนผูกอุปกรณ์ไปก่อน', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)), //[cite: 2]
              ), //[cite: 2]
            ), //[cite: 2]
          ], //[cite: 2]
        ), //[cite: 2]
      ), //[cite: 2]
    ); //[cite: 2]
  }

  // ==================== [ Helpers ] ====================[cite: 2]
  Widget _buildStepDot({required bool isActive}) {
    return AnimatedContainer( //[cite: 2]
      duration: const Duration(milliseconds: 200), //[cite: 2]
      width: isActive ? 24 : 8, //[cite: 2]
      height: 8, //[cite: 2]
      decoration: BoxDecoration(color: isActive ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(4)), //[cite: 2]
    ); //[cite: 2]
  }

  Widget _buildInputLabel(String label) {
    return Padding( //[cite: 2]
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0), //[cite: 2]
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)), //[cite: 2]
    ); //[cite: 2]
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration( //[cite: 2]
      hintText: hint, //[cite: 2]
      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 13), //[cite: 2]
      prefixIcon: Icon(icon, color: Colors.grey, size: 20), //[cite: 2]
      filled: true, //[cite: 2]
      fillColor: Colors.white, //[cite: 2]
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), //[cite: 2]
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), //[cite: 2]
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1)), //[cite: 2]
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)), //[cite: 2]
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1)), //[cite: 2]
    ); //[cite: 2]
  }
}