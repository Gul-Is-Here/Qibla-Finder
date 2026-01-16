import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PerformanceService extends GetxService {
  static PerformanceService get instance => Get.find<PerformanceService>();

  final GetStorage _storage = GetStorage();

  // Performance metrics
  var cpuUsage = 0.0.obs;
  var memoryUsage = 0.0.obs;
  var frameRenderTime = 0.0.obs;
  var isOptimizationEnabled = true.obs;

  // Caching for frequently accessed data
  final Map<String, dynamic> _memoryCache = {};
  Timer? _performanceTimer;

  @override
  void onInit() {
    super.onInit();
    _initializePerformanceOptimizations();
    _startPerformanceMonitoring();
  }

  void _initializePerformanceOptimizations() {
    // Load optimization settings
    isOptimizationEnabled.value = _storage.read('optimization_enabled') ?? true;

    // Set up Flutter performance optimizations
    _setupFlutterOptimizations();

    // Preload critical data
    _preloadCriticalData();
  }

  void _setupFlutterOptimizations() {
    // Optimize rendering performance
    if (isOptimizationEnabled.value) {
      // Reduce unnecessary rebuilds
      Get.smartManagement = SmartManagement.keepFactory;

      // Optimize image caching
      PaintingBinding.instance.imageCache.maximumSize = 100;
      PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
    }
  }

  void _preloadCriticalData() {
    // Preload compass icons and other critical assets
    final criticalAssets = [
      'assets/icons/compass.png',
      'assets/icons/compassBg.png',
      'assets/icons/kaaba.png',
      'assets/icons/qibla1.png',
      'assets/icons/qibla2.png',
    ];

    for (String asset in criticalAssets) {
      _preloadAsset(asset);
    }
  }

  Future<void> _preloadAsset(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      _memoryCache[assetPath] = true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to preload asset: $assetPath - $e');
      }
    }
  }

  void _startPerformanceMonitoring() {
    if (kDebugMode) {
      _performanceTimer = Timer.periodic(
        const Duration(seconds: 5),
        (timer) => _monitorPerformance(),
      );
    }
  }

  void _monitorPerformance() {
    // Monitor frame render times
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      frameRenderTime.value = now.millisecondsSinceEpoch.toDouble();
    });

    // Monitor memory usage (simplified)
    _estimateMemoryUsage();
  }

  void _estimateMemoryUsage() {
    // Simple memory estimation based on cache size
    final cacheSize = _memoryCache.length;
    final imageCacheSize = PaintingBinding.instance.imageCache.currentSize;
    memoryUsage.value = (cacheSize + imageCacheSize).toDouble();
  }

  // Cache management
  T? getCachedData<T>(String key) {
    return _memoryCache[key] as T?;
  }

  void setCachedData(String key, dynamic data) {
    if (_memoryCache.length > 100) {
      // Simple LRU implementation - remove oldest entries
      final keys = _memoryCache.keys.toList();
      for (int i = 0; i < 20; i++) {
        _memoryCache.remove(keys[i]);
      }
    }
    _memoryCache[key] = data;
  }

  void clearCache() {
    _memoryCache.clear();
    PaintingBinding.instance.imageCache.clear();
  }

  // Background task optimization
  static Future<T> runInBackground<T>(Function computation) async {
    if (computation is Future<T> Function()) {
      return await computation();
    } else {
      return await compute(computation as ComputeCallback<void, T>, null);
    }
  }

  // Debounce utility for preventing excessive function calls
  static Timer? _debounceTimer;
  static void debounce(VoidCallback action, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }

  // Throttle utility for limiting function call frequency
  static DateTime? _lastThrottleTime;
  static void throttle(
    VoidCallback action, {
    Duration duration = const Duration(milliseconds: 100),
  }) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || now.difference(_lastThrottleTime!) >= duration) {
      _lastThrottleTime = now;
      action();
    }
  }

  // Battery optimization methods
  void enableBatteryOptimization() {
    isOptimizationEnabled.value = true;
    _storage.write('optimization_enabled', true);

    // Reduce update frequencies
    _optimizeForBattery();
  }

  void disableBatteryOptimization() {
    isOptimizationEnabled.value = false;
    _storage.write('optimization_enabled', false);
  }

  void _optimizeForBattery() {
    if (isOptimizationEnabled.value) {
      // Reduce compass update frequency when not actively used
      // This will be integrated with the compass controller
    }
  }

  // Network optimization
  bool shouldUseCache() {
    return isOptimizationEnabled.value;
  }

  // Frame rate optimization
  void optimizeFrameRate() {
    if (isOptimizationEnabled.value) {
      // Limit frame rate for animations when battery is low
      // This can be integrated with animation controllers
    }
  }

  // Dispose method for proper cleanup
  void dispose() {
    _performanceTimer?.cancel();
    _debounceTimer?.cancel();
    _memoryCache.clear();
    PaintingBinding.instance.imageCache.clear();
    print('✅ PerformanceService disposed - all resources cleaned up');
  }

  @override
  void onClose() {
    dispose();
    super.onClose();
  }
}
