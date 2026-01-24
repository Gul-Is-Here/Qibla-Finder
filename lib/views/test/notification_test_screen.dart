import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/notifications/notification_service.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final _notificationService = NotificationService.instance;
  bool _isLoading = false;
  String _lastTestResult = '';
  List<NotificationModel> _scheduledNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadScheduledNotifications();
  }

  Future<void> _loadScheduledNotifications() async {
    final notifications = await _notificationService.getScheduledNotifications();
    setState(() {
      _scheduledNotifications = notifications;
    });
  }

  Future<void> _testAzanNotification() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Checking permissions...';
    });

    try {
      // First, check and request permissions
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();

      if (!isAllowed) {
        setState(() {
          _lastTestResult = 'Requesting notification permission...';
        });

        final permissionGranted = await AwesomeNotifications()
            .requestPermissionToSendNotifications();

        if (!permissionGranted) {
          setState(() {
            _lastTestResult =
                '❌ Notification permission denied!\n\n'
                'Please enable notifications for this app:\n'
                '1. Go to Settings → Apps → Qibla Compass\n'
                '2. Tap Notifications\n'
                '3. Enable "Allow notifications"';
          });

          Get.snackbar(
            '⚠️ Permission Required',
            'Please enable notifications in app settings',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
          return;
        }
      }

      setState(() {
        _lastTestResult = 'Testing azan notification...';
      });

      await _notificationService.testAzanNotification();
      setState(() {
        _lastTestResult =
            '✅ Test notification sent!\n'
            'If you hear the azan sound, it\'s working correctly.\n'
            'Make sure alarm volume is turned up!';
      });

      Get.snackbar(
        '🔔 Test Sent',
        'Check if you hear the azan sound',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Error: $e';
      });

      Get.snackbar(
        '❌ Error',
        'Failed to send test notification',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testScheduledNotification() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Scheduling test notification in 10 seconds...';
    });

    try {
      final testTime = DateTime.now().add(const Duration(seconds: 10));

      // First check if we can schedule exact alarms
      final canScheduleExact = await AwesomeNotifications().checkPermissionList(
        permissions: [NotificationPermission.PreciseAlarms],
      );

      print('🔔 Can schedule exact alarms: ${canScheduleExact.isNotEmpty}');

      // Create notification with explicit schedule
      final result = await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 88888,
          channelKey: 'prayer_channel_v3',
          title: '🕌 Test Scheduled Notification',
          body: 'This was scheduled 10 seconds ago - Azan sound test',
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          customSound: 'resource://raw/azan',
        ),
        schedule: NotificationCalendar(
          year: testTime.year,
          month: testTime.month,
          day: testTime.day,
          hour: testTime.hour,
          minute: testTime.minute,
          second: testTime.second,
          millisecond: 0,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );

      print('🔔 Notification creation result: $result');

      // Verify it was scheduled
      await Future.delayed(const Duration(milliseconds: 500));
      final scheduledList = await AwesomeNotifications().listScheduledNotifications();
      final wasScheduled = scheduledList.any((n) => n.content?.id == 88888);

      print('🔔 Scheduled notifications count: ${scheduledList.length}');
      print('🔔 Was notification 88888 scheduled: $wasScheduled');

      for (var notif in scheduledList) {
        print('🔔 Scheduled: ID=${notif.content?.id}, Title=${notif.content?.title}');
      }

      setState(() {
        _lastTestResult =
            '${result ? "✅" : "❌"} Notification created: $result\n'
            '${wasScheduled ? "✅" : "❌"} Found in schedule: $wasScheduled\n'
            'Scheduled for: ${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')}:${testTime.second.toString().padLeft(2, '0')}\n'
            'Total scheduled: ${scheduledList.length}\n\n'
            'Wait 10 seconds for the notification...';
      });

      await _loadScheduledNotifications();

      Get.snackbar(
        '⏰ Scheduled',
        'Notification will appear in 10 seconds',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF2D1B69),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkChannels() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Checking notification channels...';
    });

    try {
      // Try to create a test notification on the channel to verify it exists
      final testResult = await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: -1,
          channelKey: 'prayer_channel_v3',
          title: 'Channel Check',
          body: 'Testing prayer_channel_v3',
          autoDismissible: true,
        ),
      );

      if (testResult) {
        setState(() {
          _lastTestResult =
              '✅ Channel Found: prayer_channel_v3\n'
              'The channel exists and is working!\n\n'
              'A test notification was sent to verify.\n'
              'If you saw it, the channel is properly configured.';
        });

        // Immediately dismiss the test notification
        await Future.delayed(const Duration(milliseconds: 500));
        await AwesomeNotifications().cancel(-1);
      } else {
        setState(() {
          _lastTestResult =
              '⚠️ Channel test failed!\n'
              'Could not create notification on prayer_channel_v3.\n\n'
              'Try reinstalling the app or clearing app data.';
        });
      }
    } catch (e) {
      setState(() {
        _lastTestResult =
            '❌ Error checking channel: $e\n\n'
            'This might mean the channel doesn\'t exist yet.\n'
            'Try creating a notification first.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Checking permissions...';
    });

    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      final canSchedule = await AwesomeNotifications().checkPermissionList(
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.CriticalAlert,
          NotificationPermission.FullScreenIntent,
          NotificationPermission.PreciseAlarms,
        ],
      );

      final hasPreciseAlarms = canSchedule.contains(NotificationPermission.PreciseAlarms);

      setState(() {
        _lastTestResult =
            '📋 Permission Status:\n\n'
            '${isAllowed ? "✅" : "❌"} Notifications Allowed: $isAllowed\n'
            '${canSchedule.contains(NotificationPermission.Alert) ? "✅" : "❌"} Alert\n'
            '${canSchedule.contains(NotificationPermission.Sound) ? "✅" : "❌"} Sound\n'
            '${canSchedule.contains(NotificationPermission.Badge) ? "✅" : "❌"} Badge\n'
            '${canSchedule.contains(NotificationPermission.Vibration) ? "✅" : "❌"} Vibration\n'
            '${canSchedule.contains(NotificationPermission.CriticalAlert) ? "✅" : "❌"} Critical Alert\n'
            '${canSchedule.contains(NotificationPermission.FullScreenIntent) ? "✅" : "❌"} Full Screen\n'
            '${hasPreciseAlarms ? "✅" : "⚠️"} Precise Alarms (for scheduling)\n\n'
            '${hasPreciseAlarms ? "" : "⚠️ IMPORTANT: Without Precise Alarms permission,\nscheduled notifications may not work!\nGo to App Settings > Alarms & Reminders"}';
      });

      if (!isAllowed) {
        Get.snackbar(
          '⚠️ Permissions Required',
          'Tap to enable notifications',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          onTap: (_) async {
            await AwesomeNotifications().requestPermissionToSendNotifications();
          },
        );
      }
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelAllNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.cancelAllNotifications();
      await _loadScheduledNotifications();

      Get.snackbar(
        '🗑️ Cancelled',
        'All scheduled notifications removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2D1B69),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to cancel notifications',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openChannelSettings() async {
    try {
      await AwesomeNotifications().showNotificationConfigPage(channelKey: 'prayer_channel_v3');
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Could not open settings: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _requestPreciseAlarmPermission() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Opening alarm permission settings...';
    });

    try {
      // Request precise alarm permission - this opens Android settings
      final granted = await AwesomeNotifications().requestPermissionToSendNotifications(
        permissions: [NotificationPermission.PreciseAlarms],
      );

      setState(() {
        _lastTestResult =
            '${granted ? "✅" : "⚠️"} Precise Alarms permission: $granted\n\n'
            'If not granted:\n'
            '1. Go to Settings > Apps > Muslim Pro\n'
            '2. Tap "Alarms & Reminders"\n'
            '3. Enable "Allow setting alarms"';
      });
    } catch (e) {
      setState(() {
        _lastTestResult =
            '❌ Error: $e\n\n'
            'Try manually:\n'
            '1. Go to Settings > Apps > Muslim Pro\n'
            '2. Tap "Alarms & Reminders"\n'
            '3. Enable "Allow setting alarms"';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D1B69), Color(0xFF8F66FF), Color(0xFFAB80FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Test Result Card
                      if (_lastTestResult.isNotEmpty) _buildResultCard(),

                      const SizedBox(height: 20),

                      // Quick Test Buttons
                      _buildSectionTitle('🔊 Sound Tests'),
                      const SizedBox(height: 12),
                      _buildTestButton(
                        icon: Icons.play_circle_filled,
                        title: 'Test Azan Sound (Instant)',
                        subtitle: 'Plays immediately with azan sound',
                        color: const Color(0xFFD4AF37),
                        onTap: _testAzanNotification,
                      ),
                      const SizedBox(height: 12),
                      _buildTestButton(
                        icon: Icons.schedule,
                        title: 'Test Scheduled (10 sec)',
                        subtitle: 'Schedules notification for 10 seconds',
                        color: const Color(0xFF00897B),
                        onTap: _testScheduledNotification,
                      ),

                      const SizedBox(height: 30),

                      // System Checks
                      _buildSectionTitle('🔍 System Checks'),
                      const SizedBox(height: 12),
                      _buildTestButton(
                        icon: Icons.notifications_active,
                        title: 'Check Channels',
                        subtitle: 'Verify prayer_channel_v3 exists',
                        color: const Color(0xFF2196F3),
                        onTap: _checkChannels,
                      ),
                      const SizedBox(height: 12),
                      _buildTestButton(
                        icon: Icons.security,
                        title: 'Check Permissions',
                        subtitle: 'View notification permissions',
                        color: const Color(0xFF9C27B0),
                        onTap: _checkPermissions,
                      ),
                      const SizedBox(height: 12),
                      _buildTestButton(
                        icon: Icons.settings,
                        title: 'Open Channel Settings',
                        subtitle: 'Android notification settings',
                        color: const Color(0xFF607D8B),
                        onTap: _openChannelSettings,
                      ),
                      const SizedBox(height: 12),
                      _buildTestButton(
                        icon: Icons.alarm,
                        title: 'Request Alarm Permission',
                        subtitle: 'Required for scheduled notifications',
                        color: const Color(0xFFFF5722),
                        onTap: _requestPreciseAlarmPermission,
                      ),

                      const SizedBox(height: 30),

                      // Scheduled Notifications
                      _buildSectionTitle('📅 Scheduled (${_scheduledNotifications.length})'),
                      const SizedBox(height: 12),
                      _buildScheduledList(),

                      const SizedBox(height: 20),

                      // Cancel All Button
                      if (_scheduledNotifications.isNotEmpty)
                        _buildTestButton(
                          icon: Icons.delete_sweep,
                          title: 'Cancel All Scheduled',
                          subtitle: 'Remove all pending notifications',
                          color: Colors.red,
                          onTap: _cancelAllNotifications,
                        ),

                      const SizedBox(height: 20),

                      // Tips Card
                      _buildTipsCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Test',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Test azan sound & channels',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 8),
              Text(
                'Last Test Result',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _lastTestResult,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildTestButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledList() {
    if (_scheduledNotifications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            'No scheduled notifications',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _scheduledNotifications.length,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
        itemBuilder: (context, index) {
          final notification = _scheduledNotifications[index];
          final schedule = notification.schedule;

          return ListTile(
            leading: const Icon(Icons.notifications, color: Color(0xFFD4AF37)),
            title: Text(
              notification.content?.title ?? 'No Title',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              'ID: ${notification.content?.id} | ${_formatSchedule(schedule)}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
          );
        },
      ),
    );
  }

  String _formatSchedule(NotificationSchedule? schedule) {
    if (schedule == null) return 'No schedule';
    if (schedule is NotificationCalendar) {
      return '${schedule.hour ?? 0}:${schedule.minute?.toString().padLeft(2, '0') ?? '00'}';
    }
    return 'Scheduled';
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFFD4AF37), size: 24),
              const SizedBox(width: 12),
              Text(
                'Troubleshooting Tips',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTip('Turn up ALARM volume (not notification volume)'),
          _buildTip('Make sure phone is not on silent/vibrate mode'),
          _buildTip('Check "Open Channel Settings" for sound configuration'),
          _buildTip('If sound doesn\'t play, clear app data and reinstall'),
          _buildTip('Test notification plays instantly, scheduled takes 10 sec'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
