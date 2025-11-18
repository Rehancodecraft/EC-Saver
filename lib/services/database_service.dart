import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '../models/emergency.dart';
import '../models/monthly_stats.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite is not supported on web. Using localStorage instead.'
      );
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create user_profile table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.userProfileTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        designation TEXT NOT NULL,
        district TEXT NOT NULL,
        tehsil TEXT NOT NULL,
        mobile_number TEXT NOT NULL,
        registration_date TEXT NOT NULL,
        is_verified INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create emergencies table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.emergenciesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ec_number TEXT NOT NULL UNIQUE,
        emergency_date TEXT NOT NULL,
        emergency_type TEXT NOT NULL,
        location TEXT,
        notes TEXT,
        is_late_entry INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        created_by INTEGER NOT NULL,
        FOREIGN KEY (created_by) REFERENCES ${DatabaseConstants.userProfileTable} (id)
      )
    ''');

    // Create indexes
    await db.execute('''
      CREATE INDEX idx_ec_number ON ${DatabaseConstants.emergenciesTable}(ec_number)
    ''');

    await db.execute('''
      CREATE INDEX idx_emergency_date ON ${DatabaseConstants.emergenciesTable}(emergency_date)
    ''');

    // Create monthly_stats table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.monthlyStatsTable} (
        month_year TEXT PRIMARY KEY,
        total_count INTEGER NOT NULL DEFAULT 0,
        bike_accident_count INTEGER NOT NULL DEFAULT 0,
        car_accident_count INTEGER NOT NULL DEFAULT 0,
        fire_count INTEGER NOT NULL DEFAULT 0,
        other_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create feedback table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.feedbackTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // User Profile Methods
  Future<bool> isUserRegistered() async {
    if (kIsWeb) return false;
    
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.userProfileTable,
        limit: 1,
      );
      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking registration: $e');
      return false;
    }
  }

  Future<UserProfile?> getUserProfile() async {
    if (kIsWeb) return null;
    
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.userProfileTable,
        limit: 1,
      );
      
      if (maps.isEmpty) return null;
      return UserProfile.fromMap(maps.first);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<int> saveUserProfile(UserProfile profile) async {
    if (kIsWeb) return 1;
    
    try {
      final db = await database;
      return await db.insert(
        DatabaseConstants.userProfileTable,
        profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  // Alias for saveUserProfile (for registration screen)
  Future<int> insertUserProfile(UserProfile profile) async {
    return await saveUserProfile(profile);
  }

  // Emergency Methods
  Future<int> saveEmergency(Emergency emergency) async {
    if (kIsWeb) return 1;
    
    try {
      final db = await database;
      
      // Check for duplicate EC number
      final existing = await db.query(
        DatabaseConstants.emergenciesTable,
        where: 'ec_number = ?',
        whereArgs: [emergency.ecNumber],
      );
      
      if (existing.isNotEmpty) {
        throw Exception('EC number ${emergency.ecNumber} already exists');
      }
      
      final id = await db.insert(
        DatabaseConstants.emergenciesTable,
        emergency.toMap(),
      );
      
      await _updateMonthlyStats(emergency);
      
      return id;
    } catch (e) {
      print('Error saving emergency: $e');
      rethrow;
    }
  }

  Future<List<Emergency>> getEmergencies({
    String? monthYear,
    String? searchQuery,
    String? filterType,
  }) async {
    if (kIsWeb) return [];
    
    try {
      final db = await database;
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (monthYear != null) {
        whereClause = "strftime('%Y-%m', emergency_date) = ?";
        whereArgs.add(monthYear);
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        if (whereClause.isNotEmpty) {
          whereClause += ' AND ';
        }
        whereClause += '(ec_number LIKE ? OR location LIKE ? OR notes LIKE ?)';
        final searchPattern = '%$searchQuery%';
        whereArgs.addAll([searchPattern, searchPattern, searchPattern]);
      }
      
      if (filterType != null && filterType != 'All') {
        if (whereClause.isNotEmpty) {
          whereClause += ' AND ';
        }
        whereClause += 'emergency_type = ?';
        whereArgs.add(filterType);
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.emergenciesTable,
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'emergency_date DESC, id DESC',
      );
      
      return List.generate(maps.length, (i) => Emergency.fromMap(maps[i]));
    } catch (e) {
      print('Error getting emergencies: $e');
      return [];
    }
  }

  // Alias methods for RecordsScreen compatibility
  Future<List<Emergency>> getAllEmergencies() async {
    return await getEmergencies();
  }

  Future<List<Emergency>> searchEmergencies(String query) async {
    return await getEmergencies(searchQuery: query);
  }

  Future<List<Emergency>> filterEmergenciesByType(String type) async {
    return await getEmergencies(filterType: type);
  }

  Future<void> deleteEmergency(int id) async {
    if (kIsWeb) return;
    
    try {
      final db = await database;
      await db.delete(
        DatabaseConstants.emergenciesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting emergency: $e');
      rethrow;
    }
  }

  Future<void> deleteMonthEmergencies(String monthYear) async {
    if (kIsWeb) return;
    
    try {
      final db = await database;
      await db.delete(
        DatabaseConstants.emergenciesTable,
        where: "strftime('%Y-%m', emergency_date) = ?",
        whereArgs: [monthYear],
      );
      
      await db.delete(
        DatabaseConstants.monthlyStatsTable,
        where: 'month_year = ?',
        whereArgs: [monthYear],
      );
    } catch (e) {
      print('Error deleting month emergencies: $e');
      rethrow;
    }
  }

  // Alias for deleteMonthEmergencies (for RecordsScreen)
  Future<void> deleteEmergenciesByMonth(String monthYear) async {
    return await deleteMonthEmergencies(monthYear);
  }

  Future<void> _updateMonthlyStats(Emergency emergency) async {
    try {
      final db = await database;
      final monthYear = emergency.getMonthYear();
      
      final existing = await db.query(
        DatabaseConstants.monthlyStatsTable,
        where: 'month_year = ?',
        whereArgs: [monthYear],
      );
      
      if (existing.isEmpty) {
        await db.insert(
          DatabaseConstants.monthlyStatsTable,
          {
            'month_year': monthYear,
            'total_count': 1,
            'bike_accident_count': emergency.emergencyType == 'Bike Accident' ? 1 : 0,
            'car_accident_count': emergency.emergencyType == 'Car Accident' ? 1 : 0,
            'fire_count': emergency.emergencyType == 'Fire Emergency' ? 1 : 0,
            'other_count': emergency.emergencyType == 'Other Emergency' ? 1 : 0,
          },
        );
      } else {
        final stats = existing.first;
        await db.update(
          DatabaseConstants.monthlyStatsTable,
          {
            'total_count': (stats['total_count'] as int) + 1,
            'bike_accident_count': (stats['bike_accident_count'] as int) + 
                (emergency.emergencyType == 'Bike Accident' ? 1 : 0),
            'car_accident_count': (stats['car_accident_count'] as int) + 
                (emergency.emergencyType == 'Car Accident' ? 1 : 0),
            'fire_count': (stats['fire_count'] as int) + 
                (emergency.emergencyType == 'Fire Emergency' ? 1 : 0),
            'other_count': (stats['other_count'] as int) + 
                (emergency.emergencyType == 'Other Emergency' ? 1 : 0),
          },
          where: 'month_year = ?',
          whereArgs: [monthYear],
        );
      }
    } catch (e) {
      print('Error updating monthly stats: $e');
    }
  }

  Future<Map<String, int>> getMonthlyStats(String monthYear) async {
    if (kIsWeb) {
      return {'total': 0, 'bike': 0, 'car': 0, 'fire': 0, 'other': 0};
    }
    
    try {
      final db = await database;
      final result = await db.query(
        DatabaseConstants.monthlyStatsTable,
        where: 'month_year = ?',
        whereArgs: [monthYear],
      );
      
      if (result.isEmpty) {
        return {'total': 0, 'bike': 0, 'car': 0, 'fire': 0, 'other': 0};
      }
      
      final stats = result.first;
      return {
        'total': stats['total_count'] as int,
        'bike': stats['bike_accident_count'] as int,
        'car': stats['car_accident_count'] as int,
        'fire': stats['fire_count'] as int,
        'other': stats['other_count'] as int,
      };
    } catch (e) {
      print('Error getting monthly stats: $e');
      return {'total': 0, 'bike': 0, 'car': 0, 'fire': 0, 'other': 0};
    }
  }

  // Feedback Methods
  Future<int> saveFeedback(String name, String message) async {
    if (kIsWeb) return 1;
    
    try {
      final db = await database;
      return await db.insert(
        DatabaseConstants.feedbackTable,
        {
          'name': name,
          'message': message,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error saving feedback: $e');
      rethrow;
    }
  }

  // Alias for saveFeedback (for FeedbackScreen)
  Future<int> insertFeedback(String name, String message) async {
    return await saveFeedback(name, message);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
