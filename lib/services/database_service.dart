import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_profile.dart';
import '../models/emergency.dart';
import '../models/monthly_stats.dart';
import '../models/off_day.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    // Always reinitialize to ensure migrations run on version change
    // This is important when app is updated
    if (_database != null) {
      // Check if database is still valid
      try {
        await _database!.rawQuery('SELECT 1');
        return _database!;
      } catch (e) {
        // Database might be invalid, reinitialize
        print('DEBUG: DatabaseService - Database invalid, reinitializing: $e');
        _database = null;
      }
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'emergency_cases.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        designation TEXT NOT NULL,
        district TEXT NOT NULL,
        tehsil TEXT NOT NULL,
        mobile_number TEXT NOT NULL UNIQUE,
        registration_date TEXT NOT NULL,
        is_verified INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE emergencies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ec_number TEXT NOT NULL UNIQUE,
        emergency_date TEXT NOT NULL,
        emergency_type TEXT NOT NULL,
        location TEXT,
        notes TEXT,
        is_late_entry INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        created_by INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE monthly_stats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month_year TEXT NOT NULL UNIQUE,
        total_count INTEGER NOT NULL DEFAULT 0,
        bike_accident_count INTEGER NOT NULL DEFAULT 0,
        car_accident_count INTEGER NOT NULL DEFAULT 0,
        fire_count INTEGER NOT NULL DEFAULT 0,
        other_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE feedback(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE off_days(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        off_date TEXT NOT NULL UNIQUE,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('DEBUG: Database upgrade from version $oldVersion to $newVersion');
    if (oldVersion < 2) {
      print('DEBUG: Migrating database from version $oldVersion to 2 - Adding off_days table');
      // Add off_days table for version 2
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS off_days(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            off_date TEXT NOT NULL UNIQUE,
            notes TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        print('DEBUG: Successfully created off_days table');
        
        // Verify the table was created
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='off_days'"
        );
        if (tables.isNotEmpty) {
          print('DEBUG: Verified off_days table exists');
        } else {
          print('ERROR: off_days table was not created!');
        }
      } catch (e) {
        print('ERROR: Failed to create off_days table: $e');
        rethrow;
      }
    } else {
      print('DEBUG: Database already at version $oldVersion, no migration needed');
    }
  }

  // User Profile Methods
  Future<int> saveUserProfile(UserProfile profile) async {
    try {
      final db = await database;
      
      // Check if user already exists
      final existing = await db.query('user_profile', limit: 1);
      if (existing.isNotEmpty) {
        print('DEBUG: User profile already exists, updating instead');
        // Update existing profile
        return await db.update(
          'user_profile',
          profile.toMap(),
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      }
      
      // Insert new profile
      return await db.insert(
        'user_profile',
        profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('DEBUG: saveUserProfile error: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final maps = await db.query('user_profile', limit: 1);
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  Future<bool> isUserRegistered() async {
    final profile = await getUserProfile();
    return profile != null;
  }

  // Emergency Methods
  Future<int> saveEmergency(Emergency emergency) async {
    final db = await database;
    
    final existing = await db.query(
      'emergencies',
      where: 'ec_number = ?',
      whereArgs: [emergency.ecNumber],
    );

    if (existing.isNotEmpty) {
      throw Exception('EC number ${emergency.ecNumber} already exists');
    }

    final id = await db.insert('emergencies', emergency.toMap());
    await _updateMonthlyStats(emergency);
    return id;
  }

  Future<List<Emergency>> getEmergencies() async {
    final db = await database;
    final maps = await db.query('emergencies', orderBy: 'emergency_date DESC');
    return List.generate(maps.length, (i) => Emergency.fromMap(maps[i]));
  }

  Future<List<Emergency>> getAllEmergencies() async {
    return await getEmergencies();
  }

  Future<List<Emergency>> searchEmergencies(String query) async {
    final db = await database;
    final maps = await db.query(
      'emergencies',
      where: 'ec_number LIKE ? OR notes LIKE ? OR location LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'emergency_date DESC',
    );
    return List.generate(maps.length, (i) => Emergency.fromMap(maps[i]));
  }

  Future<List<Emergency>> filterEmergenciesByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'emergencies',
      where: 'emergency_type = ?',
      whereArgs: [type],
      orderBy: 'emergency_date DESC',
    );
    return List.generate(maps.length, (i) => Emergency.fromMap(maps[i]));
  }

  Future<void> deleteEmergency(int id) async {
    final db = await database;
    await db.delete('emergencies', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteEmergenciesByMonth(String monthYear) async {
    await deleteMonthRecords(monthYear);
  }

  Future<void> deleteMonthRecords(String monthYear) async {
    final db = await database;
    
    final emergencies = await db.query(
      'emergencies',
      orderBy: 'emergency_date DESC',
    );

    for (final emergency in emergencies) {
      final date = DateTime.parse(emergency['emergency_date'] as String);
      final emergencyMonthYear = Emergency.fromMap(emergency).getMonthYear();
      
      if (emergencyMonthYear == monthYear) {
        await db.delete('emergencies', where: 'id = ?', whereArgs: [emergency['id']]);
      }
    }

    // Delete off days for this month
    final offDays = await getOffDays();
    for (final offDay in offDays) {
      if (offDay.getMonthYear() == monthYear) {
        await db.delete('off_days', where: 'id = ?', whereArgs: [offDay.id]);
      }
    }

    await db.delete('monthly_stats', where: 'month_year = ?', whereArgs: [monthYear]);
  }

  Future<void> _updateMonthlyStats(Emergency emergency) async {
    final db = await database;
    final monthYear = emergency.getMonthYear();

    final existing = await db.query(
      'monthly_stats',
      where: 'month_year = ?',
      whereArgs: [monthYear],
    );

    if (existing.isEmpty) {
      await db.insert('monthly_stats', {
        'month_year': monthYear,
        'total_count': 1,
        'bike_accident_count': emergency.emergencyType.toLowerCase().contains('bike') ? 1 : 0,
        'car_accident_count': emergency.emergencyType.toLowerCase().contains('car') ? 1 : 0,
        'fire_count': emergency.emergencyType.toLowerCase().contains('fire') ? 1 : 0,
        'other_count': (!emergency.emergencyType.toLowerCase().contains('bike') &&
                        !emergency.emergencyType.toLowerCase().contains('car') &&
                        !emergency.emergencyType.toLowerCase().contains('fire')) ? 1 : 0,
      });
    } else {
      final currentStats = existing.first;
      await db.update(
        'monthly_stats',
        {
          'total_count': (currentStats['total_count'] as int) + 1,
          'bike_accident_count': (currentStats['bike_accident_count'] as int) + 
              (emergency.emergencyType.toLowerCase().contains('bike') ? 1 : 0),
          'car_accident_count': (currentStats['car_accident_count'] as int) + 
              (emergency.emergencyType.toLowerCase().contains('car') ? 1 : 0),
          'fire_count': (currentStats['fire_count'] as int) + 
              (emergency.emergencyType.toLowerCase().contains('fire') ? 1 : 0),
          'other_count': (currentStats['other_count'] as int) + 
              ((!emergency.emergencyType.toLowerCase().contains('bike') &&
                !emergency.emergencyType.toLowerCase().contains('car') &&
                !emergency.emergencyType.toLowerCase().contains('fire')) ? 1 : 0),
        },
        where: 'month_year = ?',
        whereArgs: [monthYear],
      );
    }
  }

  // Feedback Methods
  Future<int> insertFeedback(String name, String message) async {
    final db = await database;
    return await db.insert('feedback', {
      'name': name,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Off Day Methods
  Future<int> saveOffDay(OffDay offDay) async {
    final db = await database;
    try {
      return await db.insert(
        'off_days',
        offDay.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('DEBUG: saveOffDay error: $e');
      rethrow;
    }
  }

  Future<List<OffDay>> getOffDays() async {
    final db = await database;
    final maps = await db.query('off_days', orderBy: 'off_date DESC');
    return List.generate(maps.length, (i) => OffDay.fromMap(maps[i]));
  }

  Future<List<OffDay>> getOffDaysByMonth(String monthYear) async {
    final db = await database;
    final allOffDays = await getOffDays();
    return allOffDays.where((offDay) => offDay.getMonthYear() == monthYear).toList();
  }

  Future<OffDay?> getOffDayByDate(DateTime date) async {
    final db = await database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    final maps = await db.query(
      'off_days',
      where: 'off_date LIKE ?',
      whereArgs: ['${dateStr.split('T')[0]}%'],
    );
    if (maps.isEmpty) return null;
    return OffDay.fromMap(maps.first);
  }

  Future<bool> isOffDay(DateTime date) async {
    final offDay = await getOffDayByDate(date);
    return offDay != null;
  }

  Future<void> deleteOffDay(int id) async {
    final db = await database;
    await db.delete('off_days', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteOffDayByDate(DateTime date) async {
    final db = await database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    await db.delete(
      'off_days',
      where: 'off_date LIKE ?',
      whereArgs: ['${dateStr.split('T')[0]}%'],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
