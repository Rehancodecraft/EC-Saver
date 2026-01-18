import '../models/user_profile.dart';
import '../models/emergency.dart';
import '../models/off_day.dart';
import 'database_service.dart';

class WebStorageService implements DatabaseService {
  @override
  Future<void> close() {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteEmergency(int id) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteEmergenciesByMonth(String monthYear) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteMonthRecords(String monthYear) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteOffDay(int id) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteOffDayByDate(DateTime date) {
    throw UnimplementedError();
  }

  @override
  Future<List<Emergency>> filterEmergenciesByType(String type) {
    throw UnimplementedError();
  }

  @override
  Future<List<Emergency>> getAllEmergencies() {
    throw UnimplementedError();
  }

  @override
  Future<List<Emergency>> getEmergencies() {
    throw UnimplementedError();
  }

  @override
  Future<OffDay?> getOffDayByDate(DateTime date) {
    throw UnimplementedError();
  }

  @override
  Future<List<OffDay>> getOffDays() {
    throw UnimplementedError();
  }

  @override
  Future<List<OffDay>> getOffDaysByMonth(String monthYear) {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile?> getUserProfile() {
    throw UnimplementedError();
  }

  @override
  Future<int> insertFeedback(String name, String message) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isOffDay(DateTime date) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isUserRegistered() {
    throw UnimplementedError();
  }

  @override
  Future<int> saveEmergency(Emergency emergency) {
    throw UnimplementedError();
  }

  @override
  Future<int> saveOffDay(OffDay offDay) {
    throw UnimplementedError();
  }

  @override
  Future<int> saveUserProfile(UserProfile profile) {
    throw UnimplementedError();
  }

  @override
  Future<List<Emergency>> searchEmergencies(String query) {
    throw UnimplementedError();
  }
}
