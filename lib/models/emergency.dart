import 'package:intl/intl.dart';

class Emergency {
  final int? id;
  final String ecNumber;
  final DateTime emergencyDate;
  final String emergencyType;
  final String? location;
  final String? notes;
  final bool isLateEntry;
  final DateTime createdAt;
  final int createdBy;

  Emergency({
    this.id,
    required this.ecNumber,
    required this.emergencyDate,
    required this.emergencyType,
    this.location,
    this.notes,
    required this.isLateEntry,
    required this.createdAt,
    required this.createdBy,
  });
  
  // Legacy compatibility - dateTime getter
  DateTime get dateTime => emergencyDate;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ec_number': ecNumber,
      'emergency_date': emergencyDate.toIso8601String().split('T')[0],
      'emergency_type': emergencyType,
      'location': location,
      'notes': notes,
      'is_late_entry': isLateEntry ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  factory Emergency.fromMap(Map<String, dynamic> map) {
    return Emergency(
      id: map['id'],
      ecNumber: map['ec_number'],
      emergencyDate: DateTime.parse(map['emergency_date']),
      emergencyType: map['emergency_type'],
      location: map['location'],
      notes: map['notes'],
      isLateEntry: map['is_late_entry'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      createdBy: map['created_by'],
    );
  }

  // Helper method: Get formatted date-time string
  String getFormattedDateTime() {
    final formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(emergencyDate);
  }

  // Helper method: Get formatted time string (shows only date now)
  String getFormattedTime() {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(emergencyDate);
  }
  
  // Helper method: Get formatted date (for emergency card)
  String getFormattedDate() {
    final formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(emergencyDate);
  }

  // Helper method: Get month-year string
  String getMonthYear() {
    return DateFormat('yyyy-MM').format(emergencyDate);
  }
}
