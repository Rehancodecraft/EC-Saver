/// Stub implementation for non-web platforms
class WebStorageService {
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    throw UnsupportedError('Web storage not available on this platform');
  }
  
  static Future<Map<String, dynamic>?> getUserProfile() async {
    throw UnsupportedError('Web storage not available on this platform');
  }
  
  static Future<void> saveEmergency(Map<String, dynamic> emergency) async {
    throw UnsupportedError('Web storage not available on this platform');
  }
  
  static Future<List<Map<String, dynamic>>> getEmergencies() async {
    throw UnsupportedError('Web storage not available on this platform');
  }
  
  static Future<List<Map<String, dynamic>>> searchEmergencies(String query) async {
    throw UnsupportedError('Web storage not available on this platform');
  }
  
  static Future<void> deleteMonthEmergencies(String monthYear) async {
    throw UnsupportedError('Web storage not available on this platform');
  }
  
  static Future<void> clearAll() async {
    throw UnsupportedError('Web storage not available on this platform');
  }
}
