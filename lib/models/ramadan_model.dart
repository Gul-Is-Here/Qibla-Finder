/// Model for tracking fasting days during Ramadan
class FastingDayModel {
  final int day; // Day of Ramadan (1-30)
  final DateTime date;
  final String hijriDate;
  final bool isFasted;
  final String? suhoorTime;
  final String? iftarTime;
  final String? notes;

  FastingDayModel({
    required this.day,
    required this.date,
    required this.hijriDate,
    this.isFasted = false,
    this.suhoorTime,
    this.iftarTime,
    this.notes,
  });

  FastingDayModel copyWith({
    int? day,
    DateTime? date,
    String? hijriDate,
    bool? isFasted,
    String? suhoorTime,
    String? iftarTime,
    String? notes,
  }) {
    return FastingDayModel(
      day: day ?? this.day,
      date: date ?? this.date,
      hijriDate: hijriDate ?? this.hijriDate,
      isFasted: isFasted ?? this.isFasted,
      suhoorTime: suhoorTime ?? this.suhoorTime,
      iftarTime: iftarTime ?? this.iftarTime,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date.toIso8601String(),
      'hijriDate': hijriDate,
      'isFasted': isFasted,
      'suhoorTime': suhoorTime,
      'iftarTime': iftarTime,
      'notes': notes,
    };
  }

  factory FastingDayModel.fromJson(Map<String, dynamic> json) {
    return FastingDayModel(
      day: json['day'] as int,
      date: DateTime.parse(json['date'] as String),
      hijriDate: json['hijriDate'] as String,
      isFasted: json['isFasted'] as bool? ?? false,
      suhoorTime: json['suhoorTime'] as String?,
      iftarTime: json['iftarTime'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

/// Model for Ramadan Dua
class RamadanDuaModel {
  final int id;
  final String arabicText;
  final String englishText;
  final String transliteration;
  final String occasion; // suhoor, iftar, general, laylatul_qadr
  final String reference;

  RamadanDuaModel({
    required this.id,
    required this.arabicText,
    required this.englishText,
    required this.transliteration,
    required this.occasion,
    required this.reference,
  });

  factory RamadanDuaModel.fromJson(Map<String, dynamic> json) {
    return RamadanDuaModel(
      id: json['id'] as int,
      arabicText: json['arabicText'] as String,
      englishText: json['englishText'] as String,
      transliteration: json['transliteration'] as String,
      occasion: json['occasion'] as String,
      reference: json['reference'] as String,
    );
  }
}

/// Model for Ramadan info
class RamadanInfoModel {
  final int currentYear; // Hijri year
  final DateTime? startDate; // Gregorian start date
  final DateTime? endDate; // Gregorian end date
  final int totalDays;
  final int currentDay; // 0 if not in Ramadan
  final bool isRamadan;
  final int daysUntilRamadan;
  final int daysFasted;

  RamadanInfoModel({
    required this.currentYear,
    this.startDate,
    this.endDate,
    this.totalDays = 30,
    this.currentDay = 0,
    this.isRamadan = false,
    this.daysUntilRamadan = 0,
    this.daysFasted = 0,
  });

  double get progressPercentage {
    if (totalDays == 0) return 0;
    return (daysFasted / totalDays) * 100;
  }

  int get daysRemaining => totalDays - currentDay;
}
