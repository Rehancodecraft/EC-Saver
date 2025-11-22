import 'package:intl/intl.dart';

class OffDay {
  final int? id;
  final DateTime offDate;
  final String? notes;
  final DateTime createdAt;

  OffDay({
    this.id,
    required this.offDate,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'off_date': offDate.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory OffDay.fromMap(Map<String, dynamic> map) {
    return OffDay(
      id: map['id'],
      offDate: DateTime.parse(map['off_date']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  String getFormattedDate() {
    return DateFormat('dd MMM yyyy').format(offDate);
  }

  String getMonthYear() {
    return DateFormat('MMMM yyyy').format(offDate);
  }

  // Check if a date is an off day (date only comparison)
  bool isSameDate(DateTime date) {
    return offDate.year == date.year &&
           offDate.month == date.month &&
           offDate.day == date.day;
  }
}

