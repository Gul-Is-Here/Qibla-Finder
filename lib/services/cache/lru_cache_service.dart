import 'dart:collection';
import 'package:get/get.dart';

/// LRU (Least Recently Used) Cache Service
/// Implements size-limited cache with automatic eviction of least recently used items
class LRUCacheService extends GetxService {
  static LRUCacheService get instance => Get.find<LRUCacheService>();

  // Configuration
  static const int _maxCacheSize = 100; // Maximum number of entries
  static const int _maxMemoryBytes = 50 * 1024 * 1024; // 50 MB

  // Internal cache storage (maintains insertion order)
  final LinkedHashMap<String, CacheEntry> _cache = LinkedHashMap();

  // Current memory usage estimate
  int _currentMemoryBytes = 0;

  /// Get cached data by key
  T? get<T>(String key) {
    final entry = _cache.remove(key);
    if (entry == null) {
      print('🔍 Cache miss: $key');
      return null;
    }

    // Check if expired
    if (entry.isExpired) {
      _currentMemoryBytes -= entry.sizeBytes;
      print('⏰ Cache expired: $key');
      return null;
    }

    // Move to end (most recently used)
    _cache[key] = entry;
    print('✅ Cache hit: $key');
    return entry.value as T?;
  }

  /// Store data in cache
  void set(String key, dynamic value, {Duration? expiry}) {
    final sizeBytes = _estimateSize(value);

    // Check if adding this would exceed memory limit
    if (_currentMemoryBytes + sizeBytes > _maxMemoryBytes) {
      _evictUntilSpace(sizeBytes);
    }

    // Remove old entry if exists
    final oldEntry = _cache.remove(key);
    if (oldEntry != null) {
      _currentMemoryBytes -= oldEntry.sizeBytes;
    }

    // Add new entry
    final entry = CacheEntry(
      value: value,
      timestamp: DateTime.now(),
      expiry: expiry,
      sizeBytes: sizeBytes,
    );

    _cache[key] = entry;
    _currentMemoryBytes += sizeBytes;

    // Evict if cache size exceeded
    if (_cache.length > _maxCacheSize) {
      _evictOldest();
    }

    print('💾 Cached: $key (${_formatBytes(sizeBytes)})');
  }

  /// Remove specific key from cache
  void remove(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      _currentMemoryBytes -= entry.sizeBytes;
      print('🗑️ Removed from cache: $key');
    }
  }

  /// Clear all cached data
  void clear() {
    final count = _cache.length;
    _cache.clear();
    _currentMemoryBytes = 0;
    print('🧹 Cache cleared: $count entries removed');
  }

  /// Clear expired entries
  void clearExpired() {
    final keysToRemove = <String>[];

    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        keysToRemove.add(key);
        _currentMemoryBytes -= entry.sizeBytes;
      }
    });

    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      print('🧹 Cleared ${keysToRemove.length} expired entries');
    }
  }

  /// Get cache statistics
  CacheStats getStats() {
    return CacheStats(
      entryCount: _cache.length,
      memoryBytes: _currentMemoryBytes,
      maxEntries: _maxCacheSize,
      maxMemoryBytes: _maxMemoryBytes,
    );
  }

  /// Evict oldest entries until there's enough space
  void _evictUntilSpace(int requiredBytes) {
    while (_currentMemoryBytes + requiredBytes > _maxMemoryBytes && _cache.isNotEmpty) {
      _evictOldest();
    }
  }

  /// Evict the oldest (least recently used) entry
  void _evictOldest() {
    if (_cache.isEmpty) return;

    final firstKey = _cache.keys.first;
    final entry = _cache.remove(firstKey);

    if (entry != null) {
      _currentMemoryBytes -= entry.sizeBytes;
      print('♻️ Evicted LRU entry: $firstKey (${_formatBytes(entry.sizeBytes)})');
    }
  }

  /// Estimate size of cached object in bytes
  int _estimateSize(dynamic value) {
    if (value == null) return 8;
    if (value is String) return value.length * 2; // UTF-16 encoding
    if (value is int) return 8;
    if (value is double) return 8;
    if (value is bool) return 1;
    if (value is List) {
      return value.fold<int>(24, (sum, item) => sum + _estimateSize(item));
    }
    if (value is Map) {
      return value.entries.fold<int>(
        24,
        (sum, entry) => sum + _estimateSize(entry.key) + _estimateSize(entry.value),
      );
    }
    // Default estimate for complex objects
    return 1024;
  }

  /// Format bytes to human-readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Print cache status for debugging
  void printStatus() {
    final stats = getStats();
    print('📊 Cache Status:');
    print('   Entries: ${stats.entryCount}/${stats.maxEntries}');
    print('   Memory: ${_formatBytes(stats.memoryBytes)}/${_formatBytes(stats.maxMemoryBytes)}');
    print('   Usage: ${(stats.memoryUsagePercent).toStringAsFixed(1)}%');
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}

/// Cache entry with metadata
class CacheEntry {
  final dynamic value;
  final DateTime timestamp;
  final Duration? expiry;
  final int sizeBytes;

  CacheEntry({required this.value, required this.timestamp, this.expiry, required this.sizeBytes});

  bool get isExpired {
    if (expiry == null) return false;
    return DateTime.now().difference(timestamp) > expiry!;
  }
}

/// Cache statistics
class CacheStats {
  final int entryCount;
  final int memoryBytes;
  final int maxEntries;
  final int maxMemoryBytes;

  CacheStats({
    required this.entryCount,
    required this.memoryBytes,
    required this.maxEntries,
    required this.maxMemoryBytes,
  });

  double get entryUsagePercent => (entryCount / maxEntries) * 100;
  double get memoryUsagePercent => (memoryBytes / maxMemoryBytes) * 100;
}
