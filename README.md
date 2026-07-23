# smart_mechanical_hand

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## 📱 FLUTTER FRONTEND CHANGELOG: บันทึกฝั่งหน้าบ้าน (Realme GT 6 Application)

---

## 📌 PHASE 1: การวางโครงสร้างสถาปัตยกรรมแอป (Flutter Core Structure)
* **Setup Project:** ตั้งไข่โปรเจกต์ด้วย Flutter รองรับการแสดงผลแบบ Responsive บนหน้าจอประสิทธิภาพสูงของ Realme GT 6
* **State & Package Management:** เลือกใช้เครื่องมือและ HTTP client สำหรับเตรียมยิงเชื่อมต่อกับ Node.js หลังบ้าน (พอร์ต `5000`)
* **Clean UI Design:** วางธีมแอปพลิเคชันทางการแพทย์ (Medical & Rehabilitation Theme) เน้นโทนสีที่อ่านง่าย สบายตา เหมาะสำหรับผู้ป่วยทางสมองและกล้ามเนื้ออ่อนแรง

---

## 📌 PHASE 2: การพัฒนาหน้าจอหลักและระบบฟอร์ม 3 สเต็ป (The Stepper Registration UI)
ไฮไลท์เด่นของฝั่งหน้าบ้านคือการเปลี่ยนหน้าสมัครสมาชิกธรรมดาให้กลายเป็น **Multi-Step Form** เพื่อไม่ให้ผู้ป่วยต้องกรอกข้อมูลล้นทะลักในหน้าเดียว:

* **Step 1: Account Information (ข้อมูลบัญชีขั้นพื้นฐาน)**
  * ออกแบบฟิลด์กรอก: ชื่อ (`firstname`), นามสกุล (`lastname`), อีเมล (`email`), เบอร์โทร (`phone`), และรหัสผ่าน (`password`)
* **Step 2: Patient Health Info & Medical Link (ประวัติสุขภาพและการผูกแพทย์)**
  * ออกแบบฟิลด์เก็บประวัติเชิงลึก: อายุ (`age`), เพศ (`gender` - Dropdown/Radio), และอาการผู้ป่วย (`symptoms` - Textfield ขนาดใหญ่)
  * เพิ่มช่องสำหรับใส่เบอร์ติดต่อฉุกเฉิน (`emergency_phone`) เพื่อความปลอดภัยของผู้ป่วยตอนนำถุงมือไปฝึกที่บ้าน
  * เพิ่มช่องกรอก **รหัสแพทย์ (`doctor_code`)** เพื่อเตรียมส่งไปให้หลังบ้านค้นหาตัวตนของคุณหมอประจำตัว
* **Step 3: Device Pairing (การผูกสัมพันธ์อุปกรณ์มือกล IoT)**
  * ออกแบบหน้าจอเชื่อมต่อและกรอกข้อมูลถุงมือกลและแขนหุ่นยนต์ฟื้นฟู
  * มีฟิลด์รองรับ: รหัสซีเรียลบอร์ดเดนิวเคลียส (`serial_number`) และชื่อเรียกอุปกรณ์ (`device_name`) เช่น ถุงมือฝึกมือซ้าย, แขนกล A1

---

## 📌 PHASE 3: โครงสร้างไฟล์และหน้าจอที่สแตนด์บายรอพัฒนาต่อ (Current Frontend Status)

### 🛠️ สิ่งที่ทำเสร็จแล้ว / โครงสร้างที่มีแล้ว (Completed UI Layouts)
* [x] ออกแบบโครงสร้างหน้าจอลงทะเบียนแบบ 3 สเต็ปบน UI เรียบร้อยแล้ว
* [x] ออกแบบโมเดลรับค่าฝั่งคนไข้เพื่อเตรียมส่งต่อ

### ⏳ สิ่งที่กำลังจะทำต่อไป (Next Steps ฝั่ง Flutter)
* [ ] **ตัดฟิลด์ที่ไม่จำเป็นออก:** ถอดช่องเลือก `role` หรือ `status` ออกจาก UI ฝั่งหน้าบ้าน (ให้หลังบ้านเป็นคนจัดการล็อกค่า `0` ให้เองตามข้อตกลง)
* [ ] **ผูกตัวแปรส่งค่า (Mapping Request Body):** ยุบรวมตัวแปรจากฟอร์มทั้ง 3 สเต็ปมารวมเป็น Object ก้อนเดียวให้ตรงกับ JSON ตัวล่าสุดของหลังบ้าน
* [ ] **เขียนฟังก์ชันเชื่อมต่อเครือข่าย (HTTP POST request):** ใช้คำสั่งยิง `POST` ยัดข้อมูล 3 สเต็ปไปที่ `http://<IP_หลังบ้าน>:5000/api/user/register`
* [ ] **ระบบตรวจสอบการตอบกลับ (Response Handling):** เขียนเงื่อนไขดักจับ หากสมัครสำเร็จ (`status == "success"`) ให้เด้ง Navigator พาวิ่งไปหน้า `Login` หรือหน้าหลักทันที แต่ถ้าอีเมลซ้ำให้โชว์ AlertDialog เตือนผู้ใช้งาน

---
### 📅 บันทึกความคืบหน้า (อัปเดตล่าสุด: 25 มิ.ย. 2569)

#### 🎨 [UI/UX & Logic อัปเดตพาร์ทหน้าบ้าน - Client App]
* [x] **ระบบ Smart Device Card (หน้า Dashboard หลัก):** * เปลี่ยนโครงสร้างมาใช้ `InkWell` ครอบ `Container` แทน `GestureDetector` เพื่อบังคับเคอร์เซอร์เมาส์เป็น **"รูปมือคลิก (Pointer)"** บนระบบ Flutter Web
  * เพิ่มการใช้ `Expanded` คุม Layout ข้อความแจ้งเตือน เพื่อแก้ไขบั๊กตัวหนังสือล้นทะลุขอบจอขวา (`RenderFlex overflowed`)
  * ปรับ Logic ตัวแปร Mock Data หากยังไม่ผูกอุปกรณ์ (`mockDeviceSerialNumber = null`) ระบบจะแสดงสเตตัสสีส้มเตือนตา และเมื่อคลิกจะนำทาง (`Navigator.push`) สลับไปหน้าจอผูกอุปกรณ์โดยตรงแทนการขึ้น BottomSheet 
* [x] **ระบบสมัครสมาชิก (SignUpScreen - ฟอร์ม 3 สเต็ป):**
  * เพิ่มช่องเลือกอัปเดตอัปโหลดรูปภาพโปรไฟล์ผู้ป่วยวงกลมในสเต็ปที่ 1
  * เพิ่มระบบเลือกแพทย์ผู้เชี่ยวชาญประจำตัวในสเต็ปที่ 2 โดยใช้คอมโพเนนต์ `Autocomplete` เพื่อให้ผู้ป่วยพิมพ์ค้นหากรองชื่อแพทย์ได้ทันที คุมขนาดความสูงกล่องผลลัพธ์ (`maxHeight: 200`) ไม่ให้ทะลุจอ รองรับกรณีโรงพยาบาลมีแพทย์จำนวนมาก 
* [x] **หน้าข้อมูลส่วนตัวผู้ป่วย (PatientInfoScreen):**
  * พัฒนาหน้าจอในรูปแบบสลับสถานะ (State) ระหว่าง โหมดดูปกติ (Read-Only) และโหมดแก้ไขข้อมูล (Edit Mode) เพื่อความปลอดภัยของข้อมูล
  * ผูกระบบค้นหาชื่อแพทย์ด้วย `Autocomplete` แบบเดียวกับหน้าสมัครสมาชิก เพื่อให้คนไข้สามารถพิมพ์กดสลับเคสเปลี่ยนแพทย์ประจำตัวได้ตามสถานการณ์จริง
  * ล็อกฟิลด์สำคัญ (ชื่อ-นามสกุล, โรคประจำตัว) ให้เป็นแบบอ่านอย่างเดียว เพื่อป้องกันการแก้ไขข้อมูลเชิงการแพทย์ที่คลาดเคลื่อน
* [x] **ระบบการแจ้งเตือน (NotificationPage):**
  * ขึ้นโครงสร้างหน้าประวัติแจ้งเตือนย้อนหลัง (เปิดจากไอคอนกระดิ่งมุมบนขวา) แยกการแสดงผลสถานะที่ยังไม่ได้เปิดอ่านด้วยจุดไข่ปลาสีฟ้า (`isUnread: true`) เลียนแบบโครงสร้างสากล

  # 📝 Smart Mechanical Hand - Development Progress Log

**วันที่บันทึก:** 26 มิถุนายน 2569
**สถานะโครงการ:** ฝั่งคุณหมอ (Doctor Panel) ขึ้นโครงสร้าง UI และ Logic การนำทางเสร็จสมบูรณ์ 100% (Ready for API Integration)

---

## 🛠️ รายการงานที่พัฒนาเสร็จสิ้น (Completed Tasks)

### 1. หน้าจอหลักคุณหมอ (Doctor Dashboard & Navigation)
* **[UI]** ถอดแถบ Topbar เก่าออก แล้วเปลี่ยนมาใช้ **Bottom Navigation Bar** สไตล์สีส้มอิฐ-น้ำตาล คลีนและกดใช้งานง่ายด้วยมือเดียว
* **[Component]** การ์ดสรุปยอดผู้ป่วยทั้งหมด และผู้ป่วยที่ต้องดูแลด่วน แสดงผลแถวบนสุดอย่างชัดเจน
* **[Feature]** ช่องพิมพ์ค้นหาข้อมูลผู้ป่วย (Search Bar) แบบ Real-time กรองข้อมูลตามชื่อและอาการ
* **[Feature]** ปุ่มไอคอน **Refresh แบบหมุน (Rotation Transition)** จัดวางระนาบเดียวกับช่องค้นหา เพิ่มความลื่นไหลให้ UI และพร้อมดัก Event เพื่อดึงข้อมูลล่าสุดจาก MySQL

### 2. หน้าจอประวัติฝึกภาพรวม (All Patients History Log)
* **[UI]** บันทึกไทม์ไลน์ (Timeline Feed) รายการฝึกซ้อมล่าสุดของผู้ป่วยทุกคนในการดูแลรวมกันในที่เดียว
* **[Feature]** ระบบ **Cross-Referencing** เมื่อคุณหมอกดจิ้มที่การ์ดประวัติฝึกของคนไข้คนใดคนหนึ่ง จะเปิดวาร์ป (Navigator.push) พุ่งตรงสู่หน้าจอรายงานเชิงลึกของคนไข้คนนั้นทันทีโดยไม่ต้องสลับแท็บไปค้นหาใหม่

### 3. หน้าจอรายงานผลฟื้นฟูรายบุคคล (Patient Detail Screen)
* **[UI]** การ์ดโปรไฟล์ส่วนตัวของผู้ป่วย (ชื่อ, อายุ, รหัสผู้ป่วย, และคำวินิจฉัยโรค)
* **[Component]** **กราฟเส้นพัฒนาการ (Line Chart จากแพ็กเกจ `fl_chart`)** แสดงแนวโน้มองศาการงอ-เหยียด (0° - 180°) แยกตามเซสชันฝึก พร้อมปุ่มขอบมนดึง Dropdown สลับดูสถิติแยกทีละนิ้วมือ (นิ้วโป้ง - นิ้วก้อย)
* **[Feature]** แท็บเม็ดยา (Capsule Tab) สลับตัวเลขสรุปสถิติตามช่วงเวลา **รายวัน / รายสัปดาห์ / รายเดือน** เชื่อมโยงกับ Dropdown เลือกคัดกรองตามเดือนและปี (2568 - 2569) ปลอดภัยด้วยกลไก Null-Safety บน Flutter Web

### 4. หน้าจอจัดการข้อมูลส่วนตัว (Edit Profile Screen)
* **[UI]** หน้าฟอร์มกรอกข้อมูลโปรไฟล์ของคุณหมอ ประกอบด้วย: ชื่อ-นามสกุล, โรงพยาบาลต้นสังกัด, เลขที่ใบประกอบวิชาชีพเวชกรรม (รบ.), และอีเมลติดต่อ
* **[Feature]** ระบบ Form Validation ตรวจเช็คค่าว่างก่อนกดบันทึกข้อมูล พร้อมปุ่มออกจากระบบ (Logout) เด้งสเตตัสกลับสู่หน้า Login หลัก

---

## 📦 แพ็กเกจที่ใช้งานในโปรเจกต์ (Dependencies)

ต้องตรวจสอบให้มั่นใจว่าในไฟล์ `pubspec.yaml` มีการติดตั้งแพ็กเกจเหล่านี้เรียบร้อยแล้ว:

```yaml
dependencies:
  flutter:
    sdk: flutter
  fl_chart: ^0.70.0 # แพ็กเกจสำหรับวาดกราฟเส้นสถิตลองศานิ้วมือ

  #test git push

  จัดเอกสารสรุปรายละเอียดการพัฒนาระบบ **Forgot Password (2-Step Verification)** ในรูปแบบ Markdown (`.md`) ให้เรียบร้อยครับสหาย! คุณสามารถก๊อปปี้ข้อความด้านล่างนี้ไปบันทึกเป็นไฟล์ `FORGOT_PASSWORD_DOCS.md` ในโปรเจกต์ได้เลยครับ 🚀📝✨

---

```markdown
# 🔑 เอกสารพัฒนาระบบ Forgot Password (2-Step Verification)

เอกสารสรุปโครงสร้างและการพัฒนาระบบกู้คืนรหัสผ่านสำหรับแอปพลิเคชันมือกลและแอปพลิเคชันเพื่อสุขภาพ (**Smart Mechanical Hand**) 

---

## 📌 ภาพรวมการทำงาน (Workflow)

ระบบแบ่งออกเป็น **2 ขั้นตอนหลัก** เพื่อความปลอดภัยและการใช้งานที่ลื่นไหล (UX/UI):

```text
[Step 1: Verify Identity] 
  └── กรอก Email + Phone ➔ ยิง API ตรวจสอบ
        ├── ❌ ไม่พบข้อมูล: แสดง Modal แจ้งเตือน และให้กรอกใหม่
        └── ✅ พบข้อมูล: แสดง Modal ยืนยันตัวตน (โชว์ชื่อผู้ใช้) ➔ กด "ยืนยัน" 
              └── [Step 2: Reset Password]
                    └── กรอกรหัสผ่านใหม่ + ยืนยัน ➔ บันทึกลง MySQL ➔ กลับหน้า SignIn

```

---

## 📂 โครงสร้างไฟล์ในโปรเจกต์ (Project Structure)

```text
lib/
├── widgets/
│   └── forgot_password/
│       ├── verify_identity_step.dart    # 📝 Component สเต็ปที่ 1 (กรอก Email & Phone)
│       ├── reset_password_step.dart     # 📝 Component สเต็ปที่ 2 (กรอก รหัสผ่านใหม่)
│       └── forgot_password_dialogs.dart # 🚨 Dialogs (ไม่พบข้อมูล / ยืนยันตัวตน / สำเร็จ)
├── screens/
│   ├── signin_screen.dart               # 🔑 หน้าเข้าสู่ระบบ (เพิ่มปุ่ม "ลืมรหัสผ่าน?")
│   └── forgot_password_screen.dart      # 🏠 หน้าหลัก ควบคุม State & Logic ยิง API
└── api/
    └── auth_service.dart                # 🔌 ฟังก์ชันยิง API ไปยัง Backend

```

---

## 🌐 1. Backend Endpoints (Express / Node.js)

### 1.1 `POST /api/user/verify-identity`

* **คำอธิบาย:** ตรวจสอบว่ามีผู้ใช้อยู่ในฐานข้อมูลหรือไม่
* **Request Body:**
```json
{
  "email": "somsri.newtest@gmail.com",
  "phone": "0823456789"
}

```


* **Response (200 OK):**
```json
{
  "status": "success",
  "message": "ยืนยันตัวตนสำเร็จ",
  "userId": 12,
  "firstname": "สมศรี"
}

```



### 1.2 `POST /api/user/reset-password`

* **คำอธิบาย:** อัปเดตรหัสผ่านใหม่ลงคอลัมน์ `password` ในตาราง `user`
* **Request Body:**
```json
{
  "userId": 12,
  "newPassword": "newpassword123"
}

```


* **Response (200 OK):**
```json
{
  "status": "success",
  "message": "รีเซ็ตรหัสผ่านใหม่เรียบร้อยแล้ว!"
}

```



---

## 🛠️ 2. โค้ดส่วนประกอบหลัก (Flutter Frontend)

### 2.1 `lib/api/auth_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:5000/api';

  // 1. ยิงตรวจสอบตัวตนด้วย Email + Phone
  static Future<Map<String, dynamic>> verifyIdentity({
    required String email,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/verify-identity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'phone': phone}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'userId': data['userId'],
          'firstname': data['firstname'],
        };
      } else {
        return {'success': false, 'message': data['error'] ?? 'ไม่พบข้อมูลในระบบ'};
      }
    } catch (e) {
      return {'success': false, 'message': 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้: $e'};
    }
  }

  // 2. ยิงอัปเดตรหัสผ่านใหม่
  static Future<Map<String, dynamic>> resetPassword({
    required int userId,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'newPassword': newPassword}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'รีเซ็ตสำเร็จ'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'เกิดข้อผิดพลาด'};
      }
    } catch (e) {
      return {'success': false, 'message': 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้: $e'};
    }
  }
}

```

---

### 2.2 `lib/widgets/forgot_password/forgot_password_dialogs.dart`

```dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordDialogs {
  // 🚨 Modal กรณีไม่พบบัญชีในระบบ
  static void showNotFoundDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('ไม่พบข้อมูล', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ✅ Modal ยืนยันชื่อผู้ใช้ก่อนไปหน้าสเต็ป 2
  static void showConfirmIdentityDialog({
    required BuildContext context,
    required String userName,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('ยืนยันตัวตนสำเร็จ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'พบข้อมูลบัญชีของคุณ "$userName"\n\nคุณต้องการดำเนินการสร้างรหัสผ่านใหม่ใช่หรือไม่?',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('ยืนยัน', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 🎉 Modal แสดงความยินดีเมื่อตั้งรหัสผ่านใหม่สำเร็จ
  static void showSuccessDialog(BuildContext context, VoidCallback onSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('สำเร็จ'),
          ],
        ),
        content: const Text('ตั้งรหัสผ่านใหม่เรียบร้อยแล้ว กรุณาเข้าสู่ระบบอีกครั้งด้วยรหัสผ่านใหม่'),
        actions: [
          TextButton(
            onPressed: onSuccess,
            child: const Text('ตกลง', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

```

---

## 🎯 สรุปผลการทดสอบ (Testing Checkpoints)

1. **กรณีใส่ Email / Phone ผิดหรือไม่มีในระบบ:**
* [x] ต้องเด้ง Modal สีแดงว่า "ไม่พบข้อมูล"
* [x] กด "ตกลง" แล้วปิด Dialog เพื่อให้ผู้ใช้แก้ไขข้อมูลในหน้าเดิมได้


2. **กรณีใส่ Email / Phone ถูกต้อง:**
* [x] ต้องเด้ง Modal สีเขียว "พบข้อมูลบัญชีของคุณ [ชื่อผู้ป่วย]"
* [x] กด "ยืนยัน" แล้วสลับไปยังหน้า Step 2 (ตั้งรหัสผ่านใหม่)


3. **กรณีตั้งรหัสผ่านใหม่เรียบร้อย:**
* [x] บันทึกข้อมูลเข้า MySQL สำเร็จ
* [x] เด้ง Modal สำเร็จ ➔ กด "ตกลง" แล้วเด้งกลับหน้า SignIn



```

```