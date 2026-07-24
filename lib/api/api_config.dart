class ApiConfig {
  // 🌐 ปรับเปลี่ยน IP ตามสภาพแวดล้อม
  static const String baseUrl = 'http://localhost:5000/api';
  static const String imageBaseUrl = 'http://localhost:5000/uploads';

  // 📝 Standard Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  // 📸 ฟังก์ชันช่วยสร้าง Image URL
  static String getImageUrl(String? imageName) {
    if (imageName == null || imageName.isEmpty) return '';
    return '$imageBaseUrl/$imageName';
  }
}