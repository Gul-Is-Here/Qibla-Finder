import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/prayer_model/prayer_times_model.dart';

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
      // Convert date from "25 October 2025" to "2025-10-25" format
      final normalizedDate = _normalizeDate(prayerTimes.date);

      final data = {
        'date': normalizedDate,
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

  // Convert date from "25 October 2025" to "2025-10-25" format
  String _normalizeDate(String dateStr) {
    try {
      // Parse "25 October 2025" format
      final parts = dateStr.split(' ');
      if (parts.length != 3) return dateStr;

      final day = int.parse(parts[0]);
      final year = int.parse(parts[2]);

      final monthMap = {
        'January': 1,
        'February': 2,
        'March': 3,
        'April': 4,
        'May': 5,
        'June': 6,
        'July': 7,
        'August': 8,
        'September': 9,
        'October': 10,
        'November': 11,
        'December': 12,
      };

      final month = monthMap[parts[1]] ?? 1;

      // Return in "YYYY-MM-DD" format
      return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    } catch (e) {
      print('⚠️ Error normalizing date "$dateStr": $e');
      return dateStr;
    }
  }

  // Get prayer times for a specific date and location
  Future<PrayerTimesModel?> getPrayerTimes(String date, double latitude, double longitude) async {
    try {
      final db = await database;

      print('🔍 Querying database:');
      print('   Date: $date');
      print('   Latitude: $latitude');
      print('   Longitude: $longitude');

      final maps = await db.query(
        'prayer_times',
        where: 'date = ? AND ABS(latitude - ?) < 0.1 AND ABS(longitude - ?) < 0.1',
        whereArgs: [date, latitude, longitude],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        print('✅ Found prayer times in database for date: $date');
        return PrayerTimesModel.fromDatabase(maps.first);
      } else {
        print('⚠️ No prayer times found in database for date: $date');

        // Try to find any data for nearby dates (fallback)
        final allMaps = await db.query(
          'prayer_times',
          where: 'ABS(latitude - ?) < 0.1 AND ABS(longitude - ?) < 0.1',
          whereArgs: [latitude, longitude],
          orderBy: 'date DESC',
          limit: 5,
        );

        if (allMaps.isNotEmpty) {
          print('📊 Found ${allMaps.length} cached entries for this location:');
          for (var map in allMaps) {
            print('   - Date: ${map['date']}');
          }
        } else {
          print('❌ No cached data found for this location at all');
        }
      }

      return null;
    } catch (e) {
      print('❌ Error querying database: $e');
      return null;
    }
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

  // Get ANY available prayer times for location (ignoring date)
  // Used as last resort fallback when offline
  Future<PrayerTimesModel?> getAnyAvailablePrayerTimes(double latitude, double longitude) async {
    try {
      final db = await database;

      print('🔍 Searching for ANY cached prayer times near location...');

      // Get the most recent entry for this location
      final maps = await db.query(
        'prayer_times',
        where: 'ABS(latitude - ?) < 0.1 AND ABS(longitude - ?) < 0.1',
        whereArgs: [latitude, longitude],
        orderBy: 'date DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        print('✅ Found cached prayer times from date: ${maps.first['date']}');
        return PrayerTimesModel.fromDatabase(maps.first);
      }

      // If no exact location match, try wider search (0.5 degree ~ 50km)
      final widerMaps = await db.query(
        'prayer_times',
        where: 'ABS(latitude - ?) < 0.5 AND ABS(longitude - ?) < 0.5',
        whereArgs: [latitude, longitude],
        orderBy: 'date DESC',
        limit: 1,
      );

      if (widerMaps.isNotEmpty) {
        print('✅ Found nearby cached prayer times (within ~50km) from: ${widerMaps.first['date']}');
        return PrayerTimesModel.fromDatabase(widerMaps.first);
      }

      // Last resort: get any data at all
      final anyMaps = await db.query('prayer_times', orderBy: 'date DESC', limit: 1);

      if (anyMaps.isNotEmpty) {
        print(
          '⚠️ Using fallback prayer times from ${anyMaps.first['location_name'] ?? 'unknown location'}',
        );
        return PrayerTimesModel.fromDatabase(anyMaps.first);
      }

      print('❌ No prayer times in database at all');
      return null;
    } catch (e) {
      print('❌ Error searching for any available data: $e');
      return null;
    }
  }

  // Get total count of cached entries
  Future<int> getCachedCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM prayer_times');
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Clear all data
  Future<int> clearAll() async {
    final db = await database;
    return await db.delete('prayer_times');
  }

  // Close database connection and clean up
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('✅ Database connection closed and cleaned up');
    }
  }

  // Dispose method for explicit cleanup
  Future<void> dispose() async {
    await close();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
