# API Documentation - Emergency Cases Saver

## Database Service API

This document describes all available methods in the `DatabaseService` class for managing app data.

### Database Service Instance

```dart
import 'package:emergency_cases_saver/services/database_service.dart';

final dbService = DatabaseService();
```

---

## User Profile Operations

### Insert User Profile

Create a new user profile (used during registration).

```dart
Future<int> insertUserProfile(UserProfile profile)
```

**Parameters:**
- `profile`: UserProfile object containing user registration data

**Returns:** Row ID of inserted profile

**Example:**
```dart
final profile = UserProfile(
  fullName: 'Muhammad Ali',
  designation: 'Rescue Officer',
  district: 'Lahore',
  tehsil: 'Lahore City',
  mobileNumber: '03001234567',
  registrationDate: DateTime.now(),
  isVerified: true,
);

final id = await dbService.insertUserProfile(profile);
print('Profile created with ID: $id');
```

---

### Get User Profile

Retrieve the registered user profile.

```dart
Future<UserProfile?> getUserProfile()
```

**Returns:** UserProfile object or null if not registered

**Example:**
```dart
final profile = await dbService.getUserProfile();
if (profile != null) {
  print('User: ${profile.fullName}');
  print('District: ${profile.district}');
}
```

---

### Check Registration Status

Check if user has completed registration.

```dart
Future<bool> isUserRegistered()
```

**Returns:** true if user is registered, false otherwise

**Example:**
```dart
final isRegistered = await dbService.isUserRegistered();
if (!isRegistered) {
  // Navigate to registration screen
}
```

---

### Update User Profile

Update existing user profile information.

```dart
Future<int> updateUserProfile(UserProfile profile)
```

**Parameters:**
- `profile`: Updated UserProfile object (must include id)

**Returns:** Number of rows affected

**Example:**
```dart
final updatedProfile = profile.copyWith(
  district: 'Faisalabad',
  tehsil: 'Faisalabad City',
);
await dbService.updateUserProfile(updatedProfile);
```

---

## Emergency Operations

### Insert Emergency

Create a new emergency record.

```dart
Future<int> insertEmergency(Emergency emergency)
```

**Parameters:**
- `emergency`: Emergency object with all required fields

**Returns:** Row ID of inserted emergency

**Throws:** Exception if EC number already exists

**Example:**
```dart
final emergency = Emergency(
  ecNumber: '000001',
  dateTime: DateTime.now(),
  emergencyType: EmergencyType.bikeAccident,
  location: 'Main Boulevard, Lahore',
  notes: 'Multiple casualties',
  isLateEntry: false,
  createdAt: DateTime.now(),
  createdBy: userProfile.id!,
);

try {
  final id = await dbService.insertEmergency(emergency);
  print('Emergency saved with ID: $id');
} catch (e) {
  print('Error: ${e.toString()}');
}
```

---

### Check EC Number Exists

Check if an EC number is already used.

```dart
Future<bool> isEcNumberExists(String ecNumber)
```

**Parameters:**
- `ecNumber`: 6-digit EC number to check

**Returns:** true if exists, false otherwise

**Example:**
```dart
final exists = await dbService.isEcNumberExists('000001');
if (exists) {
  print('EC number already used!');
}
```

---

### Get All Emergencies

Retrieve all emergency records.

```dart
Future<List<Emergency>> getAllEmergencies({
  String? orderBy,
  bool descending = true,
})
```

**Parameters:**
- `orderBy`: Column name to sort by (default: 'date_time')
- `descending`: Sort order (default: true)

**Returns:** List of Emergency objects

**Example:**
```dart
// Get all emergencies, newest first
final emergencies = await dbService.getAllEmergencies();

// Get all emergencies, oldest first
final oldestFirst = await dbService.getAllEmergencies(
  orderBy: 'date_time',
  descending: false,
);

// Sort by EC number
final byEcNumber = await dbService.getAllEmergencies(
  orderBy: 'ec_number',
  descending: false,
);
```

---

### Get Emergencies by Month

Retrieve emergencies for a specific month.

```dart
Future<List<Emergency>> getEmergenciesByMonth(String monthYear)
```

**Parameters:**
- `monthYear`: Month in format "YYYY-MM" (e.g., "2024-11")

**Returns:** List of Emergency objects for that month

**Example:**
```dart
final novemberEmergencies = await dbService.getEmergenciesByMonth('2024-11');
print('November had ${novemberEmergencies.length} emergencies');
```

---

### Search Emergencies

Search emergencies by EC number, location, or notes.

```dart
Future<List<Emergency>> searchEmergencies(String query)
```

**Parameters:**
- `query`: Search term

**Returns:** List of matching Emergency objects

**Example:**
```dart
final results = await dbService.searchEmergencies('Main Boulevard');
print('Found ${results.length} emergencies');
```

---

### Filter by Emergency Type

Get emergencies of a specific type.

```dart
Future<List<Emergency>> filterEmergenciesByType(String type)
```

**Parameters:**
- `type`: Emergency type (use EmergencyType constants)

**Returns:** List of Emergency objects of that type

**Example:**
```dart
final fireEmergencies = await dbService.filterEmergenciesByType(
  EmergencyType.fireEmergency
);
```

---

### Get Last Emergency

Retrieve the most recently created emergency.

```dart
Future<Emergency?> getLastEmergency()
```

**Returns:** Latest Emergency object or null if none exist

**Example:**
```dart
final lastEmergency = await dbService.getLastEmergency();
if (lastEmergency != null) {
  print('Last EC: ${lastEmergency.ecNumber}');
}
```

---

### Delete Emergency

Delete a single emergency record.

```dart
Future<int> deleteEmergency(int id)
```

**Parameters:**
- `id`: Emergency ID to delete

**Returns:** Number of rows deleted

**Example:**
```dart
await dbService.deleteEmergency(emergencyId);
```

---

### Delete Month Records

Delete all emergencies for a specific month.

```dart
Future<int> deleteEmergenciesByMonth(String monthYear)
```

**Parameters:**
- `monthYear`: Month in format "YYYY-MM"

**Returns:** Number of rows deleted

**Example:**
```dart
final count = await dbService.deleteEmergenciesByMonth('2024-11');
print('Deleted $count emergencies');
```

---

## Statistics Operations

### Get Today's Stats

Get count of emergencies recorded today.

```dart
Future<Map<String, int>> getTodayStats()
```

**Returns:** Map with 'count' key

**Example:**
```dart
final stats = await dbService.getTodayStats();
print('Today: ${stats['count']} emergencies');
```

---

### Get Month Stats

Get count of emergencies for a specific month.

```dart
Future<Map<String, int>> getMonthStats(String monthYear)
```

**Parameters:**
- `monthYear`: Month in format "YYYY-MM"

**Returns:** Map with 'count' key

**Example:**
```dart
final stats = await dbService.getMonthStats('2024-11');
print('November: ${stats['count']} emergencies');
```

---

### Get Stats by Type

Get breakdown of emergency types for a month.

```dart
Future<Map<String, int>> getStatsByType(String monthYear)
```

**Parameters:**
- `monthYear`: Month in format "YYYY-MM"

**Returns:** Map with emergency type as key, count as value

**Example:**
```dart
final stats = await dbService.getStatsByType('2024-11');
stats.forEach((type, count) {
  print('$type: $count');
});
```

---

### Get Monthly Trends

Get emergency counts for last N months.

```dart
Future<List<Map<String, dynamic>>> getMonthlyTrends(int months)
```

**Parameters:**
- `months`: Number of months to retrieve

**Returns:** List of maps with 'month' and 'count' keys

**Example:**
```dart
final trends = await dbService.getMonthlyTrends(6);
for (var trend in trends) {
  print('${trend['month']}: ${trend['count']}');
}
```

---

## Feedback Operations

### Insert Feedback

Save user feedback.

```dart
Future<int> insertFeedback(String name, String message)
```

**Parameters:**
- `name`: User's name
- `message`: Feedback message

**Returns:** Row ID of inserted feedback

**Example:**
```dart
await dbService.insertFeedback(
  'Muhammad Ali',
  'Great app! Very useful for our team.'
);
```

---

### Get All Feedback

Retrieve all feedback entries.

```dart
Future<List<Map<String, dynamic>>> getAllFeedback()
```

**Returns:** List of feedback maps

**Example:**
```dart
final feedbackList = await dbService.getAllFeedback();
for (var feedback in feedbackList) {
  print('${feedback['name']}: ${feedback['message']}');
}
```

---

## Data Management

### Clear All Data

Delete all emergencies and stats (keeps user profile).

```dart
Future<void> clearAllData()
```

**Example:**
```dart
await dbService.clearAllData();
print('All data cleared');
```

---

### Export Data

Export all data to JSON format.

```dart
Future<Map<String, dynamic>> exportData()
```

**Returns:** Map containing profile, emergencies, and feedback

**Example:**
```dart
final data = await dbService.exportData();
final json = jsonEncode(data);
// Save to file or share
```

---

### Close Database

Close the database connection.

```dart
Future<void> close()
```

**Example:**
```dart
await dbService.close();
```

---

## Emergency Type Constants

```dart
class EmergencyType {
  static const String bikeAccident = 'Bike Accident';
  static const String carAccident = 'Car Accident';
  static const String fireEmergency = 'Fire Emergency';
  static const String otherEmergency = 'Other Emergency';
  
  static List<String> getAll() { ... }
  static IconData getIcon(String type) { ... }
  static Color getColor(String type) { ... }
}
```

---

## Error Handling

All database operations can throw exceptions. Always use try-catch:

```dart
try {
  await dbService.insertEmergency(emergency);
  // Success
} catch (e) {
  // Handle error
  print('Database error: ${e.toString()}');
  // Show error to user
}
```

---

## Best Practices

1. **Always check existence before insert:**
```dart
if (await dbService.isEcNumberExists(ecNumber)) {
  // Show error
  return;
}
await dbService.insertEmergency(emergency);
```

2. **Handle null returns:**
```dart
final profile = await dbService.getUserProfile();
if (profile == null) {
  // User not registered
  return;
}
// Use profile
```

3. **Use transactions for multiple operations:**
```dart
// For complex operations, consider using transactions
// (requires direct database access)
```

4. **Close database when app terminates:**
```dart
@override
void dispose() {
  DatabaseService().close();
  super.dispose();
}
```

---

## Database Schema Reference

### user_profile Table
- `id` INTEGER PRIMARY KEY
- `full_name` TEXT
- `designation` TEXT
- `district` TEXT
- `tehsil` TEXT
- `mobile_number` TEXT
- `registration_date` TEXT (ISO 8601)
- `is_verified` INTEGER (0 or 1)

### emergencies Table
- `id` INTEGER PRIMARY KEY
- `ec_number` TEXT UNIQUE
- `date_time` TEXT (ISO 8601)
- `emergency_type` TEXT
- `location` TEXT (nullable)
- `notes` TEXT (nullable)
- `is_late_entry` INTEGER (0 or 1)
- `created_at` TEXT (ISO 8601)
- `created_by` INTEGER (foreign key)

### monthly_stats Table
- `month_year` TEXT PRIMARY KEY
- `total_count` INTEGER
- `bike_accident_count` INTEGER
- `car_accident_count` INTEGER
- `fire_count` INTEGER
- `other_count` INTEGER

### feedback Table
- `id` INTEGER PRIMARY KEY
- `name` TEXT
- `message` TEXT
- `created_at` TEXT (ISO 8601)

---

**For more information, see the source code:**
- `lib/services/database_service.dart`
- `lib/models/user_profile.dart`
- `lib/models/emergency.dart`
- `lib/models/monthly_stats.dart`
