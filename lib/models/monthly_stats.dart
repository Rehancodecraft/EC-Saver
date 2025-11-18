class MonthlyStats {
  final String monthYear;
  final int totalCount;
  final int bikeAccidentCount;
  final int carAccidentCount;
  final int fireCount;
  final int otherCount;

  MonthlyStats({
    required this.monthYear,
    required this.totalCount,
    this.bikeAccidentCount = 0,
    this.carAccidentCount = 0,
    this.fireCount = 0,
    this.otherCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'month_year': monthYear,
      'total_count': totalCount,
      'bike_accident_count': bikeAccidentCount,
      'car_accident_count': carAccidentCount,
      'fire_count': fireCount,
      'other_count': otherCount,
    };
  }

  factory MonthlyStats.fromMap(Map<String, dynamic> map) {
    return MonthlyStats(
      monthYear: map['month_year'] as String,
      totalCount: map['total_count'] as int,
      bikeAccidentCount: map['bike_accident_count'] as int? ?? 0,
      carAccidentCount: map['car_accident_count'] as int? ?? 0,
      fireCount: map['fire_count'] as int? ?? 0,
      otherCount: map['other_count'] as int? ?? 0,
    );
  }

  String getFormattedMonthYear() {
    final parts = monthYear.split('-');
    if (parts.length != 2) return monthYear;
    
    final year = parts[0];
    final month = int.parse(parts[1]);
    
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${monthNames[month - 1]} $year';
  }
}
