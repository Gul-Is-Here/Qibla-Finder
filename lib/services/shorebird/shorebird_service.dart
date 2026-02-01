import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class ShorebirdService {
  static final ShorebirdService _instance = ShorebirdService._internal();
  factory ShorebirdService() => _instance;
  ShorebirdService._internal() {
    _shorebirdUpdater = ShorebirdUpdater();
  }

  late final ShorebirdUpdater _shorebirdUpdater;

  // Check if Shorebird is available
  bool get isShorebirdAvailable => _shorebirdUpdater.isAvailable;

  // Check if update is available
  Future<UpdateStatus> checkForUpdate() async {
    try {
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Checking for updates...');
      }

      final status = await _shorebirdUpdater.checkForUpdate();

      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Update status: ${status.name}');
      }

      return status;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Error checking for updates: $e');
      }
      return UpdateStatus.unavailable;
    }
  }

  // Download and install update
  Future<bool> downloadUpdate() async {
    try {
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Downloading update...');
      }

      await _shorebirdUpdater.update();

      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Update downloaded successfully. Restart app to apply.');
      }

      return true;
    } on UpdateException catch (e) {
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Update failed: ${e.message} (${e.reason.name})');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Error downloading update: $e');
      }
      return false;
    }
  }

  // Get current patch number
  Future<int?> getCurrentPatchNumber() async {
    try {
      final patch = await _shorebirdUpdater.readCurrentPatch();

      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Current patch number: ${patch?.number}');
      }

      return patch?.number;
    } on ReadPatchException catch (e) {
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Error reading patch: ${e.message}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Error getting patch number: $e');
      }
      return null;
    }
  }

  // Get next patch number
  Future<int?> getNextPatchNumber() async {
    try {
      final patch = await _shorebirdUpdater.readNextPatch();

      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Next patch number: ${patch?.number}');
      }

      return patch?.number;
    } on ReadPatchException catch (e) {
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Error reading next patch: ${e.message}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Error getting next patch number: $e');
      }
      return null;
    }
  }

  // Check and download update if available
  Future<bool> checkAndDownloadUpdate() async {
    try {
      if (!isShorebirdAvailable) {
        if (kDebugMode) {
          debugPrint('🐦 Shorebird: Not available on this platform');
        }
        return false;
      }

      final status = await checkForUpdate();

      if (status == UpdateStatus.outdated) {
        if (kDebugMode) {
          debugPrint('🐦 Shorebird: Update available, downloading...');
        }
        return await downloadUpdate();
      } else if (status == UpdateStatus.restartRequired) {
        if (kDebugMode) {
          debugPrint('🐦 Shorebird: Update ready, restart app to apply');
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Error in checkAndDownloadUpdate: $e');
      }
      return false;
    }
  }

  // Initialize and check for updates on app start
  Future<void> initializeAndCheck() async {
    try {
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Initializing...');
        debugPrint('🐦 Shorebird: Available: $isShorebirdAvailable');
      }

      if (!isShorebirdAvailable) {
        if (kDebugMode) {
          debugPrint('🐦 Shorebird: Not available on this platform');
        }
        return;
      }

      final currentPatch = await getCurrentPatchNumber();
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Running patch version: $currentPatch');
      }

      // Check for updates in background
      unawaited(checkAndDownloadUpdate());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🐦 Shorebird: Error in initializeAndCheck: $e');
      }
    }
  }
}
