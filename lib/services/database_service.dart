import '../models/user_profile.dart';
import '../models/emergency.dart';
import '../models/off_day.dart';
import 'mobile_database_service.dart';

abstract class DatabaseService {
  // Mobile-only app - always use SQLite database
  factory DatabaseService() {
    return MobileDatabaseService();
  }

  Future<int> saveUserProfile(UserProfile profile);
  Future<UserProfile?> getUserProfile();
  Future<bool> isUserRegistered();
  Future<int> saveEmergency(Emergency emergency);
  Future<List<Emergency>> getEmergencies();
  Future<List<Emergency>> getAllEmergencies();
  Future<List<Emergency>> searchEmergencies(String query);
  Future<List<Emergency>> filterEmergenciesByType(String type);
  Future<void> deleteEmergency(int id);
  Future<void> deleteEmergenciesByMonth(String monthYear);
  Future<void> deleteMonthRecords(String monthYear);
  Future<int> insertFeedback(String name, String message);
  Future<int> saveOffDay(OffDay offDay);
  Future<List<OffDay>> getOffDays();
  Future<List<OffDay>> getAllOffDays();
  Future<List<OffDay>> getOffDaysByMonth(String monthYear);
  Future<OffDay?> getOffDayByDate(DateTime date);
  Future<bool> isOffDay(DateTime date);
  Future<void> deleteOffDay(int id);
  Future<void> deleteOffDayByDate(DateTime date);
  Future<void> close();
}
