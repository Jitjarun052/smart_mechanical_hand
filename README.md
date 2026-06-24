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
