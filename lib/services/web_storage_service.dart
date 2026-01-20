import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/emergency.dart';
import '../models/off_day.dart';
import 'database_service.dart';

class WebStorageService implements DatabaseService {
  static final WebStorageService _instance = WebStorageService._internal();
  factory WebStorageService() => _instance;
  WebStorageService._internal();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // User Profile Methods
  @override
  Future<int> saveUserProfile(UserProfile profile) async {
    final prefs = await _prefs;
    final userProfileJson = jsonEncode(profile.toMap());
    await prefs.setString('user_profile', userProfileJson);
    return 1;
  }

  @override
  Future<UserProfile?> getUserProfile() async {
    final prefs = await _prefs;
    final userProfileJson = prefs.getString('user_profile');
    if (userProfileJson == null) {
      return null;
    }
    return UserProfile.fromMap(jsonDecode(userProfileJson));
  }

  @override
  Future<bool> isUserRegistered() async {
    final profile = await getUserProfile();
    return profile != null;
  }

  // Emergency Methods
  @override
  Future<int> saveEmergency(Emergency emergency) async {
    final prefs = await _prefs;
    final emergencies = await getEmergencies();
    
    if (emergencies.any((e) => e.ecNumber == emergency.ecNumber)) {
      throw Exception('EC number ${emergency.ecNumber} already exists');
    }

    emergencies.add(emergency);
    final emergenciesJson = jsonEncode(emergencies.map((e) => e.toMap()).toList());
    await prefs.setString('emergencies', emergenciesJson);
    return emergency.id ?? 0;
  }

  @override
  Future<List<Emergency>> getEmergencies() async {
    final prefs = await _prefs;
    final emergenciesJson = prefs.getString('emergencies');
    if (emergenciesJson == null) {
      return [];
    }
    final List<dynamic> emergenciesList = jsonDecode(emergenciesJson);
    return emergenciesList.map((e) => Emergency.fromMap(e)).toList();
  }

  @override
  Future<List<Emergency>> getAllEmergencies() async {
    return await getEmergencies();
  }

  @override
  Future<List<Emergency>> searchEmergencies(String query) async {
    final emergencies = await getEmergencies();
    return emergencies.where((e) => 
      e.ecNumber.toLowerCase().contains(query.toLowerCase()) ||
      (e.notes?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      (e.location?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  @override
  Future<List<Emergency>> filterEmergenciesByType(String type) async {
    final emergencies = await getEmergencies();
    return emergencies.where((e) => e.emergencyType.toLowerCase() == type.toLowerCase()).toList();
  }

  @override
  Future<void> deleteEmergency(int id) async {
    final prefs = await _prefs;
    final emergencies = await getEmergencies();
    emergencies.removeWhere((e) => e.id == id);
    final emergenciesJson = jsonEncode(emergencies.map((e) => e.toMap()).toList());
    await prefs.setString('emergencies', emergenciesJson);
  }

  @override
  Future<void> deleteEmergenciesByMonth(String monthYear) async {
    final prefs = await _prefs;
    final emergencies = await getEmergencies();
    emergencies.removeWhere((e) => e.getMonthYear() == monthYear);
    final emergenciesJson = jsonEncode(emergencies.map((e) => e.toMap()).toList());
    await prefs.setString('emergencies', emergenciesJson);
  }

  @override
  Future<void> deleteMonthRecords(String monthYear) async {
    await deleteEmergenciesByMonth(monthYear);
    
    final prefs = await _prefs;
    final offDays = await getOffDays();
    offDays.removeWhere((o) => o.getMonthYear() == monthYear);
    final offDaysJson = jsonEncode(offDays.map((o) => o.toMap()).toList());
    await prefs.setString('off_days', offDaysJson);
  }

  // Feedback Methods
  @override
  Future<int> insertFeedback(String name, String message) async {
    // Not implemented for web, as there's no corresponding UI
    return 0;
  }

  // Off Day Methods
  @override
  Future<int> saveOffDay(OffDay offDay) async {
    final prefs = await _prefs;
    final offDays = await getOffDays();
    offDays.add(offDay);
    final offDaysJson = jsonEncode(offDays.map((o) => o.toMap()).toList());
    await prefs.setString('off_days', offDaysJson);
    return offDay.id ?? 0;
  }

  @override
  Future<List<OffDay>> getOffDays() async {
    final prefs = await _prefs;
    final offDaysJson = prefs.getString('off_days');
    if (offDaysJson == null) {
      return [];
    }
    final List<dynamic> offDaysList = jsonDecode(offDaysJson);
    return offDaysList.map((o) => OffDay.fromMap(o)).toList();
  }

  @override
  Future<List<OffDay>> getOffDaysByMonth(String monthYear) async {
    final offDays = await getOffDays();
    return offDays.where((o) => o.getMonthYear() == monthYear).toList();
  }

  @override
  Future<OffDay?> getOffDayByDate(DateTime date) async {
    final offDays = await getOffDays();
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String().split('T')[0];
    try {
      return offDays.firstWhere((o) => o.offDate.toIso8601String().split('T')[0] == dateStr);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isOffDay(DateTime date) async {
    final offDay = await getOffDayByDate(date);
    return offDay != null;
  }

  @override
  Future<void> deleteOffDay(int id) async {
    final prefs = await _prefs;
    final offDays = await getOffDays();
    offDays.removeWhere((o) => o.id == id);
    final offDaysJson = jsonEncode(offDays.map((o) => o.toMap()).toList());
    await prefs.setString('off_days', offDaysJson);
  }

  @override
  Future<void> deleteOffDayByDate(DateTime date) async {
    final prefs = await _prefs;
    final offDays = await getOffDays();
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String().split('T')[0];
    offDays.removeWhere((o) => o.offDate.toIso8601String().split('T')[0] == dateStr);
    final offDaysJson = jsonEncode(offDays.map((o) => o.toMap()).toList());
    await prefs.setString('off_days', offDaysJson);
  }

  @override
  Future<void> close() async {
    // Not needed for shared_preferences
  }
}
