import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _storageKey = 'user_data';

  static Future<Map<String, String>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString != null) {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    }
    
    // Return default values
    return {
      'name': 'Isuru Pathirathna',
      'email': 'isuru2002@gmail.com',
      'phone': '+358 41 367 1742',
      'portfolio': 'https://isuru-portfolio-ten.vercel.app/',
      'whatsapp': 'https://wa.me/358413671742',
    };
  }

  static Future<bool> saveData(Map<String, String> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      return false;
    }
  }
}
