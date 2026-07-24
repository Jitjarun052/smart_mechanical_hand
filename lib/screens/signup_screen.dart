import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../api/auth_service.dart';
import '../api/doctor_service.dart';
import '../widgets/signup/step1_personal_form.dart';
import '../widgets/signup/step2_medical_form.dart';
import '../widgets/signup/step3_device_form.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

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

  int _currentStep = 0;
  bool _isSubmitting = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _symptomController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  String? _selectedDoctorId;
  String? _selectedImagePath;
  
  final _serialNumberController = TextEditingController();
  final _deviceNameController = TextEditingController();


  bool _acceptTerms = false;

  List<Map<String, String>> _doctorsList = [];
  bool _isLoadingDoctors = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorsFromApi(); // 👈 สั่งดึงหมอทันทีตอนเปิดหน้า SignUp
  }

  // 🔌 ฟังก์ชันดึงหมอจาก Backend
  Future<void> _fetchDoctorsFromApi() async {
    final doctors = await DoctorService.getDoctors();
    if (mounted) {
      setState(() {
        _doctorsList = doctors;
        _isLoadingDoctors = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await image.readAsBytes(); // Read bytes สำหรับแสดงผลบน Web
      setState(() {
        _selectedImageBytes = bytes;
        if (!kIsWeb) {
          _selectedImageFile = File(image.path);
        }
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && _formKeyStep1.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณากดยอมรับเงื่อนไขก่อน')));
        return;
      }
      _animateToPage(1);
    } else if (_currentStep == 1 && _formKeyStep2.currentState!.validate()) {
      if (_selectedDoctorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาเลือกแพทย์ประจำตัว')));
        return;
      }
      _animateToPage(2);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) _animateToPage(_currentStep - 1);
  }

  void _animateToPage(int page) {
    setState(() => _currentStep = page);
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _handleFinalSignUp({bool isSkipDevice = false}) async {
    final fullName = _nameController.text.trim().split(' ');
    final firstname = fullName.isNotEmpty ? fullName.first : '';
    final lastname = fullName.length > 1 ? fullName.sublist(1).join(' ') : '-';

    setState(() => _isSubmitting = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor))),
    );

    final result = await AuthService.registerPatient(
      firstname: firstname,
      lastname: lastname,
      email: _emailController.text.trim(),
      phone: _emergencyPhoneController.text.trim(),
      password: _passwordController.text.trim(),
      age: _ageController.text.trim(),
      gender: _genderController.text.trim(),
      symptoms: _symptomController.text.trim(),
      emergencyPhone: _emergencyPhoneController.text.trim(),
      doctorId: _selectedDoctorId,
      serialNumber: isSkipDevice ? null : _serialNumberController.text.trim(),
      deviceName: isSkipDevice ? null : _deviceNameController.text.trim(),
      imageFile: _selectedImageFile,     // 👈 เช็กว่าส่งตัวนี้
      imageBytes: _selectedImageBytes,
      imageName: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    if (!mounted) return;
    Navigator.pop(context);
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('ลงทะเบียนสำเร็จ')]),
          content: Text(result['message'] ?? 'ลงทะเบียนเรียบร้อยแล้ว'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('ตกลง', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'เกิดข้อผิดพลาด'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _symptomController.dispose();
    _emergencyPhoneController.dispose();
    _serialNumberController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _currentStep > 0 ? _prevStep() : Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textPrimary),
                    ),
                  ),
                  Row(
                    children: [
                      _buildStepDot(isActive: _currentStep == 0),
                      const SizedBox(width: 6),
                      _buildStepDot(isActive: _currentStep == 1),
                      const SizedBox(width: 6),
                      _buildStepDot(isActive: _currentStep == 2),
                    ],
                  ),
                  const SizedBox(width: 34),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Step1PersonalForm(
                    formKey: _formKeyStep1,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    selectedImageBytes: _selectedImageBytes, // 👈 ส่งไฟล์รูปภาพ
                    onPickImage: _pickImage, // 👈 ส่งฟังก์ชันเปิดแกลเลอรี
                    acceptTerms: _acceptTerms,
                    onAcceptTermsChanged: (val) => setState(() => _acceptTerms = val),
                    onNext: _nextStep,
                  ),
                  Step2MedicalForm(
                    formKey: _formKeyStep2,
                    ageController: _ageController,
                    genderController: _genderController,
                    symptomController: _symptomController,
                    emergencyPhoneController: _emergencyPhoneController,
                    selectedDoctorId: _selectedDoctorId,
                    doctorsList: _doctorsList,         // 👈 ส่งหมอที่ดึงมาจาก MySQL
                    isLoadingDoctors: _isLoadingDoctors,
                    onDoctorSelected: (docId) => setState(() => _selectedDoctorId = docId),
                    onNext: _nextStep,
                    onPrev: _prevStep,
                  ),
                  Step3DeviceForm(
                    formKey: _formKeyStep3,
                    serialNumberController: _serialNumberController,
                    deviceNameController: _deviceNameController,
                    isSubmitting: _isSubmitting,
                    onSubmitWithDevice: (deviceData){ _handleFinalSignUp(isSkipDevice: false);},
                    onSkip: () => _handleFinalSignUp(isSkipDevice: true),
                    onPrev: _prevStep,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(color: isActive ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
    );
  }
}