import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:convert';

/// Web-specific storage service using localStorage
class WebStorageService {
  static const String _storageKey = 'rescue_1122_data';
  
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    if (!kIsWeb) return;
    
    try {
      final data = await _loadAllData();
      data['userProfile'] = profile;
      await _saveAllData(data);
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }
  
  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (!kIsWeb) return null;
    
    try {
      final data = await _loadAllData();
      return data['userProfile'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }
  
  static Future<void> saveEmergency(Map<String, dynamic> emergency) async {
    if (!kIsWeb) return;
    
    try {
      final data = await _loadAllData();
      final emergencies = List<Map<String, dynamic>>.from(
        data['emergencies'] ?? []
      );
      emergencies.add(emergency);
      data['emergencies'] = emergencies;
      await _saveAllData(data);
    } catch (e) {
      print('Error saving emergency: $e');
    }
  }
  
  static Future<List<Map<String, dynamic>>> getEmergencies() async {
    if (!kIsWeb) return [];
    
    try {
      final data = await _loadAllData();
      return List<Map<String, dynamic>>.from(data['emergencies'] ?? []);
    } catch (e) {
      print('Error loading emergencies: $e');
      return [];
    }
  }
  
  static Future<List<Map<String, dynamic>>> searchEmergencies(String query) async {
    final all = await getEmergencies();
    if (query.isEmpty) return all;
    
    return all.where((e) {
      final ecNumber = e['ec_number']?.toString().toLowerCase() ?? '';
      final location = e['location']?.toString().toLowerCase() ?? '';
      final notes = e['notes']?.toString().toLowerCase() ?? '';
      final searchLower = query.toLowerCase();
      
      return ecNumber.contains(searchLower) ||
             location.contains(searchLower) ||
             notes.contains(searchLower);
    }).toList();
  }
  
  static Future<void> deleteMonthEmergencies(String monthYear) async {
    if (!kIsWeb) return;
    
    try {
      final data = await _loadAllData();
      final emergencies = List<Map<String, dynamic>>.from(
        data['emergencies'] ?? []
      );
      
      emergencies.removeWhere((e) {
        final dateTime = DateTime.tryParse(e['emergency_date'] ?? '');
        if (dateTime == null) return false;
        final eMonthYear = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}';
        return eMonthYear == monthYear;
      });
      
      data['emergencies'] = emergencies;
      await _saveAllData(data);
    } catch (e) {
      print('Error deleting month emergencies: $e');
    }
  }
  
  static Future<Map<String, dynamic>> _loadAllData() async {
    try {
      final jsonString = html.window.localStorage[_storageKey];
      if (jsonString == null || jsonString.isEmpty) {
        return {};
      }
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading data: $e');
      return {};
    }
  }
  
  static Future<void> _saveAllData(Map<String, dynamic> data) async {
    try {
      final jsonString = json.encode(data);
      html.window.localStorage[_storageKey] = jsonString;
    } catch (e) {
      print('Error saving data: $e');
      throw e;
    }
  }
  
  static Future<void> clearAll() async {
    if (!kIsWeb) return;
    html.window.localStorage.remove(_storageKey);
  }
}
