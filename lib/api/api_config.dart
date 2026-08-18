class ApiConfig {
  
  // static const String host = '10.29.16.212:5000';     
  // static const String host = '10.10.104.29:5000';     
  // static const String host = '10.143.115.212:5000';     
  // static const String host = 'localhost:5000';
  static const String host = 'glove.dogdac.com';     

  // 🔗 URL หลัก (นำ host ข้างบนมาต่ออัตโนมัติ)
  static const String baseUrl = 'https://$host/api';
  static const String imageBaseUrl = 'https://$host/uploads';

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