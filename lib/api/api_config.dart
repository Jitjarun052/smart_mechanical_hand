class ApiConfig {
  
  // static const String host = '10.29.16.212:5000';     
  static const String host = '192.168.1.119:5000';     

  // 🔗 URL หลัก (นำ host ข้างบนมาต่ออัตโนมัติ)
  static const String baseUrl = 'http://$host/api';
  static const String imageBaseUrl = 'http://$host/uploads';

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