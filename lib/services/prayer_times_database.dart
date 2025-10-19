import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/prayer_times_model.dart';

class PrayerTimesDatabase {
  static final PrayerTimesDatabase instance = PrayerTimesDatabase._init();
  static Database? _database;

  PrayerTimesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('prayer_times.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE prayer_times (
        id $idType,
        date $textType,
        fajr $textType,
        sunrise $textType,
        dhuhr $textType,
        asr $textType,
        maghrib $textType,
        isha $textType,
        hijri_date $textType,
        hijri_month $textType,
        hijri_year $textType,
        latitude $realType,
        longitude $realType,
        location_name $textType,
        UNIQUE(date, latitude, longitude)
      )
    ''');
  }

  // Insert or update prayer times for a specific date
  Future<int> insertPrayerTimes(
    PrayerTimesModel prayerTimes,
    double latitude,
    double longitude,
    String locationName,
  ) async {
    final db = await database;

    final data = {
      'date': prayerTimes.date,
      'fajr': prayerTimes.fajr,
      'sunrise': prayerTimes.sunrise,
      'dhuhr': prayerTimes.dhuhr,
      'asr': prayerTimes.asr,
      'maghrib': prayerTimes.maghrib,
      'isha': prayerTimes.isha,
      'hijri_date': prayerTimes.hijriDate,
      'hijri_month': prayerTimes.hijriMonth,
      'hijri_year': prayerTimes.hijriYear,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
    };

    return await db.insert('prayer_times', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Insert multiple prayer times (for monthly data)
  Future<void> insertMultiplePrayerTimes(
    List<PrayerTimesModel> prayerTimesList,
    double latitude,
    double longitude,
    String locationName,
  ) async {
    final db = await database;
    final batch = db.batch();

    for (var prayerTimes in prayerTimesList) {
      final data = {
        'date': prayerTimes.date,
        'fajr': prayerTimes.fajr,
        'sunrise': prayerTimes.sunrise,
        'dhuhr': prayerTimes.dhuhr,
        'asr': prayerTimes.asr,
        'maghrib': prayerTimes.maghrib,
        'isha': prayerTimes.isha,
        'hijri_date': prayerTimes.hijriDate,
        'hijri_month': prayerTimes.hijriMonth,
        'hijri_year': prayerTimes.hijriYear,
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
      };

      batch.insert('prayer_times', data, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  // Get prayer times for a specific date and location
  Future<PrayerTimesModel?> getPrayerTimes(String date, double latitude, double longitude) async {
    final db = await database;

    final maps = await db.query(
      'prayer_times',
      where: 'date = ? AND ABS(latitude - ?) < 0.1 AND ABS(longitude - ?) < 0.1',
      whereArgs: [date, latitude, longitude],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return PrayerTimesModel.fromDatabase(maps.first);
    }
    return null;
  }

  // Get monthly prayer times
  Future<List<PrayerTimesModel>> getMonthlyPrayerTimes(
    int year,
    int month,
    double latitude,
    double longitude,
  ) async {
    final db = await database;

    final maps = await db.query(
      'prayer_times',
      where: 'date LIKE ? AND ABS(latitude - ?) < 0.1 AND ABS(longitude - ?) < 0.1',
      whereArgs: ['$year-${month.toString().padLeft(2, '0')}-%', latitude, longitude],
      orderBy: 'date ASC',
    );

    return maps.map((map) => PrayerTimesModel.fromDatabase(map)).toList();
  }

  // Get all prayer times for the next 30 days
  Future<List<PrayerTimesModel>> getUpcomingPrayerTimes(
    DateTime startDate,
    double latitude,
    double longitude,
  ) async {
    final db = await database;
    final endDate = startDate.add(const Duration(days: 30));

    final maps = await db.query(
      'prayer_times',
      where: 'date >= ? AND date <= ? AND ABS(latitude - ?) < 0.1 AND ABS(longitude - ?) < 0.1',
      whereArgs: [_formatDate(startDate), _formatDate(endDate), latitude, longitude],
      orderBy: 'date ASC',
    );

    return maps.map((map) => PrayerTimesModel.fromDatabase(map)).toList();
  }

  // Check if we have data for a specific date range
  Future<bool> hasDataForMonth(int year, int month, double latitude, double longitude) async {
    final db = await database;

    final result = await db.query(
      'prayer_times',
      where: 'date LIKE ? AND ABS(latitude - ?) < 0.1 AND ABS(longitude - ?) < 0.1',
      whereArgs: ['$year-${month.toString().padLeft(2, '0')}-%', latitude, longitude],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // Delete old prayer times (older than 30 days)
  Future<int> deleteOldPrayerTimes() async {
    final db = await database;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    return await db.delete(
      'prayer_times',
      where: 'date < ?',
      whereArgs: [_formatDate(thirtyDaysAgo)],
    );
  }

  // Clear all data
  Future<int> clearAll() async {
    final db = await database;
    return await db.delete('prayer_times');
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
