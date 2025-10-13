import 'package:in_app_update/in_app_update.dart';
import 'package:get/get.dart';

/// Service to handle automatic app updates from Google Play Store
/// Updates happen silently in the background without user notification
class AppUpdateService extends GetxService {
  static AppUpdateService get instance => Get.find();

  var updateAvailable = false.obs;
  var updateDownloading = false.obs;

  /// Check for updates when app starts
  /// This runs automatically and updates silently
  Future<void> checkForUpdate() async {
    try {
      // Check if update is available
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        updateAvailable.value = true;

        // Flexible update - downloads in background, installs on app restart
        // This is SILENT - no user notification
        if (updateInfo.flexibleUpdateAllowed) {
          await _startFlexibleUpdate();
        }
        // Immediate update - only for critical security updates
        else if (updateInfo.immediateUpdateAllowed) {
          // Uncomment if you want to force immediate updates
          // await InAppUpdate.performImmediateUpdate();
        }
      }
    } catch (e) {
      print('Error checking for updates: $e');
      // Silently fail - user won't notice if update check fails
    }
  }

  /// Flexible update - silent background download
  /// User can continue using app while update downloads
  /// Update installs automatically when app restarts
  Future<void> _startFlexibleUpdate() async {
    try {
      updateDownloading.value = true;

      await InAppUpdate.startFlexibleUpdate();

      // Listen for download completion
      InAppUpdate.completeFlexibleUpdate()
          .then((_) {
            print('✓ Update downloaded successfully');
            print('✓ Update will install when app restarts');
            updateDownloading.value = false;
            // App will restart automatically to install update
          })
          .catchError((e) {
            print('Error completing flexible update: $e');
            updateDownloading.value = false;
          });
    } catch (e) {
      print('Error performing flexible update: $e');
      updateDownloading.value = false;
    }
  }

  /// Force immediate update (only use for critical security patches)
  /// This BLOCKS app usage until user updates
  /// Generally not recommended - use flexible updates instead
  Future<void> forceImmediateUpdate() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
          updateInfo.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      print('Error forcing immediate update: $e');
    }
  }

  /// Check update availability status
  Future<bool> isUpdateAvailable() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      return updateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable;
    } catch (e) {
      return false;
    }
  }
}
